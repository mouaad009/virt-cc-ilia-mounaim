# TD 3 · Conteneurisation

MOUNAIM Mouaad · ILIA · Polytech Dijon

[Énoncé du TD](https://github.com/JeromeMSD/module_virtualisation-et-cloud-computing/blob/main/tds/3_conteneurisation.md)

Les commandes s’exécutent depuis `TD/3_conteneurisation` avec Docker démarré. Chaque étape est conservée dans un commit.

## Consigne Teams

Le fichier `student.json` reste hors du dépôt et des contextes Docker. Le `.gitignore` exclut les identifiants et les clés. Chaque `.dockerignore` autorise uniquement les fichiers utiles à son image. La clé est réservée à l’authentification au registre Google.

## Frontend

### 1 · Créer la page

`frontend/index.html` contient le HTML et son CSS. Il peut être ouvert directement dans un navigateur.

### 2 · Choisir Nginx

`FROM nginx:latest` utilise la dernière image Nginx.

### 3 · Copier la page

`COPY index.html /usr/share/nginx/html/` enregistre la page dans l’image, dans le dossier servi par Nginx.

### 4–5 · Déclarer le port et sauvegarder

`EXPOSE 80` documente le port du conteneur. La publication sur l’hôte sera configurée par `-p`.

**Point d’entrée et commande de démarrage**

L’image officielle fournit `ENTRYPOINT ["/docker-entrypoint.sh"]` et `CMD ["nginx", "-g", "daemon off;"]`. Le script prépare la configuration et lance Nginx au premier plan. Notre Dockerfile hérite de ces valeurs.

```sh
docker image inspect nginx:latest --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}'
```

### 6 · Construire l’image

```sh
cd frontend
docker build . -t mon-frontend
cd ..
```

### 7–8 · Démarrer et ouvrir le site

```sh
docker run -d --name frontend-ctn -p 8080:80 mon-frontend
```

Ouvrir http://localhost:8080 dans le navigateur. Le port 8080 de l’hôte redirige vers le port 80 du conteneur.

### 9 · Modifier et redéployer

La page est passée de « Version 1 » à « Version 2 · Page mise à jour ».

```sh
docker stop frontend-ctn
docker rm frontend-ctn
docker build ./frontend -t mon-frontend
docker run -d --name frontend-ctn -p 8080:80 mon-frontend
```

**Observation attendue** — Modifier uniquement le fichier local conserve le contenu du conteneur existant. `COPY` a copié la page pendant la construction. Reconstruire l’image puis recréer le conteneur rend la nouvelle version disponible.

## Backend · Boîte à outils

### 1 · Choisir Debian

Le Dockerfile utilise `FROM debian:latest`.

### 2 · Installer les outils

`RUN` installe `bash`, `htop`, `vim` et `net-tools`. Le paquet `net-tools` fournit `netstat`.

### 3 · Définir OWNER et démarrer le conteneur

`ENV OWNER=Mouaad` définit mon prénom. `CMD ["sleep", "3600"]` garde le conteneur actif pendant une heure.

**Pourquoi aucun EXPOSE ?** La boîte à outils n’exécute aucun serveur réseau.

L’image Debian fournit habituellement `bash` par défaut. Un shell détaché sans entrée interactive peut se terminer immédiatement. Le `sleep 3600` du TD permet d’utiliser ensuite `docker exec`.

```sh
docker build ./backend -t toolbox
docker run -d --name toolbox-ctn toolbox
```

### Utiliser les outils et joindre le frontend

Le dépôt contient la version finale avec `USER nonroot`. Pour refaire l’expérience en root, récupérer le Dockerfile de l’étape précédente, puis reconstruire l’image et démarrer le conteneur :

```sh
git show c5f20fd:TD/3_conteneurisation/backend/Dockerfile > backend/Dockerfile
docker build ./backend -t toolbox
docker run -d --name toolbox-ctn toolbox
```

Si `toolbox-ctn` existe déjà, l’arrêter et le supprimer avant de le recréer.

Dans un second terminal, se connecter au conteneur.

```sh
docker exec -it toolbox-ctn /bin/bash
echo "$OWNER"
bash --version
htop
vim
netstat -an
whoami
apt-get update
apt-get install -y curl
```

Quitter `htop` avec `q`. Quitter `vim` avec Échap, puis `:q!` et Entrée.

Dans un troisième terminal, démarrer le frontend s’il n’est pas déjà actif.

```sh
docker run -d --name frontend-ctn -p 8080:80 mon-frontend
```

Sur l’hôte Linux, `ip -4 addr show docker0` donne l’adresse de l’interface Docker. Sous Windows, utiliser `ipconfig`. Puis, dans la boîte à outils, remplacer `<IP-host>` par l’adresse relevée.

```sh
curl http://<IP-host>:8080
```

Sur Docker Desktop, `host.docker.internal` permet aussi de joindre l’hôte si l’interface Docker est interne à sa VM.

**Résultat attendu** — `curl` affiche le HTML servi par Nginx via le port 8080 de l’hôte.

### Gestion des droits utilisateur

Dans le premier conteneur, `whoami` renvoie `root` et l’installation de `curl` est permise. Le Dockerfile final ajoute `RUN useradd nonroot` puis `USER nonroot`.

```sh
exit
docker stop toolbox-ctn
docker rm toolbox-ctn
git restore backend/Dockerfile
docker build ./backend -t toolbox
docker run -d --name toolbox-ctn toolbox
docker exec -it toolbox-ctn /bin/bash
whoami
apt install curl
exit
```

**Résultat attendu** — `whoami` renvoie `nonroot`. `apt install curl` échoue avec une erreur de permission. Installer les paquets dans le Dockerfile avant `USER` permet de préparer l’image avec les droits requis. L’installation interactive de `curl` dans l’ancien conteneur disparaît lorsque celui-ci est supprimé.

## Sauvegarder le frontend dans Artifact Registry

Installer [gcloud](https://docs.cloud.google.com/sdk/docs/install-sdk?hl=fr#latest-version) et exécuter toutes les commandes dans le même terminal. Conserver le JSON fourni par Teams dans un dossier privé extérieur au dépôt, puis adapter son chemin local.

```sh
gcloud auth activate-service-account student@polytech-dijon.iam.gserviceaccount.com --key-file="/chemin/prive/student.json"
gcloud config set project polytech-dijon
gcloud auth configure-docker europe-west1-docker.pkg.dev
docker tag mon-frontend europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/frontend-2026:mounaim
docker push europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/frontend-2026:mounaim
```

Répondre `Y` aux confirmations. Le tag `mounaim` correspond au travail individuel. La réussite du push se vérifie à partir du digest renvoyé par le registre. Les configurations Docker et gcloud restent à l’extérieur du dépôt.

Faire vérifier l’image par l’enseignant, comme demandé à la fin du TD.

## Bonus · RabbitMQ Hello World

Exemple adapté du [tutoriel officiel Python](https://www.rabbitmq.com/tutorials/tutorial-one-python).

Dans un premier terminal, démarrer le serveur avec la commande du TD.

```sh
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management
```

Dans un deuxième terminal, créer un environnement Python.

```sh
python -m venv rabbitmq/.venv
```

Sous Windows PowerShell, lancer `rabbitmq/.venv/Scripts/Activate.ps1`. Sous Linux, lancer `source rabbitmq/.venv/bin/activate`. Puis exécuter les commandes suivantes.

```sh
python -m pip install -r rabbitmq/requirements.txt
python rabbitmq/receive.py
```

Dans un troisième terminal avec le même environnement activé, lancer `python rabbitmq/send.py`.

Le producteur envoie `Hello World!` à la file `hello`. Le consommateur attend et affiche les messages. `auto_ack=True` reprend l’exemple introductif. L’interface de gestion se trouve sur http://localhost:15672 avec le compte local `guest`.


## Vérifications réellement effectuées le 26 novembre 2026

Les tests ont été exécutés dans une machine Linux de test avec Docker 29.0.4. Ils ne correspondent pas à des commandes exécutées sur mon PC Windows.

| Vérification | Résultat |
| --- | --- |
| Construction du frontend avec `nginx:latest` | Réussie |
| `ENTRYPOINT` / `CMD` hérités | `/docker-entrypoint.sh` puis `nginx -g 'daemon off;'` |
| HTTP sur le port 8080 | Version 1 reçue |
| Modification du HTML sans reconstruction | L’ancienne page reste servie |
| Reconstruction et recréation du conteneur | Version 2 reçue |
| Outils dans la boîte à outils | Bash, htop, Vim et netstat disponibles |
| Variable d’environnement | `OWNER=Mouaad` |
| Installation de curl en root | Réussie |
| Appel depuis toolbox vers `172.17.0.1:8080` | HTML du frontend reçu |
| Utilisateur final | `whoami` renvoie `nonroot` |
| Installation avec nonroot | Refusée : permission refusée sur le verrou dpkg |
| Bonus RabbitMQ 3.12-management | Producteur et consommateur testés : `Hello World!` envoyé et reçu |
| Authentification gcloud et configuration du projet/registre | Effectuées |
| Publication de l’image | Non effectuée : accès réseau au domaine du registre bloqué dans l’environnement de test |

Le contrôle HTTP a été automatisé avec `curl`. La consultation visuelle dans le navigateur à l’étape 8 reste à reproduire sur le PC avec http://localhost:8080.

### Publication à terminer sur le PC

L’autorisation d’accès au projet Google a été vérifiée, mais la connexion Docker au domaine `europe-west1-docker.pkg.dev` a été bloquée par la politique réseau de l’environnement de test. Aucun digest d’image publiée n’est donc annoncé.

Dans le même terminal, après les commandes gcloud indiquées plus haut, exécuter :

```sh
docker build ./frontend -t mon-frontend
docker tag mon-frontend europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/frontend-2026:mounaim
docker push europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/frontend-2026:mounaim
```

Relever le digest affiché à la fin du push, puis demander la vérification à l’enseignant.

### Confidentialité Teams

Les contenus des 15 commits de préparation du TD3 ont été contrôlés : aucun fichier `student.json` ni clé privée n’y a été trouvé. L’archive de l’image frontend construite a également été contrôlée : elle ne contient ni l’identifiant de la clé fournie, ni sa valeur privée, ni le jeton temporaire utilisé pour la tentative d’authentification. Le fichier original est resté extérieur au dépôt et aux contextes de construction.


### Résultat du bonus RabbitMQ

Le serveur `rabbitmq:3.12-management` a été démarré avec les ports 5672 et 15672 publiés. Son interface de gestion a répondu, puis les deux scripts Python ont été exécutés avec `pika==1.3.2`.

Sortie du producteur :

```text
 [x] Sent 'Hello World!'
```

Sortie du consommateur :

```text
 [*] Waiting for messages. To exit press CTRL+C
 [x] Received b'Hello World!'
```

Les tests du frontend, de la boîte à outils et du bonus sont validés. Restent la consultation dans le navigateur sur le PC, le push vers Artifact Registry depuis un réseau autorisé et la vérification de cette publication avec l’enseignant.
