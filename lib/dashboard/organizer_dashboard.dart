
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/supabase_manager.dart';


class OrganizerDashboard extends StatelessWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Event Overview'),
            _EventStats(),
            const SizedBox(height: 24),
            _SectionTitle('Agenda Builder'),
            _AgendaBuilder(),
            const SizedBox(height: 24),
            _SectionTitle('Vendor Task Manager'),
            _VendorTaskManager(),
            const SizedBox(height: 24),
            _SectionTitle('Sponsor Applications'),
            _SponsorApplications(),
            const SizedBox(height: 24),
            _SectionTitle('Announcements'),
            _AnnouncementsPanel(),
            const SizedBox(height: 24),
            _SectionTitle('Attendance Monitoring'),
            _AttendanceMonitor(),
            const SizedBox(height: 24),
            _SectionTitle('SOS Alerts'),
            _SOSAlertsPanel(),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.headlineMedium);
  }
}

class _EventStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!SupabaseManager.isReady) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatItem('Attendees', '-'),
              _StatItem('Tasks', '-'),
              _StatItem('Vendors', '-'),
              _StatItem('Sponsors', '-'),
            ],
          ),
        ),
      );
    }
    final checkinsStream = SupabaseManager.client
        .from('checkins')
        .stream(primaryKey: ['user_id', 'event_id']);
    final tasksStream = SupabaseManager.client
        .from('tasks')
        .stream(primaryKey: ['id']);
    final sponsorsStream = SupabaseManager.client
        .from('sponsors')
        .stream(primaryKey: ['id']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatStreamCount(label: 'Attendees', stream: checkinsStream, filter: (r) => r['event_id'] == 'event_456'),
            _StatStreamCount(label: 'Tasks', stream: tasksStream, filter: (r) => r['event_id'] == 'event_456'),
            _VendorDistinctCount(),
            _StatStreamCount(label: 'Sponsors', stream: sponsorsStream),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class _StatStreamCount extends StatelessWidget {
  final String label;
  final Stream<List<Map<String, dynamic>>> stream;
  final bool Function(Map<String, dynamic>)? filter;
  const _StatStreamCount({required this.label, required this.stream, this.filter});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? [];
        final filtered = filter == null ? rows : rows.where(filter!).toList();
        final count = filtered.length;
        return _StatItem(label, '$count');
      },
    );
  }
}

class _VendorDistinctCount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!SupabaseManager.isReady) return const _StatItem('Vendors', '-');
    final tasksStream = SupabaseManager.client
        .from('tasks')
        .stream(primaryKey: ['id']);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: tasksStream,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? [];
        final vendors = rows.map((e) => e['vendor_id']).where((v) => v != null).toSet();
        return _StatItem('Vendors', '${vendors.length}');
      },
    );
  }
}

class _AgendaBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Drag-and-drop agenda builder (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _VendorTaskManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Vendor task manager (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _SponsorApplications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Sponsor applications (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _AnnouncementsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stream = SupabaseManager.isReady
        ? SupabaseManager.client
            .from('announcements')
            .stream(primaryKey: ['id'])
        : const Stream<List<Map<String, dynamic>>>.empty();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Announcements:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (!SupabaseManager.isReady) return const Text('Supabase not configured.');
                final rows = snapshot.data ?? [];
                rows.sort((a, b) {
                  final ta = a['timestamp'];
                  final tb = b['timestamp'];
                  DateTime da, db;
                  if (ta is String) { da = DateTime.tryParse(ta) ?? DateTime.fromMillisecondsSinceEpoch(0); }
                  else if (ta is int) { da = DateTime.fromMillisecondsSinceEpoch(ta); }
                  else { da = DateTime.fromMillisecondsSinceEpoch(0); }
                  if (tb is String) { db = DateTime.tryParse(tb) ?? DateTime.fromMillisecondsSinceEpoch(0); }
                  else if (tb is int) { db = DateTime.fromMillisecondsSinceEpoch(tb); }
                  else { db = DateTime.fromMillisecondsSinceEpoch(0); }
                  return db.compareTo(da);
                });
                if (rows.isEmpty) return const Text('No announcements yet.');
                return Column(
                  children: rows.map((data) {
                    return ListTile(
                      title: Text(data['title']?.toString() ?? 'Announcement'),
                      subtitle: Text(data['message']?.toString() ?? ''),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceMonitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Attendance monitoring (QR check-in)'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/qr-scan'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Open QR Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SOSAlertsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stream = SupabaseManager.isReady
        ? SupabaseManager.client
            .from('sos_alerts')
            .stream(primaryKey: ['alert_id'])
        : const Stream<List<Map<String, dynamic>>>.empty();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active SOS Alerts'),
            const SizedBox(height: 8),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                final rows = snapshot.data ?? [];
                final active = rows.where((a) => (a['status'] ?? '') == 'active').toList();
                if (active.isEmpty) return const Text('No active alerts');
                return Column(
                  children: active.map((a) {
                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text('From: ${a['role'] ?? '-'} (${a['sender_id'] ?? ''})'),
                      subtitle: Text('Event: ${a['event_id'] ?? ''}'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
