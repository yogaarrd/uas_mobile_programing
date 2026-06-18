-- ==========================================
-- 1. PEMBUATAN TABEL & RELASI (FOREIGN KEY)
-- ==========================================

-- Tabel untuk merekam sesi latihan (historis)
CREATE TABLE public.workout_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    -- template_id bisa NULL agar user bisa melakukan "Free Workout" (latihan tanpa template)
    -- ON DELETE SET NULL: Jika template dihapus, history sesi ini tidak ikut terhapus, hanya link-nya yang putus.
    template_id UUID REFERENCES public.workout_templates(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    finished_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    total_volume_kg NUMERIC(10,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Tabel jembatan untuk menyimpan Exercise apa saja yang dilakukan di sesi tersebut
CREATE TABLE public.session_exercises (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id UUID REFERENCES public.workout_sessions(id) ON DELETE CASCADE NOT NULL,
    exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE NOT NULL,
    order_index INTEGER NOT NULL
);

-- Tabel untuk menyimpan konfigurasi dan status "Selesai/Belum" per-Set yang dilakukan user
CREATE TABLE public.session_sets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_exercise_id UUID REFERENCES public.session_exercises(id) ON DELETE CASCADE NOT NULL,
    set_number INTEGER NOT NULL,
    reps INTEGER,
    weight NUMERIC(6,2),
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- ==========================================
-- 2. KONFIGURASI ROW LEVEL SECURITY (RLS)
-- ==========================================

ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_sets ENABLE ROW LEVEL SECURITY;

-- Policy untuk workout_sessions: User hanya bisa akses/kelola sesi latihannya sendiri
CREATE POLICY "User dapat mengelola workout sessions miliknya"
ON public.workout_sessions FOR ALL TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy untuk session_exercises: Hanya bisa diakses jika session_id terhubung ke user
CREATE POLICY "User dapat mengelola session exercises miliknya"
ON public.session_exercises FOR ALL TO authenticated
USING ( session_id IN (SELECT id FROM public.workout_sessions WHERE user_id = auth.uid()) )
WITH CHECK ( session_id IN (SELECT id FROM public.workout_sessions WHERE user_id = auth.uid()) );

-- Policy untuk session_sets: Hanya bisa diakses jika session_exercise_id terhubung ke sesi milik user
CREATE POLICY "User dapat mengelola session sets miliknya"
ON public.session_sets FOR ALL TO authenticated
USING ( 
    session_exercise_id IN (
        SELECT id FROM public.session_exercises 
        WHERE session_id IN (SELECT id FROM public.workout_sessions WHERE user_id = auth.uid())
    ) 
)
WITH CHECK ( 
    session_exercise_id IN (
        SELECT id FROM public.session_exercises 
        WHERE session_id IN (SELECT id FROM public.workout_sessions WHERE user_id = auth.uid())
    ) 
);