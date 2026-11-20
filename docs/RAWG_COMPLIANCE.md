# RAWG, rating usia, dan keamanan

Ditinjau 18 November 2026. Dokumen ini bukan pernyataan bahwa seluruh persyaratan hukum dan lisensi telah terpenuhi.

## Sumber dan atribusi

Katalog dan detail menggunakan RAWG API: `GET https://api.rawg.io/api/games` untuk daftar, pencarian dan pagination, serta `GET https://api.rawg.io/api/games/{id}` untuk detail. `background_image` dipetakan ke `GameModel.imageUrl` dan ditampilkan menggunakan `CachedNetworkImage`; URL tersebut berasal dari respons pihak ketiga dan hak atas setiap gambar belum diverifikasi secara individual. Aplikasi juga memiliki service FreeToGame terpisah.

Data RAWG terlihat pada katalog Games, detail game, Library, Daily Quest, serta Session History (termasuk nama game yang tersimpan). `lib/widgets/rawg_attribution.dart` memberikan teks sumber dan tautan `https://rawg.io/`: widget tersedia di samping judul Games dan sebagai footer Library, Quest, Session History, serta di bagian akhir konten detail. Pembukaan browser eksternal bergantung pada dukungan perangkat.

[Halaman API RAWG](https://rawg.io/apidocs) dan [ketentuan API](https://rawg.io/tos_api) menyatakan perlunya atribusi sumber dan hyperlink aktif pada setiap halaman yang memakai data RAWG. RAWG menyatakan tidak memiliki gambar/data API dan menjelaskan adanya lisensi atas unggahan, tetapi hak setiap pemilik pihak ketiga, ruang lingkup izin per gambar, serta kesesuaian penggunaan ini belum diverifikasi secara independen. Jangan menganggap seluruh gambar bebas hak cipta. Tidak menggunakan logo RAWG. Ketentuan paket dan batas komersial pada halaman API dan Terms tidak sepenuhnya konsisten; konfirmasi langsung dengan RAWG untuk rencana penggunaan dan distribusi. Persyaratan lain dan kelayakan keseluruhan masih perlu ditinjau.

## Rating usia

Field `esrb_rating.name` dibaca jika tersedia, dipisahkan dari skor RAWG, ditampilkan pada detail, dan disimpan dalam SQLite versi 2. Record versi 1 dipertahankan; rating lama yang belum tersedia tetap null. Teks `Age rating unavailable` berarti data tidak tersedia, bukan aman untuk semua umur atau keputusan resmi bahwa game tidak dinilai. Metadata dapat tidak lengkap, usang, atau berbeda menurut platform/wilayah. Gambar dan cover dari katalog dapat memuat kekerasan atau tema dewasa, termasuk saat rating tidak ada. Tidak ada filter otomatis; label informasi digunakan. Rating game bukan rating aplikasi Checkpoint; klasifikasi aplikasi harus melalui proses penilaian yang relevan. Lihat [panduan ESRB](https://www.esrb.org/ratings-guide/) dan [proses penilaian ESRB](https://www.esrb.org/ratings/ratings-process/).

## Kunci API

Dukungan `RAWG_API_KEY` melalui `--dart-define` tersedia untuk debug dan release. Hindari menuliskan nilai ke Git, log, atau shell history; gunakan file konfigurasi lokal di luar repository dengan `--dart-define-from-file` jika sesuai. Nilai define tetap dapat diekstrak dari aplikasi yang dikompilasi: gunakan backend proxy dengan kontrol akses dan pembatasan jika kunci benar-benar harus dirahasiakan.

Kunci lama sudah terpapar dan masih dipertahankan sementara sesuai instruksi pemilik karena pengganti belum tersedia dan tervalidasi. Pemilik perlu membuat/merotasi kunci secara manual di dashboard RAWG, mengonfigurasi dan memvalidasi penggantinya secara lokal, kemudian menghapus fallback lama dari source serta menonaktifkan kunci lama. Jangan membagikan nilainya di chat. Riwayat Git, log lama, artefak, dan APK terdahulu juga dapat menyimpan kunci; rotasi tetap diperlukan setelah kode dibersihkan. API live dengan kunci pengganti belum diverifikasi.

## Keystore

Keystore di luar repository; `android/key.properties` diabaikan Git. Jangan menyimpan password dalam dokumen, command line, atau chat. Jika penggantian password diperlukan, lakukan sendiri secara lokal: buat cadangan aman terlebih dahulu, catat fingerprint sertifikat secara privat, lalu gunakan prompt interaktif `keytool -storepasswd -keystore /home/alathereonn/upload-keystore.jks -storetype JKS` dan bila perlu `keytool -keypasswd -alias upload -keystore /home/alathereonn/upload-keystore.jks -storetype JKS`. Jangan memasukkan password sebagai argumen. Verifikasi fingerprint sertifikat tetap sama, perbarui konfigurasi signing lokal secara aman dan uji akses sebelum menggunakan keystore. Langkah tersebut hanya mengubah password, bukan sertifikat; jangan membuat kunci baru. Tidak ada perubahan password yang dilakukan. Rujukan: [dokumentasi keytool Oracle](https://docs.oracle.com/en/java/javase/15/docs/specs/man/keytool.html).
