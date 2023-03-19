﻿# Procesar informe de horas staff =============================================
param (
    $archivoDestino = ""
)

# Antes de ejecutar, copiar en el portapeles 
# los datos desde el bloc de notas de citrix
# Hacemos pausa para validarlo
Read-Host "Copia los datos del informe desde el bloc de notas y pulsa Enter para continuar"

$lineas = Get-Clipboard
$lineas = $lineas.Split("`r`n")

# incializar estdao
$estado = 0

# Para obtener el primer elemento de la línea 
# (texto antes de la primera coma)
function Get-PrimerElemento($texto) {
    $dividir = $texto.Split(",")
    $dividir[0]
}

# Para obtener nombre de archivo por defecto (en el mes)
if ($archivoDestino -eq "") {
    $mes = Get-Date -Format "yyyyMMdd"
    $archivoDestino = "salida\santander-horas-ares-staff-" + $mes + ".csv"
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

# Bucle leer líneas
$lineas_n = 0
foreach($linea in $lineas) {
    $primerElemento = Get-PrimerElemento($linea)
    switch($estado) {
		0 {
			# Comprobar el comienzo de los datos que tengo copiados
			if ($primerElemento -ne "Informe Horas Staff") {
				throw "La información del portapapeles no coincide con el formato esperado"
			}
			$estado = 1
		}	
        1 {
           # Buscar la sección correspondiente del informe
           if ($primerElemento -eq "Resumen por Agente y dia") {
            $estado = 2
           } else {
			   $primerElemento
           
           }
        }
        2 {
          # Leer línea de cabecera
          if ($primerElemento -eq "GRUPO") {
            $estado = 3
            }
        }
        3 {
          # Exportar o pasar a siguiente sección del informe
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
"Lineas añadidas: " + $lineas_n
"Finalizado OK"


