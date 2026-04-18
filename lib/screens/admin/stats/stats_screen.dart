import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sentinel/core/network/cms_client.dart';

// --- Modeller ---
class HealthComponent {
  final String status;
  final Map<String, dynamic> details;

  HealthComponent({required this.status, required this.details});

  factory HealthComponent.fromJson(Map<String, dynamic> json) {
    return HealthComponent(
      status: json['status']?.toString() ?? 'UNKNOWN',
      // Actuator bazen 'details' döner, bazen de doğrudan içeriye gömer
      details: json['details'] is Map
          ? Map<String, dynamic>.from(json['details'])
          : {},
    );
  }
}

class SystemHealth {
  final String status;
  final Map<String, HealthComponent> components;

  SystemHealth({required this.status, required this.components});

  factory SystemHealth.fromJson(Map<String, dynamic> json) {
    final comps = <String, HealthComponent>{};

    // Spring Boot Actuator v3+ genellikle "components" döner,
    // ancak bazı konfigürasyonlarda veya yetki eksikliklerinde "details" içinde dönebilir.
    Map<String, dynamic>? rawComponents;

    if (json.containsKey('components') && json['components'] is Map) {
      rawComponents = json['components'];
    } else if (json.containsKey('details') && json['details'] is Map) {
      rawComponents = json['details'];
    }

    if (rawComponents != null) {
      rawComponents.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          comps[key] = HealthComponent.fromJson(value);
        }
      });
    }

    return SystemHealth(
      status: json['status']?.toString() ?? 'UNKNOWN',
      components: comps,
    );
  }
}

// --- Ekran ---
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  SystemHealth? _healthData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ÇÖZÜM: Dio'nun 500 veya 503 gibi durumlarda Exception fırlatmasını engelliyoruz.
      // Actuator bir bileşen DOWN olduğunda hata kodu dönse de bize JSON'ı verecek.
      final response = await CmsClient.instance.get(
        '/actuator/health',
        options: Options(
          validateStatus: (status) => true, // Tüm HTTP kodlarını başarılı say ve veriyi al
        ),
      );

      if (mounted) {
        setState(() {
          // Eğer dönen veri beklendiği gibi bir JSON Map ise:
          if (response.data is Map<String, dynamic> && response.data['status'] != null) {
            _healthData = SystemHealth.fromJson(response.data);
          } else {
            // Actuator JSON'u yerine Spring'in varsayılan beyaz hata sayfası falan dönerse
            _errorMessage = 'Sunucudan beklenmeyen bir yanıt döndü (HTTP ${response.statusCode})';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      // Sadece internet kesilmesi, timeout gibi gerçek bağlantı hataları buraya düşecek
      if (mounted) {
        setState(() {
          _errorMessage = 'Sistem durumu alınamadı: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Renk belirleme
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'UP':
        return Colors.green;
      case 'UNKNOWN':
        return Colors.amber.shade700;
      case 'DOWN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'UP':
        return Icons.check_circle;
      case 'UNKNOWN':
        return Icons.help_outline;
      case 'DOWN':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  // Sadece db, minio ve aisWebSocket durumlarına bakarak genel afiş durumunu hesapla
  bool _isAllOperational(SystemHealth health) {
    final db = health.components['db']?.status == 'UP';
    final minio = health.components['minio']?.status == 'UP';
    final ais = health.components['aisWebSocket']?.status == 'UP';
    return db && minio && ais;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Durumu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _fetchHealthData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _healthData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _healthData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchHealthData,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_healthData == null) {
      return const Center(child: Text('Veri bulunamadı.'));
    }

    final isAllUp = _isAllOperational(_healthData!);
    final db = _healthData!.components['db'];
    final minio = _healthData!.components['minio'];
    final ais = _healthData!.components['aisWebSocket'];

    return RefreshIndicator(
      onRefresh: _fetchHealthData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // ÜST AFİŞ (BANNER)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAllUp ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isAllUp ? Colors.green.shade200 : Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  isAllUp ? Icons.verified_user : Icons.warning_amber_rounded,
                  color: isAllUp ? Colors.green.shade700 : Colors.red.shade700,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isAllUp ? 'Tüm Sistemler Aktif' : 'Sistemde Sorunlar Tespit Edildi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isAllUp ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Bileşenler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (db != null) _buildComponentCard(
            title: 'Veritabanı (PostgreSQL)',
            status: db.status,
            subtitle: db.status.toUpperCase() == 'UP' ? 'Bağlantı sağlıklı' : 'Bağlantı kurulamıyor',
          ),

          if (minio != null) _buildComponentCard(
            title: 'Depolama (MinIO)',
            status: minio.status,
            subtitle: minio.details['endpoint'] != null
                ? 'Endpoint: ${minio.details['endpoint']}'
                : (minio.status.toUpperCase() == 'UP' ? 'Bağlantı sağlıklı' : 'Ulaşılamıyor veya bucket eksik'),
          ),

          if (ais != null) _buildComponentCard(
            title: 'Yapay Zeka Alt Sistemi (AIS)',
            status: ais.status,
            subtitle: ais.details['silenceSeconds'] != null
                ? 'Son mesaj: ${ais.details['silenceSeconds']} saniye önce'
                : (ais.status.toUpperCase() == 'UP' ? 'Bağlı ve çalışıyor' : 'Bağlantı yok'),
          ),

          // Eğer Actuator JSON yapısı tamamen farklı geldiyse boş kalmasın diye küçük bir kontrol:
          // Eğer Actuator JSON yapısı tamamen farklı geldiyse boş kalmasın diye kontrol:
                    if (db == null && minio == null && ais == null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Backend detay bileşenlerini göndermedi. Büyük ihtimalle Actuator "show-details" ayarı kapalı.',
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('Backend\'den gelen Ham Durum:'),
                            Text(
                              _healthData?.status ?? 'Bilinmiyor',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Çözüm: Backend application.properties dosyasına şu satır eklenmeli:\nmanagement.endpoint.health.show-details=always',
                              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      )
        ],
      ),
    );
  }

  Widget _buildComponentCard({required String title, required String status, required String subtitle}) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}