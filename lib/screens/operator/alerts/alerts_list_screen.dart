import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/core/navigation/app_router.dart';
import 'package:sentinel/models/alert_summary.dart';
import 'package:sentinel/screens/operator/alerts/alert_group_screen.dart';
import 'package:sentinel/services/alert_service.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  List<AlertSummary> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;

  GoRouter? _router;
  String? _previousLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= GoRouter.of(context)
      ..routerDelegate.addListener(_onRouteChange);
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouteChange);
    super.dispose();
  }

  void _onRouteChange() {
    if (!mounted) return;
    final location =
        _router!.routerDelegate.currentConfiguration.uri.toString();
    final wasInSubRoute = _previousLocation != null &&
        _previousLocation != AppRoutes.opAlerts &&
        _previousLocation!.startsWith(AppRoutes.opAlerts);
    if (location == AppRoutes.opAlerts && wasInSubRoute) {
      _fetchAlerts();
    }
    _previousLocation = location;
  }

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
      final alerts = await AlertService.instance.getAlerts(status: 'UNSEEN');
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

  @override
  Widget build(BuildContext context) {
    final groups = _groupAlerts(_alerts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertler'),
        actions: [
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
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(_errorMessage!, textAlign: TextAlign.center),
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
                              child: Center(child: Text('Yeni alert yok.')),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: groups.length,
                          itemBuilder: (context, index) => _AlertGroupCard(
                            group: groups[index],
                            onRefresh: _fetchAlerts,
                            onNavigateSingle: (id) =>
                                context.go(AppRoutes.opAlertDetail(id.toString())),
                          ),
                        ),
                ),
    );
  }
}

class _AlertGroupCard extends StatelessWidget {
  const _AlertGroupCard({
    required this.group,
    required this.onRefresh,
    required this.onNavigateSingle,
  });

  final List<AlertSummary> group;
  final VoidCallback onRefresh;
  final void Function(int alertId) onNavigateSingle;

  String _fmt(DateTime dt) {
    final d = dt.toLocal();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.day)}.${p(d.month)}.${d.year} ${p(d.hour)}:${p(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final first = group.first;
    final isSingle = group.length == 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isSingle) {
            onNavigateSingle(first.alertId);
          } else {
            Navigator.of(context)
                .push<bool>(MaterialPageRoute(
                  builder: (_) => AlertGroupScreen(
                    group: group,
                    onAcknowledged: onRefresh,
                  ),
                ))
                .then((refreshed) {
              if (refreshed == true) onRefresh();
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.warning_amber_rounded,
                    color: Colors.orange.shade700),
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
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${group.length}',
                    style: TextStyle(
                        color: Colors.red.shade800,
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
