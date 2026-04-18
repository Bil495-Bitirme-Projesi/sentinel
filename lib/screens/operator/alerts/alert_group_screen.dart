import 'package:flutter/material.dart';
import 'package:sentinel/models/alert_summary.dart';
import 'package:sentinel/screens/operator/alerts/alert_detail_screen.dart';
import 'package:sentinel/services/alert_service.dart';

class AlertGroupScreen extends StatefulWidget {
  const AlertGroupScreen({
    super.key,
    required this.group,
    required this.onAcknowledged,
    this.showAcknowledgeButton = true,
  });

  final List<AlertSummary> group;
  final VoidCallback onAcknowledged;
  final bool showAcknowledgeButton;

  @override
  State<AlertGroupScreen> createState() => _AlertGroupScreenState();
}

class _AlertGroupScreenState extends State<AlertGroupScreen> {
  bool _isAcknowledging = false;

  String _fmt(DateTime dt) {
    final d = dt.toLocal();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.day)}.${p(d.month)}.${d.year} ${p(d.hour)}:${p(d.minute)}:${p(d.second)}';
  }

  Future<void> _acknowledgeAll() async {
    setState(() => _isAcknowledging = true);
    try {
      await Future.wait(
        widget.group.map((a) => AlertService.instance.acknowledge(a.alertId)),
      );
      if (mounted) {
        widget.onAcknowledged();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
        setState(() => _isAcknowledging = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.group.length} Alert'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.group.length,
              itemBuilder: (context, index) {
                final alert = widget.group[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.warning_amber_rounded,
                          color: Colors.orange.shade700, size: 20),
                    ),
                    title: Text(alert.type,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alert.cameraName ?? 'Kamera #${alert.cameraId}'),
                        Text(_fmt(alert.timestamp),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    isThreeLine: false,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AlertDetailScreen(
                            alertId: alert.alertId.toString(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (widget.showAcknowledgeButton)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isAcknowledging ? null : _acknowledgeAll,
                icon: _isAcknowledging
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Tümünü Onayla'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
