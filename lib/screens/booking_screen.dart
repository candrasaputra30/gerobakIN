import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String serviceType;
  const BookingScreen({super.key, required this.serviceType});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _pickupCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_pickupCtrl.text.isEmpty || _destCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi lokasi penjemputan dan tujuan')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await ApiService.post('/bookings', {
        'vehicle_id': 1,
        'pickup_location': _pickupCtrl.text,
        'destination': _destCtrl.text,
        'total_price': 150000,
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              bookingId: result['bookingId'],
              amount: 150000,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat pesanan')),
        );
      }
    }
    setState(() => _loading = false);
  }

  String get _title {
    switch (widget.serviceType) {
      case 'pindahan': return 'Pindahan Rumah';
      case 'angkut': return 'Angkut Barang';
      case 'kendaraan': return 'Sewa Kendaraan';
      default: return 'Pesan Layanan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: const Color(0xFF2D8B57),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lokasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _pickupCtrl,
              decoration: InputDecoration(
                labelText: 'Lokasi Penjemputan',
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2D8B57)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destCtrl,
              decoration: InputDecoration(
                labelText: 'Lokasi Tujuan',
                prefixIcon: const Icon(Icons.flag, color: Colors.red),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Catatan tambahan...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D8B57),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Pesan Sekarang',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
