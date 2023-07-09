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

  @override
  void initState() {
    super.initState();
    fetchWeatherData('Bangladesh'); // Default location
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
                errorWidget: (context, url, error) => Icon(Icons.error),
                height: 200, // Increase the height
                width: 200, // Increase the width
              ),
              SizedBox(height: 10),
              Text(
                weatherData != null
                    ? 'Last Updated: ${weatherData!.getLastUpdated()}'
                    : '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherData {
  final String location;
  final int temperature;
  final String description;
  final String icon;
  final String lastUpdated;

  WeatherData({
    required this.location,
    required this.temperature,
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
      description: weather['description'],
      icon: weather['icon'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(dt * 1000).toString(),
    );
  }

  String getLocation() {
    return location;
  }

  String getTemperature() {
    return '$temperature°C';
  }

  String getDescription() {
    return description.toUpperCase();
  }

  String getIconUrl() {
    return 'http://openweathermap.org/img/w/$icon.png';
  }

  String getLastUpdated() {
    final dateTime = DateTime.parse(lastUpdated);
    final formattedDateTime = DateFormat('MMM d, yyyy hh:mm:ss a').format(dateTime);
    return formattedDateTime;
  }
}
