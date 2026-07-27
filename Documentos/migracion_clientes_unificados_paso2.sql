-- PASO 2 de la unificación de clientes.
-- Ejecutar en el SQL Editor de Supabase SOLO después de que Claude confirme
-- que la migración de datos (remapeo de cliente_id) se ha completado y
-- verificado correctamente.

-- Restaura la integridad referencial: cliente_id de cada tabla de movimientos
-- pasa a apuntar a la nueva tabla "clientes" en vez de a las tres tablas viejas.
alter table movimientos_rapel  add constraint movimientos_rapel_cliente_id_fkey  foreign key (cliente_id) references clientes(id);
alter table movimientos_puntos add constraint movimientos_puntos_cliente_id_fkey foreign key (cliente_id) references clientes(id);
alter table movimientos_bonus  add constraint movimientos_bonus_cliente_id_fkey  foreign key (cliente_id) references clientes(id);
