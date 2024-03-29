// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(
        (context ?? SecurityContext())..setTrustedCertificatesBytes(certificate.codeUnits)
    );
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  final SecurityContext serverContext = SecurityContext()
    ..useCertificateChainBytes(certificate.codeUnits)
    ..usePrivateKeyBytes(privateKey.codeUnits);

  final HttpServer httpServer =
      await HttpServer.bindSecure('localhost', 0, serverContext);
  final int port = httpServer.port;
  print('Listening on port $port.');

  // Initializes bindings before using any platform channels.
  WidgetsFlutterBinding.ensureInitialized();
  final ByteData byteData = await rootBundle.load('images/coast.jpg');
  httpServer.listen((HttpRequest request) async {
    const int chunk_size = 2048;
    int offset = byteData.offsetInBytes;
    while (offset < byteData.lengthInBytes) {
      final int length = min(byteData.lengthInBytes - offset, chunk_size);
      final Uint8List bytes = byteData.buffer.asUint8List(offset, length);
      offset += length;
      request.response.add(bytes);
      // Let other isolates and microtasks to run.
      await Future<void>.delayed(const Duration());
    }
    request.response.close();
  });

  runApp(MyApp(port));
}

const int IMAGES = 50;

@immutable
class MyApp extends StatelessWidget {
  const MyApp(this.port);

  final int port;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', port: port),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title, this.port}) : super(key: key);
  final String title;
  final int port;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Widget createImage(final int index, final Completer<bool> completer) {
    return Image.network(
        'https://localhost:${widget.port}/${_counter * IMAGES + index}',
        frameBuilder: (
          BuildContext context,
          Widget child,
          int frame,
          bool wasSynchronouslyLoaded,
        ) {
          if (frame == 0 && !completer.isCompleted) {
            completer.complete(true);
          }
          return child;
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<AnimationController> controllers = List<AnimationController>(IMAGES);
    for (int i = 0; i < IMAGES; i++) {
      controllers[i] = AnimationController(
        duration: const Duration(milliseconds: 3600),
        vsync: this,
      )..repeat();
    }
    final List<Completer<bool>> completers = List<Completer<bool>>(IMAGES);
    for (int i = 0; i < IMAGES; i++) {
      completers[i] = Completer<bool>();
    }
    final List<Future<bool>> futures = completers.map(
        (Completer<bool> completer) => completer.future).toList();
    final DateTime started = DateTime.now();
    Future.wait(futures).then((_) {
      print(
          '===image_list=== all loaded in ${DateTime.now().difference(started).inMilliseconds}ms.');
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(children: createImageList(IMAGES, completers, controllers)),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  List<Widget> createImageList(int count, List<Completer<bool>> completers,
      List<AnimationController> controllers) {
    final List<Widget> list = <Widget>[];
    for (int i = 0; i < count; i++) {
      list.add(Flexible(
          fit: FlexFit.tight,
          flex: i + 1,
          child: RotationTransition(
              turns: controllers[i],
              child: createImage(i + 1, completers[i]))));
    }
    return list;
  }
}
