# Audit Lisensi Aset dan Gambar — Checkpoint

## 1. Cover Game

- **Sumber:** RAWG Video Games Database API.
- **Endpoint:** `https://api.rawg.io/api/games`.
- **Field:** `background_image`.
- **Penggunaan:** Cover game pada katalog dan halaman detail.
- **Dasar penggunaan:** RAWG menyediakan paket untuk proyek pribadi/nonkomersial dengan persyaratan atribusi dan hyperlink aktif.
- **Atribusi:** “Game data by RAWG”, dengan tautan ke [RAWG](https://rawg.io/).
- **Referensi:** [Dokumentasi API RAWG](https://rawg.io/apidocs) dan [ketentuan API RAWG](https://rawg.io/tos_api).

Ilustrasi game dapat dimiliki developer, publisher, atau pemegang hak terkait. Penggunaan melalui RAWG API tidak membuktikan bahwa RAWG memiliki setiap ilustrasi. Izin individual untuk cover pihak ketiga belum diverifikasi.

## 2. Logo Aplikasi

| Komponen | Informasi |
|---|---|
| File | `assets/logo.png` |
| Aset | Checkpoint Application Logo |
| Pembuat | Project Developer |
| Kepemilikan | Karya asli milik developer |
| Lisensi | Proprietary / All Rights Reserved |
| Penggunaan | Ikon launcher aplikasi Android |
| Status | **VERIFIED — Original Asset**, berdasarkan pernyataan pemilik proyek |

Informasi pembuat, kepemilikan, lisensi, dan status di atas berasal dari pernyataan pengguna; bukti asal atau dokumen kepemilikan belum diperiksa secara independen. Konfigurasi `flutter_launcher_icons` menunjuk ke aset tersebut.

## 3. Kesesuaian Usia

Checkpoint adalah aplikasi pencatat backlog game, bukan aplikasi untuk memainkan game. Informasi ESRB ditampilkan jika tersedia dari RAWG API. Katalog dapat menampilkan game untuk pengguna dewasa dan belum memiliki filter konten berdasarkan rating usia. Rating game tidak sama dengan rating usia aplikasi Checkpoint.

## 4. Kesimpulan Audit

- Sumber cover game telah diidentifikasi sebagai RAWG API dan atribusi RAWG telah diimplementasikan pada UI.
- Pengujian hyperlink pada perangkat masih perlu didokumentasikan.
- Izin individual atas cover pihak ketiga belum diverifikasi.
- Logo dinyatakan sebagai karya asli milik developer berdasarkan informasi pemilik proyek; bukti asal belum diperiksa secara independen.
- Distribusi publik atau komersial memerlukan pemeriksaan hak penggunaan tambahan.
