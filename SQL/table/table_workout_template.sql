-- ==========================================
-- 1. PEMBUATAN TABEL DAN RELASI (FOREIGN KEY)
-- ==========================================

-- Tabel untuk menyimpan daftar Workout Template milik user
CREATE TABLE workout_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Tabel jembatan untuk menyimpan Exercise apa saja yang ada di dalam sebuah Template
CREATE TABLE template_exercises (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    template_id UUID REFERENCES workout_templates(id) ON DELETE CASCADE NOT NULL,
    exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE NOT NULL,
    order_index INTEGER NOT NULL -- Untuk mengurutkan (drag & drop) urutan latihan
);

-- Tabel untuk menyimpan konfigurasi per-Set untuk setiap Exercise di dalam Template
CREATE TABLE exercise_sets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    template_exercise_id UUID REFERENCES template_exercises(id) ON DELETE CASCADE NOT NULL,
    set_number INTEGER NOT NULL,
    reps INTEGER,
    weight NUMERIC(6,2), -- Mendukung angka desimal (misal: 67.5 kg)
    rest_seconds INTEGER
);

-- ==========================================
-- 2. KONFIGURASI ROW LEVEL SECURITY (RLS)
-- ==========================================

ALTER TABLE workout_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE template_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_sets ENABLE ROW LEVEL SECURITY;

-- Policy untuk workout_templates: User hanya bisa akses data miliknya sendiri
CREATE POLICY "User hanya bisa akses workout miliknya"
ON workout_templates FOR ALL TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy untuk template_exercises: Hanya bisa diakses jika template_id adalah milik user
CREATE POLICY "User hanya bisa akses template exercises miliknya"
ON template_exercises FOR ALL TO authenticated
USING ( template_id IN (SELECT id FROM workout_templates WHERE user_id = auth.uid()) )
WITH CHECK ( template_id IN (SELECT id FROM workout_templates WHERE user_id = auth.uid()) );

-- Policy untuk exercise_sets: Hanya bisa diakses jika template_exercise_id terhubung ke template milik user
CREATE POLICY "User hanya bisa akses exercise sets miliknya"
ON exercise_sets FOR ALL TO authenticated
USING ( 
    template_exercise_id IN (
        SELECT id FROM template_exercises 
        WHERE template_id IN (SELECT id FROM workout_templates WHERE user_id = auth.uid())
    ) 
)
WITH CHECK ( 
    template_exercise_id IN (
        SELECT id FROM template_exercises 
        WHERE template_id IN (SELECT id FROM workout_templates WHERE user_id = auth.uid())
    ) 
);


-- Seeder - test
-- 1. Insert 1 Workout Template (Push Day Beginner)
INSERT INTO workout_templates (id, user_id, name, description)
VALUES (
    '11111111-1111-1111-1111-111111111111', 
    (SELECT id FROM auth.users LIMIT 1), -- Otomatis mengambil user milikmu
    'Push Day Beginner', 
    'Latihan dasar untuk melatih otot dorong: Dada, Bahu, dan Trisep.'
);

-- 2. Insert Template Exercises (Daftar Latihan di dalam Template)
-- Menggunakan UUID dari data exercises yang kamu berikan
INSERT INTO template_exercises (id, template_id, exercise_id, order_index)
VALUES 
    -- Urutan 1: Barbell Bench Press (Dada)
    ('22222222-2222-2222-2222-222222222221', '11111111-1111-1111-1111-111111111111', 'a9db2f46-ae6a-457d-af31-5101624a278e', 1),
    
    -- Urutan 2: Overhead Press (Bahu)
    ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', '02946176-9a20-48cd-ad90-b64ebce531cc', 2),
    
    -- Urutan 3: Tricep Pushdown (Trisep)
    ('22222222-2222-2222-2222-222222222223', '11111111-1111-1111-1111-111111111111', '5b5bb33d-304e-4f8b-a23b-5f3d767ab927', 3);

-- 3. Insert Exercise Sets (Detail Repetisi, Beban, dan Istirahat per Latihan)
INSERT INTO exercise_sets (template_exercise_id, set_number, reps, weight, rest_seconds)
VALUES 
    -- Set untuk Barbell Bench Press (3 Set)
    ('22222222-2222-2222-2222-222222222221', 1, 12, 40.00, 90),
    ('22222222-2222-2222-2222-222222222221', 2, 10, 50.00, 90),
    ('22222222-2222-2222-2222-222222222221', 3, 8,  60.00, 90),

    -- Set untuk Overhead Press (3 Set)
    ('22222222-2222-2222-2222-222222222222', 1, 10, 20.00, 60),
    ('22222222-2222-2222-2222-222222222222', 2, 10, 25.00, 60),
    ('22222222-2222-2222-2222-222222222222', 3, 8,  30.00, 60),

    -- Set untuk Tricep Pushdown (2 Set)
    ('22222222-2222-2222-2222-222222222223', 1, 15, 15.00, 60),
    ('22222222-2222-2222-2222-222222222223', 2, 12, 20.00, 60);



-- Testing
SELECT 
    wt.name AS nama_workout,
    e.name AS nama_latihan,
    te.order_index AS urutan_latihan,
    es.set_number AS set_ke,
    es.reps AS repetisi,
    es.weight AS beban_kg,
    es.rest_seconds AS waktu_istirahat_detik
FROM workout_templates wt
JOIN template_exercises te ON wt.id = te.template_id
JOIN exercises e ON te.exercise_id = e.id
JOIN exercise_sets es ON te.id = es.template_exercise_id
WHERE wt.id = '11111111-1111-1111-1111-111111111111'
ORDER BY te.order_index ASC, es.set_number ASC;
