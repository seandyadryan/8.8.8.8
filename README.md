# Nexus Proxy

Flutter client bergaya WARP/1.1.1.1 dengan arsitektur MVC. Versi awal ini
membuka SSH dynamic forwarding dan menyediakan SOCKS5 proxy lokal.

## Stack

- Flutter 3.41.2 via FVM
- Dart 3.11.0
- `dartssh2` untuk SSH tunnel dan SOCKS5 dynamic forwarding

## Arsitektur

```text
lib/
  main.dart
  src/
    app.dart
    controllers/
      proxy_controller.dart
    models/
      connection_state_model.dart
      proxy_config.dart
      proxy_session.dart
    services/
      ssh_dynamic_proxy_service.dart
    views/
      home_view.dart
```

Model menyimpan konfigurasi dan status sesi, controller mengatur alur connect
dan disconnect, service menangani koneksi SSH, sedangkan view hanya mengurus UI.

## Server Default

- Host: `124.158.152.249`
- SSH Port: `22`
- Username: `nexus`
- SOCKS5 lokal: `127.0.0.1:1080`

Password tidak disimpan di source code. Masukkan password lewat field aplikasi
saat ingin connect.

## Menjalankan

```powershell
& 'C:\Users\seandy.nugraha\fvm\versions\3.41.2\bin\flutter.bat' pub get
& 'C:\Users\seandy.nugraha\fvm\versions\3.41.2\bin\flutter.bat' run -d windows
```

Setelah status menjadi Connected, arahkan browser atau aplikasi yang mendukung
SOCKS5 ke `127.0.0.1:1080`.

## Catatan

Ini adalah proxy SOCKS5 melalui SSH, bukan VPN kernel-level seperti Cloudflare
WARP. Untuk membuat semua trafik perangkat otomatis lewat tunnel, tahap
berikutnya perlu modul native per platform, misalnya Android `VpnService`, iOS
Network Extension, dan integrasi proxy sistem untuk desktop.
