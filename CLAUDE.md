# Gestor de Rapels y Puntos — Recambios Ibiza

## Descripción
Aplicación web single-page para gestionar rapels de herramienta, puntos de fidelización y bonus de clientes. Desarrollada para uso interno de Recambios Ibiza (Adeivissa).

## Estructura del proyecto
- `APP/index.html` — archivo principal (única fuente de verdad)
- `index.html` — copia sincronizada para GitHub Pages (se sobreescribe antes de cada commit)
- `APP/` — carpeta de desarrollo
- `Documentos/` — documentación interna

**IMPORTANTE:** Siempre editar `APP/index.html`. Antes de cada commit, copiar a `index.html` raíz:
```powershell
Copy-Item "APP\index.html" "index.html" -Force
```

## Despliegue
- **GitHub Pages:** https://yakobarib.github.io/Gestor-Rapels-Puntos-Bonus/
- Repo: https://github.com/yakobarib/Gestor-Rapels-Puntos-Bonus
- Usuario git: yakobarib
- CDN propagation: ~5-10 min tras push (Ctrl+Shift+R en el navegador para forzar)

## Base de datos — Supabase JS v2 (CDN)
Tablas:
- **`clientes`** (tabla única compartida por Rapel/Puntos/Bonus, ver sección dedicada abajo): `id`, `nombre`, `codigo_erp` (oculto, usado para emparejar el cliente del ERP en la importación mensual), `ejercicio` (año fiscal, rapel), `notas`, `bloqueo` (oculto, metadatos de bloqueo de Rapel), `en_rapel`/`en_puntos`/`en_bonus` (booleanos de pertenencia a cada panel, independientes de si hay movimientos).
- `movimientos_rapel`, `movimientos_puntos`, `movimientos_bonus` — cada uno con `cliente_id` apuntando a `clientes.id`.
- `consumo_anual`
- `baremo_puntos` (marca, familia, desc_marca, desc_familia, categoria: N2/N3/PF/AA/CR) — baremo Marca/Familia → categoría de puntos, editable desde la app. Migración inicial en `Documentos/migracion_baremo_puntos.sql`.
- **Tablas antiguas `clientes_rapel`/`clientes_puntos`/`clientes_bonus`**: ya no las usa la app (migradas a `clientes`), se conservan sin borrar como copia de seguridad histórica.

## Arquitectura de la app
Single HTML file — todo el HTML, CSS y JS inline.

### Datos en memoria (`db`)
```js
db = { rapels: [], puntos: [], bonus: [], consumo: [], baremo: [], clientes: [] }
```
Cada cliente tiene array `movimientos` embebido. `db.baremo` es el baremo Marca/Familia → categoría (tabla `baremo_puntos`), cargado una vez en `load()`. `db.clientes` es el listado completo de la tabla unificada `clientes` (todos los paneles), usado para renombrar y para el emparejamiento por `codigo_erp`. `db.rapels`/`db.puntos`/`db.bonus` se cargan con `sb.from('clientes').select('*, movimientos_X(*)').eq('en_X', true)` — el filtro es la columna de pertenencia (`en_rapel`/`en_puntos`/`en_bonus`), **no** la presencia de movimientos (un cliente puede pertenecer a un panel con cero movimientos, p.ej. de alta con 0€ inicial).

### Funciones clave
- `rStats(r)` → `{ingreso, gasto, saldo, pct}` — stats rapel
- `pStats(p)` → `{ganado, canjeado, saldo, ajuste}` — stats puntos
- `bStats(b)` → `{ganado, canjeado, saldo}` — stats bonus
- `parseBloq(bloqueo)` → `{bloqueado, fecha, motivo, por}` — parsea el campo `cliente.bloqueo` (columna dedicada, ya no vive dentro de `notas`)
- `eur(n)` → `"1.234,56 €"` — formatea euros
- `pts(n)` → `"1.234 pts"` — formatea puntos
- `ptsEur(n)` → conversión pts→€ (1 pt = 1 €, constante `PTS_VALUE`)
- `checkDesktop()` → devuelve false + alert si ancho < 1024px (guard para acciones de escritura)
- `renderAll()` → re-renderiza todo
- `printDoc(html)` → abre ventana de impresión

### Formatters de impresión
- `printHeader(cliente, titulo, subtitulo)` → HTML cabecera página de impresión
- `buildMonthlyPtsTable(movimientos, year, maxMes)` → tabla mensual por categoría para PDF puntos
- `buildPuntosPrintPage(p)` → página completa de impresión de un cliente de puntos

## Reglas de negocio
- **Rapel:** en euros. Puede bloquearse (metadatos en campo `notas`). Tiene % de uso.
- **Puntos:** 1 punto = 1 €. Se acumulan por categoría (Neumáticos, Pastillas, Alt./Arr., Carrocería).
- **Bonus:** en puntos directamente (no en euros). 1 € invertido = 2 pts ganados (referencia, no se aplica conversión en la app — los importes ya se introducen en pts).
- Todos los datos se introducen y muestran en **MAYÚSCULAS**.
- Cada acción (añadir, editar, eliminar, bloquear, desbloquear) requiere campo obligatorio de **usuario** que la realiza.

## Modo solo lectura en móvil
- CSS `.edit-only` → `display:none` en `@media(max-width:1023px)`
- `checkDesktop()` → guard al inicio de todas las funciones que abren modales de escritura
- En móvil solo se puede visualizar, no modificar.

## Responsive / mobile
- `@media(max-width:768px)`: nav scroll horizontal, padding reducido, tablas con scroll horizontal (`tbl-wrap`), drawer ancho 100vw
- `@media(max-width:480px)`: KPIs en 2 columnas
- Columnas numéricas: `class="num"` → `text-align:right`
- Celdas de tabla: `white-space:nowrap` en mobile para evitar que € o pts salten de línea

## Flujo de impresión PDF
Cada panel tiene dos tipos de impresión:
1. **Por cliente** (desde el cajón lateral): `printClientRapel()`, `printClientPuntos()`, `printClientBonus()`
2. **Masiva** (todos los clientes): función de impresión bulk

Las páginas de impresión incluyen "galletas" (stat cards) de resumen al inicio, con estilos CSS inline (páginas standalone).

## Importación mensual de consumo (Puntos)
- Botón "Importar Consumo" en el panel Puntos abre `ovlImportConsumo`. Diseñado para que lo use cualquier compañero sin tener que tomar decisiones: subir fichero → revisar totales → confirmar. Sin desplegables ni selección de clientes.
- Dos tipos de fichero (selector "Tipo de fichero"): **Consumo mensual de clientes** (fichero ERP "VENTAS CLIENTE-FAMILIAS", `.xls`/`.xlsx`, el uso habitual mensual) y **Baremo Marca/Familia → Categoría** (carga/actualiza `baremo_puntos`, solo cuando cambie el baremo).
- El campo "Periodo" se preselecciona automáticamente al **mes anterior al actual** (`prevMonthStr()`), editable con el selector de mes.
- Parsing 100% en el navegador con SheetJS (`XLSX.read`), sin backend. Funciones clave: `parseImportFile()`, `procesarFicheroConsumo()`, `procesarFicheroBaremo()`.
- El consumo mensual se agrega por cliente y categoría y genera **un único movimiento GANADO** por cliente/mes (mismo formato que la entrada manual), usando las funciones compartidas `categoriasPuntos()`/`categoriasTotal()`/`categoriasNotas()` (también usadas por la calculadora manual `buildCalcNotas()`/`getCalcTotal()`).
- **Emparejamiento cliente ERP↔app 100% automático y opaco**, solo por `codigo_erp` oculto (`matchClienteAppInitial()`): código ya visto → suma puntos a ese cliente; código nunca visto → crea cliente nuevo silenciosamente (nombre ERP sin sufijos legales vía `stripLegalSuffix()`), sin distinguirlo visualmente de uno reconocido. Nunca se fusiona por similitud de nombre (dos empresas con nombre parecido pero CIF/código distinto deben quedar separadas) — así se evita mezclar entes distintos.
- Caso especial ya resuelto (ejemplo real): un cliente puede cambiar de razón social en el ERP (p.ej. "Dos Torres" → "Oskar Franch") conservando el mismo `codigo_erp`; una vez emparejado una vez, sigue funcionando aunque cambie el nombre.
- Líneas Marca/Familia sin categoría en el baremo simplemente no puntúan ese mes (sin aviso ni pantalla de revisión) — el baremo se mantiene aparte, subiendo el Excel actualizado cuando haga falta.
- Normalización de códigos (`normCode()`) necesaria porque el ERP mezcla formatos numéricos/texto para el mismo código de familia (`'01'`, `1`, `01`).
- **Reimportar un periodo ya importado nunca suma puntos**: los movimientos se identifican por `referencia = 'IMPORT-<periodo>'`; al confirmar, si ya existe un movimiento con esa referencia para un cliente, se **sobrescribe** (nueva cifra, sea igual, mayor o menor) en vez de crear uno nuevo, y si el nuevo total es 0 se borra. Antes de confirmar, si detecta que ese periodo ya se importó, muestra un `confirm()` explicando que se sobrescribirá (no se sumará) y pide aceptar o cancelar.

## Tabla de clientes unificada (Rapel · Puntos · Bonus)
- Rapel, Puntos y Bonus comparten una única tabla `clientes` — el mismo negocio real es **una sola fila**, con un único `nombre`, en vez de tres registros independientes (como era antes de esta migración).
- Pertenencia a cada panel: columnas `en_rapel`/`en_puntos`/`en_bonus` (booleanas), no la presencia de movimientos — así un cliente de alta con 0€/0 puntos y sin movimientos sigue apareciendo en su panel.
- **Renombrar cliente**: botón en el cajón lateral de cada panel (`openRenombrar(tipo)`/`saveRenombrar()`) — actualiza `clientes.nombre` y refresca todas las apariciones en `db.rapels`/`db.puntos`/`db.bonus`/`db.clientes` a la vez (un cliente compartido se renombra en todos los paneles donde aparezca de un solo golpe).
- **Eliminar cliente**: `deleteClientMovimientos(clienteId, movTabla)` borra solo los movimientos del panel desde el que se elimina y pone a `false` la columna `en_<panel>` correspondiente; si tras esto el cliente no tiene ya actividad en ningún sistema, se borra también su fila de `clientes` (evita clientes fantasma). Eliminar desde un panel **nunca** afecta a la actividad del cliente en los otros dos.
- **Alta de cliente nuevo — detección de duplicados**: el campo de nombre (`qaNewNombre`) lleva un `<datalist>` (`populateClientesDatalist()`) con todos los clientes existentes, para autocompletar mientras se escribe. Al guardar, `resolverClienteNuevo(nombre, flagPanel, camposExtra)` compara el nombre contra `db.clientes` con `fuzzyMatchCliente()` (normaliza mayúsculas/acentos, compara por inclusión de subcadena, p.ej. "COTORRO" ↔ "TALLER COTORRO"): coincidencia exacta → vincula sin preguntar; coincidencia parecida → pregunta con `confirm()` si es el mismo cliente (usa el existente y activa el `en_<panel>` correspondiente) o si hay que crear uno nuevo separado; sin coincidencia → crea directamente. Sustituye a los inserts directos de las 3 ramas de `saveQuickAction`.
- Migración ejecutada: `Documentos/migracion_clientes_unificados_paso1.sql` (tabla `clientes` + RLS + quitar FKs viejas), migración de datos vía REST (reconciliación de las 3 tablas antiguas por nombre, con casos especiales resueltos a mano — ver más abajo), `paso2.sql` (nuevas FKs de `movimientos_*` hacia `clientes`), `paso3.sql` (columnas `en_rapel`/`en_puntos`/`en_bonus` + backfill).
- Casos especiales de la reconciliación (por si se repiten patrones parecidos en el futuro): "Dos Torres" renombrado a "Oskar Franch" (mismo `codigo_erp`, cambio de razón social); "Eivissa Lan" y "Giles Ibiza" son el mismo negocio real pero se mantienen como dos clientes separados a propósito (con nota cruzada interna en `notas`); "Turbocar" y "Autos Turbo" son clientes distintos pese al nombre parecido.

## Historial de cambios recientes
- KPIs del dashboard renombrados y coloreados (blancos=totales, rojo=consumos, verde/rojo dinámico=saldos)
- Filtro "Saldo bloqueado" en panel Rapel
- Panel lateral (drawer) funcional en Rapel igual que en Puntos y Bonus
- Campo obligatorio "usuario" en todas las operaciones de escritura
- Inputs siempre en MAYÚSCULAS
- Modo solo-lectura completo en móvil
- Bonus: display completo en `pts()` (ya no usa `eur()` en ningún sitio del panel Bonus)
- Galletas de resumen en impresión de Rapel y Bonus
- Tabla de evolución de consumo: celdas con `white-space:nowrap` y panel con `overflow-x:auto`
- Importación mensual de consumo (Marca/Familia → Puntos): nueva tabla `baremo_puntos`, campo `codigo_erp` en `clientes_puntos`, asistente de importación 100% automático y sin decisiones manuales (ver sección dedicada arriba)
- Primera importación real ejecutada (enero 2026): 73 clientes, 6.532 puntos, 3 clientes nuevos creados (VISANJUL, AUTOS TURBO, GILES IBIZA como entidad separada de EIVISSA LAN)
- Unificación de la tabla de clientes (Rapel/Puntos/Bonus → `clientes` compartida) + función "Renombrar cliente" (ver sección dedicada arriba)
- Preview local movido al puerto 3077 (`.claude/launch.json`) para evitar colisión con el puerto 3000, usado también por otros proyectos locales del usuario (Gestión de Stocks)
- Detección de clientes duplicados al dar de alta (autocompletar + sugerencia "¿es el mismo cliente?") — ver sección dedicada arriba
