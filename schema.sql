-- Jalankan di Supabase > SQL Editor
create table owner_cfg(id int primary key default 1 check(id=1), owner_id uuid not null);
create table documents(id text primary key, title text not null, category text, level text not null default 'rahasia' check(level in('umum','rahasia')), sort int default 0);
create table requests(
 id uuid primary key default gen_random_uuid(), name text not null, email text not null, org text not null,
 doc_ids text[] not null, status text not null default 'pending' check(status in('pending','approved','denied','revoked')),
 approved_docs text[] default '{}', expires_at timestamptz, secret_hash text not null, ip text, ua text,
 created_at timestamptz default now(), decided_at timestamptz);
create table access_log(id bigserial primary key, request_id uuid references requests(id) on delete set null, actor text not null, doc_id text, ip text, ua text, created_at timestamptz default now());

alter table owner_cfg enable row level security;
alter table documents enable row level security;
alter table requests enable row level security;
alter table access_log enable row level security;

create function public.is_owner() returns boolean language sql stable security definer set search_path=public as
$$ select exists(select 1 from owner_cfg where owner_id=auth.uid()) $$;

-- Publik hanya boleh membaca DAFTAR judul. Semua hal lain hanya lewat Edge Function (service role) atau pemilik.
create policy docs_read on documents for select to anon,authenticated using(true);
create policy docs_owner on documents for all to authenticated using(is_owner()) with check(is_owner());
create policy req_owner on requests for all to authenticated using(is_owner()) with check(is_owner());
create policy log_owner on access_log for select to authenticated using(is_owner());

-- Bucket PRIVAT: tanpa policy publik, hanya pemilik yang bisa kelola file
insert into storage.buckets(id,name,public) values('vault','vault',false) on conflict(id) do update set public=false;
create policy vault_owner on storage.objects for all to authenticated
 using(bucket_id='vault' and public.is_owner()) with check(bucket_id='vault' and public.is_owner());

insert into documents(id,title,category,level,sort) values
('bnsp','Sertifikat BNSP – Network Administrator Madya','Sertifikasi','umum',1),
('toefl','Sertifikat TOEFL (587)','Sertifikasi','umum',2),
('ijazah_s1','Ijazah S1 Teknologi Informasi','Pendidikan','umum',3),
('transkrip_s1','Transkrip Nilai S1','Pendidikan','umum',4),
('akreditasi_pt','Akreditasi BAN-PT Universitas BSI','Pendidikan','umum',5),
('akreditasi_prodi','Akreditasi Prodi Teknologi Informasi (LAM INFOKOM)','Pendidikan','umum',6),
('ektm','e-KTM Mahasiswa','Pendidikan','umum',7),
('ijazah_smk','Ijazah SMK','Pendidikan','umum',8),
('transkrip_smk','Daftar Nilai SMK','Pendidikan','umum',9),
('pkl','Surat Keterangan PKL – PT KAI','Pengalaman','umum',10),
('pasfoto','Pas Foto','Pribadi','umum',11),
('skck','SKCK','Legalitas','rahasia',12),
('bebas_narkoba','Surat Bebas Narkoba','Legalitas','rahasia',13),
('ktp','KTP','Identitas','rahasia',14),
('kk_akte','Kartu Keluarga & Akta Kelahiran','Identitas','rahasia',15),
('bpjs','Kartu BPJS Kesehatan','Identitas','rahasia',16);

-- SETELAH membuat user pemilik (lihat PANDUAN.md langkah 3), jalankan:
-- insert into owner_cfg(owner_id) select id from auth.users where email='bagasfath55@gmail.com';
