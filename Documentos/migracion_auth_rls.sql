-- Migración de RLS para restringir el acceso a usuarios autenticados
-- (Supabase Auth), como parte de cerrar la app a un grupo cerrado de
-- compañeros. Ejecutar en el SQL Editor de Supabase.
--
-- IMPORTANTE — ventana de corte: en cuanto se ejecute este script, la
-- clave anónima (embebida en el HTML público de GitHub Pages) deja de
-- poder leer o escribir nada en las tablas de abajo. Cualquier versión
-- de la app sin login (la que esté publicada en ese momento) se queda
-- sin datos. Ejecutar este script y hacer el commit+push del código
-- nuevo (con pantalla de login) en el mismo momento, sin dejar pasar
-- tiempo entre medias.
--
-- Requiere que ya exista al menos una cuenta creada en Authentication
-- para poder probar el login justo después.

-- 1. Tablas en uso hoy por la app: sustituir cualquier política "to anon"
--    por la misma política pero "to authenticated". No se asume el nombre
--    de la política (puede variar entre tablas por cómo se creó cada una),
--    se recorre pg_policies y se reconstruye cada una tal cual pero con el
--    rol cambiado.
do $$
declare
  pol record;
  tabs text[] := array['clientes','baremo_puntos','consumo_anual',
                        'movimientos_rapel','movimientos_puntos','movimientos_bonus'];
begin
  -- Asegura RLS activo por si alguna tabla no lo tuviera.
  for pol in select unnest(tabs) as tbl loop
    execute format('alter table %I enable row level security', pol.tbl);
  end loop;

  for pol in
    select schemaname, tablename, policyname, cmd, qual, with_check
    from pg_policies
    where tablename = any(tabs)
      and 'anon' = any(roles)
  loop
    execute format('drop policy %I on %I', pol.policyname, pol.tablename);
    execute format(
      'create policy %I on %I for %s to authenticated using (%s) with check (%s)',
      pol.policyname, pol.tablename,
      case pol.cmd when 'ALL' then 'all' else pol.cmd end,
      coalesce(pol.qual, 'true'),
      coalesce(pol.with_check, 'true')
    );
  end loop;
end $$;

-- 2. Tablas legadas, ya sin uso desde la unificación de clientes: se
--    bloquean por completo (RLS activo, sin ninguna política) para que
--    ni siquiera un usuario autenticado pueda leerlas desde el cliente.
--    Sirven solo de copia de seguridad histórica en la base de datos.
do $$
declare
  pol record;
  tabs text[] := array['clientes_rapel','clientes_puntos','clientes_bonus'];
begin
  for pol in select unnest(tabs) as tbl loop
    execute format('alter table %I enable row level security', pol.tbl);
  end loop;

  for pol in select policyname, tablename from pg_policies where tablename = any(tabs) loop
    execute format('drop policy %I on %I', pol.policyname, pol.tablename);
  end loop;
end $$;
