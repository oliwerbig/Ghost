#!/bin/bash

# GitHub Secrets Setup Helper Script
# Ez a script segít feltölteni a .env fájl tartalmát GitHub Secrets-ként

set -e

# Színek
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  GitHub Secrets Setup Helper                              ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""

# Ellenőrzés: létezik-e a .env fájl
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Hiba: .env fájl nem található!${NC}"
    echo ""
    echo "Először hozd létre a .env fájlt:"
    echo -e "${YELLOW}cp .github/workflows/.env.example .env${NC}"
    echo "Majd töltsd ki a saját adataiddal!"
    exit 1
fi

# GitHub CLI ellenőrzése
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) nincs telepítve${NC}"
    echo ""
    echo "Két lehetőséged van:"
    echo ""
    echo "1️⃣  Telepítsd a GitHub CLI-t (ajánlott):"
    echo "   • macOS: brew install gh"
    echo "   • Ubuntu/Debian: sudo apt install gh"
    echo "   • Vagy: https://cli.github.com/"
    echo ""
    echo "2️⃣  Vagy add hozzá manuálisan a GitHub webes felületen:"
    echo "   • GitHub repository → Settings → Secrets and variables → Actions"
    echo "   • New repository secret"
    echo "   • Másold be az értékeket a .env fájlból"
    echo ""
    exit 0
fi

# GitHub bejelentkezés ellenőrzése
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}⚠️  Nem vagy bejelentkezve GitHub-ra${NC}"
    echo ""
    echo "Jelentkezz be a következő paranccsal:"
    echo -e "${GREEN}gh auth login${NC}"
    echo ""
    exit 1
fi

# Repository ellenőrzése
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -z "$REPO" ]; then
    echo -e "${RED}❌ Nem sikerült meghatározni a repository-t${NC}"
    echo ""
    echo "Bizonyosodj meg róla, hogy Git repository-ban vagy!"
    exit 1
fi

echo -e "${GREEN}✓ Repository: $REPO${NC}"
echo ""

# .env fájl beolvasása
echo -e "${BLUE}📋 .env fájl beolvasása...${NC}"
echo ""

# Secrets feldolgozása
SECRETS_ADDED=0
SECRETS_SKIPPED=0

while IFS='=' read -r key value; do
    # Kihagyjuk az üres sorokat és kommenteket
    if [[ -z "$key" ]] || [[ "$key" =~ ^[[:space:]]*# ]]; then
        continue
    fi

    # Whitespace eltávolítása
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    # Kihagyjuk a placeholder értékeket
    if [[ "$value" == "example.com" ]] || [[ "$value" == "ghost" ]] || [[ "$value" =~ ^Your.*Password ]] || [[ "$value" =~ ^Secure.*Password ]] || [[ "$value" =~ ^your- ]]; then
        echo -e "${YELLOW}⊘ Kihagyva: $key (placeholder érték)${NC}"
        ((SECRETS_SKIPPED++))
        continue
    fi

    # Üres érték kihagyása
    if [[ -z "$value" ]]; then
        continue
    fi

    # Secret hozzáadása
    echo -e "${BLUE}➜ $key hozzáadása...${NC}"

    # Idézőjelek eltávolítása
    value="${value%\"}"
    value="${value#\"}"

    if echo "$value" | gh secret set "$key" -R "$REPO"; then
        echo -e "${GREEN}  ✓ Sikeresen hozzáadva${NC}"
        ((SECRETS_ADDED++))
    else
        echo -e "${RED}  ✗ Hiba történt${NC}"
    fi
    echo ""

done < .env

# Összefoglaló
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Kész!${NC}"
echo ""
echo -e "${GREEN}✓ Sikeresen hozzáadott secrets: $SECRETS_ADDED${NC}"
echo -e "${YELLOW}⊘ Kihagyott placeholder értékek: $SECRETS_SKIPPED${NC}"
echo ""
echo "Ellenőrizd a secrets-et:"
echo -e "${BLUE}https://github.com/$REPO/settings/secrets/actions${NC}"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Most már futtathatod a deployment workflow-t:"
echo -e "${GREEN}• GitHub → Actions → Deploy to SFTP → Run workflow${NC}"
echo ""
