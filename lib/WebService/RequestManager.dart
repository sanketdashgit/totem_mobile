import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:totem_app/Utility/Annotation/todo.dart';
import 'package:totem_app/Utility/Impl/Utilitiesimpl.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/logger.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';

class RequestManager {
  RequestManager();

  @todo('Post request')
  static postRequest(
      {@required uri,
      body,
      jsonEncoded = true,
      bool hasBearer = true,
      bool isLoader = false,
      bool isSuccessMessage = true,
      bool isFailedMessage = true,
      @required Function(dynamic responseBody) onSuccess,
      @required Function onFailure,
      Function onConnectionFailed}) async {
    bool isConnected = await Utilities.isConnectedNetwork();
    if (!isConnected) {
      if (onConnectionFailed != null)
        onConnectionFailed("Check your internet connection and try again");
      getSnackToast(
        title: 'Connection Error',
        message: "Check your internet connection and try again",
      );
      return;
    }

    Map<String, String> header = {
      'Content-Type': 'application/json-patch+json',
    };

    if (hasBearer) {
      header = {
        'Content-Type': 'application/json-patch+json',
        'Authorization': SessionImpl.getNewToken().toString(),
      };
    }

    print('header : ${header.toString()}');

    if (jsonEncoded) {
      body = jsonEncode(body);
    }

    var url = endPoints.baseUrl + uri;
    if (isLoader) Widgets.showLoading();
    http.post(Uri.parse(url), body: body, headers: header).then((response) {
      Log.displayResponse(payload: body, res: response, requestType: 'POST');
      if (isLoader) Widgets.loadingDismiss();
      var json = jsonDecode(response.body);
      if (json['meta']['status']) {
        if (isSuccessMessage) {
          RequestManager.getSnackToast(
              title: "Success",
              message: json['meta']['message'],
              colorText: Colors.white,
              backgroundColor: Colors.black);
        }
        if (onSuccess != null) {
          onSuccess(json['result']);
        }
      } else {
        if (isFailedMessage)
          responseFailed(isLoader, url, json['meta']['message'], onFailure);
        else if (onFailure != null) onFailure(json['meta']['message']);
      }
    }).catchError((error) {
      responseFailed(isLoader, url, 'Error : catch Error $error', onFailure);
    }).timeout(Duration(seconds: global.REQUEST_MAX_TIMEOUT), onTimeout: () {
      responseFailed(isLoader, url, 'Error : TimeOut', onFailure);
    });
  }

  @todo('GET Request')
  static getRequest(
      {@required uri,
      bool hasBearer = true,
      bool isLoader = false,
      bool isSuccessMessage = true,
      bool isFailedMessage = true,
      Function onSuccess,
      Function onFailure,
      Function onConnectionFailed}) async {
    bool isConnected = await Utilities.isConnectedNetwork();
    if (!isConnected) {
      onConnectionFailed(
        "Check your internet connection and try again",
      );
      return;
    }
    Map<String, String> header = {
      'Content-Type': 'application/json-patch+json',
    };
    if (hasBearer) {
      header = {
        'Content-Type': 'application/json-patch+json',
        'Authorization': SessionImpl.getToken(),
      };
    }
    print("Header " + header.toString());
    if (isLoader) Widgets.showLoading();

    String url = endPoints.baseUrl + uri;
    http.get(Uri.parse(url), headers: header).then((response) {
      print('Done : Success');
      Log.displayResponse(res: response, requestType: 'GET');
      if (isLoader) Widgets.loadingDismiss();
      var json = jsonDecode(response.body);
      if (json['meta']['status']) {
        if (isSuccessMessage) {
          RequestManager.getSnackToast(
              message: json['meta']['message'],
              colorText: Colors.white,
              backgroundColor: Colors.black);
        }
        if (onSuccess != null) onSuccess(json['data']);
      } else {
        if (isFailedMessage)
          responseFailed(isLoader, url, json['meta']['message'], onFailure);
      }
    }).catchError((error) {
      responseFailed(isLoader, url, 'Error : catchError $error', onFailure);
    }).timeout(Duration(seconds: global.REQUEST_MAX_TIMEOUT), onTimeout: () {
      responseFailed(isLoader, url, 'Error : TimeOut', onFailure);
    });
  }

  @todo('Post request')
  static deleteRequest(
      {@required uri,
      body,
      jsonEncoded = true,
      bool hasBearer = true,
      bool isLoader = false,
      bool isSuccessMessage = true,
      bool isFailedMessage = true,
      @required Function(dynamic responseBody) onSuccess,
      @required Function onFailure,
      Function onConnectionFailed}) async {
    bool isConnected = await Utilities.isConnectedNetwork();
    if (!isConnected) {
      if (onConnectionFailed != null)
        onConnectionFailed("Check your internet connection and try again");
      getSnackToast(
        title: 'Connection Error',
        message: "Check your internet connection and try again",
      );
      return;
    }
    Map<String, String> header = {
      'Content-Type': 'application/json-patch+json',
    };
    if (hasBearer) {
      header = {
        'Content-Type': 'application/json-patch+json',
        'Authorization': SessionImpl.getToken(),
      };
    }

    if (jsonEncoded) {
      body = jsonEncode(body);
    }

    var url = endPoints.baseUrl + uri;
    if (isLoader) Widgets.showLoading();
    //make sure body should not have integer values, below body accept only String values.
    //make sure here body only accept Map type data till you not set 'Content-Type': 'application/json',
    final request = http.Request("DELETE", Uri.parse(url));
    request.body = body;
    request.headers.addAll(header);
    await request.send().then((resStream) async {
      resStream.stream.transform(utf8.decoder).listen((response) {
        final responseBody = json.decode(response);
        if (isLoader) Widgets.loadingDismiss();
        if (onSuccess != null) onSuccess(responseBody);
      });
    }).catchError((error) {
      if (isLoader) Widgets.loadingDismiss();
      print('Error : catchError $error');
      print(url);
      RequestManager.getSnackToast(
          message: error.toString(),
          colorText: Colors.white,
          backgroundColor: Colors.red);

      if (onFailure != null) onFailure(error);
    }).timeout(Duration(seconds: global.REQUEST_MAX_TIMEOUT), onTimeout: () {
      if (isLoader) Widgets.loadingDismiss();
      print(url);
      print('Error : TimeOut');
      RequestManager.getSnackToast(
          message: 'Error : TimeOut',
          colorText: Colors.white,
          backgroundColor: Colors.red);
      if (onFailure != null) onFailure('Error : TimeOut');
    });
  }

  static responseFailed(
      bool isLoader, String url, String message, Function onFailure) {
    if (isLoader) Widgets.loadingDismiss();
    print(url);
    print(message);
    RequestManager.getSnackToast(
        message: message, colorText: Colors.white, backgroundColor: Colors.red);
    if (onFailure != null) onFailure(message);
  }

  static getSnackToast({
    title = "Alert",
    message = '',
    snackPosition: SnackPosition.TOP,
    backgroundColor = Colors.red,
    colorText = Colors.white,
    Widget icon,
    Duration duration,
    Function onTapSnackBar,
    Function onTapButton,
    bool withButton = false,
    buttonText = 'Ok',
    Function onDismissed,
  }) {
    Get.snackbar(
      title,
      message,
      mainButton: withButton
          ? TextButton(
              onPressed: () {
                if (onTapButton != null) onTapButton();
              },
              child: Text(buttonText))
          : null,
      onTap: (tap) {
        if (onTapSnackBar != null) onTapSnackBar(tap);
      },
      duration: duration,
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      icon: icon,
      colorText: colorText,
      snackbarStatus: (status) {
        print(status);
        if (status == SnackbarStatus.CLOSED) {
          if (onDismissed != null) onDismissed();
        }
      },
    );
  }

  @todo('POST MultiPart Request to upload Media')
  static uploadImage({
    @required uri,
    @required File file,
    @required moduleId,
    String moduleType = '',
    String moduleIdParamName = 'Id',
    bool hasBearer = false,
    bool isLoader = false,
    @required Function onSuccess,
    @required Function onFailure,
    Function onConnectionFailed,
  }) async {
    bool isConnected = await Utilities.isConnectedNetwork();
    if (!isConnected) {
      if (onConnectionFailed != null)
        onConnectionFailed("Check your internet connection and try again");
      getSnackToast(
        title: 'Connection Error',
        message: "Check your internet connection and try again",
      );
      return;
    }
    Map<String, String> header = {
      'Authorization': SessionImpl.getToken(),
    };

    if (isLoader) Widgets.showLoading();

    String url = endPoints.baseUrl + uri;

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll(header);
    if (moduleType.isEmpty) {
      request.fields.addAll({moduleIdParamName: moduleId.toString()});
    } else {
      request.fields.addAll({
        moduleIdParamName: moduleId.toString(),
        'DocumentType': moduleType.toString()
      });
    }
    if (file != null) {
      var stream = http.ByteStream(Stream.castFrom(file.openRead()));
      var length = await file.length();
      var multipartFile = http.MultipartFile('FileName', stream, length,
          filename: basename(file.path));
      request.files.add(multipartFile);
    }
    print("req : $url ${request.files.length}");
    print("req param : ${request.fields.toString()}");
    await request.send().then((resStream) async {
      resStream.stream.transform(utf8.decoder).listen((response) {
        final responseBody = json.decode(response);
        Log.displayResponse(
            payload: request.fields, res: responseBody, requestType: 'POST');
        if (isLoader) Widgets.loadingDismiss();
        if (onSuccess != null) onSuccess(responseBody);
      });
    }).catchError((error) {
      if (isLoader) Widgets.loadingDismiss();
      print('Error : catchError $error');
      print(url);
      RequestManager.getSnackToast(
          message: error.toString(),
          colorText: Colors.white,
          backgroundColor: Colors.red);

      if (onFailure != null) onFailure(error);
    }).timeout(Duration(seconds: global.REQUEST_MAX_TIMEOUT), onTimeout: () {
      if (isLoader) Widgets.loadingDismiss();
      print(url);
      print('Error : TimeOut');
      RequestManager.getSnackToast(
          message: 'Error : TimeOut',
          colorText: Colors.white,
          backgroundColor: Colors.red);
      if (onFailure != null) onFailure('Error : TimeOut');
    });
  }

  static Future<http.MultipartRequest> getFilesStream(
      List<File> files, http.MultipartRequest req) async {
    print('call getFileStream');
    files.forEach((file) async {
      var stream = http.ByteStream(Stream.castFrom(file.openRead()));
      var length = await file.length();
      var multipartFile = http.MultipartFile('FileName', stream, length,
          filename: basename(file.path));
      req.files.add(multipartFile);
      print('stream done $basename(file.path)');
    });
    print('return file stream');
    return req;
  }

  @todo('POST MultiPart Request to upload Media')
  static uploadPostMedia({
    @required uri,
    @required File file,
    File videoFile,
    @required whichId,
    @required moduleId,
    @required String mediaType,
    bool hasBearer = false,
    bool isLoader = false,
    @required Function onSuccess,
    @required Function onFailure,
    Function onConnectionFailed,
  }) async {
    bool isConnected = await Utilities.isConnectedNetwork();
    if (!isConnected) {
      if (onConnectionFailed != null)
        onConnectionFailed("Check your internet connection and try again");
      getSnackToast(
        title: 'Connection Error',
        message: "Check your internet connection and try again",
      );
      return;
    }
    Map<String, String> header = {
      'Authorization': SessionImpl.getToken(),
    };

    if (isLoader) Widgets.showLoading();

    String url = endPoints.baseUrl + uri;

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll(header);
    request.fields.addAll(
        {/*"PostId"*/ whichId: moduleId.toString(), 'MediaType': mediaType});

    if (file != null) {
      //DelegatingStream.typed(file.openRead())
      var stream = http.ByteStream(Stream.castFrom(file.openRead()));
      var length = await file.length();
      var multipartFile = http.MultipartFile('FileName', stream, length,
          filename: basename(file.path));
      request.files.add(multipartFile);
    }
    if (videoFile != null) {
      var stream = http.ByteStream(Stream.castFrom(videoFile.openRead()));
      var length = await videoFile.length();
      var multipartFile = http.MultipartFile('Video', stream, length,
          filename: basename(videoFile.path));
      request.files.add(multipartFile);
    }
    print("req : $url ${request.files.length}");
    print("req param : ${request.fields.toString()}");
    await request.send().then((resStream) async {
      resStream.stream.transform(utf8.decoder).listen((response) {
        final responseBody = json.decode(response);
        Log.displayResponse(
            payload: request.fields, res: responseBody, requestType: 'POST');
        if (isLoader) Widgets.loadingDismiss();
        if (onSuccess != null) onSuccess(responseBody);
      });
    }).catchError((error) {
      if (isLoader) Widgets.loadingDismiss();
      print('Error : catchError $error');
      print(url);
      RequestManager.getSnackToast(
          message: error.toString(),
          colorText: Colors.white,
          backgroundColor: Colors.red);

      if (onFailure != null) onFailure(error);
    }).timeout(Duration(seconds: global.REQUEST_MAX_TIMEOUT), onTimeout: () {
      if (isLoader) Widgets.loadingDismiss();
      print(url);
      print('Error : TimeOut');
      RequestManager.getSnackToast(
          message: 'Error : TimeOut',
          colorText: Colors.white,
          backgroundColor: Colors.red);
      if (onFailure != null) onFailure('Error : TimeOut');
    });
  }

  @todo('Google API')
  getGooglePlaces(String keyword,
      {requestCode,
      Function onSuccess,
      Function onFailure,
      Function onTimeout,
      Function onConnectionFailed}) async {
    bool isConnected = await Utilities.isConnectedNetwork();
    if (!isConnected) {
      onConnectionFailed(
          error: "Check your internet connection and try again",
          requestCode: requestCode);
      return;
    } else {
      try {
        String url =
            "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=" +
                endPoints.kGoogleApiKey +
                "&input=" +
                keyword +
                "&sensor=true";
        Uri encoded = Uri.parse(url);
        print("Request Param :" + encoded.toString());
        final response = await http.get(encoded, headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        }).timeout(Duration(seconds: 10));
        final responseBody = json.decode(response.body);
        if (response.statusCode != 200 && responseBody == null) {
          print('Error : catchError');
          onFailure("An error occured", requestCode);
        } else {
          if (responseBody["status"] == "OK") {
            var result = json.decode(response.body);
            onSuccess(result, requestCode);
          } else {
            print("status == 0");
            onFailure("An error occured", requestCode);
          }
        }
      } catch (e) {
        RequestManager.getSnackToast(
            title: 'Error',
            message: 'Something went wrong, Try again later...');
      }
    }
  }

  @todo('Get access token of spotify')
  static getSpotifyAccessToken({
    Function onSuccess,
    Function onFailure,
  }) async {
    var parts = [];
    parts.add('${Uri.encodeQueryComponent('grant_type')}='
        '${Uri.encodeQueryComponent('client_credentials')}');
    var formData = parts.join('&');

    Map<String, String> header = {
      'Authorization':
          'Basic ZTUwMWRhY2FhOTllNDNhMWFlOTM0OTk5Mzk4YjZkMWQ6MjM4YzUwYjM0ZjAzNGNmM2EzNTIxZGQ2NGNkYjVkNWI=',
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    String url = "https://accounts.spotify.com/api/token";

    Uri encoded = Uri.parse(url);
    print("Request Param :" + encoded.toString());
    final response = await http
        .post(encoded, headers: header, body: formData)
        .timeout(Duration(seconds: 10));
    final responseBody = json.decode(response.body);
    if (response.statusCode != 200 && responseBody == null) {
      RequestManager.getSnackToast(
          title: 'Error', message: 'Something went wrong, Try again later...');
    } else {
      String access =
          responseBody['token_type'] + ' ' + responseBody['access_token'];
      onSuccess(access);
    }
  }

  @todo('Get access token of spotify')
  static getSpotifyDetails({
    @required uri,
    @required token,
    Function onSuccess,
    Function onFailure,
  }) async {
    Map<String, String> header = {
      'Authorization': token,
      'Accept': 'application/json'
    };

    Uri encoded = Uri.parse(uri);
    print("Request Param :" + encoded.toString() + " token : " + token);
    final response =
        await http.get(encoded, headers: header).timeout(Duration(seconds: 10));
    final responseBody = json.decode(response.body);
    if (response.statusCode != 200 && responseBody == null) {
      RequestManager.getSnackToast(
          title: 'Error', message: 'Something went wrong, Try again later...');
    } else {
      onSuccess(responseBody);
    }
  }

  @todo('Get Ticket master events')
  static getTicketMasterEvents({
    String keyword,
    Function onSuccess,
    Function onFailure,
  }) async {
    Map<String, String> header = {'Content-Type': 'application/json'};
    String url =
        "https://app.ticketmaster.com/discovery/v2/events.json?size=20&classificationName=music&keyword=$keyword&apikey=0rXyG6tjk1WSYsyXBmOE2I0nQ6LBqRzt";
    Uri encoded = Uri.parse(url);
    print("Ticket master :" + url);
    final response =
        await http.get(encoded, headers: header).timeout(Duration(seconds: 10));
    final responseBody = json.decode(response.body);
    if (response.statusCode != 200 && responseBody == null) {
      RequestManager.getSnackToast(
          title: 'Error', message: 'Something went wrong, Try again later...');
    } else {
      print("Ticket master response :" + responseBody.toString());
      onSuccess(responseBody['_embedded']);
    }
  }
}
