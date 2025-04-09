// To parse this JSON data, do
//
//     final saveResponseModels = saveResponseModelsFromJson(jsonString);

import 'dart:convert';

SaveResponseModels saveResponseModelsFromJson(String str) => SaveResponseModels.fromJson(json.decode(str));

String saveResponseModelsToJson(SaveResponseModels data) => json.encode(data.toJson());

class SaveResponseModels {
    bool success;
    String message;
    dynamic data;

    SaveResponseModels({
        required this.success,
        required this.message,
        required this.data,
    });

    factory SaveResponseModels.fromJson(Map<String, dynamic> json) => SaveResponseModels(
        success: json["success"],
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
    };
}
