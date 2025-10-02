import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../common/supabase_manager.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _handled = false;
  String? _message;

  Future<void> _handleScan(String raw) async {
    if (_handled) return;
    setState(() => _handled = true);
    try {
      final parts = raw.split('|');
      if (parts.length < 3) throw Exception('Invalid QR format');
      final userId = parts[0];
      final eventId = parts[1];
      final action = parts[2];
      if (action != 'checkin') throw Exception('Unsupported action');
      if (!SupabaseManager.isReady) {
        setState(() => _message = 'Supabase not configured.');
        return;
      }
      await SupabaseManager.client.from('checkins').insert({
        'user_id': userId,
        'event_id': eventId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      setState(() => _message = 'Check-in recorded for $userId');
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Stack(
        children: [
          MobileScanner(onDetect: (capture) {
            final barcodes = capture.barcodes;
            if (barcodes.isEmpty) return;
            final raw = barcodes.first.rawValue;
            if (raw != null) {
              _handleScan(raw);
            }
          }),
          if (_message != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(12),
                child: Text(_message!, style: const TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
