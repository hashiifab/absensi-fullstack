import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presensi_app/models/save_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presensi_app/login_page.dart';
import 'package:presensi_app/models/home_response.dart';
import 'package:presensi_app/save_page.dart';
import 'utils/api_helper.dart';
import 'package:http/http.dart' as myHttp;
import 'package:location/location.dart'; // Menambahkan import untuk lokasi

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _name = ""; // Nama pengguna
  late String _token = ""; // Token otentikasi
  HomeResponseModels? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Panggil fungsi untuk memuat data pengguna
    getData(); // Memuat data dari API
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString("name") ?? "";
      _token = prefs.getString("token") ?? "";
      print('Token: $_token'); // Debugging token
    });
  }

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("name");
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> getData() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $_token',
    };

    try {
      var response = await myHttp.get(
        // Ganti 127.0.0.1 dengan 10.0.2.2 jika menggunakan emulator
        Uri.parse('${ApiHelper.getApiUrl()}/get-presensi'), // Menggunakan ApiHelper
        headers: headers,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        homeResponseModel =
            HomeResponseModels.fromJson(json.decode(response.body));

        setState(() {
          riwayat.clear();
          bool hasHariIni = false;

          for (var element in homeResponseModel!.data) {
            if (element.isHariIni) {
              hariIni = element;
              hasHariIni = true;
            } else {
              riwayat.add(element);
            }
          }

          if (!hasHariIni) {
            hariIni = null;
          }
        });

        if (hariIni != null) {
          print('Data hari ini: ${hariIni!.tanggal}, masuk: ${hariIni!.masuk}, pulang: ${hariIni!.pulang}');
        } else {
          print('Tidak ada presensi untuk hari ini');
        }

        print('Riwayat length: ${riwayat.length}');
        
        // Panggil fungsi untuk menyimpan waktu pulang otomatis
        _saveWaktuPulangOtomasis();
      } else {
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _saveWaktuPulangOtomasis() async {
    // Cek apakah hari ini sudah ada data pulang
    if (hariIni != null && hariIni!.pulang == '-') {
      // Dapatkan lokasi saat ini
      Location location = Location();
      LocationData? currentLocation;

      try {
        currentLocation = await location.getLocation();
      } catch (e) {
        print('Error getting location: $e');
      }

      if (currentLocation != null) {
        // Simpan waktu pulang (logika ini tergantung pada API Anda)
        await savePresensi(currentLocation.latitude!, currentLocation.longitude!, true); // true menandakan ini adalah pulang
      }
    }
  }

  Future<void> savePresensi(double latitude, double longitude, bool isPulang) async {
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "isPulang": isPulang.toString(), // Mengirim status apakah ini untuk pulang
    };

    Map<String, String> headers = {'Authorization': 'Bearer $_token'};

    try {
      var response = await myHttp.post(
        Uri.parse("${ApiHelper.getApiUrl()}/save-presensi"), // Menggunakan ApiHelper
        body: body,
        headers: headers,
      );

      if (response.statusCode == 200) {
        SaveResponseModels savePresensiResponseModel =
            SaveResponseModels.fromJson(json.decode(response.body));

        if (savePresensiResponseModel.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sukses simpan Pulang'),
              backgroundColor: Colors.green, // UI: Warna hijau untuk sukses
            ),
          );
          getData(); // Memperbarui data setelah menyimpan
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Gagal simpan Pulang: ${savePresensiResponseModel.message}'),
              backgroundColor: Colors.red, // UI: Warna merah untuk gagal
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20, // Ukuran avatar
              backgroundImage: NetworkImage(
                'https://www.w3schools.com/howto/img_avatar.png', // URL gambar avatar dari W3Schools
              ),
            ),
            const SizedBox(width: 8),
            Text(_name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              logout(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Presensi Hari Ini",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Presensi Hari Ini
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      hariIni?.tanggal ?? '-',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              hariIni?.masuk ?? '-',
                              style: const TextStyle(color: Colors.white, fontSize: 24),
                            ),
                            const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 16))
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              hariIni?.pulang ?? '-',
                              style: const TextStyle(color: Colors.white, fontSize: 24),
                            ),
                            const Text("Pulang", style: TextStyle(color: Colors.white, fontSize: 16))
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Riwayat Presensi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              riwayat.isEmpty
                  ? const Center(child: Text("Tidak ada riwayat presensi"))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: riwayat.length,
                        itemBuilder: (context, index) => Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(Icons.date_range, color: Colors.blue[800]),
                            title: Text(riwayat[index].tanggal, style: const TextStyle(fontSize: 18)),
                            subtitle: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Masuk: ${riwayat[index].masuk}", style: const TextStyle(fontSize: 16)),
                                    Text("Pulang: ${riwayat[index].pulang}", style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      // FloatingActionButton bisa dihilangkan jika tidak diperlukan
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        onPressed: () {
          // Arahkan ke halaman SavePage untuk menambah waktu pulang
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const SavePage()))
              .then((value) {
            getData(); // Mengambil data lagi setelah kembali dari halaman SavePage
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
