import 'package:flutter/material.dart';
import 'package:sentinel/models/alert_detail.dart';
import 'package:sentinel/models/alert_status.dart';
import 'package:sentinel/services/alert_service.dart';

class AlertDetailScreen extends StatefulWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  AlertDetail? _alert;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAcknowledging = false;

  @override
  void initState() {
    super.initState();
    _fetchAlert();
  }

  Future<void> _fetchAlert() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final id = int.parse(widget.alertId);
      final alert = await AlertService.instance.getAlertDetail(id);
      if (mounted) setState(() { _alert = alert; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _acknowledge() async {
    setState(() => _isAcknowledging = true);
    try {
      await AlertService.instance.acknowledge(int.parse(widget.alertId));
      if (mounted) {
        setState(() {
          _alert = _alert!.copyWith(status: AlertStatus.acknowledged);
          _isAcknowledging = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert onaylandı.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAcknowledging = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  Future<void> _openClip() async {
    try {
      final url = await AlertService.instance.getClipUrl(int.parse(widget.alertId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Clip URL: $url')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clip yüklenemedi: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  String _fmt(DateTime dt) {
    final d = dt.toLocal();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.day)}.${p(d.month)}.${d.year} ${p(d.hour)}:${p(d.minute)}:${p(d.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alert #${widget.alertId}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(_errorMessage!,
                            textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _fetchAlert,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final alert = _alert!;
    final isAcknowledged = alert.status == AlertStatus.acknowledged;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                avatar: Icon(
                  isAcknowledged
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  size: 18,
                  color: isAcknowledged
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
                label: Text(isAcknowledged ? 'Onaylandı' : 'Görülmedi'),
                backgroundColor: isAcknowledged
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Tür', value: alert.type),
          _DetailRow(
            label: 'Kamera',
            value: alert.cameraName ?? '#${alert.cameraId}',
          ),
          _DetailRow(label: 'Tarih', value: _fmt(alert.timestamp)),
          if (alert.description != null && alert.description!.isNotEmpty)
            _DetailRow(label: 'Açıklama', value: alert.description!),
          const SizedBox(height: 24),
          if (alert.clipObjectKey != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openClip,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Video Klibini İzle'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (!isAcknowledged)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isAcknowledging ? null : _acknowledge,
                icon: _isAcknowledging
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Onayla'),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
