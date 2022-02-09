import 'package:totem_app/Models/UpdateUserModel.dart';
import 'package:totem_app/WebService/APIRequest.dart';

class UpdateUserRepository{
  APIRequestHelper helper = APIRequestHelper();

  Future<UpdateUserModel> updateUserUser(Map<String, dynamic> params) async {
    var response = await helper.post(APITag.updateUser, params);
  }
}