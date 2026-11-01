import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  final int initialTab;
  const HistoryScreen({super.key, this.initialTab = 0});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List _bookings = [], _rentals = [], _ratings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    _load();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    final svc = context.read<AuthService>();
    final b = await svc.get('/api/bookings/my');
    final r = await svc.get('/api/rentals/my');
    final rt = await svc.get('/api/ratings/my');
    if (!mounted) return;
    setState(() {
      _bookings = b is List ? b : [];
      _rentals = r is List ? r : [];
      _ratings = rt is List ? rt : [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Riwayat'),
        backgroundColor: const Color(0xFF2D8B57),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Pesanan'), Tab(text: 'Sewa'), Tab(text: 'Rating')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D8B57)))
          : TabBarView(controller: _tab, children: [
              _BookingList(_bookings),
              _RentalList(_rentals),
              _RatingList(_ratings),
            ]),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List items;
  const _BookingList(this.items);

  Color _sc(String? s) {
    switch (s) {
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'in_progress': return Colors.blue;
      default: return Colors.orange;
    }
  }

  String _sl(String? s) {
    switch (s) {
      case 'pending': return 'Menunggu';
      case 'confirmed': return 'Dikonfirmasi';
      case 'in_progress': return 'Dalam Perjalanan';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return s ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _Empty(msg: 'Belum ada riwayat pesanan');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final b = items[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.local_shipping, color: Color(0xFF2D8B57), size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(b['service_type'] ?? 'Pesanan', style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _sc(b['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(_sl(b['status']), style: TextStyle(color: _sc(b['status']), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(b['pickup_address'] ?? '-', style: const TextStyle(fontSize: 12, color: Colors.grey)))]),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.flag, size: 14, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(b['dropoff_address'] ?? '-', style: const TextStyle(fontSize: 12, color: Colors.grey)))]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Rp ${b["total_price"] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D8B57), fontSize: 16)),
                Text(b['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _RentalList extends StatelessWidget {
  final List items;
  const _RentalList(this.items);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _Empty(msg: 'Belum ada riwayat sewa');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final r = items[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.shopping_cart, color: Color(0xFF2D8B57), size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(r['cart_name'] ?? 'Gerobak', style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(r['status'] ?? '-', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('${r["start_date"] ?? "-"} - ${r["end_date"] ?? "-"}', style: const TextStyle(fontSize: 12, color: Colors.grey))]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Rp ${r["total_price"] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D8B57), fontSize: 16)),
                Text(r['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _RatingList extends StatelessWidget {
  final List items;
  const _RatingList(this.items);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _Empty(msg: 'Belum ada riwayat rating');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final r = items[i];
        final rating = (r['rating'] ?? 0) as int;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                ...List.generate(5, (j) => Icon(j < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 18)),
                const SizedBox(width: 8),
                Text('$rating/5', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              if ((r['review'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(r['review'].toString(), style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 4),
              Text(r['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  final String msg;
  const _Empty({required this.msg});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.inbox, size: 64, color: Colors.grey),
      const SizedBox(height: 12),
      Text(msg, style: const TextStyle(color: Colors.grey)),
    ]));
  }
}