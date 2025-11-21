# 🎯 Egyszerűsített Deployment - Egy Szerver Setup

Ha **csak egy szervered** van (nincs külön staging/production), itt a legegyszerűbb beállítás.

## ✅ A te esetedben

Te már kitöltötted az alapvető beállításokat:
```bash
DEPLOY_HOST=hitinfo.hu
DEPLOY_USER=hitradio
DEPLOY_PASSWORD=Zs239134123.
DEPLOY_PATH=/var/www/hitradio
```

**Ez minden, amire szükséged van!** 🎉

## 🚀 Gyors Deployment (2 lépés)

### 1. Secrets feltöltése GitHub-ra

**Automatikusan:**
```bash
cd /workspaces/Ghost
.github/workflows/setup-secrets.sh
```

**Vagy manuálisan** (GitHub webes felület):
1. Menj: https://github.com/oliwerbig/Ghost/settings/secrets/actions
2. Kattints: **New repository secret**
3. Add hozzá ezeket:

```
Name: DEPLOY_HOST
Value: hitinfo.hu

Name: DEPLOY_USER  
Value: hitradio

Name: DEPLOY_PASSWORD
Value: Zs239134123.

Name: DEPLOY_PATH
Value: /var/www/hitradio
```

### 2. Deployment indítása

1. Menj: https://github.com/oliwerbig/Ghost/actions
2. Válaszd ki: **"Simple Deploy to Production"**
3. Kattints: **"Run workflow"**
4. Environment: válaszd a **"production"**-t (bár mindegy, ugyanaz a szerver)
5. Kattints: **"Run workflow"** (zöld gomb)

**Kész!** ✅ A deployment fut.

---

## 📋 Mit csinál a deployment?

```
1. ⬇️  Letölti a Ghost kódot GitHub-ról
2. 🔨 Felbuildi (yarn install + yarn build)
3. 📦 Becsomagolja ZIP-be
4. ⬆️  Feltölti SFTP-n a szerverre (hitinfo.hu)
5. 🛑 Leállítja a Ghost-ot
6. 💾 Backup készít
7. 📂 Kicsomagolja és frissíti a fájlokat
8. 🔧 Telepíti a függőségeket
9. 🗃️  Futtatja az adatbázis migrációkat
10. ▶️  Újraindítja a Ghost-ot
```

## ⏱️ Mennyi ideig tart?

Első alkalommal: **~10 perc**
Későbbi deploymentek: **~5-7 perc**

## 🔍 Deployment státusz ellenőrzése

**GitHub-on:**
- Actions tab → Futó workflow megnyitása → Élő logok

**Szerveren SSH-val:**
```bash
ssh hitradio@hitinfo.hu
cd /var/www/hitradio
ghost status
```

## 🎨 Melyik workflow-t használd?

Két workflow közül választhatsz:

### 1. **deploy-simple.yml** (AJÁNLOTT neked)
- ✅ Egyszerűbb
- ✅ Manuális indítás (kontroll)
- ✅ Gyorsabb
- ✅ Kevesebb konfiguráció

### 2. **deploy-sftp.yml** (Haladóknak)
- 🔄 Automatikus (minden push-nál)
- 📊 Részletesebb logok
- 💾 Több backup opció
- ⚙️ Több konfiguráció

**Javaslat:** Kezd a `deploy-simple.yml`-lel!

---

## ⚙️ Automatikus deployment bekapcsolása

Ha azt szeretnéd, hogy **minden git push után automatikusan deployoljon**, módosítsd a workflow fájlt:

```bash
# Nyisd meg a fájlt
code .github/workflows/deploy-sftp.yml

# Módosítsd ezt a részt:
on:
  push:
    branches:
      - main  # Minden main branch push után deploy
```

Ezután **minden commit után automatikusan fog deployolni** a szerverre!

---

## 🛡️ Biztonsági javaslatok

### 1. SSH kulcs használata (ERŐSEN AJÁNLOTT)

Jelszó helyett használj SSH kulcsot:

```bash
# 1. Kulcs generálása
ssh-keygen -t ed25519 -f ~/.ssh/hitinfo_deploy -C "github-deploy"

# 2. Kulcs másolása a szerverre
ssh-copy-id -i ~/.ssh/hitinfo_deploy.pub hitradio@hitinfo.hu

# 3. Teszteld
ssh -i ~/.ssh/hitinfo_deploy hitradio@hitinfo.hu

# 4. Private key-t másold a GitHub Secret-be
cat ~/.ssh/hitinfo_deploy
# Másold ki a teljes kimenetet és cseréld le a DEPLOY_PASSWORD értékét
```

### 2. Korlátozott jogosultságú user

```bash
# Szerveren hozz létre külön deploy user-t
sudo adduser github-deploy
sudo chown -R github-deploy:github-deploy /var/www/hitradio
```

### 3. .env fájl ne kerüljön GitHub-ra

**Ellenőrzés:**
```bash
cat .gitignore | grep .env
# Ha van .env benne, akkor OK ✅
```

---

## 🐛 Gyakori problémák

### "Permission denied"
```bash
# Szerveren add meg a jogokat
sudo chown -R hitradio:hitradio /var/www/hitradio
```

### "Ghost not found"
```bash
# Szerveren telepítsd a ghost-cli-t
sudo npm install -g ghost-cli@latest
```

### "Port 2368 already in use"
```bash
# Szerveren állítsd le és indítsd újra
cd /var/www/hitradio
ghost stop
ghost start
```

### "Database connection failed"
```bash
# Ellenőrizd a Ghost config-ot
cd /var/www/hitradio
cat config.production.json
```

---

## 🔄 Rollback (ha valami elromlik)

```bash
# SSH-zz a szerverre
ssh hitradio@hitinfo.hu
cd /var/www/hitradio

# Nézd meg a backup-okat
ls -la backups/

# Állj vissza egy korábbi verzióra
ghost stop
rm -rf current
cp -r backups/backup-LEGUTÓBBI-DÁTUM/* ./current/
ghost start
```

---

## 📚 Következő lépések

1. ✅ Deployment beállítása (már kész!)
2. 🔐 SSH kulcs beállítása (ajánlott)
3. 🌐 Domain és SSL konfiguráció
4. 📧 Email küldés beállítása
5. 💾 Automatikus backup megoldás
6. 🎨 Téma testreszabása

---

## 💡 Pro tipp

**Webhook értesítés Slack-be vagy Discord-ba:**

Deployment után kapsz egy értesítést, hogy sikeres volt:

```bash
# .env fájlban add meg:
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK
# vagy
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR/WEBHOOK
```

---

## 📞 Segítség

Ha elakadtál:
1. Nézd meg a GitHub Actions logokat
2. Ellenőrizd a Ghost logokat: `ssh hitradio@hitinfo.hu "tail -f /var/www/hitradio/content/logs/ghost.log"`
3. Ghost status: `ssh hitradio@hitinfo.hu "cd /var/www/hitradio && ghost doctor"`

---

**🎉 Sikeres deploymenteket!**

*Most már minden push után friss Ghost-od lesz a hitinfo.hu-n!* 🚀
