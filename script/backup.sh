#!/bin/bash

# === CONFIGURATION ===
SRC_DIRS=(
"/dossier1" # Ajouter un dossiers
"/dossier2" # Ajouter d'autres dossiers si nécessaire
)

DEST="/folder_de_backup" # Chemin vers le dossier de destination des backups
BACKUP_ROOT="$DEST/backup-$(date +%Y-%m-%d)" # Dossier de sauvegarde avec date
RETENTION_DAYS=7 # Nombre de jours avant suppression des anciennes sauvegardes
LOG="/var/log/rsync_backup.log" # Fichier de log local
ERROR_LOG_FILE="/tmp/rsync_error.log" # Fichier temporaire pour les erreurs 
> "$ERROR_LOG_FILE"

DISCORD_WEBHOOK="https://discord.com/api/webhooks/XXXXXXXX/XXXXXXXX" # URL du webhook Discord
HOSTNAME=$(hostname)

# === EXCLUSIONS ===
EXCLUDES=("node_modules/" ".cache/" "Downloads/" "tmp/")
EXCLUDE_PARAMS=()
for excl in "${EXCLUDES[@]}"; do
    EXCLUDE_PARAMS+=(--exclude="$excl")
done

# === DÉBUT ===
DATE=$(date "+%Y-%m-%d")
START_TIME=$(date +%s)
mkdir -p "$BACKUP_ROOT"

DIR_SUMMARY=""
TOTAL_SIZE_BYTES=0

# === SAUVEGARDE ===
for SRC in "${SRC_DIRS[@]}"; do
    BASENAME=$(basename "$SRC")
    DEST_DIR="$BACKUP_ROOT/$BASENAME"
    mkdir -p "$DEST_DIR"

    START_DIR=$(date +%s)
    RSYNC_OUTPUT=$(rsync -avh --info=progress2 --no-links --delete \
        "${EXCLUDE_PARAMS[@]}" "$SRC/" "$DEST_DIR" 2>&1)
    RSYNC_EXIT_CODE=$?
    END_DIR=$(date +%s)

    DURATION=$((END_DIR - START_DIR))
    DURATION_FMT=$(printf '%02dh:%02dm:%02ds' \
        $((DURATION/3600)) $((DURATION%3600/60)) $((DURATION%60)))

    SIZE=$(du -sh "$DEST_DIR" 2>/dev/null | cut -f1)
    SIZE_BYTES=$(du -sb "$DEST_DIR" 2>/dev/null | cut -f1)
    TOTAL_SIZE_BYTES=$((TOTAL_SIZE_BYTES + SIZE_BYTES))

    DIR_SUMMARY+="• **$BASENAME** → $SIZE | ⏱ $DURATION_FMT\n"

    if [ $RSYNC_EXIT_CODE -ne 0 ] && [ $RSYNC_EXIT_CODE -ne 23 ]; then
        echo -e "[$BASENAME]\n$RSYNC_OUTPUT\n" >> "$ERROR_LOG_FILE"
    fi
done

TOTAL_SIZE=$(numfmt --to=iec --suffix=B "$TOTAL_SIZE_BYTES")

# === RÉTENTION ===
DELETED_BACKUPS=""
OLD_BACKUPS=$(find "$DEST" -maxdepth 1 -type d -name "backup-*" -mtime +$RETENTION_DAYS)

if [ -n "$OLD_BACKUPS" ]; then
    while read -r folder; do
        rm -rf "$folder"
        DELETED_BACKUPS+="🗑️ $(basename "$folder")\n"
    done <<< "$OLD_BACKUPS"
fi

# === TEMPS TOTAL ===
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
TOTAL_DURATION_FMT=$(printf '%02dh:%02dm:%02ds' \
    $((TOTAL_DURATION/3600)) $((TOTAL_DURATION%3600/60)) $((TOTAL_DURATION%60)))

# === EMBED DISCORD ===
if [ -s "$ERROR_LOG_FILE" ]; then
    TITLE="❌ ERREUR DE SAUVEGARDE"
    COLOR=15158332
    STATUS="⚠️ Des erreurs ont été détectées"
else
    TITLE="✅ SAUVEGARDE TERMINÉE"
    COLOR=3066993
    STATUS="Tout s'est déroulé correctement"
fi

PAYLOAD=$(jq -n \
  --arg title "$TITLE" \
  --arg host "$HOSTNAME" \
  --arg date "$DATE" \
  --arg summary "$DIR_SUMMARY" \
  --arg size "$TOTAL_SIZE" \
  --arg duration "$TOTAL_DURATION_FMT" \
  --arg deleted "$DELETED_BACKUPS" \
  --arg status "$STATUS" \
  --argjson color "$COLOR" \
'{
  embeds: [
    {
      title: $title,
      color: $color,
      description: $status,
      fields: [
        { "name": "💻 Machine", "value": $host, "inline": true },
        { "name": "📅 Date", "value": $date, "inline": true },
        { "name": "📁 Sauvegardes", "value": $summary },
        { "name": "📊 Taille totale", "value": $size, "inline": true },
        { "name": "⏱ Temps total", "value": $duration, "inline": true }
      ],
      footer: {
        text: "Backup automatique • OpenMediaVault"
      }
    }
  ]
}')

# === ENVOI DISCORD ===
curl -s -H "Content-Type: application/json" \
     -X POST \
     -d "$PAYLOAD" \
     "$DISCORD_WEBHOOK" >/dev/null

# === LOG ERREUR LOCAL (si présent) ===
if [ -s "$ERROR_LOG_FILE" ]; then
    echo "[ERREUR] $(date)" >> "$LOG"
    cat "$ERROR_LOG_FILE" >> "$LOG"
fi
