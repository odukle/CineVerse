// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Lumière';

  @override
  String get navExplore => 'Explorer';

  @override
  String get navMovies => 'Films';

  @override
  String get navTvShows => 'Séries TV';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navAccount => 'Compte';

  @override
  String get searchHint =>
      'Rechercher des films, des émissions de télévision, des entreprises...';

  @override
  String get searchForPerson => 'Rechercher une personne...';

  @override
  String get searchLanguages => 'Rechercher des langues';

  @override
  String get searchNameOrRole => 'Rechercher un nom ou un rôle...';

  @override
  String get retry => 'Réessayer';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get clear => 'Effacer';

  @override
  String get cancel => 'Annuler';

  @override
  String get ok => 'D\'ACCORD';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get share => 'Partager';

  @override
  String get undo => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get apply => 'Appliquer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get done => 'Terminé';

  @override
  String get signInWithGoogle => 'Connectez-vous avec Google';

  @override
  String get signInWithApple => 'Connectez-vous avec Apple';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get accountDeletedSuccessfully => 'Compte supprimé avec succès.';

  @override
  String get appearance => 'Apparence';

  @override
  String get appearanceSubtitle =>
      'Choisissez votre thème et personnalisez l\'apparence de l\'application.';

  @override
  String get notifications =>
      'Traduire le libellé de cette application en français : Notifications';

  @override
  String get releaseCalendar => 'Calendrier de publication';

  @override
  String get hiddenTitles => 'Titres cachés';

  @override
  String get aiRecommendationsPrivacy => 'Recommandations IA Confidentialité';

  @override
  String get contentRegion => 'Région du contenu';

  @override
  String get contentLanguage => 'Langue du contenu';

  @override
  String get watchlist => 'Liste de surveillance';

  @override
  String get notes =>
      'Traduire le libellé de cette application en français : Notes';

  @override
  String get deleteNote => 'Supprimer la note';

  @override
  String get addNoteHint => 'Ajouter une note...';

  @override
  String get addBriefNoteHint => 'Ajouter une brève note (facultatif)...';

  @override
  String get enterNewName => 'Entrez un nouveau nom...';

  @override
  String get importSharedList => 'Importer la liste partagée';

  @override
  String get discoverOnLumi => 'DÉCOUVRIR SUR LUMI';

  @override
  String get filtered => 'Filtré';

  @override
  String get fullPlot => 'Tracé complet';

  @override
  String get userReviews => 'Avis des utilisateurs';

  @override
  String get noReviewsYet => 'Aucun avis pour l\'instant.';

  @override
  String get openInYouTube => 'Ouvrir sur YouTube';

  @override
  String get hiddenGems => 'Trésors cachés';

  @override
  String get resetSpotlight => 'Réinitialiser Spotlight';

  @override
  String get clearPreferences => 'Effacer les préférences';

  @override
  String get refreshPicks => 'Actualiser les choix';

  @override
  String get shareBoard => 'Partager le tableau';

  @override
  String get exploreDetails => 'Explorer les détails';

  @override
  String get searchWikiquotes => 'Rechercher dans les citations Wiki';

  @override
  String get selectAQuote => 'Sélectionner une citation';

  @override
  String get tooltipShareQuote => 'Partager la citation';

  @override
  String get tooltipCopyQuote => 'Copier la citation';

  @override
  String get tooltipShareDialogue => 'Partager le dialogue';

  @override
  String get tooltipCopyDialogue => 'Copier le dialogue';

  @override
  String get tooltipUnhide => 'Afficher';

  @override
  String get tooltipOpenPrivacyPolicy =>
      'Ouvrir la politique de confidentialité';

  @override
  String get tooltipRefreshInsights => 'Actualiser les informations';

  @override
  String get tooltipSortTitles => 'Trier les titres';

  @override
  String get tooltipSearch => 'Rechercher';

  @override
  String get tooltipFilters => 'Filtres';

  @override
  String get tooltipSaveToGallery => 'Enregistrer dans la galerie';

  @override
  String get tooltipShare => 'Partager';

  @override
  String get tooltipShareAnalytics => 'Partager les analyses';

  @override
  String get tooltipSetAiringReminder => 'Définir un rappel de diffusion';

  @override
  String get tooltipLibrarySynced => 'Bibliothèque synchronisée avec le cloud';

  @override
  String get noMoreEntries => 'Plus d\'entrées';

  @override
  String get noItemsFound => 'Aucun article trouvé';

  @override
  String errorLoadingGenres(String error) {
    return 'Erreur de chargement des genres : $error';
  }

  @override
  String errorGeneric(String error) {
    return 'Erreur : $error';
  }

  @override
  String get errorLoadingLists => 'Erreur de chargement des listes';

  @override
  String errorLoadingQuotes(Object error) {
    return 'Échec du chargement des citations : $error';
  }

  @override
  String get errorCouldNotShareAnalytics =>
      'Impossible partager la carte d\'analyse.';

  @override
  String get errorCouldNotShareRecommendations =>
      'Impossible de partager le tableau de recommandations.';

  @override
  String get errorCouldNotShareInsights =>
      'Impossible de partager les informations sur la montre. Les insights';

  @override
  String get watchInsightsNotReady => 'Watch ne sont pas encore prêts.';

  @override
  String titleRestoredToSpotlight(String title) {
    return '\"$title\" restauré dans Spotlight';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '\"$title\" a été masqué';
  }

  @override
  String hiddenDate(String date) {
    return 'Masqué : $date';
  }

  @override
  String get moviesInThisCollection => 'Films de cette collection';

  @override
  String get searchPlanReady => 'Le plan de recherche est prêt';

  @override
  String get hoursBeforeAirTime => 'Heures avant la diffusion';

  @override
  String get noUpcomingReleases => 'Aucune sortie à venir';

  @override
  String get noRemindersSet => 'Aucun rappel défini';

  @override
  String get noHiddenTitles => 'Aucun titre masqué';

  @override
  String get hiddenTitlesDescription =>
      'Les titres que vous masquez dans la section « À la une » apparaîtront ici, et vous pourrez les restaurer à tout moment.';

  @override
  String get tvShow => 'ÉMISSION DE TÉLÉVISION';

  @override
  String get movie => 'FILM';

  @override
  String get aiConsentGranted =>
      'Vous avez accepté. Les données de votre bibliothèque sont utilisées pour personnaliser les recommandations.';

  @override
  String get aiConsentNotGranted =>
      'Les données de votre bibliothèque ne sont jamais partagées, sauf si vous y consentez.';

  @override
  String get languageSettingExplanation =>
      'Les onglets Films et TV l\'utilisent strictement. Explore le préfère en premier et se replie lorsqu\'un rail devient clairsemé.';

  @override
  String get filterScreenTitle => 'Filtres';

  @override
  String get sortBy => 'Trier par';

  @override
  String get genres =>
      'Traduire le libellé de cette application en français : Genres';

  @override
  String get year => 'Année';

  @override
  String get rating => 'Note';

  @override
  String get runtime => 'Durée d\'exécution';

  @override
  String get withPeople => 'Avec des personnes';

  @override
  String get voteCount => 'Nombre de votes';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get yesterday => 'Hier';

  @override
  String get minutes => 'Traduire le libellé de cette application en fr: min';

  @override
  String get hours =>
      'Traduisez le libellé de cette application en français : h';

  @override
  String get cast => 'Casting';

  @override
  String get crew => 'Equipe';

  @override
  String get director => 'F@ Casting @G@ Equipe @H@ Réalisateur';

  @override
  String get seasons => 'Saisons';

  @override
  String get episodes => 'Épisodes';

  @override
  String get overview => 'Aperçu';

  @override
  String get similar => 'Similaires';

  @override
  String get recommendations => 'Recommandations';

  @override
  String get addedToWatchlist => 'Ajouté à la liste de surveillance';

  @override
  String get removedFromWatchlist => 'Supprimé de la liste de surveillance';

  @override
  String get popularity => 'Popularité';

  @override
  String get releaseDate => 'Date de sortie';

  @override
  String get revenueLabel => 'Revenus';

  @override
  String get originalTitle => 'Titre original';

  @override
  String get voteAverage => 'Moyenne des votes';

  @override
  String get favourites => 'Favoris';

  @override
  String get lists => 'listes';

  @override
  String get watched => 'Regardé';

  @override
  String get all => 'Tous';

  @override
  String get tv => 'TV';

  @override
  String get librarySubtitle =>
      'Gardez tout organisé par collection, favoris, notes et historique de visionnage.';

  @override
  String get selectRegion => 'Sélectionner la région';

  @override
  String get selectRegionDescription =>
      'Seuls les points de terminaison TMDb prenant en charge les requêtes prenant en compte la région utiliseront cette sélection.';

  @override
  String get useAutoDetectedRegion =>
      'Utiliser la région détectée automatiquement';

  @override
  String get reminderRemoved => 'Rappel supprimé';

  @override
  String releaseReminderSet(String title) {
    return 'Rappel de libération programmé pour $title.';
  }

  @override
  String episodeReminderSet(String title) {
    return 'Rappel d\'épisode programmé pour $title.';
  }

  @override
  String get filteredResults => 'Résultats filtrés';

  @override
  String get genreResults => 'Résultats par genre';

  @override
  String couldNotLoadContent(String error) {
    return 'Impossible de charger le contenu. $error';
  }

  @override
  String get noContentAvailableForThisSelection =>
      'Aucun contenu disponible pour cette sélection.';

  @override
  String get writer => 'Écrivain';

  @override
  String get actors => 'Acteurs';

  @override
  String get noteNotFound => 'Note introuvable.';

  @override
  String yourNotesCount(int count) {
    return 'Vos notes ($count)';
  }

  @override
  String get noteDeleted => 'Note supprimée';

  @override
  String noteDeletedWithCount(int count) {
    return 'Note supprimée ($count s)';
  }

  @override
  String get loadMore => 'Charger plus';

  @override
  String get noMoreProductionsFound => 'Aucune autre production trouvée.';

  @override
  String get noProductionsFound => 'Aucune production trouvée.';

  @override
  String get watchInsights =>
      'Traduire le libellé de cette application en français : Watch Insights';

  @override
  String get analyzingWatchHistory =>
      'Analyse de l\'historique de votre montre...';

  @override
  String get manageHiddenTitlesDescription =>
      'Gérez les titres que vous avez masqués dans la section Spotlight.';

  @override
  String get tmdbLanguageMetadataNote =>
      'Certaines lignes peuvent paraître clairsemées dans ce mode car les métadonnées linguistiques de TMDB sont incomplètes pour certaines parties du catalogue, et non pas nécessairement parce que ces titres n\'existent pas.';

  @override
  String get tmdbDisclaimer =>
      'Ce produit utilise l\'API TMDB mais n\'est ni approuvé ni certifié par TMDB.';

  @override
  String get useLocalLibraryForSync =>
      'Utiliser une bibliothèque locale pour la synchronisation ?';

  @override
  String get themePresets => 'Préréglages de thèmes';

  @override
  String get exitApp => 'Quitter l\'application';

  @override
  String get popular => 'Populaire';

  @override
  String couldNotLoadReminders(String error) {
    return 'Impossible de charger les rappels.\n\n$error';
  }

  @override
  String get noRemindersSetYet =>
      'Aucun rappel configuré pour le moment.\n\nCréez-en un depuis le Suivi des épisodes ou les Détails du film.';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return 'Épisode S$seasonNumber • E$episodeNumber';
  }

  @override
  String get movieRelease => 'Sortie du film';

  @override
  String voteAverageStars(String voteAverage) {
    return 'Traduire le libellé de cette application en français : $voteAverage ★';
  }

  @override
  String get addMoreTrackedContent =>
      'Ajoutez d\'autres films ou séries à votre liste de visionnage, à vos favoris ou à vos listes.';

  @override
  String get fastPicksDescription =>
      'Sélection rapide basée sur ce que vous avez déjà enregistré.';

  @override
  String get releaseCalendarDescription =>
      'Sorties de films et prochains épisodes de séries télévisées avec rappels en un clic.';

  @override
  String get staleWatchlist => 'Liste de surveillance obsolète';

  @override
  String get tracked => 'Suivi';

  @override
  String get upcoming => 'Prochain';

  @override
  String get upcomingEmptyDescription =>
      'Lorsque les films suivis auront une date de sortie ou que de nouveaux épisodes seront programmés pour les séries, ils apparaîtront ici.';

  @override
  String get howManyMoviesWatchedEachMonth =>
      'Combien de films avez-vous regardés chaque mois';

  @override
  String get howPersonalRatingsShifting =>
      'Comment vos évaluations personnelles évoluent au fil du temps';

  @override
  String get keepWatchingToBuildProfile =>
      'Continuez à regarder pour étoffer votre profil visuel.';

  @override
  String get lumiWatchAnalytics => 'ANALYSE DES MONTRES LUMI';

  @override
  String get noGenreDistributionYet =>
      'Aucune répartition par genre n\'est disponible pour le moment.';

  @override
  String get noMovieWatchHistoryRecentMonths =>
      'Aucun historique de visionnage de films ces derniers mois.';

  @override
  String get noRatingTrendDataYet =>
      'Aucune donnée sur les tendances de notation n\'est disponible pour le moment.';

  @override
  String get preferredRuntime => 'Durée d\'exécution préférée';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return 'Durée d\'exécution préférée : ~$minutes minutes ($label)';
  }

  @override
  String get styledCardWithWatchStats =>
      'Carte stylisée avec les statistiques de votre montre';

  @override
  String get titlesAnalyzed => 'Titres analysés';

  @override
  String get tryAgainAfterMoment => 'Réessayez dans un instant.';

  @override
  String get watchAnalytics =>
      'Traduire le libellé de cette application en français : Watch Analytics';

  @override
  String get whatGenresDominateHistory =>
      'Quels genres dominent votre histoire horlogère ?';

  @override
  String get toggleMovies => 'Films';

  @override
  String get toggleTv => 'TV';

  @override
  String get noMoreTitlesFound => 'Aucun autre titre trouvé.';

  @override
  String get noTitlesFoundForKeyword => 'Aucun titre trouvé pour ce mot-clé';

  @override
  String get viewFull => 'Voir la version complète';

  @override
  String get accoladeDetails => 'Détails de la distinction';

  @override
  String get noDetailedAwardsInfo =>
      'Aucune information détaillée sur les récompenses n\'est disponible.';

  @override
  String get alertSet => 'Alerte activée !';

  @override
  String get budget =>
      'Traduire le libellé de cette application en français : Budget';

  @override
  String get buy => 'Acheter';

  @override
  String chooseBetweenHours(int maxHours) {
    return 'Choisissez entre 1 et $maxHours';
  }

  @override
  String get deleteNoteConfirmationTitle => 'Supprimer la note ?';

  @override
  String get episodeReminder => 'Rappel de l\'épisode';

  @override
  String get facebook => 'Facebook';

  @override
  String get free => 'Gratuit';

  @override
  String get images =>
      'Traduire le libellé de cette application en français : Images';

  @override
  String get instagram => 'Instagram';

  @override
  String get netProfit => 'Bénéfice net';

  @override
  String get noNotesYet =>
      'Aucun commentaire pour l\'instant. Ajoutez vos impressions !';

  @override
  String get originalLanguage => 'Langue originale';

  @override
  String partOfCollection(String collectionName) {
    return 'Une partie du $collectionName';
  }

  @override
  String get roi => 'retour sur investissement';

  @override
  String releaseAlertSet(String date) {
    return 'Alerte de surveillance déclenchée pour $date.';
  }

  @override
  String get rent => 'Louer';

  @override
  String get revenue => 'Revenu';

  @override
  String seeAllReviews(int count) {
    return 'Voir tout ($count)';
  }

  @override
  String get setReminder => 'Définir un rappel';

  @override
  String get status => 'Statut';

  @override
  String get stream => 'Flux';

  @override
  String get tikTok => 'TikTok';

  @override
  String get twitterX => 'X';

  @override
  String get yours => 'LE VÔTRE';

  @override
  String get youtube => 'YouTube';

  @override
  String get durationDays =>
      'Traduisez le libellé de cette application en français : d';

  @override
  String get durationHours =>
      'Traduisez le libellé de cette application en français : h';

  @override
  String get durationMinutes =>
      'Traduisez le libellé de cette application en fr: m';

  @override
  String get durationSeconds =>
      'Traduisez le libellé de cette application en français : s';

  @override
  String seasonRating(String score) {
    return 'Traduire le libellé de cette application en français : ★ $score%';
  }

  @override
  String get we => 'Nous';

  @override
  String get aspect16x9 =>
      'Traduire le libellé de cette application en français : 16:9';

  @override
  String get aspect9x16 =>
      'Traduire le libellé de cette application en français : 9:16';

  @override
  String get background =>
      'Traduire le libellé de cette application en français : Bg';

  @override
  String episodeCount(int count) {
    return 'Traduire le libellé de cette application en français : $count Eps';
  }

  @override
  String get noEpisodesForSeason => 'Aucun épisode trouvé pour cette saison.';

  @override
  String get beautifulStyledCardForStories =>
      'Carte au style soigné pour les histoires sociales';

  @override
  String get clickableShareLink =>
      'Lien de partage cliquable pour WhatsApp et autres applications';

  @override
  String get placeQuoteOnBackdrop =>
      'Placez votre citation préférée sur un fond de film.';

  @override
  String get standardLinkToMovieDatabase =>
      'Lien standard vers la base de données de films';

  @override
  String get exploreLabel => 'Explorer';

  @override
  String quoteCharacter(String character) {
    return 'Traduire le libellé de cette application en français : — $character';
  }

  @override
  String get aiTonightWatch => 'IA ce soir à regarder';

  @override
  String get aiQueryPlan => 'plan de requête IA';

  @override
  String get airingToday => 'Diffusion aujourd\'hui';

  @override
  String get bigCrowdPleasers =>
      'Des succès populaires qui connaissent une forte croissance';

  @override
  String get cinematic => 'Cinématique';

  @override
  String get comingSoon => 'À venir';

  @override
  String get currentTheatricalSlate =>
      'Programmation actuelle des films à l\'affiche et sorties à venir';

  @override
  String get dark => 'Sombre';

  @override
  String get discoverSpotlight => 'Découvrez Spotlight';

  @override
  String get edgeOfYourSeat => 'À vous tenir en haleine';

  @override
  String get fastPaced => 'Rythmé';

  @override
  String get feelGood => 'Se sentir bien';

  @override
  String get freshPicksContinuous => 'Sélection mise à jour en continu';

  @override
  String get hideTitle => 'Masquer le titre';

  @override
  String get highRatedSkipped =>
      'Les titres les mieux notés que la plupart des spectateurs ignorent';

  @override
  String get hotNowAudience =>
      'En ce moment, le flux d\'audience est très populaire.';

  @override
  String get inTheaters => 'Au cinéma';

  @override
  String get indie =>
      'Traduire le libellé de cette application en français : Indie';

  @override
  String get mindBending => 'Époustouflant';

  @override
  String get mostDiscussedShowsThisWeek =>
      'Les émissions les plus commentées cette semaine';

  @override
  String get multiplePicks => 'Choix multiples';

  @override
  String get onTheAir => 'À l\'antenne';

  @override
  String get personalizedFromWatchBehavior =>
      'Personnalisé en fonction de votre comportement avec votre montre';

  @override
  String get pickAVibe =>
      'Choisissez une ambiance et obtenez instantanément des titres correspondants';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get seriesCurrentlyAiring =>
      'Séries actuellement diffusées avec des épisodes disponibles';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get topRated => 'Les mieux notés';

  @override
  String get voiceInput => 'Entrée vocale';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% Correspondance';
  }

  @override
  String runtimeMinutes(String minutes) {
    return 'Traduisez ce libellé d\'application en français : $minutes min';
  }

  @override
  String get examplePrompt =>
      'Exemple : Quelque chose comme Interstellar, mais pas de science-fiction.';

  @override
  String findingYourPerfectWatch(String dots) {
    return 'Trouver la montre parfaite$dots';
  }

  @override
  String get moreLikeThis => 'Plus d\'articles similaires';

  @override
  String get notForMe => 'Pas pour moi';

  @override
  String get recentQueries => 'Requêtes récentes';

  @override
  String get shufflingIdeas => 'Mélanger les idées...';

  @override
  String get tooMainstream => 'Trop grand public';

  @override
  String get whatShouldIWatchTonight => 'Que devrais-je regarder ce soir ?';

  @override
  String debugLogEntry(String time, String message) {
    return 'Traduire le libellé de cette application en français : [$time] $message';
  }

  @override
  String get from => 'Depuis';

  @override
  String get to => 'À';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return 'Retiré de la liste de surveillance ($seconds s)';
  }

  @override
  String creditsCount(String count) {
    return '$count Crédits';
  }

  @override
  String get acrossFilmography => 'Filmographie';

  @override
  String get birthplace => 'Lieu de naissance';

  @override
  String get born => 'Né';

  @override
  String get credits => 'Crédits';

  @override
  String get died => 'Décédé';

  @override
  String get knownFor => 'Connu pour';

  @override
  String get noSharedTitlesAvailable => 'Aucun titre partagé disponible.';

  @override
  String get photos =>
      'Traduire le libellé de cette application en français : Photos';

  @override
  String get personRating => 'Notation';

  @override
  String get taggedImages => 'Images étiquetées';

  @override
  String get website => 'Site web';

  @override
  String get noQuotesFound => 'Aucune citation trouvée.';

  @override
  String get noSectionsFound => 'Aucune section trouvée.';

  @override
  String get clearAll => 'Effacer tout';

  @override
  String get noCollectionsFound => 'Aucune collection trouvée';

  @override
  String get noCompaniesFound => 'Aucune entreprise trouvée';

  @override
  String get noKeywordsFound => 'Aucun mot-clé trouvé';

  @override
  String get noMoreResultsFound => 'Aucun autre résultat trouvé.';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String deleteListConfirmation(String listName) {
    return 'Êtes-vous sûr de vouloir supprimer $listName ?';
  }

  @override
  String get deleteListTitle => 'Supprimer la liste ?';

  @override
  String get everythingYouPlanToWatch =>
      'Tout ce que vous prévoyez de regarder ensuite.';

  @override
  String get finishedTitlesAndHistory =>
      'Titres obtenus, ainsi que votre historique et vos statistiques.';

  @override
  String get noListsCreatedYet => 'Aucune liste n\'a encore été créée.';

  @override
  String get noNotesFound => 'Aucune note trouvée';

  @override
  String get renameList => 'Liste de renommage';

  @override
  String get titlesYouNeverWantToLose =>
      'Les titres que vous ne voulez jamais perdre.';

  @override
  String get yourThoughtsReactions => 'Vos pensées, réactions et rappels.';

  @override
  String imageCounter(String current, String total) {
    return 'Traduire le libellé de cette application en français : $current / $total';
  }

  @override
  String get removeFromWatchedConfirmation =>
      'Êtes-vous sûr de vouloir retirer cet élément de votre liste de surveillance ?';

  @override
  String get savedAsWatchedWithoutRating =>
      'Cette vidéo sera enregistrée comme visionnée sans évaluation personnelle.';

  @override
  String get noAdditionalRecommendationTrailers =>
      'Aucune autre bande-annonce recommandée n\'a été trouvée.';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return 'Traduire le libellé de cette application en français : $count $itemLabel';
  }

  @override
  String get invalidSharedListLink =>
      'Le lien est peut-être invalide, expiré ou inaccessible.';

  @override
  String get noTitlesAvailableToImport =>
      'Aucun titre n\'est disponible à l\'importation.';

  @override
  String get allLanguages => 'Toutes les langues';

  @override
  String get arabic => 'arabe';

  @override
  String get bengali => 'bengali';

  @override
  String get chinese => 'Chinois';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get german => 'Allemand';

  @override
  String get gujarati =>
      'Traduire le libellé de cette application en gujarati (fr)';

  @override
  String get hindi => 'hindi';

  @override
  String get indonesian => 'indonésien';

  @override
  String get italian => 'italien';

  @override
  String get japanese => 'japonais';

  @override
  String get kannada =>
      'Traduire le libellé de cette application en français : kannada';

  @override
  String get korean => 'coréen';

  @override
  String get malayalam =>
      'Traduire le libellé de cette application en malayalam';

  @override
  String get marathi =>
      'Traduire le libellé de cette application en fr: Marathi';

  @override
  String get persian => 'persan';

  @override
  String get polish => 'polonais';

  @override
  String get portuguese => 'portugais';

  @override
  String get punjabi =>
      'Traduire le libellé de cette application en fr : Punjabi';

  @override
  String get russian => 'russe';

  @override
  String get spanish => 'Espagnol';

  @override
  String get swedish => 'suédois';

  @override
  String get tamil => 'tamoul';

  @override
  String get telugu =>
      'Traduire le libellé de cette application en télougou (fr)';

  @override
  String get thai => 'thaïlandais';

  @override
  String get turkish => 'turc';

  @override
  String get urdu => 'ourdou';

  @override
  String get vietnamese => 'vietnamien';

  @override
  String get failedToLoadCollectionDetails =>
      'Impossible de charger les détails de la collection';

  @override
  String get franchiseProgress => 'Progrès de la franchise';

  @override
  String get officialSite => 'Site officiel';

  @override
  String get productions =>
      'Traduire le libellé de cette application en français : Productions';

  @override
  String get productionCompany => 'Société de production';

  @override
  String get failedToLoadCompanyInfo =>
      'Impossible de charger les informations de l\'entreprise';

  @override
  String get profile => 'Profil';

  @override
  String get guestViewer => 'Spectateur invité';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      'Votre profil, votre état de synchronisation, votre région et vos préférences visuelles se trouvent ici.';

  @override
  String get signInToSync =>
      'Connectez-vous pour synchroniser votre liste de visionnage, vos évaluations et vos préférences.';

  @override
  String get signedInAndSyncing =>
      'Connexion établie et synchronisation avec le cloud en cours.';

  @override
  String get developedBy => 'Développé par';

  @override
  String get couldNotAnalyzeWatchHistory =>
      'Impossible d\'analyser l\'historique des montres pour le moment.';

  @override
  String get includeLocalLibrary => 'Inclure la bibliothèque locale';

  @override
  String get useCloudOnly => 'Utiliser uniquement le cloud';

  @override
  String get localLibrarySyncDescription =>
      'Cet appareil contient déjà des titres de bibliothèque locale. Ajoutez-les à votre bibliothèque locale ou remplacez les données de la bibliothèque locale par celles de votre bibliothèque cloud.';

  @override
  String get mergedLocalTitles =>
      'Les titres locaux ont été fusionnés avec votre bibliothèque connectée.';

  @override
  String get replacedLocalLibrary =>
      'Les données de la bibliothèque locale ont été remplacées par celles de votre bibliothèque cloud.';

  @override
  String get deleteAccountConfirmation =>
      'Cette action supprime définitivement votre compte Lumi et les données synchronisées dans le cloud. Les données locales sur cet appareil resteront intactes, sauf si vous supprimez les données de l\'application séparément.';

  @override
  String get signedOutAndCleared =>
      'Déconnexion et suppression de la bibliothèque locale sur cet appareil.';

  @override
  String get keepLocalLibrary => 'Préservez votre bibliothèque locale';

  @override
  String get clearLocalLibrary => 'Bibliothèque locale propre';

  @override
  String get signOutChoiceDescription =>
      'Choisissez si vous souhaitez conserver la bibliothèque locale sur cet appareil après la déconnexion.';

  @override
  String get disable => 'Désactiver';

  @override
  String get aiRecommendationsEnabled =>
      'Partage de données des recommandations IA activé.';

  @override
  String get aiRecommendationsDisabled =>
      'Le partage des données relatives aux recommandations de l\'IA est désactivé.';

  @override
  String get reviewAndManageConsent =>
      'Examiner et gérer le consentement relatif à l\'envoi de données de bibliothèque aux fournisseurs d\'IA.';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      'Activé. L\'option « Recommander ce soir » peut envoyer le résumé de votre bibliothèque et vos dernières requêtes à des fournisseurs d\'IA.';

  @override
  String basedOnWatchedTitles(String count) {
    return 'D\'après les titres visionnés $count';
  }

  @override
  String lastUpdated(String date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get chooseYourVibe =>
      'Choisissez votre ambiance. Choisissez votre style.';

  @override
  String get appearanceDescription =>
      'Changez de personnalité cinématographique dans l\'application sans modifier aucun comportement.';

  @override
  String get exitAppConfirmation => 'Êtes-vous sûr de vouloir quitter Lumi ?';

  @override
  String get dismiss => 'Rejeter';

  @override
  String get generatingWatchAnalytics => 'Générer des analyses de montres';

  @override
  String get thisUsuallyTakesAFewSeconds =>
      'Cela prend généralement quelques secondes.';

  @override
  String get yourScreenStory => 'Votre histoire à l\'écran';

  @override
  String get snapshotOfHowAndWhatYouWatch =>
      'Un aperçu de ce que vous regardez et de comment vous le regardez';

  @override
  String get yourFavoriteGenres => 'Vos genres préférés';

  @override
  String get genrePerformanceHighestRated =>
      'Performance du genre (Meilleure note)';

  @override
  String get personalizedViewingPatterns =>
      'Modèles de visionnage personnalisés';

  @override
  String get builtWithLumi => 'Conçu avec Lumi';

  @override
  String get sharedWithLumi => 'Partagé avec Lumi';

  @override
  String get shareAnalytics => 'Analyses de partage';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return 'Titres analysés $count • Titres mis à jour $date';
  }

  @override
  String get allSeasons => 'Toutes saisons';

  @override
  String get castAndCrew => 'Distribution et équipe technique';

  @override
  String get featuredCrew => 'Équipe vedette';

  @override
  String get stills => 'Images fixes';

  @override
  String get accoladeSummary => 'Résumé des distinctions';

  @override
  String get awardsAndAccolades => 'Prix et distinctions';

  @override
  String get unableToLoadMovieDetails =>
      'Impossible de charger les détails du film';

  @override
  String get overviewUnavailable => 'Présentation indisponible pour ce titre.';

  @override
  String get openCompletePlot =>
      'Ouvrir le synopsis complet et les métadonnées supplémentaires depuis OMDb.';

  @override
  String get noOverviewForSeason =>
      'Aucun aperçu disponible pour cette saison.';

  @override
  String get userScore => 'Note de l\'utilisateur';

  @override
  String get playTrailer => 'Bande-annonce de Play';

  @override
  String get whereToWatch => 'Où regarder';

  @override
  String get availabilityDataByJustWatch =>
      'Données de disponibilité fournies par JustWatch.';

  @override
  String get reminderSaved => 'Rappel enregistré';

  @override
  String reminderForTitle(String title) {
    return 'Rappel pour $title';
  }

  @override
  String get pleaseSelectFutureTime =>
      'Veuillez sélectionner une date ultérieure';

  @override
  String get notifyAt => 'Prévenez à';

  @override
  String get notifyHoursBeforeAiring =>
      'Prévenir combien d\'heures avant la diffusion ?';

  @override
  String enterNumberBetween(String maxHours) {
    return 'Saisissez un nombre entre 1 et $maxHours';
  }

  @override
  String get set => 'Ensemble';

  @override
  String get selectedReminderTimePassed =>
      'L\'heure de rappel sélectionnée est déjà passée.';

  @override
  String episodeReminderSaved(String date) {
    return 'Rappel d\'épisode enregistré pour $date';
  }

  @override
  String get areYouSureDeleteNote =>
      'Êtes-vous sûr de vouloir supprimer cette note ?';

  @override
  String get noteAdded => 'Note ajoutée';

  @override
  String get lastSeason => 'La saison dernière';

  @override
  String get currentSeason => 'Saison actuelle';

  @override
  String get viewAllSeasons => 'Voir toutes les saisons';

  @override
  String get removedFromFavourites => 'Retiré des favoris';

  @override
  String get addedToFavourites => 'Ajouté aux favoris';

  @override
  String get awardsAndNominations => 'Prix et nominations';

  @override
  String get viewAll => 'Afficher tout';

  @override
  String get boxOfficeFinancials => 'Résultats financiers du box-office';

  @override
  String get successMeter => 'Indicateur de réussite';

  @override
  String get blockbuster =>
      'Traduisez le nom de cette application en français : BLOCKBUSTER';

  @override
  String get hit => 'FRAPPER';

  @override
  String get breakEven => 'SEUIL DE RENTABILITÉ';

  @override
  String get underperformer => 'PERFORMANCES RÉDUITES';

  @override
  String get boxOfficeBomb => 'ÉCHEC AU BOX-OFFICE';

  @override
  String get episodeTracker => 'Suivi des épisodes';

  @override
  String get setAiringReminder => 'Programmer un rappel de diffusion';

  @override
  String get nextEpisodeCountdown => 'Compte à rebours du prochain épisode';

  @override
  String get nextEpisode => 'Prochain épisode';

  @override
  String get lastEpisodeToAir => 'Dernier épisode à diffuser';

  @override
  String get unknown => 'Inconnu';

  @override
  String get contentAdvisory => 'Avertissement relatif au contenu';

  @override
  String get violence =>
      'Traduire le libellé de cette application en français : Violence';

  @override
  String get sexAndNudity => 'Sexe et nudité';

  @override
  String get foulLanguage => 'Langue';

  @override
  String get substances =>
      'Traduire le libellé de cette application en français : Substances';

  @override
  String get fearAndHorror => 'Peur et horreur';

  @override
  String get familyFriendly => 'Adapté aux familles';

  @override
  String get generalAudience => 'Grand public';

  @override
  String get releaseTimeline => 'Calendrier de sortie';

  @override
  String get notifyMe => 'Prévenez-moi';

  @override
  String get theatricalRelease => 'Sortie en salles';

  @override
  String get digitalStreaming => 'Numérique / Streaming';

  @override
  String get physicalRelease => 'Version physique (Blu-ray / DVD)';

  @override
  String get awesome => 'Génial';

  @override
  String get keywordsAndThemes => 'Mots clés et thèmes';

  @override
  String get videosAndBehindTheScenes => 'Vidéos et coulisses';

  @override
  String get productionStudios => 'Studios de production';

  @override
  String get fetchingWatchLink => 'Récupération du lien de la montre';

  @override
  String get findingBestProviderPage =>
      'Trouver la meilleure page fournisseur pour ce titre.';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode';
  }

  @override
  String get error => 'Erreur';

  @override
  String get failedToLoadSeasonDetails =>
      'Impossible de charger les détails de la saison';

  @override
  String get loading => 'Chargement...';

  @override
  String runtimeSeparator(String runtime) {
    return 'Traduire le libellé de cette application en français : • $runtime';
  }

  @override
  String get fullCastAndCrew => 'Distribution et équipe complètes';

  @override
  String get shareMovie => 'Partager un film';

  @override
  String get quotes => 'Citations';

  @override
  String get mayIncludeMismatches =>
      'Peut contenir des erreurs de correspondance occasionnelles dues à la recherche par citation lexicale.';

  @override
  String get movieApiConfigurationRequired =>
      'Configuration de l\'API Movie requise';

  @override
  String get addMovieProxyBaseUrl =>
      'Ajoutez MOVIE_PROXY_BASE_URL pour connecter l\'application au proxy TMDB.';

  @override
  String get cinematicPicksContext =>
      'Des choix cinématographiques qui donnent immédiatement le ton. Lancez les dés pour une autre carte surprise.';

  @override
  String get curatedTonight => 'Sélectionné pour ce soir';

  @override
  String curatedTonightTitle(String title) {
    return 'Sélection de ce soir : $title';
  }

  @override
  String get describeItYourWay =>
      'Décrivez-le à votre façon.\n\nNous trouvons les meilleures correspondances.';

  @override
  String get hide => 'Cacher';

  @override
  String get hideTitleDescription =>
      'Masquer ce titre l\'empêchera d\'apparaître dans la section « À la une » à l\'avenir.';

  @override
  String get dontAskAgain => 'Ne posez plus la question';

  @override
  String get imdbNa =>
      'Traduire le libellé de cette application en français : IMDb NA';

  @override
  String get noDiscoverPicks =>
      'Aucune sélection de découverte disponible pour le moment.';

  @override
  String get playPreview => 'Aperçu du jeu';

  @override
  String get recommendedForYou => 'Recommandé pour vous';

  @override
  String get spotlightCompleted => 'Projecteur terminé';

  @override
  String get startAddingTitlesForRecommendations =>
      'Commencez à ajouter des titres pour les recommandations';

  @override
  String get clearedAllChoices =>
      'Vous avez fait défiler et effacé tous les choix dans votre flux Découvrir.';

  @override
  String get whatsPopular => 'Ce qui est populaire';

  @override
  String get trending => 'Tendances';

  @override
  String get trendingPeople => 'Personnalités tendances';

  @override
  String get starringTodayOrThisWeek =>
      'Étoiles tendance aujourd\'hui ou cette semaine';

  @override
  String get nowPlaying => 'Lecture en cours';

  @override
  String get tvTrending => 'Tendances TV';

  @override
  String get discoverByMood => 'Découvrez par humeur';

  @override
  String get needSomethingToWatchTonight =>
      'Vous cherchez quelque chose à regarder ce soir ?';

  @override
  String get needAMovieForTonight => 'Besoin d\'un film pour ce soir ?';

  @override
  String get tryAiShows => 'Essayez les émissions d\'IA';

  @override
  String get tryAiMovies => 'Essayez les films d\'IA';

  @override
  String get findShows => 'Trouver des spectacles';

  @override
  String get findMovies => 'Trouver des films';

  @override
  String get couldNotLoadThisRail => 'Impossible de charger ce rail';

  @override
  String get temporaryIssueLoadingRail =>
      'Un problème temporaire est survenu lors du chargement de ce rail.';

  @override
  String get noTitlesHereYet => 'Aucun titre ici pour le moment';

  @override
  String get noHiddenGemsForGenre =>
      'Aucun joyau caché trouvé pour ce genre pour l\'instant. Essayez un autre genre.';

  @override
  String get tryAnotherFilter =>
      'Essayez un autre filtre ou ouvrez cette section pour une exploration plus large.';

  @override
  String get seeAllFilters => 'Afficher tous les filtres';

  @override
  String get couldNotLoadCuratedPicks =>
      'Impossible de charger la sélection personnalisée.';

  @override
  String get temporaryIssueLoadingCurated =>
      'Un problème temporaire est survenu lors du chargement de la liste de ce soir.';

  @override
  String get noCuratedPicksAvailable =>
      'Aucune sélection personnalisée disponible';

  @override
  String get tryAgainWhileRefresh =>
      'Veuillez réessayer dans un instant, le temps que nous actualisions la liste TMDB de ce soir.';

  @override
  String get fromSpotlight => 'De Spotlight';

  @override
  String get addShowsMoviesForRecommendations =>
      'Ajoutez des séries télévisées/films à votre liste de visionnage, à vos favoris ou à votre liste de films vus pour découvrir des titres susceptibles de vous plaire.';

  @override
  String get allow => 'Permettre';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get allowAiDataSharingTitle => 'Autoriser le partage de données IA ?';

  @override
  String get allowAiDataSharingDescription =>
      'Recommend Tonight envoie le texte que vous saisissez pour une demande de recommandation de film, ainsi qu\'un contexte temporaire d\'affinage de la requête, à Google Gemini et OpenRouter. Votre bibliothèque complète et vos identifiants de connexion ne sont pas transmis à ces fournisseurs d\'IA. Autorisez-vous ce partage de données pour les recommandations d\'IA ?';

  @override
  String get liveProgress => 'Progression en direct';

  @override
  String percentComplete(String percent) {
    return '$percent% terminé';
  }

  @override
  String get describeIdealShowNight => 'Décrivez votre soirée spectacle idéale';

  @override
  String get describeIdealMovieNight => 'Décrivez votre soirée cinéma idéale';

  @override
  String get useNaturalLanguage =>
      'Utilisez un langage naturel. Mentionnez ce que vous souhaitez, ce que vous voulez éviter et, le cas échéant, des indications linguistiques ou d\'exécution.';

  @override
  String get listeningTapMicToStop =>
      'Écoute en cours... appuyez à nouveau sur le micro pour arrêter.';

  @override
  String voiceInputError(String error) {
    return 'Erreur de saisie vocale : $error';
  }

  @override
  String get tapMicToDictate =>
      'Appuyez sur le micro pour dicter votre demande.';

  @override
  String get tapMicToEnableVoice =>
      'Appuyez sur le micro pour activer la saisie vocale.';

  @override
  String get findingShows => 'Trouver des émissions...';

  @override
  String get findingMovies => 'Trouver des films...';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return 'Les choix Lumi de ce soir pour : $prompt';
  }

  @override
  String get tonightsPicks => 'Les pronostics de ce soir';

  @override
  String get sharedFromLumi => 'Partagé depuis Lumi';

  @override
  String get intent => 'Intention:';

  @override
  String get genreLabel =>
      'Traduire le libellé de cette application en français : Genre :';

  @override
  String get avoid => 'Éviter:';

  @override
  String get languageLabel => 'Langue:';

  @override
  String runtimeAtMost(String minutes) {
    return 'Durée d\'exécution <= $minutes min';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return 'Durée d\'exécution >= $minutes min';
  }

  @override
  String get yearLabel => 'Année:';

  @override
  String yearAfter(String year) {
    return 'Après $year';
  }

  @override
  String yearBefore(String year) {
    return 'Avant $year';
  }

  @override
  String get like => 'Comme:';

  @override
  String get signal =>
      'Traduire le libellé de cette application en français : Signal :';

  @override
  String get readingWatchedHistory => 'Lire votre historique de visionnage...';

  @override
  String get findingTopGenres =>
      'Identifier vos genres et tendances principaux...';

  @override
  String get buildingTrends =>
      'Élaboration des tendances mensuelles et des notes...';

  @override
  String get writingInsights => 'Rédiger vos réflexions personnalisées...';

  @override
  String get applyFilters => 'Appliquer les filtres';

  @override
  String get includeNotRated => 'Inclure les non évalués';

  @override
  String get errorLoadingTvGenres => 'Erreur lors du chargement des genres TV';

  @override
  String get alsoKnownAs => 'Également connu sous le nom de';

  @override
  String get biography => 'Biographie';

  @override
  String get careerStatistics => 'Statistiques de carrière';

  @override
  String get frequentlyCollaboratesWith => 'Collabore fréquemment avec';

  @override
  String get notableQuotes => 'Citations remarquables';

  @override
  String get primaryRole => 'Rôle principal';

  @override
  String get averageRating => 'Note moyenne';

  @override
  String get topGenre => 'Genre principal';

  @override
  String get peakBoxOffice => 'Box-office de pointe';

  @override
  String percentOfTitles(String percent) {
    return '$percent% des titres';
  }

  @override
  String sharedTitleCount(String count) {
    return '$count titre(s) partagé(s)';
  }

  @override
  String billingOrder(String order) {
    return 'Facturé n° $order';
  }

  @override
  String get startTypingToSearch =>
      'Commencez à saisir du texte pour effectuer une recherche';

  @override
  String get movieDiscoveryMadePersonal =>
      'Découverte de films, rendue personnelle';

  @override
  String get allNotes => 'Toutes les notes';

  @override
  String get viewPersonalizedInsights =>
      'Consultez des analyses, des graphiques et des tendances personnalisés.';

  @override
  String get curatedCollections => 'Collections sélectionnées';

  @override
  String get list => 'liste';

  @override
  String get openList => 'Liste ouverte';

  @override
  String get thisListNoLongerExists => 'Cette liste n\'existe plus.';

  @override
  String listRenamed(String name) {
    return 'Liste renommée $name';
  }

  @override
  String listDeleted(String name) {
    return 'Liste $name supprimée';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return 'Aucun $filter dans votre liste de surveillance';
  }

  @override
  String noFilterInFavourites(String filter) {
    return 'Aucun $filter dans vos favoris';
  }

  @override
  String noFilterInWatched(String filter) {
    return 'Aucun $filter dans la liste des visionnages';
  }

  @override
  String noFilterInThisList(String filter) {
    return 'Aucun $filter dans cette liste';
  }

  @override
  String noListsWithFilter(String filter) {
    return 'Aucune liste avec $filter';
  }

  @override
  String importedInto(String name) {
    return 'Importé dans \"$name\"';
  }

  @override
  String get couldNotImportList => 'Impossible d\'importer la liste';

  @override
  String get importing => 'Importation en cours...';

  @override
  String get couldNotLoadSharedList =>
      'Impossible de charger cette liste partagée';

  @override
  String get editWatchedInfo => 'Modifier les informations de visionnage';

  @override
  String get watchDate => 'Date de surveillance';

  @override
  String get rewatchCount => 'Nombre de visionnages';

  @override
  String get watchedInfoUpdated => 'Informations mises à jour';

  @override
  String removedFromList(String listName) {
    return 'Retiré de $listName';
  }

  @override
  String addedToList(String listName) {
    return 'Ajouté à $listName';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return 'Ajouté à $listName et à la liste de surveillance';
  }

  @override
  String get moreTrailersLikeThis => 'Plus de bandes-annonces comme celle-ci';

  @override
  String get noDescriptionForTrailer =>
      'Aucune description disponible pour cette bande-annonce.';

  @override
  String get closeTrailer => 'Bande-annonce fermée';

  @override
  String get recommendedSeries => 'Séries recommandées';

  @override
  String get recommendedMovie => 'Film recommandé';

  @override
  String get notEnoughDataYet => 'Données insuffisantes pour le moment';

  @override
  String addAndRateMoreTitles(String count) {
    return 'Ajoutez et évaluez au moins $count titres pour débloquer les analyses.';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return 'Vous avez visionné $watchedCount/$requiredCount titres. Ajoutez $remaining titres supplémentaires pour accéder aux statistiques.';
  }

  @override
  String get moviesPerMonth => 'Films par mois';

  @override
  String get genreDistribution => 'Répartition par genre';

  @override
  String get ratingTrends => 'Tendances de notation';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get myLatestWatchAnalytics =>
      'Mes dernières analyses de montres sur Lumi';

  @override
  String get myWatchInsights => 'Mon avis sur le Lumi dans les montres';

  @override
  String get infographicsCard => 'Carte infographique';

  @override
  String get watchInsightsSnapshot => 'Aperçu des informations sur la montre';

  @override
  String get availableOnceInsightsReady =>
      'Disponible une fois les analyses prêtes';

  @override
  String get shareYourWatchInsights =>
      'Partagez votre carte d\'informations sur les montres';

  @override
  String get recentlyWatchedVibe => 'Vibe récemment visionné';

  @override
  String get mixedAcrossGenres => 'Mélange de genres';

  @override
  String get moviesPerMonthShort => 'Films / Mois';

  @override
  String get ratingTrend => 'Tendances de notation';

  @override
  String get balanced => 'Équilibré';

  @override
  String get noWatchNextSuggestionsYet =>
      'Aucune suggestion de film ou série à regarder pour le moment';

  @override
  String get upcomingFromLibrary => 'Prochainement dans votre bibliothèque';

  @override
  String get removeReminder => 'Supprimer le rappel';

  @override
  String get remindMe => 'Rappelle-moi';

  @override
  String titleReleasesToday(String title) {
    return '$title sort aujourd\'hui.';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle sera bientôt diffusé.';
  }

  @override
  String get controlPremiereAlerts =>
      'Contrôlez les alertes de première et les rappels de sortie.';

  @override
  String upcomingReleasesCount(String count) {
    return '$count prochaine(s) sortie(s) dans votre bibliothèque.';
  }

  @override
  String sittingInWatchlist(String days) {
    return 'En attente dans votre liste de surveillance depuis $days jours';
  }

  @override
  String get alreadyOnWatchlist => 'Déjà sur votre liste de surveillance';

  @override
  String get favouritedButNotWatched =>
      'Vous avez ajouté cette page à vos favoris, mais vous ne l\'avez pas encore marquée comme vue.';

  @override
  String get savedInListReady =>
      'Enregistré dans une de vos listes et prêt à être visionné';

  @override
  String get matchesTitlesYouTrack =>
      'Correspond aux titres que vous suivez déjà.';

  @override
  String get noOfficialSite => 'Aucun site officiel';

  @override
  String get episodeAiring => 'Diffusion de l\'épisode';

  @override
  String get general => 'Général';

  @override
  String scheduledFor(String date) {
    return 'Prévu pour $date';
  }

  @override
  String wasScheduledFor(String date) {
    return 'Prévu pour $date';
  }

  @override
  String get noOverviewAvailable => 'Aucun aperçu disponible.';

  @override
  String get searchHistoryCleared => 'Historique de recherche effacé';

  @override
  String get visualMovieCard => 'Carte de film visuelle';

  @override
  String get smartLumiLink => 'Lien lumineux intelligent';

  @override
  String get directTmdbLink => 'Lien direct vers TMDB';

  @override
  String recommendedOnLumi(String title) {
    return 'Recommandé sur Lumi : $title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return 'Découvrez $title sur Lumi !\n\n$link\n\nObtenez Lumi : $appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return 'Consultez la fiche $title sur TMDB : $link';
  }

  @override
  String releaseAlertTitle(String title) {
    return 'Alerte de publication $title';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return 'Alerte de sortie activée pour $date. Nous vous informerons dès sa disponibilité.';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return 'Nous vous informerons dès que \"$title\" sera disponible en version numérique ou en Blu-ray/DVD !';
  }

  @override
  String get episodeAlreadyDueToAir =>
      'Cet épisode est déjà programmé pour diffusion.';

  @override
  String get reminderSetSuccessfully => 'Rappel configuré avec succès';

  @override
  String get speechRecognitionNotAvailable =>
      'La reconnaissance vocale n\'est pas disponible sur cet appareil.';

  @override
  String get describeShowMood =>
      'Décrivez-nous le type de série que vous avez envie de regarder, et nous vous proposerons un classement.';

  @override
  String get describeMovieMood =>
      'Décrivez le film que vous avez envie de voir, et nous vous proposerons une liste classée.';

  @override
  String get aiLauncherDescription =>
      'Saisissez ou dictez une requête en langage naturel. Lumi élabore un plan basé sur l\'IA, effectue une recherche vectorielle et vous propose plusieurs suggestions de films et de séries.';

  @override
  String yearRange(String from, String to) {
    return 'Traduire le libellé de cette application en français : $from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return '$count rappel(s) programmé(s).';
  }

  @override
  String regionAutoDetected(String region) {
    return 'Détection automatique : $region';
  }

  @override
  String regionSelected(String region) {
    return 'Sélectionné : $region';
  }

  @override
  String get allLanguagesSubtitle => 'Toutes les langues';

  @override
  String currentlySetToLanguage(String language) {
    return 'Actuellement réglé sur $language';
  }

  @override
  String get availabilities => 'Disponibilités';

  @override
  String get mood => 'Humeur';

  @override
  String get people => 'Personnes';

  @override
  String get ads => 'Publicités';

  @override
  String get theatricalLimited => 'Sortie en salles limitée';

  @override
  String get premier =>
      'Traduire le libellé de cette application en français : Premier';

  @override
  String get mediaType => 'Type de média';

  @override
  String get couldNotLoadAnalytics => 'Impossible de charger les analyses';

  @override
  String get viewAllAwards => 'Afficher tout';

  @override
  String get win => 'Gagner';

  @override
  String get wins => 'Victoires';

  @override
  String get nomination =>
      'Traduire le libellé de cette application en français : Nomination';

  @override
  String get nominations => 'Candidatures';

  @override
  String sharedBy(String name) {
    return 'Partagé par $name';
  }

  @override
  String titleCount(String count) {
    return '$count titre(s)';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count titres enregistrés dans vos listes';
  }

  @override
  String get curatedCollectionsSubtitle =>
      'Des collections organisées que vous pouvez partager.';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return 'Importer \"$name\" dans Lumi ($count $itemLabel): $link';
  }

  @override
  String get notEnoughData => 'Données insuffisantes';

  @override
  String shareQuote(String title) {
    return 'Découvrez cette citation de \"$title\" sur Lumi !';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Recommandé sur Lumi : $title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      'Saisissez ou dictez une requête en langage naturel. Lumi élabore un plan basé sur l\'IA, effectue une recherche vectorielle et vous propose plusieurs suggestions de spectacles.';

  @override
  String get aiLauncherDescriptionMovie =>
      'Saisissez ou dictez une requête en langage naturel. Lumi élabore un plan basé sur l\'IA, effectue une recherche vectorielle et vous propose plusieurs films.';

  @override
  String get warmingUpMovieSearch => 'Échauffement de votre recherche de films';

  @override
  String get connectingToRecommendationEngine =>
      'Connexion au moteur de recommandation';

  @override
  String get understandingYourTaste => 'Comprendre ce dont vous avez envie';

  @override
  String get buildingCustomSearch =>
      'Création d\'une recherche personnalisée à partir de votre requête';

  @override
  String get tinyNetworkHiccup =>
      'Petit problème de réseau, nouvelle tentative';

  @override
  String get planLocked => 'Plan verrouillé : genre, style, langue et durée';

  @override
  String get scanningTmdb =>
      'Recherche de correspondances pertinentes dans TMDB';

  @override
  String get collectingDetails =>
      'Collecte des affiches, des notes et de la durée des meilleurs films';

  @override
  String shortlistingPicksCount(String current, String total) {
    return 'Sélection des candidats retenus ($current/$total)';
  }

  @override
  String get shortlistingBestPicks => 'Sélection des meilleurs choix';

  @override
  String get finalPolish => 'Dernières précisions sur vos recommandations';

  @override
  String get retryingAfterIssue =>
      'Nouvelle tentative suite à un problème temporaire';

  @override
  String get regionUnitedStates => 'États-Unis';

  @override
  String get regionIndia => 'Inde';

  @override
  String get regionUnitedKingdom => 'Royaume-Uni';

  @override
  String get regionCanada => 'Traduction en français : Canada';

  @override
  String get regionAustralia => 'Australie';

  @override
  String get regionNewZealand => 'Nouvelle-Zélande';

  @override
  String get regionGermany => 'Allemagne';

  @override
  String get regionFrance => 'Traduction en français : France';

  @override
  String get regionSpain => 'Espagne';

  @override
  String get regionItaly => 'Italie';

  @override
  String get regionJapan => 'Japon';

  @override
  String get regionSouthKorea => 'Corée du Sud';

  @override
  String get regionBrazil => 'Brésil';

  @override
  String get regionMexico => 'Mexique';

  @override
  String get regionSingapore => 'Singapour';

  @override
  String get regionPhilippines => 'Traduction en français : Philippines';

  @override
  String get regionIndonesia => 'Indonésie';

  @override
  String get regionUnitedArabEmirates => 'Émirats arabes unis';

  @override
  String get regionSaudiArabia => 'Arabie Saoudite';

  @override
  String get regionTurkey => 'Turquie';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return 'Région détectée automatiquement : $regionLabel ($regionCode). Sélectionnez une région à remplacer pour les requêtes de films localisées et les recherches de fournisseurs de visionnage.';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return 'Région sélectionnée : $regionLabel ($regionCode). Les requêtes de films et les recherches de fournisseurs de visionnage prises en charge réutiliseront automatiquement cette région lors de la prochaine utilisation.';
  }

  @override
  String get syncSignInTooltip =>
      'Connectez-vous pour synchroniser avec le cloud';

  @override
  String get syncFailedTooltip =>
      'La synchronisation a échoué. Appuyez pour réessayer.';

  @override
  String get syncedTooltip => 'Bibliothèque synchronisée avec le cloud';

  @override
  String get shareQuoteTooltip => 'Partager la citation';

  @override
  String get copyQuoteTooltip => 'Copier la citation';

  @override
  String get quoteCopiedToast => 'Citation copiée dans le presse-papiers';

  @override
  String get shareDialogueTooltip => 'Partager le dialogue';

  @override
  String get copyDialogueTooltip => 'Copier le dialogue';

  @override
  String get dialogueCopiedToast => 'Dialogue copié dans le presse-papiers';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$title sera diffusé dans 1 heure';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel \"$episodeName\" est diffusé à $localAirTime.';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$title sort aujourd\'hui';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return 'Un film de votre bibliothèque sortira le $localDate.';
  }

  @override
  String get curatedNeoNoirNights => 'Nuits néo-noires';

  @override
  String get curatedPulsePoundingRush => 'Une montée d\'adrénaline palpitante';

  @override
  String get curatedFeelGoodEscape => 'Évasion bien-être';

  @override
  String get curatedMindBenders => 'Des casse-têtes';

  @override
  String get curatedEpicWorlds => 'Mondes épiques';

  @override
  String get curatedHumanStories => 'Histoires humaines';

  @override
  String get curatedDarkDetectiveFiles => 'Dossiers sombres du détective';

  @override
  String get curatedNeoNoirNightsDescription =>
      'Tension palpable sous la pluie, personnages principaux à la moralité ambiguë et récits urbains empreints d\'atmosphère.';

  @override
  String get curatedPulsePoundingRushDescription =>
      'Poursuites à haut risque, danger croissant et rythme effréné.';

  @override
  String get curatedFeelGoodEscapeDescription =>
      'Des histoires touchantes, des intrigues inspirantes et des choix réconfortants pour une soirée de détente.';

  @override
  String get curatedMindBendersDescription =>
      'Des concepts qui déforment la réalité, une intrigue complexe et des récits aux grandes idées.';

  @override
  String get curatedEpicWorldsDescription =>
      'Aventures à grande échelle, enjeux mythiques et dimension cinématographique.';

  @override
  String get curatedHumanStoriesDescription =>
      'Des drames centrés sur les personnages, porteurs d\'émotion et portés par des performances mémorables.';

  @override
  String get curatedDarkDetectiveFilesDescription =>
      'Indices froids, suspects complexes et enquêtes à progression lente.';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get appLanguageSystemDefault => 'Valeurs par défaut du système';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return 'La langue de l\'application est définie sur $language. Cela modifie uniquement l\'interface de l\'application, et non la langue des films et des séries.';
  }

  @override
  String get appLanguageSystemSubtitle =>
      'La langue de l\'application dépend des paramètres de votre appareil. Modifiez-la pour que l\'interface soit dans une autre langue.';

  @override
  String get contentLanguageAllSubtitle =>
      'Toutes les langues. Les onglets Films et Séries restent généraux, tandis que l\'onglet Explorer peut toujours privilégier des correspondances locales plus précises lorsqu\'elles sont disponibles.';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return 'Actuellement configuré sur $language. Les onglets Films et TV resteront stricts, tandis que l\'onglet Explorer privilégiera cette langue.';
  }
}
