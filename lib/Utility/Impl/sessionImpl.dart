import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:totem_app/Models/UserModel.dart';

import 'global.dart';

class SessionImpl {
  static GetStorage box;

  init() async {
    await GetStorage.init(sessionKeys.sbStore);
    box = GetStorage(sessionKeys.sbStore);
  }

  static isFirstTimeUser() {
    if (box != null && box.hasData(sessionKeys.keyFirstTimeUser))
      return box.read(sessionKeys.keyFirstTimeUser);
    return true;
  }

  static showIntroScreen() {
    if (box != null && box.hasData(sessionKeys.keyShowIntroScreen))
      return box.read(sessionKeys.keyShowIntroScreen);
    return true;
  }

  static setShowIntroScreen(bool show) {
    box?.write(sessionKeys.keyShowIntroScreen, show);
  }

  static isLogin() {
    if (box != null && box.hasData(sessionKeys.keyLogin)) {
      bool cx = box.read(sessionKeys.keyLogin);
      return cx;
    }
    return false;
  }

  static setLogIn(bool isUserLoggedIn) {
    box?.write(sessionKeys.keyLogin, isUserLoggedIn);
  }

  static setPrivacy(bool isPrivate) {
    box?.write(sessionKeys.keyisPrivate, isPrivate);
  }

  static getTokenB() {
    if (box != null && box.hasData(sessionKeys.keyLoginToken))
      return box.read(sessionKeys.keyLoginToken);
    return '';
  }

  static setToken(String token) {
    print("set token " + token);
    if (token != null) {
      box?.write(sessionKeys.keyLoginToken, token);
    }
  }

  static getToken() {
    if (box != null && box.hasData(sessionKeys.keyLoginToken))
      return box.read(sessionKeys.keyLoginToken);
    else {
      return 'asdlasdkajsndknda';
    }
  }

  static setId(int id) {
    box?.write(sessionKeys.keyLoginID, id);
  }

  static getId() {
    if (box != null && box.hasData(sessionKeys.keyLoginID))
      return box.read(sessionKeys.keyLoginID);
    return 0;
  }

  static setFCMToken(String token) {
    box?.write(sessionKeys.KeyFCMToken, token);
  }

  static getFCMToken() {
    if (box != null && box.hasData(sessionKeys.KeyFCMToken))
      return box.read(sessionKeys.KeyFCMToken);
    return '';
  }

  static setNewToken(String token) {
    box?.write(sessionKeys.KeyToken, token);
  }

  static getNewToken() {
    if (box != null && box.hasData(sessionKeys.KeyToken))
      return box.read(sessionKeys.KeyToken);
    return '';
  }

  static setprivacy(bool isPrivate) {
    box?.write(sessionKeys.keyisPrivate, isPrivate);
  }

  static getprivacy() {
    if (box != null && box.hasData(sessionKeys.keyisPrivate))
      return box.read(sessionKeys.keyisPrivate);
  }

  static eventgetId() {
    if (box != null && box.hasData(sessionKeys.keyLoginID))
      return box.read(sessionKeys.keyLoginID);
    return 0;
  }

  static String getName() {
    var json = box.read(sessionKeys.keyLoginProfile);
    UserInfoModel userInfoModel = UserInfoModel.fromJson(jsonDecode(json));
    return userInfoModel.username;
  }

  static setLoginProfileModel(UserInfoModel loginModel) {
    setId(loginModel.id);
    setPrivacy(loginModel.isPrivate);
    box?.write(sessionKeys.keyLoginProfile, jsonEncode(loginModel));
  }

  static getLoginProfileModel() {
    var json = box.read(sessionKeys.keyLoginProfile);
    UserInfoModel userInfoModel = UserInfoModel.fromJson(jsonDecode(json));
    return userInfoModel;
  }

  static setSpotifyToken(String token) {
    box?.write(sessionKeys.KeySpotifyToken, token);
  }

  static String getSpotifyToken() {
    if (box != null && box.hasData(sessionKeys.KeySpotifyToken))
      return box.read(sessionKeys.KeySpotifyToken);
    return '';
  }

  static setIntro1(bool isIntro) {
    box?.write(sessionKeys.KeyIntro1, isIntro);
  }

  static getIntro1() {
    if (box != null && box.hasData(sessionKeys.KeyIntro1))
      return box.read(sessionKeys.KeyIntro1);
    else {
      setIntro1(false);
      return getIntro1();
    }
  }

  static setIntro2(bool isIntro) {
    box?.write(sessionKeys.KeyIntro2, isIntro);
  }

  static getIntro2() {
    if (box != null && box.hasData(sessionKeys.KeyIntro2))
      return box.read(sessionKeys.KeyIntro2);
    else {
      setIntro2(false);
      return getIntro2();
    }
  }

  static setIntro3(bool isIntro) {
    box?.write(sessionKeys.KeyIntro3, isIntro);
  }

  static getIntro3() {
    if (box != null && box.hasData(sessionKeys.KeyIntro3))
      return box.read(sessionKeys.KeyIntro3);
    else {
      setIntro3(false);
      return getIntro3();
    }
  }

  static setIntro4(bool isIntro) {
    box?.write(sessionKeys.KeyIntro4, isIntro);
  }

  static getIntro4() {
    if (box != null && box.hasData(sessionKeys.KeyIntro4))
      return box.read(sessionKeys.KeyIntro4);
    else {
      setIntro4(false);
      return getIntro4();
    }
  }

  static setIntro5(bool isIntro) {
    box?.write(sessionKeys.KeyIntro5, isIntro);
  }

  static getIntro5() {
    if (box != null && box.hasData(sessionKeys.KeyIntro5))
      return box.read(sessionKeys.KeyIntro5);
    else {
      setIntro5(false);
      return getIntro5();
    }
  }

  static setIntro6(bool isIntro) {
    box?.write(sessionKeys.KeyIntro6, isIntro);
  }

  static getIntro6() {
    if (box != null && box.hasData(sessionKeys.KeyIntro6))
      return box.read(sessionKeys.KeyIntro6);
    else {
      setIntro6(false);
      return getIntro6();
    }
  }

  static setIntro7(bool isIntro) {
    box?.write(sessionKeys.KeyIntro7, isIntro);
  }

  static getIntro7() {
    if (box != null && box.hasData(sessionKeys.KeyIntro7))
      return box.read(sessionKeys.KeyIntro7);
    else {
      setIntro7(false);
      return getIntro7();
    }
  }

  static setIntro8(bool isIntro) {
    box?.write(sessionKeys.KeyIntro8, isIntro);
  }

  static getIntro8() {
    if (box != null && box.hasData(sessionKeys.KeyIntro8))
      return box.read(sessionKeys.KeyIntro8);
    else {
      setIntro8(false);
      return getIntro8();
    }
  }

  static setIntro9(bool isIntro) {
    box?.write(sessionKeys.KeyIntro9, isIntro);
  }

  static getIntro9() {
    if (box != null && box.hasData(sessionKeys.KeyIntro9))
      return box.read(sessionKeys.KeyIntro9);
    else {
      setIntro9(false);
      return getIntro9();
    }
  }

  static setIntro10(bool isIntro) {
    box?.write(sessionKeys.KeyIntro10, isIntro);
  }

  static getIntro10() {
    if (box != null && box.hasData(sessionKeys.KeyIntro10))
      return box.read(sessionKeys.KeyIntro10);
    else {
      setIntro10(false);
      return getIntro10();
    }
  }
}
