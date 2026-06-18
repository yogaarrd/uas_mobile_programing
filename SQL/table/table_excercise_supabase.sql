-- Buat Enum dulu
create type public.muscle_group_enum as enum (
  'chest',
  'back',
  'legs',
  'shoulders',
  'arms',
  'core',
  'cardio'
);

create type public.equipment_enum as enum (
  'bodyweight',
  'dumbbell',
  'barbell',
  'machine' 
);

-- Buat Table
create table public.exercises (
  id uuid not null default gen_random_uuid (),
  name text not null,
  muscle_group public.muscle_group_enum not null,
  secondary_muscles text[] null default '{}'::text[],
  equipment public.equipment_enum not null,
  instructions text not null,
  image_url text null,
  is_custom boolean null default false,
  created_by uuid null,
  created_at timestamp with time zone null default now(),
  constraint exercises_pkey primary key (id),
  constraint exercises_created_by_fkey foreign KEY (created_by) references auth.users (id)
) TABLESPACE pg_default;


-- 1. Pastikan fitur RLS aktif pada tabel exercises
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

-- 2. POLICY READ (SELECT)
-- Mengizinkan semua user yang sudah login untuk melihat latihan bawaan (is_custom = false)
-- DAN melihat latihan custom yang mereka buat sendiri (created_by = auth.uid())
CREATE POLICY "Izinkan user melihat latihan bawaan dan miliknya sendiri"
ON public.exercises FOR SELECT
TO authenticated
USING (is_custom = false OR created_by = auth.uid());

-- 3. POLICY CREATE (INSERT)
-- User hanya bisa memasukkan data jika itu adalah latihan custom (is_custom = true) 
-- dan didaftarkan atas ID mereka sendiri.
CREATE POLICY "Izinkan user menambah latihan custom"
ON public.exercises FOR INSERT
TO authenticated
WITH CHECK (is_custom = true AND created_by = auth.uid());

-- 4. POLICY UPDATE
-- User HANYA bisa mengedit data jika ID pembuatnya cocok dengan ID user tersebut.
CREATE POLICY "Izinkan user mengedit latihan miliknya sendiri"
ON public.exercises FOR UPDATE
TO authenticated
USING (created_by = auth.uid());

-- 5. POLICY DELETE
-- User HANYA bisa menghapus data jika ID pembuatnya cocok dengan ID user tersebut.
CREATE POLICY "Izinkan user menghapus latihan miliknya sendiri"
ON public.exercises FOR DELETE
TO authenticated
USING (created_by = auth.uid());