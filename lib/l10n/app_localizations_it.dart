// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Lumi';

  @override
  String get navExplore => 'Esplora';

  @override
  String get navMovies => 'Film';

  @override
  String get navTvShows => 'Programmi TV';

  @override
  String get navLibrary => 'Libreria';

  @override
  String get navAccount => 'Traduci questa etichetta dell\'app in: Account';

  @override
  String get searchHint => 'Cerca film, programmi TV, aziende...';

  @override
  String get searchForPerson => 'Cerca una persona...';

  @override
  String get searchLanguages => 'Cerca lingue';

  @override
  String get searchNameOrRole => 'Cerca nome o ruolo...';

  @override
  String get retry => 'Riprova';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get clear => 'Cancella';

  @override
  String get cancel => 'Annulla';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get share => 'Condividi';

  @override
  String get undo => 'Annulla';

  @override
  String get close => 'Chiudi';

  @override
  String get apply => 'Applica';

  @override
  String get reset => 'Reimposta';

  @override
  String get done => 'Fine';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String get signInWithApple => 'Accedi con Apple';

  @override
  String get signOut => 'Esci';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get accountDeletedSuccessfully => 'Account eliminato correttamente.';

  @override
  String get appearance => 'Aspetto';

  @override
  String get appearanceSubtitle =>
      'Scegli il tuo tema e personalizza l\'aspetto dell\'app.';

  @override
  String get notifications => 'Notifiche';

  @override
  String get releaseCalendar => 'Calendario uscite';

  @override
  String get hiddenTitles => 'Titoli nascosti';

  @override
  String get aiRecommendationsPrivacy => 'Privacy consigli AI';

  @override
  String get contentRegion => 'Area contenuti';

  @override
  String get contentLanguage => 'Lingua contenuti';

  @override
  String get watchlist => 'Lista di controllo';

  @override
  String get notes => 'Note';

  @override
  String get deleteNote => 'Elimina nota';

  @override
  String get addNoteHint => 'Aggiungi una nota...';

  @override
  String get addBriefNoteHint => 'Aggiungi una breve nota (facoltativo)...';

  @override
  String get enterNewName => 'Inserisci un nuovo nome...';

  @override
  String get importSharedList => 'Importa elenco condiviso';

  @override
  String get discoverOnLumi => 'SCOPRI SU LUMI';

  @override
  String get filtered => 'Filtrato';

  @override
  String get fullPlot => 'Trama completa';

  @override
  String get userReviews => 'Recensioni degli utenti';

  @override
  String get noReviewsYet => 'Ancora nessuna recensione.';

  @override
  String get openInYouTube => 'Apri su YouTube';

  @override
  String get hiddenGems => 'Gemme nascoste';

  @override
  String get resetSpotlight => 'Reimposta Spotlight';

  @override
  String get clearPreferences => 'Cancella preferenze';

  @override
  String get refreshPicks => 'Aggiorna scelte';

  @override
  String get shareBoard => 'Condividi bacheca';

  @override
  String get exploreDetails => 'Esplora dettagli';

  @override
  String get searchWikiquotes => 'Cerca citazioni Wiki';

  @override
  String get selectAQuote => 'Seleziona una citazione';

  @override
  String get tooltipShareQuote => 'Condividi citazione';

  @override
  String get tooltipCopyQuote => 'Copia citazione';

  @override
  String get tooltipShareDialogue => 'Condividi dialogo';

  @override
  String get tooltipCopyDialogue => 'Copia dialogo';

  @override
  String get tooltipUnhide => 'Scopri';

  @override
  String get tooltipOpenPrivacyPolicy => 'Apri informativa sulla privacy';

  @override
  String get tooltipRefreshInsights => 'Aggiorna approfondimenti';

  @override
  String get tooltipSortTitles => 'Ordina titoli';

  @override
  String get tooltipSearch => 'Cerca';

  @override
  String get tooltipFilters => 'Filtri';

  @override
  String get tooltipSaveToGallery => 'Salva nella Galleria';

  @override
  String get tooltipShare => 'Condividi';

  @override
  String get tooltipShareAnalytics => 'Condividi analisi';

  @override
  String get tooltipSetAiringReminder => 'Imposta promemoria di messa in onda';

  @override
  String get tooltipLibrarySynced => 'Libreria sincronizzata con il cloud';

  @override
  String get noMoreEntries => 'Nessun altro ingresso';

  @override
  String get noItemsFound => 'Nessun elemento trovato';

  @override
  String errorLoadingGenres(String error) {
    return 'Errore caricamento generi: $error';
  }

  @override
  String errorGeneric(String error) {
    return 'Errore: $error';
  }

  @override
  String get errorLoadingLists => 'Errore caricamento elenchi';

  @override
  String errorLoadingQuotes(Object error) {
    return 'Impossibile caricare le citazioni: $error';
  }

  @override
  String get errorCouldNotShareAnalytics =>
      'Impossibile condividere analisi carta.';

  @override
  String get errorCouldNotShareRecommendations =>
      'Impossibile condividere la scheda dei suggerimenti.';

  @override
  String get errorCouldNotShareInsights =>
      'Impossibile condividere i dati statistici sull\'orologio.';

  @override
  String get watchInsightsNotReady =>
      'Gli approfondimenti sugli orologi non sono ancora pronti.';

  @override
  String titleRestoredToSpotlight(String title) {
    return '\"$title\" ripristinato in Spotlight';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '\"$title\" è stato nascosto';
  }

  @override
  String hiddenDate(String date) {
    return 'Nascosto: $date';
  }

  @override
  String get moviesInThisCollection => 'Film in questa raccolta';

  @override
  String get searchPlanReady => 'Il piano di ricerca è pronto';

  @override
  String get hoursBeforeAirTime => 'Ore prima della messa in onda';

  @override
  String get noUpcomingReleases => 'Nessuna uscita imminente';

  @override
  String get noRemindersSet => 'Nessun promemoria impostato';

  @override
  String get noHiddenTitles => 'Nessun titolo nascosto';

  @override
  String get hiddenTitlesDescription =>
      'I titoli che nascondi dalla sezione In evidenza appariranno qui e potrai ripristinarli in qualsiasi momento.';

  @override
  String get tvShow => 'PROGRAMMA TELEVISIVO';

  @override
  String get movie => 'FILM';

  @override
  String get aiConsentGranted =>
      'Hai attivato la registrazione. I dati della tua libreria vengono utilizzati per personalizzare i consigli.';

  @override
  String get aiConsentNotGranted =>
      'I dati della tua raccolta non vengono mai condivisi a meno che tu non lo accetti.';

  @override
  String get languageSettingExplanation =>
      'Le schede Film e TV lo utilizzano rigorosamente. Explore lo preferisce per primo e si ritira quando i binari diventano radi.';

  @override
  String get filterScreenTitle => 'Filtri';

  @override
  String get sortBy => 'Ordina per';

  @override
  String get genres => 'Generi';

  @override
  String get year => 'Anno';

  @override
  String get rating => 'Valutazione';

  @override
  String get runtime => 'Tempo di esecuzione';

  @override
  String get withPeople => 'Con persone';

  @override
  String get voteCount => 'Conteggio voti';

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String get yesterday => 'Ieri';

  @override
  String get minutes => 'Traduci questa etichetta dell\'app in: min';

  @override
  String get hours => 'H';

  @override
  String get cast => 'Lancio';

  @override
  String get crew => 'Troupe';

  @override
  String get director => 'F@ Cast @G@ Troupe @H@ Regista';

  @override
  String get seasons => 'Stagioni';

  @override
  String get episodes => 'Episodi';

  @override
  String get overview => 'Panoramica';

  @override
  String get similar => 'Simile';

  @override
  String get recommendations => 'Consigli';

  @override
  String get addedToWatchlist => 'Aggiunto alla lista di controllo';

  @override
  String get removedFromWatchlist => 'Rimosso dalla lista di controllo';

  @override
  String get popularity => 'Popolarità';

  @override
  String get releaseDate => 'Data di uscita';

  @override
  String get revenueLabel => 'Entrate';

  @override
  String get originalTitle => 'Titolo originale';

  @override
  String get voteAverage => 'Media dei voti';

  @override
  String get favourites => 'Preferiti';

  @override
  String get lists => 'elenchi';

  @override
  String get watched => 'Guardato';

  @override
  String get all => 'Tutto';

  @override
  String get tv => 'TV';

  @override
  String get librarySubtitle =>
      'Mantieni tutto organizzato per collezione, preferiti, note e cronologia delle visualizzazioni.';

  @override
  String get selectRegion => 'Seleziona la regione';

  @override
  String get selectRegionDescription =>
      'Solo gli endpoint TMDb che supportano le query sensibili alla regione utilizzeranno questa selezione.';

  @override
  String get useAutoDetectedRegion =>
      'Utilizza la regione rilevata automaticamente';

  @override
  String get reminderRemoved => 'Promemoria rimosso';

  @override
  String releaseReminderSet(String title) {
    return 'Promemoria di rilascio impostato per $title.';
  }

  @override
  String episodeReminderSet(String title) {
    return 'Promemoria episodio impostato per $title.';
  }

  @override
  String get filteredResults => 'Risultati filtrati';

  @override
  String get genreResults => 'Risultati del genere';

  @override
  String couldNotLoadContent(String error) {
    return 'Impossibile caricare il contenuto. $error';
  }

  @override
  String get noContentAvailableForThisSelection =>
      'Nessun contenuto disponibile per questa selezione.';

  @override
  String get writer => 'Scrittore';

  @override
  String get actors => 'Attori';

  @override
  String get noteNotFound => 'Nota non trovata.';

  @override
  String yourNotesCount(int count) {
    return 'Le tue note ($count)';
  }

  @override
  String get noteDeleted => 'Nota eliminata';

  @override
  String noteDeletedWithCount(int count) {
    return 'Nota eliminata ($count s)';
  }

  @override
  String get loadMore => 'Carica altro';

  @override
  String get noMoreProductionsFound =>
      'Non sono state trovate altre produzioni.';

  @override
  String get noProductionsFound => 'Nessuna produzione trovata.';

  @override
  String get watchInsights => 'Guarda gli approfondimenti';

  @override
  String get analyzingWatchHistory =>
      'Analisi della cronologia degli orologi...';

  @override
  String get manageHiddenTitlesDescription =>
      'Gestisci i titoli che hai nascosto dalla sezione Spotlight.';

  @override
  String get tmdbLanguageMetadataNote =>
      'In questa modalità, alcuni binari potrebbero apparire spogli perché i metadati linguistici di TMDB sono incompleti per alcune parti del catalogo, non necessariamente perché quei titoli non esistano.';

  @override
  String get tmdbDisclaimer =>
      'Questo prodotto utilizza l\'API di TMDB ma non è approvato né certificato da TMDB.';

  @override
  String get useLocalLibraryForSync =>
      'Utilizzare la libreria locale per la sincronizzazione?';

  @override
  String get themePresets => 'Preimpostazioni del tema';

  @override
  String get exitApp => 'Esci dall\'app';

  @override
  String get popular => 'Popolare';

  @override
  String couldNotLoadReminders(String error) {
    return 'Impossibile caricare i promemoria.\n\n$error';
  }

  @override
  String get noRemindersSetYet =>
      'Nessun promemoria impostato finora.\nCreane uno dal Tracker episodi o dai Dettagli film.';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return 'Episodio S$seasonNumber • E$episodeNumber';
  }

  @override
  String get movieRelease => 'Uscita del film';

  @override
  String voteAverageStars(String voteAverage) {
    return 'Traduci questa etichetta dell\'app in: $voteAverage ★';
  }

  @override
  String get addMoreTrackedContent =>
      'Aggiungi altri film o serie TV alla tua lista di titoli da guardare, ai preferiti o alle liste.';

  @override
  String get fastPicksDescription =>
      'Selezione rapida in base agli elementi che hai già salvato.';

  @override
  String get releaseCalendarDescription =>
      'Promemoria per le nuove uscite cinematografiche e i prossimi episodi delle serie TV, con un solo tocco.';

  @override
  String get staleWatchlist => 'Lista di controllo obsoleta';

  @override
  String get tracked => 'Tracciato';

  @override
  String get upcoming => 'Prossimamente';

  @override
  String get upcomingEmptyDescription =>
      'Quando i film monitorati avranno una data di uscita o quando saranno programmati nuovi episodi delle serie TV, queste informazioni appariranno qui.';

  @override
  String get howManyMoviesWatchedEachMonth =>
      'Quanti film hai guardato ogni mese?';

  @override
  String get howPersonalRatingsShifting =>
      'Come cambiano le tue valutazioni personali nel tempo';

  @override
  String get keepWatchingToBuildProfile =>
      'Continua a guardare per costruire il tuo profilo visivo.';

  @override
  String get lumiWatchAnalytics => 'ANALISI DEGLI OROLOGI LUMI';

  @override
  String get noGenreDistributionYet =>
      'Non sono ancora disponibili informazioni sulla distribuzione per genere.';

  @override
  String get noMovieWatchHistoryRecentMonths =>
      'Nessuna cronologia di visualizzazione di film negli ultimi mesi.';

  @override
  String get noRatingTrendDataYet =>
      'Al momento non sono disponibili dati sull\'andamento delle valutazioni.';

  @override
  String get preferredRuntime => 'Tempo di esecuzione preferito';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return 'Il tempo di esecuzione preferito è di circa $minutes minuti ($label)';
  }

  @override
  String get styledCardWithWatchStats =>
      'Scheda personalizzabile con le statistiche del tuo orologio.';

  @override
  String get titlesAnalyzed => 'Titoli analizzati';

  @override
  String get tryAgainAfterMoment => 'Riprova tra un attimo.';

  @override
  String get watchAnalytics => 'Analisi dei dati';

  @override
  String get whatGenresDominateHistory =>
      'Quali generi dominano la tua cronologia di visione?';

  @override
  String get toggleMovies => 'Film';

  @override
  String get toggleTv => 'TV';

  @override
  String get noMoreTitlesFound => 'Nessun altro titolo trovato.';

  @override
  String get noTitlesFoundForKeyword =>
      'Nessun titolo trovato per questa parola chiave';

  @override
  String get viewFull => 'Visualizza tutto';

  @override
  String get accoladeDetails => 'Dettagli del riconoscimento';

  @override
  String get noDetailedAwardsInfo =>
      'Non sono disponibili informazioni dettagliate sui premi.';

  @override
  String get alertSet => 'Allerta impostata!';

  @override
  String get budget => 'Bilancio';

  @override
  String get buy => 'Acquistare';

  @override
  String chooseBetweenHours(int maxHours) {
    return 'Scegli tra 1 e $maxHours';
  }

  @override
  String get deleteNoteConfirmationTitle => 'Eliminare la nota?';

  @override
  String get episodeReminder => 'Promemoria episodi';

  @override
  String get facebook => 'Facebook';

  @override
  String get free => 'Gratuito';

  @override
  String get images => 'Immagini';

  @override
  String get instagram => 'Instagram';

  @override
  String get netProfit => 'Utile netto';

  @override
  String get noNotesYet => 'Nessun commento ancora. Aggiungi i tuoi pensieri!';

  @override
  String get originalLanguage => 'Lingua originale';

  @override
  String partOfCollection(String collectionName) {
    return 'Parte del $collectionName';
  }

  @override
  String get roi => 'ROI';

  @override
  String releaseAlertSet(String date) {
    return 'Impostazione dell\'avviso di rilascio per $date.';
  }

  @override
  String get rent => 'Affitto';

  @override
  String get revenue => 'Reddito';

  @override
  String seeAllReviews(int count) {
    return 'Vedi tutto ($count)';
  }

  @override
  String get setReminder => 'Imposta promemoria';

  @override
  String get status => 'Stato';

  @override
  String get stream => 'Flusso';

  @override
  String get tikTok => 'TikTok';

  @override
  String get twitterX => 'X';

  @override
  String get yours => 'IL TUO';

  @override
  String get youtube => 'YouTube';

  @override
  String get durationDays => 'D';

  @override
  String get durationHours => 'H';

  @override
  String get durationMinutes => 'M';

  @override
  String get durationSeconds => 'S';

  @override
  String seasonRating(String score) {
    return 'Traduci questa etichetta dell\'app in: ★ $score%';
  }

  @override
  String get we => 'Noi';

  @override
  String get aspect16x9 => 'Traduci l\'etichetta di questa app in: 16:9';

  @override
  String get aspect9x16 => 'Traduci questa etichetta dell\'app in: 9:16';

  @override
  String get background => 'Traduci questa etichetta dell\'app in: Bg';

  @override
  String episodeCount(int count) {
    return 'Traduci questa etichetta dell\'app in: $count Eps';
  }

  @override
  String get noEpisodesForSeason =>
      'Nessun episodio trovato per questa stagione.';

  @override
  String get beautifulStyledCardForStories =>
      'Bellissima cartolina per storie sui social';

  @override
  String get clickableShareLink =>
      'Link di condivisione cliccabile per WhatsApp e altre app';

  @override
  String get placeQuoteOnBackdrop =>
      'Inserisci la tua citazione preferita sullo sfondo di un film.';

  @override
  String get standardLinkToMovieDatabase =>
      'Collegamento standard al database dei film';

  @override
  String get exploreLabel => 'Esplorare';

  @override
  String quoteCharacter(String character) {
    return 'Traduci questa etichetta dell\'app in: — $character';
  }

  @override
  String get aiTonightWatch =>
      'Traduci questa etichetta dell\'app in: AI Tonight Watch';

  @override
  String get aiQueryPlan => 'piano di interrogazione AI';

  @override
  String get airingToday => 'In onda oggi';

  @override
  String get bigCrowdPleasers =>
      'Grandi successi di pubblico con un forte slancio';

  @override
  String get cinematic => 'Cinematografico';

  @override
  String get comingSoon => 'Prossimamente';

  @override
  String get currentTheatricalSlate =>
      'Programmazione cinematografica attuale e uscite a breve termine';

  @override
  String get dark => 'Buio';

  @override
  String get discoverSpotlight => 'Scopri Spotlight';

  @override
  String get edgeOfYourSeat => 'Con il fiato sospeso';

  @override
  String get fastPaced => 'Ritmo incalzante';

  @override
  String get feelGood => 'Sentirsi bene';

  @override
  String get freshPicksContinuous => 'Nuove selezioni aggiornate continuamente';

  @override
  String get hideTitle => 'Giardino nascosto';

  @override
  String get highRatedSkipped =>
      'Titoli molto apprezzati che la maggior parte degli spettatori salta';

  @override
  String get hotNowAudience => 'Hot in questo momento sul feed del pubblico';

  @override
  String get inTheaters => 'Al cinema';

  @override
  String get indie => 'Traduci questa etichetta dell\'app in: Indie';

  @override
  String get mindBending => 'Sconcertante';

  @override
  String get mostDiscussedShowsThisWeek =>
      'Gli spettacoli più discussi di questa settimana';

  @override
  String get multiplePicks => 'Scelte multiple';

  @override
  String get onTheAir => 'In onda';

  @override
  String get personalizedFromWatchBehavior =>
      'Personalizzato in base al tuo comportamento di visione';

  @override
  String get pickAVibe =>
      'Scegli un\'atmosfera e ottieni subito titoli corrispondenti';

  @override
  String get seeAll => 'Vedi tutto';

  @override
  String get seriesCurrentlyAiring =>
      'Serie attualmente in onda con episodi attivi';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get topRated => 'I migliori gusti';

  @override
  String get voiceInput => 'Ingresso vocale';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% Corrispondenza';
  }

  @override
  String runtimeMinutes(String minutes) {
    return 'Traduci questa etichetta dell\'app in: $minutes min';
  }

  @override
  String get examplePrompt =>
      'Esempio: Qualcosa di simile a Interstellar, ma non di fantascienza.';

  @override
  String findingYourPerfectWatch(String dots) {
    return 'Trovare l\'orologio perfetto$dots';
  }

  @override
  String get moreLikeThis => 'Altri contenuti simili';

  @override
  String get notForMe => 'Non fa per me';

  @override
  String get recentQueries => 'Ricerche recenti';

  @override
  String get shufflingIdeas => 'Mescolare le idee...';

  @override
  String get tooMainstream => 'Troppo mainstream';

  @override
  String get whatShouldIWatchTonight => 'Cosa dovrei guardare stasera?';

  @override
  String debugLogEntry(String time, String message) {
    return 'Traduci questa etichetta dell\'app in: [$time] $message';
  }

  @override
  String get from => 'Da';

  @override
  String get to => 'A';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return 'Rimosso dalla watchlist ($seconds s)';
  }

  @override
  String creditsCount(String count) {
    return '$count Crediti';
  }

  @override
  String get acrossFilmography => 'Nell\'ambito della sua filmografia';

  @override
  String get birthplace => 'Luogo di nascita';

  @override
  String get born => 'Nato';

  @override
  String get credits => 'Crediti';

  @override
  String get died => 'Morto';

  @override
  String get knownFor => 'Noto per';

  @override
  String get noSharedTitlesAvailable =>
      'Non sono disponibili titoli condivisi.';

  @override
  String get photos => 'Foto';

  @override
  String get personRating => 'Valutazione';

  @override
  String get taggedImages => 'Immagini taggate';

  @override
  String get website => 'Sito web';

  @override
  String get noQuotesFound => 'Nessuna citazione trovata.';

  @override
  String get noSectionsFound => 'Nessuna sezione trovata.';

  @override
  String get clearAll => 'Cancella tutto';

  @override
  String get noCollectionsFound => 'Nessuna raccolta trovata';

  @override
  String get noCompaniesFound => 'Nessuna azienda trovata';

  @override
  String get noKeywordsFound => 'Nessuna parola chiave trovata';

  @override
  String get noMoreResultsFound => 'Nessun altro risultato trovato.';

  @override
  String get noResultsFound => 'Nessun risultato trovato';

  @override
  String deleteListConfirmation(String listName) {
    return 'Sei sicuro di voler eliminare $listName?';
  }

  @override
  String get deleteListTitle => 'Eliminare la lista?';

  @override
  String get everythingYouPlanToWatch =>
      'Tutto ciò che hai intenzione di guardare dopo.';

  @override
  String get finishedTitlesAndHistory =>
      'Titoli completati, cronologia e statistiche.';

  @override
  String get noListsCreatedYet => 'Non sono ancora state create liste.';

  @override
  String get noNotesFound => 'Nessuna nota trovata';

  @override
  String get renameList => 'Rinomina elenco';

  @override
  String get titlesYouNeverWantToLose =>
      'I titoli che non vorresti mai perdere.';

  @override
  String get yourThoughtsReactions => 'I tuoi pensieri, reazioni e promemoria.';

  @override
  String imageCounter(String current, String total) {
    return 'Traduci questa etichetta dell\'app in: $current / $total';
  }

  @override
  String get removeFromWatchedConfirmation =>
      'Sei sicuro di voler rimuovere questo elemento dalla tua lista di elementi osservati?';

  @override
  String get savedAsWatchedWithoutRating =>
      'Questo contenuto verrà salvato come visto senza una valutazione personale.';

  @override
  String get noAdditionalRecommendationTrailers =>
      'Non sono stati trovati altri trailer consigliati.';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return 'Traduci questa etichetta dell\'app in: $count $itemLabel';
  }

  @override
  String get invalidSharedListLink =>
      'Il link potrebbe essere non valido, scaduto o non più accessibile.';

  @override
  String get noTitlesAvailableToImport =>
      'Non sono disponibili titoli da importare.';

  @override
  String get allLanguages => 'Tutte le lingue';

  @override
  String get arabic => 'arabo';

  @override
  String get bengali => 'bengalese';

  @override
  String get chinese => 'cinese';

  @override
  String get english => 'Inglese';

  @override
  String get french => 'francese';

  @override
  String get german => 'tedesco';

  @override
  String get gujarati => 'Traduci questa etichetta dell\'app in: Gujarati';

  @override
  String get hindi => 'hindi';

  @override
  String get indonesian => 'indonesiano';

  @override
  String get italian => 'Italiano';

  @override
  String get japanese => 'giapponese';

  @override
  String get kannada => 'Traduci questa etichetta dell\'app in: Kannada';

  @override
  String get korean => 'coreano';

  @override
  String get malayalam => 'Traduci questa etichetta dell\'app in: Malayalam';

  @override
  String get marathi => 'Traduci questa etichetta dell\'app in: Marathi';

  @override
  String get persian => 'persiano';

  @override
  String get polish => 'Polacco';

  @override
  String get portuguese => 'portoghese';

  @override
  String get punjabi => 'Traduci questa etichetta dell\'app in: Punjabi';

  @override
  String get russian => 'russo';

  @override
  String get spanish => 'spagnolo';

  @override
  String get swedish => 'svedese';

  @override
  String get tamil => 'Traduci questa etichetta dell\'app in: Tamil';

  @override
  String get telugu => 'Traduci questa etichetta dell\'app in: Telugu';

  @override
  String get thai => 'tailandese';

  @override
  String get turkish => 'turco';

  @override
  String get urdu => 'Traduci questa etichetta dell\'app in: Urdu';

  @override
  String get vietnamese => 'vietnamita';

  @override
  String get failedToLoadCollectionDetails =>
      'Impossibile caricare i dettagli della raccolta';

  @override
  String get franchiseProgress => 'Progresso del franchising';

  @override
  String get officialSite => 'Sito ufficiale';

  @override
  String get productions => 'Produzioni';

  @override
  String get productionCompany => 'Società di produzione';

  @override
  String get failedToLoadCompanyInfo =>
      'Impossibile caricare le informazioni aziendali';

  @override
  String get profile => 'Profilo';

  @override
  String get guestViewer => 'Ospite spettatore';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      'Il tuo profilo, lo stato di sincronizzazione, la regione e le preferenze visive sono tutti qui.';

  @override
  String get signInToSync =>
      'Accedi per sincronizzare la tua lista di titoli da guardare, le valutazioni e le preferenze.';

  @override
  String get signedInAndSyncing =>
      'Accesso effettuato e sincronizzazione con il cloud in corso.';

  @override
  String get developedBy => 'Sviluppato da';

  @override
  String get couldNotAnalyzeWatchHistory =>
      'Impossibile analizzare la cronologia degli orologi al momento.';

  @override
  String get includeLocalLibrary => 'Includi la biblioteca locale';

  @override
  String get useCloudOnly => 'Utilizzare solo il cloud';

  @override
  String get localLibrarySyncDescription =>
      'Questo dispositivo contiene già titoli della libreria locale. Aggiungili alla libreria a cui hai effettuato l\'accesso oppure sostituisci i dati della libreria locale con quelli della tua libreria cloud.';

  @override
  String get mergedLocalTitles =>
      'I titoli locali sono stati uniti alla tua libreria a cui hai effettuato l\'accesso.';

  @override
  String get replacedLocalLibrary =>
      'I dati della libreria locale sono stati sostituiti con quelli della libreria cloud.';

  @override
  String get deleteAccountConfirmation =>
      'Questa operazione elimina definitivamente il tuo account Lumi e i dati sincronizzati sul cloud. I dati locali su questo dispositivo rimarranno a meno che tu non rimuova separatamente i dati dell\'app.';

  @override
  String get signedOutAndCleared =>
      'Ho effettuato il logout e svuotato la libreria locale su questo dispositivo.';

  @override
  String get keepLocalLibrary => 'Sostieni la biblioteca locale';

  @override
  String get clearLocalLibrary => 'Biblioteca locale Clear';

  @override
  String get signOutChoiceDescription =>
      'Scegli se conservare la libreria locale su questo dispositivo dopo aver effettuato il logout.';

  @override
  String get disable => 'Disabilita';

  @override
  String get aiRecommendationsEnabled =>
      'Condivisione dei dati relativi alle raccomandazioni basate sull\'IA abilitata.';

  @override
  String get aiRecommendationsDisabled =>
      'Condivisione dei dati relativi alle raccomandazioni basate sull\'IA disabilitata.';

  @override
  String get reviewAndManageConsent =>
      'Esaminare e gestire il consenso per l\'invio dei dati della biblioteca ai fornitori di intelligenza artificiale.';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      'Attivato. Recommend Tonight potrebbe inviare il riepilogo della tua libreria e le tue ricerche recenti ai fornitori di intelligenza artificiale.';

  @override
  String basedOnWatchedTitles(String count) {
    return 'In base ai titoli visualizzati ($count)';
  }

  @override
  String lastUpdated(String date) {
    return 'Ultimo aggiornamento: $date';
  }

  @override
  String get chooseYourVibe => 'Scegli il tuo stile';

  @override
  String get appearanceDescription =>
      'Passa da una personalità cinematografica all\'altra dell\'app senza modificarne il comportamento.';

  @override
  String get exitAppConfirmation => 'Sei sicuro di voler uscire da Lumi?';

  @override
  String get dismiss => 'Congedare';

  @override
  String get generatingWatchAnalytics => 'Generazione di analisi degli orologi';

  @override
  String get thisUsuallyTakesAFewSeconds =>
      'Questa operazione richiede solitamente pochi secondi.';

  @override
  String get yourScreenStory => 'La tua storia sullo schermo';

  @override
  String get snapshotOfHowAndWhatYouWatch =>
      'Una panoramica di come e cosa guardi';

  @override
  String get yourFavoriteGenres => 'I tuoi generi preferiti';

  @override
  String get genrePerformanceHighestRated =>
      'Performance di genere (punteggio più alto)';

  @override
  String get personalizedViewingPatterns =>
      'Modelli di visualizzazione personalizzati';

  @override
  String get builtWithLumi => 'Realizzato con Lumi';

  @override
  String get sharedWithLumi => 'Condiviso con Lumi';

  @override
  String get shareAnalytics => 'Analisi dei dati';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return 'Analizzati i titoli $count • Aggiornato $date';
  }

  @override
  String get allSeasons => 'Tutte le stagioni';

  @override
  String get castAndCrew => 'Cast e troupe';

  @override
  String get featuredCrew => 'Equipaggio in primo piano';

  @override
  String get stills => 'Immagini fisse';

  @override
  String get accoladeSummary => 'Riepilogo dei riconoscimenti';

  @override
  String get awardsAndAccolades => 'Premi e riconoscimenti';

  @override
  String get unableToLoadMovieDetails =>
      'Impossibile caricare i dettagli del film';

  @override
  String get overviewUnavailable =>
      'Panoramica non disponibile per questo titolo.';

  @override
  String get openCompletePlot =>
      'Apri la trama completa e i metadati aggiuntivi da OMDb.';

  @override
  String get noOverviewForSeason =>
      'Non è disponibile alcuna panoramica per questa stagione.';

  @override
  String get userScore => 'Punteggio utente';

  @override
  String get playTrailer => 'Guarda il trailer';

  @override
  String get whereToWatch => 'Dove guardare';

  @override
  String get availabilityDataByJustWatch =>
      'Dati di disponibilità forniti da JustWatch.';

  @override
  String get reminderSaved => 'Promemoria salvato';

  @override
  String reminderForTitle(String title) {
    return 'Promemoria per $title';
  }

  @override
  String get pleaseSelectFutureTime => 'Seleziona un orario futuro';

  @override
  String get notifyAt => 'Avvisare a';

  @override
  String get notifyHoursBeforeAiring =>
      'Con quante ore di anticipo avvisare prima della messa in onda?';

  @override
  String enterNumberBetween(String maxHours) {
    return 'Inserisci un numero compreso tra 1 e $maxHours';
  }

  @override
  String get set => 'Impostato';

  @override
  String get selectedReminderTimePassed =>
      'Il tempo selezionato per il promemoria è già trascorso.';

  @override
  String episodeReminderSaved(String date) {
    return 'Promemoria dell\'episodio salvato per $date';
  }

  @override
  String get areYouSureDeleteNote =>
      'Sei sicuro di voler eliminare questa nota?';

  @override
  String get noteAdded => 'Nota aggiunta';

  @override
  String get lastSeason => 'Stagione scorsa';

  @override
  String get currentSeason => 'Stagione attuale';

  @override
  String get viewAllSeasons => 'Visualizza tutte le stagioni';

  @override
  String get removedFromFavourites => 'Rimosso dai preferiti';

  @override
  String get addedToFavourites => 'Aggiunto ai preferiti';

  @override
  String get awardsAndNominations => 'Premi e candidature';

  @override
  String get viewAll => 'Visualizza tutto';

  @override
  String get boxOfficeFinancials => 'Dati finanziari del botteghino';

  @override
  String get successMeter => 'Misuratore di successo';

  @override
  String get blockbuster =>
      'Traduci questa etichetta dell\'app in: BLOCKBUSTER';

  @override
  String get hit => 'COLPO';

  @override
  String get breakEven => 'PAREGGIARE';

  @override
  String get underperformer => 'PRESTAZIONI INFERIORI';

  @override
  String get boxOfficeBomb => 'BOMBA AL BOTTEGHINO';

  @override
  String get episodeTracker => 'Tracciatore di episodi';

  @override
  String get setAiringReminder => 'Imposta promemoria di messa in onda';

  @override
  String get nextEpisodeCountdown =>
      'Conto alla rovescia per il prossimo episodio';

  @override
  String get nextEpisode => 'Prossimo episodio';

  @override
  String get lastEpisodeToAir => 'Ultimo episodio in onda';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get contentAdvisory => 'Avviso sui contenuti';

  @override
  String get violence => 'Violenza';

  @override
  String get sexAndNudity => 'Sesso e nudità';

  @override
  String get foulLanguage => 'Lingua';

  @override
  String get substances => 'Sostanze';

  @override
  String get fearAndHorror => 'Paura e orrore';

  @override
  String get familyFriendly => 'Adatto alle famiglie';

  @override
  String get generalAudience => 'Pubblico generale';

  @override
  String get releaseTimeline => 'Tempistiche di rilascio';

  @override
  String get notifyMe => 'Avvisami';

  @override
  String get theatricalRelease => 'Uscita nelle sale cinematografiche';

  @override
  String get digitalStreaming => 'Digitale / Streaming';

  @override
  String get physicalRelease => 'Formato fisico (Blu-ray / DVD)';

  @override
  String get awesome => 'Eccezionale';

  @override
  String get keywordsAndThemes => 'Parole chiave e temi';

  @override
  String get videosAndBehindTheScenes => 'Video e dietro le quinte';

  @override
  String get productionStudios => 'Studi di produzione';

  @override
  String get fetchingWatchLink => 'Recupero del link dell\'orologio';

  @override
  String get findingBestProviderPage =>
      'Trovare la pagina del fornitore migliore per questo titolo.';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode';
  }

  @override
  String get error => 'Errore';

  @override
  String get failedToLoadSeasonDetails =>
      'Impossibile caricare i dettagli della stagione';

  @override
  String get loading => 'Caricamento...';

  @override
  String runtimeSeparator(String runtime) {
    return 'Traduci questa etichetta dell\'app in: • $runtime';
  }

  @override
  String get fullCastAndCrew => 'Cast e troupe completi';

  @override
  String get shareMovie => 'Condividi il film';

  @override
  String get quotes => 'Citazioni';

  @override
  String get mayIncludeMismatches =>
      'Potrebbero essere presenti occasionali discrepanze dovute alla ricerca di citazioni lessicali.';

  @override
  String get movieApiConfigurationRequired =>
      'È necessaria la configurazione dell\'API Movie.';

  @override
  String get addMovieProxyBaseUrl =>
      'Aggiungi MOVIE_PROXY_BASE_URL per connettere l\'app al proxy TMDB.';

  @override
  String get cinematicPicksContext =>
      'Scelte cinematografiche con un\'atmosfera immediata. Tira i dadi per un\'altra carta a sorpresa.';

  @override
  String get curatedTonight => 'I migliori articoli di stasera';

  @override
  String curatedTonightTitle(String title) {
    return 'I contenuti selezionati stasera: $title';
  }

  @override
  String get describeItYourWay =>
      'Descrivilo a modo tuo.\nTroviamo le corrispondenze migliori.';

  @override
  String get hide => 'Nascondere';

  @override
  String get hideTitleDescription =>
      'Nascondendo questo titolo, si impedirà che venga visualizzato nella sezione In evidenza in futuro.';

  @override
  String get dontAskAgain => 'Non chiedere di nuovo';

  @override
  String get imdbNa => 'Traduci questa etichetta dell\'app in: IMDb NA';

  @override
  String get noDiscoverPicks =>
      'Al momento non sono disponibili selezioni Discover.';

  @override
  String get playPreview => 'Anteprima di riproduzione';

  @override
  String get recommendedForYou => 'Consigliato per te';

  @override
  String get spotlightCompleted => 'Riflettori puntati al termine';

  @override
  String get startAddingTitlesForRecommendations =>
      'Inizia ad aggiungere titoli per i consigli';

  @override
  String get clearedAllChoices =>
      'Hai eliminato tutte le opzioni dal tuo feed Discover.';

  @override
  String get whatsPopular => 'Cosa è popolare';

  @override
  String get trending => 'Di tendenza';

  @override
  String get nowPlaying => 'In riproduzione';

  @override
  String get tvTrending => 'Tendenze TV';

  @override
  String get discoverByMood => 'Scopri attraverso l\'umore';

  @override
  String get needSomethingToWatchTonight =>
      'Cerchi qualcosa da guardare stasera?';

  @override
  String get needAMovieForTonight => 'Cerchi un film per stasera?';

  @override
  String get tryAiShows => 'Prova gli spettacoli basati sull\'IA';

  @override
  String get tryAiMovies => 'Prova AI Movies';

  @override
  String get findShows => 'Trova spettacoli';

  @override
  String get findMovies => 'Trova film';

  @override
  String get couldNotLoadThisRail => 'Impossibile caricare questa rotaia';

  @override
  String get temporaryIssueLoadingRail =>
      'Si è verificato un problema temporaneo durante il carico su questa rotaia.';

  @override
  String get noTitlesHereYet => 'Ancora nessun titolo.';

  @override
  String get noHiddenGemsForGenre =>
      'Non sono ancora state trovate gemme nascoste per questo genere. Prova con un altro genere.';

  @override
  String get tryAnotherFilter =>
      'Prova un altro filtro oppure apri questa sezione per una ricerca più ampia.';

  @override
  String get seeAllFilters => 'Visualizza tutti i filtri';

  @override
  String get couldNotLoadCuratedPicks =>
      'Impossibile caricare i risultati selezionati';

  @override
  String get temporaryIssueLoadingCurated =>
      'Si è verificato un problema temporaneo durante il caricamento della lista selezionata per stasera.';

  @override
  String get noCuratedPicksAvailable => 'Nessuna selezione curata disponibile';

  @override
  String get tryAgainWhileRefresh =>
      'Riprova tra un attimo, mentre aggiorniamo l\'elenco TMDB di stasera.';

  @override
  String get fromSpotlight => 'Sotto i riflettori';

  @override
  String get addShowsMoviesForRecommendations =>
      'Aggiungi serie TV e film alla tua lista di titoli da guardare, ai preferiti o alla lista di titoli già visti per scoprire quelli che potrebbero piacerti.';

  @override
  String get allow => 'Permettere';

  @override
  String get notNow => 'Non adesso';

  @override
  String get allowAiDataSharingTitle =>
      'Consentire la condivisione dei dati dell\'IA?';

  @override
  String get allowAiDataSharingDescription =>
      'Recommend Tonight invia il testo che digiti per una richiesta di raccomandazione di film e un contesto temporaneo di affinamento della query a Google Gemini e OpenRouter. La tua libreria completa e le tue credenziali di accesso non vengono inviate a questi fornitori di intelligenza artificiale. Vuoi consentire questa condivisione di dati per le raccomandazioni basate sull\'IA?';

  @override
  String get liveProgress => 'Avanzamento in tempo reale';

  @override
  String percentComplete(String percent) {
    return '$percent% completato';
  }

  @override
  String get describeIdealShowNight =>
      'Descrivi la tua serata ideale di spettacolo';

  @override
  String get describeIdealMovieNight => 'Descrivi la tua serata cinema ideale';

  @override
  String get useNaturalLanguage =>
      'Utilizza un linguaggio naturale. Indica cosa desideri, cosa evitare e, facoltativamente, suggerimenti relativi al linguaggio o all\'esecuzione.';

  @override
  String get listeningTapMicToStop =>
      'In ascolto... tocca di nuovo il microfono per interrompere.';

  @override
  String voiceInputError(String error) {
    return 'Errore di input vocale: $error';
  }

  @override
  String get tapMicToDictate =>
      'Tocca il microfono per dettare la tua richiesta.';

  @override
  String get tapMicToEnableVoice =>
      'Tocca il microfono per abilitare l\'input vocale.';

  @override
  String get findingShows => 'Trovare spettacoli...';

  @override
  String get findingMovies => 'Trovare film...';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return 'I consigli di Lumi per stasera: $prompt';
  }

  @override
  String get tonightsPicks => 'Le scelte di stasera';

  @override
  String get sharedFromLumi => 'Condiviso da Lumi';

  @override
  String get intent => 'Intento:';

  @override
  String get genreLabel => 'Genere:';

  @override
  String get avoid => 'Evitare:';

  @override
  String get languageLabel => 'Lingua:';

  @override
  String runtimeAtMost(String minutes) {
    return 'Tempo di esecuzione <= $minutes min';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return 'Tempo di esecuzione >= $minutes min';
  }

  @override
  String get yearLabel => 'Anno:';

  @override
  String yearAfter(String year) {
    return 'Dopo $year';
  }

  @override
  String yearBefore(String year) {
    return 'Prima di $year';
  }

  @override
  String get like => 'Come:';

  @override
  String get signal => 'Segnale:';

  @override
  String get readingWatchedHistory =>
      'Leggendo la cronologia che hai guardato...';

  @override
  String get findingTopGenres => 'Scopri i tuoi generi e modelli preferiti...';

  @override
  String get buildingTrends => 'Analisi delle tendenze mensili e dei rating...';

  @override
  String get writingInsights => 'Scrivere le proprie analisi personalizzate...';

  @override
  String get applyFilters => 'Applica filtri';

  @override
  String get includeNotRated => 'Includi non valutato';

  @override
  String get errorLoadingTvGenres =>
      'Errore durante il caricamento dei generi TV';

  @override
  String get alsoKnownAs => 'Conosciuto anche come';

  @override
  String get biography => 'Biografia';

  @override
  String get careerStatistics => 'Statistiche di carriera';

  @override
  String get frequentlyCollaboratesWith => 'Collabora frequentemente con';

  @override
  String get notableQuotes => 'Citazioni celebri';

  @override
  String get primaryRole => 'Ruolo principale';

  @override
  String get averageRating => 'Valutazione media';

  @override
  String get topGenre => 'Genere principale';

  @override
  String get peakBoxOffice => 'Picco di incassi al botteghino';

  @override
  String percentOfTitles(String percent) {
    return '$percent% dei titoli';
  }

  @override
  String sharedTitleCount(String count) {
    return '$count titolo(i) condiviso(i)';
  }

  @override
  String billingOrder(String order) {
    return 'Fatturato n. $order';
  }

  @override
  String get startTypingToSearch => 'Inizia a digitare per cercare';

  @override
  String get movieDiscoveryMadePersonal =>
      'Scoperta del cinema, resa personale';

  @override
  String get allNotes => 'Tutte le note';

  @override
  String get viewPersonalizedInsights =>
      'Visualizza analisi personalizzate, grafici e tendenze.';

  @override
  String get curatedCollections => 'Collezioni selezionate';

  @override
  String get list => 'lista';

  @override
  String get openList => 'Lista aperta';

  @override
  String get thisListNoLongerExists => 'Questo elenco non esiste più';

  @override
  String listRenamed(String name) {
    return 'Elenco rinominato in $name';
  }

  @override
  String listDeleted(String name) {
    return 'Elenco $name eliminato';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return 'Nessun $filter nella tua watchlist';
  }

  @override
  String noFilterInFavourites(String filter) {
    return 'Nessun $filter nei tuoi preferiti';
  }

  @override
  String noFilterInWatched(String filter) {
    return 'Nessun $filter osservato';
  }

  @override
  String noFilterInThisList(String filter) {
    return 'Nessun $filter in questo elenco';
  }

  @override
  String noListsWithFilter(String filter) {
    return 'Nessun elenco con $filter';
  }

  @override
  String importedInto(String name) {
    return 'Importato in \"$name\"';
  }

  @override
  String get couldNotImportList => 'Impossibile importare l\'elenco';

  @override
  String get importing => 'Importazione...';

  @override
  String get couldNotLoadSharedList =>
      'Impossibile caricare questo elenco condiviso';

  @override
  String get editWatchedInfo =>
      'Modifica le informazioni sugli elementi visualizzati';

  @override
  String get watchDate => 'Guarda la data';

  @override
  String get rewatchCount => 'Numero di volte che guardo';

  @override
  String get watchedInfoUpdated => 'Informazioni aggiornate';

  @override
  String removedFromList(String listName) {
    return 'Rimosso da $listName';
  }

  @override
  String addedToList(String listName) {
    return 'Aggiunto a $listName';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return 'Aggiunto a $listName e alla watchlist';
  }

  @override
  String get moreTrailersLikeThis => 'Altri trailer come questo';

  @override
  String get noDescriptionForTrailer =>
      'Nessuna descrizione disponibile per questo trailer.';

  @override
  String get closeTrailer => 'Trailer chiuso';

  @override
  String get recommendedSeries => 'Serie consigliate';

  @override
  String get recommendedMovie => 'Film consigliato';

  @override
  String get notEnoughDataYet => 'Dati ancora insufficienti';

  @override
  String addAndRateMoreTitles(String count) {
    return 'Aggiungi e valuta almeno $count titoli per sbloccare le statistiche.';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return 'Hai guardato $watchedCount/$requiredCount titoli. Aggiungine altri $remaining per sbloccare le statistiche.';
  }

  @override
  String get moviesPerMonth => 'Film al mese';

  @override
  String get genreDistribution => 'Distribuzione dei generi';

  @override
  String get ratingTrends => 'Andamento delle valutazioni';

  @override
  String get noData => 'Nessun dato';

  @override
  String get myLatestWatchAnalytics =>
      'Le mie ultime analisi sugli orologi Lumi';

  @override
  String get myWatchInsights => 'Le mie considerazioni sull\'orologio Lumi';

  @override
  String get infographicsCard => 'Scheda Infografica';

  @override
  String get watchInsightsSnapshot => 'Panoramica delle analisi';

  @override
  String get availableOnceInsightsReady =>
      'Disponibile non appena i dati saranno pronti.';

  @override
  String get shareYourWatchInsights =>
      'Condividi la tua scheda informativa sugli orologi';

  @override
  String get recentlyWatchedVibe => 'Vibe guardato di recente';

  @override
  String get mixedAcrossGenres => 'Un mix di generi';

  @override
  String get moviesPerMonthShort => 'Film al mese';

  @override
  String get ratingTrend => 'Andamento delle valutazioni';

  @override
  String get balanced => 'Equilibrato';

  @override
  String get noWatchNextSuggestionsYet =>
      'Nessun suggerimento su cosa guardare dopo.';

  @override
  String get upcomingFromLibrary => 'Prossimamente dalla tua biblioteca';

  @override
  String get removeReminder => 'Rimuovi promemoria';

  @override
  String get remindMe => 'Ricordami';

  @override
  String titleReleasesToday(String title) {
    return '$title viene rilasciato oggi.';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle andrà in onda presto.';
  }

  @override
  String get controlPremiereAlerts =>
      'Gestisci gli avvisi di anteprima e i promemoria di rilascio.';

  @override
  String upcomingReleasesCount(String count) {
    return '$count Prossime uscite nella tua libreria.';
  }

  @override
  String sittingInWatchlist(String days) {
    return 'Presente nella tua watchlist da $days giorni';
  }

  @override
  String get alreadyOnWatchlist => 'Già nella tua lista di monitoraggio';

  @override
  String get favouritedButNotWatched =>
      'Hai aggiunto questo elemento ai preferiti ma non l\'hai ancora contrassegnato come visualizzato.';

  @override
  String get savedInListReady =>
      'Salvato in una delle tue liste e pronto per essere guardato';

  @override
  String get matchesTitlesYouTrack => 'Corrisponde ai titoli che già segui';

  @override
  String get noOfficialSite => 'Nessun sito ufficiale';

  @override
  String get episodeAiring => 'Episodio in onda';

  @override
  String get general => 'Generale';

  @override
  String scheduledFor(String date) {
    return 'Previsto per $date';
  }

  @override
  String wasScheduledFor(String date) {
    return 'Era previsto per $date';
  }

  @override
  String get noOverviewAvailable => 'Nessuna panoramica disponibile.';

  @override
  String get searchHistoryCleared => 'Cronologia delle ricerche cancellata';

  @override
  String get visualMovieCard => 'Scheda video visuale';

  @override
  String get smartLumiLink =>
      'Traduci questa etichetta dell\'app in: Smart Lumi Link';

  @override
  String get directTmdbLink => 'Collegamento diretto a TMDB';

  @override
  String recommendedOnLumi(String title) {
    return 'Consigliato su Lumi: $title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return 'Scopri $title su Lumi!\n\n$link\n\nAcquista Lumi: $appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return 'Consulta $title su TMDB: $link';
  }

  @override
  String releaseAlertTitle(String title) {
    return 'Avviso di rilascio $title';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return 'È stato impostato un avviso di rilascio per $date. Ti avviseremo quando sarà disponibile.';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return 'Ti avviseremo non appena \"$title\" sarà disponibile in formato digitale o su Blu-ray/DVD!';
  }

  @override
  String get episodeAlreadyDueToAir =>
      'Questo episodio è già in programma per la messa in onda';

  @override
  String get reminderSetSuccessfully => 'Promemoria impostato correttamente';

  @override
  String get speechRecognitionNotAvailable =>
      'Il riconoscimento vocale non è disponibile su questo dispositivo.';

  @override
  String get describeShowMood =>
      'Descrivi quale programma ti piacerebbe vedere e ti forniremo una classifica.';

  @override
  String get describeMovieMood =>
      'Descrivi il tipo di film che ti piacerebbe vedere e ti forniremo una classifica.';

  @override
  String get aiLauncherDescription =>
      'Digita o pronuncia una richiesta in linguaggio naturale. Lumi crea un piano basato sull\'intelligenza artificiale, esegue una ricerca vettoriale e restituisce diverse proposte di film/serie TV.';

  @override
  String yearRange(String from, String to) {
    return 'Traduci questa etichetta dell\'app in: $from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return 'Promemoria programmato per $count.';
  }

  @override
  String regionAutoDetected(String region) {
    return 'Rilevato automaticamente: $region';
  }

  @override
  String regionSelected(String region) {
    return 'Selezionato: $region';
  }

  @override
  String get allLanguagesSubtitle => 'Tutte le lingue';

  @override
  String currentlySetToLanguage(String language) {
    return 'Attualmente impostato su $language';
  }

  @override
  String get availabilities => 'Disponibilità';

  @override
  String get mood => 'Umore';

  @override
  String get people => 'Persone';

  @override
  String get ads => 'Annunci';

  @override
  String get theatricalLimited =>
      'Traduci questa etichetta dell\'app in: Theatrical Limited';

  @override
  String get premier => 'Traduci questa etichetta dell\'app in: Premier';

  @override
  String get mediaType => 'Icona multimediale';

  @override
  String get couldNotLoadAnalytics => 'Impossibile caricare i dati analitici';

  @override
  String get viewAllAwards => 'Visualizza tutto';

  @override
  String get win => 'Vincita';

  @override
  String get wins => 'Vittorie';

  @override
  String get nomination => 'Nomina';

  @override
  String get nominations => 'Candidature';

  @override
  String sharedBy(String name) {
    return 'Condiviso da $name';
  }

  @override
  String titleCount(String count) {
    return '$count titolo(i)';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count titoli salvati in tutti i tuoi elenchi';
  }

  @override
  String get curatedCollectionsSubtitle =>
      'Collezioni selezionate che puoi organizzare e condividere.';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return 'Importa \"$name\" in Lumi ($count $itemLabel): $link';
  }

  @override
  String get notEnoughData => 'Dati insufficienti';

  @override
  String shareQuote(String title) {
    return 'Dai un\'occhiata a questa citazione di \"$title\" su Lumi!';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Consigliato su Lumi: $title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      'Digita o pronuncia una richiesta in linguaggio naturale. Lumi crea un piano basato sull\'intelligenza artificiale, esegue una ricerca vettoriale e restituisce diverse proposte di programmi.';

  @override
  String get aiLauncherDescriptionMovie =>
      'Digita o pronuncia una richiesta in linguaggio naturale. Lumi crea un piano basato sull\'intelligenza artificiale, esegue una ricerca vettoriale e restituisce diverse proposte di film.';

  @override
  String get warmingUpMovieSearch => 'Riscaldamento della ricerca di film';

  @override
  String get connectingToRecommendationEngine =>
      'Connessione al motore di raccomandazione';

  @override
  String get understandingYourTaste => 'Capire di cosa hai voglia';

  @override
  String get buildingCustomSearch =>
      'Creazione di una ricerca personalizzata in base alla tua richiesta';

  @override
  String get tinyNetworkHiccup => 'Piccolo problema di rete, riprovo.';

  @override
  String get planLocked => 'Piano bloccato: genere, stile, lingua e durata';

  @override
  String get scanningTmdb =>
      'Scansione di TMDB alla ricerca di corrispondenze significative';

  @override
  String get collectingDetails =>
      'Raccolta di poster, valutazioni e durata per le migliori scelte';

  @override
  String shortlistingPicksCount(String current, String total) {
    return 'Selezione dei candidati ($current/$total)';
  }

  @override
  String get shortlistingBestPicks => 'Selezione delle migliori opzioni';

  @override
  String get finalPolish => 'Ultimi ritocchi alle vostre raccomandazioni.';

  @override
  String get retryingAfterIssue => 'Riprovo dopo un problema temporaneo';

  @override
  String get regionUnitedStates => 'Stati Uniti';

  @override
  String get regionIndia => 'Traduci in: India';

  @override
  String get regionUnitedKingdom => 'Regno Unito';

  @override
  String get regionCanada => 'Traduci in: Canada';

  @override
  String get regionAustralia => 'Traduci in: Australia';

  @override
  String get regionNewZealand => 'Nuova Zelanda';

  @override
  String get regionGermany => 'Germania';

  @override
  String get regionFrance => 'Francia';

  @override
  String get regionSpain => 'Spagna';

  @override
  String get regionItaly => 'Italia';

  @override
  String get regionJapan => 'Giappone';

  @override
  String get regionSouthKorea => 'Corea del Sud';

  @override
  String get regionBrazil => 'Brasile';

  @override
  String get regionMexico => 'Messico';

  @override
  String get regionSingapore => 'Traduci in: Singapore';

  @override
  String get regionPhilippines => 'Filippine';

  @override
  String get regionIndonesia => 'Traduci in: Indonesia';

  @override
  String get regionUnitedArabEmirates => 'Emirati Arabi Uniti';

  @override
  String get regionSaudiArabia => 'Arabia Saudita';

  @override
  String get regionTurkey => 'Tacchino';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return 'Regione rilevata automaticamente: $regionLabel ($regionCode). Seleziona una regione da sovrascrivere per le ricerche di film localizzati e le ricerche di fornitori di contenuti.';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return 'Regione selezionata: $regionLabel ($regionCode). Le query sui film e le ricerche sui fornitori di contenuti supportati riutilizzeranno automaticamente questa informazione la prossima volta.';
  }

  @override
  String get syncSignInTooltip => 'Accedi per sincronizzare con il cloud';

  @override
  String get syncFailedTooltip =>
      'Sincronizzazione non riuscita. Tocca per riprovare.';

  @override
  String get syncedTooltip => 'Libreria sincronizzata con il cloud';

  @override
  String get shareQuoteTooltip => 'Condividi la citazione';

  @override
  String get copyQuoteTooltip => 'Copia citazione';

  @override
  String get quoteCopiedToast => 'Citazione copiata negli appunti';

  @override
  String get shareDialogueTooltip => 'Condividi il dialogo';

  @override
  String get copyDialogueTooltip => 'Copia dialogo';

  @override
  String get dialogueCopiedToast => 'Dialogo copiato negli appunti';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$title andrà in onda tra 1 ora';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel \"$episodeName\" va in onda alle $localAirTime.';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$title viene rilasciato oggi';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return 'Un film presente nella tua libreria uscirà il $localDate.';
  }

  @override
  String get curatedNeoNoirNights => 'Notti neo-noir';

  @override
  String get curatedPulsePoundingRush => 'Un\'ondata travolgente';

  @override
  String get curatedFeelGoodEscape => 'Fuga rigenerante';

  @override
  String get curatedMindBenders => 'Sbilancia-mente';

  @override
  String get curatedEpicWorlds => 'Traducilo in: Mondi epici';

  @override
  String get curatedHumanStories => 'Storie umane';

  @override
  String get curatedDarkDetectiveFiles => 'Traducilo in: Dark Detective Files';

  @override
  String get curatedNeoNoirNightsDescription =>
      'Tensione intrisa di pioggia, protagonisti moralmente ambigui e storie cittadine suggestive.';

  @override
  String get curatedPulsePoundingRushDescription =>
      'Inseguimenti ad alto rischio, pericolo crescente e ritmo incalzante.';

  @override
  String get curatedFeelGoodEscapeDescription =>
      'Storie commoventi, trame edificanti e titoli perfetti per una serata rilassante.';

  @override
  String get curatedMindBendersDescription =>
      'Concetti che distorcono la realtà, trame intricate e storie che affrontano grandi temi.';

  @override
  String get curatedEpicWorldsDescription =>
      'Avventure in universi vasti, posta in gioco epica e portata cinematografica.';

  @override
  String get curatedHumanStoriesDescription =>
      'Drammi incentrati sui personaggi, con un forte impatto emotivo e interpretazioni memorabili.';

  @override
  String get curatedDarkDetectiveFilesDescription =>
      'Indizi freddi, sospetti a catena e indagini che si sviluppano lentamente.';

  @override
  String get appLanguage => 'Lingua dell\'app';

  @override
  String get appLanguageSystemDefault => 'Impostazioni predefinite del sistema';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return 'La lingua dell\'app è impostata su $language. Questa impostazione modifica solo l\'interfaccia dell\'app, non la lingua di film e serie TV.';
  }

  @override
  String get appLanguageSystemSubtitle =>
      'La lingua dell\'app segue le impostazioni del dispositivo. Modificala per mantenere l\'interfaccia in una lingua diversa.';

  @override
  String get contentLanguageAllSubtitle =>
      'Tutte le lingue. Le schede Film e TV rimangono generiche, mentre Esplora può comunque privilegiare i contenuti locali più pertinenti, laddove disponibili.';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return 'Attualmente impostato su $language. Le schede Film e TV manterranno la formattazione standard, mentre Esplora darà la precedenza a questa lingua.';
  }
}
