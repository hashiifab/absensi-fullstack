import 'dart:convert'; // Backend: Untuk mengonversi data JSON
import 'package:flutter/material.dart'; // UI: Untuk menggunakan widget Flutter
import 'package:location/location.dart'; // Backend: Untuk mengakses lokasi perangkat
import 'package:presensi_app/models/save_response.dart'; // Backend: Model untuk menyimpan respons dari API
import 'package:presensi_app/utils/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Backend: Untuk menyimpan data lokal di perangkat
import 'package:syncfusion_flutter_maps/maps.dart'; // UI: Untuk menampilkan peta
import 'package:http/http.dart' as myHttp; // Backend: Untuk melakukan HTTP request

// Kelas utama untuk halaman simpan presensi
class SavePage extends StatefulWidget {
  const SavePage({super.key}); // UI: Constructor untuk halaman simpan presensi

  @override
  State<SavePage> createState() => _SavePageState(); // UI: Membuat state untuk halaman ini
}

class _SavePageState extends State<SavePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
  }

  Future<LocationData?> _currenctLocation() async {
    bool serviceEnable;
    PermissionStatus permissionGranted;
    Location location = Location();

    serviceEnable = await location.serviceEnabled();
    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  Future savePresensi(double latitude, double longitude) async {
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };

    Map<String, String> headers = {'Authorization': 'Bearer ${await _token}'};

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
          _showSnackBar(
            'Sukses simpan Presensi',
            Colors.green,
            Icons.check_circle, // Ikon sukses
          );
          Navigator.pop(context);
        } else {
          _showSnackBar(
            'Gagal simpan Presensi: ${savePresensiResponseModel.message}',
            Colors.red,
            Icons.error, // Ikon error
          );
        }
      } else {
        _showSnackBar(
          'Error: ${response.statusCode}',
          Colors.red,
          Icons.error,
        );
      }
    } catch (e) {
      _showSnackBar(
        'Exception: $e',
        Colors.red,
        Icons.error,
      );
    }
  }

  // Fungsi untuk menampilkan SnackBar yang lebih menarik
  void _showSnackBar(String message, Color color, IconData icon) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
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
      appBar: AppBar(
        title: const Text("Presensi", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800], // UI: Warna AppBar
        iconTheme: const IconThemeData(
          color: Colors.white, // Mengatur ikon menjadi putih
        ),
      ),
      body: FutureBuilder<LocationData?>(
        future: _currenctLocation(),
        builder: (BuildContext context, AsyncSnapshot<LocationData?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final LocationData currentLocation = snapshot.data!;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // UI: Menambah padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Peta lokasi
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            15), // UI: Membuat peta lebih rounded
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          height: 300,
                          child: SfMaps(
                            layers: [
                              MapTileLayer(
                                initialFocalLatLng: MapLatLng(
                                    currentLocation.latitude!,
                                    currentLocation.longitude!),
                                initialZoomLevel: 15,
                                initialMarkersCount: 1,
                                urlTemplate:
                                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                markerBuilder:
                                    (BuildContext context, int index) {
                                  return MapMarker(
                                    latitude: currentLocation.latitude!,
                                    longitude: currentLocation.longitude!,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        savePresensi(currentLocation.latitude!,
                            currentLocation.longitude!);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 50), // UI: Padding tombol
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blue[800], // UI: Warna tombol
                        elevation: 5,
                      ),
                      child: const Text(
                        "Simpan Presensi",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white), // UI: Teks yang lebih besar
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("Lokasi tidak ditemukan"));
          }
        },
      ),
    );
  }
}
