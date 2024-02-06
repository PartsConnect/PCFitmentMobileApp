import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetConnectionManager {
  bool isDeviceConnected = false;

  // Add a variable to store the current internet connection status
  bool internetCheck = false;

  void checkInternetConnection(VoidCallback setStateCallback) async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    // Update the internetCheck variable
    internetCheck = isDeviceConnected;
    if (!isDeviceConnected) {
      if (kDebugMode) {
        print("No internet connection");
      }
    }

    setStateCallback();

    InternetConnectionChecker().onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        // Update the internetCheck variable
        internetCheck = true;

        setStateCallback();
        if (kDebugMode) {
          print("Internet connected");
        }
      } else {
        // Update the internetCheck variable
        internetCheck = false;
        setStateCallback();
        if (kDebugMode) {
          print("Internet disconnected");
        }
      }
    });
  }
}
