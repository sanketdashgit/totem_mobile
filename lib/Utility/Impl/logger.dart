import 'package:http/http.dart' as http;

class Log {
  Log.displayResponse({payload, var res, String requestType = 'GET'}) {
    // res as http.Response;
    if (payload != null) {
      String logData = payload.toString();
      if (logData.length > 1000) {
        print("payload : ");
        int maxLogSize = 1000;
        for (int i = 0; i <= logData.length / maxLogSize; i++) {
          int start = i * maxLogSize;
          int end = (i + 1) * maxLogSize;
          end = end > logData.length ? logData.length : end;
          print('${logData.substring(start, end)}');
        }
      } else
        print("payload : " + payload.toString());
    }
    if (res != null && res is http.Response) {
//      print('headers : '+ res.headers.toString());
      print("url : " + res.request.url.toString());
      if (requestType != null) {
        print("requestType : " + requestType);
      }
      print("status code : " + res.statusCode.toString());
      if (res.body != null) {
        String logData = res.body.toString();
        if (logData.length > 1000) {
          print("response : ");
          int maxLogSize = 1000;
          for (int i = 0; i <= logData.length / maxLogSize; i++) {
            int start = i * maxLogSize;
            int end = (i + 1) * maxLogSize;
            end = end > logData.length ? logData.length : end;
            print('${logData.substring(start, end)}');
          }
        } else
          print("response : " + res.body.toString());
      }
    } else {
      print("Log displayResponse is : " + res.toString());
    }
  }
}
