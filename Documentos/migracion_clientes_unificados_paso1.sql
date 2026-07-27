-- PASO 1 de la unificación de clientes (Rapel + Puntos + Bonus en una sola tabla).
-- Ejecutar en el SQL Editor de Supabase. Después de esto, Claude ejecuta la
-- migración de datos vía REST; cuando confirme que ha ido bien, se ejecuta el
-- PASO 2 (migracion_clientes_unificados_paso2.sql) para restaurar las claves
-- foráneas apuntando ya a la tabla nueva.

-- 1. Tabla unificada de clientes.
--    - codigo_erp: heredado de clientes_puntos, usado para el emparejamiento
--      automático de la importación mensual.
--    - ejercicio: heredado de clientes_rapel (año fiscal).
--    - bloqueo: columna nueva dedicada al bloqueo de Rapel (antes vivía
--      codificado dentro de "notas" como un bloque __BLQ__{...}__BLQ__; se
--      separa para que no se mezcle con las notas normales de un cliente
--      compartido entre paneles).
create table clientes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  codigo_erp text,
  ejercicio int,
  notas text default '',
  bloqueo text,
  created_at timestamptz default now()
);

-- 2. Permisos: misma política abierta para "anon" que ya tienen las demás tablas.
alter table clientes enable row level security;
create policy "anon full access" on clientes for all to anon using (true) with check (true);

-- 3. Quitar las claves foráneas actuales de movimientos_rapel/puntos/bonus hacia
--    las tablas viejas de clientes, para poder re-apuntar "cliente_id" libremente
--    durante la migración de datos (si no, cualquier UPDATE que ponga un id de la
--    tabla nueva "clientes" fallaría por violar la FK antigua).
do $$
declare r record;
begin
  for r in
    select conname, conrelid::regclass as tbl from pg_constraint
    where confrelid in ('clientes_rapel'::regclass, 'clientes_puntos'::regclass, 'clientes_bonus'::regclass)
      and contype = 'f'
  loop
    execute format('alter table %s drop constraint %I', r.tbl, r.conname);
  end loop;
end $$;

-- Nota: las tablas clientes_rapel / clientes_puntos / clientes_bonus NO se tocan
-- ni se borran en este paso — quedan como estaban, sirviendo de copia de
-- seguridad hasta que todo esté verificado funcionando.
