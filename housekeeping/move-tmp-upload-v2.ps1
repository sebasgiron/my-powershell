write-host "Num argumentos especificados =  $($args.count)"

for ( $i = 0; $i -lt $args.count; $i++ ) {
	Move-Item -Path $($args[$i]) -Destination "C:\tmp\upload" -PassThru | Write-Host
} 
 
pause
