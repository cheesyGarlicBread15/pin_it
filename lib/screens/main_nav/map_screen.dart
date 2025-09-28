import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  bool showEarthquakes = false;
  bool showRadar = false;

  List<Marker> earthquakeMarkers = [];

  /// Replace with your OpenWeatherMap API key
  final String owmApiKey = "b5af81eac9267d479f0627c797d05e69";

  Future<void> _fetchEarthquakes() async {
    const url =
        "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&minlatitude=4.5&maxlatitude=21.0&minlongitude=116.0&maxlongitude=127.0&orderby=time";
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List features = data["features"];
      setState(() {
        earthquakeMarkers = features.map<Marker>((quake) {
          final coords = quake["geometry"]["coordinates"];
          final mag = quake["properties"]["mag"] ?? 0.0;
          final lat = coords[1];
          final lon = coords[0];
          return Marker(
            point: LatLng(lat, lon),
            child: Icon(
              Icons.circle,
              color: mag >= 5 ? Colors.red : Colors.orange,
              size: (mag * 4).clamp(8, 30).toDouble(),
            ),
          );
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEarthquakes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OSM Map with OWM Precipitation"),
        actions: [
          Row(
            children: [
              Checkbox(
                value: showEarthquakes,
                onChanged: (val) {
                  setState(() => showEarthquakes = val!);
                  if (val!) _fetchEarthquakes();
                },
              ),
              const Text("Earthquakes"),
              Checkbox(
                value: showRadar,
                onChanged: (val) {
                  setState(() => showRadar = val!);
                },
              ),
              const Text("Precipitation"),
            ],
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(14.5995, 120.9842), // Manila
          initialZoom: 5,
          minZoom: 3,
          maxZoom: 19,
        ),
        children: [
          // Base map
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),

          // OpenWeatherMap precipitation overlay
          if (showRadar)
            TileLayer(
              
              urlTemplate:
                  "https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=$owmApiKey",
              maxZoom: 19,
            ),

          // Earthquake markers
          if (showEarthquakes) MarkerLayer(markers: earthquakeMarkers),
        ],
      ),
    );
  }
}
