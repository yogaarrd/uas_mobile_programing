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

-- Seed Table

INSERT INTO "public"."exercises" (
  "id", "name", "muscle_group", "secondary_muscles", "equipment", 
  "instructions", "image_url", "is_custom", "created_by", "created_at"
) VALUES 
('02946176-9a20-48cd-ad90-b64ebce531cc', 'Overhead Press', 'shoulders', ARRAY['arms','core'], 'barbell', 'Berdiri tegak, dorong barbel dari posisi depan bahu lurus ke atas kepala. Turunkan perlahan tanpa mengandalkan ayunan kaki.', 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=800&q=80', false, null, '2026-06-06 05:19:47.851855+00'), 
('0a5b4609-1a28-48e5-80e8-6663e3a821d5', 'Barbell Squat', 'legs', ARRAY['core','back'], 'barbell', 'Posisikan barbel di punggung atas. Turunkan pinggul ke bawah (jongkok) hingga paha sejajar lantai, dorong kuat ke atas.', 'https://images.unsplash.com/photo-1770026136877-8ddf98cd6500?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', false, null, '2026-06-06 05:19:47.851855+00'), 
('1a9f9cdd-2611-4b69-ad5d-400146a90791', 'Bicycle Crunch', 'core', ARRAY[]::text[], 'bodyweight', 'Berbaring telentang, angkat kedua kaki bergantian. Putar dada menyilangkan siku kanan ke arah lutut kiri dan sebaliknya.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTlD4rRRJzNrBfsTM3IMplPn1vukTLWj_2avF3t8y8YSg&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('244953a2-fbc4-4bd3-a5ee-6b6ed0685acf', 'Pec Deck Fly', 'chest', ARRAY['shoulders'], 'machine', 'Duduk di mesin pec deck. Bawa lengan pada bantalan mesin bersamaan di depan dada sambil membuang napas, tahan sejenak.', 'https://images.aasaan.shop/stores/b3412024/products/product_images/product_1772867974923.png', false, null, '2026-06-06 05:19:47.851855+00'), 
('2755504e-775e-4ba8-a796-261eec62236c', 'Romanian Deadlift', 'legs', ARRAY['back','core'], 'barbell', 'Pegang barbel di depan paha. Dorong pinggul ke belakang dengan lutut sedikit ditekuk hingga meregangkan hamstring maksimal.', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=800&q=80', false, null, '2026-06-06 05:19:47.851855+00'), 
('27ee10f8-6b95-4adf-a303-27e1d46bb2b0', 'Incline Dumbbell Press', 'chest', ARRAY['shoulders','arms'], 'dumbbell', 'Gunakan bangku miring (30-45 derajat). Dorong dumbbell lurus ke atas sejajar dengan bahu, lalu turunkan perlahan untuk melatih dada atas.', 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=800&q=80', false, null, '2026-06-06 05:19:47.851855+00'), 
('2822bf5a-67b3-4bfa-9144-38f510e86d27', 'Face Pull', 'shoulders', ARRAY['back'], 'machine', 'Pasang tali (rope) di kabel atas. Tarik tali mengarah ke wajah (level mata) sambil melebarkan kedua siku ke luar.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFFBs5Cr6Qt7yVHu0uOlVzKyIqVCssgUuT9qAaNRR8ql2Q6LNnQ9pbxXDt&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('3196bf39-aab9-4102-b70a-75aa9bbda7d0', 'Rowing Machine', 'cardio', ARRAY['back','legs','core'], 'machine', 'Duduk di mesin dayung. Dorong mundur menggunakan kaki terlebih dahulu, kemudian tarik tuas ke arah dada kuat-kuat.', 'https://burnfit.io/en/wp-content/uploads/sites/3/2026/01/ROW_MACH.gif', false, null, '2026-06-06 05:19:47.851855+00'), 
('3354296d-ad64-4d70-8a98-d19b4ea0cc8d', 'Chest Dip', 'chest', ARRAY['arms','shoulders'], 'bodyweight', 'Pegang bar dip paralel, condongkan dada ke depan. Turunkan tubuh hingga siku membentuk sudut 90 derajat, lalu dorong badan naik.', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcRMJP26l36O7M9DwwNqrlhSpbsYHzz6NUT0gZJ-KLbp2zOVSpN5', false, null, '2026-06-06 05:19:47.851855+00'), 
('33df9058-b9d1-442b-989b-604b75b87517', 'Deadlift', 'back', ARRAY['legs','core'], 'barbell', 'Berdiri dengan kaki selebar bahu. Angkat barbel dari lantai menggunakan pinggul dan kaki, pastikan punggung netral tanpa membungkuk.', 'https://training.fit/wp-content/uploads/2020/03/kreuzheben-gestreckte-beine.png', false, null, '2026-06-06 05:19:47.851855+00'), 
('3c24bd72-89f2-4771-a386-1a2836b18150', 'Dumbbell Lateral Raise', 'shoulders', ARRAY[]::text[], 'dumbbell', 'Berdiri tegak memegang dumbbell di sisi tubuh. Angkat kedua lengan ke samping hingga sejajar dengan bahu, kontrol saat turun.', 'https://liftmanual.com/wp-content/uploads/2023/04/dumbbell-seated-lateral-raise.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('470ecd1d-34e2-44a1-983b-48f33c5a339d', 'Burpees', 'cardio', ARRAY['chest','legs','core'], 'bodyweight', 'Gerakan berantai: squat turun, lompat tendang ke posisi push-up, tarik kaki kembali ke depan, lalu akhiri berdiri lompat.', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQKgc3PnX-mlsGd7WL5FxBGFk_YV-lwjXsS4K2JdnCb2XIhLn2m', false, null, '2026-06-06 05:19:47.851855+00'), 
('49791fe6-64ad-4b61-8ee3-17e85f88d034', 'Lat Pulldown', 'back', ARRAY['arms'], 'machine', 'Duduk tegak, pegang bar mesin dengan pegangan lebar. Tarik bar ke arah dada atas, lalu kembalikan perlahan sambil meregangkan otot.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpsu8JxtPgJrKSbL19dC06ET2Kl6wLRdestssGDq0s2dYYo-2w', false, null, '2026-06-06 05:19:47.851855+00'), 
('56d8ea11-d5d6-4265-ba14-912ee2d8e688', 'Cable Crossover', 'chest', ARRAY['shoulders'], 'machine', 'Tarik kabel dari sisi kanan dan kiri ke depan dada dengan sedikit tekukan di siku. Fokus pada kontraksi otot dada di titik puncak.', 'https://liftmanual.com/wp-content/uploads/2023/04/cable-standing-up-straight-crossovers.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('59f084a1-d99d-4b49-8e10-fcd10b1ed365', 'Push Up', 'chest', ARRAY['shoulders','arms','core'], 'bodyweight', 'Posisikan tubuh tengkurap, angkat tubuh menggunakan lengan. Jaga punggung tetap lurus dan turunkan tubuh hingga dada hampir menyentuh lantai.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDJwGWYp6kpYes7MPWigTUI5_qd1bcpWWLnbiqPuzDkg&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('5b5bb33d-304e-4f8b-a23b-5f3d767ab927', 'Tricep Pushdown', 'arms', ARRAY[]::text[], 'machine', 'Gunakan mesin kabel dengan sambungan lurus atau tali. Dorong kabel ke bawah menggunakan otot trisep, jaga postur tegap.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnYOCL8CIhibgZr3aF2x91iIfrulb1qTFlxTv-AoXWWrzo8FM1UJI8hhg&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('5dac5a3a-4bce-450b-bc2d-58242a75fbe7', 'Close Grip Bench Press', 'arms', ARRAY['chest','shoulders'], 'barbell', 'Berbaring di bangku datar. Pegang barbel lebih rapat dari lebar bahu untuk memindahkan beban tekanan pada otot trisep.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSq_vH2j9Yj9wd855ODSH6BYlBoeZ1ZC5q4jj1ZC0z8ytz_qd7S', false, null, '2026-06-06 05:19:47.851855+00'), 
('63e882b0-2bf3-45ee-8ffc-e90c1acd10b3', 'Lying Leg Curl', 'legs', ARRAY[]::text[], 'machine', 'Tengkurap di mesin curl kaki. Tekuk lutut dan angkat beban menuju glutes secara perlahan lalu rentangkan kaki.', 'https://watsongym.co.uk/wp-content/uploads/2023/03/IMG_9973.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('64db03e5-f93f-420c-a25e-d7ffe948c74b', 'Treadmill Running', 'cardio', ARRAY['legs'], 'machine', 'Berlari dengan kecepatan medium hingga tinggi secara konstan di treadmill. Pertahankan ritme napas yang teratur.', 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQe3LEwCT5XbBnYS2eYRxSuzzLx1ChvdftCwO9Q0_1lFJ1SjcLQ', false, null, '2026-06-06 05:19:47.851855+00'), 
('6c1208a3-5b45-4469-ae09-cb238e5d086f', 'Dumbbell Pullover', 'chest', ARRAY['back'], 'dumbbell', 'Berbaring melintang di bangku. Pegang satu dumbbell dengan dua tangan, turunkan ke belakang kepala lalu tarik kembali ke atas dada.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTktiOBRxjj-PN8tuwjwE6z0H-pUgaGhokIywo8tb0QSEJYlaxYMylZ_GQ&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('6ccc0c51-43be-45c5-afd4-343d42294f33', 'Upright Row', 'shoulders', ARRAY['back','arms'], 'barbell', 'Pegang barbel di depan paha. Tarik lurus ke atas menuju dagu sambil menjaga siku tetap lebih tinggi dari barbel.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSSrqVMQLbKOvvg0niPVuJ83LqNncvwqEDBwtQnFXSp8U6Ry5ciQSwhByk&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('76536f7d-2cbf-4974-93c3-5c333304782c', 'Stationary Bike', 'cardio', ARRAY['legs'], 'machine', 'Gowes di sepeda statis gym. Atur tingkat resistensi sesuai target untuk membakar kalori dan melatih otot paha.', 'https://hips.hearstapps.com/hmg-prod/images/wahoo-fitness-kickr-bike-v2-678680ddf0090.jpg?crop=0.668xw:1.00xh;0.167xw,0&resize=1200:*', false, null, '2026-06-06 05:19:47.851855+00'), 
('77b2dbd5-9bfc-45fe-82cf-357d8624be9c', 'Front Raise', 'shoulders', ARRAY['chest'], 'dumbbell', 'Angkat dumbbell ke arah depan lurus sejajar dengan mata, pertahankan punggung tetap tegak dan core stabil.', 'https://liftmanual.com/wp-content/uploads/2023/04/weighted-front-raise.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('7f742975-330a-4412-b9c9-f2fa00a7e3d2', 'Stair Climber', 'cardio', ARRAY['legs'], 'machine', 'Naiki anak tangga berputar secara konsisten. Hindari bertumpu atau merebahkan berat badan berlebih di pegangan mesin.', 'https://sunnyhealthfitness.com/cdn/shop/files/Sunny-health-fitness-Steppers-Premium-Stepper-Stair-Climber-SF-X7300SMART-01.jpg?v=1738276435', false, null, '2026-06-06 05:19:47.851855+00'), 
('82daa808-3685-4941-832d-c6defaa9ba06', 'Crunch', 'core', ARRAY[]::text[], 'bodyweight', 'Berbaring terlentang, lutut ditekuk. Angkat bahu dan dada atas dari lantai sedikit saja, kontraksikan otot perut keras.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQbffAwxdisLqmYQPoQzskhd_eNy6WniNPHEmC8GljY4E_dpZfRX_4aKqo&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('898bc41a-705a-4059-a836-3ba85be14031', 'Calf Raise', 'legs', ARRAY[]::text[], 'machine', 'Berdiri dengan ujung kaki di pinggiran platform. Angkat tumit setinggi mungkin, tahan, turunkan perlahan melebihi batas rata.', 'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcS-RcTZC0WNQIE9KbguBzm4sueIw0qmstjfKD7tXlsgW2Ltlp4_', false, null, '2026-06-06 05:19:47.851855+00'), 
('8a25f812-af08-4ed1-af07-8cf004e20b8f', 'Bulgarian Split Squat', 'legs', ARRAY['core'], 'dumbbell', 'Letakkan satu punggung kaki di bangku belakang. Turunkan pinggul secara vertikal dengan kaki depan sebagai tumpuan utama.', 'https://liftmanual.com/wp-content/uploads/2023/04/bulgarian-split-squat-with-chair.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('8cef70eb-45cc-4151-a457-1fb3275a5e6a', 'Barbell Bicep Curl', 'arms', ARRAY[]::text[], 'barbell', 'Berdiri tegak, pegang barbel selebar bahu. Angkat barbel ke arah dada dengan melipat siku, jaga siku tetap menempel di sisi tubuh.', 'https://liftmanual.com/wp-content/uploads/2023/04/ez-barbell-curl.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('93702a51-5871-43c1-8c48-f7323889e322', 'Cable Woodchopper', 'core', ARRAY['shoulders'], 'machine', 'Tarik handle kabel dari titik tinggi secara diagonal melewati tubuh ke bawah, gunakan pinggang untuk memutar batang tubuh.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRW1AN_KoVAKB8tmV567_UlcWtyS04Lnvj3A5bXETjYSCY_OCvvtVrjH_Uv&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('980ed12b-a50a-4e77-97d7-6c1ba6ae0e23', 'Plank', 'core', ARRAY['shoulders','back'], 'bodyweight', 'Tahan posisi bertumpu pada siku dan ujung kaki. Jaga postur punggung selurus papan kayu, tahan posisi selama mungkin.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYgG4bgh4nlWffPq1nN031LSoyx2Gx6sWKqE12Qx9htZJN_oFKExLEmBg&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('9a7742b8-91e7-44c6-9197-b7bb01033dcb', 'Ab Wheel Rollout', 'core', ARRAY['shoulders','arms'], 'machine', 'Berlutut memegang ab wheel. Dorong roda jauh ke depan menahan beban tubuh, lalu tarik kembali menggunakan otot perut.', 'https://hctravisplace.com/wp-content/uploads/2020/10/abwheelrollout.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('9b7affde-05a7-4e8f-bbe3-2a708aa3b9aa', 'Leg Extension', 'legs', ARRAY[]::text[], 'machine', 'Duduk di mesin, posisikan bantalan tepat di atas pergelangan kaki. Angkat beban dengan meluruskan kaki ke depan.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRRO5jWu97C4EDe-GUGKy195nqYBDaL2HdfPINE-zr9QA&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('9dcfa679-c900-47aa-a916-e869538c6fd4', 'Jump Rope', 'cardio', ARRAY['legs','shoulders'], 'bodyweight', 'Gunakan tali lompat dengan memutar pergelangan tangan. Lakukan loncatan kecil dengan ritme cepat tanpa jeda.', 'https://liftmanual.com/wp-content/uploads/2023/04/jump-rope.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('9efad043-84bc-48a4-8322-31a022bc6869', 'Barbell Row', 'back', ARRAY['arms','core'], 'barbell', 'Condongkan badan ke depan dengan lutut sedikit ditekuk. Tarik barbel ke arah perut sambil menjaga punggung tetap lurus dan stabil.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZ4b_oHrkxeqqYybR6Eg34PjVtsejsyQ02UimKLA4xNQ&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('a9db2f46-ae6a-457d-af31-5101624a278e', 'Barbell Bench Press', 'chest', ARRAY['shoulders','arms'], 'barbell', 'Berbaring di bangku datar. Turunkan barbel ke tengah dada secara perlahan, lalu dorong kembali ke posisi awal dengan kuat.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-oYou-Zv4S-wks_5sKr9e4KYqORKOt7V4ydKjiqUdHQ&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('acb7540b-251a-4788-a0f0-a9fb1eab4a48', 'Leg Press', 'legs', ARRAY[]::text[], 'machine', 'Duduk di mesin leg press, letakkan kaki di platform. Turunkan beban ke arah dada tanpa mengangkat bokong, dorong kembali.', 'https://liftmanual.com/wp-content/uploads/2023/04/lever-seated-leg-press.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('b6e68ade-6c50-4aa9-bd9b-61d26fd9a665', 'Concentration Curl', 'arms', ARRAY[]::text[], 'dumbbell', 'Duduk di bangku, sandarkan satu siku di bagian dalam paha. Lakukan gerakan curl dengan fokus dan kontrol lambat.', 'https://liftmanual.com/wp-content/uploads/2023/04/kettlebell-concentration-curl.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('b7f5b598-2b6b-4b3f-b1d2-d5e585f843a0', 'T-Bar Row', 'back', ARRAY['arms','core'], 'machine', 'Berdiri menyilang di atas T-bar. Tarik beban ke arah dada dan kontrol perlahan saat beban turun kembali.', 'https://hips.hearstapps.com/hmg-prod/images/landmine-t-bar-row-1677585906.jpg?crop=1.00xw:0.724xh;0,0.129xh&resize=980:*', false, null, '2026-06-06 05:19:47.851855+00'), 
('c425f808-72a9-471a-9eed-dbf5f9c98d13', 'Seated Cable Row', 'back', ARRAY['arms'], 'machine', 'Duduk di mesin kabel, tarik *handle* ke arah perut bagian bawah, rapatkan tulang belikat di posisi puncak gerakan.', 'https://static.strengthlevel.com/images/exercises/seated-cable-row/seated-cable-row-800.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('c48b247f-8717-4304-af5c-0c6b0c6ff9c5', 'Single-Arm Dumbbell Row', 'back', ARRAY['arms'], 'dumbbell', 'Sangga satu lutut dan tangan di bangku. Tarik dumbbell ke arah pinggul dengan lengan yang bebas, rasakan kontraksi di sisi punggung.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTXbHqtyxIQAF56Uw5_45mH2KKqgc5MyV4wZiDQaVdmQYXIDr2mXTfOTSo&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('c549354a-4ecb-4f46-990c-1d8601fa489d', 'Arnold Press', 'shoulders', ARRAY['arms'], 'dumbbell', 'Duduk memegang dumbbell setinggi dada dengan telapak tangan menghadap ke dada. Dorong ke atas sambil memutar telapak tangan menghadap ke depan.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnacLuxqfu3kv2V0g0X2CLieQlVOh0YRZJiRDqQwZXyxLZRpw25F1pROI&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('c63a3ee3-033a-474c-b720-2977d2766b69', 'Decline Bench Press', 'chest', ARRAY['shoulders','arms'], 'barbell', 'Berbaring di bangku menurun. Turunkan barbel ke bagian bawah dada, lalu dorong perlahan ke atas untuk fokus dada bawah.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS79SZViTi5PYfrKKPmS9r-cfOE6ZqT3rv64yOR8quiK_Q_RwXU', false, null, '2026-06-06 05:19:47.851855+00'), 
('c8b83dbc-a076-4ff3-9db0-d0436f3debcc', 'Reverse Pec Deck', 'shoulders', ARRAY['back'], 'machine', 'Duduk menghadap mesin pec deck. Pegang handle dan dorong lengan ke belakang untuk melatih otot bahu bagian belakang.', 'https://static.vecteezy.com/ti/vetor-gratis/p1/26751791-homem-fazendo-haltere-dobrado-sobre-peito-suportado-marcha-re-voa-vetor.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('ce685d02-2272-4cbe-896e-ffcdf0454b9f', 'Walking Lunge', 'legs', ARRAY['core'], 'dumbbell', 'Sambil memegang dumbbell, langkahkan kaki jauh ke depan, turunkan pinggul hingga lutut membentuk sudut siku-siku, ulangi bergantian.', 'https://trainingstation.co.uk/cdn/shop/articles/Lunges-movment_d958998d-2a9f-430e-bdea-06f1e2bcc835_900x.webp?v=1741687877', false, null, '2026-06-06 05:19:47.851855+00'), 
('d28fd34e-9e04-49bc-a284-a3fcc2a7b1c9', 'Hammer Curl', 'arms', ARRAY[]::text[], 'dumbbell', 'Pegang dumbbell dengan grip netral (telapak tangan saling berhadapan). Angkat ke atas bergantian tanpa mengayun tubuh.', 'https://liftmanual.com/wp-content/uploads/2023/04/dumbbell-hammer-curl.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('e45f7e79-8e58-474e-969a-2da1a8dacd69', 'Dumbbell Tricep Extension', 'arms', ARRAY[]::text[], 'dumbbell', 'Pegang satu dumbbell besar dengan dua tangan di belakang kepala, dorong lurus ke atas hingga lengan terentang penuh.', 'https://static.strengthlevel.com/images/exercises/seated-dumbbell-tricep-extension/seated-dumbbell-tricep-extension-800.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('f0ec9441-75ac-41e9-a05a-d436dfd7993c', 'Skullcrusher', 'arms', ARRAY[]::text[], 'barbell', 'Berbaring di bangku. Turunkan EZ bar atau barbel lurus ke arah dahi, lalu dorong kembali ke atas menggunakan trisep.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4MLh7RBbyyIUx4rhKIUzHaqHDEJNGHqHiZlKSIHOhRNSbqkKJqBuzVPl9&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('f2890e44-597e-4f7d-a709-8159d3d9a558', 'Preacher Curl', 'arms', ARRAY[]::text[], 'barbell', 'Duduk di bangku preacher, tempatkan lengan atas di bantalan. Angkat beban melengkung ke atas untuk mengisolasi bicep penuh.', 'https://liftmanual.com/wp-content/uploads/2023/04/ez-barbell-preacher-curl.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('f55ecfcb-7242-4c67-8f3a-8a15219b3deb', 'Hanging Leg Raise', 'core', ARRAY['arms'], 'bodyweight', 'Menggantung lurus di pull-up bar. Angkat kedua kaki lurus ke depan hingga rata dengan panggul (90 derajat) tanpa mengayun.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtfzJGc_WJ2hYXaxkjXn6C3s6sIb1nQEH5_RdAKd31zw&s=10', false, null, '2026-06-06 05:19:47.851855+00'), 
('f5de0fbc-1af2-4d27-8a37-b3aed27649d8', 'Pull Up', 'back', ARRAY['arms','core'], 'bodyweight', 'Gantungkan tubuh di pull-up bar. Tarik tubuh ke atas hingga dagu melewati bar, lalu turunkan tubuh dengan terkontrol dan tidak berayun.', 'https://liftmanual.com/wp-content/uploads/2023/04/pull-up.jpg', false, null, '2026-06-06 05:19:47.851855+00'), 
('fee1da93-746d-4b94-ba33-ca8c83ab6845', 'Russian Twist', 'core', ARRAY[]::text[], 'bodyweight', 'Duduk dengan kaki sedikit melayang. Condongkan badan 45 derajat ke belakang dan putar bahu ke sisi kanan lalu kiri.', 'https://trainingstation.co.uk/cdn/shop/articles/russian-twist-kettlebell_1_1600x.png?v=1758384047', false, null, '2026-06-06 05:19:47.851855+00');


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