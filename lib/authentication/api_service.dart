import 'dart:convert';
import 'package:agricultura_inteligente/pages/login/components/login_model.dart';

class APIService {
  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    String hardcodedToken = "1234";

    if (hardcodedToken == requestModel.token) {
      return LoginResponseModel.fromJson(
        json.decode(hardcodedToken),
      );
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
