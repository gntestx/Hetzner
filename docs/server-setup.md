# Serverinstallation på Hetzner Cloud

## 1. Skapa server

Välj Ubuntu 24.04 och en region nära användarna, exempelvis Helsinki eller Nürnberg. Lägg till din SSH-nyckel och aktivera backups om det behövs.

## 2. Hetzner Firewall

Tillåt:

- TCP 22 från dina administratörs-IP-adresser
- TCP 80 från alla
- TCP 443 från alla
- UDP 443 från alla för HTTP/3

## 3. Grundinstallation

```bash
ssh root@SERVER_IP
apt update && apt upgrade -y
apt install -y ca-certificates curl git ufw unattended-upgrades
```

Skapa en driftanvändare:

```bash
adduser deploy
usermod -aG sudo deploy
rsync --archive --chown=deploy:deploy ~/.ssh /home/deploy
```

## 4. Installera Docker

```bash
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker deploy
```

Logga ut och in igen som `deploy`.

## 5. DNS

Skapa A-poster för både huvuddomänen och wildcard:

```text
example.com       A   SERVER_IP
*.example.com     A   SERVER_IP
```

## 6. Installera projektet

```bash
sudo mkdir -p /opt/hetzner-info
sudo chown deploy:deploy /opt/hetzner-info
git clone https://github.com/gntestx/Hetzner_info.git /opt/hetzner-info
cd /opt/hetzner-info
cp .env.example .env
chmod +x scripts/*.sh
```

Redigera `.env` och `Caddyfile`, därefter:

```bash
docker compose pull
docker compose up -d
```

## 7. Kontrollera drift

```bash
docker compose ps
docker compose logs -f --tail=200
curl -I https://example.com
```

## 8. Uppdatering

```bash
cd /opt/hetzner-info
git pull --ff-only
./scripts/deploy.sh
```

## 9. SQLite

Använd en enda appinstans när SQLite är den skrivande databasen. Aktivera WAL i applikationen och kör backup regelbundet. För flera samtidiga appinstanser bör databasen flyttas till PostgreSQL.

## 10. Cron för backup

```bash
crontab -e
```

Exempel, varje natt 02:15:

```cron
15 2 * * * cd /opt/hetzner-info && ./scripts/backup.sh >> /var/log/hetzner-info-backup.log 2>&1
```
