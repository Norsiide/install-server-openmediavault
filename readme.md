<p align="center"><img src="https://wiki.debian.org/FrontPage?action=AttachFile&do=get&target=11-bullseye-wiki-banner-04.png" width="400" alt="norsiide"></p>

# Installation d’un serveur dédié ou VPS sous OpenMediaVault 

* **OpenMediaVault** est un système de type NAS (Network Attached Storage) open source, basé sur Debian, conçu pour être simple à utiliser et accessible à tous.

<p align="center"><img src="https://github.com/Norsiide/install-openmediavault/blob/main/img/openmediavault.png" alt="norsiide"></p>

* **PS:** Je tiens à rappeler que cette configuration est basée sur mon propre serveur, que je rends public afin de vous aider dans l’installation. Il se peut donc que certaines informations manquent.
Dans ce cas, n’hésitez pas à me contacter, et je les ajouterai pour faciliter l’installation des prochains utilisateurs.

### Lien utiles

* **Discord** : [Rejoins notre communauté](https://discord.gg/EV3fAhFZJT)
* **Website** : [Plus d'information](https://norsiide.be)

* **OpenMediaVault** : [Lien ver OpenMediaVault](https://www.openmediavault.org/)

## Mise à jour et installation des paquets via SSH en ligne de commande (CLI).

(1) Nous allons mettre à jour tous les paquets du système :

```
apt update && apt upgrade
```
(1) Nous allons maintenant installer les dépendances dont nous aurons besoin pour la suite de l’installation.
```
apt install sudo && apt install curl && apt install nano && apt install git
``` 
(2) Nous allons maintenant procéder à l’installation de openmediavault.
 
```
sudo wget -O - https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install | sudo bash
```
MMaintenant, vous pouvez accéder à OpenMediavault en utilisant l'URL qui vous a été fournie lors de l'installation. Par exemple : 25.155.215.25.

<p align="center"><img src="https://github.com/Norsiide/install-openmediavault/blob/main/img/update-cli.png"  alt="update cli"></p>

## Dans cette étape, nous allons changer le port de OpenMediaVault.
* Accédez au menu des paramètres depuis le web GUI de OpenMediaVault, puis modifiez le port en (9090) à la place du port (80).
Ce changement est nécessaire car nous allons utiliser un conteneur avec Nginx Proxy Manager, qui nécessite les ports 80 et 443. Par conséquent, nous devons modifier le port par défaut de OpenMediaVault.
<p align="center"><img src="https://github.com/Norsiide/install-openmediavault/blob/main/img/omv-port.png"  alt="port omv"></p>

## Nous allons maintenant procéder à l’installation du script de connexion SSH.

* Repos [Liens](https://github.com/Norsiide/SSH-login-notifications/)

## Pour installer Neofetch, un script permettant d'afficher les informations système dans le terminal, suivez les étapes ci-dessous :

* Repos [Liens](https://github.com/Norsiide/install-openmediavault/tree/main/neofetch)

## Si vous n'avez pas besoin de l'IPv6, vous pouvez le désactiver. Cela n'est pas obligatoire, mais peut être utile selon vos besoins.

Vous pouvez maintenant exécuter la commande suivante pour procéder à l’action.:
 
```
nano /etc/sysctl.conf
```
Veuillez ajouter le code suivant dans votre terminal. :
```
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
```

Enfin, activez toutes les configurations en exécutant la commande suivante.
```
sudo sysctl -p
```
