-- ============================================================
-- STORAGE: Setup bucket 'avatars' untuk foto profil
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- 1. Tambah kolom avatar_url ke tabel profiles (jika belum ada)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- ============================================================
-- 2. Buat Storage bucket 'avatars'
--    (Bisa juga via Dashboard: Storage > New Bucket)
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 3. Storage Policies untuk bucket 'avatars'
-- ============================================================

-- Policy: User bisa UPLOAD foto ke folder miliknya sendiri
CREATE POLICY "Users can upload own avatar"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Policy: User bisa UPDATE/REPLACE foto miliknya
CREATE POLICY "Users can update own avatar"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Policy: Foto bisa dilihat oleh siapapun (public)
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

-- Policy: User bisa DELETE foto miliknya
CREATE POLICY "Users can delete own avatar"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
