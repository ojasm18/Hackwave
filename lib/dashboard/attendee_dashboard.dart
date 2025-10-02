
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/supabase_manager.dart';
import '../ai_assistant/ai_chat_panel.dart';


class AttendeeDashboard extends StatelessWidget {
  const AttendeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendee Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Personalized Agenda'),
            _PersonalAgenda(),
            const SizedBox(height: 24),
            _SectionTitle('QR Event Check-In'),
            _QRCheckIn(),
            const SizedBox(height: 24),
            _SectionTitle('Announcements'),
            _AnnouncementsPanel(),
            const SizedBox(height: 24),
            _SectionTitle('Feedback & Polls'),
            _FeedbackPolls(),
            const SizedBox(height: 24),
            _SectionTitle('Gamification'),
            _GamificationPanel(),
            const SizedBox(height: 24),
            _SectionTitle('SOS'),
            _SOSButton(),
            const SizedBox(height: 24),
            _SectionTitle('AI Chatbot'),
            _AIChatbotPanel(),
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


class _PersonalAgenda extends StatelessWidget {
  final List<Map<String, String>> sessions = const [
    {
      'time': '09:00',
      'title': 'Opening Ceremony',
      'desc': 'Welcome and introduction.'
    },
    {
      'time': '10:00',
      'title': 'Keynote: Future of Events',
      'desc': 'Speaker: Jane Doe'
    },
    {
      'time': '11:30',
      'title': 'Networking Break',
      'desc': 'Meet other attendees.'
    },
    {
      'time': '12:00',
      'title': 'Workshop: AI in Events',
      'desc': 'Hands-on session.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < sessions.length; i++)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (i < sessions.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.blueAccent,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sessions[i]['time']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(sessions[i]['title']!, style: const TextStyle(fontSize: 16)),
                        Text(sessions[i]['desc']!, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}


class _QRCheckIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = SupabaseManager.isReady
        ? (SupabaseManager.client.auth.currentUser?.id ?? 'user_demo')
        : 'user_demo';
    const eventId = 'event_456'; // Replace with actual event ID
    final qrData = '$userId|$eventId|checkin';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scan this QR code at the event entrance:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Center(
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 160,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text('Your check-in code: $qrData', style: const TextStyle(fontSize: 12)),
          ],
        ),
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
                if (!SupabaseManager.isReady) {
                  return const Text('Supabase not configured.');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
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
                    String timeStr = '';
                    final ts = data['timestamp'];
                    if (ts is String) {
                      timeStr = DateTime.tryParse(ts)?.toLocal().toString().substring(0, 16) ?? '';
                    } else if (ts is int) {
                      timeStr = DateTime.fromMillisecondsSinceEpoch(ts).toLocal().toString().substring(0, 16);
                    }
                    return ListTile(
                      title: Text(data['title']?.toString() ?? 'Announcement'),
                      subtitle: Text(data['message']?.toString() ?? ''),
                      trailing: Text(timeStr),
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


class _FeedbackPolls extends StatefulWidget {
  @override
  State<_FeedbackPolls> createState() => _FeedbackPollsState();
}

class _FeedbackPollsState extends State<_FeedbackPolls> {
  final _commentController = TextEditingController();
  double _rating = 3;
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);
    try {
      if (!SupabaseManager.isReady) throw Exception('Supabase not configured');
      final userId = SupabaseManager.client.auth.currentUser?.id ?? 'user_demo';
      await SupabaseManager.client.from('feedback').insert({
        'session_id': 'session_001', // Replace with actual session ID
        'user_id': userId,
        'rating': _rating,
        'comment': _commentController.text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _commentController.clear();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate this session:', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: i <= _rating ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () => setState(() => _rating = i.toDouble()),
                  ),
                Text(_rating.toString()),
              ],
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Add a comment'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              child: _isSubmitting ? const CircularProgressIndicator() : const Text('Submit'),
            ),
            const SizedBox(height: 16),
            const Text('Recent Feedback:', style: TextStyle(fontSize: 16)),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: SupabaseManager.isReady
                  ? SupabaseManager.client
                      .from('feedback')
                      .stream(primaryKey: ['id'])
                  : const Stream.empty(),
              builder: (context, snapshot) {
                if (!SupabaseManager.isReady) return const Text('Supabase not configured.');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
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
                final limited = rows.take(5).toList();
                if (limited.isEmpty) return const Text('No feedback yet.');
                return Column(
                  children: limited.map((data) {
                    String timeStr = '';
                    final ts = data['timestamp'];
                    if (ts is String) {
                      timeStr = DateTime.tryParse(ts)?.toLocal().toString().substring(0, 16) ?? '';
                    } else if (ts is int) {
                      timeStr = DateTime.fromMillisecondsSinceEpoch(ts).toLocal().toString().substring(0, 16);
                    }
                    return ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: Text('Rating: ${data['rating'] ?? '-'}'),
                      subtitle: Text(data['comment']?.toString() ?? ''),
                      trailing: Text(timeStr),
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


class _GamificationPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = SupabaseManager.isReady ? (SupabaseManager.client.auth.currentUser?.id ?? 'user_demo') : 'user_demo';
    final userStream = SupabaseManager.isReady
        ? SupabaseManager.client
            .from('gamification')
            .stream(primaryKey: ['user_id'])
        : const Stream<List<Map<String, dynamic>>>.empty();
    final topStream = SupabaseManager.isReady
        ? SupabaseManager.client
            .from('gamification')
            .stream(primaryKey: ['user_id'])
        : const Stream<List<Map<String, dynamic>>>.empty();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Points & Badges:', style: TextStyle(fontSize: 16)),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: userStream,
              builder: (context, snapshot) {
                final rows = snapshot.data ?? [];
                final filtered = rows.where((r) => r['user_id'] == userId).toList();
                final data = filtered.isNotEmpty ? filtered.first : <String, dynamic>{};
                final points = data['points'] ?? 0;
                final badges = (data['badges'] ?? []) as List;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Points: $points', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: badges.map((b) => Chip(label: Text(b.toString()))).toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Leaderboard:', style: TextStyle(fontSize: 16)),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: topStream,
              builder: (context, snapshot) {
                final rows = snapshot.data ?? [];
                rows.sort((a, b) => ((b['points'] ?? 0) as num).compareTo((a['points'] ?? 0) as num));
                final top5 = rows.take(5).toList();
                if (top5.isEmpty) return const Text('No leaderboard data yet.');
                return Column(
                  children: top5.map((data) {
                    return ListTile(
                      leading: const Icon(Icons.emoji_events, color: Colors.amber),
                      title: Text(data['user_id']?.toString() ?? 'User'),
                      trailing: Text('Points: ${data['points'] ?? 0}'),
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


class _SOSButton extends StatefulWidget {
  @override
  State<_SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<_SOSButton> {
  bool _isSending = false;
  bool _sent = false;

  Future<void> _sendSOS() async {
    setState(() { _isSending = true; });
    try {
      if (!SupabaseManager.isReady) throw Exception('Supabase not configured');
      final userId = SupabaseManager.client.auth.currentUser?.id ?? 'user_demo';
      await SupabaseManager.client.from('sos_alerts').insert({
        'sender_id': userId,
        'role': 'attendee',
        'event_id': 'event_456', // Replace with actual event ID
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'active',
      });
    } finally {
      setState(() { _isSending = false; _sent = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SOS Alert:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.warning, color: Colors.red),
              label: _isSending ? const Text('Sending...') : const Text('Send SOS Alert'),
              onPressed: _isSending || _sent ? null : _sendSOS,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
            if (_sent)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('SOS alert sent to organizers!', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}

class _AIChatbotPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AIChatPanel(
      systemPrompt: 'You are SyncSphere AI assistant helping attendees with event Q&A and navigation.',
    );
  }
}
