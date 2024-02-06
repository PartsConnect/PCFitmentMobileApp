import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkSpeed {
  unknown,
  slow,
  moderate,
  fast,
}

class Network {
  static Future<bool> isConnected1() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Connected to mobile data or Wi-Fi
    } else {
      return false; // Not connected
    }
  }

  static Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {

      var networkSpeed = _inferNetworkSpeed();

      // Check network speed
      if (networkSpeed == NetworkSpeed.fast || networkSpeed == NetworkSpeed.moderate) {
        return true; // Connected to mobile data or Wi-Fi with good speed
      } else {
        return false; // Connected, but network speed is slow or unknown
      }

    } else {
      return false; // Not connected
    }
  }

  static NetworkSpeed _inferNetworkSpeed() {
    if (Duration.zero < const Duration(milliseconds: 500)) {
      return NetworkSpeed.fast;
    } else if (const Duration(milliseconds: 500) < const Duration(milliseconds: 1500)) {
      return NetworkSpeed.moderate;
    } else {
      return NetworkSpeed.slow;
    }
  }
}
