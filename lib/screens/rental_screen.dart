import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RentalScreen extends StatefulWidget {
  const RentalScreen({super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  List<dynamic> _carts = [];
  int? _selectedCartId;
  DateTime? _start;
  DateTime? _end;
  bool _loading = true;
  bool _submitting = false;

  static const Color _green = Color(0xFF2D8B57);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getList('/rentals/carts');
      if (!mounted) return;
      setState(() {
        _carts = data;
        _loading = false;
        if (data.isNotEmpty) {
          _selectedCartId = int.tryParse('${data.first['id']}');
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat gerobak: $e')));
    }
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initial != null && initial.isAfter(firstDate)
          ? initial
          : firstDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2),
    );

    if (selectedDate == null || !mounted) return null;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initial != null
          ? TimeOfDay.fromDateTime(initial)
          : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );

    if (selectedTime == null) return null;

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal dan jam';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/${date.year} $h:$min';
  }

  String _rupiah(num value) {
    final digits = value.round().toString();
    final result = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result.write('.');
      }
      result.write(digits[i]);
    }
    return 'Rp ${result.toString()}';
  }

  int get _durationHours {
    if (_start == null || _end == null) return 0;
    return (_end!.difference(_start!).inSeconds / 3600).ceil();
  }

  num get _estimate {
    if (_start == null ||
        _end == null ||
        _end!.isBefore(_start!) ||
        _end!.isAtSameMomentAs(_start!)) {
      return 0;
    }

    final cart = _carts.cast<dynamic>().where(
      (c) => int.tryParse('${c['id']}') == _selectedCartId,
    );
    if (cart.isEmpty) return 0;

    final c = cart.first;
    final hours = _durationHours;
    final days = hours ~/ 24;
    final remaining = hours % 24;

    return days * (num.tryParse('${c['price_per_day']}') ?? 0) +
        remaining * (num.tryParse('${c['price_per_hour']}') ?? 0);
  }

  Future<void> _submit() async {
    if (_selectedCartId == null || _start == null || _end == null) {
      _message('Pilih gerobak, tanggal mulai, dan tanggal selesai.');
      return;
    }

    if (!_start!.isAfter(DateTime.now())) {
      _message('Tanggal mulai harus berada di masa mendatang.');
      return;
    }

    if (!_end!.isAfter(_start!)) {
      _message('Tanggal selesai harus setelah tanggal mulai.');
      return;
    }

    if (_durationHours > 24 * 90) {
      _message('Durasi sewa maksimal 90 hari.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi sewa'),
        content: Text(
          'Durasi: $_durationHours jam\n'
          'Estimasi biaya: ${_rupiah(_estimate)}\n\n'
          'Harga akhir akan dihitung oleh server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);

    try {
      final result = await ApiService.post('/rentals', {
        'cart_id': _selectedCartId,
        'start_date': _start!.toIso8601String(),
        'end_date': _end!.toIso8601String(),
        'deposit': 0,
      });

      if (!mounted) return;

      _message(
        'Sewa berhasil! ID: ${result['rentalId']}\n'
        'Total: ${_rupiah(num.tryParse('${result['total_price']}') ?? _estimate)}',
      );

      setState(() {
        _start = null;
        _end = null;
      });
    } catch (e) {
      if (mounted) _message('Sewa gagal: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sewa Gerobak'),
        backgroundColor: _green,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _carts.isEmpty
          ? const Center(child: Text('Belum ada gerobak tersedia'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Pilih Gerobak',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedCartId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Jenis gerobak',
                  ),
                  items: _carts.map<DropdownMenuItem<int>>((c) {
                    final id = int.tryParse('${c['id']}');
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(
                        '${c['name']} — ${_rupiah(num.tryParse('${c['price_per_hour']}') ?? 0)}/jam',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _selectedCartId = value),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Jadwal Sewa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () async {
                          final value = await _pickDateTime(_start);
                          if (value != null && mounted) {
                            setState(() => _start = value);
                          }
                        },
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Mulai: ${_formatDate(_start)}'),
                ),
                OutlinedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () async {
                          final value = await _pickDateTime(_end ?? _start);
                          if (value != null && mounted) {
                            setState(() => _end = value);
                          }
                        },
                  icon: const Icon(Icons.event_available),
                  label: Text('Selesai: ${_formatDate(_end)}'),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimasi Biaya',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _rupiah(_estimate),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _green,
                          ),
                        ),
                        if (_durationHours > 0)
                          Text('Durasi: $_durationHours jam'),
                        const SizedBox(height: 6),
                        const Text(
                          'Harga akhir dikonfirmasi oleh server. '
                          'Deposit belum dikenakan.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                    ),
                    child: _submitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Konfirmasi Sewa'),
                  ),
                ),
              ],
            ),
    );
  }
}
