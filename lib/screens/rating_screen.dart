import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RatingScreen extends StatefulWidget {
  final int bookingId;
  final String bookingType;
  const RatingScreen({
    super.key,
    required this.bookingId,
    this.bookingType = 'booking',
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 5;
  final _reviewCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ApiService.post('/ratings', {
        'booking_id': widget.bookingId,
        'rating': _rating,
        'review': _reviewCtrl.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terima kasih atas ulasanmu!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim ulasan')),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beri Ulasan'),
        backgroundColor: const Color(0xFF2D8B57),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.local_shipping, size: 64, color: Color(0xFF2D8B57)),
            const SizedBox(height: 16),
            const Text('Bagaimana pengalamanmu?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Ulasanmu membantu kami berkembang',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 48,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _rating == 5 ? 'Luar Biasa!' :
              _rating == 4 ? 'Bagus!' :
              _rating == 3 ? 'Cukup' :
              _rating == 2 ? 'Kurang' : 'Mengecewakan',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _reviewCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis ulasanmu di sini...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
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
                    : const Text('Kirim Ulasan',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
