import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/data/weather_cache.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/screens/home/widgets/empty_state_view.dart';
import 'package:weather_app/screens/home/widgets/error_state_view.dart';
import 'package:weather_app/screens/home/widgets/weather_content.dart';
import 'package:weather_app/screens/search_screen.dart';
import 'package:weather_app/services/location_service.dart';
import 'package:weather_app/services/weather_api.dart';
import 'package:weather_app/widgets/loading_skeleton.dart';
import 'package:weather_app/screens/home/widgets/offline_banner.dart';

import '../../models/place.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Place? selectedPlace;

  final LocationService _locationService = LocationService();
  bool _isLocating = false;

  final weatherApi = WeatherApi();

  Weather? _weather;
  bool _isFetchingWeather = false;
  bool _isRefreshingWeather = false;
  String? _error;
  DateTime? _lastUpdated;

  bool _isRetryingFromError = false;

  bool _didInitLoad = false;
  bool _isOffline = false;

  final cache = WeatherCache();

  Future<void> _loadWeatherFor(
    Place place, {
    bool showSnackOnFail = true,
  }) async {
    if (_isFetchingWeather) return;

    setState(() {
      _isFetchingWeather = true;
      _isRefreshingWeather = _weather != null;
      _error = null;
      _isOffline = false;
    });

    try {
      final result = await weatherApi.fetchWeatherWithRawJson(
        place.latitude,
        place.longitude,
      );

      if (!mounted) return;

      final now = DateTime.now();

      setState(() {
        _weather = result.weather;
        _lastUpdated = now;
        _isOffline = false;
        _error = null;
      });

      cache.save(
        place: place,
        fullResponseJson: result.rawJson,
        updatedAt: now,
      );
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().replaceFirst('Exception: ', '');
      final hasCachedShown = _weather != null;

      setState(() {
        _error = msg;
        _isOffline = hasCachedShown;
      });

      if (!_isRetryingFromError && showSnackOnFail && !hasCachedShown) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading weather: $msg')));
      }
    } finally {
      if (!mounted) return;

      setState(() {
        _isFetchingWeather = false;
        _isRefreshingWeather = false;
        _isRetryingFromError = false;
      });
    }
  }

  Future<void> _useMyLocation() async {
    if (_isLocating) return;

    setState(() {
      _isLocating = true;
    });

    try {
      final position = await _locationService.getCurrentPositionOrThrow();

      if (!mounted) return;

      final place = Place(
          name: 'My Location',
          country: '',
          latitude: position.latitude,
          longitude: position.longitude,
        );

      setState(() {
        selectedPlace = place;
      });

      await _loadWeatherFor(place);

    } on PermissionDenied {
      await _showPermissionDeniedDialog();
    } on PermissionDeniedForever {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Enable location permission?'),
          content: Text(
            'Location permissions are permanently denied. Please enable them in settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
              child: Text('Open settings'),
            ),
          ],
        ),
      );
    } on LocationServiceDisabled {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location services disabled'),
          content: Text(
            'Please enable location services in your device settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: Text('Open location settings'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Allow location access?'),
        content: Text(
          'We use your location to show local weather. Allow access to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.microtask(_useMyLocation);
            },
            child: Text('Try again'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Not now'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didInitLoad) return;
      _didInitLoad = true;
      _loadCachedThenRefresh();
    });
  }

  Future<void> _loadCachedThenRefresh() async {
    final cached = await cache.load();
    if (cached != null) {
      setState(() {
        selectedPlace = cached.place;
        _weather = cached.weather;
        _lastUpdated = cached.updatedAt;
        _isOffline = false;
        _error = null;
      });

      await _loadWeatherFor(cached.place, showSnackOnFail: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showSkeleton =
        _isFetchingWeather && _weather == null && !_isRetryingFromError;
    final isRefreshing = _isRefreshingWeather;

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
        actions: [
          selectedPlace != null
              ? IconButton(
                  onPressed: isRefreshing
                      ? null
                      : () => _loadWeatherFor(selectedPlace!),
                  icon: _isRefreshingWeather
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.refresh_rounded),
                )
              : SizedBox.shrink(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: () async {
            if (selectedPlace != null && !_isFetchingWeather) {
              await _loadWeatherFor(selectedPlace!);
            }
          },
          child: SingleChildScrollView(
            physics: _weather == null
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            child: Column(
              spacing: 16,
              children: [
                OfflineBanner(
                  isOffline: _isOffline,
                  lastUpdated: _lastUpdated,
                  onRetry: selectedPlace == null
                      ? null
                      : () => _loadWeatherFor(
                          selectedPlace!,
                          showSnackOnFail: true,
                        ),
                ),
                InkWell(
                  onTap: _isRefreshingWeather
                      ? null
                      : () async {
                          final Place? place = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(),
                            ),
                          );
                          if (place != null) {
                            setState(() {
                              selectedPlace = place;
                            });
                            _loadWeatherFor(place);
                          }
                        },
                  child: IgnorePointer(
                    child: SearchBar(
                      hintText: selectedPlace?.name ?? 'Search city',
                      leading: Icon(Icons.search_rounded),
                      readOnly: true,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: (_isLocating || _isFetchingWeather)
                      ? null
                      : () => _useMyLocation(),
                  icon: Icon(Icons.my_location_rounded),
                  label: Text(
                    _isLocating
                        ? 'Getting location...'
                        : 'Use current location',
                  ),
                ),

                if (showSkeleton)
                  const WeatherSkeletonPage()
                else if (_weather != null)
                  WeatherContent(weather: _weather!, lastUpdated: _lastUpdated)
                else if (_error != null)
                  ErrorStateView(
                    errorMessage: _error!,
                    canRetry: selectedPlace != null,
                    isRetrying: _isRetryingFromError,
                    onRetry: () {
                      setState(() {
                        _isRetryingFromError = true;
                      });
                      _loadWeatherFor(selectedPlace!);
                    },
                  )
                else
                  EmptyStateView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
