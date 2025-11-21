# GitHub Secrets példa konfiguráció

## Minimális konfiguráció (egy szerver)

```env
DEPLOY_HOST=example.com
DEPLOY_USER=ghost
DEPLOY_PASSWORD=YourSecurePassword123!
DEPLOY_PATH=/var/www/ghost
```

## Teljes konfiguráció (staging + production)

### Production környezet
```env
PRODUCTION_HOST=prod.example.com
PRODUCTION_USER=ghost-prod
PRODUCTION_PASSWORD=ProdSecurePass123!
PRODUCTION_PATH=/var/www/ghost
```

### Staging környezet
```env
STAGING_HOST=staging.example.com
STAGING_USER=ghost-staging
STAGING_PASSWORD=StagingSecurePass123!
STAGING_PATH=/var/www/ghost-staging
```

## SFTP specifikus konfiguráció

```env
SFTP_HOST=example.com
SFTP_USERNAME=ghost
SFTP_PASSWORD=YourPassword123!
SFTP_PORT=22
SFTP_REMOTE_PATH=/tmp
GHOST_INSTALL_DIR=/var/www/ghost
```

## SSH kulcs használata

Ha SSH private key-t használsz jelszó helyett:

```env
DEPLOY_HOST=example.com
DEPLOY_USER=ghost
DEPLOY_PASSWORD=-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACDFq1234567890abcdefghijklmnopqrstuvwxyz+ABCDEFGH==
-----END OPENSSH PRIVATE KEY-----
```

## MySQL adatbázis konfiguráció (opcionális)

Ha az automatikus telepítés során szeretnéd használni:

```env
DB_HOST=localhost
DB_USER=ghost_user
DB_PASSWORD=SecureDBPassword123!
DB_NAME=ghost_production
```

## Email konfiguráció (opcionális)

```env
MAIL_TRANSPORT=SMTP
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your-email@gmail.com
MAIL_PASSWORD=your-app-specific-password
```

## Slack értesítések (opcionális)

```env
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

---

## Hogyan add hozzá GitHub-on?

1. Menj a repository Settings oldalára
2. Kattints a **Secrets and variables** → **Actions**
3. Kattints a **New repository secret** gombra
4. Add meg a nevet (pl. `DEPLOY_HOST`) és az értéket
5. Kattints a **Add secret** gombra
6. Ismételd meg minden secret-tel

## Biztonsági ellenőrzőlista

- [ ] Használj erős jelszavakat (min. 16 karakter)
- [ ] SSH kulcsot használj jelszó helyett (ajánlott)
- [ ] Korlátozott jogosultságú felhasználót használj
- [ ] Ne commitolj secret-eket a repository-ba
- [ ] Rendszeresen változtasd a jelszavakat
- [ ] Használj 2FA-t a GitHub accountodon
- [ ] Korlátozd az SSH hozzáférést IP alapján
- [ ] Használj firewall-t a szerveren

## Tesztelés

Mielőtt éles környezetben használnád, teszteld staging környezetben!

```bash
# Staging telepítése
ssh staging-user@staging.example.com
cd /var/www/ghost-staging
ghost install --url https://staging.example.com
```
