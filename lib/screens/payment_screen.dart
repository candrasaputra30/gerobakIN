import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final double amount;
  const PaymentScreen({super.key, required this.bookingId, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'transfer';
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  final List<Map<String, dynamic>> _methods = [
    {'id': 'transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'id': 'qris', 'label': 'QRIS', 'icon': Icons.qr_code},
    {'id': 'cash', 'label': 'Tunai', 'icon': Icons.money},
  ];

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ApiService.post('/payments', {
        'booking_id': widget.bookingId,
        'amount': widget.amount,
        'method': _method,
        'notes': _notesCtrl.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil dibuat, tunggu konfirmasi admin')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat pembayaran')),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF2D8B57),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D8B57),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Total Pembayaran',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${widget.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Metode Pembayaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._methods.map((m) => GestureDetector(
              onTap: () => setState(() => _method = m['id']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _method == m['id']
                      ? const Color(0xFF2D8B57).withOpacity(0.1)
                      : Colors.white,
                  border: Border.all(
                    color: _method == m['id']
                        ? const Color(0xFF2D8B57)
                        : Colors.grey.shade300,
                    width: _method == m['id'] ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(m['icon'],
                        color: _method == m['id']
                            ? const Color(0xFF2D8B57)
                            : Colors.grey),
                    const SizedBox(width: 12),
                    Text(m['label'],
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _method == m['id']
                                ? const Color(0xFF2D8B57)
                                : Colors.black)),
                    const Spacer(),
                    if (_method == m['id'])
                      const Icon(Icons.check_circle,
                          color: Color(0xFF2D8B57)),
                  ],
                ),
              ),
            )),
            if (_method == 'transfer') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Info Transfer',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Bank BCA: 1234567890'),
                    Text('Bank Mandiri: 0987654321'),
                    Text('Atas nama: GERObakIN'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Contoh: Transfer BCA jam 14.00',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                    : const Text('Konfirmasi Pembayaran',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
