// import 'package:english_words/english_words.dart';

import 'package:flutter/material.dart';
import 'package:flutter_weather_app/data_service.dart';
import 'package:flutter_weather_app/models.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String currentSearch = '';
  String currentId = '';

  @override
  notifyListeners();

  var favorites = <String>[];

  void addToFavorites() {
    if (favorites.contains(currentId)) {
      favorites.remove(currentId);
    } else {
      favorites.add(currentId);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GetLocation();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final _dataService = DataService();
    WeatherData? _weatherData;

    void search(location) async {
      final response = await _dataService.fetchWeatherData(location);
      _weatherData = response;
      appState.currentId = _weatherData!.cityId;
      print(response.cityName);
      print(response.temp);
    }

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Text('You have '
            '${appState.favorites.length} favorites:'),
      ),
      for (var cityId in appState.favorites) ...[
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text(cityId),
        ),
      ],
    ]);
  }
}

class GetLocation extends StatefulWidget {
  const GetLocation({super.key});

  @override
  State<GetLocation> createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final cityController = TextEditingController();
  final _dataService = DataService();
  WeatherData? _weatherData;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    String cityId = appState.currentId;

    IconData icon;
    if (appState.favorites.contains(cityId)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    void search(location) async {
      final response = await _dataService.fetchWeatherData(location);
      setState(() => _weatherData = response);
      appState.currentId = _weatherData!.cityId;
      print(response.cityName);
      print(response.temp);
    }

    var mainCard = [
      if (_weatherData != null)
        Column(
          children: createWeatherCard(appState, icon),
        ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: SizedBox(
          width: 150,
          child: TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City'),
              textAlign: TextAlign.center),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          {
            var searchCity = cityController.text;
            search(searchCity);
          }
        },
        child: const Text('Get Weather'),
      ),
    ];

    return MaterialApp(
        home: Scaffold(
      key: _formKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: mainCard,
        ),
      ),
    ));
  }

  List<Widget> createWeatherCard(MyAppState appState, IconData icon) {
    return [
      Text(
        '${_weatherData!.cityName}, ${_weatherData!.countryName}',
        style: TextStyle(fontSize: 40),
      ),
      Text(DateFormat("EEEE, MMMM d").format(_weatherData!.dateTime)),
      Text(DateFormat("Hm").format(_weatherData!.dateTime)),
      Image.network(_weatherData!.iconUrl),
      Text(
        '${_weatherData?.temp}°F',
        style: TextStyle(fontSize: 35),
      ),
      Text(
        _weatherData!.description,
        style: TextStyle(fontSize: 25),
      ),
      Text('Wind: ${_weatherData!.windSpeed.toString()} mph'),
      SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: () {
          appState.addToFavorites();
        },
        icon: Icon(icon),
        label: Text('Like'),
      ),
    ];
  }
}
