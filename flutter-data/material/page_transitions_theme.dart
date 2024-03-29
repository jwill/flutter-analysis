// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'theme.dart';

// Slides the page upwards and fades it in, starting from 1/4 screen
// below the top.
class _FadeUpwardsPageTransition extends StatelessWidget {
  _FadeUpwardsPageTransition({
    Key key,
    @required
        Animation<double>
            routeAnimation, // The route's linear 0.0 - 1.0 animation.
    @required this.child,
  })  : _positionAnimation =
            routeAnimation.drive(_bottomUpTween.chain(_fastOutSlowInTween)),
        _opacityAnimation = routeAnimation.drive(_easeInTween),
        super(key: key);

  // Fractional offset from 1/4 screen below the top to fully on screen.
  static final Tween<Offset> _bottomUpTween = Tween<Offset>(
    begin: const Offset(0.0, 0.25),
    end: Offset.zero,
  );
  static final Animatable<double> _fastOutSlowInTween =
      CurveTween(curve: Curves.fastOutSlowIn);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);

  final Animation<Offset> _positionAnimation;
  final Animation<double> _opacityAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _positionAnimation,
      // TODO(ianh): tell the transform to be un-transformed for hit testing
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: child,
      ),
    );
  }
}

// This transition is intended to match the default for Android P.
class _OpenUpwardsPageTransition extends StatelessWidget {
  const _OpenUpwardsPageTransition({
    Key key,
    this.animation,
    this.secondaryAnimation,
    this.child,
  }) : super(key: key);

  // The new page slides upwards just a little as its clip
  // rectangle exposes the page from bottom to top.
  static final Tween<Offset> _primaryTranslationTween = Tween<Offset>(
    begin: const Offset(0.0, 0.05),
    end: Offset.zero,
  );

  // The old page slides upwards a little as the new page appears.
  static final Tween<Offset> _secondaryTranslationTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, -0.025),
  );

  // The scrim obscures the old page by becoming increasingly opaque.
  static final Tween<double> _scrimOpacityTween = Tween<double>(
    begin: 0.0,
    end: 0.25,
  );

  // Used by all of the transition animations.
  static const Curve _transitionCurve = Cubic(0.20, 0.00, 0.00, 1.00);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = constraints.biggest;

        final CurvedAnimation primaryAnimation = CurvedAnimation(
          parent: animation,
          curve: _transitionCurve,
          reverseCurve: _transitionCurve.flipped,
        );

        // Gradually expose the new page from bottom to top.
        final Animation<double> clipAnimation = Tween<double>(
          begin: 0.0,
          end: size.height,
        ).animate(primaryAnimation);

        final Animation<double> opacityAnimation =
            _scrimOpacityTween.animate(primaryAnimation);
        final Animation<Offset> primaryTranslationAnimation =
            _primaryTranslationTween.animate(primaryAnimation);

        final Animation<Offset> secondaryTranslationAnimation =
            _secondaryTranslationTween.animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: _transitionCurve,
            reverseCurve: _transitionCurve.flipped,
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget child) {
            return Container(
              color: Colors.black.withOpacity(opacityAnimation.value),
              alignment: Alignment.bottomLeft,
              child: ClipRect(
                child: SizedBox(
                  height: clipAnimation.value,
                  child: OverflowBox(
                    alignment: Alignment.bottomLeft,
                    maxHeight: size.height,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: AnimatedBuilder(
            animation: secondaryAnimation,
            child: FractionalTranslation(
              translation: primaryTranslationAnimation.value,
              child: child,
            ),
            builder: (BuildContext context, Widget child) {
              return FractionalTranslation(
                translation: secondaryTranslationAnimation.value,
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}

// Zooms and fades a new page in, zooming out the previous page. This transition
// is designed to match the Android 10 activity transition.
class _ZoomPageTransition extends StatefulWidget {
  const _ZoomPageTransition({
    Key key,
    this.animation,
    this.secondaryAnimation,
    this.child,
  }) : super(key: key);

  // The scrim obscures the old page by becoming increasingly opaque.
  static final Tween<double> _scrimOpacityTween = Tween<double>(
    begin: 0.0,
    end: 0.60,
  );

  // A curve sequence that is similar to the 'fastOutExtraSlowIn' curve used in
  // the native transition.
  static final List<TweenSequenceItem<double>>
      fastOutExtraSlowInTweenSequenceItems = <TweenSequenceItem<double>>[
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: 0.0, end: 0.4)
          .chain(CurveTween(curve: const Cubic(0.05, 0.0, 0.133333, 0.06))),
      weight: 0.166666,
    ),
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: 0.4, end: 1.0)
          .chain(CurveTween(curve: const Cubic(0.208333, 0.82, 0.25, 1.0))),
      weight: 1.0 - 0.166666,
    ),
  ];
  static final TweenSequence<double> _scaleCurveSequence =
      TweenSequence<double>(fastOutExtraSlowInTweenSequenceItems);
  static final FlippedTweenSequence _flippedScaleCurveSequence =
      FlippedTweenSequence(fastOutExtraSlowInTweenSequenceItems);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  __ZoomPageTransitionState createState() => __ZoomPageTransitionState();
}

class __ZoomPageTransitionState extends State<_ZoomPageTransition> {
  AnimationStatus _currentAnimationStatus;
  AnimationStatus _lastAnimationStatus;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener((AnimationStatus animationStatus) {
      _lastAnimationStatus = _currentAnimationStatus;
      _currentAnimationStatus = animationStatus;
    });
  }

  // This check ensures that the animation reverses the original animation if
  // the transition were interruped midway. This prevents a disjointed
  // experience since the reverse animation uses different fade and scaling
  // curves.
  bool get _transitionWasInterrupted {
    bool wasInProgress = false;
    bool isInProgress = false;

    switch (_currentAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        isInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        isInProgress = true;
        break;
    }
    switch (_lastAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        wasInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        wasInProgress = true;
        break;
    }
    return wasInProgress && isInProgress;
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> _forwardScrimOpacityAnimation = widget.animation
        .drive(_ZoomPageTransition._scrimOpacityTween
            .chain(CurveTween(curve: const Interval(0.2075, 0.4175))));

    final Animation<double> _forwardEndScreenScaleTransition = widget.animation
        .drive(Tween<double>(begin: 0.85, end: 1.00)
            .chain(_ZoomPageTransition._scaleCurveSequence));

    final Animation<double> _forwardStartScreenScaleTransition =
        widget.secondaryAnimation.drive(Tween<double>(begin: 1.00, end: 1.05)
            .chain(_ZoomPageTransition._scaleCurveSequence));

    final Animation<double> _forwardEndScreenFadeTransition = widget.animation
        .drive(Tween<double>(begin: 0.0, end: 1.00)
            .chain(CurveTween(curve: const Interval(0.125, 0.250))));

    final Animation<double> _reverseEndScreenScaleTransition =
        widget.secondaryAnimation.drive(Tween<double>(begin: 1.00, end: 1.10)
            .chain(_ZoomPageTransition._flippedScaleCurveSequence));

    final Animation<double> _reverseStartScreenScaleTransition =
        widget.animation.drive(Tween<double>(begin: 0.9, end: 1.0)
            .chain(_ZoomPageTransition._flippedScaleCurveSequence));

    final Animation<double> _reverseStartScreenFadeTransition = widget.animation
        .drive(Tween<double>(begin: 0.0, end: 1.00)
            .chain(CurveTween(curve: const Interval(1 - 0.2075, 1 - 0.0825))));

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget child) {
        if (widget.animation.status == AnimationStatus.forward ||
            _transitionWasInterrupted) {
          return Container(
            color:
                Colors.black.withOpacity(_forwardScrimOpacityAnimation.value),
            child: FadeTransition(
              opacity: _forwardEndScreenFadeTransition,
              child: ScaleTransition(
                scale: _forwardEndScreenScaleTransition,
                child: child,
              ),
            ),
          );
        } else if (widget.animation.status == AnimationStatus.reverse) {
          return ScaleTransition(
            scale: _reverseStartScreenScaleTransition,
            child: FadeTransition(
              opacity: _reverseStartScreenFadeTransition,
              child: child,
            ),
          );
        }
        return child;
      },
      child: AnimatedBuilder(
        animation: widget.secondaryAnimation,
        builder: (BuildContext context, Widget child) {
          if (widget.secondaryAnimation.status == AnimationStatus.forward ||
              _transitionWasInterrupted) {
            return ScaleTransition(
              scale: _forwardStartScreenScaleTransition,
              child: child,
            );
          } else if (widget.secondaryAnimation.status ==
              AnimationStatus.reverse) {
            return ScaleTransition(
              scale: _reverseEndScreenScaleTransition,
              child: child,
            );
          }
          return child;
        },
        child: widget.child,
      ),
    );
  }
}

/// Used by [PageTransitionsTheme] to define a [MaterialPageRoute] page
/// transition animation.
///
/// Apps can configure the map of builders for [ThemeData.platformTheme]
/// to customize the default [MaterialPageRoute] page transition animation
/// for different platforms.
///
/// See also:
///
///  * [FadeUpwardsPageTransitionsBuilder], which defines a default page transition.
///  * [OpenUpwardsPageTransitionsBuilder], which defines a page transition
///    that's similar to the one provided by Android P.
///  * [ZoomPageTransitionsBuilder], which defines a page transition similar
///    to the one provided in Android 10.
///  * [CupertinoPageTransitionsBuilder], which defines a horizontal page
///    transition that matches native iOS page transitions.
abstract class PageTransitionsBuilder {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const PageTransitionsBuilder();

  /// Wraps the child with one or more transition widgets which define how [route]
  /// arrives on and leaves the screen.
  ///
  /// The [MaterialPageRoute.buildTransitions] method looks up the current
  /// current [PageTransitionsTheme] with `Theme.of(context).pageTransitionsTheme`
  /// and delegates to this method with a [PageTransitionsBuilder] based
  /// on the theme's [ThemeData.platform].
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  );
}

/// Used by [PageTransitionsTheme] to define a default [MaterialPageRoute] page
/// transition animation.
///
/// The default animation fades the new page in while translating it upwards,
/// starting from about 25% below the top of the screen.
///
/// See also:
///
///  * [OpenUpwardsPageTransitionsBuilder], which defines a page transition
///    that's similar to the one provided by Android P.
///  * [ZoomPageTransitionsBuilder], which defines a page transition similar
///    to the one provided in Android 10.
///  * [CupertinoPageTransitionsBuilder], which defines a horizontal page
///    transition that matches native iOS page transitions.
class FadeUpwardsPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Construct a [FadeUpwardsPageTransitionsBuilder].
  const FadeUpwardsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _FadeUpwardsPageTransition(routeAnimation: animation, child: child);
  }
}

/// Used by [PageTransitionsTheme] to define a vertical [MaterialPageRoute] page
/// transition animation that looks like the default page transition
/// used on Android P.
///
/// See also:
///
///  * [FadeUpwardsPageTransitionsBuilder], which defines a default page transition.
///  * [ZoomPageTransitionsBuilder], which defines a page transition similar
///    to the one provided in Android 10.
///  * [CupertinoPageTransitionsBuilder], which defines a horizontal page
///    transition that matches native iOS page transitions.
class OpenUpwardsPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Construct a [OpenUpwardsPageTransitionsBuilder].
  const OpenUpwardsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _OpenUpwardsPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Used by [PageTransitionsTheme] to define a zooming [MaterialPageRoute] page
/// transition animation that looks like the default page transition used on
/// Android 10.
///
/// See also:
///
///  * [FadeUpwardsPageTransitionsBuilder], which defines a default page transition.
///  * [OpenUpwardsPageTransitionsBuilder], which defines a page transition
///    similar to the one provided by Android P.
///  * [CupertinoPageTransitionsBuilder], which defines a horizontal page
///    transition that matches native iOS page transitions.
class ZoomPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Construct a [ZoomPageTransitionsBuilder].
  const ZoomPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _ZoomPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Used by [PageTransitionsTheme] to define a horizontal [MaterialPageRoute]
/// page transition animation that matches native iOS page transitions.
///
/// See also:
///
///  * [FadeUpwardsPageTransitionsBuilder], which defines a default page transition.
///  * [OpenUpwardsPageTransitionsBuilder], which defines a page transition
///    that's similar to the one provided by Android P.
///  * [ZoomPageTransitionsBuilder], which defines a page transition similar
///    to the one provided in Android 10.
class CupertinoPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Construct a [CupertinoPageTransitionsBuilder].
  const CupertinoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoPageRoute.buildPageTransitions<T>(
        route, context, animation, secondaryAnimation, child);
  }
}

/// Defines the page transition animations used by [MaterialPageRoute]
/// for different [TargetPlatform]s.
///
/// The [MaterialPageRoute.buildTransitions] method looks up the current
/// current [PageTransitionsTheme] with `Theme.of(context).pageTransitionsTheme`
/// and delegates to [buildTransitions].
///
/// If a builder with a matching platform is not found, then the
/// [FadeUpwardsPageTransitionsBuilder] is used.
///
/// See also:
///
///  * [ThemeData.pageTransitionsTheme], which defines the default page
///    transitions for the overall theme.
///  * [FadeUpwardsPageTransitionsBuilder], which defines a default page transition.
///  * [OpenUpwardsPageTransitionsBuilder], which defines a page transition
///    that's similar to the one provided by Android P.
///  * [CupertinoPageTransitionsBuilder], which defines a horizontal page
///    transition that matches native iOS page transitions.
@immutable
class PageTransitionsTheme extends Diagnosticable {
  /// Construct a PageTransitionsTheme.
  ///
  /// By default the list of builders is: [FadeUpwardsPageTransitionsBuilder],
  /// [CupertinoPageTransitionsBuilder] for [TargetPlatform.android]
  /// and [TargetPlatform.iOS] respectively.
  const PageTransitionsTheme(
      {Map<TargetPlatform, PageTransitionsBuilder> builders})
      : _builders = builders;

  static const Map<TargetPlatform, PageTransitionsBuilder> _defaultBuilders =
      <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  };

  /// The [PageTransitionsBuilder]s supported by this theme.
  Map<TargetPlatform, PageTransitionsBuilder> get builders =>
      _builders ?? _defaultBuilders;
  final Map<TargetPlatform, PageTransitionsBuilder> _builders;

  /// Delegates to the builder for the current [ThemeData.platform]
  /// or [FadeUpwardsPageTransitionsBuilder].
  ///
  /// [MaterialPageRoute.buildTransitions] delegates to this method.
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    TargetPlatform platform = Theme.of(context).platform;

    if (CupertinoPageRoute.isPopGestureInProgress(route))
      platform = TargetPlatform.iOS;

    final PageTransitionsBuilder matchingBuilder =
        builders[platform] ?? const FadeUpwardsPageTransitionsBuilder();
    return matchingBuilder.buildTransitions<T>(
        route, context, animation, secondaryAnimation, child);
  }

  // Just used to the builders Map to a list with one PageTransitionsBuilder per platform
  // for the operator == overload.
  List<PageTransitionsBuilder> _all(
      Map<TargetPlatform, PageTransitionsBuilder> builders) {
    return TargetPlatform.values
        .map((TargetPlatform platform) => builders[platform])
        .toList();
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final PageTransitionsTheme typedOther = other;
    if (identical(builders, other.builders)) return true;
    return listEquals<PageTransitionsBuilder>(
        _all(builders), _all(typedOther.builders));
  }

  @override
  int get hashCode => hashList(_all(builders));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Map<TargetPlatform, PageTransitionsBuilder>>(
        'builders',
        builders,
        defaultValue: PageTransitionsTheme._defaultBuilders,
      ),
    );
  }
}
