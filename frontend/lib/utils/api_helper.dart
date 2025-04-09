import 'dart:convert';
import 'package:http/http.dart' as myHttp;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:presensi_app/models/login_response.dart';
import 'package:presensi_app/models/save_response.dart';

class ApiHelper {
  // Fungsi untuk mendapatkan URL API sesuai platform
  static String getApiUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api'; // URL untuk web
    } else {
      return 'http://10.0.2.2:8000/api'; // URL untuk emulator
    }
  }

  // Fungsi untuk login
  static Future<LoginResponseModels?> login(String email, String password) async {
    String apiUrl = getApiUrl();
    Map<String, String> body = {"email": email, "password": password};

    try {
      var response = await myHttp.post(Uri.parse('$apiUrl/login'), body: body);

      if (response.statusCode == 200) {
        return LoginResponseModels.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception("Email atau password salah");
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception: $e');
    }
  }

  // Fungsi untuk menyimpan presensi
  static Future<SaveResponseModels?> savePresensi(double latitude, double longitude, String token) async {
    String apiUrl = getApiUrl();
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };

    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    try {
      var response = await myHttp.post(Uri.parse('$apiUrl/save-presensi'), body: body, headers: headers);

      if (response.statusCode == 200) {
        return SaveResponseModels.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception: $e');
    }
  }
}
