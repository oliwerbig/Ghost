# Ghost SFTP Deployment Workflow

Ez a GitHub Actions workflow automatikusan buildi, csomagolja és telepíti a Ghost-ot egy távoli szerverre SFTP-n keresztül.

## Előfeltételek

### 1. Ghost-CLI a célszerveren

A célszerveren telepítve kell lennie a Ghost-CLI-nek és egy működő Ghost példánynak:

```bash
# Ghost-CLI telepítése
npm install -g ghost-cli@latest

# Ghost inicializálása (ha még nincs)
ghost install --db mysql --dbhost localhost --dbuser ghost --dbpass password --dbname ghost_production
```

### 2. GitHub Secrets beállítása

A GitHub repository Settings → Secrets and variables → Actions menüben add hozzá a következő secreteket:

#### Kötelező secrets:
- `SFTP_HOST` - A szerver IP címe vagy domain neve (pl. `example.com` vagy `192.168.1.100`)
- `SFTP_USERNAME` - SSH/SFTP felhasználónév
- `SFTP_PASSWORD` - SSH/SFTP jelszó (vagy SSH key használata esetén private key)

#### Opcionális secrets (alapértelmezett értékekkel):
- `SFTP_PORT` - SFTP port (alapértelmezett: `22`)
- `SFTP_REMOTE_PATH` - Távoli útvonal a ZIP feltöltéséhez (alapértelmezett: `/tmp`)
- `GHOST_INSTALL_DIR` - Ghost telepítési könyvtár (alapértelmezett: `/var/www/ghost`)

### 3. SSH kulcs használata (ajánlott)

Jelszó helyett SSH kulcsot is használhatsz:

```bash
# SSH kulcspár generálása a lokális gépen
ssh-keygen -t ed25519 -C "github-actions-deploy"

# Public key hozzáadása a szerverhez
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@your-server.com

# Private key tartalmát add hozzá GitHub Secrethez mint SFTP_PASSWORD
cat ~/.ssh/id_ed25519
```

## Használat

### Automatikus deployment

A workflow automatikusan lefut amikor:
- Pusholsz a `main` branchre
- Vagy manuálisan indítod a GitHub Actions felületen

### Manuális indítás

1. Menj a GitHub repository-ba
2. Kattints az **Actions** tabra
3. Válaszd ki a **Deploy to SFTP** workflow-t
4. Kattints a **Run workflow** gombra
5. Válaszd ki a branch-et és kattints a **Run workflow** újra

## Mit csinál a workflow?

1. **Checkout**: Letölti a repository tartalmát
2. **Build**: Felbuildi a Ghost-ot (yarn build)
3. **Package**: Összecsomagolja a szükséges fájlokat:
   - `ghost/core/core` - Ghost core fájlok
   - `ghost/core/content` - Content könyvtár
   - `ghost/admin/dist` - Admin UI build
   - `ghost/i18n` - Fordítások
   - `package.json` és `yarn.lock`
4. **ZIP**: ZIP archívumot készít
5. **Upload**: Feltölti SFTP-n a szerverre
6. **Deploy**: SSH-n keresztül:
   - Leállítja a Ghost-ot
   - Backup-ot készít
   - Kicsomagolja és frissíti a fájlokat
   - Telepíti a függőségeket
   - Futtatja a migrációkat
   - Újraindítja a Ghost-ot

## Fájlstruktúra a szerveren

```
/var/www/ghost/
├── config.production.json    # Ghost konfiguráció (nem érintett)
├── content/                   # Tartalom (csak első telepítésnél frissül)
│   ├── data/                 # Adatbázis (SQLite esetén)
│   ├── images/               # Feltöltött képek
│   └── themes/               # Témák
├── current/                   # Jelenlegi Ghost telepítés
│   ├── core/                 # Ghost core (FRISSÜL)
│   ├── content/              # Link a ../content-re
│   └── package.json
├── versions/                  # Ghost-CLI által kezelt verziók
└── backups/                   # Automatikus backup-ok
    └── 20250129_143022/      # Dátum-alapú backup-ok
```

## Hibaelhárítás

### "Ghost directory does not exist"
- Ellenőrizd, hogy a `GHOST_INSTALL_DIR` secret helyes-e
- Telepítsd a Ghost-ot a szerveren ghost-cli-vel

### "Permission denied"
- Ellenőrizd, hogy az SSH felhasználónak van-e írási joga a Ghost könyvtárhoz
- Futtasd: `sudo chown -R $USER:$USER /var/www/ghost`

### "Ghost-CLI not found"
- Telepítsd a ghost-cli-t: `npm install -g ghost-cli`
- Vagy használj teljes útvonalat: `/usr/local/bin/ghost`

### Deployment sikertelen
- Ellenőrizd a workflow logokat a GitHub Actions-ben
- A backup könyvtárban megtalálod a korábbi verziót
- Visszaállítás: `cp -r /var/www/ghost/backups/LATEST/current /var/www/ghost/`

## Testreszabás

### Branch váltása

Módosítsd a workflow fájlt (`.github/workflows/deploy-sftp.yml`):

```yaml
on:
  push:
    branches:
      - production  # Változtasd meg a branch nevet
```

### Több szerver kezelése

Készíts több workflow fájlt különböző környezetekhez:
- `deploy-staging.yml` - staging szerverhez
- `deploy-production.yml` - production szerverhez

Használj különböző GitHub secreteket:
- `STAGING_SFTP_HOST`
- `PRODUCTION_SFTP_HOST`

### Post-deployment scriptek

Add hozzá egyedi parancsokat a deployment script végéhez:

```yaml
script: |
  # ... meglévő deployment script ...
  
  # Egyedi post-deployment lépések
  cd $GHOST_DIR
  ghost doctor
  curl -X POST https://api.slack.com/webhooks/... -d '{"text":"Ghost deployed!"}'
```

## Biztonság

⚠️ **Fontos biztonsági megjegyzések:**

1. **Soha ne commitolj secreteket** a repository-ba
2. **Használj SSH kulcsot** jelszó helyett
3. **Korlátozd az SSH hozzáférést** csak a szükséges IP címekről
4. **Rendszeres backup-ok** - a workflow automatikusan készít, de használj külső backup rendszert is
5. **Staging környezet** - tesztelj staging szerveren először

## Támogatás

Ha problémád van, ellenőrizd:
- GitHub Actions logokat
- Ghost logokat: `/var/www/ghost/content/logs/`
- Rendszer logokat: `journalctl -u ghost_*`
