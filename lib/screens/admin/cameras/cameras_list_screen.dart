import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/services/camera_service.dart';
import 'package:sentinel/models/camera.dart';
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

  GoRouter? _router;
  String? _previousLocation;

  @override
  void initState() {
    super.initState();
    _fetchCameras();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (_router != router) {
      _router?.routerDelegate.removeListener(_onRouteChange);
      _router = router;
      _router!.routerDelegate.addListener(_onRouteChange);
    }
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
        _previousLocation != AppRoutes.adminCameras &&
        _previousLocation!.startsWith(AppRoutes.adminCameras);
    if (location == AppRoutes.adminCameras && wasInSubRoute) {
      _fetchCameras();
    }
    _previousLocation = location;
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
        _fetchCameras(); // Listeyi güncelle
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
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
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.videocam, color: Colors.blue),
              ),
              title: Text(cam.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(cam.rtspUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
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