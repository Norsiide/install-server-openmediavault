<p align="center"><img src="https://github.com/Norsiide/install-openmediavault/blob/main/img/docker.png" width="auto" alt="norsiide"></p>

# installation de docker + docker compose

* **Docker compose** est une application complémentaire à Docker.
Son principal avantage est qu’au lieu d’utiliser de longues commandes pour gérer les conteneurs, il permet de centraliser toute la configuration dans un fichier unique (docker-compose.yml).

Grâce à ce fichier, on dispose d’une vue claire et structurée de la configuration des conteneurs (images, volumes, ports, variables, redémarrage, etc.), ce qui rend la gestion plus simple, plus lisible et plus flexible qu’avec des commandes Docker classiques.

<p align="center"><img src="https://github.com/Norsiide/install-openmediavault/blob/main/img/docker-compose.png" alt="openmediavault"></p>

---

### configuration des volumes 

* **condifuration des applications** : 
    - /mnt/docker-compose/backup # Ou les sauvegarde que docker peut effectué
    - /mnt/docker-compose/config # Ou les configuration du container
    - /mnt/docker-compose/data # ou le serveur va stocker les donnée d'applications
* **raid 1( MIRROIR )** : 
    - /srv/dev-disk-by-uuid-id_du_disque/downloads #exemple
Celui ci est celui ou toute les donnée son stocker (Films, download, livre, ect)

---


## 🧠 Qu’est-ce que OMV-Extras ?

**OMV-Extras** est un dépôt de plugins supplémentaires pour OpenMediaVault.
Il permet notamment d’installer :

* Docker
* Docker Compose (v2)
* Portainer
* Autres outils avancés

---

## 🔹 Étape 1 – Installer OMV-Extras

Connecte-toi en **SSH** sur ton serveur OMV puis exécute :

```bash
wget -O - https://github.com/OpenMediaVault-Plugin-Developers/packages/raw/master/install | bash
```

Une fois terminé :

* reconnecte-toi à l’interface web OMV
* rafraîchis la page si nécessaire

## 🔹 Étape 2 – Installer docker
<p align="center"><img src="https://github.com/Norsiide/install-openmediavault/blob/main/img/install-docker.png" alt="openmediavault"></p>

* coche la case (Docker repo)

* puis -> enable backports

---

## 🔹 Étape 3 – Installer Docker via l’interface OMV

1. Va dans **System → Plugins**
2. Installe le plugin :

   ```
   openmediavault-compose
   ```

   *(ou Docker si ce n’est pas encore fait)*
