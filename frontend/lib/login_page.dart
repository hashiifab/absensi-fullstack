import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as myHttp;
import 'package:presensi_app/reset_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presensi_app/home_page.dart';
import 'package:presensi_app/models/login_response.dart';
import 'utils/api_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Future<String> _name, _token;

  @override
  void initState() {
    super.initState();

    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });

    checkToken(_token, _name);
  }

  checkToken(token, name) async {
    String tokenStr = await token;
    String nameStr = await name;
    if (tokenStr != "" && nameStr != "") {
      Future.delayed(const Duration(seconds: 1), () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const HomePage()))
            .then((value) {
          setState(() {});
        });
      });
    }
  }

  Future login(email, password) async {
    LoginResponseModels? loginResponseModel;
    Map<String, String> body = {"email": email, "password": password};

    try {
      var response = await myHttp.post(
        Uri.parse('${ApiHelper.getApiUrl()}/login'), // Menggunakan ApiHelper
        body: body,
      );

      if (response.statusCode == 401) {
        _showSnackBar("Email atau password salah", Colors.red);
      } else {
        loginResponseModel =
            LoginResponseModels.fromJson(json.decode(response.body));
        saveUser(loginResponseModel.data.token, loginResponseModel.data.name);
      }
    } catch (e) {
      _showSnackBar("Kesalahan saat login: $e", Colors.red);
    }
  }

  Future saveUser(token, name) async {
    try {
      final SharedPreferences pref = await _prefs;
      pref.setString("name", name);
      pref.setString("token", token);

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const HomePage()))
          .then((value) {
        setState(() {});
      });
    } catch (err) {
      _showSnackBar(err.toString(), Colors.red);
    }
  }

  // Fungsi untuk menampilkan SnackBar yang lebih menarik
  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo atau Ikon Aplikasi
                Icon(Icons.lock_outline, size: 100, color: Colors.blue[800]),
                const SizedBox(height: 20),

                // Judul halaman
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // Subjudul
                const Text(
                  "Log in to your account",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // Input Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      login(emailController.text, passwordController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Log In",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Teks tambahan untuk forgot password
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              const ResetPasswordPage()), // Navigasi ke halaman reset password
                    );
                  },
                  child: const Text(
                    "Forgot your password?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}
