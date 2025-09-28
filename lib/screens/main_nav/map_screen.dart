import 'dart:async';
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
  List<int> radarFrames = [];
  int currentFrameIndex = 0;
  Timer? radarTimer;

  // Smooth fade control
  bool showFirstLayer = true;

  /// Fetch earthquakes from USGS
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

  /// Fetch RainViewer radar frames
  Future<void> _fetchRadarFrames() async {
    const url = "https://tilecache.rainviewer.com/api/maps.json";
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List && data.isNotEmpty) {
        setState(() {
          radarFrames = List<int>.from(data);
          currentFrameIndex = 0;
        });
        _startRadarAnimation();
      }
    }
  }

  /// Start radar animation with crossfade
  void _startRadarAnimation() {
    radarTimer?.cancel();
    radarTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentFrameIndex = (currentFrameIndex + 1) % radarFrames.length;
        showFirstLayer = !showFirstLayer; // toggle layer for smooth fade
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchEarthquakes();
    _fetchRadarFrames();
  }

  @override
  void dispose() {
    radarTimer?.cancel();
    super.dispose();
  }

  Widget _buildToggleButton({
    required String label,
    required bool value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: value ? Colors.blueAccent : Colors.white70,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: value ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(14.5995, 120.9842), // Manila
              initialZoom: 5,
              minZoom: 3,
              maxZoom: 12,
            ),
            children: [
              // Base map
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),

              // Radar overlay with smooth crossfade
              if (showRadar && radarFrames.isNotEmpty)
                Stack(
                  children: [
                    AnimatedOpacity(
                      opacity: showFirstLayer ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: TileLayer(
                        urlTemplate:
                            "https://tilecache.rainviewer.com/v2/radar/${radarFrames[currentFrameIndex]}/256/{z}/{x}/{y}/2/1_1.png",
                        maxNativeZoom: 12,
                        maxZoom: 12,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: showFirstLayer ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 800),
                      child: TileLayer(
                        urlTemplate:
                            "https://tilecache.rainviewer.com/v2/radar/${radarFrames[currentFrameIndex]}/256/{z}/{x}/{y}/2/1_1.png",
                        maxNativeZoom: 12,
                        maxZoom: 12,
                      ),
                    ),
                  ],
                ),

              // Earthquake markers
              if (showEarthquakes) MarkerLayer(markers: earthquakeMarkers),
            ],
          ),

          // Bottom-right toggle buttons
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildToggleButton(
                  label: "Earthquakes",
                  value: showEarthquakes,
                  onTap: () {
                    setState(() => showEarthquakes = !showEarthquakes);
                    if (showEarthquakes) _fetchEarthquakes();
                  },
                ),
                _buildToggleButton(
                  label: "Precipitation",
                  value: showRadar,
                  onTap: () {
                    setState(() => showRadar = !showRadar);
                    if (showRadar && radarFrames.isEmpty) _fetchRadarFrames();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
