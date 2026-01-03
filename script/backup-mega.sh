#!/bin/bash

# Charge les variables d'environnement depuis un fichier .env (optionnel)
ENV_FILE="./.env"
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

# === CONFIGURATION ===
LOCAL_DIR="/DATA"
MEGA_DIR="/backup"
MEGA_EMAIL="ton email"
MEGA_PASSWORD="ton mot de passe"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/13631"
DAYS_TO_KEEP=1

# === VARIABLES INTERNES ===
DATE_TAG=$(date +"%Y-%m-%d_%H-%M")
ARCHIVE_NAME="backup_${DATE_TAG}.zip"
ARCHIVE_PATH="/tmp/$ARCHIVE_NAME"
ERROR_LOG="/tmp/backup_error.log"

# === FONCTIONS ===
send_discord_notification() {
    local title="$1"; local description="$2"; local color="$3"; shift; shift; shift
    local fields="$@"
 
    # Construit le JSON via jq
    payload=$(jq -n \
      --arg title "$title" \
      --arg desc "$description" \
      --arg timestamp "$(date --utc +%FT%TZ)" \
      --argjson color "$color" \
      --argjson fields "$fields" \
      '{ embeds: [{
        title: $title,
        description: $desc,
        color: $color,
        timestamp: $timestamp,
        fields: $fields
      }] }')

    # Envoie et capture le code HTTP
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST -H "Content-Type: application/json" -d "$payload" \
      "$DISCORD_WEBHOOK")
    echo "→ Discord webhook HTTP code: $http_code"
    # Log si erreur
    if [ "$http_code" -ne 204 ]; then
      echo "$(date): Webhook Discord a répondu $http_code" >> "$ERROR_LOG"
    fi
}

log_error() {
    echo "$(date): $1" >> "$ERROR_LOG"
    send_discord_notification "❌ Erreur lors du backup" "$1" 16711680 '[{"name": "Détails", "value": "'"$1"'", "inline": false}]'
}

# === DÉBUT DU SCRIPT ===
start_time=$(date +%s)

# Vérif dépendances
for cmd in mega-login mega-put mega-rm mega-ls zip jq; do
  command -v "$cmd" >/dev/null 2>&1 || { log_error "Commande manquante : $cmd"; exit 1; }
done
[ ! -d "$LOCAL_DIR" ] && log_error "Le dossier $LOCAL_DIR n'existe pas." && exit 1

# Connexion Mega
mega-login "$MEGA_EMAIL" "$MEGA_PASSWORD" >/dev/null 2>&1 \
  || { log_error "Échec de connexion à Mega.nz"; exit 1; }

# Compression (Exclure uniquement les fichiers .desktop)
echo "📦 Compression de $LOCAL_DIR → $ARCHIVE_PATH"
zip -r "$ARCHIVE_PATH" "$LOCAL_DIR" -x "*.desktop" >/dev/null \
  || { log_error "Échec de la création de l'archive ZIP"; mega-logout; exit 1; }
ARCHIVE_SIZE=$(du -sh "$ARCHIVE_PATH" | awk '{print $1}')
FILE_COUNT=$(zipinfo -1 "$ARCHIVE_PATH" | wc -l)

# Construct fields as a JSON array
fields=$(jq -n \
  --arg archive "$ARCHIVE_NAME" \
  --arg size "$ARCHIVE_SIZE" \
  --arg count "$FILE_COUNT" \
  '[{
    "name": "📦 Archive",
    "value": $archive,
    "inline": false
  }, {
    "name": "🧳 Taille",
    "value": $size,
    "inline": true
  }, {
    "name": "📂 Fichiers",
    "value": $count,
    "inline": true
  }]')

send_discord_notification "🔄 Début du Backup vers Mega" \
"**Préparation du backup**" 3447003 "$fields"

# Upload
echo "☁️ Envoi de l'archive vers $MEGA_DIR"
mega-put "$ARCHIVE_PATH" "$MEGA_DIR" >/dev/null \
  || { log_error "Échec de l'envoi de l'archive sur Mega"; mega-logout; exit 1; }

# Suppression des anciens ZIP (basée sur la date dans le nom)
echo "🧹 Suppression des anciens ZIP…"
deleted_count=0
now_epoch=$(date +%s)
mega-ls "$MEGA_DIR" > /tmp/mega_files.log

while read -r file; do
  if [[ $file =~ backup_([0-9]{4}-[0-9]{2}-[0-9]{2})_([0-9]{2}-[0-9]{2})\.zip$ ]]; then
    file_date="${BASH_REMATCH[1]}"
    file_epoch=$(date -d "$file_date" +%s 2>/dev/null) || continue
    age_days=$(( (now_epoch - file_epoch) / 86400 ))
    if [ "$age_days" -gt "$DAYS_TO_KEEP" ]; then
      echo "🗑️ Suppression de $file ($age_days jours)"
      mega-rm "$MEGA_DIR/$file" >/dev/null \
        && { echo "✅ Supprimé : $file"; ((deleted_count++)); } \
        || echo "❌ Échec suppression : $file"
    fi
  fi
done < /tmp/mega_files.log

# Nettoyage local
rm -f "$ARCHIVE_PATH"
mega-logout >/dev/null

# Calcul de la durée
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
h=$(( elapsed/3600 )); m=$(( (elapsed%3600)/60 )); s=$(( elapsed%60 ))
duration=$(printf "%02dh %02dm %02ds" "$h" "$m" "$s")

# Construct final fields as a JSON array
final_fields=$(jq -n \
  --arg archive "$ARCHIVE_NAME" \
  --arg size "$ARCHIVE_SIZE" \
  --arg count "$FILE_COUNT" \
  --arg deleted "$deleted_count" \
  --arg duration "$duration" \
  '[{
    "name": "🏁 Archive créée",
    "value": $archive,
    "inline": false
  }, {
    "name": "📏 Taille",
    "value": $size,
    "inline": true
  }, {
    "name": "🗃️ Fichiers",
    "value": $count,
    "inline": true
  }, {
    "name": "🗑️ supprimés",
    "value": $deleted,
    "inline": true
  }, {
    "name": "⏱️ Durée totale",
    "value": $duration,
    "inline": true
  }]')

send_discord_notification "✅ Backup terminé avec succès" \
"**Fin du backup Mega**" 5763719 "$final_fields"

echo "✅ Backup terminé en $duration, $deleted_count anciens fichiers supprimés."
