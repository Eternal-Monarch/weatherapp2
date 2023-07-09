import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

const apiKey = 'd9a523a4106fb48cb5347cec928c7897';
const weatherApiUrl =
    'https://api.openweathermap.org/data/2.5/weather?appid=$apiKey&units=metric';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool isLoading = false;
  bool isError = false;
  WeatherData? weatherData;
  TextEditingController _locationController = TextEditingController();
  bool isSearchBoxVisible = false;

  @override
  void initState() {
    super.initState();
    fetchWeatherData('Dhaka'); // Default location
  }

  Future<void> fetchWeatherData(String location) async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(Uri.parse('$weatherApiUrl&q=$location'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          weatherData = WeatherData.fromJson(data);
        });
      } else {
        setState(() {
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleSearchBox() {
    setState(() {
      isSearchBoxVisible = !isSearchBoxVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blue[900],
        appBar: AppBar(
          title: Text('Weather App'),
          centerTitle: true,
          backgroundColor: Colors.blue[800],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : isError
            ? Center(child: Text('Error fetching data'))
            : Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  weatherData != null ? weatherData!.getLocation() : '',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  weatherData != null ? weatherData!.getTemperature() : '',
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontFamily: 'CustomFont',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  weatherData != null ? weatherData!.getDescription() : '',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'CustomFont',
                  ),
                ),
                SizedBox(height: 20),
                CachedNetworkImage(
                  imageUrl:
                  weatherData != null ? weatherData!.getIconUrl() : '',
                  placeholder: (context, url) =>
                      CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error),
                  fit: BoxFit.contain, // Resize the image to fit
                  height: 150,
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    Text(
                      weatherData != null ? 'Max Temperature' : '',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      weatherData != null
                          ? '${weatherData!.getMaxTemperature()}'
                          : '',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      weatherData != null ? 'Min Temperature' : '',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      weatherData != null
                          ? '${weatherData!.getMinTemperature()}'
                          : '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      weatherData != null
                          ? 'Last Updated: ${weatherData!.getLastUpdated()}'
                          : '',
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Visibility(
                  visible: isSearchBoxVisible,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextField(
                      controller: _locationController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter city/country',
                        hintStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: toggleSearchBox,
                  child: Text(
                    isSearchBoxVisible ? 'Cancel' : 'Change Location',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    final String location =
                    _locationController.text.trim();
                    if (location.isNotEmpty) {
                      fetchWeatherData(location);
                    }
                  },
                  child: Text(
                    'Get Weather',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Visibility(
          visible: !isSearchBoxVisible,
          child: FloatingActionButton(
            onPressed: toggleSearchBox,
            child: Icon(Icons.search),
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class WeatherData {
  final String location;
  final int temperature;
  final int maxTemperature;
  final int minTemperature;
  final String description;
  final String icon;
  final String lastUpdated;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.maxTemperature,
    required this.minTemperature,
    required this.description,
    required this.icon,
    required this.lastUpdated,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final weather = json['weather'][0];
    final dt = json['dt'];
    final name = json['name'];

    return WeatherData(
      location: name,
      temperature: main['temp'].toInt(),
      maxTemperature: main['temp_max'].toInt(),
      minTemperature: main['temp_min'].toInt(),
      description: weather['description'],
      icon: weather['icon'],
      lastUpdated:
      DateTime.fromMillisecondsSinceEpoch(dt * 1000).toString(),
    );
  }

  String getLocation() {
    return location;
  }

  String getTemperature() {
    return '$temperature°C';
  }

  String getMaxTemperature() {
    return '${maxTemperature}°C';
  }

  String getMinTemperature() {
    return '${minTemperature}°C';
  }

  String getDescription() {
    return description.toUpperCase();
  }

  String getIconUrl() {
    return 'http://openweathermap.org/img/w/$icon.png';
  }

  String getLastUpdated() {
    final dateTime = DateTime.parse(lastUpdated);
    final formattedDateTime =
    DateFormat('MMM d, yyyy hh:mm:ss a').format(dateTime);
    return formattedDateTime;
  }
}
