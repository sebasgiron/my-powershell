# Procesar informe campa�a recobros ===========================================
param (
    $archivoDestino = ""
)

# Antes de ejecutar, copiar en el portapeles 
# los datos desde el bloc de notas de citrix
# Hacemos pausa para validarlo
Read-Host "Copia los datos del informe desde el bloc de notas y pulsa Enter para continuar"

$lineas = Get-Clipboard
$lineas = $lineas.Split("`r`n")

# incializar estado
$estado = 0

# Para obtener el primer elemento de la l�nea 
# (texto antes de la primera coma)
function Get-PrimerElemento($texto) {
    $dividir = $texto.Split(",")
    $dividir[0]
}

# Para obtener nombre de archivo por defecto (en el mes)
if ($archivoDestino -eq "") {
    $mes = Get-Date -Format "yyyyMMdd"
    $archivoDestino = "salida\santander-campa�a-recobros-" + $mes + ".csv"
}
"Archivo destino es " + $archivoDestino

# Para hacer Add-Content de forma segura por si aparece el error de 
# stream no disponible
function Add-Content-Safe($texto) {
	$isWritten = $false
	do {
		try {
			Add-Content -Path $archivoDestino -Value $texto -ErrorAction Stop
			$isWritten = $true
		}
		catch {
		}
	} until ( $isWritten )
}


# Bucle leer l�neas
$lineas_n = 0
foreach($linea in $lineas) {
    $primerElemento = Get-PrimerElemento($linea)
    switch($estado) {
		0 {
			# Comprobar el comienzo de los datos que tengo copiados
			if ($primerElemento -ne "Informe_Campa�a_Recobros") {
				$linea
				throw "La informaci�n del portapapeles no coincide con el formato esperado"
			}
			$estado = 1
		}	
        1 {
           # Buscar la secci�n correspondiente del informe
           if ($primerElemento -eq "DETALLE CAMPA�A RECOBROS") {
            $estado = 2
           } 
        }
        2 {
          # Leer l�nea de cabecera
          if ($primerElemento -eq "NOMBRE CAMPA�A") {
            $estado = 3
          } else {
				throw "La cabecera de la secci�n no coincide con lo esperado"
		  }
        }
        3 {
          # Exportar o pasar a siguiente secci�n del informe
          if ($primerElemento -eq "") 
            {
            $estado = 4
            } 
          else {
            Add-Content-Safe($linea)
            $lineas_n++
          }
        }
        4 {}
    }
}
"Lineas a�adidas: " + $lineas_n
"Finalizado OK"