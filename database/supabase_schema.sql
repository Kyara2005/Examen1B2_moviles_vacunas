-- Script sencillo para Supabase
-- Ejecutar en SQL Editor.

create extension if not exists "uuid-ossp";

create table if not exists public.sectores (
  id uuid primary key default uuid_generate_v4(),
  nombre text not null,
  descripcion text,
  coordinador_id uuid null,
  created_at timestamp with time zone default now()
);

create table if not exists public.usuarios (
  id uuid primary key references auth.users(id) on delete cascade,
  cedula text not null,
  nombres text not null,
  apellidos text not null,
  telefono text,
  correo text not null unique,
  rol text not null check (rol in ('coordinador_campana', 'coordinador_brigada', 'vacunador')),
  sector_id uuid references public.sectores(id),
  debe_cambiar_clave boolean default true,
  created_at timestamp with time zone default now()
);

alter table public.sectores
add constraint sectores_coordinador_fk
foreign key (coordinador_id) references public.usuarios(id);

create table if not exists public.vacunaciones (
  id uuid primary key default uuid_generate_v4(),
  propietario text not null,
  cedula text not null,
  telefono text,
  tipo_mascota text not null check (tipo_mascota in ('Perro', 'Gato')),
  nombre_mascota text not null,
  edad_aproximada text,
  sexo text check (sexo in ('Macho', 'Hembra')),
  vacuna text not null,
  observaciones text,
  imagen_url text,
  latitud double precision,
  longitud double precision,
  fecha date not null,
  hora text not null,
  usuario_id uuid not null references public.usuarios(id),
  sector_id uuid not null references public.sectores(id),
  sincronizado boolean default true,
  created_at timestamp with time zone default now()
);

-- Storage para fotos
insert into storage.buckets (id, name, public)
values ('vacunaciones', 'vacunaciones', true)
on conflict (id) do nothing;

-- RLS
alter table public.usuarios enable row level security;
alter table public.sectores enable row level security;
alter table public.vacunaciones enable row level security;

-- Usuarios pueden leer su propio perfil.
create policy "usuarios leen perfil propio"
on public.usuarios for select
using (auth.uid() = id);

-- Coordinador de campana administra usuarios.
create policy "campana administra usuarios"
on public.usuarios for all
using (
  exists (
    select 1 from public.usuarios u
    where u.id = auth.uid() and u.rol = 'coordinador_campana'
  )
);

-- Coordinador de brigada ve vacunadores de su sector.
create policy "brigada ve usuarios sector"
on public.usuarios for select
using (
  exists (
    select 1 from public.usuarios u
    where u.id = auth.uid()
    and u.rol = 'coordinador_brigada'
    and u.sector_id = usuarios.sector_id
  )
);

-- Sectores visibles para usuarios autenticados.
create policy "usuarios leen sectores"
on public.sectores for select
using (auth.uid() is not null);

-- Solo campana administra sectores.
create policy "campana administra sectores"
on public.sectores for all
using (
  exists (
    select 1 from public.usuarios u
    where u.id = auth.uid() and u.rol = 'coordinador_campana'
  )
);

-- Vacunador crea registros propios.
create policy "vacunador crea vacunaciones"
on public.vacunaciones for insert
with check (auth.uid() = usuario_id);

-- Vacunador ve y edita registros propios.
create policy "vacunador gestiona propios"
on public.vacunaciones for all
using (auth.uid() = usuario_id);

-- Coordinador de brigada gestiona registros de su sector.
create policy "brigada gestiona sector"
on public.vacunaciones for all
using (
  exists (
    select 1 from public.usuarios u
    where u.id = auth.uid()
    and u.rol = 'coordinador_brigada'
    and u.sector_id = vacunaciones.sector_id
  )
);

-- Coordinador de campana ve todo.
create policy "campana gestiona todo"
on public.vacunaciones for all
using (
  exists (
    select 1 from public.usuarios u
    where u.id = auth.uid() and u.rol = 'coordinador_campana'
  )
);

-- Politicas simples para fotos publicas.
create policy "usuarios suben fotos"
on storage.objects for insert
with check (bucket_id = 'vacunaciones' and auth.uid() is not null);

create policy "usuarios leen fotos"
on storage.objects for select
using (bucket_id = 'vacunaciones');
