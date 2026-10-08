# Design Direction — Enterprise ERP untuk Flutter Web

**Status:** rancangan desain produk dan UI/UX, bukan implementasi aplikasi  
**Target:** perusahaan menengah-besar, tim operasional, finance, procurement, sales, dan pimpinan  
**Prinsip utama:** serius untuk pengambilan keputusan, cepat untuk pekerjaan rutin, dan mudah dipelajari tanpa mengorbankan kedalaman fitur.

## 1. Arah visual

**Enterprise clarity, not enterprise clutter.** Tampilan memadukan pendekatan SAP Fiori yang berbasis peran, konsisten, adaptif, dan menyederhanakan kompleksitas [1](https://experience.sap.com/fiori-design-web/explore_category/foundation/) dengan kualitas pengalaman Oracle Redwood yang modern, accessible, konsisten, dan dapat dikembangkan untuk kebutuhan enterprise [2](https://docs.oracle.com/en/cloud/saas/readiness/redwood-adoption/). Ini inspirasi prinsip, **bukan menyalin identitas, logo, atau komponen proprietary** mereka.

- **Karakter:** presisi, tenang, premium, cepat dipindai; bukan dashboard penuh kartu dekoratif.
- **Visual:** latar netral dingin, teks gelap berkontras tinggi, biru korporat untuk aksi, teal untuk sinyal positif, amber untuk perhatian, merah untuk risiko.
- **Bentuk:** radius 6–8 px; garis pemisah tipis; elevasi dipakai hanya untuk menu, dialog, dan panel mengambang.
- **Tipografi:** IBM Plex Sans untuk UI dan angka; berat 400/500/600/700. Aktifkan angka tabular pada tabel dan KPI.
- **Ikon:** satu keluarga ikon outline yang konsisten; ikon tidak pernah menjadi satu-satunya penanda status.
- **Branding klien:** logo dan aksen dapat diganti per tenant, tetapi warna status, kontras, dan hierarki tetap konsisten.

## 2. Struktur produk

### Shell aplikasi

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ Logo / tenant  │ Pencarian global (Ctrl/Cmd+K) │ Bantuan │ Notif │ Profil │
├─────────────────┬───────────────────────────────────────────────────────────┤
│ Navigasi utama  │ Breadcrumb / konteks perusahaan > unit > periode         │
│                │ Judul halaman                            Aksi utama      │
│ Beranda        │───────────────────────────────────────────────────────────│
│ Finance        │ Konten: ringkasan / tabel / formulir / analitik           │
│ Procurement    │                                                           │
│ Sales          │                                                           │
│ Inventory      │                                                           │
│ Reports        │                                                           │
│ Administration │                                                           │
└─────────────────┴───────────────────────────────────────────────────────────┘
```

- **Navigasi primer** mengikuti domain kerja; submenu hanya muncul saat domain aktif. Favorit dan halaman terakhir dapat diakses melalui pencarian global.
- **Konteks tenant, unit, dan periode** selalu terlihat jika memengaruhi data. Ganti konteks tanpa membuat pengguna kehilangan draft yang belum disimpan.
- **Halaman detail** memakai pola judul + status + metadata penting + tab (Ringkasan, Aktivitas, Dokumen, Riwayat) + aksi kontekstual.
- **Aksi berisiko** seperti approve, reject, void, atau posting selalu memperlihatkan objek, dampak, dan konfirmasi yang sesuai.

### Beranda / “hero” aplikasi

Hero di sini adalah **area orientasi kerja setelah login**, bukan banner pemasaran besar. Gabungkan kejelasan launchpad SAP dengan sentuhan editorial dan ruang napas Oracle: judul kontekstual seperti **“Selamat pagi, Dimas”**, nama entitas dan periode, ringkasan prioritas, lalu satu aksi yang paling relevan. Jangan pakai foto stok, ilustrasi 3D, gradien dekoratif, atau angka fiktif yang terlihat seperti data nyata.

```text
[Selamat pagi, Dimas]       [Perusahaan ▾] [Oktober 2026 ▾]
3 hal perlu perhatian       [Lihat pekerjaan saya →]
────────────────────────────────────────────────────────────
[Perlu persetujuan] [Jatuh tempo] [Anomali] [Aktivitas terbaru]
────────────────────────────────────────────────────────────
[Daftar tugas prioritas]                 [Ringkasan modul sesuai peran]
```

- Hero maksimal ±160 px di desktop agar data kerja terlihat pada viewport pertama.
- Isi hero berubah menurut **peran dan konteks**, bukan pesan promosi generik.
- Jika ERP juga memiliki **situs publik**, hero situs terpisah: headline literal tentang ERP, screenshot produk yang nyata, satu CTA utama “Jadwalkan demo”, dan satu tautan sekunder “Lihat produk”. Hindari menggabungkan marketing hero dengan beranda aplikasi.

## 3. Dua mode pengalaman

| Aspek | Lite Mode | Pro Mode |
|---|---|---|
| Pengguna utama | Pengguna baru, pimpinan, approver sesekali | Power user, analis, finance/ops harian |
| Navigasi | Menu ringkas, tugas dan modul favorit | Sidebar lengkap, recent pages, tab kerja |
| Beranda | “Apa yang harus saya lakukan?” dan KPI inti | Workbench dengan banyak panel dan antrian |
| Tabel | Kolom esensial, filter sederhana | Kolom dapat diatur, filter lanjutan, sort multi-kolom |
| Form | Langkah terarah, progressive disclosure | Form padat, input cepat, shortcut, bulk edit bila aman |
| Analitik | Ringkasan dengan penjelasan | Drill-down, perbandingan periode, ekspor sesuai hak akses |
| Kepadatan | Comfortable | Compact, tetapi tetap terbaca |

**Aturan transisi:** Lite dan Pro adalah **preferensi tampilan, bukan hak akses**. Data, validasi, izin, audit trail, dan hasil transaksi tetap sama. Perpindahan mode tersedia di menu profil, mempertahankan halaman, filter, dan draft pengguna. Fitur penting tidak boleh hanya tersedia di Pro; Pro membuatnya lebih efisien, bukan membuka privilege baru.

## 4. Light dan Night Mode

Gunakan token semantik, jangan mewarnai tiap halaman secara manual. Nilai berikut adalah **starting point** yang perlu diuji dengan konten dan perangkat nyata.

| Token | Light | Night | Pemakaian |
|---|---|---|---|
| `surface.canvas` | `#F6F8FA` | `#11171D` | latar kerja |
| `surface.base` | `#FFFFFF` | `#1A222A` | tabel, formulir, panel |
| `surface.subtle` | `#EDF1F4` | `#25303A` | hover, header tabel |
| `text.primary` | `#18232D` | `#F2F5F7` | isi utama |
| `text.secondary` | `#53616D` | `#ABB8C2` | label sekunder |
| `border.default` | `#D9E1E6` | `#35434E` | garis pemisah |
| `action.primary` | `#1259A7` | `#78B7FF` | tautan, fokus, aksi utama |
| `action.onPrimary` | `#FFFFFF` | `#101820` | teks di tombol utama |
| `status.success` | `#087A65` | `#5AD1AF` | sukses/selesai |
| `status.warning` | `#9A6200` | `#F0BD63` | butuh perhatian |
| `status.danger` | `#B3363B` | `#FF8F91` | gagal/risiko |

**Aturan tema:** ikuti preferensi sistem pertama kali; pilihan Light/Night/System disimpan per pengguna. Grafik memakai warna dan pola/label, bukan warna saja. Pada Night Mode, jangan membalikkan warna secara otomatis; gunakan pasangan token khusus dan jaga garis tabel, tooltip, input, disabled, serta overlay tetap terbaca. Target kontras WCAG AA: teks normal ≥4,5:1; teks besar dan indikator UI ≥3:1, lalu verifikasi pada implementasi.

## 5. Komponen dan perilaku

- **Tombol:** satu primary per area keputusan; secondary/tertiary untuk aksi lain; destructive terpisah secara visual. Loading, disabled, dan sukses harus jelas.
- **Tabel data:** sticky header; angka rata kanan dan tabular; judul kolom jelas; status berupa teks + warna; pilih baris untuk bulk actions; pagination atau virtual scroll untuk volume besar; total dan jumlah hasil selalu jelas.
- **Filter:** chips filter aktif terlihat dan mudah dihapus; filter lanjutan berada di panel; simpan preset pribadi bila alur sering berulang; tindakan “Reset” mengembalikan keadaan yang diketahui.
- **Form:** label di atas field; helper text seperlunya; validasi dekat field dan rangkuman error di atas setelah submit; autosave draft hanya bila dijelaskan statusnya; tinggalkan halaman dengan draft → konfirmasi.
- **Pencarian global:** hasil dikelompokkan menurut modul, menampilkan nama, nomor dokumen, dan konteks perusahaan; kosong/error/loading dibedakan.
- **Notifikasi:** prioritas, waktu, sumber, tautan ke objek terkait; jangan mengandalkan toast yang hilang untuk hasil transaksi penting.
- **Persetujuan:** tampilkan nilai, pemohon, tanggal, dokumen pendukung, dan jejak keputusan sebelum tombol approve/reject.
- **Empty state:** jelaskan kondisi aktual dan berikan aksi relevan; jangan mengarang data untuk mengisi ruang.

## 6. Contoh layar prioritas

1. **Beranda Lite:** sapaan singkat, tugas saya, 3–4 KPI sesuai peran, aktivitas terbaru.
2. **Beranda Pro:** antrian persetujuan, KPI, exception feed, tabel transaksi terbaru, pintasan kerja.
3. **Daftar transaksi:** pencarian, filter, tabel, aksi massal, ekspor sesuai izin.
4. **Detail transaksi:** status dan nilai dominan, metadata, tab dokumen/aktivitas/audit, aksi sesuai state.
5. **Form transaksi:** versi terarah di Lite; versi padat dan shortcut di Pro.
6. **Analitik:** filter periode dan unit yang konsisten; KPI → grafik → tabel pendukung → drill-down.
7. **Pengaturan tampilan:** pilihan Lite/Pro, Light/Night/System, kepadatan tabel, dan preferensi navigasi.

## 7. Responsif dan aksesibilitas

- **≥1440 px:** sidebar 240 px; Pro dapat memakai panel samping kontekstual; lebar konten utama fleksibel.
- **1024–1439 px:** sidebar dapat diciutkan; kurangi panel paralel sebelum memperkecil teks.
- **768–1023 px:** satu kolom utama; filter dan detail sekunder menjadi drawer.
- **<768 px:** Lite menjadi pengalaman utama; daftar transaksi berubah menjadi baris ringkas dengan detail terpisah. Pro tetap dapat dipilih bila fitur layak digunakan, bukan sekadar desktop yang diperkecil.
- Target klik/sentuh minimal **44 × 44 px** pada kontrol utama; urutan fokus logis, fokus keyboard jelas, tooltip juga dapat diakses lewat fokus.
- Uji zoom browser 200%, navigasi keyboard, screen reader, panjang nama perusahaan/dokumen, dan format angka/tanggal lokal.
- Animasi singkat hanya untuk orientasi (drawer, perubahan status); hormati reduced motion.

## 8. Panduan implementasi Flutter Web

- Bentuk sistem token dalam `ThemeData` + `ColorScheme` dan `ThemeExtension` untuk surface, status, chart, serta density. Jangan menaruh kode warna langsung pada widget halaman.
- Pisahkan **app shell**, komponen reusable (table, filter, form, status), dan konfigurasi Lite/Pro. Mode memilih komposisi dan density, bukan logika izin.
- Gunakan breakpoints berbasis ruang tersedia (`LayoutBuilder`/constraints), bukan hanya tipe perangkat. Pastikan tabel lebar memiliki pola scroll horizontal yang jelas, sticky identitas baris bila perlu, dan tidak memotong aksi.
- Pertahankan URL/deep link untuk daftar, detail, dan filter yang bisa dibagikan; tangani back/forward browser dengan benar.
- Lokalisasi dari awal: Bahasa Indonesia, format `id_ID`, Rupiah, tanggal dan zona waktu eksplisit; sisakan ruang untuk Inggris dan angka besar.
- Audit komponen di kedua tema dan mode: default, hover, focus, active, selected, disabled, loading, empty, error, success.

## 9. Kriteria penerimaan desain

- Pengguna Lite menemukan tugas prioritas dan menyelesaikan satu persetujuan tanpa membuka navigasi kompleks.
- Pengguna Pro dapat menemukan transaksi, memfilter, membuka detail, dan kembali dengan filter tetap tersimpan.
- Mengganti Lite ↔ Pro atau Light ↔ Night tidak menghilangkan draft atau konteks kerja.
- Tidak ada data penting yang hanya ditandai warna; tidak ada aksi kritis tanpa konteks atau konfirmasi.
- Setiap layar prioritas punya rancangan desktop dan mobile, serta state loading/empty/error.
- UI terasa seperti satu produk konsisten, bukan campuran template dashboard dan halaman formulir.

## 10. Urutan kerja desain

1. Tetapkan identitas merek klien: nama produk, logo, serta apakah ada warna korporat yang wajib.
2. Rancang **empat layar jangkar** dalam Light: beranda Lite, beranda Pro, daftar transaksi, detail/transaksi.
3. Turunkan ke Night dengan token yang sama; audit kontras dan status.
4. Rancang form, analitik, pengaturan, dan seluruh state non-ideal.
5. Uji tugas nyata bersama pengguna baru dan power user; revisi alur sebelum memperluas modul.

### Referensi prinsip

- [1 — SAP Fiori Design Principles](https://experience.sap.com/fiori-design-web/explore_category/foundation/): role-based, coherent, adaptive, simple.
- [2 — Oracle Redwood](https://docs.oracle.com/en/cloud/saas/readiness/redwood-adoption/): enterprise-grade UX, consistency, accessibility, extensibility.
- [3 — Oracle Redwood appearance](https://docs.oracle.com/en/cloud/saas/readiness/common/25d/common25d/25D-common-wn-f39869.htm): theming lintas halaman dan standar aksesibilitas.
