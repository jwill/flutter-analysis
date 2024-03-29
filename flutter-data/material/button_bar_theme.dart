// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'button_theme.dart';
import 'theme.dart';

/// Defines the visual properties of [ButtonBar] widgets.
///
/// Used by [ButtonBarTheme] to control the visual properties of [ButtonBar]
/// instances in a widget subtree.
///
/// To obtain this configuration, use [ButtonBarTheme.of] to access the closest
/// ancestor [ButtonBarTheme] of the current [BuildContext].
///
/// See also:
///
///   * [ButtonBarTheme], an [InheritedWidget] that propagates the theme down
///     its subtree.
///   * [ButtonBar], which uses this to configure itself and its children
///     button widgets.
class ButtonBarThemeData extends Diagnosticable {
  /// Constructs the set of properties used to configure [ButtonBar] widgets.
  ///
  /// Both [buttonMinWidth] and [buttonHeight] must be non-negative if they
  /// are not null.
  const ButtonBarThemeData({
    this.alignment,
    this.mainAxisSize,
    this.buttonTextTheme,
    this.buttonMinWidth,
    this.buttonHeight,
    this.buttonPadding,
    this.buttonAlignedDropdown,
    this.layoutBehavior,
  })  : assert(buttonMinWidth == null || buttonMinWidth >= 0.0),
        assert(buttonHeight == null || buttonHeight >= 0.0);

  /// How the children should be placed along the horizontal axis.
  final MainAxisAlignment alignment;

  /// How much horizontal space is available. See [Row.mainAxisSize].
  final MainAxisSize mainAxisSize;

  /// Defines a [ButtonBar] button's base colors, and the defaults for
  /// the button's minimum size, internal padding, and shape.
  ///
  /// This will override the surrounding [ButtonTheme.textTheme] setting
  /// for buttons contained in the [ButtonBar].
  ///
  /// Despite the name, this property is not a [TextTheme], its value is not a
  /// collection of [TextStyle]s.
  final ButtonTextTheme buttonTextTheme;

  /// The minimum width for [ButtonBar] buttons.
  ///
  /// This will override the surrounding [ButtonTheme.minWidth] setting
  /// for buttons contained in the [ButtonBar].
  ///
  /// The actual horizontal space allocated for a button's child is
  /// at least this value less the theme's horizontal [padding].
  final double buttonMinWidth;

  /// The minimum height for [ButtonBar] buttons.
  ///
  /// This will override the surrounding [ButtonTheme.height] setting
  /// for buttons contained in the [ButtonBar].
  final double buttonHeight;

  /// Padding for a [ButtonBar] button's child (typically the button's label).
  ///
  /// This will override the surrounding [ButtonTheme.padding] setting
  /// for buttons contained in the [ButtonBar].
  final EdgeInsetsGeometry buttonPadding;

  /// If true, then a [DropdownButton] menu's width will match the [ButtonBar]
  /// button's width.
  ///
  /// If false, then the dropdown's menu will be wider than
  /// its button. In either case the dropdown button will line up the leading
  /// edge of the menu's value with the leading edge of the values
  /// displayed by the menu items.
  ///
  /// This will override the surrounding [ButtonTheme.alignedDropdown] setting
  /// for buttons contained in the [ButtonBar].
  ///
  /// This property only affects [DropdownButton] contained in a [ButtonBar]
  /// and its menu.
  final bool buttonAlignedDropdown;

  /// Defines whether a [ButtonBar] should size itself with a minimum size
  /// constraint or with padding.
  final ButtonBarLayoutBehavior layoutBehavior;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  ButtonBarThemeData copyWith({
    MainAxisAlignment alignment,
    MainAxisSize mainAxisSize,
    ButtonTextTheme buttonTextTheme,
    double buttonMinWidth,
    double buttonHeight,
    EdgeInsetsGeometry buttonPadding,
    bool buttonAlignedDropdown,
    ButtonBarLayoutBehavior layoutBehavior,
  }) {
    return ButtonBarThemeData(
      alignment: alignment ?? this.alignment,
      mainAxisSize: mainAxisSize ?? this.mainAxisSize,
      buttonTextTheme: buttonTextTheme ?? this.buttonTextTheme,
      buttonMinWidth: buttonMinWidth ?? this.buttonMinWidth,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      buttonAlignedDropdown:
          buttonAlignedDropdown ?? this.buttonAlignedDropdown,
      layoutBehavior: layoutBehavior ?? this.layoutBehavior,
    );
  }

  /// Linearly interpolate between two button bar themes.
  ///
  /// If both arguments are null, then null is returned.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static ButtonBarThemeData lerp(
      ButtonBarThemeData a, ButtonBarThemeData b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    return ButtonBarThemeData(
      alignment: t < 0.5 ? a.alignment : b.alignment,
      mainAxisSize: t < 0.5 ? a.mainAxisSize : b.mainAxisSize,
      buttonTextTheme: t < 0.5 ? a.buttonTextTheme : b.buttonTextTheme,
      buttonMinWidth: lerpDouble(a?.buttonMinWidth, b?.buttonMinWidth, t),
      buttonHeight: lerpDouble(a?.buttonHeight, b?.buttonHeight, t),
      buttonPadding: EdgeInsets.lerp(a?.buttonPadding, b?.buttonPadding, t),
      buttonAlignedDropdown:
          t < 0.5 ? a.buttonAlignedDropdown : b.buttonAlignedDropdown,
      layoutBehavior: t < 0.5 ? a.layoutBehavior : b.layoutBehavior,
    );
  }

  @override
  int get hashCode {
    return hashValues(
      alignment,
      mainAxisSize,
      buttonTextTheme,
      buttonMinWidth,
      buttonHeight,
      buttonPadding,
      buttonAlignedDropdown,
      layoutBehavior,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final ButtonBarThemeData typedOther = other;
    return typedOther.alignment == alignment &&
        typedOther.mainAxisSize == mainAxisSize &&
        typedOther.buttonTextTheme == buttonTextTheme &&
        typedOther.buttonMinWidth == buttonMinWidth &&
        typedOther.buttonHeight == buttonHeight &&
        typedOther.buttonPadding == buttonPadding &&
        typedOther.buttonAlignedDropdown == buttonAlignedDropdown &&
        typedOther.layoutBehavior == layoutBehavior;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<MainAxisAlignment>(
        'alignment', alignment,
        defaultValue: null));
    properties.add(DiagnosticsProperty<MainAxisSize>(
        'mainAxisSize', mainAxisSize,
        defaultValue: null));
    properties.add(DiagnosticsProperty<ButtonTextTheme>(
        'textTheme', buttonTextTheme,
        defaultValue: null));
    properties
        .add(DoubleProperty('minWidth', buttonMinWidth, defaultValue: null));
    properties.add(DoubleProperty('height', buttonHeight, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
        'padding', buttonPadding,
        defaultValue: null));
    properties.add(FlagProperty('buttonAlignedDropdown',
        value: buttonAlignedDropdown,
        ifTrue: 'dropdown width matches button',
        defaultValue: null));
    properties.add(DiagnosticsProperty<ButtonBarLayoutBehavior>(
        'layoutBehavior', layoutBehavior,
        defaultValue: null));
  }
}

/// Applies a button bar theme to descendant [ButtonBar] widgets.
///
/// A button bar theme describes the layout and properties for the buttons
/// contained in a [ButtonBar].
///
/// Descendant widgets obtain the current theme's [ButtonBarTheme] object using
/// [ButtonBarTheme.of]. When a widget uses [ButtonBarTheme.of], it is automatically
/// rebuilt if the theme later changes.
///
/// A button bar theme can be specified as part of the overall Material theme
/// using [ThemeData.buttonBarTheme].
///
/// See also:
///
///  * [ButtonBarThemeData], which describes the actual configuration of a button
///    bar theme.
class ButtonBarTheme extends InheritedWidget {
  /// Constructs a button bar theme that configures all descendent [ButtonBar]
  /// widgets.
  ///
  /// The [data] must not be null.
  const ButtonBarTheme({
    Key key,
    @required this.data,
    Widget child,
  })  : assert(data != null),
        super(key: key, child: child);

  /// The properties used for all descendant [ButtonBar] widgets.
  final ButtonBarThemeData data;

  /// Returns the configuration [data] from the closest [ButtonBarTheme]
  /// ancestor. If there is no ancestor, it returns [ThemeData.buttonBarTheme].
  /// Applications can assume that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ButtonBarThemeData theme = ButtonBarTheme.of(context);
  /// ```
  static ButtonBarThemeData of(BuildContext context) {
    final ButtonBarTheme buttonBarTheme =
        context.dependOnInheritedWidgetOfExactType<ButtonBarTheme>();
    return buttonBarTheme?.data ?? Theme.of(context).buttonBarTheme;
  }

  @override
  bool updateShouldNotify(ButtonBarTheme oldWidget) => data != oldWidget.data;
}
