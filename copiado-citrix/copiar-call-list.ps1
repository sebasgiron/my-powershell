# Procesar Excel de call list =================================================
param (
    $archivoDestino = ""
)

# Primer paso es obtener desde citrix el nombre del archivo de call list
# Pausa para validarlo
Read-Host "Copia primero el nombre del archivo Citrix y pulsa Enter para continuar"
$archivoRemoto = Get-Clipboard

"El nombre del archivo remoto es: " + $archivoRemoto

# Ahora los datos desde el Excel de citrix
# Hacemos pausa para validarlo
Read-Host "Ahora copia los datos desde Excel y pulsa Enter para continuar"

$lineas = Get-Clipboard
$lineas = $lineas.Split("`r`n")

# incializar estado
$estado = 0

# Para obtener el primer elemento de la línea 
# (texto antes del primer tabulador)
function Get-PrimerElemento($texto) {
    $dividir = $texto.Split("`t")
    $dividir[0]
}

# Para obtener nombre de archivo por defecto (en el mes)
if ($archivoDestino -eq "") {
    $mes = Get-Date -Format "yyyyMMdd"
    $archivoDestino = "salida\santander-call-list-" + $mes + ".txt"
}
"Archivo destino es " + $archivoDestino

# Para saber si el archivo de destino existe o no
# y por tanto si tengo que añadir la línea de cabecera
if (Test-Path $archivoDestino) {
	$lineas_n_destino = (Get-Content -Path $archivoDestino | Measure-Object -Line).Lines
	"  Nº registros en archivo destino: " + $lineas_n_destino
	$flagAppend = $true
	"  Se añadirán datos al archivo destino"
} else {
	$lineas_n_destino = 0 
	$flagAppend = $false
	"  Se creará nuevo archivo destino"
}

try {

	$stream = New-Object System.IO.StreamWriter @($archivoDestino, $flagAppend)


	# Bucle leer líneas
	$lineas_n = 0
	foreach($linea in $lineas) {
		$primerElemento = Get-PrimerElemento($linea)
		switch($estado) {
			0 {
				# Comprobar el comienzo de los datos que tengo copiados
				if ($primerElemento -ne "record_id") {
					$linea
					throw "La información del portapapeles no coincide con el formato esperado"
				}
				$estado = 1
				if ($lineas_n_destino -eq 0) {
					$lineas_n++
					$stream.WriteLine("archivo remoto`t" + $linea)
				} else {
					"  Omitida cabecera en archivo destino"
				}
			}	
			1 {
			  # Se copia todo hasta final del archivo
				$stream.WriteLine($archivoRemoto + "`t" + $linea)
				$lineas_n++
				if($lineas_n % 500 -eq 0) {
					"  Copiadas: " + $lineas_n
				}
			 }
		}
	}
	"Lineas añadidas: " + $lineas_n
	"Finalizado OK"

} finally {
	$stream.close()
}
