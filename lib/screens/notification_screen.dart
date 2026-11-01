import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.checkOrderStatus();
  }

  @override
  Widget build(BuildContext context) {
    final notifs = NotificationService.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: const Color(0xFF2D8B57),
        foregroundColor: Colors.white,
      ),
      body: notifs.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada notifikasi',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifs.length,
              itemBuilder: (_, i) {
                final n = notifs[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: n['read'] ? Colors.white : const Color(0xFF2D8B57).withOpacity(0.05),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n['read']
                          ? Colors.grey.shade200
                          : const Color(0xFF2D8B57).withOpacity(0.1),
                      child: Icon(
                        Icons.local_shipping,
                        color: n['read'] ? Colors.grey : const Color(0xFF2D8B57),
                      ),
                    ),
                    title: Text(n['title'],
                        style: TextStyle(
                            fontWeight: n['read']
                                ? FontWeight.normal
                                : FontWeight.bold)),
                    subtitle: Text(n['message']),
                    onTap: () {
                      setState(() => NotificationService.markRead(i));
                    },
                  ),
                );
              },
            ),
    );
  }
}
