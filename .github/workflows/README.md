# 🚀 Ghost SFTP Deployment - Teljes Telepítési Csomag

Automatikus Ghost deployment GitHub Actions-szel SFTP-n keresztül.

## 📦 Mit kaptál?

### Workflow fájlok:

1. **`deploy-sftp.yml`** - Teljes featured deployment
   - Automatikus build és deploy
   - Backup készítés
   - Migráció futtatás
   - Rollback támogatás
   - Részletes logging

2. **`deploy-simple.yml`** - Egyszerűsített verzió
   - Könnyebb konfiguráció
   - Manuális trigger
   - Staging/Production választás
   - Gyorsabb futás

### Dokumentációk:

- **`QUICKSTART.md`** - 5 perces gyors telepítés 🚀
- **`DEPLOY_README.md`** - Részletes dokumentáció 📚
- **`SECRETS_EXAMPLE.md`** - Secret konfigurációs példák 🔐

## 🎯 Első lépések (3 egyszerű lépés)

### 1️⃣ Konfiguráció létrehozása

```bash
# Másold le a .env példa fájlt
cp .github/workflows/.env.example .env

# Szerkeszd meg a saját adataiddal
nano .env  # vagy code .env
```

**Töltsd ki a következő mezőket:**
- `DEPLOY_HOST` - Szerver címe
- `DEPLOY_USER` - SSH felhasználónév  
- `DEPLOY_PASSWORD` - Jelszó vagy SSH kulcs
- `DEPLOY_PATH` - Ghost könyvtár (pl. /var/www/ghost)

### 2️⃣ GitHub Secrets feltöltése

**Automatikusan (ajánlott):**
```bash
.github/workflows/setup-secrets.sh
```

**Vagy manuálisan GitHub webes felületen:**
- Settings → Secrets and variables → Actions → New repository secret
- Részletes útmutató: [`SETUP_SECRETS.md`](SETUP_SECRETS.md)

### 3️⃣ Első deployment

- GitHub → **Actions** tab
- **"Simple Deploy to Production"** kiválasztása
- **"Run workflow"** → Environment választás → **Run**

🎉 **Kész! A deployment fut!**

---

## 📁 Fájlok áttekintése

| Fájl | Leírás |
|------|--------|
| [`.env.example`](.env.example) | Konfiguráció sablon (másold .env-be) |
| [`setup-secrets.sh`](setup-secrets.sh) | Automatikus secrets feltöltő script |
| [`SETUP_SECRETS.md`](SETUP_SECRETS.md) | Részletes secrets beállítási útmutató |
| [`QUICKSTART.md`](QUICKSTART.md) | 5 perces gyors telepítés |
| [`deploy-sftp.yml`](deploy-sftp.yml) | Teljes deployment workflow |
| [`deploy-simple.yml`](deploy-simple.yml) | Egyszerű deployment workflow |
| [`DEPLOY_README.md`](DEPLOY_README.md) | Részletes dokumentáció |

---

## 🚀 Workflow választás

### 1. Válaszd ki a workflow típust:

**Kezdőknek:** `deploy-simple.yml`
- Egyszerűbb beállítás
- Manuális kontrollja a deploymentnek
- Kevesebb konfiguráció

**Haladóknak:** `deploy-sftp.yml`
- Automatikus deployment
- Több funkció (backup, részletes log, stb.)
- Testreszabható

### 2. Gyors telepítés (3 lépés):

```bash
# 1. GitHub Secrets beállítása (GitHub webfelület)
DEPLOY_HOST=your-server.com
DEPLOY_USER=ghost
DEPLOY_PASSWORD=your-password
DEPLOY_PATH=/var/www/ghost

# 2. Szerver előkészítés (SSH-val a szerveren)
sudo npm install -g ghost-cli
cd /var/www && sudo mkdir ghost && sudo chown $USER:$USER ghost
cd ghost && ghost install

# 3. Deployment indítás (GitHub Actions)
# Actions tab → Run workflow → Deploy!
```

**Részletes lépésekért nézd meg a `QUICKSTART.md`-t!**

## 🔧 Működési folyamat

```
┌─────────────────────────────────────────────────────────────┐
│  GitHub Push/Manual Trigger                                 │
└────────────────┬────────────────────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────────────────────┐
│  1. Checkout & Build                                        │
│     - Git clone                                             │
│     - yarn install                                          │
│     - yarn build                                            │
└────────────────┬────────────────────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────────────────────┐
│  2. Package                                                 │
│     - Ghost core fájlok összegyűjtése                       │
│     - Admin UI build hozzáadása                             │
│     - ZIP archívum készítése                                │
└────────────────┬────────────────────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────────────────────┐
│  3. Upload via SFTP                                         │
│     - Kapcsolódás a szerverhez                              │
│     - ghost.zip feltöltése /tmp-be                          │
└────────────────┬────────────────────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────────────────────┐
│  4. Deploy via SSH                                          │
│     - ghost stop                                            │
│     - Backup készítése                                      │
│     - Fájlok frissítése                                     │
│     - yarn install --production                             │
│     - ghost update (migráció)                               │
│     - ghost start                                           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────────────────────┐
│  ✅ Deployment Complete!                                    │
│     - Ghost futnak                                          │
│     - Backup készült                                        │
│     - Logok elérhetők                                       │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Előfeltételek

### Szerveren:
- [x] Ubuntu/Debian Linux (vagy kompatibilis)
- [x] Node.js 18+ telepítve
- [x] MySQL/SQLite adatbázis
- [x] Ghost-CLI telepítve
- [x] SSH/SFTP hozzáférés
- [x] Minimum 1GB RAM

### GitHub-on:
- [x] Repository admin jogosultság
- [x] GitHub Actions engedélyezve
- [x] Secrets beállítva

## 🎨 Testreszabási lehetőségek

### Branch megváltoztatása:
```yaml
on:
  push:
    branches:
      - production  # vagy bármi más
```

### Deployment schedule:
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # Minden nap 2:00-kor
```

### Post-deployment hook:
```yaml
- name: Post Deploy Actions
  run: |
    ssh user@server 'cd /var/www/ghost && ghost doctor'
    curl -X POST https://your-webhook.com/deployed
```

### Slack értesítés hozzáadása:
```yaml
- name: Notify Slack
  if: success()
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
      -d '{"text":"Ghost successfully deployed!"}'
```

## 🔐 Biztonság

### Ajánlások:
1. **SSH kulcs használata** jelszó helyett
2. **Korlátozott jogosultságú user** a deploymenthez
3. **Firewall szabályok** csak GitHub IP-kről
4. **Secrets rotation** 90 naponta
5. **Staging environment** éles deploy előtt

### SSH kulcs generálás:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_deploy -C "github-deploy"
ssh-copy-id -i ~/.ssh/github_deploy.pub user@server
# Private key tartalmát másold a DEPLOY_PASSWORD secret-be
```

## 📊 Monitoring

### Deployment státusz ellenőrzése:
```bash
# Szerveren
ghost status
ghost log
tail -f /var/www/ghost/content/logs/ghost.log

# GitHub-on
# Actions tab → Workflow futások
```

### Badge hozzáadása a README-hez:
```markdown
![Deployment Status](https://github.com/USERNAME/Ghost/actions/workflows/deploy-sftp.yml/badge.svg)
```

## 🆘 Hibaelhárítás

| Hiba | Megoldás |
|------|----------|
| Permission denied | `sudo chown -R $USER:$USER /var/www/ghost` |
| Ghost-CLI not found | `sudo npm install -g ghost-cli@latest` |
| Port already in use | `ghost stop && ghost start` |
| Database error | `ghost setup mysql` |
| Build failed | Ellenőrizd a Node.js verziót (22.x) |

**Részletes hibaelhárítás:** `DEPLOY_README.md` → "Hibaelhárítás" szekció

## 🔄 Rollback

Ha valami elromlik:

```bash
# SSH-val a szerveren
cd /var/www/ghost
ghost stop
rm -rf current
cp -r backups/backup-LATEST/ ./current/
ghost start
```

## 📚 További olvasnivaló

- [Ghost CLI Dokumentáció](https://ghost.org/docs/ghost-cli/)
- [GitHub Actions Dokumentáció](https://docs.github.com/en/actions)
- [Ghost Deployment Best Practices](https://ghost.org/docs/hosting/)

## 🎯 Roadmap / Jövőbeli fejlesztések

- [ ] Docker support
- [ ] Multi-server deployment
- [ ] Automatikus rollback hiba esetén
- [ ] Health check monitoring
- [ ] Discord értesítések
- [ ] Deployment metrics
- [ ] Blue-Green deployment

## 💬 Support

Ha kérdésed van:
1. Nézd meg a `QUICKSTART.md`-t
2. Olvasd el a `DEPLOY_README.md`-t
3. Ellenőrizd a GitHub Actions logokat
4. Nézd meg a Ghost logokat a szerveren

---

**Készítette:** GitHub Copilot 🤖
**Verzió:** 1.0.0
**Frissítve:** 2025-01-29

🎉 **Sikeres deploymenteket!**
