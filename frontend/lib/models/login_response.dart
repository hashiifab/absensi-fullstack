// To parse this JSON data, do
//
//     final loginResponseModels = loginResponseModelsFromJson(jsonString);

import 'dart:convert';

LoginResponseModels loginResponseModelsFromJson(String str) => LoginResponseModels.fromJson(json.decode(str));

String loginResponseModelsToJson(LoginResponseModels data) => json.encode(data.toJson());

class LoginResponseModels {
    bool success;
    String message;
    Data data;

    LoginResponseModels({
        required this.success,
        required this.message,
        required this.data,
    });

    factory LoginResponseModels.fromJson(Map<String, dynamic> json) => LoginResponseModels(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    int id;
    String name;
    String email;
    dynamic emailVerifiedAt;
    DateTime createdAt;
    DateTime updatedAt;
    String token;
    String tokenType;

    Data({
        required this.id,
        required this.name,
        required this.email,
        required this.emailVerifiedAt,
        required this.createdAt,
        required this.updatedAt,
        required this.token,
        required this.tokenType,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        token: json["token"],
        tokenType: json["token_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "token": token,
        "token_type": tokenType,
    };
}
