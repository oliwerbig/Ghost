# 🚀 Gyors telepítési útmutató

## 1. GitHub Secrets beállítása (5 perc)

Menj a GitHub repository-ba: **Settings → Secrets and variables → Actions → New repository secret**

### Alapvető deployment-hez (deploy-simple.yml):

```
DEPLOY_HOST = your-server.com
DEPLOY_USER = ghost-user
DEPLOY_PASSWORD = your-password
DEPLOY_PATH = /var/www/ghost
```

### Teljes deployment-hez staging + production (deploy-sftp.yml):

**Production:**
```
PRODUCTION_HOST = prod.your-server.com
PRODUCTION_USER = ghost
PRODUCTION_PASSWORD = secure-password
PRODUCTION_PATH = /var/www/ghost
```

**Staging (opcionális):**
```
STAGING_HOST = staging.your-server.com
STAGING_USER = ghost
STAGING_PASSWORD = secure-password
STAGING_PATH = /var/www/ghost-staging
```

## 2. Szerver előkészítése (10 perc)

SSH-zz a szerverre és futtasd:

```bash
# 1. Node.js telepítése (ha még nincs)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. Ghost-CLI telepítése
sudo npm install -g ghost-cli@latest

# 3. Könyvtár létrehozása
sudo mkdir -p /var/www/ghost
sudo chown $USER:$USER /var/www/ghost
cd /var/www/ghost

# 4. Ghost telepítése (követd a promptokat)
ghost install

# Vagy automatikus telepítés MySQL-lel:
ghost install \
  --db mysql \
  --dbhost localhost \
  --dbuser ghost \
  --dbpass YOUR_DB_PASSWORD \
  --dbname ghost_production \
  --url https://your-domain.com \
  --no-prompt \
  --no-start

# 5. Indítsd el a Ghost-ot
ghost start
```

## 3. Első deployment (2 perc)

### Opció A: Egyszerű deployment (ajánlott kezdőknek)

1. Menj a GitHub repository Actions tabjára
2. Válaszd ki: **"Simple Deploy to Production"**
3. Kattints: **"Run workflow"**
4. Válaszd ki az environmentet (staging/production)
5. Kattints: **"Run workflow"** (zöld gomb)

### Opció B: Teljes deployment (haladóknak)

1. Menj a GitHub repository Actions tabjára
2. Válaszd ki: **"Deploy to SFTP"**
3. Kattints: **"Run workflow"**
4. Várj ~5-10 percet

### Opció C: Automatikus deployment minden push-nál

Módosítsd a `.github/workflows/deploy-sftp.yml` fájlt:

```yaml
on:
  push:
    branches:
      - main  # vagy bármelyik branch
```

Ezután minden push után automatikusan deployol!

## 4. Ellenőrzés

Deployment után menj a szerverhez SSH-n:

```bash
ssh user@your-server.com
cd /var/www/ghost
ghost status

# Ha nem fut, nézd meg a logokat:
ghost log
```

Vagy látogasd meg a weboldalad: `https://your-domain.com`

## 🔒 Biztonsági tippek

### SSH kulcs használata jelszó helyett:

```bash
# 1. Generálj SSH kulcsot
ssh-keygen -t ed25519 -f ~/.ssh/github_deploy

# 2. Másold a public key-t a szerverre
ssh-copy-id -i ~/.ssh/github_deploy.pub user@your-server.com

# 3. Private key-t add hozzá GitHub Secret-ként
# A DEPLOY_PASSWORD helyett másold be a private key tartalmát:
cat ~/.ssh/github_deploy
```

### Csak specific IP-ről engedélyezd az SSH-t:

```bash
# Szerveren: /etc/ssh/sshd_config
AllowUsers ghost@github-runner-ip
```

## ⚠️ Gyakori hibák

### "Permission denied"
```bash
sudo chown -R $USER:$USER /var/www/ghost
```

### "Ghost-CLI not found"
```bash
sudo npm install -g ghost-cli@latest
# Vagy használd a teljes path-ot: /usr/local/bin/ghost
```

### "Database connection failed"
```bash
cd /var/www/ghost
ghost setup mysql
```

### "Port 2368 already in use"
```bash
ghost stop
# Vagy találd meg a processt:
lsof -i :2368
kill -9 <PID>
```

## 📊 Workflow státusz badge

Add hozzá a README.md-hez:

```markdown
![Deploy Status](https://github.com/YOUR_USERNAME/Ghost/actions/workflows/deploy-sftp.yml/badge.svg)
```

## 🎯 Következő lépések

- [ ] Állíts be HTTPS-t (Let's Encrypt)
- [ ] Konfiguráld az email küldést
- [ ] Állíts be automatikus backup-ot
- [ ] Slack/Discord értesítések hozzáadása
- [ ] Rollback mechanizmus tesztelése

## 💡 Tippek

**Staging környezet létrehozása:**
```bash
# Másik könyvtárban telepíts egy külön Ghost példányt
cd /var/www/ghost-staging
ghost install --url https://staging.your-domain.com
```

**Rollback korábbi verzióra:**
```bash
cd /var/www/ghost
ghost stop
rm -rf current
cp -r backups/backup-20250129-120000/* ./
ghost start
```

**Deployment előnézet:**
Nézd meg mi fog deployolódni:
```bash
git diff main..your-branch
```

---

🎉 **Kész! Most már automatikusan deployolhatsz minden push-nál vagy manuálisan!**
