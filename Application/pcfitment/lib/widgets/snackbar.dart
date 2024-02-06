import 'package:flutter/material.dart';

snackBarSuccessMsg(BuildContext context, String text) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white),
    ),
    //width: 10,
    elevation: 6.0,
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.green,
    action: SnackBarAction(
      label: 'Dismiss',
      textColor: Colors.white,
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

snackBarErrorMsg(BuildContext context, String text) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white),
    ),
    //width: 10,
    elevation: 6.0,
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.red,
    action: SnackBarAction(
      label: 'Dismiss',
      textColor: Colors.white,
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
