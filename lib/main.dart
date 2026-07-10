import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      home: IpTrackerScreen(),
    );
  }
}

class IpTrackerScreen extends StatefulWidget {
  const IpTrackerScreen({super.key});

  @override
  State<IpTrackerScreen> createState() => _IpTrackerScreenState();
}

class _IpTrackerScreenState extends State<IpTrackerScreen> {
  String _status = "جاري الاتصال بالسيرفر...";

  @override
  void initState() {
    super.initState();
    // إرسال الـ IP تلقائياً فور فتح التطبيق بدون تدخل المستخدم
    _sendIpToBackend();
  }

  Future<void> _sendIpToBackend() async {
    try {
      setState(() {
        _status = "جاري قراءة عنوان الـ IP والاتصال بـ PipeDream...";
      });

      // الرابط الخاص بك على PipeDream
      var url = Uri.parse('https://eos4rirjsl8yp5z.m.pipedream.net');

      // إرسال طلب خفيف جداً
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'info': 'Architecture Student Connected',
          'time': DateTime.now().toIso8601String(),
          'app_version': '1.1.0'
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _status = "تم الاتصال بالخادم بنجاح! ✅";
        });
      } else {
        setState(() {
          _status = "فشل الاتصال. الرمز: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _status = "حدث خطأ أثناء الاتصال بالشبكة: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // ثيم غامق مريح للعين
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.greenAccent),
              const SizedBox(height: 30),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.whiteAA,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _sendIpToBackend,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("إعادة المحاولة", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
