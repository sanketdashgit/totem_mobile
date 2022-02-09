import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/WebService/APIRequest.dart';

class SignInRepository {
  APIRequestHelper helper = APIRequestHelper();

  Future<UserModel> signInUser(Map<String, dynamic> params) async {
    var response = await helper.post(APITag.signIn, params);
    return UserModel.fromJson(response);
  }
}
