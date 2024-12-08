import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'forecast_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService(
    apiKey: '8785e9eb67c9502a0bfc71a9a0f3669b',
  );
  Map<String, dynamic>? _weatherData;
  String? _error;
  bool _isLoading = false;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeatherByLocation();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('rain')) {
      return Icons.grain;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    } else if (condition.contains('thunderstorm')) {
      return Icons.flash_on;
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return Icons.cloud_queue;
    }
    return Icons.question_mark;
  }

  Future<void> _fetchWeatherByLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Fetching weather data...');
      final weatherData = await _weatherService.getWeather();
      print('Weather data received: $weatherData');
      
      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherByCity(String city) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Fetching weather for city: $city');
      final weatherData = await _weatherService.getWeatherByCity(city);
      print('Weather data received for $city: $weatherData');
      
      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching weather for $city: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showSearchDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter City Name'),
          content: TextField(
            autofocus: true,
            controller: _cityController,
            decoration: const InputDecoration(
              hintText: 'e.g., London',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (value) {
              Navigator.of(context).pop();
              _fetchWeatherByCity(value);
            },
          ),
          actions: [
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, size: 20),
                  SizedBox(width: 8),
                  Text('Cancel'),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchWeatherByCity(_cityController.text);
              },
              icon: const Icon(Icons.search, size: 20),
              label: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fetchWeatherByLocation,
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!.contains('Location not found')
                              ? 'City not found. Please check the spelling and try again.'
                              : 'Unable to fetch weather data.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_error!.contains('Location not found')) {
                              _showSearchDialog();
                            } else if (_cityController.text.isNotEmpty) {
                              _fetchWeatherByCity(_cityController.text);
                            } else {
                              _fetchWeatherByLocation();
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : _weatherData == null
                    ? const Text('No weather data available')
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_weatherData!['name']}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Icon(
                            _getWeatherIcon(_weatherData!['weather'][0]['main']),
                            size: 70,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${_weatherData!['main']['temp'].round()}°C',
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_weatherData!['weather'][0]['description']}'.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 32),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForecastPage(
                                    weatherService: _weatherService,
                                    city: _weatherData!['name'],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('7-Day Forecast'),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Min: ${_weatherData!['main']['temp_min'].round()}°C',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                'Max: ${_weatherData!['main']['temp_max'].round()}°C',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
      ),
    );
  }
}
