import 'package:flutter/material.dart';
import '/month_picker_dialog.dart';

///The widget that presents the current selected date on the header.
class HeaderSelectedDate extends StatelessWidget {
  const HeaderSelectedDate({
    super.key,
    required this.theme,
    required this.localeString,
    required this.controller,
  });
  final ThemeData theme;
  final String localeString;
  final MonthpickerController controller;

  @override
  Widget build(BuildContext context) {
    return Text(
      controller.getDateTimeHeaderText(localeString),
      textScaler:
          controller.monthPickerDialogSettings.dialogSettings.textScaleFactor !=
                  null
              ? TextScaler.linear(controller
                  .monthPickerDialogSettings.dialogSettings.textScaleFactor!)
              : null,
      style: controller.monthPickerDialogSettings.headerSettings
              .headerSelectedIntervalTextStyle ??
          theme.primaryTextTheme.titleMedium,
    );
  }
}
