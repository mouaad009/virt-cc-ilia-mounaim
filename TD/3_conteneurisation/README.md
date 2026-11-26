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
