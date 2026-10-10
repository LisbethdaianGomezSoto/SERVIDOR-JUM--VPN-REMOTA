# Checklist de capturas (38 imágenes, 00 a 37)

Guardar en `images/` con el **nombre exacto** (minúsculas, sin espacios, .png).
Pegar en el repositorio solo después de revisar que no se vea ninguna contraseña.

| # | Archivo | Equipo | Qué capturar |
|---|---|---|---|
| 00 | 00-miniatura-video.png | — | Ya generada (portada del video) |
| 01 | 01-topologia-gns3.png | GNS3 | Topología completa, todos los nodos en verde |
| 02 | 02-isp-interfaces.png | ISP | `show ip interface brief` y `show ip nat translations` |
| 03 | 03-r1-interfaces-dhcp.png | R-1 | `show ip interface brief`, `show ip route`, `show ip dhcp pool` |
| 04 | 04-sw1-vlan-trunk.png | SW-1 | `show vlan brief` y `show interfaces trunk` |
| 05 | 05-dhcp-pc-usuarios.png | PC-USUARIOS (VPCS) | `ip dhcp` y `show ip` |
| 06 | 06-fortigate-acceso-gui.png | PC-ADMIN | Login de la GUI en 192.168.99.1 |
| 07 | 07-fortigate-interfaces.png | FortiGate GUI | Network → Interfaces (port1 a port4) |
| 08 | 08-fortigate-ruta-estatica.png | FortiGate GUI | Network → Static Routes |
| 09 | 09-fortigate-addresses.png | FortiGate GUI | Policy & Objects → Addresses |
| 10 | 10-fortigate-usuarios-grupos.png | FortiGate GUI | User Definition y User Groups (GRP-VPN) |
| 11 | 11-ipsec-wizard-vpn-setup.png | FortiGate GUI | Asistente IPsec, paso 1 |
| 12 | 12-ipsec-wizard-autenticacion.png | FortiGate GUI | Asistente IPsec, paso 2 (**sin mostrar la PSK**) |
| 13 | 13-ipsec-wizard-politica-red.png | FortiGate GUI | Asistente IPsec, paso 3 (rango 10.10.10.10-50, split tunnel) |
| 14 | 14-fortigate-ipsec-tunnels.png | FortiGate GUI | VPN → IPsec Tunnels con VPN-JUMP |
| 15 | 15-fortigate-politicas.png | FortiGate GUI | Firewall Policy en *By Sequence* |
| 16 | 16-webserver-servicios.png | Web Server | `ip addr` y `netstat -ln \| grep -E ":22\|:443\|:3389"` |
| 17 | 17-jump-red-dominio.png | Jump | `ipconfig` y `Get-ADDomain` |
| 18 | 18-jump-usuarios-grupos-ad.png | Jump | `Get-ADGroupMember GRP-SINPRIV` y `GRP-CONPRIV` |
| 19 | 19-jump-rds-despliegue.png | Jump | `Get-RDServer` |
| 20 | 20-jump-remoteapps.png | Jump | `Get-RDRemoteApp -CollectionName COL-JUMP \| Select DisplayName, Alias, UserGroups` |
| 21 | 21-jump-gpo-derechos.png | Jump | gpmc.msc: "Permitir inicio de sesión a través de Servicios de Escritorio remoto" |
| 22 | 22-jump-webclient-publicado.png | Jump | `Get-RDWebClientPackage` (publishedAs Production) |
| 23 | 23-forticlient-configuracion.png | PC cliente | Conexión VPN IPsec en FortiClient (**PSK oculta**) |
| 24 | 24-pruebas-sin-vpn.png | PC cliente | `Test-NetConnection` puerto 22 a 10.7.1.146 y 10.7.1.138 (False) |
| 25 | 25-forticlient-conectado.png | PC cliente | FortiClient "Conectado" + `ipconfig` con 10.10.10.x |
| 26 | 26-fortigate-tunel-activo.png | FortiGate GUI | VPN Events con `tunnel-up` o widget IPsec |
| 27 | 27-pruebas-con-vpn.png | PC cliente | 10.7.1.146:443 True; 10.7.1.146:22 y 10.7.1.138:443 False |
| 28 | 28-webclient-sinpriv.png | PC cliente | Web Client con LAB\sinpriv: solo Navegador |
| 29 | 29-sistema-de-caja.png | Web Client | Navegador en https://10.7.1.138 mostrando "Sistema de Caja" |
| 30 | 30-webclient-conpriv.png | PC cliente | Web Client con LAB\conpriv: Navegador, Putty, RDP |
| 31 | 31-putty-webserver.png | Web Client | Putty a 10.7.1.138:22 (login SSH) |
| 32 | 32-rdp-webserver.png | Web Client | RDP a 10.7.1.138 (login/escritorio xrdp) |
| 33 | 33-pruebas-jump-webserver.png | Jump | Puertos 22, 443, 3389 True y 80 False |
| 34 | 34-fortigate-politicas-contadores.png | FortiGate GUI | Firewall Policy con columna Bytes/contadores |
| 35 | 35-fortigate-propuestas-ipsec.png | FortiGate GUI | VPN → IPsec Tunnels → VPN-JUMP (personalizado): Phase 1 y Phase 2 (DES, DH 14/5, PFS) |
| 37 | 37-fortigate-log-deny-ssh.png | FortiGate GUI | Forward Traffic con el SSH de 10.10.10.x bloqueado |
| 36 | 36-forticlient-avanzado.png | PC cliente | FortiClient → Ajustes avanzados, Fase 1 y Fase 2 (**PSK oculta**) |

## Reglas de privacidad
- Ocultar la PSK, las contraseñas y cualquier clave visible.
- No usar la CLI del FortiGate en las capturas (el enunciado pide GUI).

## Comprobar que no falta ninguna (PowerShell, dentro del repo)
```powershell
$n = Select-String -Path README.md -Pattern 'images/\d\d-[a-z0-9-]+\.png' -AllMatches |
  % { $_.Matches.Value } | Sort-Object -Unique
$n | ? { -not (Test-Path $_) } | % { "FALTA: $_" }
```

## Archivos de configuración que debes pegar (running-configs/)
| Archivo | Cómo se obtiene |
|---|---|
| ISP_running-config.txt | `show running-config` en el ISP |
| R-1_running-config.txt | `show running-config` en R-1 |
| SW-1_running-config.txt | `show running-config` en SW-1 |
| FortiGate_running-config.txt | GUI: admin → Configuration → Backup (quitar claves) |
| WebServer_config.txt | Salida de `ip addr show eth0`, `ip route`, `netstat -ln`, `id rdpuser` |
