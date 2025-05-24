import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/websocket_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çiftçi Dostu',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16.0),
          bodyMedium: TextStyle(fontSize: 14.0),
        ),
      ),
      home: const WeatherPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});
  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  final WebSocketService webSocketService = WebSocketService();
  String? sicaklik;
  String? nem;
  List<double> sicaklikVerisi = [];
  List<double> nemVerisi = [];

  List<dynamic>? forecastData;
  String? selectedCity;
  Set<String> shownWarnings = {};

  @override
  void initState() {
    super.initState();
    webSocketService.connect('ws://localhost:3000');

    webSocketService.onMessageReceived = (data) {
      try {
        final jsonData = json.decode(data);
        final double temp = double.parse(jsonData['sicaklik'].toString());
        final double hum = double.parse(jsonData['nem'].toString());

        setState(() {
          sicaklik = temp.toStringAsFixed(1);
          nem = hum.toStringAsFixed(1);

          sicaklikVerisi.add(temp);
          nemVerisi.add(hum);

          if (sicaklikVerisi.length > 20) sicaklikVerisi.removeAt(0);
          if (nemVerisi.length > 20) nemVerisi.removeAt(0);
        });
      } catch (_) {}
    };
  }

  @override
  void dispose() {
    webSocketService.disconnect();
    super.dispose();
  }

  Future<void> fetchWeatherForecast(String city) async {
    setState(() => isLoading = true);
    const apiKey = 'a4aa17b075471ac54f56008f9cb9c544';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&lang=tr&appid=$apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          forecastData = data['list'];
          selectedCity = data['city']['name'];
        });

        final warnings = getForecastWarnings(data['list']);
        for (final warning in warnings) {
          if (!shownWarnings.contains(warning)) {
            shownWarnings.add(warning);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(warning),
                backgroundColor: Colors.orange.shade700,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Şehir bulunamadı")));
      }
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Veri alınamadı")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<String> getForecastWarnings(List<dynamic> forecastList) {
    List<String> warnings = [];

    for (var item in forecastList.take(40)) {
      final main = item['main'];
      final weather = item['weather'][0];
      final wind = item['wind'];

      final temp = main['temp'];
      final humidity = main['humidity'];
      final windSpeed = wind['speed'];
      final description = weather['description'].toLowerCase();

      if (temp < 0 &&
          !warnings.contains("🌨️ Don riski var! Bitkilerinizi koruyun.")) {
        warnings.add("🌨️ Don riski var! Bitkilerinizi koruyun.");
      }
      if (temp > 35 &&
          !warnings.contains("🔥 Aşırı sıcak! Sulama ihtiyacı artabilir.")) {
        warnings.add("🔥 Aşırı sıcak! Sulama ihtiyacı artabilir.");
      }
      if (description.contains('yağmur') &&
          !warnings.contains("🌧️ Yağmur bekleniyor. Ekinleri güvene alın.")) {
        warnings.add("🌧️ Yağmur bekleniyor. Ekinleri güvene alın.");
      }
      if (windSpeed > 14 &&
          !warnings.contains("🌬️ Kuvvetli rüzgar olabilir, seraları sabitleyin.")) {
        warnings.add("🌬️ Kuvvetli rüzgar olabilir, seraları sabitleyin.");
      }
      if (description.contains('dolu') &&
          !warnings.contains("🧊 Dolu riski! Bitkilere zarar gelebilir.")) {
        warnings.add("🧊 Dolu riski! Bitkilere zarar gelebilir.");
      }
      if (humidity > 90 &&
          !warnings.contains("💧 Yüksek nem! Mantar hastalıklarına dikkat.")) {
        warnings.add("💧 Yüksek nem! Mantar hastalıklarına dikkat.");
      }
    }

    return warnings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/yesil_tarla.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          color: Colors.black.withOpacity(0.4),
        ),
        SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 800),
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: "Şehir girin",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final city = _controller.text.trim();
                    if (city.isNotEmpty) {
                      fetchWeatherForecast(city);
                    }
                  },
                  child: const Text("📅 5 Günlük Tahmin Getir"),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (forecastData != null && forecastData!.isNotEmpty) ...[
                  Text(
                    "📅 5 Günlük Tahmin - $selectedCity",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final item = forecastData![index * 8];
                      final date = item['dt_txt'].split(' ')[0];
                      final temp = item['main']['temp'];
                      final desc = item['weather'][0]['description'];
                      final icon = item['weather'][0]['icon'];
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          leading: Image.network("https://openweathermap.org/img/wn/$icon.png"),
                          title: Text(date),
                          subtitle: Text("Sıcaklık: $temp°C\n$desc"),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 20),
                if (sicaklik != null && nem != null) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.water_drop),
                    label: const Text("💧 Sulamayı Başlat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      webSocketService.sendCommand("sula");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sulama komutu gönderildi."),
                          backgroundColor: Colors.teal,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text("🚫 Sulamayı Durdur"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      webSocketService.sendCommand("kapat");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sulamayı durdur komutu gönderildi."),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ]
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}