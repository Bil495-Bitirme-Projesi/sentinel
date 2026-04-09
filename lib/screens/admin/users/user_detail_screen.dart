import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/services/user_service.dart';
import 'package:sentinel/services/camera_service.dart';
import 'package:sentinel/services/user_camera_access_service.dart';
import 'package:sentinel/models/user.dart';
import 'package:sentinel/models/user_camera_access.dart';
import 'package:sentinel/core/navigation/app_router.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  User? _user;
  List<UserCameraAccess> _assignedCameras = [];
  bool _isLoading = true;

  // Kullanıcının operatör olup olmadığını güvenli bir şekilde kontrol eden fonksiyon
  bool get _isOperator {
    if (_user == null) return false;
    final roleStr = _user!.role.toString().toUpperCase();
    // İçinde ADMIN geçmiyorsa veya OPERATOR geçiyorsa o bir operatördür
    return roleStr.contains('OPERATOR') || !roleStr.contains('ADMIN');
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      _user = await UserService.instance.getUserById(widget.userId);

      // Güvenli kontrolü kullanıyoruz
      if (_isOperator) {
        _assignedCameras = await UserCameraAccessService.instance.getUserAccessList(widget.userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcıyı Sil'),
        content: const Text('Bu kullanıcı kalıcı olarak silinecek. Onaylıyor musunuz?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await UserService.instance.deleteUser(widget.userId);
        if (mounted) context.go(AppRoutes.adminUsers);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Silinemedi: $e')));
      }
    }
  }

  Future<void> _showAddCameraBottomSheet() async {
    try {
      final allCameras = await CameraService.instance.getAllCameras();
      if (!mounted) return;

      // ÇÖZÜM BURADA: Halihazırda atanmış olan kameraları listeden filtreliyoruz
      final availableCameras = allCameras.where((camera) {
        return !_assignedCameras.any((assigned) => assigned.cameraId == camera.id);
      }).toList();

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Kamera Erişimi Tanımla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              Expanded(
                // Artık allCameras yerine filtrelenmiş availableCameras listesini kullanıyoruz
                child: availableCameras.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Eklenebilecek yeni bir kamera bulunmuyor.', style: TextStyle(fontSize: 16)),
                      )
                    )
                  : ListView.builder(
                  itemCount: availableCameras.length,
                  itemBuilder: (context, index) {
                    final camera = availableCameras[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.videocam, size: 20, color: Colors.blue)
                      ),
                      title: Text(camera.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(camera.rtspUrl, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.add_circle_outline, color: Colors.blue),
                      onTap: () async {
                        Navigator.pop(context); // Menüyü kapat
                        try {
                          await UserCameraAccessService.instance.grantAccess(widget.userId, camera.id);
                          _fetchData(); // Listeyi yenile
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Atama başarısız: $e')));
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kamera listesi alınamadı: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null) return const Scaffold(body: Center(child: Text('Kullanıcı bulunamadı.')));

    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.name),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: _deleteUser),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kullanıcı Bilgi Kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: _user!.enabled ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                      child: Icon(Icons.person, size: 35, color: _user!.enabled ? Colors.deepPurple : Colors.grey)
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_user!.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          // Rolü yazdırıyoruz
                          Text('Rol: ${_user!.role.toString().split('.').last.toUpperCase()}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(_user!.enabled ? "Aktif" : "Pasif", style: TextStyle(color: _user!.enabled ? Colors.green.shade700 : Colors.grey.shade700, fontWeight: FontWeight.bold)),
                      backgroundColor: _user!.enabled ? Colors.green.shade50 : Colors.grey.shade200,
                      side: BorderSide.none,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sadece OPERATOR ise Kamera Erişim Listesini Göster
            if (_isOperator) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Atanmış Kameralar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  FilledButton.icon(
                    onPressed: _showAddCameraBottomSheet,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Erişim Ver'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _assignedCameras.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_off, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Bu operatöre henüz kamera atanmamış.', style: TextStyle(color: Colors.grey.shade600))
                          ],
                        )
                      )
                    : ListView.builder(
                        itemCount: _assignedCameras.length,
                        itemBuilder: (context, index) {
                          final access = _assignedCameras[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.videocam, color: Colors.blue),
                              ),
                              title: Text(access.cameraName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                tooltip: 'Erişimi Kaldır',
                                onPressed: () async {
                                  try {
                                    await UserCameraAccessService.instance.revokeAccess(widget.userId, access.cameraId);
                                    _fetchData();
                                  } catch (e) {
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}