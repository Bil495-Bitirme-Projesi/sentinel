import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/services/camera_service.dart';
import 'package:sentinel/models/camera.dart'; // StreamStatus'un buradan geldiğinden emin ol
import 'package:sentinel/core/navigation/app_router.dart';

class CamerasListScreen extends StatefulWidget {
  const CamerasListScreen({super.key});

  @override
  State<CamerasListScreen> createState() => _CamerasListScreenState();
}

class _CamerasListScreenState extends State<CamerasListScreen> {
  List<Camera> _cameras = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCameras();
  }

  Future<void> _fetchCameras() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final cameras = await CameraService.instance.getAllCameras();
      if (mounted) setState(() { _cameras = cameras; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _deleteCamera(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kamerayı Sil'),
        content: const Text('Bu kamera kalıcı olarak silinecek. Onaylıyor musunuz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil')
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await CameraService.instance.deleteCamera(id);
        _fetchCameras();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  // YENİ: Relatif zaman hesaplayıcı (Örn: "2 dakika önce")
  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} gün önce';
    if (diff.inHours > 0) return '${diff.inHours} saat önce';
    if (diff.inMinutes > 0) return '${diff.inMinutes} dakika önce';
    return 'Az önce';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera Yönetimi'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Yenile', onPressed: _fetchCameras),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.adminCameraNew),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Yeni Ekle'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text('Hata: $_errorMessage'));
    if (_cameras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Sisteme kayıtlı kamera bulunmuyor', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCameras,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
        itemCount: _cameras.length,
        itemBuilder: (context, index) {
          final cam = _cameras[index];

          // YENİ: Durum (Badge) ve İkonları belirleme
          Color statusColor;
          IconData statusIcon;

          switch (cam.streamStatus) {
            case StreamStatus.online:
              statusColor = Colors.green;
              statusIcon = Icons.circle;
              break;
            case StreamStatus.offline:
              statusColor = Colors.red;
              statusIcon = Icons.circle;
              break;
            case StreamStatus.unknown:
            default:
              statusColor = Colors.grey;
              statusIcon = Icons.circle_outlined;
              break;
          }

          return Card(
            child: ListTile(
              // İkonun yanına küçük durum noktasını (Badge) ekliyoruz
              leading: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.videocam, color: Colors.blue),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 14),
                  ),
                ],
              ),
              title: Text(cam.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cam.rtspUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
                  // Eğer Heartbeat bilgisi varsa alt satırda göster
                  if (cam.lastHeartbeatAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Son bağlantı: ${_timeAgo(cam.lastHeartbeatAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    tooltip: 'Düzenle',
                    onPressed: () => context.go(AppRoutes.adminCameraEdit(cam.id.toString())),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Sil',
                    onPressed: () => _deleteCamera(cam.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}