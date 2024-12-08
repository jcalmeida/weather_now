import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_service.dart';

class HourlyForecastPage extends StatelessWidget {
  final List<dynamic> hourlyForecasts;
  final String city;
  final DateTime date;

  const HourlyForecastPage({
    super.key,
    required this.hourlyForecasts,
    required this.city,
    required this.date,
  });

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
    print('Building HourlyForecastPage with ${hourlyForecasts.length} forecasts');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city),
            Text(
              'Next 24 Hours',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: hourlyForecasts.isEmpty
          ? Center(
              child: Text(
                'No forecast data available for the next 24 hours',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: hourlyForecasts.length,
              itemBuilder: (context, index) {
                final forecast = hourlyForecasts[index];
                final forecastTime = DateTime.fromMillisecondsSinceEpoch(
                  forecast['dt'] * 1000,
                );
                final temp = (forecast['main']['temp'] is int)
                    ? (forecast['main']['temp'] as int).toDouble()
                    : forecast['main']['temp'] as double;
                final weather = forecast['weather'][0];

                return Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            DateFormat('HH:mm').format(forecastTime),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          _getWeatherIcon(weather['main']),
                          size: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather['description'].toString().toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${temp.round()}°C',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Humidity',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${forecast['main']['humidity']}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
