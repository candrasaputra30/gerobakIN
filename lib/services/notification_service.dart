import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class NotificationService {
  static List<Map<String, dynamic>> _notifications = [];

  static List<Map<String, dynamic>> get notifications => _notifications;

  static Future<void> checkOrderStatus() async {
    try {
      final orders = await ApiService.getList('/bookings/my');
      final prefs = await SharedPreferences.getInstance();
      
      for (var order in orders) {
        final key = 'notif_${order['id']}_${order['status']}';
        final shown = prefs.getBool(key) ?? false;
        
        if (!shown) {
          _notifications.insert(0, {
            'id': order['id'],
            'title': 'Update Pesanan #${order['id']}',
            'message': _statusMessage(order['status']),
            'time': DateTime.now().toIso8601String(),
            'read': false,
          });
          await prefs.setBool(key, true);
        }
      }
    } catch (e) {}
  }

  static String _statusMessage(String status) {
    switch (status) {
      case 'confirmed': return 'Pesanan kamu sudah dikonfirmasi driver';
      case 'driver_heading': return 'Driver sedang menuju lokasi kamu';
      case 'driver_arrived': return 'Driver sudah tiba di lokasi';
      case 'in_progress': return 'Pengangkutan sedang berlangsung';
      case 'completed': return 'Pesanan selesai, terima kasih!';
      case 'cancelled': return 'Pesanan dibatalkan';
      default: return 'Status pesanan diupdate: $status';
    }
  }

  static void markRead(int index) {
    if (index < _notifications.length) {
      _notifications[index]['read'] = true;
    }
  }

  static int get unreadCount =>
      _notifications.where((n) => n['read'] == false).length;
}
