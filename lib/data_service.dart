import 'package:flutter_weather_app/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataService {
  bool isNumeric(String s) {
    //   if (s == null) {
    //     return false;
    //   }
    return double.tryParse(s) != null;
  }

  Future<WeatherData> fetchWeatherData(String city) async {
    var weatherKey = 'b254a5652f0594f0e3d3c9ce8bef5d5e';
    Uri url;

    if (isNumeric(city)) {
      url = Uri.https('api.openweathermap.org', '/data/2.5/weather',
          {'id': city, 'appid': weatherKey, 'units': 'imperial', 'cnt': 1});
    } else {
      url = Uri.https('api.openweathermap.org', '/data/2.5/weather',
          {'q': city, 'appid': weatherKey, 'units': 'imperial'});
    }

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final result = WeatherData.fromJson(jsonDecode(response.body));
      // print(result.cityName);
      // print(result.temp);

      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}
