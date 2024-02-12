// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String? token;
  String? id;
  String? loginModelId;

  LoginModel({
    this.token,
    this.id,
    this.loginModelId,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    token: json["token"],
    id: json["@id"],
    loginModelId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "@id": id,
    "id": loginModelId,
  };
}
