import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/WebService/APIRequest.dart';

class EmailExistRepository {
  APIRequestHelper helper = APIRequestHelper();

  Future<dynamic> emailExitUser(String email) async {
    var response = await helper.post(APITag.checkMailExist, {Parameters.CemailId: email});
    return response;
  }
}