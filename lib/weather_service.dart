import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService({required this.apiKey});

  Future<Position> _getCurrentLocation() async {
    print('Checking location services...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');
      throw Exception('Location services are disabled');
    }

    print('Checking location permission...');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('Requesting location permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions denied');
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions permanently denied');
      throw Exception('Location permissions are permanently denied');
    }

    print('Getting current position...');
    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    try {
      final String fullUrl = '$baseUrl?q=$city&appid=$apiKey&units=metric';
      print('Requesting weather from: $fullUrl');

      final response = await http.get(Uri.parse(fullUrl));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load weather data: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getWeatherByCity: $e');
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<Map<String, dynamic>> getWeather() async {
    try {
      print('Getting current location...');
      final position = await _getCurrentLocation();
      print('Position received: ${position.latitude}, ${position.longitude}');
      
      final String fullUrl = '$baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';
      print('Requesting weather from: $fullUrl');

      final response = await http.get(Uri.parse(fullUrl));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load weather data: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getWeather: $e');
      throw Exception('Error fetching weather data: $e');
    }
  }
}
