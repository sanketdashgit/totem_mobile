import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/WebService/APIRequest.dart';

class SignUpRepository {
  APIRequestHelper helper = APIRequestHelper();

  Future<UserModel> signUpUser(Map<String, dynamic> params) async {
    var response = await helper.post(APITag.signUp, params);
    return UserModel.fromJson(response);
  }
}
