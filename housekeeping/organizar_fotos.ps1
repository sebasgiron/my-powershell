# Especifica la ruta de la carpeta con las fotograf�as
$rutaCarpeta = "D:\Users\Sebas\Dropbox\Cargas de c�mara"

# Obt�n todos los archivos en la carpeta
$archivos = Get-ChildItem -Path $rutaCarpeta -File

# Expresi�n regular para extraer el a�o del nombre del archivo
$patronFecha = "^(\d{4})-\d{2}-\d{2}.+"
$contadorArchivos = 0

foreach ($archivo in $archivos) {
    # Intenta hacer coincidir el patr�n de fecha en el nombre del archivo
    $coincidencia = $archivo.BaseName -match $patronFecha

    if ($coincidencia) {
        # Extrae el a�o de la primera captura del patr�n
        $a�o = $Matches[1]

        # Define la ruta de la subcarpeta del a�o
        $rutaSubcarpetaA�o = Join-Path $rutaCarpeta $a�o

        # Crea la subcarpeta si no existe
        if (-not (Test-Path -Path $rutaSubcarpetaA�o -PathType Container)) {
            Write-Host "Creando carpeta: $rutaSubcarpetaA�o"
            New-Item -Path $rutaSubcarpetaA�o -ItemType Directory | Out-Null
        }

        # Define la ruta de destino del archivo
        $rutaDestino = Join-Path $rutaSubcarpetaA�o $archivo.Name

        # Mueve el archivo a la subcarpeta del a�o
        try {
            Move-Item -Path $archivo.FullName -Destination $rutaDestino -Force
            Write-Host "Movido: $($archivo.Name) a $rutaSubcarpetaA�o"
        }
        catch {
            Write-Warning "Error al mover $($archivo.Name): $($_.Exception.Message)"
        }
    }
    # Si el nombre del archivo no coincide con el patr�n de fecha, se mantiene en la carpeta original
	# Incrementar contadorArchivos
	$contadorArchivos++
    if ($contadorArchivos % 100 -eq 0) {
        Write-Host "Archivos procesados: $contadorArchivos"
    }	
}

Write-Host "Proceso completado."