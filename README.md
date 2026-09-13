# D3TV — application Android

Application Android de la chaîne D3TV : l'interface web est embarquée dans une
coque Capacitor, le direct lit le flux HLS de la chaîne.

## Mettre en ligne

1. Créer un dépôt GitHub (par exemple `d3tv-app`), branche `main`.
2. Y déposer tout le contenu de ce dossier, en conservant l'arborescence
   (le dossier `.github` est masqué : bien vérifier qu'il est présent).
3. Onglet **Actions** du dépôt : le build démarre tout seul au premier push.
4. Une fois le build terminé (5 à 10 min), ouvrir le build et télécharger
   l'artefact **d3tv-apk**. Il contient `app-debug.apk`.
5. Copier l'APK sur un téléphone Android et l'installer (autoriser les
   « sources inconnues »).

Pour relancer un build sans rien modifier : Actions > Build APK > *Run workflow*.

## Modifier l'application

Tout est dans `www/index.html` (un seul fichier : HTML, CSS, JS, images).
Chaque push sur `main` reconstruit l'APK.

## Flux direct

`https://live20.bozztv.com/akamaissh101/ssh101/d3tvnet/playlist.m3u8`

Défini dans la constante `LIVE_URL` de `www/index.html`.

## Limites de cette version

- APK **debug** : installable directement, mais non signé pour le Play Store.
  Pour publier, il faut générer une clé de signature et passer en `assembleRelease`.
- Icône et écran de démarrage : ceux par défaut de Capacitor.
- Le compte (connexion, inscription) est une maquette, sans serveur derrière.
