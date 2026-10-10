# ============================================================
# Jump Server - pruebas hacia el Web Server (PowerShell)
# ============================================================
Test-NetConnection 10.7.1.138 -Port 22      # SSH    -> permitido
Test-NetConnection 10.7.1.138 -Port 443     # HTTPS  -> permitido
Test-NetConnection 10.7.1.138 -Port 3389    # RDP    -> permitido
Test-NetConnection 10.7.1.138 -Port 80      # HTTP   -> bloqueado (no esta en la politica)
