import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar {
  PreferredSizeWidget appBar(BuildContext context, String text,
      {VoidCallback? press}) {
    return AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.red,
            statusBarIconBrightness: Brightness.dark),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.red,
        elevation: 0,
        title: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        leading: IconButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back)),
        actions: <Widget>[
          IconButton(
            onPressed: press,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
        bottom: null);
  }
}
