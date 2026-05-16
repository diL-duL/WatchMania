# 🎬 Filmku — Aplikasi Manajemen Film

Aplikasi mobile Flutter untuk mengelola data film dengan operasi **CRUD**, autentikasi **Supabase**, role-based access (**Admin/User**), dan arsitektur **MVC**.

---

## 📸 Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🔐 **Login & Register** | Autentikasi pengguna dengan Supabase Auth |
| 👤 **Role-Based Access** | Admin dapat CRUD, User hanya bisa melihat |
| 📋 **Daftar Film** | Grid & list view dengan animasi card modern |
| 🔍 **Pencarian** | Cari film berdasarkan judul atau kategori |
| ➕ **Tambah Film** | Form 3-step (Info → Media → Detail) — Admin only |
| ✏️ **Edit Film** | Edit informasi film — Admin only |
| 🗑️ **Hapus Film** | Hapus dengan konfirmasi — Admin only |
| 📖 **Detail Film** | Halaman detail dengan hero animation & rating circular |
| 👨‍💼 **Profil User** | Lihat & edit profil, role badge, logout |
| 🎨 **Splash Screen** | Animated splash dengan auto-login check |

---

## 🏗️ Arsitektur — MVC (Model-View-Controller)

```
lib/
├── main.dart                          # Entry point + Supabase init
├── models/
│   ├── film_model.dart                # Model data Film
│   └── user_model.dart                # Model data User/Profile
├── services/
│   ├── film_service.dart              # Chopper service definition
│   └── film_service.chopper.dart      # Generated Chopper code
├── controllers/
│   ├── film_controller.dart           # Controller CRUD Film
│   └── auth_controller.dart           # Controller Auth + Profile
├── views/
│   ├── splash_view.dart               # Splash screen animasi
│   ├── login_view.dart                # Halaman login
│   ├── register_view.dart             # Halaman registrasi
│   ├── film_list_view.dart            # Daftar film (grid/list)
│   ├── film_detail_view.dart          # Detail film
│   ├── film_form_view.dart            # Form tambah/edit (3-step)
│   └── profile_view.dart             # Halaman profil user
└── theme/
    └── app_theme.dart                 # Tema hitam-kuning premium
```

---

## 🔐 Autentikasi & Role

### Role Permissions

| Feature | Admin | User |
|---------|-------|------|
| Lihat daftar film | ✅ | ✅ |
| Lihat detail film | ✅ | ✅ |
| Search film | ✅ | ✅ |
| Tambah film | ✅ | ❌ |
| Edit film | ✅ | ❌ |
| Hapus film | ✅ | ❌ |
| Lihat profil | ✅ | ✅ |

### Setup Admin
Untuk menjadikan user sebagai admin, ubah role di **Supabase SQL Editor**:
```sql
UPDATE profiles SET role = 'admin' WHERE email = 'email@example.com';
```

---

## 🗄️ Database Setup (Supabase)

Jalankan SQL berikut di **Supabase SQL Editor**:

```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  nama TEXT NOT NULL DEFAULT '',
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own profile
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Policy: Allow insert during signup
CREATE POLICY "Enable insert for signup" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

---

## 🌐 Film API (MockAPI)

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `GET` | `/film` | Ambil semua film |
| `GET` | `/film/{id}` | Ambil film by ID |
| `POST` | `/film` | Tambah film baru |
| `PUT` | `/film/{id}` | Update film |
| `DELETE` | `/film/{id}` | Hapus film |

**Base URL:** `https://68ff8dfbe02b16d1753e765d.mockapi.io`

---

## 📦 Dependencies

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `chopper` | ^8.0.0 | HTTP client |
| `provider` | ^6.1.0 | State management |
| `supabase_flutter` | ^2.12.4 | Auth & Database |
| `flutter_dotenv` | ^5.2.1 | Environment variables |
| `google_fonts` | ^6.0.0 | Typography (Poppins) |
| `intl` | ^0.19.0 | Format tanggal |

---

## 🎨 Tema — Hitam & Kuning Premium

| Elemen | Warna | Kode |
|--------|-------|------|
| Primary Gold | 🟡 | `#FFD700` |
| Background | ⬛ | `#0A0A0A` |
| Surface | ⬛ | `#141414` |
| Card | ⬛ | `#1C1C1E` |
| Text | ⬜ | `#F5F5F5` |

---

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK ^3.11.5
- Supabase Project (URL & Anon Key)

### Langkah-langkah

1. **Clone & masuk ke project**
   ```bash
   git clone <repository-url>
   cd mobile_api
   ```

2. **Setup environment**  
   Edit file `.env` dan isi credentials Supabase:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

3. **Setup database**  
   Jalankan SQL di atas di Supabase SQL Editor

4. **Install dependencies & run**
   ```bash
   flutter pub get
   flutter run
   ```

---

## 📱 Alur Penggunaan

1. **Splash Screen** → Cek session → Login / Home
2. **Register** → Buat akun baru (default role: user)
3. **Login** → Masuk ke daftar film
4. **Lihat Film** → Grid/list view dengan search
5. **Detail Film** → Tap card untuk info lengkap
6. **CRUD** → Hanya admin yang bisa tambah/edit/hapus
7. **Profil** → Tap avatar → lihat info & logout
8. **Set Admin** → Manual via Supabase SQL Editor

---

## 👨‍💻 Tech Stack

- **Framework:** Flutter
- **HTTP Client:** Chopper
- **Auth & DB:** Supabase
- **State Management:** Provider
- **Arsitektur:** MVC
