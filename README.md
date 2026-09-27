# Convention App

Application Flutter hors ligne pour gérer un catalogue d’articles, le stock, les conventions et les ventes. Pendant une convention, chaque client possède un panier temporaire ; au paiement, les ventes sont enregistrées et le stock est décrémenté. L’écran Statistiques récapitule les ventes et les moyens de paiement. Les données sont stockées localement sur l’appareil. Les réglages proposent l’export et l’import JSON.

## Prérequis

- Flutter installé (avec le support Android) et accessible dans le `PATH`.
- Android Studio avec le SDK Android ; accepter les licences avec `flutter doctor --android-licenses`.
- Un émulateur Android ou un téléphone Android pour l’installation.

Vérifier l’installation depuis PowerShell à la racine du projet :

```powershell
flutter doctor
flutter pub get
```

## Générer l’APK

Pour un APK de test optimisé :

```powershell
flutter build apk --release
```

Le fichier à récupérer est :

```text
build\app\outputs\flutter-apk\app-release.apk
```

Pour produire des APK séparés par architecture (fichiers plus petits, mais il faut choisir le bon pour l’appareil) :

```powershell
flutter build apk --release --split-per-abi
```

Les APK apparaissent dans le même dossier, avec le nom de l’architecture dans leur nom. Pour un premier essai, l’APK universel sans `--split-per-abi` est le plus simple.

## Installer et tester

### Émulateur Android

1. Démarrer l’émulateur depuis Android Studio.
2. Faire glisser `app-release.apk` dans sa fenêtre, puis confirmer l’installation.

On peut aussi installer avec ADB :

```powershell
adb install -r .\build\app\outputs\flutter-apk\app-release.apk
```

### Téléphone Android

1. Transférer `app-release.apk` sur le téléphone (USB, stockage cloud ou partage de fichiers).
2. Ouvrir le fichier APK depuis le gestionnaire de fichiers du téléphone.
3. Si Android le demande, autoriser temporairement l’installation d’applications provenant de cette source, puis confirmer l’installation.

Cette configuration Gradle signe actuellement le build `release` avec la clé de debug de Flutter. C’est adapté à un essai local et au glisser-déposer sur un appareil, mais pas à une publication. Pour distribuer l’application, il faudra configurer une clé de signature release privée.

## Vérifications développeur

```powershell
flutter analyze
flutter test
```

## Fonctionnalités

- Catalogue : nom, description, prix, quantité en stock et photo.
- Conventions : création et suivi des articles mis en vente.
- Vente : paniers clients, paiement en espèces ou par carte et décrément du stock.
- Statistiques : chiffre d’affaires, transactions, moyens de paiement et articles vendus.
- Préférences : interface française ou anglaise, export et import JSON.
