$MaxDate = (Get-Date).AddDays(-45)
$Folder = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path


Write-Output "================================================================================"
Write-Output "Ejecutando script Housekeeping el: $(Get-Date)"
Write-Output "Carpeta:                           $($Folder)"
Write-Output "Borrado de archivos anteriores a:  $($MaxDate)" 

$DeletedSize = 0

Get-ChildItem -Path $Folder -File | 
Where-Object { $_.LastWriteTime -le $MaxDate } | 
ForEach-Object -Process { 
    Write-Output "Borrando $($_.Name)" 
	$DeletedSize = $DeletedSize + $_.length
    Remove-Item -LiteralPath $_.FullName -Force 
    }
	
$DeletedSize = ($DeletedSize / 1MB).ToString("0.0")

Write-Output "Tamaño de archivos borrados (MB):  $($DeletedSize)"
Write-Output "Fin del proceso el:                $(Get-Date)"
