# ============================================================
# Jump Server - Windows Server 2019 (PowerShell como administrador)
# ============================================================

# ---------- 1. Red ----------
New-NetIPAddress -InterfaceAlias "Ethernet0 2" -IPAddress 10.7.1.146 -PrefixLength 29 -DefaultGateway 10.7.1.145
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0 2" -ServerAddresses 127.0.0.1
Rename-Computer -NewName JUMP -Restart

# ---------- 2. Active Directory (dominio lab.local) ----------
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName lab.local -InstallDns

# ---------- 3. Usuarios y grupos del dominio ----------
$p = Read-Host "Contrasena para sinpriv y conpriv" -AsSecureString
New-ADUser -Name sinpriv -SamAccountName sinpriv -AccountPassword $p -Enabled $true
New-ADUser -Name conpriv -SamAccountName conpriv -AccountPassword $p -Enabled $true
New-ADGroup -Name GRP-SINPRIV -GroupScope Global
New-ADGroup -Name GRP-CONPRIV -GroupScope Global
Add-ADGroupMember GRP-SINPRIV sinpriv
Add-ADGroupMember GRP-CONPRIV conpriv

# ---------- 4. Remote Desktop Services ----------
# Despliegue estandar por Administrador del servidor:
# Agregar roles y caracteristicas > Servicios de Escritorio remoto > Implementacion estandar >
# Implementacion basada en sesiones > Agente de conexion, Acceso web y Host de sesion en JUMP.lab.local
Get-RDServer

# ---------- 5. Coleccion y RemoteApps ----------
New-RDSessionCollection -CollectionName COL-JUMP -SessionHost JUMP.lab.local -ConnectionBroker JUMP.lab.local
Set-RDSessionCollectionConfiguration -CollectionName COL-JUMP -UserGroup "LAB\GRP-SINPRIV","LAB\GRP-CONPRIV" -ConnectionBroker JUMP.lab.local

New-RDRemoteApp -CollectionName COL-JUMP -DisplayName "Navegador" -FilePath "C:\Program Files\Mozilla Firefox\firefox.exe" -UserGroups "LAB\GRP-SINPRIV","LAB\GRP-CONPRIV" -ConnectionBroker JUMP.lab.local
New-RDRemoteApp -CollectionName COL-JUMP -DisplayName "RDP" -FilePath "C:\Windows\System32\mstsc.exe" -UserGroups "LAB\GRP-CONPRIV" -ConnectionBroker JUMP.lab.local
New-RDRemoteApp -CollectionName COL-JUMP -DisplayName "Putty" -FilePath "C:\Program Files\PuTTY\putty.exe" -UserGroups "LAB\GRP-CONPRIV" -ConnectionBroker JUMP.lab.local
Get-RDRemoteApp -CollectionName COL-JUMP -ConnectionBroker JUMP.lab.local | Select Alias, DisplayName, UserGroups

# ---------- 6. Derecho de inicio de sesion remoto (controlador de dominio) ----------
# gpmc.msc > Domain Controllers > Default Domain Controllers Policy > Editar:
# Directivas locales > Asignacion de derechos de usuario:
#   - Permitir el inicio de sesion local
#   - Permitir inicio de sesion a traves de Servicios de Escritorio remoto
# Agregar LAB\GRP-SINPRIV, LAB\GRP-CONPRIV y Administradores
gpupdate /force

# ---------- 7. Certificado y RD Gateway ----------
$cert = New-SelfSignedCertificate -DnsName "JUMP.lab.local","10.7.1.146" -CertStoreLocation Cert:\LocalMachine\My -NotAfter (Get-Date).AddYears(2)
$pw = Read-Host "Contrasena del PFX" -AsSecureString
Export-PfxCertificate -Cert $cert -FilePath C:\jump.pfx -Password $pw
Export-Certificate -Cert $cert -FilePath C:\cert.cer
Import-Certificate -FilePath C:\cert.cer -CertStoreLocation Cert:\LocalMachine\Root
Add-RDServer -Server JUMP.lab.local -Role RDS-GATEWAY -ConnectionBroker JUMP.lab.local -GatewayExternalFqdn JUMP.lab.local
Set-RDCertificate -Role RDPublishing -ImportPath C:\jump.pfx -Password $pw -ConnectionBroker JUMP.lab.local -Force
Set-RDCertificate -Role RDRedirector -ImportPath C:\jump.pfx -Password $pw -ConnectionBroker JUMP.lab.local -Force
Set-RDCertificate -Role RDWebAccess  -ImportPath C:\jump.pfx -Password $pw -ConnectionBroker JUMP.lab.local -Force
Set-RDCertificate -Role RDGateway    -ImportPath C:\jump.pfx -Password $pw -ConnectionBroker JUMP.lab.local -Force
Get-RDCertificate -ConnectionBroker JUMP.lab.local

# ---------- 8. RemoteApp Web Client ----------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Modulo RDWebClientManagement (descarga directa desde PowerShell Gallery)
$dest = "$env:ProgramFiles\WindowsPowerShell\Modules\RDWebClientManagement"
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Invoke-WebRequest -Uri "https://www.powershellgallery.com/api/v2/package/RDWebClientManagement" -OutFile "$env:TEMP\rdwc.zip" -UseBasicParsing
Expand-Archive -Path "$env:TEMP\rdwc.zip" -DestinationPath $dest -Force
Import-Module RDWebClientManagement
Install-RDWebClientPackage
Import-RDWebClientBrokerCert C:\cert.cer
Publish-RDWebClientPackage -Type Production -Latest
Get-RDWebClientPackage

# ---------- 9. PuTTY ----------
New-Item -ItemType Directory -Path "C:\Program Files\PuTTY" -Force | Out-Null
Invoke-WebRequest -Uri "https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe" -OutFile "C:\Program Files\PuTTY\putty.exe" -UseBasicParsing

# ---------- 9b. Firefox (navegador publicado) ----------
# El Jump no tiene internet: copiar el instalador completo "Firefox Setup xxx.exe" desde el anfitrion.
# Start-Process "C:\Users\Administrador\Downloads\Firefox Setup 157.0.1.exe" -ArgumentList "/S" -Wait
# Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe"   # debe dar True

# ---------- 10. Verificacion hacia el Web Server ----------
Test-NetConnection 10.7.1.138 -Port 443
Test-NetConnection 10.7.1.138 -Port 22
Test-NetConnection 10.7.1.138 -Port 3389
Test-NetConnection 10.7.1.138 -Port 80
