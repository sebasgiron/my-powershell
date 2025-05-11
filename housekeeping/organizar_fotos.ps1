# Especifica la ruta de la carpeta con las fotografías
$rutaCarpeta = "D:\Users\Sebas\Dropbox\Cargas de cámara"

# Obtén todos los archivos en la carpeta
$archivos = Get-ChildItem -Path $rutaCarpeta -File

# Expresión regular para extraer el año del nombre del archivo
$patronFecha = "^(\d{4})-\d{2}-\d{2}.+"
$contadorArchivos = 0

foreach ($archivo in $archivos) {
    # Intenta hacer coincidir el patrón de fecha en el nombre del archivo
    $coincidencia = $archivo.BaseName -match $patronFecha

    if ($coincidencia) {
        # Extrae el año de la primera captura del patrón
        $año = $Matches[1]

        # Define la ruta de la subcarpeta del año
        $rutaSubcarpetaAño = Join-Path $rutaCarpeta $año

        # Crea la subcarpeta si no existe
        if (-not (Test-Path -Path $rutaSubcarpetaAño -PathType Container)) {
            Write-Host "Creando carpeta: $rutaSubcarpetaAño"
            New-Item -Path $rutaSubcarpetaAño -ItemType Directory | Out-Null
        }

        # Define la ruta de destino del archivo
        $rutaDestino = Join-Path $rutaSubcarpetaAño $archivo.Name

        # Mueve el archivo a la subcarpeta del año
        try {
            Move-Item -Path $archivo.FullName -Destination $rutaDestino -Force
            Write-Host "Movido: $($archivo.Name) a $rutaSubcarpetaAño"
        }
        catch {
            Write-Warning "Error al mover $($archivo.Name): $($_.Exception.Message)"
        }
    }
    # Si el nombre del archivo no coincide con el patrón de fecha, se mantiene en la carpeta original
	# Incrementar contadorArchivos
	$contadorArchivos++
    if ($contadorArchivos % 100 -eq 0) {
        Write-Host "Archivos procesados: $contadorArchivos"
    }	
}

Write-Host "Proceso completado."