import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'tracking_screen.dart';
import 'rating_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getList('/bookings/my');
      setState(() { _bookings = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'in_progress': return Colors.blue;
      case 'confirmed': return const Color(0xFF2D8B57);
      default: return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'confirmed': return 'Dikonfirmasi';
      case 'in_progress': return 'Dalam Perjalanan';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: const Color(0xFF2D8B57),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D8B57)))
          : _bookings.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada pesanan', style: TextStyle(color: Colors.grey)),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFF2D8B57),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (_, i) {
                      final b = _bookings[i];
                      final status = b['status'] ?? 'pending';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Pesanan #${b['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(_statusLabel(status), style: TextStyle(color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.local_shipping, size: 15, color: Color(0xFF2D8B57)),
                              const SizedBox(width: 6),
                              Text(b['service_type'] ?? '-', style: const TextStyle(color: Color(0xFF2D8B57), fontWeight: FontWeight.w500)),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(b['pickup_location'] ?? b['pickup_address'] ?? '-', style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ]),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.flag, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(b['destination'] ?? b['dropoff_address'] ?? '-', style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ]),
                            const SizedBox(height: 10),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Rp ${b['total_price'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D8B57), fontSize: 15)),
                              Text(b['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ]),
                            if (status == 'in_progress') ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(
                                    bookingId: b['id'] as int,
                                    pickupAddress: b['pickup_location'] ?? b['pickup_address'] ?? '-',
                                    dropoffAddress: b['destination'] ?? b['dropoff_address'] ?? '-',
                                    pickupLatLng: LatLng(b['pickup_lat'] ?? -6.2088, b['pickup_lng'] ?? 106.8456),
                                    dropoffLatLng: LatLng(b['dropoff_lat'] ?? -6.2088, b['dropoff_lng'] ?? 106.9000),
                                  ))),
                                  icon: const Icon(Icons.location_on),
                                  label: const Text('Lacak Driver'),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D8B57), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                ),
                              ),
                            ],
                            if (status == 'completed') ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RatingScreen(bookingId: b['id'] as int, bookingType: 'booking'))),
                                  icon: const Icon(Icons.star_outline),
                                  label: const Text('Beri Rating'),
                                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2D8B57), side: const BorderSide(color: Color(0xFF2D8B57)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                ),
                              ),
                            ],
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}