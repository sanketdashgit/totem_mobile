import 'package:totem_app/Models/GetAllUsersModel.dart';
import 'package:totem_app/WebService/APIRequest.dart';

class GetAllUsersRepository{
  APIRequestHelper helper = APIRequestHelper();

  Future<List<GetAllUsersModel>> getallUser() async {
    var response = await helper.get(APITag.getAllUsers);

    return response;
  }
}