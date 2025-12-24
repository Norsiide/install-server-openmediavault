<p align="center"><img src="https://wiki.debian.org/FrontPage?action=AttachFile&do=get&target=11-bullseye-wiki-banner-04.png" width="auto" alt="norsiide"></p>

# Installation d’un serveur dédié ou VPS sous OpenMediaVault

* **OpenMediaVault** est un système de type NAS (Network Attached Storage) open source, basé sur Debian, conçu pour être simple d’utilisation et accessible à tous.

<p align="center"><img src="https://github.com/Norsiide/install-openmediavault/blob/main/img/openmediavault.png" alt="openmediavault"></p>

> **PS :** Cette configuration est basée sur mon propre serveur, que je partage publiquement afin de vous aider dans l’installation. Certaines informations peuvent manquer ; n’hésitez pas à me contacter pour que je les ajoute et facilite ainsi l’installation pour les prochains utilisateurs.

Les tutoriels concernant les conteneurs Docker Compose seront disponibles dans des dossiers dédiés au sein de ce guide.

---

### Liens utiles

* **Discord** : [Rejoins notre communauté](https://discord.gg/EV3fAhFZJT)
* **Site web** : [Plus d'informations](https://norsiide.be)
* **OpenMediaVault** : [Lien vers OpenMediaVault](https://www.openmediavault.org/)

---

## Mise à jour et installation des paquets via SSH (CLI)

### (1) Mise à jour du système

```
apt update && apt upgrade
```

### (2) Installation des dépendances nécessaires

```
apt install sudo curl nano git
```

### (3) Installation de OpenMediaVault

```
sudo wget -O - https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install | sudo bash
```

Une fois l’installation terminée, vous pouvez accéder à OpenMediaVault via l’URL indiquée à la fin du script.
**Exemple :** `25.155.215.25`

<p align="center"><img src="https://github.com/Norsiide/install-openmediavault/blob/main/img/update-cli.png" alt="update cli"></p>

---

## Modifier le port d’accès à OpenMediaVault

Accédez à l’interface web d’OpenMediaVault, puis rendez-vous dans les paramètres pour changer le port d’accès.
Remplacez le port **80** par **9090**.

Ce changement est nécessaire, car nous allons utiliser un conteneur **Nginx Proxy Manager**, qui utilise les ports **80** et **443**.

<p align="center"><img src="https://github.com/Norsiide/install-openmediavault/blob/main/img/omv-port.png" alt="port omv"></p>

---

## Installation du script de notification de connexion SSH

* Dépôt GitHub : [Lien](https://github.com/Norsiide/SSH-login-notifications/)

---

## Installation de Neofetch

Neofetch permet d’afficher les informations système dans le terminal, de manière claire et esthétique.

* Dépôt GitHub : [Lien](https://github.com/Norsiide/install-openmediavault/tree/main/neofetch)

---

## Désactiver l’IPv6 (optionnel)

Si vous n’avez pas besoin de l’IPv6, vous pouvez le désactiver.
Cela n’est pas obligatoire, mais peut être utile selon vos besoins.

### Édition du fichier de configuration

```
nano /etc/sysctl.conf
```

Ajoutez les lignes suivantes :

```
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
```

### Appliquer les modifications

```
sudo sysctl -p
```