# Copiar CSV del día ===============================================
param (
	$fechaProceso = "",
	$rutaDestino = "G:\Unidades compartidas\Intercambio BI-Recobro\santander\informe-intradia-ares\entrada"
)

"Ruta destino es " + $rutaDestino

# Si no se ha especificado fecha, asignar la del día
if ($fechaProceso -eq "") {
	$fechaProceso = Get-Date -Format "yyyyMMdd"
}
"Fecha de proceso es " + $fechaProceso

"Copiando archivos con esta fecha de proceso:"
Get-ChildItem -Path salida\ -Filter *$fechaProceso.csv |
	Copy-Item -Destination $rutaDestino -PassThru |
	Get-ItemPropertyValue -Name "Name"
	
Get-ChildItem -Path salida\ -Filter *$fechaProceso.txt |
	Copy-Item -Destination $rutaDestino -PassThru |
	Get-ItemPropertyValue -Name "Name"
	
"Terminado OK"
