-- Filtro de puntos por grupo Millennium (Mecánica / Carrocería) — según el
-- listado revisado por el jefe (Documentos/grupos_millenium_MAESTRO.xlsx).
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
  ('0463', true, true),
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
  ('4621', true, true),
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
  ('0723', true, true),
  ('1979', true, false),
  ('0365', true, false),
  ('3018', true, true),
  ('0381', true, true),
  ('0604', true, true),
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

-- 4. Casos especiales resueltos a mano: 10 códigos del Excel no coincidieron
--    en el paso 2 (67/77). Revisados uno a uno contra clientes reales:
--    - 5 clientes ya existían en la app pero nunca habían tenido codigo_erp
--      (nunca les llegó una importación de Puntos): AUTOMAGIC, REPARAUTO,
--      INSTITUTO MACABICH, MASTER AUTOS, QUIÑOBUS. Se les asigna el código
--      del Excel directamente por id, y de paso se clasifican.
--    - GARCIA SERVICE: el Excel decía 1661, pero el código real en la app
--      es 1961 (typo en el Excel del jefe) — se clasifica por su código real.
--    - CRUZ MOTOR: el Excel decía 1240 (código antiguo, antes de que el ERP
--      renumerara al cliente al pasar a "Cruz Motor Hijos S.L."); no existe
--      ninguna fila huérfana con codigo_erp=1240 (comprobado), así que es
--      un único cliente activo con código actual 0769 — se clasifica por
--      su código real, sin nada que fusionar.
--    - FLASHAUTO, JOSE FELIZ PEDROSA, VICTOR GABRIEL MENDOZA: no existen
--      todavía como clientes en la app (nunca tuvieron consumo de Puntos).
--      No requieren ninguna acción — se crearán solos, sin clasificar
--      (puntos completos por defecto), en cuanto llegue su primer consumo.
update clientes set codigo_erp = '0368', puntos_mecanica = true,  puntos_carroceria = false where id = '7d72e6e0-7b2e-49bd-96ca-8999d9296e57'; -- AUTOMAGIC
update clientes set codigo_erp = '4621', puntos_mecanica = true,  puntos_carroceria = true  where id = '3833ec93-54f9-4fcc-a167-cd433d821a30'; -- REPARAUTO
update clientes set codigo_erp = '1308', puntos_mecanica = true,  puntos_carroceria = false where id = '8aabb8e8-e7d0-424f-bce2-b1c35151a804'; -- INSTITUTO MACABICH
update clientes set codigo_erp = '0779', puntos_mecanica = true,  puntos_carroceria = false where id = '3f555d1e-3461-471d-88b2-e9b31c9ebd74'; -- MASTER AUTOS
update clientes set codigo_erp = '0568', puntos_mecanica = true,  puntos_carroceria = true  where id = 'cce3b43d-fba2-48a6-b47b-c6479e3c39a1'; -- QUIÑOBUS
update clientes set puntos_mecanica = true, puntos_carroceria = false where id = 'e7414b05-be6b-4da2-8508-ba0b86b9a083'; -- GARCIA SERVICE (código real 1961)
update clientes set puntos_mecanica = true, puntos_carroceria = true  where id = '114558de-3ce7-4662-b711-5c8b8f62b717'; -- CRUZ MOTOR (código real 0769)

-- 5. Corrección posterior del jefe (tras revisar la comparativa con el
--    cálculo manual de la compañera): Reparauto, Taller Dos Torres/Oskar
--    Franch y Taller Rubiu SÍ tenían derecho a puntos de mecánica — la
--    versión anterior del Excel los marcaba por error como "solo
--    carrocería". Quedan igual que la mayoría de clientes: puntúan en todo.
--    (Los VALUES de las secciones 2 y 4 de arriba ya se actualizaron a
--    juego con esto; estas 3 líneas son el UPDATE real a ejecutar porque
--    esos clientes ya se habían migrado con el valor antiguo.)
update clientes set puntos_mecanica = true, puntos_carroceria = true where id = '3833ec93-54f9-4fcc-a167-cd433d821a30'; -- REPARAUTO
update clientes set puntos_mecanica = true, puntos_carroceria = true where codigo_erp in ('0723','00723'); -- TALLER DOS TORRES / OSKAR FRANCH
update clientes set puntos_mecanica = true, puntos_carroceria = true where codigo_erp in ('0604','00604'); -- TALLER RUBIU

-- 6. Segunda correccion tras revisar el ERP: Autocolor (0463) SI produce
--    puntos de carroceria ademas de mecanica (el Excel del jefe lo tenia
--    marcado como "solo mecanica" por error). El VALUES de la seccion 2
--    ya se actualizo a juego; esta linea es el UPDATE real porque ya se
--    habia migrado con el valor antiguo.
update clientes set puntos_mecanica = true, puntos_carroceria = true where codigo_erp in ('0463','00463'); -- AUTOCOLOR
