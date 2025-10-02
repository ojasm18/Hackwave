import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/supabase_manager.dart';
import '../roi_analytics/roi_chart.dart';


class SponsorDashboard extends StatelessWidget {
  const SponsorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sponsor Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Sponsor Profile'),
            _SponsorProfilePanel(),
            const SizedBox(height: 24),
            _SectionTitle('Sponsorship Applications'),
            _SponsorshipApplicationsPanel(),
            const SizedBox(height: 24),
            _SectionTitle('ROI Dashboard'),
            _ROIDashboardPanel(),
            const SizedBox(height: 24),
            _SectionTitle('Notifications'),
            _NotificationsPanel(),
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

class _SponsorProfilePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Sponsor profile (logo, description, links, coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _SponsorshipApplicationsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Apply for event sponsorships (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _ROIDashboardPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!SupabaseManager.isReady) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('ROI Dashboard', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Supabase not configured.'),
            ],
          ),
        ),
      );
    }
    final sponsorId = SupabaseManager.client.auth.currentUser?.id ?? 'sponsor_demo';
    final stream = SupabaseManager.client
        .from('sponsor_roi')
        .stream(primaryKey: ['sponsor_id', 'event_id']);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? [];
        final filtered = rows.where((r) => r['sponsor_id'] == sponsorId && r['event_id'] == 'event_456').toList();
        final row = filtered.isNotEmpty ? filtered.first : <String, dynamic>{};
        final revenue = (row['revenue_generated'] ?? 0) as num;
        final budget = (row['budget_committed'] ?? 0) as num;
        final visits = (row['booth_visits'] ?? 0) as num;
        final clicks = (row['clicks'] ?? 0) as num;
        final impressions = (row['impressions'] ?? 0) as num;
        final leads = (row['leads'] ?? 0) as num;
        return ROISummaryChart(
          revenueGenerated: revenue,
          budgetCommitted: budget,
          boothVisits: visits,
          clicks: clicks,
          impressions: impressions,
          leads: leads,
        );
      },
    );
  }
}

class _NotificationsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Notifications for approvals and reminders (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _AIChatbotPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('AI chatbot for ROI and applications (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
