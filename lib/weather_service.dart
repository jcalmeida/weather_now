import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';
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
      } else if (response.statusCode == 404) {
        throw WeatherException('Location not found');
      } else {
        print('Error response: ${response.body}');
        throw WeatherException('Failed to load weather data: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getWeatherByCity: $e');
      if (e is WeatherException) {
        rethrow;
      }
      throw WeatherException('Error fetching weather data: $e');
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

  Future<Map<String, dynamic>> getForecast(double lat, double lon) async {
    try {
      final String fullUrl = '$forecastUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
      print('Requesting forecast from: $fullUrl');

      final response = await http.get(Uri.parse(fullUrl));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw WeatherException('Location not found');
      } else {
        print('Error response: ${response.body}');
        throw WeatherException('Failed to load forecast data: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getForecast: $e');
      if (e is WeatherException) {
        rethrow;
      }
      throw WeatherException('Error fetching forecast data: $e');
    }
  }

  Future<Map<String, dynamic>> getForecastByCity(String city) async {
    try {
      final String fullUrl = '$forecastUrl?q=$city&appid=$apiKey&units=metric';
      print('Requesting forecast from: $fullUrl');

      final response = await http.get(Uri.parse(fullUrl));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw WeatherException('City not found');
      } else {
        throw WeatherException('Failed to get forecast data');
      }
    } catch (e) {
      print('Error in getForecastByCity: $e');
      rethrow;
    }
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  
  @override
  String toString() => message;
}
