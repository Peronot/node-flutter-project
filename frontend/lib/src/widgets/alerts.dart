import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class AlertHelper {
  static Future<void> success(BuildContext context, String message) async {
    await _show(context, DialogType.success, 'Success', message);
  }

  static Future<void> error(BuildContext context, String message) async {
    await _show(context, DialogType.error, 'Error', message);
  }

  static Future<bool> confirm(BuildContext context,
      {String title = 'Are you sure?', String desc = 'This action cannot be undone.'}) async {
    bool confirmed = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOkText: 'Yes',
      btnCancelText: 'No',
      btnOkOnPress: () => confirmed = true,
      btnCancelOnPress: () => confirmed = false,
    ).show();
    return confirmed;
  }

  static Future<void> _show(BuildContext context, DialogType type, String title, String desc) {
    return AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOkOnPress: () {},
    ).show();
  }
}
