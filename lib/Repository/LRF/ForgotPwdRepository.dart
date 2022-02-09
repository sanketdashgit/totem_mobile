import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/WebService/APIRequest.dart';

class ForgotPwdRepository {
  APIRequestHelper helper = APIRequestHelper();

  Future<dynamic> forgotPwd(String email) async {
    var response = await helper.post(APITag.forgotPwd, {Parameters.CEmailId: email});
    return response;
  }
}
