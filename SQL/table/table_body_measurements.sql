-- ============================================================
-- TABLE: body_measurements
-- Menyimpan catatan berat badan pengguna dari waktu ke waktu
-- ============================================================

CREATE TABLE IF NOT EXISTS public.body_measurements (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  measured_at DATE NOT NULL DEFAULT CURRENT_DATE,
  weight_kg   NUMERIC(5, 2) NOT NULL CHECK (weight_kg > 0 AND weight_kg < 700),
  note        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index untuk query cepat berdasarkan user + tanggal
CREATE INDEX IF NOT EXISTS idx_body_measurements_user_date
  ON public.body_measurements (user_id, measured_at DESC);

-- Unique constraint: 1 catatan per hari per user
ALTER TABLE public.body_measurements
  ADD CONSTRAINT uq_body_measurements_user_date UNIQUE (user_id, measured_at);

-- ===========================
-- ROW LEVEL SECURITY (RLS)
-- ===========================
ALTER TABLE public.body_measurements ENABLE ROW LEVEL SECURITY;

-- Hanya user yang terautentikasi dapat membaca data miliknya sendiri
CREATE POLICY "Users can view own measurements"
  ON public.body_measurements
  FOR SELECT
  USING (auth.uid() = user_id);

-- Hanya user yang terautentikasi dapat menambah data miliknya sendiri
CREATE POLICY "Users can insert own measurements"
  ON public.body_measurements
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Hanya user yang terautentikasi dapat mengupdate data miliknya sendiri
CREATE POLICY "Users can update own measurements"
  ON public.body_measurements
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Hanya user yang terautentikasi dapat menghapus data miliknya sendiri
CREATE POLICY "Users can delete own measurements"
  ON public.body_measurements
  FOR DELETE
  USING (auth.uid() = user_id);
