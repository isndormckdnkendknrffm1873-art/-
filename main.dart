import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

void sendLocationFast() async {
  try {
    // 1. جلب الموقع الحالي للجهاز
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // 2. الرابط الخاص بك من الصورة
    var url = Uri.parse('https://webhook.site/ed347329-8f2b-41e1-8e62-f88865ae0086');

    // 3. إرسال البيانات فوراً
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
    
    print("Status Code: ${response.statusCode}");
  } catch (e) {
    print("حدث خطأ أثناء الإرسال: $e");
  }
}
