import 'package:flutter/material.dart';


class VendorDashboard extends StatelessWidget {
  const VendorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Task List'),
            _TaskListPanel(),
            const SizedBox(height: 24),
            _SectionTitle('File Uploads'),
            _FileUploadPanel(),
            const SizedBox(height: 24),
            _SectionTitle('Real-Time Updates'),
            _RealtimeUpdatesPanel(),
            const SizedBox(height: 24),
            _SectionTitle('SOS'),
            _SOSButton(),
            const SizedBox(height: 24),
            _SectionTitle('AI Assistant'),
            _AIAssistantPanel(),
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

class _TaskListPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Task list with status animations (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _FileUploadPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('File uploads with live progress (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _RealtimeUpdatesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Real-time task updates (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _SOSButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('SOS alert button (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _AIAssistantPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('AI assistant chatbot (coming soon)', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
