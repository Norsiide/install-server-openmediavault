#!/bin/bash

LINKS_FILE="links.txt"
DOWNLOAD_DIR="$HOME/mega_downloads"
LOG_FILE="mega_cmd_download.log"

mkdir -p "$DOWNLOAD_DIR"
touch "$LOG_FILE"

echo "===== MEGA DOWNLOAD : $(date) =====" | tee -a "$LOG_FILE"

# Vérifie la connexion
if ! mega-whoami >/dev/null 2>&1; then
    echo "❌ Non connecté à MEGA" | tee -a "$LOG_FILE"
    echo "➡️ Lance : mega-login email@exemple.com"
    exit 1
fi

while IFS= read -r link || [[ -n "$link" ]]; do
    [[ -z "$link" || "$link" == \#* ]] && continue

    echo "⬇️ $link" | tee -a "$LOG_FILE"

    mega-get "$link" "$DOWNLOAD_DIR" >> "$LOG_FILE" 2>&1

    if [[ $? -eq 0 ]]; then
        echo "✅ OK" | tee -a "$LOG_FILE"
    else
        echo "❌ ERREUR" | tee -a "$LOG_FILE"
    fi
done < "$LINKS_FILE"

echo "===== FIN =====" | tee -a "$LOG_FILE"
