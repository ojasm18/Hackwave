import 'package:flutter/material.dart';
import 'ai_service.dart';

class AIChatPanel extends StatefulWidget {
  final String? systemPrompt;
  final String? model;
  const AIChatPanel({super.key, this.systemPrompt, this.model});

  @override
  State<AIChatPanel> createState() => _AIChatPanelState();
}

class _AIChatPanelState extends State<AIChatPanel> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _controller.clear();
    final reply = await AIService.chat(text, systemPrompt: widget.systemPrompt, model: widget.model);
    if (!mounted) return;
    setState(() {
      _messages.add({'role': 'ai', 'content': reply});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Assistant', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                children: _messages
                    .map((m) => ListTile(
                          leading: Icon(m['role'] == 'user' ? Icons.person : Icons.smart_toy),
                          title: Text(m['content'] ?? ''),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Ask something...'),
                  ),
                ),
                IconButton(
                  icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.send),
                  onPressed: _isLoading ? null : _send,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
