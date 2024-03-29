// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Defines the visual properties of [Divider], [VerticalDivider], dividers
/// between [ListTile]s, and dividers between rows in [DataTable]s.
///
/// Descendant widgets obtain the current [DividerThemeData] object using
/// `DividerTheme.of(context)`. Instances of [DividerThemeData]
/// can be customized with [DividerThemeData.copyWith].
///
/// Typically a [DividerThemeData] is specified as part of the overall
/// [Theme] with [ThemeData.dividerTheme].
///
/// All [DividerThemeData] properties are `null` by default. When null,
/// the widgets will provide their own defaults.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
class DividerThemeData extends Diagnosticable {
  /// Creates a theme that can be used for [DividerTheme] or
  /// [ThemeData.dividerTheme].
  const DividerThemeData({
    this.color,
    this.space,
    this.thickness,
    this.indent,
    this.endIndent,
  });

  /// The color of [Divider]s and [VerticalDivider]s, also
  /// used between [ListTile]s, between rows in [DataTable]s, and so forth.
  final Color color;

  /// The [Divider]'s width or the [VerticalDivider]'s height.
  ///
  /// This represents the amount of horizontal or vertical space the divider
  /// takes up.
  final double space;

  /// The thickness of the line drawn within the divider.
  final double thickness;

  /// The amount of empty space at the leading edge of [Divider] or top edge of
  /// [VerticalDivider].
  final double indent;

  /// The amount of empty space at the trailing edge of [Divider] or bottom edge
  /// of [VerticalDivider].
  final double endIndent;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  DividerThemeData copyWith({
    Color color,
    double space,
    double thickness,
    double indent,
    double endIndent,
  }) {
    return DividerThemeData(
      color: color ?? this.color,
      space: space ?? this.space,
      thickness: thickness ?? this.thickness,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
    );
  }

  /// Linearly interpolate between two Divider themes.
  ///
  /// The argument `t` must not be null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static DividerThemeData lerp(
      DividerThemeData a, DividerThemeData b, double t) {
    assert(t != null);
    return DividerThemeData(
      color: Color.lerp(a?.color, b?.color, t),
      space: lerpDouble(a?.space, b?.space, t),
      thickness: lerpDouble(a?.thickness, b?.thickness, t),
      indent: lerpDouble(a?.indent, b?.indent, t),
      endIndent: lerpDouble(a?.endIndent, b?.endIndent, t),
    );
  }

  @override
  int get hashCode {
    return hashValues(
      color,
      space,
      thickness,
      indent,
      endIndent,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final DividerThemeData typedOther = other;
    return typedOther.color == color &&
        typedOther.space == space &&
        typedOther.thickness == thickness &&
        typedOther.indent == indent &&
        typedOther.endIndent == endIndent;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(DoubleProperty('space', space, defaultValue: null));
    properties.add(DoubleProperty('thickness', thickness, defaultValue: null));
    properties.add(DoubleProperty('indent', indent, defaultValue: null));
    properties.add(DoubleProperty('endIndent', endIndent, defaultValue: null));
  }
}

/// An inherited widget that defines the configuration for
/// [Divider]s, [VerticalDividers]s, dividers between [ListTile]s, and dividers
/// between rows in [DataTable]s in this widget's subtree.
class DividerTheme extends InheritedTheme {
  /// Creates a divider theme that controls the configurations for
  /// [Divider]s, [VerticalDividers]s, dividers between [ListTile]s, and dividers
  /// between rows in [DataTable]s in its widget subtree.
  const DividerTheme({
    Key key,
    @required this.data,
    Widget child,
  })  : assert(data != null),
        super(key: key, child: child);

  /// The properties for descendant [Divider]s, [VerticalDividers]s, dividers
  /// between [ListTile]s, and dividers between rows in [DataTable]s.
  final DividerThemeData data;

  /// The closest instance of this class's [data] value that encloses the given
  /// context.
  ///
  /// If there is no ancestor, it returns [ThemeData.dividerTheme]. Applications
  /// can assume that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// DividerThemeData theme = DividerTheme.of(context);
  /// ```
  static DividerThemeData of(BuildContext context) {
    final DividerTheme dividerTheme =
        context.dependOnInheritedWidgetOfExactType<DividerTheme>();
    return dividerTheme?.data ?? Theme.of(context).dividerTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    final DividerTheme ancestorTheme =
        context.findAncestorWidgetOfExactType<DividerTheme>();
    return identical(this, ancestorTheme)
        ? child
        : DividerTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(DividerTheme oldWidget) => data != oldWidget.data;
}
