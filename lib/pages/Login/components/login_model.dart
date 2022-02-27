class LoginResponseModel {
  final int? token;

  LoginResponseModel({this.token});

  factory LoginResponseModel.fromJson(int json) {
    return LoginResponseModel(token: json);
  }
}

class LoginRequestModel {
  String token;

  LoginRequestModel({
    this.token = "",
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'token': token.trim(),
    };

    return map;
  }
}
