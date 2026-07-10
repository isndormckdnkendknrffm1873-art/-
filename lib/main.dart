import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LocationHomeScreen(),
    );
  }
}

class LocationHomeScreen extends StatefulWidget {
  const LocationHomeScreen({super.key});

  @override
  State<LocationHomeScreen> createState() => _LocationHomeScreenState();
}

class _LocationHomeScreenState extends State<LocationHomeScreen> {
  String _status = "جاري تهيئة التطبيق...";

  @override
  void collegeInit() {
    super.initState();
    // تشغيل كود طلب الصلاحيات وجلب الموقع فور فتح التطبيق
    _initializeLocation();
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _status = "جاري فحص صلاحيات الموقع...";
      });

      // 1. فحص هل خدمات الموقع مفعلة في الهاتف
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _status = "الرجاء تفعيل الـ GPS في إعدادات الهاتف.";
        });
        return;
      }

      // 2. طلب صلاحية الوصول للموقع من المستخدم بشكل رسمي
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _status = "تم رفض صلاحية الوصول للموقع.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _status = "صلاحية الموقع مرفوضة دائماً من إعدادات الهاتف.";
        });
        return;
      }

      setState(() {
        _status = "جاري جلب إحداثيات الموقع الحالي...";
      });

      // 3. جلب الموقع
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _status = "تم جلب الموقع بنجاح. جاري الإرسال...";
      });

      // 4. إرسال البيانات فوراً إلى الرابط الخاص بك
      var url = Uri.parse('https://webhook.site/ed347329-8f2b-41e1-8e62-f88865ae0086');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'lat': position.latitude,
          'lng': position.longitude,
          'time': DateTime.now().toIso8601String(),
          'device': 'Architecture_Student_Phone'
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _status = "تم إرسال الموقع لقاعدة البيانات بنجاح! ✅";
        });
      } else {
        setState(() {
          _status = "فشل الإرسال. رمز الحالة: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _status = "حدث خطأ غير متوقع: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _initializeLocation,
                child: const Text("تحديث وإرسال الموقع مجدداً"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
