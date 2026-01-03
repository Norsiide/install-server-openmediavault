<p align="center"><img src="https://wiki.debian.org/FrontPage?action=AttachFile&do=get&target=11-bullseye-wiki-banner-04.png" width="400" alt="norsiide"></p>

**tutoriel détaillé** pour **mettre en place le script de sauvegarde** avec les bonnes étapes et les paquets nécessaires.

---

# 📜 **Tutoriel complet pour le script de sauvegarde avec notification Discord**

---

### Prérequis

Avant de commencer, voici les paquets et outils nécessaires :

1. **`rsync`** pour la sauvegarde.
2. **`jq`** pour créer et manipuler des messages JSON (format utilisé par Discord).
3. **`curl`** pour envoyer la notification au webhook Discord.

---

## 🔧 **Étape 1 : Installer les paquets nécessaires**

Commence par installer les outils nécessaires à l'exécution du script. Ouvre un terminal sur ton serveur Debian et tape les commandes suivantes :

```bash
sudo apt update
sudo apt install rsync jq curl -y
```

---

## 🛠️ **Étape 2 : Créer le script de sauvegarde**

1. Crée le fichier du script dans le répertoire `/usr/local/bin/` :
   ```bash
   sudo nano /usr/local/bin/backup.sh
   ```

2. Copie et colle le **script complet** qui ce trouve dans le fichier backup.sh.

3. Sauvegarde et ferme l’éditeur (`CTRL + O`, puis `CTRL + X`).

4. **Rends le script exécutable** :
   ```bash
   sudo chmod +x /usr/local/bin/backup.sh
   ```

---

## 📝 **Étape 3 : Configurer le Webhook Discord**

1. Dans **Discord**, va dans le canal où tu veux recevoir les notifications de sauvegarde.
2. Clique sur les **paramètres du canal**, puis dans **Webhooks**.
3. Crée un **nouveau webhook**, copie son **URL** et remplace la dans le script à cette ligne :
   ```bash
   WEBHOOK_URL="https://discord.com/api/webhooks/TON_ID/TON_TOKEN"
   ```

> Remplace `TON_ID` et `TON_TOKEN` par l'URL complète que tu as récupérée.

---

## 📅 **Étape 4 : Automatiser le script avec Cron**

Pour automatiser la sauvegarde tous les jours, tu peux ajouter le script à la crontab.

1. Ouvre la crontab pour l'édition :
   ```bash
   crontab -e
   ```

2. Ajoute cette ligne à la fin du fichier pour exécuter le script tous les jours à **2h00** du matin :
   ```bash
   0 2 * * * /usr/local/bin/backup.sh >> /var/log/rsync_backup.log 2>&1
   ```

3. Sauvegarde et ferme (`CTRL + O`, puis `CTRL + X`).

> Cela exécutera le script de sauvegarde tous les jours à 2h00 du matin et enregistrera les logs dans `/var/log/rsync_backup.log`.

---

## 📑 **Étape 5 : Tester la notification Discord**

Si tu veux tester uniquement la notification Discord (sans faire une vraie sauvegarde), tu peux modifier légèrement le script. Voici comment faire :

1. **Ajoute un test de message Discord** au début du script :
   ```bash
   curl -H "Content-Type: application/json" \
        -X POST \
        -d '{"content": "@here \nTest de la notification Discord !"}' \
        "https://discord.com/api/webhooks/TON_ID/TON_TOKEN"
   ```

2. Exécute le script manuellement pour vérifier si tu reçois bien le message dans Discord.

---

## 🧑‍💻 **Étape 6 : Personnaliser le script**

Si tu veux personnaliser davantage le script, voici quelques options :

- **Ajouter d’autres dossiers à sauvegarder** : Dans la section `SRC_DIRS=()`, ajoute ou modifie les chemins des dossiers à sauvegarder.
- **Exclure d'autres dossiers** : Dans `EXCLUDES=()`, ajoute les dossiers à exclure de la sauvegarde.
- **Changer la rétention des backups** : Le nombre de jours avant de supprimer les anciennes sauvegardes peut être modifié dans `RETENTION_DAYS=7`.

---

## 📦 **Résultat attendu**

1. **Backup quotidien** à l'heure que tu as définie (2h00).
2. **Notification Discord** :
   - Message vert ✅ si tout va bien.
   - Message rouge ❌ avec logs d'erreur si quelque chose ne va pas.
3. **Nettoyage des anciens backups** après 7 jours (modifiable).

---

## 🧑‍💻 **Exemple de message Discord en cas d'échec**

Si une erreur survient, tu devrais voir un message comme ceci dans Discord :

> **❌ Erreur de sauvegarde**  
> **Machine** : server01  
> **Date** : 2025-04-19  
> **Logs d'erreur** :  
> ```
> rsync: permission denied (13)
> rsync: failed to set times
> rsync error: some files/attrs were not transferred
> ```

Et tu recevras une **mention `@here`** pour alerter l'équipe ou les administrateurs.

---

## 📝 **Étape 7 : Vérifier les logs**

Tu peux consulter les logs de la sauvegarde pour vérifier si tout s'est bien passé en consultant le fichier `/var/log/rsync_backup.log` :

```bash
cat /var/log/rsync_backup.log
```

---

## 🎯 **Conclusion**

Avec ce script de sauvegarde automatique, tu as une **solution complète de backup** avec un système de **nettoyage automatique** et une **notification Discord** pour te tenir informé de l'état des sauvegardes. 😎