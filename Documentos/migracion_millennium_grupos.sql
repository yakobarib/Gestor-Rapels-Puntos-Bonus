-- Filtro de puntos por grupo Millennium (Mecánica / Carrocería) — según el
-- listado revisado por el jefe (Documentos/Grupos_Millenium_Maestro.xlsx).
-- Ejecutar en el SQL Editor de Supabase. No requiere ninguna coordinación
-- especial de tiempo con el push del código: las columnas nuevas tienen
-- default true (comportamiento actual, sin cambios) hasta que esta misma
-- migración las rellena, y el código de la app ya comprueba `=== false`
-- explícitamente — así que da igual si el código nuevo llega antes o
-- después de ejecutar esto.

-- 1. Columnas nuevas en clientes. Default true = comportamiento actual
--    (recibe todo) para cualquier cliente no listado aquí (clientes nuevos,
--    o pendientes de que el jefe los clasifique).
alter table clientes add column if not exists puntos_mecanica boolean not null default true;
alter table clientes add column if not exists puntos_carroceria boolean not null default true;

-- 2. Relleno para los 77 clientes ya clasificados, buscando por codigo_erp
--    normalizado (sin ceros a la izquierda) para que dé igual si en clientes
--    está guardado como "375" o "0375".
update clientes c set
  puntos_mecanica = v.mecanica,
  puntos_carroceria = v.carroceria
from (values
  ('5155', true, true),
  ('0463', true, false),
  ('0647', true, false),
  ('0368', true, false),
  ('1380', true, true),
  ('4055', true, true),
  ('3020', true, true),
  ('1580', true, false),
  ('7608', true, false),
  ('2350', true, false),
  ('0545', true, true),
  ('3047', true, false),
  ('1240', true, true),
  ('0338', true, true),
  ('1393', true, false),
  ('0337', true, false),
  ('1341', true, false),
  ('1078', true, true),
  ('3058', true, false),
  ('5087', true, false),
  ('3003', true, false),
  ('2064', true, false),
  ('1661', true, false),
  ('0630', true, false),
  ('1252', true, false),
  ('1308', true, false),
  ('3146', true, true),
  ('5122', true, false),
  ('0516', true, false),
  ('1250', true, false),
  ('0405', true, false),
  ('0262', true, false),
  ('4148', true, true),
  ('4010', true, false),
  ('0779', true, false),
  ('4698', true, false),
  ('0540', true, false),
  ('0789', true, false),
  ('3069', true, false),
  ('3026', true, true),
  ('4044', true, false),
  ('2229', true, false),
  ('1286', true, true),
  ('1573', true, false),
  ('4043', true, false),
  ('1295', true, false),
  ('1873', true, false),
  ('0568', true, true),
  ('4621', false, true),
  ('1202', true, false),
  ('4106', true, false),
  ('0417', true, true),
  ('0607', true, true),
  ('1246', true, false),
  ('5019', true, false),
  ('1337', true, false),
  ('0825', true, false),
  ('1054', true, true),
  ('2349', true, false),
  ('0624', true, false),
  ('0682', true, false),
  ('0723', false, true),
  ('1979', true, false),
  ('0365', true, false),
  ('3018', true, true),
  ('0381', true, true),
  ('0604', false, true),
  ('0704', true, false),
  ('0685', true, false),
  ('0718', true, false),
  ('3025', true, false),
  ('1275', true, true),
  ('1324', true, false),
  ('2336', true, false),
  ('1921', true, false),
  ('3041', true, true),
  ('0558', true, false)
) as v(codigo, mecanica, carroceria)
where regexp_replace(c.codigo_erp, '^0+', '') = regexp_replace(v.codigo, '^0+', '');

-- 3. Verificación: cuántas filas del listado (77) se han emparejado de
--    verdad con un cliente real. Si sale menos de 77, hay códigos del
--    Excel que no existen (o no coinciden) en clientes.codigo_erp.
select count(*) as clientes_actualizados
from clientes c
join (values
  ('5155'),('0463'),('0647'),('0368'),('1380'),('4055'),('3020'),('1580'),('7608'),('2350'),
  ('0545'),('3047'),('1240'),('0338'),('1393'),('0337'),('1341'),('1078'),('3058'),('5087'),
  ('3003'),('2064'),('1661'),('0630'),('1252'),('1308'),('3146'),('5122'),('0516'),('1250'),
  ('0405'),('0262'),('4148'),('4010'),('0779'),('4698'),('0540'),('0789'),('3069'),('3026'),
  ('4044'),('2229'),('1286'),('1573'),('4043'),('1295'),('1873'),('0568'),('4621'),('1202'),
  ('4106'),('0417'),('0607'),('1246'),('5019'),('1337'),('0825'),('1054'),('2349'),('0624'),
  ('0682'),('0723'),('1979'),('0365'),('3018'),('0381'),('0604'),('0704'),('0685'),('0718'),
  ('3025'),('1275'),('1324'),('2336'),('1921'),('3041'),('0558')
) as v(codigo) on regexp_replace(c.codigo_erp, '^0+', '') = regexp_replace(v.codigo, '^0+', '');
