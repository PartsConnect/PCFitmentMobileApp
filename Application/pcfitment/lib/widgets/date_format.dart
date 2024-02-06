import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String currentDate() {
  DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  String currentDate = dateFormat.format(DateTime.now());
  return currentDate;
}

String currentYYYYMMDDDate() {
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  String currentDate = dateFormat.format(DateTime.now());
  return currentDate;
}

String currentYear() {
  DateFormat yearFormat = DateFormat('yyyy');
  String strYear = yearFormat.format(DateTime.now());
  return strYear;
}

String currentMonth() {
  DateFormat monthFormat = DateFormat('MM');
  String strMonth = monthFormat.format(DateTime.now());
  return strMonth;
}

String currentDay() {
  DateFormat dayFormat = DateFormat('dd');
  String strDay = dayFormat.format(DateTime.now());
  return strDay;
}

String formatDate(DateTime dateTime) {
  //DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  String selected = dateFormat.format(dateTime);
  return selected;
}

String yearMMMDDForm(String dateString) {
  final DateTime date = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

String dateMMMForm(String dateString) {
  final DateTime date = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('dd-MMM-yyyy');
  return formatter.format(date);
}

void allDateEnable(
    BuildContext context, TextEditingController controller) async {
  final DateTime? selected = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1999),
    lastDate: DateTime(int.parse(currentYear()), 12, 31),
    //firstDate: DateTime.now(),//Previous Date Disable
    //lastDate: DateTime.now(),//Future Date Disable
    initialEntryMode: DatePickerEntryMode.calendarOnly,

    /*helpText: "SELECT BOOKING DATE",
      cancelText: "NOT NOW",
      confirmText: "BOOK NOW",
      fieldHintText: "DATE/MONTH/YEAR",
      fieldLabelText: "BOOKING DATE",
      errorFormatText: "Enter a Valid Date",
      errorInvalidText: "Date Out of Range",
      initialDatePickerMode: DatePickerMode.day,*/
  );

  if (selected != null) {
    controller.text = formatDate(selected);
  }
}

void previousDateDisable(
    BuildContext context, TextEditingController controller) async {
  final DateTime? selected = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    //lastDate: DateTime(int.parse(currentYear()), 12, 31),
    lastDate: DateTime(2100, 12, 31),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
  );

  if (selected != null) {
    controller.text = formatDate(selected);
  }
}

void futureDateDisable(
    BuildContext context, TextEditingController controller) async {
  final DateTime? selected = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1999),
    lastDate: DateTime.now(),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
  );

  if (selected != null) {
    controller.text = formatDate(selected);
  }
}

String convertDateFormat(
    String inputDate, String inputDateFormat, String outputDateFormat) {
  DateFormat inputParser = DateFormat(inputDateFormat);
  DateFormat outputParser = DateFormat(outputDateFormat);
  var date = inputParser.parse(inputDate);
  String outPutData = outputParser.format(date);
  return outPutData;
}
