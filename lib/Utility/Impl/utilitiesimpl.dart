import 'dart:io';
import 'dart:math';

class Utilities {
  static Future<bool> isConnectedNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print("Internet available");
        return true;
      } else {
        print("Internet not available");
        return false;
      }
    } on SocketException catch (_) {
      print("Something went wrong with connection");
      return false;
    }
  }

  static String getRandomString({int length = 9}) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}
