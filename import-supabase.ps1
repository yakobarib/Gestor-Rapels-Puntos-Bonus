$SUPABASE_URL = "https://qiwacvjrytpgdqhwnkcj.supabase.co"
$ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpd2FjdmpyeXRwZ2RxaHdua2NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMzIwMDUsImV4cCI6MjA5NjcwODAwNX0.sZVVLa5Y69upY70dG9BUvIaIOX1zr7N1B5mEKfqWmxQ"

$headers = @{
    "apikey"        = $ANON_KEY
    "Authorization" = "Bearer $ANON_KEY"
    "Content-Type"  = "application/json"
    "Prefer"        = "return=representation"
}

function New-Consumo($alb, $imp) { @{ albaran = $alb; importe = $imp } }

$clientes = @(
    @{ nombre="ADNOTOR";               total=2360.00;  consumos=@() },
    @{ nombre="AGULLO";                total=1500.00;  consumos=@() },
    @{ nombre="AUTOCOLOR";             total=3048.00;  consumos=@(
        (New-Consumo "041589" 274.00),  (New-Consumo "093485" 1390.00)) },
    @{ nombre="AUTOLAVADOS";           total=4800.00;  consumos=@(
        (New-Consumo "038570" 450.00)) },
    @{ nombre="AUTOMAGIC";             total=671.00;   consumos=@() },
    @{ nombre="AUTOMOCION ISLA";       total=3414.00;  consumos=@(
        (New-Consumo "028155" 27.00),   (New-Consumo "034646" 12.64),
        (New-Consumo "041491" 109.91),  (New-Consumo "045681" 40.66),
        (New-Consumo "052297" 133.72),  (New-Consumo "053922" 112.98),
        (New-Consumo "057707" 1.95),    (New-Consumo "058696" 11.95),
        (New-Consumo "063811" 109.00),  (New-Consumo "068943" 159.00),
        (New-Consumo "071478" 28.52),   (New-Consumo "073723" 34.08),
        (New-Consumo "PEDIDO 14030" 59.90), (New-Consumo "102200" 7.20),
        (New-Consumo "103287" 58.95)) },
    @{ nombre="AUTOMOCION SAN FERNANDO"; total=0.00;  consumos=@(
        (New-Consumo "017144" 149.00)) },
    @{ nombre="AUTOS MARI";            total=0.00;    consumos=@() },
    @{ nombre="BARTOLME MARI";         total=2331.00; consumos=@(
        (New-Consumo "023469" 492.00)) },
    @{ nombre="BUMALI";                total=4195.00; consumos=@(
        (New-Consumo "050797" 109.91),  (New-Consumo "PEDIDO 8518" 2911.43),
        (New-Consumo "090506" 228.10),  (New-Consumo "ped12825" 109.76),
        (New-Consumo "101355" 175.00)) },
    @{ nombre="CAN RITA";              total=305.00;  consumos=@(
        (New-Consumo "024011" 250.40),  (New-Consumo "024007" 90.54)) },
    @{ nombre="CAS MOTOR";             total=415.00;  consumos=@(
        (New-Consumo "PEDIDO 10396" 679.00)) },
    @{ nombre="CLASS CAR SERVICE";     total=1105.00; consumos=@() },
    @{ nombre="COTORRO";               total=0.00;    consumos=@() },
    @{ nombre="CRUZ";                  total=3321.00; consumos=@(
        (New-Consumo "034318" 159.95),  (New-Consumo "040182" 14.00),
        (New-Consumo "042199" 98.00),   (New-Consumo "042559" 88.00),
        (New-Consumo "084896" 682.90),  (New-Consumo "085293" 99.59),
        (New-Consumo "096618" 18.00)) },
    @{ nombre="CURUNE";                total=1284.00; consumos=@() },
    @{ nombre="EIVISSA LAN";           total=0.00;    consumos=@() },
    @{ nombre="ESCUTIA";               total=2551.00; consumos=@(
        (New-Consumo "034814" 39.60),   (New-Consumo "038146" 50.00),
        (New-Consumo "071577" 99.00),   (New-Consumo "073347" 61.40),
        (New-Consumo "094475" 3090.00)) },
    @{ nombre="FORMENTERA MOTOR";      total=4942.00; consumos=@() },
    @{ nombre="FRANCISCO TORRES";      total=7917.00; consumos=@(
        (New-Consumo "MARGA" 7917.00)) },
    @{ nombre="FUSIAUTO";              total=3026.00; consumos=@(
        (New-Consumo "pedido 4586" 1418.00), (New-Consumo "043080" 319.00),
        (New-Consumo "062094" 359.00)) },
    @{ nombre="GARAGE 51";             total=2594.00; consumos=@(
        (New-Consumo "MARGA" 2594.00)) },
    @{ nombre="GARAGE MICHEL";         total=1335.00; consumos=@(
        (New-Consumo "PEDIDO 10398" 68.00), (New-Consumo "075155" 169.95),
        (New-Consumo "ped12836" 307.42),    (New-Consumo "100833" 121.00)) },
    @{ nombre="GARCIA SERVICE";        total=1877.00; consumos=@(
        (New-Consumo "053437" 6290.00)) },
    @{ nombre="GIGA MOTOR";            total=3003.00; consumos=@(
        (New-Consumo "031990" 461.00),  (New-Consumo "053466" 249.38),
        (New-Consumo "063748" 5830.00)) },
    @{ nombre="GUAYTOR";               total=6358.00; consumos=@(
        (New-Consumo "MARGA" 6358.00)) },
    @{ nombre="GUILLERMO";             total=2583.00; consumos=@(
        (New-Consumo "PEDIDO 15457" 3671.11)) },
    @{ nombre="IBINAUTCAR";            total=2308.00; consumos=@() },
    @{ nombre="IVENS";                 total=2204.00; consumos=@(
        (New-Consumo "YAKO" 2204.00)) },
    @{ nombre="KASSMI";                total=3415.00; consumos=@(
        (New-Consumo "075559" 47.00),   (New-Consumo "PEDIDO 10523" 208.00)) },
    @{ nombre="LAVACAR";               total=2824.00; consumos=@(
        (New-Consumo "073345" 310.00)) },
    @{ nombre="LE CERCLE";             total=2825.00; consumos=@(
        (New-Consumo "031875" 850.00)) },
    @{ nombre="LECHAB";                total=2730.00; consumos=@(
        (New-Consumo "PEDIDO 10521" 30.51), (New-Consumo "099098" 3217.28)) },
    @{ nombre="MANOLO";                total=2847.00; consumos=@(
        (New-Consumo "021440" 6490.00)) },
    @{ nombre="MARCELO LUIS SERRA";    total=1009.00; consumos=@(
        (New-Consumo "041861" 3590.00)) },
    @{ nombre="MARCOS MONTES";         total=3982.00; consumos=@(
        (New-Consumo "2025.258444" 899.00), (New-Consumo "024216" 221.00),
        (New-Consumo "026559" 184.95),      (New-Consumo "029495" 151.00),
        (New-Consumo "063741" 811.00)) },
    @{ nombre="MARI BALAFIA";          total=4226.00; consumos=@(
        (New-Consumo "056674" 197.00),  (New-Consumo "071394" 550.00),
        (New-Consumo "090485" 125.06),  (New-Consumo "ped12822" 262.77)) },
    @{ nombre="MARINES";               total=1885.00; consumos=@(
        (New-Consumo "143553" 1885.00)) },
    @{ nombre="MIGUEL ANGELO SILVA";   total=594.00;  consumos=@() },
    @{ nombre="MOTOR 34";              total=1959.00; consumos=@(
        (New-Consumo "025820" 219.00),  (New-Consumo "048832" 850.00),
        (New-Consumo "FACTURA LIBRE 261" 1140.00)) },
    @{ nombre="MOTOR SAN ANTONIO";     total=5029.00; consumos=@(
        (New-Consumo "023483" 403.72),  (New-Consumo "026902" 395.00),
        (New-Consumo "027234" 24.80),   (New-Consumo "038121" 309.25),
        (New-Consumo "050807" 19.66),   (New-Consumo "053092" 96.95),
        (New-Consumo "073715" 247.40),  (New-Consumo "075482" 12.00),
        (New-Consumo "094645" 77.90),   (New-Consumo "013838" 109.00),
        (New-Consumo "001199" 480.00),  (New-Consumo "103689" 160.00),
        (New-Consumo "110790" -109.00), (New-Consumo "116957" 56.42)) },
    @{ nombre="MOTOS SAN JOSE";        total=2568.00; consumos=@(
        (New-Consumo "034799" 318.95),  (New-Consumo "042432" 29.95),
        (New-Consumo "074293" 265.00),  (New-Consumo "013752" 1279.00)) },
    @{ nombre="MOVIL SANTA EULALIA";   total=2803.00; consumos=@(
        (New-Consumo "025431" 1613.72), (New-Consumo "071475" 850.00)) },
    @{ nombre="MULTICAR SERVICE";      total=2473.00; consumos=@(
        (New-Consumo "MARGA" 2473.00)) },
    @{ nombre="PETAXEL";               total=934.00;  consumos=@(
        (New-Consumo "GABRIEL" 934.00)) },
    @{ nombre="POLL";                  total=4678.00; consumos=@() },
    @{ nombre="PORTINATX";             total=2991.00; consumos=@(
        (New-Consumo "090495" 129.12),  (New-Consumo "ped12823" 162.14)) },
    @{ nombre="QUICK";                 total=0.00;    consumos=@() },
    @{ nombre="REPARAUTO";             total=831.00;  consumos=@(
        (New-Consumo "ped12831" 91.15)) },
    @{ nombre="REVYMAN";               total=6419.00; consumos=@(
        (New-Consumo "017098" 440.00)) },
    @{ nombre="RIOAUTO";               total=0.00;    consumos=@() },
    @{ nombre="ROIG";                  total=8905.00; consumos=@(
        (New-Consumo "037310" 8479.00)) },
    @{ nombre="RUBIU";                 total=2370.00; consumos=@(
        (New-Consumo "063745" 3400.00)) },
    @{ nombre="RUTASA";                total=4821.00; consumos=@(
        (New-Consumo "089142" 485.70),  (New-Consumo "100113" 458.36),
        (New-Consumo "101721" 114.95)) },
    @{ nombre="SAN CARLOS";            total=3332.00; consumos=@(
        (New-Consumo "GABRIEL" 1812.00),(New-Consumo "GABRIEL" 1520.00)) },
    @{ nombre="AUTOS FORMENTERA";      total=5428.00; consumos=@(
        (New-Consumo "108024" 970.00)) },
    @{ nombre="DOS TORRES";            total=3006.00; consumos=@() },
    @{ nombre="TALLER EUROPA";         total=3540.00; consumos=@(
        (New-Consumo "027282" 861.08)) },
    @{ nombre="TALLERES IBIZA CARS";   total=5670.00; consumos=@(
        (New-Consumo "050949" 299.85)) },
    @{ nombre="TECNOMOTOR";            total=1099.00; consumos=@(
        (New-Consumo "024042" 229.00),  (New-Consumo "037538" 2790.00)) },
    @{ nombre="TECNOMOVIL";            total=3251.00; consumos=@(
        (New-Consumo "052008" 2293.35)) },
    @{ nombre="YANEZ";            total=1883.00; consumos=@(
        (New-Consumo "073750" 240.00),  (New-Consumo "PEDIDO 10397" 395.00)) },
    @{ nombre="YOUNES";                total=2095.00; consumos=@() },
    @{ nombre="ARANCHEZ";              total=1095.00; consumos=@(
        (New-Consumo "MARGA" 1095.00)) },
    @{ nombre="CALA LLENYA VIP SERVICE"; total=3998.00; consumos=@(
        (New-Consumo "044457" 1320.00), (New-Consumo "049204" 505.00),
        (New-Consumo "056692" 200.00),  (New-Consumo "070621" 453.60),
        (New-Consumo "085957" 34.95),   (New-Consumo "107455" 715.00)) },
    @{ nombre="INSTITUTO MACABICH";    total=937.14;  consumos=@() }
)

$ok = 0; $fail = 0

foreach ($c in $clientes) {
    try {
        # Insert client
        $body = @{ nombre=$c.nombre; ejercicio=2026; notas="" } | ConvertTo-Json -Compress
        $res = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/clientes_rapel" -Method POST -Headers $headers -Body $body
        $cid = $res[0].id

        # INGRESO movement
        if ($c.total -gt 0) {
            $mov = @{ cliente_id=$cid; tipo="INGRESO"; albaran="RAPEL-2026"; importe=$c.total; fecha="2026-01-01"; notas="Rapel ejercicio 2026" } | ConvertTo-Json -Compress
            Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/movimientos_rapel" -Method POST -Headers $headers -Body $mov | Out-Null
        }

        # GASTO movements
        foreach ($g in $c.consumos) {
            $mov = @{ cliente_id=$cid; tipo="GASTO"; albaran=$g.albaran; importe=$g.importe; notas="" } | ConvertTo-Json -Compress
            Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/movimientos_rapel" -Method POST -Headers $headers -Body $mov | Out-Null
        }

        $ok++
        Write-Host "OK  $($c.nombre)" -ForegroundColor Green
    } catch {
        $fail++
        Write-Host "ERR $($c.nombre): $_" -ForegroundColor Red
    }
}

Write-Host "`n=== Importacion completa: $ok OK / $fail errores ===" -ForegroundColor Cyan
