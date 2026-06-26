import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/location_service.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../../models/issue.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _initialPosition;
  String _selectedCategory = 'All';

  final List<String> _filters = [
    'All',
    'Pothole',
    'Streetlight Out',
    'Graffiti',
    'Litter',
    'Water Leak'
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      final position = await ref.read(locationServiceProvider).getCurrentLocation();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Fallback to a default location
      setState(() {
        _initialPosition = const LatLng(37.7749, -122.4194); // San Francisco
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _getMarkerColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _showIssueDetails(Issue issue) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(issue.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Chip(
                  label: Text(issue.severity),
                  backgroundColor: _getMarkerColor(issue.severity).withOpacity(0.2),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('Category: ${issue.category}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(issue.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/issue-details/${issue.id}');
                },
                child: const Text('View Full Details'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialPosition == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Acquiring satellite lock...'),
            ],
          ),
        ),
      );
    }

    final issuesAsync = ref.watch(nearbyIssuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_initialPosition != null) {
                _mapController.move(_initialPosition!, 14.0);
              }
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: _selectedCategory == filter,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = filter);
                      }
                    },
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: issuesAsync.when(
        data: (issues) {
          final filteredIssues = _selectedCategory == 'All' 
              ? issues 
              : issues.where((i) => i.category == _selectedCategory).toList();

          final markers = filteredIssues.map((issue) {
            return Marker(
              point: LatLng(issue.latitude, issue.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showIssueDetails(issue),
                child: Icon(
                  Icons.location_on,
                  color: _getMarkerColor(issue.severity),
                  size: 40,
                ),
              ),
            );
          }).toList();

          // Add Current Location Marker
          final currentLocationMarker = Marker(
            point: _initialPosition!,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 40,
            ),
          );

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition!,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.communityhero.app',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  markers: markers,
                  builder: (context, clusterMarkers) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: Text(
                          clusterMarkers.length.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
              MarkerLayer(
                markers: [currentLocationMarker],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading map data: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/report'),
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
