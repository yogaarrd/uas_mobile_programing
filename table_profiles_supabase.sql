-- ============================================================
-- TABLE: profiles
-- Menyimpan data profil pengguna setelah registrasi
-- Jalankan script ini di Supabase SQL Editor
-- ============================================================

-- 1. Buat Enum untuk goal utama (skip jika sudah ada)
DO $$ BEGIN
  CREATE TYPE public.fitness_goal_enum AS ENUM (
    'Strength',
    'Hypertrophy',
    'Weight Loss',
    'General Fitness'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- 2. Buat tabel profiles
CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID        NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT        NOT NULL,
  birth_date  DATE        NOT NULL,
  weight_kg   NUMERIC(5,2) NOT NULL CHECK (weight_kg BETWEEN 20 AND 300),
  height_cm   NUMERIC(5,2) NOT NULL CHECK (height_cm BETWEEN 100 AND 250),
  goal        public.fitness_goal_enum NOT NULL DEFAULT 'General Fitness',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Aktifkan Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 4. Policy: user bisa SELECT profil miliknya sendiri
CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- 5. Policy: user bisa INSERT profil saat onboarding
CREATE POLICY "Users can insert own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- 6. Policy: user bisa UPDATE profil miliknya sendiri
CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 7. Trigger: auto-update kolom updated_at setiap kali ada perubahan
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_profiles_updated ON public.profiles;
CREATE TRIGGER on_profiles_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- Verifikasi: cek apakah tabel berhasil dibuat
-- ============================================================
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = 'profiles'
ORDER BY ordinal_position;
