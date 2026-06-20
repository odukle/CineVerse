// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Lumi';

  @override
  String get navExplore => 'Entdecken';

  @override
  String get navMovies => 'Filme';

  @override
  String get navTvShows => 'Fernsehsendungen';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navAccount => 'Konto';

  @override
  String get searchHint => 'Filme, Fernsehsendungen, Unternehmen suchen...';

  @override
  String get searchForPerson => 'Nach einer Person suchen...';

  @override
  String get searchLanguages => 'Sprachen suchen';

  @override
  String get searchNameOrRole => 'Namen oder Rolle suchen...';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get clear => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get share => 'Teilen';

  @override
  String get undo => 'Rückgängig machen';

  @override
  String get close => 'Schließen';

  @override
  String get apply => 'Übernehmen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get done => 'Fertig';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get signInWithApple => 'Mit Apple anmelden';

  @override
  String get signOut => 'Abmelden';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get accountDeletedSuccessfully => 'Konto erfolgreich gelöscht.';

  @override
  String get appearance => 'Aussehen';

  @override
  String get appearanceSubtitle =>
      'Wählen Sie Ihr Thema und passen Sie das Aussehen der App an.';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get releaseCalendar => 'Veröffentlichungskalender';

  @override
  String get hiddenTitles => 'Versteckte Titel';

  @override
  String get aiRecommendationsPrivacy => 'AI-Empfehlungen Datenschutz';

  @override
  String get contentRegion => 'Inhaltsbereich';

  @override
  String get contentLanguage => 'Inhaltssprache';

  @override
  String get watchlist => 'Beobachtungsliste';

  @override
  String get notes => 'Notizen';

  @override
  String get deleteNote => 'Notiz löschen';

  @override
  String get addNoteHint => 'Notiz hinzufügen...';

  @override
  String get addBriefNoteHint =>
      'Fügen Sie eine kurze Notiz hinzu (optional) ...';

  @override
  String get enterNewName => 'Geben Sie einen neuen Namen ein ...';

  @override
  String get importSharedList => 'Geteilte Liste importieren';

  @override
  String get discoverOnLumi => 'ENTDECKEN SIE AUF LUMI';

  @override
  String get filtered => 'Gefiltert';

  @override
  String get fullPlot => 'Vollständiger Plot';

  @override
  String get userReviews => 'Benutzerbewertungen';

  @override
  String get noReviewsYet => 'Noch keine Bewertungen.';

  @override
  String get openInYouTube => 'In YouTube öffnen';

  @override
  String get hiddenGems => 'Versteckte Juwelen';

  @override
  String get resetSpotlight => 'Spotlight zurücksetzen';

  @override
  String get clearPreferences => 'Einstellungen löschen';

  @override
  String get refreshPicks => 'Auswahl aktualisieren';

  @override
  String get shareBoard => 'Board teilen';

  @override
  String get exploreDetails => 'Details erkunden';

  @override
  String get searchWikiquotes => 'Wikiquotes durchsuchen';

  @override
  String get selectAQuote => 'Zitat auswählen';

  @override
  String get tooltipShareQuote => 'Zitat teilen';

  @override
  String get tooltipCopyQuote => 'Zitat kopieren';

  @override
  String get tooltipShareDialogue => 'Dialog teilen';

  @override
  String get tooltipCopyDialogue => 'Dialog kopieren';

  @override
  String get tooltipUnhide => 'Einblenden';

  @override
  String get tooltipOpenPrivacyPolicy => 'Datenschutzrichtlinie öffnen';

  @override
  String get tooltipRefreshInsights => 'Einblicke aktualisieren';

  @override
  String get tooltipSortTitles => 'Titel sortieren';

  @override
  String get tooltipSearch => 'Suchen';

  @override
  String get tooltipFilters => 'Filter';

  @override
  String get tooltipSaveToGallery => 'In Galerie speichern';

  @override
  String get tooltipShare => 'Teilen';

  @override
  String get tooltipShareAnalytics => 'Analysen teilen';

  @override
  String get tooltipSetAiringReminder => 'Ausstrahlungserinnerung festlegen';

  @override
  String get tooltipLibrarySynced => 'Bibliothek mit Cloud synchronisiert';

  @override
  String get noMoreEntries => 'Keine weiteren Einträge';

  @override
  String get noItemsFound => 'Keine Artikel gefunden';

  @override
  String errorLoadingGenres(String error) {
    return 'Fehler beim Laden von Genres: $error';
  }

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get errorLoadingLists => 'Fehler beim Laden von Listen';

  @override
  String errorLoadingQuotes(Object error) {
    return 'Zitate konnten nicht geladen werden: $error';
  }

  @override
  String get errorCouldNotShareAnalytics =>
      'Die Analysekarte konnte nicht geteilt werden.';

  @override
  String get errorCouldNotShareRecommendations =>
      'Empfehlungsboard konnte nicht geteilt werden.';

  @override
  String get errorCouldNotShareInsights =>
      'Beobachtungs-Einblicke konnten nicht geteilt werden.';

  @override
  String get watchInsightsNotReady => 'Watch Insights sind noch nicht fertig.';

  @override
  String titleRestoredToSpotlight(String title) {
    return '„$title“ im Spotlight wiederhergestellt';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '„$title“ wurde ausgeblendet';
  }

  @override
  String hiddenDate(String date) {
    return 'Ausgeblendet: $date';
  }

  @override
  String get moviesInThisCollection => 'Filme in dieser Sammlung';

  @override
  String get searchPlanReady => 'Suchplan ist fertig';

  @override
  String get hoursBeforeAirTime => 'Stunden vor Sendezeit';

  @override
  String get noUpcomingReleases => 'Keine bevorstehenden Veröffentlichungen';

  @override
  String get noRemindersSet => 'Keine Erinnerungen festgelegt';

  @override
  String get noHiddenTitles => 'Keine ausgeblendeten Titel';

  @override
  String get hiddenTitlesDescription =>
      'Titel, die Sie im Spotlight-Bereich ausblenden, werden hier angezeigt und können jederzeit wiederhergestellt werden.';

  @override
  String get tvShow => 'Fernsehsendung';

  @override
  String get movie => 'FILM';

  @override
  String get aiConsentGranted =>
      'Sie haben sich angemeldet. Ihre Bibliotheksdaten werden zur Personalisierung von Empfehlungen verwendet.';

  @override
  String get aiConsentNotGranted =>
      'Ihre Bibliotheksdaten werden niemals weitergegeben, es sei denn, Sie stimmen zu.';

  @override
  String get languageSettingExplanation =>
      'Filme und TV-Tabs verwenden dies strikt. Explore bevorzugt es zuerst und greift zurück, wenn eine Schiene spärlich wird.';

  @override
  String get filterScreenTitle => 'Filter';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get genres => 'Übersetze diese App-Bezeichnung ins Deutsche: Genres';

  @override
  String get year => 'Jahr';

  @override
  String get rating => 'Bewertung';

  @override
  String get runtime => 'Laufzeit';

  @override
  String get withPeople => 'Mit Personen';

  @override
  String get voteCount => 'Stimmenzahl';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get yesterday => 'Gestern';

  @override
  String get minutes =>
      'Übersetzen Sie diese App-Bezeichnung ins Deutsche: Min.';

  @override
  String get hours => 'H';

  @override
  String get cast => 'Besetzung';

  @override
  String get crew => 'Übersetzen Sie diese App-Bezeichnung ins Deutsche: Crew';

  @override
  String get director => 'F@ Besetzung @G@ Crew @H@ Regisseur';

  @override
  String get seasons => 'Staffeln';

  @override
  String get episodes => 'Episoden';

  @override
  String get overview => 'Übersicht';

  @override
  String get similar => 'Ähnliche';

  @override
  String get recommendations => 'Empfehlungen';

  @override
  String get addedToWatchlist => 'Zur Beobachtungsliste hinzugefügt';

  @override
  String get removedFromWatchlist => 'Aus der Beobachtungsliste entfernt';

  @override
  String get popularity => 'Beliebtheit';

  @override
  String get releaseDate => 'Erscheinungsdatum';

  @override
  String get revenueLabel => 'Umsatz';

  @override
  String get originalTitle => 'Originaltitel';

  @override
  String get voteAverage => 'Durchschnittliche Abstimmung';

  @override
  String get favourites => 'Favoriten';

  @override
  String get lists => 'Listen';

  @override
  String get watched => 'Angesehen';

  @override
  String get all => 'Alle';

  @override
  String get tv => 'Fernseher';

  @override
  String get librarySubtitle =>
      'Halten Sie alles übersichtlich nach Sammlung, Favoriten, Notizen und Uhrenverlauf organisiert.';

  @override
  String get selectRegion => 'Region auswählen';

  @override
  String get selectRegionDescription =>
      'Nur TMDb-Endpunkte, die regionsbezogene Abfragen unterstützen, verwenden diese Auswahl.';

  @override
  String get useAutoDetectedRegion => 'Automatisch erkannte Region verwenden';

  @override
  String get reminderRemoved => 'Erinnerung entfernt';

  @override
  String releaseReminderSet(String title) {
    return 'Release-Erinnerung für $title eingerichtet.';
  }

  @override
  String episodeReminderSet(String title) {
    return 'Episodenerinnerung für $title eingestellt.';
  }

  @override
  String get filteredResults => 'Gefilterte Ergebnisse';

  @override
  String get genreResults => 'Genre-Ergebnisse';

  @override
  String couldNotLoadContent(String error) {
    return 'Inhalt konnte nicht geladen werden. $error';
  }

  @override
  String get noContentAvailableForThisSelection =>
      'Für diese Auswahl sind keine Inhalte verfügbar.';

  @override
  String get writer => 'Schriftsteller';

  @override
  String get actors => 'Schauspieler';

  @override
  String get noteNotFound => 'Notiz nicht gefunden.';

  @override
  String yourNotesCount(int count) {
    return 'Ihre Notizen ($count)';
  }

  @override
  String get noteDeleted => 'Notiz gelöscht';

  @override
  String noteDeletedWithCount(int count) {
    return 'Notiz gelöscht ($count s)';
  }

  @override
  String get loadMore => 'Mehr laden';

  @override
  String get noMoreProductionsFound =>
      'Es wurden keine weiteren Produktionen gefunden.';

  @override
  String get noProductionsFound => 'Keine Produktionen gefunden.';

  @override
  String get watchInsights => 'Einblicke in die Videoanalyse';

  @override
  String get analyzingWatchHistory => 'Analyse Ihrer Wiedergabehistorie...';

  @override
  String get manageHiddenTitlesDescription =>
      'Verwalten Sie die Titel, die Sie im Spotlight-Bereich ausgeblendet haben.';

  @override
  String get tmdbLanguageMetadataNote =>
      'Einige Rails sehen in diesem Modus möglicherweise spärlich aus, weil die TMDB-Sprachmetadaten für Teile des Katalogs unvollständig sind, nicht unbedingt, weil diese Titel nicht existieren.';

  @override
  String get tmdbDisclaimer =>
      'Dieses Produkt nutzt die TMDB-API, wird aber von TMDB weder unterstützt noch zertifiziert.';

  @override
  String get useLocalLibraryForSync =>
      'Lokale Bibliothek für die Synchronisierung verwenden?';

  @override
  String get themePresets => 'Designvoreinstellungen';

  @override
  String get exitApp => 'App beenden';

  @override
  String get popular => 'Beliebt';

  @override
  String couldNotLoadReminders(String error) {
    return 'Erinnerungen konnten nicht geladen werden.\n\n$error';
  }

  @override
  String get noRemindersSetYet =>
      'Noch keine Erinnerungen eingerichtet.\nErstelle eine im Episoden-Tracker oder in den Filmdetails.';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return 'Diese App-Bezeichnung ins Deutsche übersetzen: Episode S$seasonNumber • E$episodeNumber';
  }

  @override
  String get movieRelease => 'Filmveröffentlichung';

  @override
  String voteAverageStars(String voteAverage) {
    return 'Übersetzen Sie dieses App-Label ins Deutsche: $voteAverage ★';
  }

  @override
  String get addMoreTrackedContent =>
      'Füge weitere Filme oder Serien zu deiner Merkliste, deinen Favoriten oder Listen hinzu.';

  @override
  String get fastPicksDescription =>
      'Schnelle Empfehlungen basierend auf Ihren bisherigen Ersparnissen.';

  @override
  String get releaseCalendarDescription =>
      'Kinostarts und nächste TV-Episoden mit Erinnerungen per Fingertipp.';

  @override
  String get staleWatchlist => 'Veraltete Watchlist';

  @override
  String get tracked => 'Verfolgt';

  @override
  String get upcoming => 'Demnächst';

  @override
  String get upcomingEmptyDescription =>
      'Wenn Filme, die von der Beobachtungsliste erfasst werden, einen Veröffentlichungstermin erhalten oder neue Folgen von Serien geplant sind, werden diese hier angezeigt.';

  @override
  String get howManyMoviesWatchedEachMonth =>
      'Wie viele Filme Sie pro Monat gesehen haben';

  @override
  String get howPersonalRatingsShifting =>
      'Wie sich Ihre persönlichen Bewertungen im Laufe der Zeit verändern';

  @override
  String get keepWatchingToBuildProfile =>
      'Bleiben Sie dran, um Ihr visuelles Profil aufzubauen.';

  @override
  String get lumiWatchAnalytics => 'LUMI UHRENANALYSE';

  @override
  String get noGenreDistributionYet => 'Noch keine Genre-Einteilung verfügbar.';

  @override
  String get noMovieWatchHistoryRecentMonths =>
      'In den letzten Monaten wurden keine Filme angesehen.';

  @override
  String get noRatingTrendDataYet =>
      'Es liegen noch keine Daten zur Bewertungsentwicklung vor.';

  @override
  String get preferredRuntime => 'Bevorzugte Laufzeit';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return 'Die bevorzugte Laufzeit beträgt ca. $minutes Minuten ($label).';
  }

  @override
  String get styledCardWithWatchStats => 'Stilvolle Karte mit Ihren Uhrendaten';

  @override
  String get titlesAnalyzed => 'Analysierte Titel';

  @override
  String get tryAgainAfterMoment =>
      'Versuchen Sie es nach einem Moment erneut.';

  @override
  String get watchAnalytics =>
      'Diese App-Bezeichnung ins Deutsche übersetzen: Watch Analytics';

  @override
  String get whatGenresDominateHistory =>
      'Welche Genres dominieren Ihre Uhrenhistorie?';

  @override
  String get toggleMovies => 'Filme';

  @override
  String get toggleTv => 'Fernseher';

  @override
  String get noMoreTitlesFound => 'Keine weiteren Titel gefunden.';

  @override
  String get noTitlesFoundForKeyword =>
      'Für dieses Stichwort wurden keine Titel gefunden.';

  @override
  String get viewFull => 'Vollständige Ansicht';

  @override
  String get accoladeDetails => 'Details zur Auszeichnung';

  @override
  String get noDetailedAwardsInfo =>
      'Es liegen keine detaillierten Informationen zu den Auszeichnungen vor.';

  @override
  String get alertSet => 'Alarm eingestellt!';

  @override
  String get budget =>
      'Übersetzen Sie diese App-Bezeichnung ins Deutsche: Budget';

  @override
  String get buy => 'Kaufen';

  @override
  String chooseBetweenHours(int maxHours) {
    return 'Wählen Sie zwischen 1 und $maxHours';
  }

  @override
  String get deleteNoteConfirmationTitle => 'Notiz löschen?';

  @override
  String get episodeReminder => 'Episoden-Erinnerung';

  @override
  String get facebook => 'Facebook';

  @override
  String get free => 'Frei';

  @override
  String get images => 'Bilder';

  @override
  String get instagram => 'Instagram';

  @override
  String get netProfit => 'Reingewinn';

  @override
  String get noNotesYet => 'Noch keine Anmerkungen. Teilen Sie Ihre Gedanken!';

  @override
  String get originalLanguage => 'Originalsprache';

  @override
  String partOfCollection(String collectionName) {
    return 'Teil des $collectionName';
  }

  @override
  String get roi => 'ROI';

  @override
  String releaseAlertSet(String date) {
    return 'Release-Warnung für $date eingerichtet.';
  }

  @override
  String get rent => 'Mieten';

  @override
  String get revenue => 'Einnahmen';

  @override
  String seeAllReviews(int count) {
    return 'Alle anzeigen ($count)';
  }

  @override
  String get setReminder => 'Erinnerung einstellen';

  @override
  String get status => 'Diese App-Bezeichnung ins Deutsche übersetzen: Status';

  @override
  String get stream => 'Strom';

  @override
  String get tikTok => 'TikTok';

  @override
  String get twitterX => 'X';

  @override
  String get yours => 'DEIN';

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
    return 'Übersetzen Sie dieses App-Label ins Deutsche: ★ $score%';
  }

  @override
  String get we => 'Wir';

  @override
  String get aspect16x9 =>
      'Diese App-Bezeichnung ins Deutsche übersetzen: 16:9';

  @override
  String get aspect9x16 =>
      'Diese App-Bezeichnung ins Deutsche übersetzen: 9:16';

  @override
  String get background =>
      'Übersetzen Sie diese App-Bezeichnung ins Deutsche: Bg';

  @override
  String episodeCount(int count) {
    return 'Übersetzen Sie dieses App-Label ins Deutsche: $count Eps';
  }

  @override
  String get noEpisodesForSeason =>
      'Für diese Staffel wurden keine Folgen gefunden.';

  @override
  String get beautifulStyledCardForStories =>
      'Wunderschön gestaltete Karte für Social Stories';

  @override
  String get clickableShareLink =>
      'Klickbarer Teilen-Link für WhatsApp und andere Apps';

  @override
  String get placeQuoteOnBackdrop =>
      'Platziere dein Lieblingszitat auf einer Filmkulisse.';

  @override
  String get standardLinkToMovieDatabase => 'Standardlink zur Filmdatenbank';

  @override
  String get exploreLabel => 'Erkunden';

  @override
  String quoteCharacter(String character) {
    return 'Übersetzen Sie diese App-Bezeichnung ins Deutsche: — $character';
  }

  @override
  String get aiTonightWatch =>
      'Übersetzen Sie diese App-Bezeichnung ins Deutsche: AI Tonight Watch';

  @override
  String get aiQueryPlan => 'KI-Abfrageplan';

  @override
  String get airingToday => 'Heute im Fernsehen';

  @override
  String get bigCrowdPleasers => 'Große Publikumslieblinge mit starker Dynamik';

  @override
  String get cinematic => 'Filmisch';

  @override
  String get comingSoon => 'Demnächst verfügbar';

  @override
  String get currentTheatricalSlate =>
      'Aktuelles Kinoprogramm und Kinostarts in naher Zukunft';

  @override
  String get dark => 'Dunkel';

  @override
  String get discoverSpotlight => 'Entdecken Sie Spotlight';

  @override
  String get edgeOfYourSeat => 'Spannung pur';

  @override
  String get fastPaced => 'Schnelllebig';

  @override
  String get feelGood => 'Wohlfühlen';

  @override
  String get freshPicksContinuous => 'Laufend aktualisierte Empfehlungen';

  @override
  String get hideTitle => 'Titel ausblenden';

  @override
  String get highRatedSkipped =>
      'Hoch bewertete Titel, die die meisten Zuschauer überspringen';

  @override
  String get hotNowAudience => 'Aktuell heiß begehrt im Zuschauerfeed';

  @override
  String get inTheaters => 'Im Kino';

  @override
  String get indie => 'Diese App-Bezeichnung ins Deutsche übersetzen: Indie';

  @override
  String get mindBending => 'Umwerfend';

  @override
  String get mostDiscussedShowsThisWeek =>
      'Die meistdiskutierten Sendungen dieser Woche';

  @override
  String get multiplePicks => 'Mehrere Tipps';

  @override
  String get onTheAir => 'Live auf Sendung';

  @override
  String get personalizedFromWatchBehavior =>
      'Personalisiert anhand Ihres Uhrenverhaltens';

  @override
  String get pickAVibe =>
      'Wähle eine Stimmung und erhalte sofort passende Titel';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get seriesCurrentlyAiring =>
      'Serien, die aktuell mit laufenden Folgen ausgestrahlt werden';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get topRated => 'Top-Bewertung';

  @override
  String get voiceInput => 'Spracheingabe';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% Übereinstimmung';
  }

  @override
  String runtimeMinutes(String minutes) {
    return 'Übersetzen Sie diese App-Bezeichnung ins Deutsche: $minutes min';
  }

  @override
  String get examplePrompt =>
      'Beispiel: Etwas wie Interstellar, aber kein Science-Fiction-Film.';

  @override
  String findingYourPerfectWatch(String dots) {
    return 'Finden Sie Ihre perfekte Uhr$dots';
  }

  @override
  String get moreLikeThis => 'Ähnliche Artikel';

  @override
  String get notForMe => 'Nichts für mich';

  @override
  String get recentQueries => 'Aktuelle Suchanfragen';

  @override
  String get shufflingIdeas => 'Ideen neu mischen...';

  @override
  String get tooMainstream => 'Zu kommerziell';

  @override
  String get whatShouldIWatchTonight => 'Was soll ich heute Abend schauen?';

  @override
  String debugLogEntry(String time, String message) {
    return 'Übersetzen Sie diese App-Bezeichnung ins Deutsche: [$time] $message';
  }

  @override
  String get from => 'Aus';

  @override
  String get to => 'Zu';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return 'Von der Beobachtungsliste entfernt ($seconds s)';
  }

  @override
  String creditsCount(String count) {
    return 'Übersetzen Sie dieses App-Label ins Deutsche: $count Credits';
  }

  @override
  String get acrossFilmography => 'Filmografie';

  @override
  String get birthplace => 'Geburtsort';

  @override
  String get born => 'Geboren';

  @override
  String get credits => 'Übersetze diese App-Bezeichnung ins Deutsche: Credits';

  @override
  String get died => 'Gestorben';

  @override
  String get knownFor => 'Bekannt für';

  @override
  String get noSharedTitlesAvailable => 'Keine gemeinsamen Titel verfügbar.';

  @override
  String get photos => 'Fotos';

  @override
  String get personRating => 'Bewertung';

  @override
  String get taggedImages => 'Markierte Bilder';

  @override
  String get website => 'Webseite';

  @override
  String get noQuotesFound => 'Keine Zitate gefunden.';

  @override
  String get noSectionsFound => 'Keine Abschnitte gefunden.';

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get noCollectionsFound => 'Keine Sammlungen gefunden';

  @override
  String get noCompaniesFound => 'Keine Unternehmen gefunden';

  @override
  String get noKeywordsFound => 'Keine Schlüsselwörter gefunden';

  @override
  String get noMoreResultsFound =>
      'Es wurden keine weiteren Ergebnisse gefunden.';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String deleteListConfirmation(String listName) {
    return 'Möchten Sie $listName wirklich löschen?';
  }

  @override
  String get deleteListTitle => 'Liste löschen?';

  @override
  String get everythingYouPlanToWatch =>
      'Alles, was Sie als Nächstes ansehen möchten.';

  @override
  String get finishedTitlesAndHistory =>
      'Abgeschlossene Titel sowie Ihre Historie und Statistiken.';

  @override
  String get noListsCreatedYet => 'Es wurden noch keine Listen erstellt.';

  @override
  String get noNotesFound => 'Keine Notizen gefunden';

  @override
  String get renameList => 'Umbenennungsliste';

  @override
  String get titlesYouNeverWantToLose =>
      'Die Titel, die man niemals verlieren möchte.';

  @override
  String get yourThoughtsReactions =>
      'Ihre Gedanken, Reaktionen und Erinnerungen.';

  @override
  String imageCounter(String current, String total) {
    return 'Übersetzen Sie diese App-Bezeichnung ins Deutsche: $current / $total';
  }

  @override
  String get removeFromWatchedConfirmation =>
      'Möchten Sie diesen Artikel wirklich aus Ihrer Beobachtungsliste entfernen?';

  @override
  String get savedAsWatchedWithoutRating =>
      'Dies wird als angesehen gespeichert, ohne dass eine persönliche Bewertung abgegeben wird.';

  @override
  String get noAdditionalRecommendationTrailers =>
      'Es wurden keine weiteren Empfehlungstrailer gefunden.';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return 'Übersetzen Sie diese App-Bezeichnung ins Deutsche: $count $itemLabel';
  }

  @override
  String get invalidSharedListLink =>
      'Der Link ist möglicherweise ungültig, abgelaufen oder nicht mehr erreichbar.';

  @override
  String get noTitlesAvailableToImport =>
      'Es sind keine Titel zum Importieren verfügbar.';

  @override
  String get allLanguages => 'Alle Sprachen';

  @override
  String get arabic => 'Arabisch';

  @override
  String get bengali => 'Übersetzen Sie diese App-Bezeichnung ins Bengali:';

  @override
  String get chinese => 'chinesisch';

  @override
  String get english => 'Englisch';

  @override
  String get french => 'Französisch';

  @override
  String get german => 'Deutsch';

  @override
  String get gujarati => 'Übersetzen Sie diese App-Bezeichnung ins Gujarati:';

  @override
  String get hindi => 'Übersetzen Sie dieses App-Label ins Hindi: Hindi';

  @override
  String get indonesian => 'Indonesisch';

  @override
  String get italian => 'Italienisch';

  @override
  String get japanese => 'japanisch';

  @override
  String get kannada =>
      'Übersetzen Sie diese App-Bezeichnung ins Kannada: Kannada';

  @override
  String get korean => 'Koreanisch';

  @override
  String get malayalam => 'Übersetzen Sie diese App-Bezeichnung ins Malayalam.';

  @override
  String get marathi =>
      'Übersetzen Sie diese App-Bezeichnung ins Marathi: Marathi';

  @override
  String get persian => 'persisch';

  @override
  String get polish => 'Polieren';

  @override
  String get portuguese => 'Portugiesisch';

  @override
  String get punjabi => 'Übersetzen Sie diese App-Bezeichnung ins Punjabi:';

  @override
  String get russian => 'Russisch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get swedish => 'Schwedisch';

  @override
  String get tamil => 'Übersetzen Sie diese App-Bezeichnung ins Tamilische:';

  @override
  String get telugu =>
      'Übersetzen Sie diese App-Bezeichnung ins Telugu: Telugu';

  @override
  String get thai => 'Übersetzen Sie dieses App-Label ins Thailändische:';

  @override
  String get turkish => 'Türkisch';

  @override
  String get urdu => 'Übersetzen Sie diese App-Bezeichnung ins Urdu: Urdu';

  @override
  String get vietnamese => 'Vietnamesisch';

  @override
  String get failedToLoadCollectionDetails =>
      'Sammlungsdetails konnten nicht geladen werden';

  @override
  String get franchiseProgress => 'Franchise-Fortschritt';

  @override
  String get officialSite => 'Offizielle Website';

  @override
  String get productions => 'Produktionen';

  @override
  String get productionCompany => 'Produktionsfirma';

  @override
  String get failedToLoadCompanyInfo =>
      'Firmeninformationen konnten nicht geladen werden';

  @override
  String get profile => 'Profil';

  @override
  String get guestViewer => 'Gastzuschauer';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      'Ihr Profil, Ihr Synchronisierungsstatus, Ihre Region und Ihre visuellen Einstellungen werden alle hier gespeichert.';

  @override
  String get signInToSync =>
      'Melden Sie sich an, um Ihre Merkliste, Bewertungen und Einstellungen zu synchronisieren.';

  @override
  String get signedInAndSyncing =>
      'Angemeldet und Synchronisierung mit der Cloud wird durchgeführt.';

  @override
  String get developedBy => 'Entwickelt von';

  @override
  String get couldNotAnalyzeWatchHistory =>
      'Die Wiedergabehistorie konnte momentan nicht analysiert werden.';

  @override
  String get includeLocalLibrary => 'Lokale Bibliothek einbeziehen';

  @override
  String get useCloudOnly => 'Nur Cloud verwenden';

  @override
  String get localLibrarySyncDescription =>
      'Dieses Gerät enthält bereits Titel aus Ihrer lokalen Bibliothek. Fügen Sie diese Ihrer angemeldeten Bibliothek hinzu oder ersetzen Sie die lokalen Bibliotheksdaten durch Ihre Cloud-Bibliothek.';

  @override
  String get mergedLocalTitles =>
      'Lokale Titel wurden in Ihre angemeldete Bibliothek integriert.';

  @override
  String get replacedLocalLibrary =>
      'Die lokalen Bibliotheksdaten wurden durch Ihre Cloud-Bibliothek ersetzt.';

  @override
  String get deleteAccountConfirmation =>
      'Dadurch werden Ihr Lumi-Konto und die synchronisierten Cloud-Daten endgültig gelöscht. Lokale Daten auf diesem Gerät bleiben erhalten, sofern Sie die App-Daten nicht separat entfernen.';

  @override
  String get signedOutAndCleared =>
      'Ich habe mich abgemeldet und die lokale Bibliothek auf diesem Gerät gelöscht.';

  @override
  String get keepLocalLibrary => 'Lokale Bibliotheken unterstützen';

  @override
  String get clearLocalLibrary => 'Lokale Bibliothek freihalten';

  @override
  String get signOutChoiceDescription =>
      'Wählen Sie aus, ob die lokale Bibliothek nach dem Abmelden auf diesem Gerät erhalten bleiben soll.';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get aiRecommendationsEnabled =>
      'Datenaustausch für KI-Empfehlungen aktiviert.';

  @override
  String get aiRecommendationsDisabled =>
      'Die Weitergabe von KI-Empfehlungsdaten ist deaktiviert.';

  @override
  String get reviewAndManageConsent =>
      'Überprüfung und Verwaltung der Einwilligung zur Übermittlung von Bibliotheksdaten an KI-Anbieter.';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      'Aktiviert. Recommend Tonight sendet möglicherweise Ihre Bibliotheksübersicht und Ihre letzten Suchanfragen an KI-Anbieter.';

  @override
  String basedOnWatchedTitles(String count) {
    return 'Basierend auf $count angesehenen Titeln';
  }

  @override
  String lastUpdated(String date) {
    return 'Letzte Aktualisierung: $date';
  }

  @override
  String get chooseYourVibe => 'Wähle deine Stimmung';

  @override
  String get appearanceDescription =>
      'Wechseln Sie in der App zwischen verschiedenen filmischen Persönlichkeiten, ohne dabei das Verhalten zu ändern.';

  @override
  String get exitAppConfirmation => 'Möchten Sie Lumi wirklich verlassen?';

  @override
  String get dismiss => 'Zurückweisen';

  @override
  String get generatingWatchAnalytics => 'Generierung von Watch-Analysen';

  @override
  String get thisUsuallyTakesAFewSeconds =>
      'Das dauert normalerweise ein paar Sekunden.';

  @override
  String get yourScreenStory => 'Deine Bildschirmgeschichte';

  @override
  String get snapshotOfHowAndWhatYouWatch =>
      'Ein Überblick darüber, wie und was Sie sehen';

  @override
  String get yourFavoriteGenres => 'Ihre Lieblingsgenres';

  @override
  String get genrePerformanceHighestRated =>
      'Genre-Performance (Höchstbewertung)';

  @override
  String get personalizedViewingPatterns =>
      'Personalisierte Betrachtungsmuster';

  @override
  String get builtWithLumi => 'Hergestellt mit Lumi';

  @override
  String get sharedWithLumi => 'Geteilt mit Lumi';

  @override
  String get shareAnalytics =>
      'Diese App-Bezeichnung ins Deutsche übersetzen: Share Analytics';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return 'Analysierte $count-Titel • Aktualisierte $date-Titel';
  }

  @override
  String get allSeasons => 'Alle Jahreszeiten';

  @override
  String get castAndCrew => 'Besetzung und Crew';

  @override
  String get featuredCrew => 'Vorgestelltes Team';

  @override
  String get stills =>
      'Übersetzen Sie diese App-Bezeichnung ins Deutsche: Stills';

  @override
  String get accoladeSummary => 'Zusammenfassung der Auszeichnungen';

  @override
  String get awardsAndAccolades => 'Auszeichnungen und Ehrungen';

  @override
  String get unableToLoadMovieDetails =>
      'Filmdetails konnten nicht geladen werden';

  @override
  String get overviewUnavailable =>
      'Eine Übersicht zu diesem Titel ist nicht verfügbar.';

  @override
  String get openCompletePlot =>
      'Öffnen Sie die vollständige Handlung und zusätzliche Metadaten von OMDb.';

  @override
  String get noOverviewForSeason =>
      'Für diese Saison ist keine Übersicht verfügbar.';

  @override
  String get userScore => 'Nutzerbewertung';

  @override
  String get playTrailer => 'Trailer abspielen';

  @override
  String get whereToWatch => 'Wo man es sehen kann';

  @override
  String get availabilityDataByJustWatch =>
      'Verfügbarkeitsdaten von JustWatch.';

  @override
  String get reminderSaved => 'Erinnerung gespeichert';

  @override
  String reminderForTitle(String title) {
    return 'Erinnerung für $title';
  }

  @override
  String get pleaseSelectFutureTime =>
      'Bitte wählen Sie einen zukünftigen Zeitpunkt.';

  @override
  String get notifyAt => 'Benachrichtigen Sie bei';

  @override
  String get notifyHoursBeforeAiring =>
      'Wie viele Stunden vor der Ausstrahlung soll benachrichtigt werden?';

  @override
  String enterNumberBetween(String maxHours) {
    return 'Geben Sie eine Zahl zwischen 1 und $maxHours ein.';
  }

  @override
  String get set => 'Satz';

  @override
  String get selectedReminderTimePassed =>
      'Die gewählte Erinnerungszeit ist bereits verstrichen.';

  @override
  String episodeReminderSaved(String date) {
    return 'Episodenerinnerung für $date gespeichert';
  }

  @override
  String get areYouSureDeleteNote =>
      'Möchten Sie diese Notiz wirklich löschen?';

  @override
  String get noteAdded => 'Hinweis hinzugefügt';

  @override
  String get lastSeason => 'Letzte Saison';

  @override
  String get currentSeason => 'Aktuelle Saison';

  @override
  String get viewAllSeasons => 'Alle Jahreszeiten anzeigen';

  @override
  String get removedFromFavourites => 'Aus Favoriten entfernt';

  @override
  String get addedToFavourites => 'Zu Favoriten hinzugefügt';

  @override
  String get awardsAndNominations => 'Auszeichnungen & Nominierungen';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get boxOfficeFinancials => 'Kassenfinanzen';

  @override
  String get successMeter => 'Erfolgsmesser';

  @override
  String get blockbuster =>
      'Übersetze dieses App-Label ins Deutsche: BLOCKBUSTER';

  @override
  String get hit => 'SCHLAG';

  @override
  String get breakEven => 'DIE GEWINNZONE ERREICHEN';

  @override
  String get underperformer => 'SCHLECHTE LEISTUNG';

  @override
  String get boxOfficeBomb => 'KINO-Flop';

  @override
  String get episodeTracker => 'Episodenübersicht';

  @override
  String get setAiringReminder => 'Sendeerinnerung einstellen';

  @override
  String get nextEpisodeCountdown => 'Countdown zur nächsten Folge';

  @override
  String get nextEpisode => 'Nächste Folge';

  @override
  String get lastEpisodeToAir => 'Letzte Folge wird ausgestrahlt';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get contentAdvisory => 'Inhaltswarnung';

  @override
  String get violence => 'Gewalt';

  @override
  String get sexAndNudity => 'Sex und Nacktheit';

  @override
  String get foulLanguage => 'Sprache';

  @override
  String get substances => 'Substanzen';

  @override
  String get fearAndHorror => 'Angst und Horror';

  @override
  String get familyFriendly => 'Familienfreundlich';

  @override
  String get generalAudience => 'Allgemeines Publikum';

  @override
  String get releaseTimeline => 'Veröffentlichungszeitplan';

  @override
  String get notifyMe => 'Benachrichtige mich';

  @override
  String get theatricalRelease => 'Kinostart';

  @override
  String get digitalStreaming =>
      'Diese App-Bezeichnung ins Deutsche übersetzen: Digital / Streaming';

  @override
  String get physicalRelease => 'Physisch (Blu-ray / DVD)';

  @override
  String get awesome => 'Eindrucksvoll';

  @override
  String get keywordsAndThemes => 'Schlüsselwörter & Themen';

  @override
  String get videosAndBehindTheScenes => 'Videos & Blicke hinter die Kulissen';

  @override
  String get productionStudios => 'Produktionsstudios';

  @override
  String get fetchingWatchLink => 'Link zur Uhr wird abgerufen';

  @override
  String get findingBestProviderPage =>
      'Die beste Anbieterseite für diesen Titel finden.';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode';
  }

  @override
  String get error => 'Fehler';

  @override
  String get failedToLoadSeasonDetails =>
      'Saisondetails konnten nicht geladen werden';

  @override
  String get loading => 'Laden...';

  @override
  String runtimeSeparator(String runtime) {
    return 'Übersetzen Sie diese App-Bezeichnung ins Deutsche: • $runtime';
  }

  @override
  String get fullCastAndCrew => 'Vollständige Besetzung und Crew';

  @override
  String get shareMovie => 'Film teilen';

  @override
  String get quotes => 'Zitate';

  @override
  String get mayIncludeMismatches =>
      'Kann aufgrund der lexikalischen Zitatsuche gelegentlich zu Abweichungen führen.';

  @override
  String get movieApiConfigurationRequired =>
      'Movie API-Konfiguration erforderlich';

  @override
  String get addMovieProxyBaseUrl =>
      'Fügen Sie MOVIE_PROXY_BASE_URL hinzu, um die App mit dem TMDB-Proxy zu verbinden.';

  @override
  String get cinematicPicksContext =>
      'Filmreife Filme mit sofort stimmungsvollem Kontext. Würfeln Sie für eine weitere Überraschungskarte.';

  @override
  String get curatedTonight => 'Heute Abend kuratiert';

  @override
  String curatedTonightTitle(String title) {
    return 'Heute Abend kuratiert: $title';
  }

  @override
  String get describeItYourWay =>
      'Beschreiben Sie es so, wie Sie es möchten. Wir finden die besten Ergebnisse.';

  @override
  String get hide => 'Verstecken';

  @override
  String get hideTitleDescription =>
      'Wenn Sie diesen Titel ausblenden, wird er zukünftig nicht mehr im Spotlight-Bereich angezeigt.';

  @override
  String get dontAskAgain => 'Frag nicht noch einmal';

  @override
  String get imdbNa => 'Diese App-Bezeichnung ins Deutsche übersetzen: IMDb NA';

  @override
  String get noDiscoverPicks => 'Derzeit sind keine Empfehlungen verfügbar.';

  @override
  String get playPreview => 'Wiedergabevorschau';

  @override
  String get recommendedForYou => 'Für Sie empfohlen';

  @override
  String get spotlightCompleted => 'Spotlight abgeschlossen';

  @override
  String get startAddingTitlesForRecommendations =>
      'Beginnen Sie damit, Titel für Empfehlungen hinzuzufügen.';

  @override
  String get clearedAllChoices =>
      'Du hast alle Optionen in deinem Entdecken-Feed durchgewischt und gelöscht.';

  @override
  String get whatsPopular => 'Was ist beliebt?';

  @override
  String get trending => 'Im Trend';

  @override
  String get nowPlaying => 'Jetzt läuft';

  @override
  String get tvTrending => 'TV-Trends';

  @override
  String get discoverByMood => 'Entdecken Sie nach Stimmung';

  @override
  String get needSomethingToWatchTonight =>
      'Suchst du noch etwas zum Anschauen heute Abend?';

  @override
  String get needAMovieForTonight => 'Brauchst du einen Film für heute Abend?';

  @override
  String get tryAiShows => 'Probieren Sie KI-Shows aus';

  @override
  String get tryAiMovies => 'Probieren Sie AI Movies aus';

  @override
  String get findShows => 'Shows finden';

  @override
  String get findMovies => 'Filme finden';

  @override
  String get couldNotLoadThisRail =>
      'Diese Schiene konnte nicht beladen werden.';

  @override
  String get temporaryIssueLoadingRail =>
      'Es gab ein vorübergehendes Problem beim Verladen dieser Schiene.';

  @override
  String get noTitlesHereYet => 'Hier gibt es noch keine Titel.';

  @override
  String get noHiddenGemsForGenre =>
      'Für dieses Genre wurden noch keine Geheimtipps gefunden. Versuchen Sie es mit einem anderen Genre.';

  @override
  String get tryAnotherFilter =>
      'Probieren Sie einen anderen Filter oder öffnen Sie diesen Abschnitt für eine umfassendere Suche.';

  @override
  String get seeAllFilters => 'Alle Filter anzeigen';

  @override
  String get couldNotLoadCuratedPicks =>
      'Die ausgewählten Empfehlungen konnten nicht geladen werden.';

  @override
  String get temporaryIssueLoadingCurated =>
      'Es gab ein vorübergehendes Problem beim Laden der heutigen kuratierten Liste.';

  @override
  String get noCuratedPicksAvailable =>
      'Keine kuratierten Empfehlungen verfügbar';

  @override
  String get tryAgainWhileRefresh =>
      'Versuchen Sie es in einem Moment noch einmal, während wir die TMDB-Liste für heute Abend aktualisieren.';

  @override
  String get fromSpotlight => 'Aus dem Spotlight';

  @override
  String get addShowsMoviesForRecommendations =>
      'Füge Fernsehsendungen/Filme zu deiner Merkliste, deinen Favoriten oder deiner Liste der bereits gesehenen Filme hinzu, um Titel zu entdecken, die dir gefallen könnten.';

  @override
  String get allow => 'Erlauben';

  @override
  String get notNow => 'Nicht jetzt.';

  @override
  String get allowAiDataSharingTitle => 'KI-Datenaustausch zulassen?';

  @override
  String get allowAiDataSharingDescription =>
      '„Heute Abend empfehlen“ sendet den von Ihnen eingegebenen Text für eine Filmempfehlung sowie temporäre Informationen zur Suchverfeinerung an Google Gemini und OpenRouter. Ihre vollständige Bibliothek und Ihre Anmeldedaten werden nicht an diese KI-Anbieter übermittelt. Sind Sie damit einverstanden, dass diese Daten für KI-Empfehlungen weitergegeben werden?';

  @override
  String get liveProgress => 'Live-Fortschritt';

  @override
  String percentComplete(String percent) {
    return '$percent% abgeschlossen';
  }

  @override
  String get describeIdealShowNight =>
      'Beschreiben Sie Ihren idealen Showabend';

  @override
  String get describeIdealMovieNight => 'Beschreibe deinen idealen Filmabend';

  @override
  String get useNaturalLanguage =>
      'Verwenden Sie natürliche Sprache. Erwähnen Sie, was Sie möchten, was zu vermeiden ist und geben Sie optionale Hinweise zu Sprache/Laufzeitumgebung.';

  @override
  String get listeningTapMicToStop =>
      'Zuhören... Tippen Sie erneut auf das Mikrofon, um zu stoppen.';

  @override
  String voiceInputError(String error) {
    return 'Spracheingabefehler: $error';
  }

  @override
  String get tapMicToDictate =>
      'Tippen Sie auf das Mikrofon, um Ihre Anfrage zu diktieren.';

  @override
  String get tapMicToEnableVoice =>
      'Tippen Sie auf das Mikrofon, um die Spracheingabe zu aktivieren.';

  @override
  String get findingShows => 'Sendungen finden...';

  @override
  String get findingMovies => 'Filme finden...';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return 'Lumi-Tipps für heute Abend: $prompt';
  }

  @override
  String get tonightsPicks => 'Die heutigen Tipps';

  @override
  String get sharedFromLumi => 'Geteilt von Lumi';

  @override
  String get intent => 'Absicht:';

  @override
  String get genreLabel => 'Übersetze dieses App-Label ins Deutsche: Genre:';

  @override
  String get avoid => 'Vermeiden:';

  @override
  String get languageLabel => 'Sprache:';

  @override
  String runtimeAtMost(String minutes) {
    return 'Laufzeit <= $minutes min';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return 'Laufzeit >= $minutes min';
  }

  @override
  String get yearLabel => 'Jahr:';

  @override
  String yearAfter(String year) {
    return 'Nach $year';
  }

  @override
  String yearBefore(String year) {
    return 'Vor $year';
  }

  @override
  String get like => 'Wie:';

  @override
  String get signal =>
      'Übersetzen Sie diese App-Bezeichnung ins Deutsche: Signal:';

  @override
  String get readingWatchedHistory =>
      'Ich lese gerade meinen Wiedergabeverlauf...';

  @override
  String get findingTopGenres => 'Finde deine Lieblingsgenres und -muster...';

  @override
  String get buildingTrends =>
      'Erstellung monatlicher Trendanalysen und Bewertungsstatistiken...';

  @override
  String get writingInsights =>
      'Verfassen Sie Ihre personalisierten Erkenntnisse...';

  @override
  String get applyFilters => 'Filter anwenden';

  @override
  String get includeNotRated => 'Nicht bewertete Inhalte einschließen';

  @override
  String get errorLoadingTvGenres => 'Fehler beim Laden der TV-Genres';

  @override
  String get alsoKnownAs => 'Auch bekannt als';

  @override
  String get biography => 'Biographie';

  @override
  String get careerStatistics => 'Karrierestatistiken';

  @override
  String get frequentlyCollaboratesWith => 'Arbeitet häufig zusammen mit';

  @override
  String get notableQuotes => 'Bemerkenswerte Zitate';

  @override
  String get primaryRole => 'Hauptrolle';

  @override
  String get averageRating => 'Durchschnittliche Bewertung';

  @override
  String get topGenre => 'Top-Genre';

  @override
  String get peakBoxOffice => 'Spitzenkasse';

  @override
  String percentOfTitles(String percent) {
    return '$percent% der Titel';
  }

  @override
  String sharedTitleCount(String count) {
    return '$count gemeinsamer Titel/gemeinsame Titel';
  }

  @override
  String billingOrder(String order) {
    return 'Rechnung Nr. $order';
  }

  @override
  String get startTypingToSearch =>
      'Beginnen Sie mit der Eingabe, um zu suchen';

  @override
  String get movieDiscoveryMadePersonal =>
      'Filmentdeckung, persönlich gestaltet';

  @override
  String get allNotes => 'Alle Notizen';

  @override
  String get viewPersonalizedInsights =>
      'Personalisierte Einblicke, Diagramme und Trends ansehen.';

  @override
  String get curatedCollections => 'Kuratierte Kollektionen';

  @override
  String get list => 'Liste';

  @override
  String get openList => 'Liste öffnen';

  @override
  String get thisListNoLongerExists => 'Diese Liste existiert nicht mehr.';

  @override
  String listRenamed(String name) {
    return 'Liste umbenannt in $name';
  }

  @override
  String listDeleted(String name) {
    return 'Liste $name gelöscht';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return 'Kein Eintrag $filter in Ihrer Watchlist';
  }

  @override
  String noFilterInFavourites(String filter) {
    return 'Kein $filter in Ihren Favoriten';
  }

  @override
  String noFilterInWatched(String filter) {
    return 'Keine $filter in der Liste der überwachten Sendungen';
  }

  @override
  String noFilterInThisList(String filter) {
    return 'Keine $filter in dieser Liste';
  }

  @override
  String noListsWithFilter(String filter) {
    return 'Keine Listen mit $filter';
  }

  @override
  String importedInto(String name) {
    return 'Importiert in \"$name\"';
  }

  @override
  String get couldNotImportList => 'Liste konnte nicht importiert werden';

  @override
  String get importing => 'Importiert...';

  @override
  String get couldNotLoadSharedList =>
      'Diese freigegebene Liste konnte nicht geladen werden.';

  @override
  String get editWatchedInfo => 'Bearbeitete Informationen';

  @override
  String get watchDate => 'Datum ansehen';

  @override
  String get rewatchCount => 'Wiederholungszähler';

  @override
  String get watchedInfoUpdated =>
      'Informationen zum Beobachtungsstatus aktualisiert';

  @override
  String removedFromList(String listName) {
    return 'Aus $listName entfernt';
  }

  @override
  String addedToList(String listName) {
    return 'Hinzugefügt zu $listName';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return 'Hinzugefügt zu $listName und der Watchlist';
  }

  @override
  String get moreTrailersLikeThis => 'Mehr Trailer wie dieser';

  @override
  String get noDescriptionForTrailer =>
      'Für diesen Trailer ist keine Beschreibung verfügbar.';

  @override
  String get closeTrailer => 'Trailer schließen';

  @override
  String get recommendedSeries => 'Empfohlene Serien';

  @override
  String get recommendedMovie => 'Empfohlener Film';

  @override
  String get notEnoughDataYet => 'Noch nicht genügend Daten';

  @override
  String addAndRateMoreTitles(String count) {
    return 'Füge mindestens $count Titel hinzu und bewerte sie, um die Analysefunktionen freizuschalten.';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return 'Du hast $watchedCount/$requiredCount Titel angesehen. Füge $remaining weitere hinzu, um die Analysefunktionen freizuschalten.';
  }

  @override
  String get moviesPerMonth => 'Filme pro Monat';

  @override
  String get genreDistribution => 'Genreverteilung';

  @override
  String get ratingTrends => 'Bewertungstrends';

  @override
  String get noData => 'Keine Daten';

  @override
  String get myLatestWatchAnalytics => 'Meine neuesten Uhrenanalysen zu Lumi';

  @override
  String get myWatchInsights => 'Meine Eindrücke zur Lumi-Uhr';

  @override
  String get infographicsCard => 'Infografikkarte';

  @override
  String get watchInsightsSnapshot => 'Einblick in die Videoanalyse';

  @override
  String get availableOnceInsightsReady =>
      'Verfügbar, sobald die Erkenntnisse vorliegen.';

  @override
  String get shareYourWatchInsights => 'Teilen Sie Ihre Uhren-Einblicke-Karte';

  @override
  String get recentlyWatchedVibe => 'Kürzlich angesehen Vibe';

  @override
  String get mixedAcrossGenres => 'Genreübergreifend';

  @override
  String get moviesPerMonthShort => 'Filme / Monat';

  @override
  String get ratingTrend => 'Bewertungstrend';

  @override
  String get balanced => 'Ausgewogen';

  @override
  String get noWatchNextSuggestionsYet =>
      'Noch keine Vorschläge für das nächste Video';

  @override
  String get upcomingFromLibrary => 'Demnächst aus Ihrer Bibliothek';

  @override
  String get removeReminder => 'Erinnerung entfernen';

  @override
  String get remindMe => 'Erinnere mich';

  @override
  String titleReleasesToday(String title) {
    return '$title erscheint heute.';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle wird demnächst ausgestrahlt.';
  }

  @override
  String get controlPremiereAlerts =>
      'Steuern Sie Premierenbenachrichtigungen und Veröffentlichungserinnerungen.';

  @override
  String upcomingReleasesCount(String count) {
    return '$count kommende Veröffentlichungen in Ihrer Bibliothek.';
  }

  @override
  String sittingInWatchlist(String days) {
    return 'Befindet sich seit $days Tagen auf Ihrer Beobachtungsliste.';
  }

  @override
  String get alreadyOnWatchlist => 'Bereits auf Ihrer Beobachtungsliste';

  @override
  String get favouritedButNotWatched =>
      'Du hast diesen Beitrag als Favorit markiert, aber noch nicht als angesehen.';

  @override
  String get savedInListReady =>
      'In einer Ihrer Listen gespeichert und bereit zum Ansehen';

  @override
  String get matchesTitlesYouTrack =>
      'Entspricht Titeln, die Sie bereits verfolgen';

  @override
  String get noOfficialSite => 'Keine offizielle Website';

  @override
  String get episodeAiring => 'Ausstrahlung der Folge';

  @override
  String get general => 'Allgemein';

  @override
  String scheduledFor(String date) {
    return 'Geplant für $date';
  }

  @override
  String wasScheduledFor(String date) {
    return 'War für $date geplant';
  }

  @override
  String get noOverviewAvailable => 'Keine Übersicht verfügbar.';

  @override
  String get searchHistoryCleared => 'Suchverlauf gelöscht';

  @override
  String get visualMovieCard => 'Visuelle Filmkarte';

  @override
  String get smartLumiLink =>
      'Übersetzen Sie diese App-Bezeichnung ins Deutsche: Smart Lumi Link';

  @override
  String get directTmdbLink => 'Direkter TMDB-Link';

  @override
  String recommendedOnLumi(String title) {
    return 'Empfohlen auf Lumi: $title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return 'Schau dir $title auf Lumi an!\n\n$link\n\nLumi herunterladen: $appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return 'Schauen Sie sich $title auf TMDB an: $link';
  }

  @override
  String releaseAlertTitle(String title) {
    return '$title Freigabealarm';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return 'Veröffentlichungsalarm für $date eingerichtet. Wir benachrichtigen Sie, sobald es veröffentlicht ist.';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return 'Wir benachrichtigen Sie, sobald \"$title\" digital oder auf Blu-ray/DVD erscheint!';
  }

  @override
  String get episodeAlreadyDueToAir =>
      'Diese Folge wird demnächst ausgestrahlt.';

  @override
  String get reminderSetSuccessfully => 'Erinnerung erfolgreich eingestellt';

  @override
  String get speechRecognitionNotAvailable =>
      'Die Spracherkennung ist auf diesem Gerät nicht verfügbar.';

  @override
  String get describeShowMood =>
      'Beschreiben Sie, auf welche Serie Sie gerade Lust haben, und wir senden Ihnen eine Rangliste.';

  @override
  String get describeMovieMood =>
      'Beschreiben Sie, auf welchen Film Sie gerade Lust haben, und wir senden Ihnen eine Rangliste.';

  @override
  String get aiLauncherDescription =>
      'Geben Sie Ihre Anfrage in natürlicher Sprache ein oder sprechen Sie sie. Lumi erstellt einen KI-Plan, führt eine Vektorsuche durch und liefert mehrere Vorschläge für Serien/Filme.';

  @override
  String yearRange(String from, String to) {
    return 'Übersetzen Sie diese App-Bezeichnung ins Deutsche: $from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return '$count Erinnerung(en) geplant.';
  }

  @override
  String regionAutoDetected(String region) {
    return 'Automatisch erkannt: $region';
  }

  @override
  String regionSelected(String region) {
    return 'Ausgewählt: $region';
  }

  @override
  String get allLanguagesSubtitle => 'Alle Sprachen';

  @override
  String currentlySetToLanguage(String language) {
    return 'Aktuell eingestellt auf $language';
  }

  @override
  String get availabilities => 'Verfügbarkeiten';

  @override
  String get mood => 'Stimmung';

  @override
  String get people => 'Menschen';

  @override
  String get ads => 'Anzeigen';

  @override
  String get theatricalLimited => 'Begrenzte Kinofassung';

  @override
  String get premier =>
      'Übersetzen Sie diese App-Bezeichnung ins Deutsche: Premier';

  @override
  String get mediaType => 'Medientyp';

  @override
  String get couldNotLoadAnalytics =>
      'Analysedaten konnten nicht geladen werden.';

  @override
  String get viewAllAwards => 'Alle anzeigen';

  @override
  String get win => 'Gewinnen';

  @override
  String get wins => 'Siege';

  @override
  String get nomination => 'Nominierung';

  @override
  String get nominations => 'Nominierungen';

  @override
  String sharedBy(String name) {
    return 'Geteilt von $name';
  }

  @override
  String titleCount(String count) {
    return '$count Titel(n)';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count gespeicherte Titel in Ihren Listen';
  }

  @override
  String get curatedCollectionsSubtitle =>
      'Kuratierte Sammlungen, die Sie organisieren und teilen können.';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return 'Importiere \"$name\" in Lumi ($count $itemLabel): $link';
  }

  @override
  String get notEnoughData => 'Nicht genügend Daten';

  @override
  String shareQuote(String title) {
    return 'Schaut euch dieses Zitat von \"$title\" auf Lumi an!';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Empfohlen für Lumi: $title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      'Geben Sie Ihre Anfrage in natürlicher Sprache ein oder sprechen Sie sie. Lumi erstellt einen KI-Plan, führt eine Vektorsuche durch und liefert mehrere Showvorschläge.';

  @override
  String get aiLauncherDescriptionMovie =>
      'Geben Sie Ihre Anfrage in natürlicher Sprache ein oder sprechen Sie sie. Lumi erstellt einen KI-Plan, führt eine Vektorsuche durch und liefert mehrere Filmvorschläge.';

  @override
  String get warmingUpMovieSearch => 'Aufwärmen Ihrer Filmsuche';

  @override
  String get connectingToRecommendationEngine =>
      'Verbindung zum Empfehlungssystem herstellen';

  @override
  String get understandingYourTaste => 'Verstehen, worauf du gerade Lust hast';

  @override
  String get buildingCustomSearch =>
      'Erstellung einer benutzerdefinierten Suche anhand Ihrer Anfrage';

  @override
  String get tinyNetworkHiccup => 'Kleiner Netzwerkfehler, neuer Versuch.';

  @override
  String get planLocked => 'Plan steht fest: Genre, Stil, Sprache und Laufzeit';

  @override
  String get scanningTmdb =>
      'TMDB wird nach starken Übereinstimmungen durchsucht';

  @override
  String get collectingDetails =>
      'Sammelt Poster, Bewertungen und Laufzeiten für die Top-Empfehlungen';

  @override
  String shortlistingPicksCount(String current, String total) {
    return 'Vorauswahl ($current/$total)';
  }

  @override
  String get shortlistingBestPicks => 'Auswahl der besten Kandidaten';

  @override
  String get finalPolish => 'Feinschliff für Ihre Empfehlungen';

  @override
  String get retryingAfterIssue =>
      'Erneuter Versuch nach einem vorübergehenden Problem';

  @override
  String get regionUnitedStates => 'Vereinigte Staaten';

  @override
  String get regionIndia => 'Indien';

  @override
  String get regionUnitedKingdom => 'Vereinigtes Königreich';

  @override
  String get regionCanada => 'Kanada';

  @override
  String get regionAustralia => 'Australien';

  @override
  String get regionNewZealand => 'Neuseeland';

  @override
  String get regionGermany => 'Deutschland';

  @override
  String get regionFrance => 'Frankreich';

  @override
  String get regionSpain => 'Spanien';

  @override
  String get regionItaly => 'Italien';

  @override
  String get regionJapan => 'Übersetzen nach de: Japan';

  @override
  String get regionSouthKorea => 'Südkorea';

  @override
  String get regionBrazil => 'Brasilien';

  @override
  String get regionMexico => 'Mexiko';

  @override
  String get regionSingapore => 'Singapur';

  @override
  String get regionPhilippines => 'Philippinen';

  @override
  String get regionIndonesia => 'Indonesien';

  @override
  String get regionUnitedArabEmirates => 'Vereinigte Arabische Emirate';

  @override
  String get regionSaudiArabia => 'Saudi-Arabien';

  @override
  String get regionTurkey => 'Truthahn';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return 'Automatisch erkannte Region: $regionLabel ($regionCode). Wählen Sie eine Region aus, die für lokalisierte Filmabfragen und die Suche nach Streaming-Anbietern überschrieben werden soll.';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return 'Ausgewählte Region: $regionLabel ($regionCode). Unterstützte Filmabfragen und Abfragen von Streaming-Anbietern verwenden diese Region beim nächsten Mal automatisch wieder.';
  }

  @override
  String get syncSignInTooltip =>
      'Melden Sie sich an, um mit der Cloud zu synchronisieren.';

  @override
  String get syncFailedTooltip =>
      'Synchronisierung fehlgeschlagen. Zum erneuten Versuch tippen.';

  @override
  String get syncedTooltip => 'Bibliothek mit Cloud synchronisiert';

  @override
  String get shareQuoteTooltip => 'Kurs teilen';

  @override
  String get copyQuoteTooltip => 'Zitat kopieren';

  @override
  String get quoteCopiedToast => 'Zitat in die Zwischenablage kopiert';

  @override
  String get shareDialogueTooltip => 'Dialog teilen';

  @override
  String get copyDialogueTooltip => 'Dialog kopieren';

  @override
  String get dialogueCopiedToast => 'Dialog in die Zwischenablage kopiert';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$title wird in 1 Stunde ausgestrahlt';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel \"$episodeName\" wird um $localAirTime ausgestrahlt.';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$title erscheint heute';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return 'Ein Film aus Ihrer Bibliothek erscheint am $localDate.';
  }

  @override
  String get curatedNeoNoirNights => 'Neo-Noir-Nächte';

  @override
  String get curatedPulsePoundingRush => 'Pulsschlagender Rausch';

  @override
  String get curatedFeelGoodEscape => 'Wohlfühl-Auszeit';

  @override
  String get curatedMindBenders => 'Verblüffende';

  @override
  String get curatedEpicWorlds => 'Epische Welten';

  @override
  String get curatedHumanStories => 'Menschliche Geschichten';

  @override
  String get curatedDarkDetectiveFiles =>
      'Übersetzung ins Deutsche: Dark Detective Files';

  @override
  String get curatedNeoNoirNightsDescription =>
      'Regengetränkte Spannung, moralisch ambivalente Hauptfiguren und atmosphärische Stadtgeschichten.';

  @override
  String get curatedPulsePoundingRushDescription =>
      'Hochriskante Verfolgungsjagden, zunehmende Gefahr und ein rasantes Tempo, das einem keine Zeit zum Luftholen lässt.';

  @override
  String get curatedFeelGoodEscapeDescription =>
      'Herzerwärmende Geschichten, erhebende Handlungsstränge und wohltuende Empfehlungen für einen entspannten Abend.';

  @override
  String get curatedMindBendersDescription =>
      'Realitätsverzerrende Konzepte, verschlungene Handlungsstränge und Geschichten mit großen Ideen.';

  @override
  String get curatedEpicWorldsDescription =>
      'Abenteuer in einem gewaltigen Universum, mythische Einsätze und filmreife Inszenierung.';

  @override
  String get curatedHumanStoriesDescription =>
      'Charakterdramen mit emotionaler Wucht und unvergesslichen Darbietungen.';

  @override
  String get curatedDarkDetectiveFilesDescription =>
      'Kalte Spuren, vielschichtige Verdächtige und sich langsam entwickelnde Ermittlungen.';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get appLanguageSystemDefault => 'Systemstandard';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return 'Die App-Sprache ist auf $language eingestellt. Dadurch ändert sich nur die Benutzeroberfläche der App, nicht die Sprache des Films oder der Sendung.';
  }

  @override
  String get appLanguageSystemSubtitle =>
      'Die App-Sprache richtet sich nach den Geräteeinstellungen. Ändern Sie sie, um die Benutzeroberfläche in einer anderen Sprache beizubehalten.';

  @override
  String get contentLanguageAllSubtitle =>
      'Alle Sprachen. Die Registerkarten „Filme“ und „Fernsehen“ bleiben breit gefasst, während „Entdecken“ gegebenenfalls stärkere lokale Ergebnisse bevorzugt.';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return 'Aktuell ist die Sprache auf $language eingestellt. Die Tabs „Filme“ und „Fernsehen“ bleiben strikt, während im Bereich „Entdecken“ diese Sprache bevorzugt wird.';
  }
}
