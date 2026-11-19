// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Scontrini';

  @override
  String get navHome => 'Home';

  @override
  String get navReceipts => 'Storico';

  @override
  String get navAnalytics => 'Analisi';

  @override
  String get addReceipt => 'Aggiungi';

  @override
  String get settings => 'Impostazioni';

  @override
  String get captureTitle => 'Nuovo scontrino';

  @override
  String get captureScan => 'Scansiona con la fotocamera';

  @override
  String get captureGallery => 'Scegli dalla galleria';

  @override
  String get capturePdf => 'Importa PDF';

  @override
  String get comingSoon => 'Funzionalità in arrivo';

  @override
  String get dashboardEmpty =>
      'Nessuno scontrino ancora.\nAggiungi il primo per vedere le tue spese.';

  @override
  String get receiptsEmpty => 'Lo storico degli acquisti apparirà qui.';

  @override
  String get analyticsEmpty => 'Grafici e statistiche appariranno qui.';

  @override
  String get settingsEmpty => 'Categorie, backup e sicurezza.';

  @override
  String get captureFailed => 'Impossibile acquisire lo scontrino.';

  @override
  String get extractionTitle => 'Scontrino letto';

  @override
  String get extractionLoading => 'Lettura dello scontrino…';

  @override
  String get extractionFailed => 'Impossibile leggere lo scontrino.';

  @override
  String get retry => 'Riprova';

  @override
  String get extractionPreviewNotice =>
      'Anteprima di sviluppo: lo scontrino non viene ancora salvato.';

  @override
  String get fieldStore => 'Negozio';

  @override
  String get fieldDate => 'Data';

  @override
  String get fieldTotal => 'Totale';

  @override
  String get fieldItemsTotal => 'Somma articoli';

  @override
  String extractionItems(int count) {
    return 'Articoli ($count)';
  }

  @override
  String extractionDiscount(String amount) {
    return 'Sconto $amount';
  }

  @override
  String get extractionReceiptDiscount => 'Sconti sul totale';

  @override
  String get extractionUnparsed => 'Righe non riconosciute';

  @override
  String get extractionRawText => 'Testo riconosciuto';

  @override
  String get warningMissingStore => 'Negozio non trovato';

  @override
  String get warningMissingDate => 'Data non trovata';

  @override
  String get warningMissingTotal => 'Totale non trovato';

  @override
  String get warningTotalMismatch =>
      'La somma degli articoli non corrisponde al totale';

  @override
  String get warningLineTotalMismatch =>
      'Quantità × prezzo diverso dall\'importo della riga';

  @override
  String get exportFixture => 'Esporta come test';

  @override
  String exportFixtureDone(String name) {
    return 'Salvato: $name';
  }

  @override
  String get navPantry => 'Dispensa';

  @override
  String get pantryEmpty =>
      'La dispensa è vuota.\nAggiungi prodotti da uno scontrino o a mano.';

  @override
  String get pantryShowClosed => 'Mostra finiti e buttati';

  @override
  String get pantryHideClosed => 'Nascondi finiti e buttati';

  @override
  String get pantryAdd => 'Aggiungi prodotto';

  @override
  String get pantryUncategorised => 'Senza categoria';

  @override
  String pantryRemaining(String remaining, String initial) {
    return '$remaining di $initial';
  }

  @override
  String get pantrySourceManualPurchase => 'Comprato, senza scontrino';

  @override
  String get pantrySourceInitialStock => 'Già in casa';

  @override
  String get pantrySourceGift => 'Regalo';

  @override
  String get pantryStatusConsumed => 'Finito';

  @override
  String get pantryStatusDiscarded => 'Buttato';

  @override
  String get pantryConsumeAll => 'Segna come finito';

  @override
  String get pantryDiscard => 'Butta via';

  @override
  String get pantryReasonExpired => 'Scaduto';

  @override
  String get pantryReasonSpoiled => 'Andato a male';

  @override
  String get pantryReasonOther => 'Altro motivo';

  @override
  String get pantryUndo => 'Annulla';

  @override
  String get pantryUndoLast => 'Annulla l\'ultima azione';

  @override
  String get pantryNothingToUndo => 'Niente da annullare';

  @override
  String get pantryDelete => 'Elimina dalla dispensa';

  @override
  String pantryDeleteConfirm(String name) {
    return 'Eliminare $name? Il suo storico di consumo andrà perso.';
  }

  @override
  String pantryConsumedMessage(String name, String amount) {
    return '$name: usato $amount';
  }

  @override
  String pantryDiscardedMessage(String name) {
    return '$name buttato';
  }

  @override
  String pantryFinishedMessage(String name) {
    return '$name finito';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get save => 'Salva';

  @override
  String get pantryFieldName => 'Nome';

  @override
  String get pantryFieldQuantity => 'Quantità';

  @override
  String get pantryFieldPrice => 'Prezzo pagato (facoltativo)';

  @override
  String get pantryFieldCategory => 'Categoria';

  @override
  String get pantryFieldSource => 'Provenienza';

  @override
  String get pantryInvalidName => 'Inserisci un nome';

  @override
  String get pantryInvalidQuantity => 'Inserisci una quantità maggiore di zero';

  @override
  String get pantryInvalidPrice => 'Prezzo non valido';

  @override
  String get unitPieces => 'pz';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitLitres => 'l';
}
