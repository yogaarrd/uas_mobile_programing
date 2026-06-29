# 🎨 Moreps — Color Palette

Dokumentasi lengkap palet warna yang digunakan di aplikasi **Moreps**.

---

## 🟢 Primary — Neon Green (Brand Color)

| Nama | Hex | ARGB | Preview | Penggunaan |
|------|------|------|---------|------------|
| **Neon Green** | `#CFFF4B` | `Color.fromARGB(255, 207, 255, 75)` | 🟩 | Warna utama brand, tombol CTA, aksen teks penting, ikon navigasi aktif, marker kalender |

> **Catatan:** Warna ini adalah identitas visual Moreps. Digunakan secara konsisten di semua tombol utama (`ElevatedButton`), Bottom Navigation (selected item), dan elemen interaktif penting.

---

## ⬛ Background & Surface (Dark Mode)

| Nama | Hex | ARGB / Kode | Preview | Penggunaan |
|------|------|-------------|---------|------------|
| **Dark Background** | `#010102` | `Color.fromARGB(255, 1, 1, 2)` | ⬛ | Background utama scaffold, warna paling gelap |
| **Surface Color** | `#16161D` | `Color.fromARGB(255, 22, 22, 29)` | 🖤 | Bottom Navigation Bar, card summary, elemen floating |
| **Surface Dark** | `#1E1E1E` | `Color(0xFF1E1E1E)` | 🖤 | Input field fill color |
| **Surface Blue-Dark** | `#1E1E2A` | `Color(0xFF1E1E2A)` | 🖤 | Card profil, chip selection, dialog background |
| **Surface Blue-Dark Alt** | `#1E1E26` | `Color(0xFF1E1E26)` | 🖤 | Onboarding surface color scheme |
| **Card Elevated** | `#2A2A3A` | `Color(0xFF2A2A3A)` | ◼️ | Card dengan elevasi (profil section, stat card) |
| **Gradient Surface** | `#2B2B3A` | `Color(0xFF2B2B3A)` | ◼️ | Gradient start (active session bottom sheet) |

---

## 🎨 Accent Colors (Triad Aksen)

Tiga warna aksen ini membentuk **Color Triad** yang digunakan di seluruh fitur Progress, Profile Stats, dan Onboarding Goals.

| Nama | Hex | Kode | Preview | Penggunaan |
|------|------|------|---------|------------|
| **Purple Accent** | `#7B61FF` | `Color(0xFF7B61FF)` | 🟪 | Ikon progress (Total Sesi), exercise card, badge indikator, chevron |
| **Orange Accent** | `#FF6B35` | `Color(0xFFFF6B35)` | 🟧 | Ikon progress (Volume/Angkatan), berat naik indikator, fitness goal "Strength" |
| **Teal/Mint Accent** | `#00D4AA` | `Color(0xFF00D4AA)` | 🟩 | Ikon progress (Durasi), berat turun indikator, fitness goal "Weight Loss" |

### Penggunaan di fitur:

- **Progress Page:** Ketiga warna sebagai ikon statistik (Sesi, Volume, Durasi)
- **Body Weight Tracker:** Teal = berat turun (positif), Orange = berat naik
- **Profile Page:** Stats card icons
- **Onboarding/Edit Profile:** Goal selection chip colors

---

## 🔀 Gradient

| Nama | Warna | Kode | Penggunaan |
|------|-------|------|------------|
| **Neon Gradient** | `#CFFF4B` → `#9EBA00` | `[AppTheme.neonGreen, Color(0xFF9EBA00)]` | Gradient tombol/banner Home Page |
| **Session Gradient** | `#2B2B3A` → `#010102` | `[Color(0xFF2B2B3A), AppTheme.darkBackground]` | Active Session bottom sheet fade |

---

## 🔘 Neutral / Utility (Flutter Built-in)

| Warna | Kode | Penggunaan |
|-------|------|------------|
| **White** | `Colors.white` | Teks heading, judul, label utama |
| **White70** | `Colors.white70` | Teks sekunder, instruksi latihan |
| **White54** | `Colors.white54` | Teks hint/placeholder |
| **Grey** | `Colors.grey` | Ikon non-aktif, teks deskripsi, divider, ikon placeholder |
| **Grey.shade600** | `Colors.grey.shade600` | Hint text input field |
| **Grey.shade800** | `Colors.grey.shade800` | Border outline input field, card border |
| **Black** | `Colors.black` | Teks pada tombol neon (foreground kontras) |
| **Transparent** | `Colors.transparent` | AppBar background |

---

## ⚠️ Semantic / Status Colors

| Warna | Kode | Penggunaan |
|-------|------|------------|
| **Red Accent** | `Colors.redAccent` | Error state (SnackBar error, border error input) |
| **Red** | `Colors.red` | Error text di library |
| **Orange Accent** | `Colors.orangeAccent` | Badge pencapaian/PR baru di Session Summary |
| **Light Blue Accent** | `Colors.lightBlueAccent` | Chip info equipment latihan |
| **Amber** | `Colors.amber` *(ref PRD)* | Highlight Personal Record di tabel historis |

---

## 📐 Ringkasan Visual Hierarki Warna

```
┌─────────────────────────────────────────────┐
│  MOREPS COLOR HIERARCHY                     │
├─────────────────────────────────────────────┤
│                                             │
│  🟩 #CFFF4B  ←  PRIMARY / BRAND            │
│                                             │
│  ⬛ #010102  ←  BACKGROUND (deepest)        │
│  ◼️ #16161D  ←  SURFACE (nav, cards)        │
│  ◼️ #1E1E2A  ←  CARD / INPUT               │
│  ◼️ #2A2A3A  ←  ELEVATED CARD              │
│                                             │
│  🟪 #7B61FF  ←  ACCENT 1 (Purple)          │
│  🟧 #FF6B35  ←  ACCENT 2 (Orange)          │
│  🟩 #00D4AA  ←  ACCENT 3 (Teal)            │
│                                             │
│  ⚪ White    ←  TEXT PRIMARY                │
│  🔘 Grey     ←  TEXT SECONDARY              │
│  ⬛ Black    ←  TEXT ON PRIMARY BUTTON       │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 📍 Referensi File

Semua warna utama didefinisikan di:
- [`app_theme.dart`](lib/core/theme/app_theme.dart) — `AppTheme.neonGreen`, `AppTheme.darkBackground`, `AppTheme.surfaceColor`

Warna aksen digunakan secara inline di:
- [`progress_page.dart`](lib/features/progress/pages/progress_page.dart)
- [`body_weight_page.dart`](lib/features/progress/pages/body_weight_page.dart)
- [`profile_page.dart`](lib/features/profile/pages/profile_page.dart)
- [`onboarding_page.dart`](lib/features/profile/pages/onboarding_page.dart)
- [`home_page.dart`](lib/features/home/pages/home_page.dart)
