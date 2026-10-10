# ============================================================
# PC Cliente (Windows + FortiClient) - pruebas de acceso
# ============================================================

# --- 1. Con la VPN DESCONECTADA (el acceso por SSH debe estar bloqueado) ---
Test-NetConnection 10.7.1.146 -Port 22     # Jump Server por SSH
Test-NetConnection 10.7.1.138 -Port 22     # Web Server por SSH

# --- 2. Con la VPN IPsec CONECTADA (FortiClient -> 198.7.1.2) ---
ipconfig                                    # adaptador de la VPN con IP 10.10.10.x
Test-NetConnection 10.7.1.146 -Port 443    # Jump Server por HTTPS   -> permitido
Test-NetConnection 10.7.1.146 -Port 22     # Jump Server por SSH     -> bloqueado
Test-NetConnection 10.7.1.138 -Port 443    # Web Server (directo)    -> bloqueado

# --- 3. Cliente web RemoteApp (Edge, Chrome o Brave) ---
# https://10.7.1.146/RDWeb/webclient/index.html

# --- 4. Con el Web Client (conpriv): Putty y RDP a 10.7.1.138 (usuario rdpuser) ---
