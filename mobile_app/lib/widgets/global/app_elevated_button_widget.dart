import 'package:flutter/material.dart';
import 'package:winball/widgets/widgets.dart';

class AppElevatedButtonWidget extends StatelessWidget {
  const AppElevatedButtonWidget({
    super.key,
    this.iconAlignment = IconAlignment.start,
    this.autofocus = false,
    this.onFocusChanged,
    this.buttonStyle,
    this.child,
    this.clipBehavior,
    this.focusNode,
    this.onHover,
    this.onLongPress,
    this.onPressed,
    this.statesController,
    this.borderRadius,
  });
  final Widget? child;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final bool autofocus;
  final Clip? clipBehavior;
  final FocusNode? focusNode;
  final IconAlignment iconAlignment;
  final void Function(bool?)? onFocusChanged;
  final void Function(bool?)? onHover;
  final WidgetStatesController? statesController;
  final ButtonStyle? buttonStyle;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return BlueBackgroundWidget(
      borderRadius: borderRadius,
      child: ElevatedButton(
        onPressed: onPressed,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        key: key,
        onFocusChange: onFocusChanged,
        onHover: onHover,
        onLongPress: onLongPress,
        statesController: statesController,
        style: buttonStyle,
        child: child,
      ),
    );
  }
}
