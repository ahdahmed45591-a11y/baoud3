# D3TV — application mobile

Prototype Flutter (v1), un seul code pour iOS/Android : Accueil, Direct (flux HLS Bozztv/Akamai), Programme (JSON statique embarqué), À propos.

Aucun backend en v1 — pas de compte utilisateur, pas de serveur. Le direct pointe directement sur le flux Bozztv déjà en place ; le programme est un fichier JSON livré avec l'app.

## Lancer

```
flutter pub get
flutter run
```

## CI

`.github/workflows/flutter.yml` fait `flutter analyze` + `flutter test` à chaque push/PR.
