# 🔐 Secrets Beállítási Útmutató

## Gyors Setup (3 mód)

### 🚀 Mód 1: Automatikus (GitHub CLI-vel) - LEGGYORSABB

```bash
# 1. Másold le a .env.example fájlt
cp .github/workflows/.env.example .env

# 2. Szerkeszd meg a .env fájlt a saját adataiddal
nano .env
# vagy
code .env

# 3. Futtasd a setup scriptet
.github/workflows/setup-secrets.sh
```

**Kész!** A script automatikusan feltölti az összes secret-et GitHub-ra.

---

### 📝 Mód 2: GitHub CLI manuálisan

```bash
# GitHub CLI telepítése (ha még nincs)
# macOS:
brew install gh

# Linux:
sudo apt install gh

# Windows:
winget install GitHub.cli

# Bejelentkezés
gh auth login

# Secrets hozzáadása egyesével
gh secret set DEPLOY_HOST -b "your-server.com"
gh secret set DEPLOY_USER -b "ghost"
gh secret set DEPLOY_PASSWORD -b "your-password"
gh secret set DEPLOY_PATH -b "/var/www/ghost"

# Vagy fájlból
gh secret set DEPLOY_PASSWORD < ~/.ssh/github_deploy
```

---

### 🌐 Mód 3: Webes felület (manuális)

1. **Menj a GitHub repository-ba:**
   ```
   https://github.com/YOUR_USERNAME/Ghost
   ```

2. **Kattints a Settings (⚙️) tabra**

3. **Bal oldali menüben:**
   ```
   Secrets and variables → Actions
   ```

4. **Kattints a "New repository secret" gombra**

5. **Add hozzá egyesével a secrets-eket:**

   | Name | Value |
   |------|-------|
   | `DEPLOY_HOST` | `your-server.com` |
   | `DEPLOY_USER` | `ghost` |
   | `DEPLOY_PASSWORD` | `your-password` |
   | `DEPLOY_PATH` | `/var/www/ghost` |

6. **Opcionális secrets (staging/production):**

   | Name | Value |
   |------|-------|
   | `PRODUCTION_HOST` | `prod.your-server.com` |
   | `PRODUCTION_USER` | `ghost-prod` |
   | `PRODUCTION_PASSWORD` | `prod-password` |
   | `PRODUCTION_PATH` | `/var/www/ghost` |
   | `STAGING_HOST` | `staging.your-server.com` |
   | `STAGING_USER` | `ghost-staging` |
   | `STAGING_PASSWORD` | `staging-password` |
   | `STAGING_PATH` | `/var/www/ghost-staging` |

---

## 🔑 SSH Kulcs használata (AJÁNLOTT)

### Miért használj SSH kulcsot?
- ✅ Biztonságosabb mint jelszó
- ✅ Nem kell jelszót tárolni
- ✅ Könnyebb kulcs rotáció
- ✅ Jobb audit trail

### SSH kulcs generálása és beállítása:

```bash
# 1. Kulcspár generálása
ssh-keygen -t ed25519 -f ~/.ssh/github_deploy -C "github-actions"

# Enter drükk a passphrase kérdéseknél (ne adj meg jelszót)

# 2. Public key másolása a szerverre
ssh-copy-id -i ~/.ssh/github_deploy.pub your-user@your-server.com

# Vagy manuálisan:
cat ~/.ssh/github_deploy.pub
# Másold a kimenet, majd a szerveren:
# mkdir -p ~/.ssh && echo "PUBLIC_KEY_CONTENT" >> ~/.ssh/authorized_keys

# 3. Private key hozzáadása GitHub Secret-ként
cat ~/.ssh/github_deploy

# Másold ki a teljes kimenetet (az -----BEGIN és -----END sorokat is!)
# És add hozzá a DEPLOY_PASSWORD secret-ként a GitHub-on
```

### SSH kulcs tesztelése:

```bash
# Tesztelés jelszó nélkül
ssh -i ~/.ssh/github_deploy your-user@your-server.com

# Ha működik, akkor a GitHub Actions is működni fog!
```

---

## ✅ Ellenőrzés

### Secrets ellenőrzése GitHub-on:

1. **Webes felület:**
   ```
   https://github.com/YOUR_USERNAME/Ghost/settings/secrets/actions
   ```

2. **CLI-vel:**
   ```bash
   gh secret list
   ```

### Tesztelés:

```bash
# 1. Próbáld ki a deployment workflow-t
# GitHub → Actions → "Simple Deploy to Production" → Run workflow

# 2. Vagy CLI-vel:
gh workflow run deploy-simple.yml
```

---

## 🛡️ Biztonsági Checklist

Mielőtt éles környezetben használnád:

- [ ] Használj SSH kulcsot jelszó helyett
- [ ] Erős jelszavak (min. 16 karakter, vegyes karakterek)
- [ ] `.env` fájl a `.gitignore`-ban van
- [ ] Soha ne commitolj jelszavakat a repository-ba
- [ ] GitHub 2FA bekapcsolva
- [ ] Korlátozott jogosultságú felhasználó a szerveren
- [ ] Firewall konfiguráció (csak szükséges portok)
- [ ] SSH port változtatása (opcionális, de ajánlott)
- [ ] Fail2ban vagy hasonló telepítve
- [ ] Rendszeres secret rotáció (90 naponta)

---

## 🔄 Secret Rotáció

Secrets frissítése:

```bash
# 1. Generálj új SSH kulcsot
ssh-keygen -t ed25519 -f ~/.ssh/github_deploy_new

# 2. Add hozzá a szerverhez
ssh-copy-id -i ~/.ssh/github_deploy_new.pub user@server

# 3. Frissítsd a GitHub Secret-et
gh secret set DEPLOY_PASSWORD < ~/.ssh/github_deploy_new

# 4. Tesztelés után töröld a régi kulcsot a szerverről
ssh user@server "sed -i '/OLD_KEY_FINGERPRINT/d' ~/.ssh/authorized_keys"
```

---

## 🐛 Hibaelhárítás

### "Secret not found"
```bash
# Ellenőrizd, hogy létezik-e:
gh secret list

# Ha nem, add hozzá:
gh secret set SECRET_NAME -b "value"
```

### "gh: command not found"
```bash
# Telepítsd a GitHub CLI-t:
# macOS:
brew install gh

# Ubuntu/Debian:
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### "Permission denied (publickey)"
```bash
# Ellenőrizd az SSH kulcsot:
ssh -i ~/.ssh/github_deploy -v user@server

# Ellenőrizd a szerveren az authorized_keys jogosultságokat:
ssh user@server "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

### ".env file contains passwords"
```bash
# Ellenőrizd a .gitignore-t:
cat .gitignore | grep .env

# Ha nincs benne, add hozzá:
echo ".env" >> .gitignore
echo ".github/workflows/.env" >> .gitignore

# Távolítsd el a git-ből, ha véletlenül commitoltad:
git rm --cached .env
git commit -m "Remove .env from git"
```

---

## 📚 További források

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [SSH Key Best Practices](https://www.ssh.com/academy/ssh/keygen)
- [Ghost Deployment Guide](https://ghost.org/docs/hosting/)

---

## 💡 Pro tippek

1. **Environment-specifikus secrets**
   - Használj prefix-et: `PROD_`, `STAGING_`
   - Könnyebb kezelni több környezetet

2. **Secret értékek tesztelése**
   ```bash
   # Teszteld a connection-t manuálisan
   ssh $DEPLOY_USER@$DEPLOY_HOST "echo 'Connection OK'"
   ```

3. **Backup készítése a secrets-ekről**
   ```bash
   # Exportáld a .env fájlt biztonságos helyre
   cp .env ~/.secrets/ghost-deploy-$(date +%Y%m%d).env
   chmod 600 ~/.secrets/ghost-deploy-*.env
   ```

4. **Secrets verziózása**
   - Használj password managet (1Password, Bitwarden, stb.)
   - Tartsd karban a secrets történetét

---

**🎉 Most már készen állsz a deployment-re!**

Következő lépés: Próbáld ki a deployment-et!
```bash
# GitHub → Actions → Deploy to SFTP → Run workflow
```
