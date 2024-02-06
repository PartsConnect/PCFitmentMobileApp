import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String currentTime() {
  DateFormat timeFormat = DateFormat('hh:mm a');
  String currentTime = timeFormat.format(DateTime.now());
  return currentTime;

  //String currentTime1 = DateFormat.jm().format(DateTime.now());
}

String formatTime(DateTime dateTime) {
  DateFormat timeFormat = DateFormat('hh:mm a');
  String selected = timeFormat.format(dateTime);
  return selected;
}

void allTimeEnable(
    BuildContext context, TextEditingController controller) async {
  final TimeOfDay? timeOfDay = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    //initialTime: const TimeOfDay(hour: 12, minute: 00),
    initialEntryMode: TimePickerEntryMode.dial,
    //confirmText: "CONFIRM",
    //cancelText: "NOT NOW",
    //helpText: "BOOKING TIME"
  );
  if (timeOfDay != null) {
    // ignore: use_build_context_synchronously
    controller.text = timeOfDay.format(context);
  }
}
