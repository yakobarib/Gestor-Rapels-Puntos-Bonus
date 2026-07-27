-- PASO 3 de la unificación de clientes.
-- Corrige un fallo detectado al probar la migración: usar "¿tiene movimientos?"
-- para decidir si un cliente pertenece a un panel deja fuera a los clientes que
-- legítimamente no tienen ningún movimiento todavía (ej. de alta en Rapel con
-- 0€ inicial y sin consumo, o un cliente de Puntos nunca usado). Se añaden tres
-- columnas de pertenencia explícita, independientes de si hay movimientos.
alter table clientes add column if not exists en_rapel  boolean not null default false;
alter table clientes add column if not exists en_puntos boolean not null default false;
alter table clientes add column if not exists en_bonus  boolean not null default false;
