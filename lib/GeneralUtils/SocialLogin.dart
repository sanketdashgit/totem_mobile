import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:totem_app/GeneralUtils/Alertview.dart';
import 'package:http/http.dart' as http;

class GoogleSignInClass {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  Future<GoogleSignInAccount> googleSignIn() async {
    bool isSignedIn = await _googleSignIn.isSignedIn();

    if (isSignedIn) {
      _googleSignIn.signOut();
    }

    try {
      final GoogleSignInAccount account = await _googleSignIn.signIn();

      if (account != null) {
        return account;
      }
    } catch (error) {
      print(error);
    }
  }
}

class FaceBookSignInClass {
  Future<dynamic> signInWithFB(BuildContext context) async {
    final facebookLogin = FacebookLogin();

    await facebookLogin.isLoggedIn.then((isLoggedIn) {
      if (isLoggedIn) facebookLogin.logOut();
    });

    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token'));
        final userInfo = json.decode(graphResponse.body);
        return userInfo;

      case FacebookLoginStatus.cancelledByUser:
        return null;
      case FacebookLoginStatus.error:
        AlertView().showAlert(result.errorMessage, context);
        break;
    }
  }
}

class AppleSignInClass {
  Future<Map<String, dynamic>> appleSignIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final AuthCredential authCredential = OAuthProvider('apple.com')
          .credential(
              accessToken: credential.authorizationCode,
              idToken: credential.identityToken);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(authCredential);

      if (userCredential != null) {
        return {
          'familyname': credential.familyName,
          'givenname': credential.givenName,
          'email': userCredential.user.email
        };
      } else {

      }
    } catch (error) {

      return null;
    }
  }
}

class VerifyPhoneNumber {
  Future registerPhoneNumber(
      String mobile,
      String countryCode,
      BuildContext context,
      Function completionCodeSent(String verificationId),
     ) async {

    FirebaseAuth auth = FirebaseAuth.instance;
    auth.setLanguageCode('en');

    print('$countryCode$mobile');
    auth.verifyPhoneNumber(
        phoneNumber: '$countryCode$mobile',
        timeout: Duration(seconds: 120),
        verificationCompleted: (AuthCredential authCredential) async {
          UserCredential userCredential =
              await auth.signInWithCredential(authCredential);
        },
        verificationFailed: (FirebaseAuthException authException) {
          print(authException.message);
          completionCodeSent("-1");
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          completionCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          completionCodeSent("-1");
        });
  }

  verifyOTPCode(String verificationId, String smsCode,
      Function completionPhoneAuth(UserCredential userCredential, bool isValid)) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    try {
      UserCredential userCredential =
          await auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        completionPhoneAuth(userCredential, true);
      } else {
        completionPhoneAuth(null, false);
      }
    } catch (e) {
      completionPhoneAuth(null, false);
    }
  }
}
