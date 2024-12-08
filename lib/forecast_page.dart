import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_service.dart';
import 'hourly_forecast_page.dart';

class ForecastPage extends StatefulWidget {
  final WeatherService weatherService;
  final String city;
  
  const ForecastPage({
    super.key,
    required this.weatherService,
    required this.city,
  });

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  Map<String, dynamic>? _forecastData;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final forecastData = await widget.weatherService.getForecastByCity(widget.city);
      setState(() {
        _forecastData = forecastData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('${widget.city} Forecast'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
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
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchForecast,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _getDailyForecasts().length,
                  itemBuilder: (context, index) {
                    final forecast = _getDailyForecasts()[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      forecast['dt'] * 1000,
                    );
                    final weather = forecast['weather'][0];

                    // Don't show today's forecast since we already show current weather
                    if (index == 0 && DateFormat('yyyy-MM-dd').format(date) == 
                        DateFormat('yyyy-MM-dd').format(DateTime.now())) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: InkWell(
                        onTap: () {
                          final dateStr = DateFormat('yyyy-MM-dd').format(date);
                          final hourlyForecasts = _forecastData!['list'].where((item) {
                            final itemDate = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
                            return DateFormat('yyyy-MM-dd').format(itemDate) == dateStr;
                          }).toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HourlyForecastPage(
                                hourlyForecasts: hourlyForecasts,
                                city: widget.city,
                                date: date,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                _getWeatherIcon(weather['main']),
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      date.day == DateTime.now().day
                                          ? 'Today'
                                          : DateFormat('EEEE, MMM d').format(date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      weather['description'].toString().toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '↑${forecast['temp_max'].round()}°C',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '↓${forecast['temp_min'].round()}°C',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  List<dynamic> _getDailyForecasts() {
    if (_forecastData == null || _forecastData!['list'] == null) {
      return [];
    }

    final Map<String, dynamic> dailyForecasts = {};
    final Map<String, double> maxTemps = {};
    final Map<String, double> minTemps = {};
    
    for (var forecast in _forecastData!['list']) {
      final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final temp = (forecast['main']['temp'] is int) 
          ? (forecast['main']['temp'] as int).toDouble()
          : forecast['main']['temp'] as double;
      
      // Update max and min temperatures for this day
      maxTemps[dateStr] = (maxTemps[dateStr] ?? temp).compareTo(temp) > 0 
          ? maxTemps[dateStr]! 
          : temp;
      minTemps[dateStr] = (minTemps[dateStr] ?? temp).compareTo(temp) < 0 
          ? minTemps[dateStr]! 
          : temp;
      
      // For each day, use the forecast from around noon (12:00)
      final hour = date.hour;
      if (dailyForecasts[dateStr] == null || (hour - 12).abs() < (dailyForecasts[dateStr]['hour'] - 12).abs()) {
        forecast['hour'] = hour;
        dailyForecasts[dateStr] = forecast;
      }
    }

    // Add max and min temperatures to each daily forecast
    for (var entry in dailyForecasts.entries) {
      final dateStr = entry.key;
      dailyForecasts[dateStr]['temp_max'] = maxTemps[dateStr];
      dailyForecasts[dateStr]['temp_min'] = minTemps[dateStr];
    }

    return dailyForecasts.values.toList()
      ..sort((a, b) => (a['dt'] as int).compareTo(b['dt'] as int));
  }
}
