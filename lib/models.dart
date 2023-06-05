class WeatherData {
  final String cityName;
  final double lat;
  final double lon;
  final String countryName;
  final String cityId;
  final double temp;
  final double windSpeed;
  final String description;
  final String iconUrl;
  final DateTime dateTime;
  final int timeZone;

  const WeatherData(
      {required this.cityName,
      required this.cityId,
      required this.countryName,
      required this.dateTime,
      required this.description,
      required this.lat,
      required this.lon,
      required this.temp,
      required this.iconUrl,
      required this.windSpeed,
      required this.timeZone});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final result = WeatherData(
        cityName: json['name'],
        cityId: json['id'].toString(),
        countryName: json['sys']['country'],
        description: json['weather'][0]['description'],
        lat: json['coord']['lat'],
        lon: json['coord']['lon'],
        temp: ((json['main']['temp'] * 10).round() / 10),
        iconUrl:
            'https://openweathermap.org/img/wn/${json['weather'][0]['icon']}@2x.png',
        windSpeed: ((json['wind']['speed'] * 10).round() / 10),
        timeZone: json['timezone'],
        dateTime:
            DateTime.now().toUtc().add(Duration(seconds: json['timezone'])));
    return result;
  }
}
