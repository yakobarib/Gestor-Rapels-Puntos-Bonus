-- Migración para la importación mensual de consumo (Marca/Familia -> Puntos)
-- Ejecutar una sola vez en el SQL Editor de Supabase del proyecto.

-- 1. Campo interno (nunca mostrado en la interfaz) para emparejar el cliente
--    del fichero del ERP con el cliente ya existente en la app, de forma
--    estable aunque el nombre comercial cambie en el ERP.
alter table clientes_puntos add column if not exists codigo_erp text;

-- 2. Baremo Marca/Familia -> Categoría de puntos.
--    Categorías: N2 (2 pts/ud neumático 2ª marca), N3 (3 pts/ud neumático 1ª marca),
--    PF (2 pts/ud pastillas de freno), AA (2 pts/ud alternador/motor de arranque),
--    CR (10 pts / 100 € en carrocería).
create table if not exists baremo_puntos (
  id bigint generated always as identity primary key,
  marca text not null,
  familia text not null,
  desc_marca text,
  desc_familia text,
  categoria text not null check (categoria in ('N2','N3','PF','AA','CR')),
  created_at timestamptz default now(),
  unique (marca, familia)
);

-- 3. Permisos: esta tabla la lee/escribe la app directamente desde el navegador
--    con la misma anon key que usa para clientes_puntos / movimientos_puntos.
--    Aplica aquí la MISMA configuración de RLS que ya tengan esas tablas:
--
--    - Si clientes_puntos / movimientos_puntos NO tienen Row Level Security
--      activado, no lo actives tampoco en baremo_puntos (déjala igual de abierta).
--
--    - Si SÍ tienen RLS activado con políticas que permiten todo al rol "anon"
--      (select/insert/update/delete), replica esas mismas políticas aquí, por
--      ejemplo:
--
--      alter table baremo_puntos enable row level security;
--      create policy "anon full access" on baremo_puntos
--        for all to anon using (true) with check (true);
--
--    Sin esto, la app dará error de permisos (403/RLS) al intentar leer o
--    escribir el baremo desde el navegador.
