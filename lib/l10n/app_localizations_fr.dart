// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Convention App';

  @override
  String get modeRefill => 'Stock';

  @override
  String get modeConvention => 'Conventions';

  @override
  String get modeSettings => 'Paramètres';

  @override
  String get itemsTitle => 'Articles';

  @override
  String get addItem => 'Ajouter un article';

  @override
  String get editItem => 'Modifier l\'article';

  @override
  String get deleteItem => 'Supprimer l\'article';

  @override
  String deleteItemConfirm(String name) {
    return 'Supprimer \"$name\" ?';
  }

  @override
  String get itemName => 'Nom';

  @override
  String get itemDescription => 'Description';

  @override
  String get itemPrice => 'Prix unitaire';

  @override
  String get itemStock => 'Quantité en stock';

  @override
  String get itemImage => 'Image';

  @override
  String get pickFromGallery => 'Galerie';

  @override
  String get pickFromCamera => 'Appareil photo';

  @override
  String get removeImage => 'Supprimer l\'image';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get conventionsTitle => 'Conventions';

  @override
  String get addConvention => 'Nouvelle convention';

  @override
  String get editConvention => 'Modifier la convention';

  @override
  String get deleteConvention => 'Supprimer la convention';

  @override
  String get conventionName => 'Nom de la convention';

  @override
  String get conventionStartDate => 'Date de début';

  @override
  String get conventionEndDate => 'Date de fin (optionnelle)';

  @override
  String get conventionClosed => 'Fermée';

  @override
  String get conventionOpen => 'Ouverte';

  @override
  String get closeConvention => 'Fermer la convention';

  @override
  String get reopenConvention => 'Rouvrir la convention';

  @override
  String get conventionDetail => 'Détail de la convention';

  @override
  String get addEntry => 'Ajouter un article à la vente';

  @override
  String get quantity => 'Qté';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get receipt => 'Reçu';

  @override
  String get shareReceipt => 'Partager le reçu';

  @override
  String get noItems => 'Aucun article. Ajoutez-en dans l\'onglet Stock.';

  @override
  String get noConventions => 'Aucune convention.';

  @override
  String get noEntries => 'Aucun article ajouté.';

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get invalidNumber => 'Entrez un nombre valide';

  @override
  String get invalidPrice => 'Entrez un prix valide (ex: 5.00)';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get exportDataDesc =>
      'Exporter tous les articles et conventions en JSON (sauvegarde / changement d\'appareil)';

  @override
  String get importData => 'Importer les données';

  @override
  String get importDataDesc =>
      'Restaurer depuis un fichier JSON exporté précédemment';

  @override
  String get exportSuccess => 'Données exportées avec succès';

  @override
  String get importSuccess => 'Données importées avec succès';

  @override
  String importError(String error) {
    return 'Échec de l\'import : $error';
  }

  @override
  String get importConfirm =>
      'Cela remplacera toutes les données actuelles. Continuer ?';

  @override
  String get errorGeneric => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String stockLabel(int qty) {
    return 'Stock : $qty';
  }

  @override
  String priceLabel(String price) {
    return '$price';
  }

  @override
  String get analyticsStatistics => 'Analytiques et statistiques';

  @override
  String get totalRevenue => 'Chiffre d\'affaires total';

  @override
  String get averageCart => 'Panier moyen';

  @override
  String get totalTransactions => 'Nombre de transactions';

  @override
  String get topItems => 'Articles les plus vendus';

  @override
  String get conventionStats => 'Statistiques par convention';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get revenue => 'Chiffre d\'affaires';

  @override
  String get name => 'Nom';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get payCash => 'Espèces';

  @override
  String get payCard => 'Carte bancaire';

  @override
  String get allConventions => 'Toutes les conventions';

  @override
  String get clients => 'Clients';

  @override
  String get cashRevenue => 'Espèces';

  @override
  String get cardRevenue => 'Carte';

  @override
  String get paymentBreakdown => 'Répartition des paiements';
}
