// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lumi';

  @override
  String get navExplore => 'Explore';

  @override
  String get navMovies => 'Movies';

  @override
  String get navTvShows => 'TV Shows';

  @override
  String get navLibrary => 'Library';

  @override
  String get navAccount => 'Account';

  @override
  String get searchHint => 'Search movies, TV shows, companies...';

  @override
  String get searchForPerson => 'Search for a person...';

  @override
  String get searchLanguages => 'Search languages';

  @override
  String get searchNameOrRole => 'Search name or role...';

  @override
  String get retry => 'Retry';

  @override
  String get tryAgain => 'Try again';

  @override
  String get clear => 'Clear';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get share => 'Share';

  @override
  String get undo => 'UNDO';

  @override
  String get close => 'Close';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get done => 'Done';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signOut => 'Sign Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully.';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSubtitle =>
      'Choose your theme and customize the app look.';

  @override
  String get notifications => 'Notifications';

  @override
  String get releaseCalendar => 'Release Calendar';

  @override
  String get hiddenTitles => 'Hidden Titles';

  @override
  String get aiRecommendationsPrivacy => 'AI Recommendations Privacy';

  @override
  String get contentRegion => 'Content Region';

  @override
  String get contentLanguage => 'Content Language';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get notes => 'Notes';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get addNoteHint => 'Add a note...';

  @override
  String get addBriefNoteHint => 'Add a brief note (optional)...';

  @override
  String get enterNewName => 'Enter new name...';

  @override
  String get importSharedList => 'Import Shared List';

  @override
  String get discoverOnLumi => 'DISCOVER ON LUMI';

  @override
  String get filtered => 'Filtered';

  @override
  String get fullPlot => 'Full Plot';

  @override
  String get userReviews => 'User Reviews';

  @override
  String get noReviewsYet => 'No reviews yet.';

  @override
  String get openInYouTube => 'Open in YouTube';

  @override
  String get hiddenGems => 'Hidden Gems';

  @override
  String get resetSpotlight => 'Reset Spotlight';

  @override
  String get clearPreferences => 'Clear preferences';

  @override
  String get refreshPicks => 'Refresh picks';

  @override
  String get shareBoard => 'Share board';

  @override
  String get exploreDetails => 'Explore details';

  @override
  String get searchWikiquotes => 'Search Wikiquotes';

  @override
  String get selectAQuote => 'Select a Quote';

  @override
  String get tooltipShareQuote => 'Share quote';

  @override
  String get tooltipCopyQuote => 'Copy quote';

  @override
  String get tooltipShareDialogue => 'Share dialogue';

  @override
  String get tooltipCopyDialogue => 'Copy dialogue';

  @override
  String get tooltipUnhide => 'Unhide';

  @override
  String get tooltipOpenPrivacyPolicy => 'Open privacy policy';

  @override
  String get tooltipRefreshInsights => 'Refresh insights';

  @override
  String get tooltipSortTitles => 'Sort titles';

  @override
  String get tooltipSearch => 'Search';

  @override
  String get tooltipFilters => 'Filters';

  @override
  String get tooltipSaveToGallery => 'Save to Gallery';

  @override
  String get tooltipShare => 'Share';

  @override
  String get tooltipShareAnalytics => 'Share analytics';

  @override
  String get tooltipSetAiringReminder => 'Set airing reminder';

  @override
  String get tooltipLibrarySynced => 'Library synced with cloud';

  @override
  String get noMoreEntries => 'No more entries';

  @override
  String get noItemsFound => 'No items found';

  @override
  String errorLoadingGenres(String error) {
    return 'Error loading genres: $error';
  }

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get errorLoadingLists => 'Error loading lists';

  @override
  String errorLoadingQuotes(Object error) {
    return 'Error loading quotes.';
  }

  @override
  String get errorCouldNotShareAnalytics => 'Could not share analytics card.';

  @override
  String get errorCouldNotShareRecommendations =>
      'Could not share recommendation board.';

  @override
  String get errorCouldNotShareInsights => 'Could not share watch insights.';

  @override
  String get watchInsightsNotReady => 'Watch insights are not ready yet.';

  @override
  String titleRestoredToSpotlight(String title) {
    return '\"$title\" restored to Spotlight';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '\"$title\" has been hidden';
  }

  @override
  String hiddenDate(String date) {
    return 'Hidden: $date';
  }

  @override
  String get moviesInThisCollection => 'Movies in this Collection';

  @override
  String get searchPlanReady => 'Search plan is ready';

  @override
  String get hoursBeforeAirTime => 'Hours before air time';

  @override
  String get noUpcomingReleases => 'No upcoming releases';

  @override
  String get noRemindersSet => 'No reminders set';

  @override
  String get noHiddenTitles => 'No hidden titles';

  @override
  String get hiddenTitlesDescription =>
      'Titles you hide from the Spotlight section will appear here, and you will be able to restore them at any time.';

  @override
  String get tvShow => 'TV SHOW';

  @override
  String get movie => 'MOVIE';

  @override
  String get aiConsentGranted =>
      'You\'ve opted in. Your library data is used to personalize recommendations.';

  @override
  String get aiConsentNotGranted =>
      'Your library data is never shared unless you opt in.';

  @override
  String get languageSettingExplanation =>
      'Movies and TV tabs use this strictly. Explore prefers it first and falls back when a rail gets sparse.';

  @override
  String get filterScreenTitle => 'Filters';

  @override
  String get sortBy => 'Sort by';

  @override
  String get genres => 'Genres';

  @override
  String get year => 'Year';

  @override
  String get rating => 'Rating';

  @override
  String get runtime => 'Runtime';

  @override
  String get withPeople => 'With People';

  @override
  String get voteCount => 'Vote Count';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get minutes => 'min';

  @override
  String get hours => 'h';

  @override
  String get cast => 'Cast';

  @override
  String get crew => 'Crew';

  @override
  String get director => 'Director';

  @override
  String get seasons => 'Seasons';

  @override
  String get episodes => 'Episodes';

  @override
  String get overview => 'Overview';

  @override
  String get similar => 'Similar';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get addedToWatchlist => 'Added to watchlist';

  @override
  String get removedFromWatchlist => 'Removed from watchlist';

  @override
  String get popularity => 'Popularity';

  @override
  String get releaseDate => 'Release Date';

  @override
  String get revenueLabel => 'Revenue';

  @override
  String get originalTitle => 'Original Title';

  @override
  String get voteAverage => 'Vote Average';

  @override
  String get favourites => 'Favourites';

  @override
  String get lists => 'lists';

  @override
  String get watched => 'Watched';

  @override
  String get all => 'All';

  @override
  String get tv => 'TV';

  @override
  String get librarySubtitle =>
      'Keep everything organized by collection, favourites, notes, and watch history.';

  @override
  String get selectRegion => 'Select Region';

  @override
  String get selectRegionDescription =>
      'Only TMDb endpoints that support region-aware queries will use this selection.';

  @override
  String get useAutoDetectedRegion => 'Use Auto-Detected Region';

  @override
  String get reminderRemoved => 'Reminder removed';

  @override
  String releaseReminderSet(String title) {
    return 'Release reminder set for $title.';
  }

  @override
  String episodeReminderSet(String title) {
    return 'Episode reminder set for $title.';
  }

  @override
  String get filteredResults => 'Filtered Results';

  @override
  String get genreResults => 'Genre Results';

  @override
  String couldNotLoadContent(String error) {
    return 'Could not load content. $error';
  }

  @override
  String get noContentAvailableForThisSelection =>
      'No content available for this selection.';

  @override
  String get writer => 'Writer';

  @override
  String get actors => 'Actors';

  @override
  String get noteNotFound => 'Note not found.';

  @override
  String yourNotesCount(int count) {
    return 'Your Notes ($count)';
  }

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String noteDeletedWithCount(int count) {
    return 'Note deleted ($count s)';
  }

  @override
  String get loadMore => 'Load More';

  @override
  String get noMoreProductionsFound => 'No more productions found.';

  @override
  String get noProductionsFound => 'No productions found.';

  @override
  String get watchInsights => 'Watch Insights';

  @override
  String get analyzingWatchHistory => 'Analyzing your watch history...';

  @override
  String get manageHiddenTitlesDescription =>
      'Manage the titles you have hidden from the Spotlight section.';

  @override
  String get tmdbLanguageMetadataNote =>
      'Some rails may look sparse in this mode because TMDB language metadata is incomplete for parts of the catalog, not necessarily because those titles do not exist.';

  @override
  String get tmdbDisclaimer =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get useLocalLibraryForSync => 'Use local library for sync?';

  @override
  String get themePresets => 'Theme presets';

  @override
  String get exitApp => 'Exit App';

  @override
  String get popular => 'Popular';

  @override
  String couldNotLoadReminders(String error) {
    return 'Could not load reminders.\n$error';
  }

  @override
  String get noRemindersSetYet =>
      'No reminders set yet.\nCreate one from Episode Tracker or Movie Details.';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return 'Episode S$seasonNumber • E$episodeNumber';
  }

  @override
  String get movieRelease => 'Movie release';

  @override
  String voteAverageStars(String voteAverage) {
    return '$voteAverage ★';
  }

  @override
  String get addMoreTrackedContent =>
      'Add more movies or shows to your watchlist, favourites, or lists.';

  @override
  String get fastPicksDescription =>
      'Fast picks based on what you already saved.';

  @override
  String get releaseCalendarDescription =>
      'Movie releases and next TV episodes with one-tap reminders.';

  @override
  String get staleWatchlist => 'Stale watchlist';

  @override
  String get tracked => 'Tracked';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get upcomingEmptyDescription =>
      'When tracked movies get release dates or shows have new episodes scheduled, they will appear here.';

  @override
  String get howManyMoviesWatchedEachMonth =>
      'How many movies you watched each month';

  @override
  String get howPersonalRatingsShifting =>
      'How your personal ratings are shifting over time';

  @override
  String get keepWatchingToBuildProfile =>
      'Keep watching to build your visual profile.';

  @override
  String get lumiWatchAnalytics => 'LUMI WATCH ANALYTICS';

  @override
  String get noGenreDistributionYet => 'No genre distribution available yet.';

  @override
  String get noMovieWatchHistoryRecentMonths =>
      'No movie watch history for recent months.';

  @override
  String get noRatingTrendDataYet => 'No rating trend data available yet.';

  @override
  String get preferredRuntime => 'Preferred Runtime';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return 'Preferred runtime is ~$minutes mins ($label)';
  }

  @override
  String get styledCardWithWatchStats => 'Styled card with your watch stats';

  @override
  String get titlesAnalyzed => 'Titles Analyzed';

  @override
  String get tryAgainAfterMoment => 'Try again after a moment.';

  @override
  String get watchAnalytics => 'Watch Analytics';

  @override
  String get whatGenresDominateHistory =>
      'What genres dominate your watch history';

  @override
  String get toggleMovies => 'Movies';

  @override
  String get toggleTv => 'TV';

  @override
  String get noMoreTitlesFound => 'No more titles found.';

  @override
  String get noTitlesFoundForKeyword => 'No titles found for this keyword';

  @override
  String get viewFull => 'View Full';

  @override
  String get accoladeDetails => 'Accolade Details';

  @override
  String get noDetailedAwardsInfo => 'No detailed awards info available.';

  @override
  String get alertSet => 'Alert Set!';

  @override
  String get budget => 'Budget';

  @override
  String get buy => 'Buy';

  @override
  String chooseBetweenHours(int maxHours) {
    return 'Choose between 1 and $maxHours';
  }

  @override
  String get deleteNoteConfirmationTitle => 'Delete Note?';

  @override
  String get episodeReminder => 'Episode Reminder';

  @override
  String get facebook => 'Facebook';

  @override
  String get free => 'Free';

  @override
  String get images => 'Images';

  @override
  String get instagram => 'Instagram';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get noNotesYet => 'No notes yet. Add your thoughts!';

  @override
  String get originalLanguage => 'Original Language';

  @override
  String partOfCollection(String collectionName) {
    return 'Part of the $collectionName';
  }

  @override
  String get roi => 'ROI';

  @override
  String releaseAlertSet(String date) {
    return 'Release watch alert set for $date. ';
  }

  @override
  String get rent => 'Rent';

  @override
  String get revenue => 'Revenue';

  @override
  String seeAllReviews(int count) {
    return 'See All ($count)';
  }

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get status => 'Status';

  @override
  String get stream => 'Stream';

  @override
  String get tikTok => 'TikTok';

  @override
  String get twitterX => 'X';

  @override
  String get yours => 'YOURS';

  @override
  String get youtube => 'YouTube';

  @override
  String get durationDays => 'd';

  @override
  String get durationHours => 'h';

  @override
  String get durationMinutes => 'm';

  @override
  String get durationSeconds => 's';

  @override
  String seasonRating(String score) {
    return '★ $score%';
  }

  @override
  String get we => 'We';

  @override
  String get aspect16x9 => '16:9';

  @override
  String get aspect9x16 => '9:16';

  @override
  String get background => 'Bg';

  @override
  String episodeCount(int count) {
    return '$count Eps';
  }

  @override
  String get noEpisodesForSeason => 'No episodes found for this season.';

  @override
  String get beautifulStyledCardForStories =>
      'Beautiful styled card for social stories';

  @override
  String get clickableShareLink =>
      'Clickable share link for WhatsApp and other apps';

  @override
  String get placeQuoteOnBackdrop =>
      'Place your favorite quote on a movie backdrop';

  @override
  String get standardLinkToMovieDatabase => 'Standard link to movie database';

  @override
  String get exploreLabel => 'Explore';

  @override
  String quoteCharacter(String character) {
    return '— $character';
  }

  @override
  String get aiTonightWatch => 'AI Tonight Watch';

  @override
  String get aiQueryPlan => 'AI query plan';

  @override
  String get airingToday => 'Airing Today';

  @override
  String get bigCrowdPleasers => 'Big crowd-pleasers with strong momentum';

  @override
  String get cinematic => 'Cinematic';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get currentTheatricalSlate =>
      'Current theatrical slate and near-future releases';

  @override
  String get dark => 'Dark';

  @override
  String get discoverSpotlight => 'Discover Spotlight';

  @override
  String get edgeOfYourSeat => 'Edge-of-your-seat';

  @override
  String get fastPaced => 'Fast-paced';

  @override
  String get feelGood => 'Feel-good';

  @override
  String get freshPicksContinuous => 'Fresh picks updated continuously';

  @override
  String get hideTitle => 'Hide Title';

  @override
  String get highRatedSkipped => 'High-rated titles most viewers skip';

  @override
  String get hotNowAudience => 'Hot now across the audience feed';

  @override
  String get inTheaters => 'In Theaters';

  @override
  String get indie => 'Indie';

  @override
  String get mindBending => 'Mind-bending';

  @override
  String get mostDiscussedShowsThisWeek => 'Most discussed shows this week';

  @override
  String get multiplePicks => 'Multiple picks';

  @override
  String get onTheAir => 'On The Air';

  @override
  String get personalizedFromWatchBehavior =>
      'Personalized from your watch behavior';

  @override
  String get pickAVibe => 'Pick a vibe and get instant matching titles';

  @override
  String get seeAll => 'See All';

  @override
  String get seriesCurrentlyAiring =>
      'Series currently airing with active episodes';

  @override
  String get thisWeek => 'This Week';

  @override
  String get topRated => 'Top Rated';

  @override
  String get voiceInput => 'Voice input';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% Match';
  }

  @override
  String runtimeMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String get examplePrompt =>
      'Example: Something like Interstellar, but not sci-fi.';

  @override
  String findingYourPerfectWatch(String dots) {
    return 'Finding your perfect watch$dots';
  }

  @override
  String get moreLikeThis => 'More like this';

  @override
  String get notForMe => 'Not for me';

  @override
  String get recentQueries => 'Recent queries';

  @override
  String get shufflingIdeas => 'Shuffling ideas...';

  @override
  String get tooMainstream => 'Too mainstream';

  @override
  String get whatShouldIWatchTonight => 'What should I watch tonight?';

  @override
  String debugLogEntry(String time, String message) {
    return '[$time] $message';
  }

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return 'Removed from watchlist ($seconds s)';
  }

  @override
  String creditsCount(String count) {
    return '$count Credits';
  }

  @override
  String get acrossFilmography => 'Across filmography';

  @override
  String get birthplace => 'Birthplace';

  @override
  String get born => 'Born';

  @override
  String get credits => 'Credits';

  @override
  String get died => 'Died';

  @override
  String get knownFor => 'Known For';

  @override
  String get noSharedTitlesAvailable => 'No shared titles available.';

  @override
  String get photos => 'Photos';

  @override
  String get personRating => 'Rating';

  @override
  String get taggedImages => 'Tagged Images';

  @override
  String get website => 'Website';

  @override
  String get noQuotesFound => 'No quotes found.';

  @override
  String get noSectionsFound => 'No sections found.';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noCollectionsFound => 'No collections found';

  @override
  String get noCompaniesFound => 'No companies found';

  @override
  String get noKeywordsFound => 'No keywords found';

  @override
  String get noMoreResultsFound => 'No more results found.';

  @override
  String get noResultsFound => 'No results found';

  @override
  String deleteListConfirmation(String listName) {
    return 'Are you sure you want to delete $listName?';
  }

  @override
  String get deleteListTitle => 'Delete List?';

  @override
  String get everythingYouPlanToWatch => 'Everything you plan to watch next.';

  @override
  String get finishedTitlesAndHistory =>
      'Finished titles plus your history and stats.';

  @override
  String get noListsCreatedYet => 'No lists created yet.';

  @override
  String get noNotesFound => 'No notes found';

  @override
  String get renameList => 'Rename';

  @override
  String get titlesYouNeverWantToLose => 'The titles you never want to lose.';

  @override
  String get yourThoughtsReactions =>
      'Your thoughts, reactions, and reminders.';

  @override
  String imageCounter(String current, String total) {
    return '$current / $total';
  }

  @override
  String get removeFromWatchedConfirmation =>
      'Are you sure you want to remove this from your watched list?';

  @override
  String get savedAsWatchedWithoutRating =>
      'This will be saved as watched without a personal rating.';

  @override
  String get noAdditionalRecommendationTrailers =>
      'No additional recommendation trailers were found.';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return '$count $itemLabel';
  }

  @override
  String get invalidSharedListLink =>
      'The link may be invalid, expired, or no longer accessible.';

  @override
  String get noTitlesAvailableToImport =>
      'There are no titles available to import.';

  @override
  String get allLanguages => 'All Languages';

  @override
  String get arabic => 'Arabic';

  @override
  String get bengali => 'Bengali';

  @override
  String get chinese => 'Chinese';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get german => 'German';

  @override
  String get gujarati => 'Gujarati';

  @override
  String get hindi => 'Hindi';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get italian => 'Italian';

  @override
  String get japanese => 'Japanese';

  @override
  String get kannada => 'Kannada';

  @override
  String get korean => 'Korean';

  @override
  String get malayalam => 'Malayalam';

  @override
  String get marathi => 'Marathi';

  @override
  String get persian => 'Persian';

  @override
  String get polish => 'Polish';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get punjabi => 'Punjabi';

  @override
  String get russian => 'Russian';

  @override
  String get spanish => 'Spanish';

  @override
  String get swedish => 'Swedish';

  @override
  String get tamil => 'Tamil';

  @override
  String get telugu => 'Telugu';

  @override
  String get thai => 'Thai';

  @override
  String get turkish => 'Turkish';

  @override
  String get urdu => 'Urdu';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get failedToLoadCollectionDetails =>
      'Failed to load collection details';

  @override
  String get franchiseProgress => 'Franchise Progress';

  @override
  String get officialSite => 'Official Site';

  @override
  String get productions => 'Productions';

  @override
  String get productionCompany => 'Production Company';

  @override
  String get failedToLoadCompanyInfo => 'Failed to load company info';

  @override
  String get profile => 'Profile';

  @override
  String get guestViewer => 'Guest Viewer';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      'Your profile, sync state, region, and visual preferences all live here.';

  @override
  String get signInToSync =>
      'Sign in to sync your watchlist, ratings, and preferences.';

  @override
  String get signedInAndSyncing => 'Signed in and syncing to the cloud.';

  @override
  String get developedBy => 'Developed by';

  @override
  String get couldNotAnalyzeWatchHistory =>
      'Could not analyze watch history right now.';

  @override
  String get includeLocalLibrary => 'Include Local Library';

  @override
  String get useCloudOnly => 'Use Cloud Only';

  @override
  String get localLibrarySyncDescription =>
      'This device already has local library titles. Include them in your signed-in library, or replace local library data with your cloud library.';

  @override
  String get mergedLocalTitles =>
      'Merged local titles into your signed-in library.';

  @override
  String get replacedLocalLibrary =>
      'Replaced local library data with your cloud library.';

  @override
  String get deleteAccountConfirmation =>
      'This permanently deletes your Lumi account and synced cloud data. Local data on this device will remain unless you remove the app data separately.';

  @override
  String get signedOutAndCleared =>
      'Signed out and cleared the local library on this device.';

  @override
  String get keepLocalLibrary => 'Keep Local Library';

  @override
  String get clearLocalLibrary => 'Clear Local Library';

  @override
  String get signOutChoiceDescription =>
      'Choose whether to keep the local library on this device after signing out.';

  @override
  String get disable => 'Disable';

  @override
  String get aiRecommendationsEnabled =>
      'AI recommendations data sharing enabled.';

  @override
  String get aiRecommendationsDisabled =>
      'AI recommendations data sharing disabled.';

  @override
  String get reviewAndManageConsent =>
      'Review and manage consent for sending library data to AI providers.';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      'Enabled. Recommend Tonight may send your library summary and recent queries to AI providers.';

  @override
  String basedOnWatchedTitles(String count) {
    return 'Based on $count watched titles';
  }

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get chooseYourVibe => 'Choose your vibe';

  @override
  String get appearanceDescription =>
      'Swap the app between cinematic personalities without changing any behavior.';

  @override
  String get exitAppConfirmation => 'Are you sure you want to exit Lumi?';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get generatingWatchAnalytics => 'Generating Watch Analytics';

  @override
  String get thisUsuallyTakesAFewSeconds => 'This usually takes a few seconds.';

  @override
  String get yourScreenStory => 'Your Screen Story';

  @override
  String get snapshotOfHowAndWhatYouWatch =>
      'A snapshot of how and what you watch';

  @override
  String get yourFavoriteGenres => 'Your Favorite Genres';

  @override
  String get genrePerformanceHighestRated =>
      'Genre Performance (Highest Rated)';

  @override
  String get personalizedViewingPatterns => 'Personalized viewing patterns';

  @override
  String get builtWithLumi => 'Built with Lumi';

  @override
  String get sharedWithLumi => 'Shared with Lumi';

  @override
  String get shareAnalytics => 'Share Analytics';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return 'Analyzed $count titles • Updated $date';
  }

  @override
  String get allSeasons => 'All Seasons';

  @override
  String get castAndCrew => 'Cast & Crew';

  @override
  String get featuredCrew => 'Featured Crew';

  @override
  String get stills => 'Stills';

  @override
  String get accoladeSummary => 'Accolade Summary';

  @override
  String get awardsAndAccolades => 'Awards & Accolades';

  @override
  String get unableToLoadMovieDetails => 'Unable to load movie details';

  @override
  String get overviewUnavailable => 'Overview unavailable for this title.';

  @override
  String get openCompletePlot =>
      'Open complete plot and extra metadata from OMDb.';

  @override
  String get noOverviewForSeason => 'No overview available for this season.';

  @override
  String get userScore => 'User Score';

  @override
  String get playTrailer => 'Play Trailer';

  @override
  String get whereToWatch => 'Where to Watch';

  @override
  String get availabilityDataByJustWatch => 'Availability data by JustWatch.';

  @override
  String get reminderSaved => 'Reminder saved';

  @override
  String reminderForTitle(String title) {
    return 'Reminder for $title';
  }

  @override
  String get pleaseSelectFutureTime => 'Please select a future time';

  @override
  String get notifyAt => 'Notify at';

  @override
  String get notifyHoursBeforeAiring => 'Notify how many hours before airing?';

  @override
  String enterNumberBetween(String maxHours) {
    return 'Enter a number between 1 and $maxHours';
  }

  @override
  String get set => 'Set';

  @override
  String get selectedReminderTimePassed =>
      'Selected reminder time has already passed';

  @override
  String episodeReminderSaved(String date) {
    return 'Episode reminder saved for $date';
  }

  @override
  String get areYouSureDeleteNote =>
      'Are you sure you want to delete this note?';

  @override
  String get noteAdded => 'Note added';

  @override
  String get lastSeason => 'Last Season';

  @override
  String get currentSeason => 'Current Season';

  @override
  String get viewAllSeasons => 'View All Seasons';

  @override
  String get removedFromFavourites => 'Removed from Favourites';

  @override
  String get addedToFavourites => 'Added to Favourites';

  @override
  String get awardsAndNominations => 'Awards & Nominations';

  @override
  String get viewAll => 'View All';

  @override
  String get boxOfficeFinancials => 'Box Office Financials';

  @override
  String get successMeter => 'Success Meter';

  @override
  String get blockbuster => 'BLOCKBUSTER';

  @override
  String get hit => 'HIT';

  @override
  String get breakEven => 'BREAK-EVEN';

  @override
  String get underperformer => 'UNDERPERFORMER';

  @override
  String get boxOfficeBomb => 'BOX OFFICE BOMB';

  @override
  String get episodeTracker => 'Episode Tracker';

  @override
  String get setAiringReminder => 'Set airing reminder';

  @override
  String get nextEpisodeCountdown => 'Next Episode Countdown';

  @override
  String get nextEpisode => 'Next episode';

  @override
  String get lastEpisodeToAir => 'Last Episode To Air';

  @override
  String get unknown => 'Unknown';

  @override
  String get contentAdvisory => 'Content Advisory';

  @override
  String get violence => 'Violence';

  @override
  String get sexAndNudity => 'Sex & Nudity';

  @override
  String get foulLanguage => 'Language';

  @override
  String get substances => 'Substances';

  @override
  String get fearAndHorror => 'Fear & Horror';

  @override
  String get familyFriendly => 'Family Friendly';

  @override
  String get generalAudience => 'General Audience';

  @override
  String get releaseTimeline => 'Release Timeline';

  @override
  String get notifyMe => 'Notify Me';

  @override
  String get theatricalRelease => 'Theatrical Release';

  @override
  String get digitalStreaming => 'Digital / Streaming';

  @override
  String get physicalRelease => 'Physical (Blu-ray / DVD)';

  @override
  String get awesome => 'Awesome';

  @override
  String get keywordsAndThemes => 'Keywords & Themes';

  @override
  String get videosAndBehindTheScenes => 'Videos & Behind-the-Scenes';

  @override
  String get productionStudios => 'Production Studios';

  @override
  String get fetchingWatchLink => 'Fetching watch link';

  @override
  String get findingBestProviderPage =>
      'Finding the best provider page for this title.';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode ';
  }

  @override
  String get error => 'Error';

  @override
  String get failedToLoadSeasonDetails => 'Failed to load season details';

  @override
  String get loading => 'Loading...';

  @override
  String runtimeSeparator(String runtime) {
    return '• $runtime';
  }

  @override
  String get fullCastAndCrew => 'Full Cast & Crew';

  @override
  String get shareMovie => 'Share Movie';

  @override
  String get quotes => 'Quotes';

  @override
  String get mayIncludeMismatches =>
      'May include occasional mismatches due to lexical quote search.';

  @override
  String get movieApiConfigurationRequired =>
      'Movie API configuration required';

  @override
  String get addMovieProxyBaseUrl =>
      'Add MOVIE_PROXY_BASE_URL to connect the app to the TMDB proxy.';

  @override
  String get cinematicPicksContext =>
      'Cinematic picks with instant vibe context. Roll for another surprise card.';

  @override
  String get curatedTonight => 'Curated Tonight';

  @override
  String curatedTonightTitle(String title) {
    return 'Curated Tonight: $title';
  }

  @override
  String get describeItYourWay =>
      'Describe it your way.\nWe find the best matches.';

  @override
  String get hide => 'Hide';

  @override
  String get hideTitleDescription =>
      'Hiding this title will prevent it from appearing in the Spotlight section in the future.';

  @override
  String get dontAskAgain => 'Don\'t ask again';

  @override
  String get imdbNa => 'IMDb NA';

  @override
  String get noDiscoverPicks => 'No discover picks available right now.';

  @override
  String get playPreview => 'Play Preview';

  @override
  String get recommendedForYou => 'Recommended for You';

  @override
  String get spotlightCompleted => 'Spotlight Completed';

  @override
  String get startAddingTitlesForRecommendations =>
      'Start adding titles for recommendations';

  @override
  String get clearedAllChoices =>
      'You have swiped and cleared all choices in your discover feed.';

  @override
  String get whatsPopular => 'What\'s Popular';

  @override
  String get trending => 'Trending';

  @override
  String get trendingPeople => 'Trending Personalities';

  @override
  String get starringTodayOrThisWeek => 'Stars trending today or this week';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get tvTrending => 'TV Trending';

  @override
  String get discoverByMood => 'Discover by Mood';

  @override
  String get needSomethingToWatchTonight => 'Need something to watch tonight?';

  @override
  String get needAMovieForTonight => 'Need a movie for tonight?';

  @override
  String get tryAiShows => 'Try AI Shows';

  @override
  String get tryAiMovies => 'Try AI Movies';

  @override
  String get findShows => 'Find Shows';

  @override
  String get findMovies => 'Find Movies';

  @override
  String get couldNotLoadThisRail => 'Couldn\'t load this rail';

  @override
  String get temporaryIssueLoadingRail =>
      'There was a temporary issue loading this rail.';

  @override
  String get noTitlesHereYet => 'No titles here yet';

  @override
  String get noHiddenGemsForGenre =>
      'No hidden gems found for this genre yet. Try another genre.';

  @override
  String get tryAnotherFilter =>
      'Try another filter or open this section for broader discovery.';

  @override
  String get seeAllFilters => 'See all filters';

  @override
  String get couldNotLoadCuratedPicks => 'Couldn\'t load curated picks';

  @override
  String get temporaryIssueLoadingCurated =>
      'There was a temporary issue loading tonight\'s curated list.';

  @override
  String get noCuratedPicksAvailable => 'No curated picks available';

  @override
  String get tryAgainWhileRefresh =>
      'Try again in a moment while we refresh tonight\'s TMDB list.';

  @override
  String get fromSpotlight => 'From Spotlight';

  @override
  String get addShowsMoviesForRecommendations =>
      'Add TV shows/movies to your watchlist, favourites, or watched list to see titles you might love.';

  @override
  String get allow => 'Allow';

  @override
  String get notNow => 'Not now';

  @override
  String get allowAiDataSharingTitle => 'Allow AI data sharing?';

  @override
  String get allowAiDataSharingDescription =>
      'Recommend Tonight sends the text you type for a movie recommendation request and temporary query-refinement context to Google Gemini and OpenRouter. Your full library and your sign-in credentials are not sent to those AI providers. Allow this data sharing for AI recommendations?';

  @override
  String get liveProgress => 'Live progress';

  @override
  String percentComplete(String percent) {
    return '$percent% complete';
  }

  @override
  String get describeIdealShowNight => 'Describe your ideal show night';

  @override
  String get describeIdealMovieNight => 'Describe your ideal movie night';

  @override
  String get useNaturalLanguage =>
      'Use natural language. Mention what you want, what to avoid, and optional language/runtime hints.';

  @override
  String get listeningTapMicToStop => 'Listening... tap mic again to stop.';

  @override
  String voiceInputError(String error) {
    return 'Voice input error: $error';
  }

  @override
  String get tapMicToDictate => 'Tap mic to dictate your request.';

  @override
  String get tapMicToEnableVoice => 'Tap mic to enable voice input.';

  @override
  String get findingShows => 'Finding Shows...';

  @override
  String get findingMovies => 'Finding Movies...';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return 'Tonight\'s Lumi picks for: $prompt';
  }

  @override
  String get tonightsPicks => 'Tonight\'s Picks';

  @override
  String get sharedFromLumi => 'Shared from Lumi';

  @override
  String get intent => 'Intent:';

  @override
  String get genreLabel => 'Genre:';

  @override
  String get avoid => 'Avoid:';

  @override
  String get languageLabel => 'Language:';

  @override
  String runtimeAtMost(String minutes) {
    return 'Runtime <= $minutes min';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return 'Runtime >= $minutes min';
  }

  @override
  String get yearLabel => 'Year:';

  @override
  String yearAfter(String year) {
    return 'After $year';
  }

  @override
  String yearBefore(String year) {
    return 'Before $year';
  }

  @override
  String get like => 'Like:';

  @override
  String get signal => 'Signal:';

  @override
  String get readingWatchedHistory => 'Reading your watched history...';

  @override
  String get findingTopGenres => 'Finding your top genres and patterns...';

  @override
  String get buildingTrends => 'Building monthly and rating trends...';

  @override
  String get writingInsights => 'Writing your personalized insights...';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get includeNotRated => 'Include Not Rated';

  @override
  String get errorLoadingTvGenres => 'Error loading TV genres';

  @override
  String get alsoKnownAs => 'Also Known As';

  @override
  String get biography => 'Biography';

  @override
  String get careerStatistics => 'Career Statistics';

  @override
  String get frequentlyCollaboratesWith => 'Frequently Collaborates With';

  @override
  String get notableQuotes => 'Notable Quotes';

  @override
  String get primaryRole => 'Primary Role';

  @override
  String get averageRating => 'Average Rating';

  @override
  String get topGenre => 'Top Genre';

  @override
  String get peakBoxOffice => 'Peak Box Office';

  @override
  String percentOfTitles(String percent) {
    return '$percent% of titles';
  }

  @override
  String sharedTitleCount(String count) {
    return '$count shared title(s)';
  }

  @override
  String billingOrder(String order) {
    return 'Billed #$order';
  }

  @override
  String get startTypingToSearch => 'Start typing to search';

  @override
  String get movieDiscoveryMadePersonal => 'Movie discovery, made personal';

  @override
  String get allNotes => 'All Notes';

  @override
  String get viewPersonalizedInsights =>
      'View personalized insights, charts, and trends.';

  @override
  String get curatedCollections => 'Curated collections';

  @override
  String get list => 'list';

  @override
  String get openList => 'Open list';

  @override
  String get thisListNoLongerExists => 'This list no longer exists';

  @override
  String listRenamed(String name) {
    return 'List renamed to $name';
  }

  @override
  String listDeleted(String name) {
    return 'List $name deleted';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return 'No $filter in your watchlist';
  }

  @override
  String noFilterInFavourites(String filter) {
    return 'No $filter in your favourites';
  }

  @override
  String noFilterInWatched(String filter) {
    return 'No $filter in watched';
  }

  @override
  String noFilterInThisList(String filter) {
    return 'No $filter in this list';
  }

  @override
  String noListsWithFilter(String filter) {
    return 'No lists with $filter';
  }

  @override
  String importedInto(String name) {
    return 'Imported into \"$name\"';
  }

  @override
  String get couldNotImportList => 'Could not import list';

  @override
  String get importing => 'Importing...';

  @override
  String get couldNotLoadSharedList => 'Could not load this shared list';

  @override
  String get editWatchedInfo => 'Edit Watched Info';

  @override
  String get watchDate => 'Watch Date';

  @override
  String get rewatchCount => 'Rewatch Count';

  @override
  String get watchedInfoUpdated => 'Watched info updated';

  @override
  String removedFromList(String listName) {
    return 'Removed from $listName';
  }

  @override
  String addedToList(String listName) {
    return 'Added to $listName';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return 'Added to $listName and Watchlist';
  }

  @override
  String get moreTrailersLikeThis => 'More Trailers Like This';

  @override
  String get noDescriptionForTrailer =>
      'No description available for this trailer.';

  @override
  String get closeTrailer => 'Close trailer';

  @override
  String get recommendedSeries => 'Recommended Series';

  @override
  String get recommendedMovie => 'Recommended Movie';

  @override
  String get notEnoughDataYet => 'Not enough data yet';

  @override
  String addAndRateMoreTitles(String count) {
    return 'Add and rate at least $count titles to unlock analytics.';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return 'You have $watchedCount/$requiredCount watched titles. Add $remaining more to unlock analytics.';
  }

  @override
  String get moviesPerMonth => 'Movies Per Month';

  @override
  String get genreDistribution => 'Genre Distribution';

  @override
  String get ratingTrends => 'Rating Trends';

  @override
  String get noData => 'No Data';

  @override
  String get myLatestWatchAnalytics => 'My latest watch analytics on Lumi';

  @override
  String get myWatchInsights => 'My watch insights on Lumi';

  @override
  String get infographicsCard => 'Infographics Card';

  @override
  String get watchInsightsSnapshot => 'Watch Insights Snapshot';

  @override
  String get availableOnceInsightsReady => 'Available once insights are ready';

  @override
  String get shareYourWatchInsights => 'Share your watch insights card';

  @override
  String get recentlyWatchedVibe => 'Recently Watched Vibe';

  @override
  String get mixedAcrossGenres => 'Mixed across genres';

  @override
  String get moviesPerMonthShort => 'Movies / Month';

  @override
  String get ratingTrend => 'Rating Trend';

  @override
  String get balanced => 'Balanced';

  @override
  String get noWatchNextSuggestionsYet => 'No watch-next suggestions yet';

  @override
  String get upcomingFromLibrary => 'Upcoming from your library';

  @override
  String get removeReminder => 'Remove reminder';

  @override
  String get remindMe => 'Remind me';

  @override
  String titleReleasesToday(String title) {
    return '$title releases today.';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle airs soon.';
  }

  @override
  String get controlPremiereAlerts =>
      'Control premiere alerts and release reminders.';

  @override
  String upcomingReleasesCount(String count) {
    return '$count upcoming release(s) across your library.';
  }

  @override
  String sittingInWatchlist(String days) {
    return 'Sitting in your watchlist for $days days';
  }

  @override
  String get alreadyOnWatchlist => 'Already on your watchlist';

  @override
  String get favouritedButNotWatched =>
      'You favourited this but have not marked it watched yet';

  @override
  String get savedInListReady =>
      'Saved in one of your lists and ready to watch';

  @override
  String get matchesTitlesYouTrack => 'Matches titles you already track';

  @override
  String get noOfficialSite => 'No official site';

  @override
  String get episodeAiring => 'Episode Airing';

  @override
  String get general => 'General';

  @override
  String scheduledFor(String date) {
    return 'Scheduled for $date';
  }

  @override
  String wasScheduledFor(String date) {
    return 'Was scheduled for $date';
  }

  @override
  String get noOverviewAvailable => 'No overview available.';

  @override
  String get searchHistoryCleared => 'Search history cleared';

  @override
  String get visualMovieCard => 'Visual Movie Card';

  @override
  String get smartLumiLink => 'Smart Lumi Link';

  @override
  String get directTmdbLink => 'Direct TMDB Link';

  @override
  String recommendedOnLumi(String title) {
    return 'Recommended on Lumi: $title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return 'Check out $title on Lumi!\n\n$link\n\nGet Lumi: $appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return 'Check out $title on TMDB: $link';
  }

  @override
  String releaseAlertTitle(String title) {
    return '$title release alert';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return 'Release watch alert set for $date. We will notify you when it is out.';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return 'We\'ll notify you as soon as \"$title\" is released digitally or on Blu-ray/DVD!';
  }

  @override
  String get episodeAlreadyDueToAir => 'This episode is already due to air';

  @override
  String get reminderSetSuccessfully => 'Reminder set successfully';

  @override
  String get speechRecognitionNotAvailable =>
      'Speech recognition is not available on this device.';

  @override
  String get describeShowMood =>
      'Describe what show you are in the mood for, and we will return a ranked list.';

  @override
  String get describeMovieMood =>
      'Describe what movie you are in the mood for, and we will return a ranked list.';

  @override
  String get aiLauncherDescription =>
      'Type or speak a natural-language request. Lumi builds an AI plan, runs vector search, and returns multiple show/movie picks.';

  @override
  String yearRange(String from, String to) {
    return '$from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return '$count reminder(s) scheduled.';
  }

  @override
  String regionAutoDetected(String region) {
    return 'Auto-detected: $region';
  }

  @override
  String regionSelected(String region) {
    return 'Selected: $region';
  }

  @override
  String get allLanguagesSubtitle => 'All languages';

  @override
  String currentlySetToLanguage(String language) {
    return 'Currently set to $language';
  }

  @override
  String get availabilities => 'Availabilities';

  @override
  String get mood => 'Mood';

  @override
  String get people => 'People';

  @override
  String get ads => 'Ads';

  @override
  String get theatricalLimited => 'Theatrical Limited';

  @override
  String get premier => 'Premier';

  @override
  String get mediaType => 'Media Type';

  @override
  String get couldNotLoadAnalytics => 'Could not load analytics';

  @override
  String get viewAllAwards => 'View All';

  @override
  String get win => 'Win';

  @override
  String get wins => 'Wins';

  @override
  String get nomination => 'Nomination';

  @override
  String get nominations => 'Nominations';

  @override
  String sharedBy(String name) {
    return 'Shared by $name';
  }

  @override
  String titleCount(String count) {
    return '$count title(s)';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count saved titles across your lists';
  }

  @override
  String get curatedCollectionsSubtitle =>
      'Curated collections you can organize and share.';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return 'Import \"$name\" into Lumi ($count $itemLabel): $link';
  }

  @override
  String get notEnoughData => 'Not enough data';

  @override
  String shareQuote(String title) {
    return 'Check out this quote from \"$title\" on Lumi!';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Recommended on Lumi: $title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      'Type or speak a natural-language request. Lumi builds an AI plan, runs vector search, and returns multiple show picks.';

  @override
  String get aiLauncherDescriptionMovie =>
      'Type or speak a natural-language request. Lumi builds an AI plan, runs vector search, and returns multiple movie picks.';

  @override
  String get warmingUpMovieSearch => 'Warming up your movie search';

  @override
  String get connectingToRecommendationEngine =>
      'Connecting to the recommendation engine';

  @override
  String get understandingYourTaste =>
      'Understanding what you are in the mood for';

  @override
  String get buildingCustomSearch =>
      'Building a custom search from your request';

  @override
  String get tinyNetworkHiccup => 'Tiny network hiccup, trying again';

  @override
  String get planLocked => 'Plan locked: genre, style, language, and runtime';

  @override
  String get scanningTmdb => 'Scanning TMDB for strong matches';

  @override
  String get collectingDetails =>
      'Collecting posters, ratings, and runtime for top picks';

  @override
  String shortlistingPicksCount(String current, String total) {
    return 'Shortlisting picks ($current/$total)';
  }

  @override
  String get shortlistingBestPicks => 'Shortlisting the best picks';

  @override
  String get finalPolish => 'Final polish on your recommendations';

  @override
  String get retryingAfterIssue => 'Retrying after a temporary issue';

  @override
  String get regionUnitedStates => 'United States';

  @override
  String get regionIndia => 'India';

  @override
  String get regionUnitedKingdom => 'United Kingdom';

  @override
  String get regionCanada => 'Canada';

  @override
  String get regionAustralia => 'Australia';

  @override
  String get regionNewZealand => 'New Zealand';

  @override
  String get regionGermany => 'Germany';

  @override
  String get regionFrance => 'France';

  @override
  String get regionSpain => 'Spain';

  @override
  String get regionItaly => 'Italy';

  @override
  String get regionJapan => 'Japan';

  @override
  String get regionSouthKorea => 'South Korea';

  @override
  String get regionBrazil => 'Brazil';

  @override
  String get regionMexico => 'Mexico';

  @override
  String get regionSingapore => 'Singapore';

  @override
  String get regionPhilippines => 'Philippines';

  @override
  String get regionIndonesia => 'Indonesia';

  @override
  String get regionUnitedArabEmirates => 'United Arab Emirates';

  @override
  String get regionSaudiArabia => 'Saudi Arabia';

  @override
  String get regionTurkey => 'Turkey';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return 'Auto-detected region: $regionLabel ($regionCode). Select a region to override for localized movie queries and watch-provider lookups.';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return 'Selected region: $regionLabel ($regionCode). Supported movie queries and watch-provider lookups will reuse this automatically next time.';
  }

  @override
  String get syncSignInTooltip => 'Sign in to sync with cloud';

  @override
  String get syncFailedTooltip => 'Sync failed. Tap to retry.';

  @override
  String get syncedTooltip => 'Library synced with cloud';

  @override
  String get shareQuoteTooltip => 'Share quote';

  @override
  String get copyQuoteTooltip => 'Copy quote';

  @override
  String get quoteCopiedToast => 'Quote copied to clipboard';

  @override
  String get shareDialogueTooltip => 'Share dialogue';

  @override
  String get copyDialogueTooltip => 'Copy dialogue';

  @override
  String get dialogueCopiedToast => 'Dialogue copied to clipboard';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$title airs in 1 hour';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel \"$episodeName\" airs at $localAirTime.';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$title releases today';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return 'A movie in your library is releasing on $localDate.';
  }

  @override
  String get curatedNeoNoirNights => 'Neo-noir Nights';

  @override
  String get curatedPulsePoundingRush => 'Pulse-Pounding Rush';

  @override
  String get curatedFeelGoodEscape => 'Feel-Good Escape';

  @override
  String get curatedMindBenders => 'Mind-Benders';

  @override
  String get curatedEpicWorlds => 'Epic Worlds';

  @override
  String get curatedHumanStories => 'Human Stories';

  @override
  String get curatedDarkDetectiveFiles => 'Dark Detective Files';

  @override
  String get curatedNeoNoirNightsDescription =>
      'Rain-soaked tension, morally gray leads, and atmospheric city stories.';

  @override
  String get curatedPulsePoundingRushDescription =>
      'High-stakes chases, escalating danger, and no-time-to-breathe pacing.';

  @override
  String get curatedFeelGoodEscapeDescription =>
      'Warm stories, uplifting arcs, and comforting picks for a relaxed night.';

  @override
  String get curatedMindBendersDescription =>
      'Reality-warping concepts, twisty plotting, and big-idea storytelling.';

  @override
  String get curatedEpicWorldsDescription =>
      'Big-universe adventures, mythic stakes, and cinematic scale.';

  @override
  String get curatedHumanStoriesDescription =>
      'Character-first dramas with emotional pull and memorable performances.';

  @override
  String get curatedDarkDetectiveFilesDescription =>
      'Cold clues, layered suspects, and slow-burn investigations.';

  @override
  String get appLanguage => 'App Language';

  @override
  String get appLanguageSystemDefault => 'System default';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return 'App language set to $language. This only changes the app interface, not the movie and show language.';
  }

  @override
  String get appLanguageSystemSubtitle =>
      'App language follows your device settings. Change it to keep the interface in a different language.';

  @override
  String get contentLanguageAllSubtitle =>
      'All languages. Movies and TV tabs stay broad, while Explore can still prefer stronger local fits when available.';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return 'Currently set to $language. Movies and TV tabs will stay strict, while Explore will prefer this language first.';
  }
}
