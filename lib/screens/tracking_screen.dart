import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class TrackingScreen extends StatefulWidget {
  final int bookingId;
  final String pickupAddress;
  final String dropoffAddress;
  final LatLng pickupLatLng;
  final LatLng dropoffLatLng;

  const TrackingScreen({
    super.key,
    required this.bookingId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLatLng,
    required this.dropoffLatLng,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _timer;
  LatLng? _driverLoc;
  String _driverName = '-';
  String _driverPhone = '-';
  String _lastUpdate = '-';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    final svc = context.read<AuthService>();
    final res = await svc.get('/api/locations/booking/${widget.bookingId}');
    if (!mounted) return;
    if (res is Map && res['latitude'] != null) {
      setState(() {
        _driverLoc = LatLng(
          (res['latitude'] as num).toDouble(),
          (res['longitude'] as num).toDouble(),
        );
        _driverName = res['driver_name'] ?? '-';
        _driverPhone = res['driver_phone'] ?? '-';
        _lastUpdate = res['updated_at']?.toString().substring(11, 19) ?? '-';
        _loading = false;
        _error = null;
      });
    } else {
      setState(() {
        _loading = false;
        _error = 'Menunggu driver memulai perjalanan...';
      });
    }
  }

  void _centerMap() {
    if (_driverLoc != null) {
      _mapController.move(_driverLoc!, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        point: widget.pickupLatLng,
        width: 40, height: 40,
        child: const Icon(Icons.location_on, color: Colors.green, size: 40),
      ),
      Marker(
        point: widget.dropoffLatLng,
        width: 40, height: 40,
        child: const Icon(Icons.flag, color: Colors.red, size: 40),
      ),
      if (_driverLoc != null)
        Marker(
          point: _driverLoc!,
          width: 50, height: 50,
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFF2D8B57), shape: BoxShape.circle),
            child: const Icon(Icons.local_shipping, color: Colors.white, size: 28),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Lacak Pesanan'),
        backgroundColor: const Color(0xFF2D8B57),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.my_location), onPressed: _centerMap),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _driverLoc ?? widget.pickupLatLng,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gerobak.gerobakIN',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            top: 12, left: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
              child: Row(children: [
                const Icon(Icons.circle, color: Colors.green, size: 10),
                const SizedBox(width: 6),
                Expanded(child: Text('Update: $_lastUpdate', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                GestureDetector(onTap: _fetch, child: const Icon(Icons.refresh, size: 18, color: Color(0xFF2D8B57))),
              ]),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              padding: const EdgeInsets.all(20),
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D8B57)))
                  : _error != null
                      ? Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.hourglass_empty, size: 40, color: Colors.orange),
                          const SizedBox(height: 8),
                          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                        ])
                      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(width: 44, height: 44, decoration: const BoxDecoration(color: Color(0xFF2D8B57), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(_driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(_driverPhone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ])),
                            Container(
                              decoration: BoxDecoration(color: const Color(0xFF2D8B57).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: IconButton(icon: const Icon(Icons.phone, color: Color(0xFF2D8B57)), onPressed: () {}),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.location_on, color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            Expanded(child: Text(widget.pickupAddress, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.flag, color: Colors.red, size: 16),
                            const SizedBox(width: 6),
                            Expanded(child: Text(widget.dropoffAddress, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ]),
                        ]),
            ),
          ),
        ],
      ),
    );
  }
}