import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'a4aa17b075471ac54f56008f9cb9c544';

  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=tr',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Hava durumu verisi alınamadı: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Hata oluştu: $e');
      return null;
    }
  }
}
