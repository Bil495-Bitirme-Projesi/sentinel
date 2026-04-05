## Gereksinimler

- Flutter SDK (stable channel)
- Android emülatör
- CMS ve MinIO'nun çalışır durumda olması

---

## Çalıştırma

### Terminalde

Geliştirme ortamında çalıştırmak için:

```bash
flutter run --dart-define-from-file=config/dev.json
```

### Android Studio'dan (önerilen)

Repo kökündeki `.run/run.run.xml` dosyası sayesinde Android Studio, `run` adlı hazır bir run configuration'ı otomatik olarak tanır.

**IDE üst araç çubuğundan** `run` konfigürasyonunu seçip ▶ butonuna basmak yeterlidir; `--dart-define-from-file=config/dev.json` argümanı otomatik iletilir.

### APK Alma

| Ortam | Komut |
|---|---|
| Development | `flutter build apk --dart-define-from-file=config/dev.json` |
| Production  | `flutter build apk --dart-define-from-file=config/prod.json` |

Oluşturulan APK `build/app/outputs/flutter-apk/` altına düşer.

### Ortam değişkenleri

| Değişken | Açıklama | Örnek                        |
|---|---|------------------------------|
| `API_BASE_URL` | CMS backend base URL (trailing slash olmadan) | `https://192.168.137.1/api`  |
| `MINIO_BASE_URL` | MinIO servis base URL (trailing slash olmadan) | `https://192.168.137.1:9443` |
| `APP_ENV` | Ortam adı: `development` \| `production` | `development`                |

Değerler `config/dev.json` ve `config/prod.json` dosyalarında tanımlıdır.

---

## CMS API Dokümantasyonu

CMS'nin OpenAPI dokümantasyonu hem **Swagger UI** arayüzü üzerinden hem de **JSON** olarak görüntülenebilir.

### Swagger UI

CMS'e erişilen adrese `/swagger-ui.html` yolu eklenerek tarayıcıdan açılabilir:

```text
https://<CMS_HOST>/swagger-ui.html
```

**Örnek:** CMS'e `192.168.137.1` IP adresi üzerinden erişiliyorsa:

```text
https://192.168.137.1/swagger-ui.html
```

### OpenAPI JSON

Tüm API dokümantasyonuna makine tarafından okunabilir **JSON** formatında da `/v3/api-docs` yolu üzerinden erişilebilir:

```text
https://<CMS_HOST>/v3/api-docs
```

**Örnek:**

```text
https://192.168.137.1/v3/api-docs
```

Bu çıktı, özellikle yapay zeka destekli geliştirme araçlarıyla çalışırken faydalıdır. Araç, bu endpoint'e istek atarak OpenAPI şemasını okuyabilir; endpoint'leri, request/response modellerini ve parametre yapılarını doğrudan dokümantasyondan anlayıp geliştirme sürecinde bundan yararlanabilir.

## Proje Yapısı

```
lib/
├── config/
│   └── app_config.dart        # Ortam değişkenleri (API_BASE_URL, MINIO_BASE_URL, APP_ENV)
├── core/
│   ├── auth/                  # Token yönetimi
│   ├── network/
│   │   ├── cms_client.dart    # CMS REST API Dio singleton (AuthInterceptor dahil)
│   │   ├── minio_client.dart  # MinIO Dio singleton (presigned URL auth, uzun timeout)
│   │   ├── auth_interceptor.dart
│   │   ├── dio_exception_ext.dart
│   │   └── http_error.dart
│   └── ...
├── models/                    # JSON model sınıfları
├── services/                  # API çağrılarını kapsayan servis sınıfları
└── main.dart
```

---

## Kod Üretimi — dart_mappable

Projede model sınıfları ([`User`](lib/models/user.dart), [`ApiError`](lib/models/api_error.dart), vb.) `dart_mappable` paketi ile işaretlenmiştir (`@MappableClass()`). Bu paket, `fromJson` / `toJson` / `copyWith` gibi boilerplate kodunu elle yazmak yerine otomatik üretir; üretilen dosyalar `*.mapper.dart` uzantısı taşır (ör. `user.mapper.dart`).

Bu dosyalar **kaynak koda dahil edilir** (`.gitignore`'da değildir), ancak bir model değiştiğinde yeniden üretilmesi gerekir.

### Üretimi Yenilemek

**Terminalde:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Android Studio'dan (önerilen):** `.run/Mappable Build.run.xml` sayesinde IDE'de `Mappable Build` konfigürasyonu hazır gelir. Üst araç çubuğundan `Mappable Build` seçip ▶ ile çalıştırmak yeterlidir.

---

## TLS / Self-Signed Sertifika

`assets/certs/server.crt` dosyasına yerleştirilen self-signed sertifika, uygulama başlangıcında hem `CmsClient` hem de `MinioClient` tarafından Dart TLS katmanına tanıtılır.

MinIO farklı bir sertifika kullanıyorsa `minio_client.dart` içindeki `createHttpClient` bloğunu ilgili `.crt` dosyasına yönlendirin.
