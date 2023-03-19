Write-Output "================================================================================"
Write-Output "Ejecutando script Housekeeping el: $(Get-Date)"

$continuar = 0
try {
	New-PSDrive -Name "RemDownloads" -PSProvider "FileSystem" -Root "\\ad.somosazierta.es\DFS\Perfiles\u00003.V6\Downloads" -ErrorAction Stop
	$continuar = 1
}
catch {
	"No fue posible asignar la unidad RemDownloads. El script no puede continuar."
	Write-Output "Error en asignación de la carpeta RemDownloads"
}

if ($continuar -eq 1) {

cd RemDownloads:\

$MaxDate = (Get-Date).AddDays(-45)

Write-Output "Carpeta:                           RemDownloads"
Write-Output "Borrado de archivos anteriores a:  $($MaxDate)" 

$DeletedSize = 0

Get-ChildItem -File | 
Where-Object { $_.LastWriteTime -le $MaxDate } | 
ForEach-Object -Process { 
    Write-Output "Borrando $($_.Name)" 
	$DeletedSize = $DeletedSize + $_.length
    Remove-Item -LiteralPath $_.FullName -Force 
    }
	
$DeletedSize = ($DeletedSize / 1MB).ToString("0.0")
	
Write-Output "Tamaño de archivos borrados (MB):  $($DeletedSize)"
Write-Output "Fin del proceso el:                $(Get-Date)"

}
