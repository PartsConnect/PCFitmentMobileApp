import 'package:flutter/material.dart';

class Navigation {
  static void push(BuildContext context, var builder) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => builder));
  }

  static void pushRemoveUntil(BuildContext context, var builder) {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => builder), (route) => false);
  }

  static void pushReplacement(BuildContext context, var builder) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => builder,
    ));
  }

  static void pushName(BuildContext context, var builder) {
    Navigator.pushNamed(context, builder);
  }
}
