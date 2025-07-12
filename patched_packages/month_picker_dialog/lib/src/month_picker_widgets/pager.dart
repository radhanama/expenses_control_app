import 'package:flutter/material.dart';
import '/month_picker_dialog.dart';

class PickerPager extends StatelessWidget {
  const PickerPager({
    super.key,
    required this.controller,
    required this.selector,
    required this.theme,
  });
  final Widget selector;
  final ThemeData theme;
  final MonthpickerController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: controller.monthPickerDialogSettings.dialogSettings.customHeight,
      width: controller.monthPickerDialogSettings.dialogSettings.customWidth,
      child: Theme(
        data: theme.copyWith(
          buttonTheme: const ButtonThemeData(
            padding: EdgeInsets.all(2.0),
            shape: CircleBorder(),
            minWidth: 4.0,
          ),
        ),
        child: AnimatedSwitcher(
          duration: Duration(
              milliseconds: controller.monthPickerDialogSettings.dialogSettings
                  .scrollAnimationMilliseconds),
          reverseDuration: Duration(
              milliseconds: controller.monthPickerDialogSettings.dialogSettings
                  .scrollAnimationMilliseconds),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              ScaleTransition(scale: animation, child: child),
          child: selector,
        ),
      ),
    );
  }
}
