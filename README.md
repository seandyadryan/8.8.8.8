# Nexus WireGuard

Flutter client bergaya WARP/1.1.1.1 dengan arsitektur MVC. Versi ini memakai
WireGuard supaya trafik perangkat bisa diarahkan lewat tunnel VPN, bukan hanya
SOCKS5 proxy.

## Stack

- Flutter 3.41.2 via FVM
- Dart 3.11.0
- `wireguard_flutter_plus` untuk tunnel WireGuard lintas platform

## Arsitektur

```text
lib/
  main.dart
  src/
    app.dart
    controllers/
      vpn_controller.dart
    models/
      connection_state_model.dart
      wireguard_config.dart
      vpn_session.dart
      traffic_stats.dart
    services/
      wireguard_vpn_service.dart
    views/
      home_view.dart
```

Model menyimpan konfigurasi dan status sesi, controller mengatur alur connect
dan disconnect, service memanggil engine WireGuard, sedangkan view hanya
mengurus UI.

## Server Default

- Host: `124.158.152.249`
- UDP Port: `51820`
- Client Address: `10.8.0.2/32`
- Allowed IPs: `0.0.0.0/0, ::/0`
- DNS: `1.1.1.1, 8.8.8.8`

Private key client dan public key server tidak disimpan di source code.
Masukkan key WireGuard lewat field aplikasi saat ingin connect.

## Menjalankan

```powershell
& 'C:\Users\seandy.nugraha\fvm\versions\3.41.2\bin\flutter.bat' pub get
& 'C:\Users\seandy.nugraha\fvm\versions\3.41.2\bin\flutter.bat' run -d windows
```

Catatan Windows: plugin native membutuhkan Developer Mode untuk symlink Flutter
dan aplikasi harus dijalankan sebagai Administrator agar bisa membuat tunnel.

## Catatan

Server Ubuntu tetap harus dipasang WireGuard, dibuatkan keypair server/client,
dan firewall harus membuka port UDP WireGuard. Untuk iOS/macOS, Apple Network
Extension dan App Group perlu dikonfigurasi di Xcode sebelum tunnel bisa aktif.
