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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LocationHomeScreen(),
    );
  }
}

class LocationHomeScreen extends StatefulWidget {
  const LocationHomeScreen({super.key});

  @override
  State<LocationHomeScreen> createState() => _LocationHomeScreenState();
}

class _LocationHomeScreenState extends State<LocationHomeScreen> {
  String _status = "جاري تهيئة التطبيق وفحص الصلاحيات...";

  @override
  void initState() {
    super.initState();
    // إجبار التطبيق على طلب إذن الـ GPS فوراً عند فتح الشاشة
    _requestPermissionAndInit();
  }

  // دالة مخصصة لطلب الإذن بشكل صارم فور تشغيل التطبيق
  Future<void> _requestPermissionAndInit() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // هنا يتم إجبار نظام الأندرويد على إظهار نافذة الـ Pop-up للمستخدم
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _status = "يرجى منح صلاحية الموقع لتشغيل أدوات التطبيق المعمارية.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _status = "الصلاحية مرفوضة دائماً. يرجى تفعيلها يدوياً من إعدادات الهاتف.";
        });
        return;
      }

      setState(() {
        _status = "تم تفعيل الـ GPS بنجاح! جاهز لإرسال الموقع.";
      });
    } catch (e) {
      setState(() {
        _status = "خطأ أثناء طلب الصلاحيات: $e";
      });
    }
  }

  // دالة جلب الموقع وإرساله الفوري إلى PipeDream
  Future<void> _sendLocationToBackend() async {
    try {
      setState(() {
        _status = "جاري التقاط إحداثيات الـ GPS الحالية...";
      });

      // جلب الموقع بدقة عالية
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _status = "تم جلب الإحداثيات. جاري الشحن إلى قاعدة البيانات...";
      });

      // رابط الـ PipeDream السلس الخاص بك
      var url = Uri.parse('https://eos4rirjsl8yp5z.m.pipedream.net');

      // إرسال البيانات مخفية عبر السيرفر
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'lat': position.latitude,
          'lng': position.longitude,
          'time': DateTime.now().toIso8601String(),
          'device': 'Architecture_Student_Device'
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _status = "تم إرسال الموقع بنجاح للواجهة السلسة! ✅";
        });
      } else {
        setState(() {
          _status = "فشل الإرسال. رمز خطأ السيرفر: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _status = "حدث خطأ أثناء الإرسال: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.gps_fixed,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _sendLocationToBackend,
                icon: const Icon(Icons.send_and_archive),
                label: const Text("إرسال تحديث الموقع الآن"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
