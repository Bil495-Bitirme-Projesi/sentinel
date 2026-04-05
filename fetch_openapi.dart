/// Çalıştırma:
///   dart run fetch_openapi.dart
///
/// Sonuç: proje kökünde openapi.json dosyası oluşur.

import 'dart:convert';
import 'dart:io';

void main() async {
  const url = 'https://192.168.137.1/v3/api-docs';
  const certPath = 'assets/certs/server.crt';
  const outputPath = 'openapi.json';

  final certBytes = File(certPath).readAsBytesSync();

  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => false;

  // Self-signed sertifikayı Dart TLS context'ine tanıt
  final ctx = SecurityContext(withTrustedRoots: true);
  ctx.setTrustedCertificatesBytes(certBytes);

  final secureClient = HttpClient(context: ctx)
    ..badCertificateCallback = (cert, host, port) {
      // Sadece bilinen host'a izin ver
      return host == '192.168.137.1';
    };

  try {
    stdout.writeln('Bağlanıyor: $url');
    final request = await secureClient.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != 200) {
      stderr.writeln('HTTP ${response.statusCode}');
      exit(1);
    }

    final body = await response.transform(utf8.decoder).join();

    // Pretty-print JSON
    final jsonObj = jsonDecode(body);
    final pretty = const JsonEncoder.withIndent('  ').convert(jsonObj);

    File(outputPath).writeAsStringSync(pretty);
    stdout.writeln('Kaydedildi: $outputPath (${pretty.length} karakter)');
  } catch (e) {
    stderr.writeln('Hata: $e');
    exit(1);
  } finally {
    secureClient.close();
  }
}

