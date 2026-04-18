import 'package:flutter/material.dart';
import 'package:sentinel/models/alert_summary.dart';
import 'package:sentinel/screens/operator/alerts/alert_detail_screen.dart';
import 'package:sentinel/screens/operator/alerts/alert_group_screen.dart';
import 'package:sentinel/services/alert_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AlertSummary> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filtreler
  String _status = 'ACKNOWLEDGED';
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final alerts = await AlertService.instance.getAlerts(
        status: _status,
        from: _from,
        to: _to,
      );
      if (mounted) setState(() { _alerts = alerts; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  List<List<AlertSummary>> _groupAlerts(List<AlertSummary> alerts) {
    if (alerts.isEmpty) return [];
    final sorted = List<AlertSummary>.from(alerts)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final groups = <List<AlertSummary>>[];
    List<AlertSummary> current = [sorted.first];

    for (int i = 1; i < sorted.length; i++) {
      final diff = current.first.timestamp.difference(sorted[i].timestamp);
      if (diff.inMinutes < 5) {
        current.add(sorted[i]);
      } else {
        groups.add(current);
        current = [sorted[i]];
      }
    }
    groups.add(current);
    return groups;
  }

  Future<void> _openFilterSheet() async {
    String tempStatus = _status;
    DateTime? tempFrom = _from;
    DateTime? tempTo = _to;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          String fmtDate(DateTime? dt) {
            if (dt == null) return 'Seç';
            return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Filtreler',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setLocal(() {
                          tempStatus = 'ACKNOWLEDGED';
                          tempFrom = null;
                          tempTo = null;
                        });
                      },
                      child: const Text('Sıfırla'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Durum',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'ACKNOWLEDGED', label: Text('Onaylanmış')),
                    ButtonSegment(value: 'UNSEEN', label: Text('Görülmemiş')),
                  ],
                  selected: {tempStatus},
                  onSelectionChanged: (s) =>
                      setLocal(() => tempStatus = s.first),
                ),
                const SizedBox(height: 16),
                const Text('Tarih Aralığı',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text('Başlangıç: ${fmtDate(tempFrom)}'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: tempFrom ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setLocal(() => tempFrom = picked);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text('Bitiş: ${fmtDate(tempTo)}'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: tempTo ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setLocal(() => tempTo = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _status = tempStatus;
                        _from = tempFrom;
                        _to = tempTo;
                      });
                      Navigator.of(ctx).pop();
                      _fetchAlerts();
                    },
                    child: const Text('Uygula'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool get _hasActiveFilter => _from != null || _to != null || _status != 'ACKNOWLEDGED';

  @override
  Widget build(BuildContext context) {
    final groups = _groupAlerts(_alerts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _hasActiveFilter,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filtrele',
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAlerts,
          ),
        ],
      ),
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
                        onPressed: _fetchAlerts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAlerts,
                  child: groups.isEmpty
                      ? const CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              child: Center(
                                  child: Text('Kayıt bulunamadı.')),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: groups.length,
                          itemBuilder: (context, index) =>
                              _HistoryGroupCard(group: groups[index]),
                        ),
                ),
    );
  }
}

class _HistoryGroupCard extends StatelessWidget {
  const _HistoryGroupCard({required this.group});

  final List<AlertSummary> group;

  String _fmt(DateTime dt) {
    final d = dt.toLocal();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.day)}.${p(d.month)}.${d.year} ${p(d.hour)}:${p(d.minute)}';
  }

  void _navigate(BuildContext context) {
    if (group.length == 1) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            AlertDetailScreen(alertId: group.first.alertId.toString()),
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AlertGroupScreen(
          group: group,
          onAcknowledged: () {},
          showAcknowledgeButton: false,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = group.first;
    final isSingle = group.length == 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigate(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_circle_outline,
                    color: Colors.blueGrey.shade400),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(first.type,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(first.cameraName ?? 'Kamera #${first.cameraId}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(_fmt(first.timestamp),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              if (!isSingle) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${group.length}',
                    style: TextStyle(
                        color: Colors.blueGrey.shade800,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
