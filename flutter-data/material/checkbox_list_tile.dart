// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'checkbox.dart';
import 'list_tile.dart';
import 'theme.dart';
import 'theme_data.dart';

// Examples can assume:
// void setState(VoidCallback fn) { }

/// A [ListTile] with a [Checkbox]. In other words, a checkbox with a label.
///
/// The entire list tile is interactive: tapping anywhere in the tile toggles
/// the checkbox.
///
/// The [value], [onChanged], [activeColor] and [checkColor] properties of this widget are
/// identical to the similarly-named properties on the [Checkbox] widget.
///
/// The [title], [subtitle], [isThreeLine], and [dense] properties are like
/// those of the same name on [ListTile].
///
/// The [selected] property on this widget is similar to the [ListTile.selected]
/// property, but the color used is that described by [activeColor], if any,
/// defaulting to the accent color of the current [Theme]. No effort is made to
/// coordinate the [selected] state and the [value] state; to have the list tile
/// appear selected when the checkbox is checked, pass the same value to both.
///
/// The checkbox is shown on the right by default in left-to-right languages
/// (i.e. the trailing edge). This can be changed using [controlAffinity]. The
/// [secondary] widget is placed on the opposite side. This maps to the
/// [ListTile.leading] and [ListTile.trailing] properties of [ListTile].
///
/// To show the [CheckboxListTile] as disabled, pass null as the [onChanged]
/// callback.
///
/// {@tool snippet --template=stateful_widget_scaffold_center}
///
/// ![CheckboxListTile sample](https://flutter.github.io/assets-for-api-docs/assets/material/checkbox_list_tile.png)
///
/// This widget shows a checkbox that, when checked, slows down all animations
/// (including the animation of the checkbox itself getting checked!).
///
/// This sample requires that you also import 'package:flutter/scheduler.dart',
/// so that you can reference [timeDilation].
///
/// ```dart imports
/// import 'package:flutter/scheduler.dart' show timeDilation;
/// ```
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return CheckboxListTile(
///     title: const Text('Animate Slowly'),
///     value: timeDilation != 1.0,
///     onChanged: (bool value) {
///       setState(() { timeDilation = value ? 10.0 : 1.0; });
///     },
///     secondary: const Icon(Icons.hourglass_empty),
///   );
/// }
/// ```
/// {@end-tool}
///
/// ## Semantics in CheckboxListTile
///
/// Since the entirety of the CheckboxListTile is interactive, it should represent
/// itself as a single interactive entity.
///
/// To do so, a CheckboxListTile widget wraps its children with a [MergeSemantics]
/// widget. [MergeSemantics] will attempt to merge its descendant [Semantics]
/// nodes into one node in the semantics tree. Therefore, CheckboxListTile will
/// throw an error if any of its children requires its own [Semantics] node.
///
/// For example, you cannot nest a [RichText] widget as a descendant of
/// CheckboxListTile. [RichText] has an embedded gesture recognizer that
/// requires its own [Semantics] node, which directly conflicts with
/// CheckboxListTile's desire to merge all its descendants' semantic nodes
/// into one. Therefore, it may be necessary to create a custom radio tile
/// widget to accommodate similar use cases.
///
/// {@tool snippet --template=stateful_widget_scaffold_center}
///
/// ![Checkbox list tile semantics sample](https://flutter.github.io/assets-for-api-docs/assets/material/checkbox_list_tile_semantics.png)
///
/// Here is an example of a custom labeled checkbox widget, called
/// LinkedLabelCheckbox, that includes an interactive [RichText] widget that
/// handles tap gestures.
///
/// ```dart imports
/// import 'package:flutter/gestures.dart';
/// ```
/// ```dart preamble
/// class LinkedLabelCheckbox extends StatelessWidget {
///   const LinkedLabelCheckbox({
///     this.label,
///     this.padding,
///     this.value,
///     this.onChanged,
///   });
///
///   final String label;
///   final EdgeInsets padding;
///   final bool value;
///   final Function onChanged;
///
///   @override
///   Widget build(BuildContext context) {
///     return Padding(
///       padding: padding,
///       child: Row(
///         children: <Widget>[
///           Expanded(
///             child: RichText(
///               text: TextSpan(
///                 text: label,
///                 style: TextStyle(
///                   color: Colors.blueAccent,
///                   decoration: TextDecoration.underline,
///                 ),
///                 recognizer: TapGestureRecognizer()
///                   ..onTap = () {
///                   print('Label has been tapped.');
///                 },
///               ),
///             ),
///           ),
///           Checkbox(
///             value: value,
///             onChanged: (bool newValue) {
///               onChanged(newValue);
///             },
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
/// ```dart
/// bool _isSelected = false;
///
/// @override
/// Widget build(BuildContext context) {
///   return LinkedLabelCheckbox(
///     label: 'Linked, tappable label text',
///     padding: const EdgeInsets.symmetric(horizontal: 20.0),
///     value: _isSelected,
///     onChanged: (bool newValue) {
///       setState(() {
///         _isSelected = newValue;
///       });
///     },
///   );
/// }
/// ```
/// {@end-tool}
///
/// ## CheckboxListTile isn't exactly what I want
///
/// If the way CheckboxListTile pads and positions its elements isn't quite
/// what you're looking for, you can create custom labeled checkbox widgets by
/// combining [Checkbox] with other widgets, such as [Text], [Padding] and
/// [InkWell].
///
/// {@tool snippet --template=stateful_widget_scaffold_center}
///
/// ![Custom checkbox list tile sample](https://flutter.github.io/assets-for-api-docs/assets/material/checkbox_list_tile_custom.png)
///
/// Here is an example of a custom LabeledCheckbox widget, but you can easily
/// make your own configurable widget.
///
/// ```dart preamble
/// class LabeledCheckbox extends StatelessWidget {
///   const LabeledCheckbox({
///     this.label,
///     this.padding,
///     this.value,
///     this.onChanged,
///   });
///
///   final String label;
///   final EdgeInsets padding;
///   final bool value;
///   final Function onChanged;
///
///   @override
///   Widget build(BuildContext context) {
///     return InkWell(
///       onTap: () {
///         onChanged(!value);
///       },
///       child: Padding(
///         padding: padding,
///         child: Row(
///           children: <Widget>[
///             Expanded(child: Text(label)),
///             Checkbox(
///               value: value,
///               onChanged: (bool newValue) {
///                 onChanged(newValue);
///               },
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```
/// ```dart
/// bool _isSelected = false;
///
/// @override
/// Widget build(BuildContext context) {
///   return LabeledCheckbox(
///     label: 'This is the label text',
///     padding: const EdgeInsets.symmetric(horizontal: 20.0),
///     value: _isSelected,
///     onChanged: (bool newValue) {
///       setState(() {
///         _isSelected = newValue;
///       });
///     },
///   );
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [ListTileTheme], which can be used to affect the style of list tiles,
///    including checkbox list tiles.
///  * [RadioListTile], a similar widget for radio buttons.
///  * [SwitchListTile], a similar widget for switches.
///  * [ListTile] and [Checkbox], the widgets from which this widget is made.
class CheckboxListTile extends StatelessWidget {
  /// Creates a combination of a list tile and a checkbox.
  ///
  /// The checkbox tile itself does not maintain any state. Instead, when the
  /// state of the checkbox changes, the widget calls the [onChanged] callback.
  /// Most widgets that use a checkbox will listen for the [onChanged] callback
  /// and rebuild the checkbox tile with a new [value] to update the visual
  /// appearance of the checkbox.
  ///
  /// The following arguments are required:
  ///
  /// * [value], which determines whether the checkbox is checked, and must not
  ///   be null.
  ///
  /// * [onChanged], which is called when the value of the checkbox should
  ///   change. It can be set to null to disable the checkbox.
  const CheckboxListTile({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.activeColor,
    this.checkColor,
    this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
  })  : assert(value != null),
        assert(isThreeLine != null),
        assert(!isThreeLine || subtitle != null),
        assert(selected != null),
        assert(controlAffinity != null),
        super(key: key);

  /// Whether this checkbox is checked.
  ///
  /// This property must not be null.
  final bool value;

  /// Called when the value of the checkbox should change.
  ///
  /// The checkbox passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the checkbox tile with the
  /// new value.
  ///
  /// If null, the checkbox will be displayed as disabled.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// ```dart
  /// CheckboxListTile(
  ///   value: _throwShotAway,
  ///   onChanged: (bool newValue) {
  ///     setState(() {
  ///       _throwShotAway = newValue;
  ///     });
  ///   },
  ///   title: Text('Throw away your shot'),
  /// )
  /// ```
  final ValueChanged<bool> onChanged;

  /// The color to use when this checkbox is checked.
  ///
  /// Defaults to accent color of the current [Theme].
  final Color activeColor;

  /// The color to use for the check icon when this checkbox is checked.
  ///
  /// Defaults to Color(0xFFFFFFFF).
  final Color checkColor;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget subtitle;

  /// A widget to display on the opposite side of the tile from the checkbox.
  ///
  /// Typically an [Icon] widget.
  final Widget secondary;

  /// Whether this list tile is intended to display three lines of text.
  ///
  /// If false, the list tile is treated as having one line if the subtitle is
  /// null and treated as having two lines if the subtitle is non-null.
  final bool isThreeLine;

  /// Whether this list tile is part of a vertically dense list.
  ///
  /// If this property is null then its value is based on [ListTileTheme.dense].
  final bool dense;

  /// Whether to render icons and text in the [activeColor].
  ///
  /// No effort is made to automatically coordinate the [selected] state and the
  /// [value] state. To have the list tile appear selected when the checkbox is
  /// checked, pass the same value to both.
  ///
  /// Normally, this property is left to its default value, false.
  final bool selected;

  /// Where to place the control relative to the text.
  final ListTileControlAffinity controlAffinity;

  @override
  Widget build(BuildContext context) {
    final Widget control = Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      checkColor: checkColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    Widget leading, trailing;
    switch (controlAffinity) {
      case ListTileControlAffinity.leading:
        leading = control;
        trailing = secondary;
        break;
      case ListTileControlAffinity.trailing:
      case ListTileControlAffinity.platform:
        leading = secondary;
        trailing = control;
        break;
    }
    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: activeColor ?? Theme.of(context).accentColor,
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          isThreeLine: isThreeLine,
          dense: dense,
          enabled: onChanged != null,
          onTap: onChanged != null
              ? () {
                  onChanged(!value);
                }
              : null,
          selected: selected,
        ),
      ),
    );
  }
}
