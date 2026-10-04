Write-Host "Zatrzymywanie usług EventFlow na portach 8000, 8080, 8081, 5173, 5174..." -ForegroundColor Yellow

$ports = @(8000, 8080, 8081, 5173, 5174)
$found = $false

foreach ($port in $ports) {
    try {
        $conns = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($conns) {
            $pids = $conns | Select-Object -ExpandProperty OwningProcess -Unique
            foreach ($processId in $pids) {
                if ($processId -gt 0) {
                    $p = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($p) {
                        Write-Host "Zamykanie procesu $($p.ProcessName) (PID: $processId) na porcie $port..." -ForegroundColor Cyan
                        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                        $found = $true
                    }
                }
            }
        }
    } catch { }
}

if ($found) {
    Write-Host "Wszystkie usługi EventFlow zostały pomyślnie zatrzymane." -ForegroundColor Green
} else {
    Write-Host "Brak aktywnych procesów EventFlow na monitorowanych portach." -ForegroundColor Green
}
