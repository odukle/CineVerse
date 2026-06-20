import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('gu'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('mr'),
    Locale('pa'),
    Locale('pt'),
    Locale('ru'),
    Locale('ta'),
    Locale('te'),
    Locale('zh'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Lumi'**
  String get appName;

  /// Bottom navigation label for Explore tab
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// Bottom navigation label for Movies tab
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get navMovies;

  /// Bottom navigation label for TV Shows tab
  ///
  /// In en, this message translates to:
  /// **'TV Shows'**
  String get navTvShows;

  /// Bottom navigation label for Library/Watchlist tab
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Bottom navigation label for Account tab
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// Search bar hint text
  ///
  /// In en, this message translates to:
  /// **'Search movies, TV shows, companies...'**
  String get searchHint;

  /// Search person placeholder
  ///
  /// In en, this message translates to:
  /// **'Search for a person...'**
  String get searchForPerson;

  /// Hint for language search input
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get searchLanguages;

  /// Search cast crew placeholder
  ///
  /// In en, this message translates to:
  /// **'Search name or role...'**
  String get searchNameOrRole;

  /// Button label to retry a failed action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Alternative retry button label
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Button label to clear content
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Button label to cancel an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button label to confirm/acknowledge
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Button label to save content
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button label to delete content
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Button label to share content
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Undo button
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// Button label to close a dialog/sheet
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button label to apply filters
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Button label to reset a state
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Button label for completion
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Google sign-in button label
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Apple sign-in button label
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// Sign out button label
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Delete account button label
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Snackbar message after account deletion
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeletedSuccessfully;

  /// Appearance settings title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Appearance settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose your theme and customize the app look.'**
  String get appearanceSubtitle;

  /// Notifications settings title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Release calendar title
  ///
  /// In en, this message translates to:
  /// **'Release Calendar'**
  String get releaseCalendar;

  /// Hidden titles screen title
  ///
  /// In en, this message translates to:
  /// **'Hidden Titles'**
  String get hiddenTitles;

  /// AI consent settings title
  ///
  /// In en, this message translates to:
  /// **'AI Recommendations Privacy'**
  String get aiRecommendationsPrivacy;

  /// Content region settings title
  ///
  /// In en, this message translates to:
  /// **'Content Region'**
  String get contentRegion;

  /// Content language settings title
  ///
  /// In en, this message translates to:
  /// **'Content Language'**
  String get contentLanguage;

  /// Watchlist section title
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// Notes section title
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Tooltip for delete note action
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// Hint for note input field
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get addNoteHint;

  /// Hint for brief note input
  ///
  /// In en, this message translates to:
  /// **'Add a brief note (optional)...'**
  String get addBriefNoteHint;

  /// Hint for rename input
  ///
  /// In en, this message translates to:
  /// **'Enter new name...'**
  String get enterNewName;

  /// Import shared list screen title
  ///
  /// In en, this message translates to:
  /// **'Import Shared List'**
  String get importSharedList;

  /// Branding text on recommendation cards
  ///
  /// In en, this message translates to:
  /// **'DISCOVER ON LUMI'**
  String get discoverOnLumi;

  /// Label for filtered genre chip
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filtered;

  /// Full plot dialog/button label
  ///
  /// In en, this message translates to:
  /// **'Full Plot'**
  String get fullPlot;

  /// User reviews section title
  ///
  /// In en, this message translates to:
  /// **'User Reviews'**
  String get userReviews;

  /// Empty state message for reviews
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviewsYet;

  /// Button to open video in YouTube
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get openInYouTube;

  /// Explore section title for hidden gems
  ///
  /// In en, this message translates to:
  /// **'Hidden Gems'**
  String get hiddenGems;

  /// Button to reset spotlight selections
  ///
  /// In en, this message translates to:
  /// **'Reset Spotlight'**
  String get resetSpotlight;

  /// Button to clear user preferences
  ///
  /// In en, this message translates to:
  /// **'Clear preferences'**
  String get clearPreferences;

  /// Button to refresh recommendations
  ///
  /// In en, this message translates to:
  /// **'Refresh picks'**
  String get refreshPicks;

  /// Button to share recommendation board
  ///
  /// In en, this message translates to:
  /// **'Share board'**
  String get shareBoard;

  /// Button to explore item details
  ///
  /// In en, this message translates to:
  /// **'Explore details'**
  String get exploreDetails;

  /// Wikiquotes search button
  ///
  /// In en, this message translates to:
  /// **'Search Wikiquotes'**
  String get searchWikiquotes;

  /// Quote selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select a Quote'**
  String get selectAQuote;

  /// Tooltip for share quote button
  ///
  /// In en, this message translates to:
  /// **'Share quote'**
  String get tooltipShareQuote;

  /// Tooltip for copy quote button
  ///
  /// In en, this message translates to:
  /// **'Copy quote'**
  String get tooltipCopyQuote;

  /// Tooltip for share dialogue button
  ///
  /// In en, this message translates to:
  /// **'Share dialogue'**
  String get tooltipShareDialogue;

  /// Tooltip for copy dialogue button
  ///
  /// In en, this message translates to:
  /// **'Copy dialogue'**
  String get tooltipCopyDialogue;

  /// Tooltip for unhide title button
  ///
  /// In en, this message translates to:
  /// **'Unhide'**
  String get tooltipUnhide;

  /// Tooltip for privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Open privacy policy'**
  String get tooltipOpenPrivacyPolicy;

  /// Tooltip for refresh insights button
  ///
  /// In en, this message translates to:
  /// **'Refresh insights'**
  String get tooltipRefreshInsights;

  /// Tooltip for sort button
  ///
  /// In en, this message translates to:
  /// **'Sort titles'**
  String get tooltipSortTitles;

  /// Tooltip for search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tooltipSearch;

  /// Tooltip for filters button
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get tooltipFilters;

  /// Tooltip for save to gallery button
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get tooltipSaveToGallery;

  /// Tooltip for share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get tooltipShare;

  /// Tooltip for share analytics button
  ///
  /// In en, this message translates to:
  /// **'Share analytics'**
  String get tooltipShareAnalytics;

  /// Tooltip for airing reminder
  ///
  /// In en, this message translates to:
  /// **'Set airing reminder'**
  String get tooltipSetAiringReminder;

  /// Tooltip when library sync is complete
  ///
  /// In en, this message translates to:
  /// **'Library synced with cloud'**
  String get tooltipLibrarySynced;

  /// Message shown when there are no more items to load
  ///
  /// In en, this message translates to:
  /// **'No more entries'**
  String get noMoreEntries;

  /// Message shown when no items are found
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// Error message when genres fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading genres: {error}'**
  String errorLoadingGenres(String error);

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// Error when lists fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading lists'**
  String get errorLoadingLists;

  /// Error loading quotes
  ///
  /// In en, this message translates to:
  /// **'Error loading quotes.'**
  String errorLoadingQuotes(Object error);

  /// Snackbar error for analytics sharing failure
  ///
  /// In en, this message translates to:
  /// **'Could not share analytics card.'**
  String get errorCouldNotShareAnalytics;

  /// Snackbar error for recommendation sharing failure
  ///
  /// In en, this message translates to:
  /// **'Could not share recommendation board.'**
  String get errorCouldNotShareRecommendations;

  /// Snackbar error for insights sharing failure
  ///
  /// In en, this message translates to:
  /// **'Could not share watch insights.'**
  String get errorCouldNotShareInsights;

  /// Snackbar message when insights are still loading
  ///
  /// In en, this message translates to:
  /// **'Watch insights are not ready yet.'**
  String get watchInsightsNotReady;

  /// Snackbar when a title is restored to spotlight
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" restored to Spotlight'**
  String titleRestoredToSpotlight(String title);

  /// Snackbar when a title is hidden
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" has been hidden'**
  String titleHasBeenHidden(String title);

  /// Label showing when a title was hidden
  ///
  /// In en, this message translates to:
  /// **'Hidden: {date}'**
  String hiddenDate(String date);

  /// Collection details section header
  ///
  /// In en, this message translates to:
  /// **'Movies in this Collection'**
  String get moviesInThisCollection;

  /// Tonight watch progress message
  ///
  /// In en, this message translates to:
  /// **'Search plan is ready'**
  String get searchPlanReady;

  /// Hint for reminder time input
  ///
  /// In en, this message translates to:
  /// **'Hours before air time'**
  String get hoursBeforeAirTime;

  /// Empty state for release calendar
  ///
  /// In en, this message translates to:
  /// **'No upcoming releases'**
  String get noUpcomingReleases;

  /// Empty state for notifications
  ///
  /// In en, this message translates to:
  /// **'No reminders set'**
  String get noRemindersSet;

  /// Empty state for hidden titles
  ///
  /// In en, this message translates to:
  /// **'No hidden titles'**
  String get noHiddenTitles;

  /// Description for hidden titles screen
  ///
  /// In en, this message translates to:
  /// **'Titles you hide from the Spotlight section will appear here, and you will be able to restore them at any time.'**
  String get hiddenTitlesDescription;

  /// Label for TV show type
  ///
  /// In en, this message translates to:
  /// **'TV SHOW'**
  String get tvShow;

  /// Label for movie type
  ///
  /// In en, this message translates to:
  /// **'MOVIE'**
  String get movie;

  /// Subtitle when AI consent is granted
  ///
  /// In en, this message translates to:
  /// **'You\'ve opted in. Your library data is used to personalize recommendations.'**
  String get aiConsentGranted;

  /// Subtitle when AI consent is not granted
  ///
  /// In en, this message translates to:
  /// **'Your library data is never shared unless you opt in.'**
  String get aiConsentNotGranted;

  /// Explanation for content language setting
  ///
  /// In en, this message translates to:
  /// **'Movies and TV tabs use this strictly. Explore prefers it first and falls back when a rail gets sparse.'**
  String get languageSettingExplanation;

  /// Filter screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterScreenTitle;

  /// Sort by label in filters
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Genres label in filters
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// Year filter label
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Rating filter label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Runtime filter label
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get runtime;

  /// People filter label
  ///
  /// In en, this message translates to:
  /// **'With People'**
  String get withPeople;

  /// Vote count filter label
  ///
  /// In en, this message translates to:
  /// **'Vote Count'**
  String get voteCount;

  /// Localized string for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for tomorrow's date
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Label for yesterday's date
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Abbreviation for minutes
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// Abbreviation for hours
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hours;

  /// Cast section title
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// Crew section title
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crew;

  /// Director label
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get director;

  /// Seasons label for TV shows
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get seasons;

  /// Episodes label for TV shows
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodes;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Similar titles section
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get similar;

  /// Recommendations section
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// Snackbar after adding to watchlist
  ///
  /// In en, this message translates to:
  /// **'Added to watchlist'**
  String get addedToWatchlist;

  /// Snackbar after removing from watchlist
  ///
  /// In en, this message translates to:
  /// **'Removed from watchlist'**
  String get removedFromWatchlist;

  /// Sort option: popularity
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get popularity;

  /// Sort option: release date
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get releaseDate;

  /// Sort option: revenue
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenueLabel;

  /// Sort option: original title
  ///
  /// In en, this message translates to:
  /// **'Original Title'**
  String get originalTitle;

  /// Sort option: vote average
  ///
  /// In en, this message translates to:
  /// **'Vote Average'**
  String get voteAverage;

  /// Favourites section label
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// Localized string for lists
  ///
  /// In en, this message translates to:
  /// **'lists'**
  String get lists;

  /// Localized string for watched
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watched;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// TV filter option
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get tv;

  /// Watchlist screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Keep everything organized by collection, favourites, notes, and watch history.'**
  String get librarySubtitle;

  /// Region selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Region'**
  String get selectRegion;

  /// Region selection dialog description
  ///
  /// In en, this message translates to:
  /// **'Only TMDb endpoints that support region-aware queries will use this selection.'**
  String get selectRegionDescription;

  /// Button to use auto-detected region
  ///
  /// In en, this message translates to:
  /// **'Use Auto-Detected Region'**
  String get useAutoDetectedRegion;

  /// Localized string for reminderRemoved
  ///
  /// In en, this message translates to:
  /// **'Reminder removed'**
  String get reminderRemoved;

  /// Snackbar when a release reminder is set
  ///
  /// In en, this message translates to:
  /// **'Release reminder set for {title}.'**
  String releaseReminderSet(String title);

  /// Snackbar when an episode reminder is set
  ///
  /// In en, this message translates to:
  /// **'Episode reminder set for {title}.'**
  String episodeReminderSet(String title);

  /// Filtered results label
  ///
  /// In en, this message translates to:
  /// **'Filtered Results'**
  String get filteredResults;

  /// Genre results label
  ///
  /// In en, this message translates to:
  /// **'Genre Results'**
  String get genreResults;

  /// Error when content fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load content. {error}'**
  String couldNotLoadContent(String error);

  /// Empty state when no content is available
  ///
  /// In en, this message translates to:
  /// **'No content available for this selection.'**
  String get noContentAvailableForThisSelection;

  /// Writer label
  ///
  /// In en, this message translates to:
  /// **'Writer'**
  String get writer;

  /// Actors label
  ///
  /// In en, this message translates to:
  /// **'Actors'**
  String get actors;

  /// Error when note is not found
  ///
  /// In en, this message translates to:
  /// **'Note not found.'**
  String get noteNotFound;

  /// Localized string for yourNotesCount
  ///
  /// In en, this message translates to:
  /// **'Your Notes ({count})'**
  String yourNotesCount(int count);

  /// Localized string for noteDeleted
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// Localized string for noteDeletedWithCount
  ///
  /// In en, this message translates to:
  /// **'Note deleted ({count} s)'**
  String noteDeletedWithCount(int count);

  /// Load more button
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No more productions in company details
  ///
  /// In en, this message translates to:
  /// **'No more productions found.'**
  String get noMoreProductionsFound;

  /// No productions in company details
  ///
  /// In en, this message translates to:
  /// **'No productions found.'**
  String get noProductionsFound;

  /// Watch insights section title
  ///
  /// In en, this message translates to:
  /// **'Watch Insights'**
  String get watchInsights;

  /// Analyzing watch history loading text
  ///
  /// In en, this message translates to:
  /// **'Analyzing your watch history...'**
  String get analyzingWatchHistory;

  /// Description for hidden titles management
  ///
  /// In en, this message translates to:
  /// **'Manage the titles you have hidden from the Spotlight section.'**
  String get manageHiddenTitlesDescription;

  /// Note about TMDB language metadata sparseness
  ///
  /// In en, this message translates to:
  /// **'Some rails may look sparse in this mode because TMDB language metadata is incomplete for parts of the catalog, not necessarily because those titles do not exist.'**
  String get tmdbLanguageMetadataNote;

  /// TMDB API disclaimer
  ///
  /// In en, this message translates to:
  /// **'This product uses the TMDB API but is not endorsed or certified by TMDB.'**
  String get tmdbDisclaimer;

  /// Ask user to use local library for sync
  ///
  /// In en, this message translates to:
  /// **'Use local library for sync?'**
  String get useLocalLibraryForSync;

  /// Theme presets label
  ///
  /// In en, this message translates to:
  /// **'Theme presets'**
  String get themePresets;

  /// Exit app dialog title
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// Popular section label
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// Error loading reminders
  ///
  /// In en, this message translates to:
  /// **'Could not load reminders.\n{error}'**
  String couldNotLoadReminders(String error);

  /// No reminders set yet
  ///
  /// In en, this message translates to:
  /// **'No reminders set yet.\nCreate one from Episode Tracker or Movie Details.'**
  String get noRemindersSetYet;

  /// Episode season and episode label
  ///
  /// In en, this message translates to:
  /// **'Episode S{seasonNumber} • E{episodeNumber}'**
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber);

  /// Movie release reminder label
  ///
  /// In en, this message translates to:
  /// **'Movie release'**
  String get movieRelease;

  /// Vote average with stars
  ///
  /// In en, this message translates to:
  /// **'{voteAverage} ★'**
  String voteAverageStars(String voteAverage);

  /// Add more tracked content
  ///
  /// In en, this message translates to:
  /// **'Add more movies or shows to your watchlist, favourites, or lists.'**
  String get addMoreTrackedContent;

  /// Fast picks based on saved content
  ///
  /// In en, this message translates to:
  /// **'Fast picks based on what you already saved.'**
  String get fastPicksDescription;

  /// Release calendar feature description
  ///
  /// In en, this message translates to:
  /// **'Movie releases and next TV episodes with one-tap reminders.'**
  String get releaseCalendarDescription;

  /// Stale watchlist label
  ///
  /// In en, this message translates to:
  /// **'Stale watchlist'**
  String get staleWatchlist;

  /// Tracked tab label
  ///
  /// In en, this message translates to:
  /// **'Tracked'**
  String get tracked;

  /// Upcoming tab label
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Empty state for upcoming releases
  ///
  /// In en, this message translates to:
  /// **'When tracked movies get release dates or shows have new episodes scheduled, they will appear here.'**
  String get upcomingEmptyDescription;

  /// Chart description
  ///
  /// In en, this message translates to:
  /// **'How many movies you watched each month'**
  String get howManyMoviesWatchedEachMonth;

  /// Chart description
  ///
  /// In en, this message translates to:
  /// **'How your personal ratings are shifting over time'**
  String get howPersonalRatingsShifting;

  /// Empty state for watch history
  ///
  /// In en, this message translates to:
  /// **'Keep watching to build your visual profile.'**
  String get keepWatchingToBuildProfile;

  /// Watch analytics branding
  ///
  /// In en, this message translates to:
  /// **'LUMI WATCH ANALYTICS'**
  String get lumiWatchAnalytics;

  /// Empty state for genre distribution
  ///
  /// In en, this message translates to:
  /// **'No genre distribution available yet.'**
  String get noGenreDistributionYet;

  /// Empty state for monthly watch history
  ///
  /// In en, this message translates to:
  /// **'No movie watch history for recent months.'**
  String get noMovieWatchHistoryRecentMonths;

  /// Empty state for rating trend
  ///
  /// In en, this message translates to:
  /// **'No rating trend data available yet.'**
  String get noRatingTrendDataYet;

  /// Preferred runtime label
  ///
  /// In en, this message translates to:
  /// **'Preferred Runtime'**
  String get preferredRuntime;

  /// Preferred runtime text
  ///
  /// In en, this message translates to:
  /// **'Preferred runtime is ~{minutes} mins ({label})'**
  String preferredRuntimeLabel(String minutes, String label);

  /// Share option description
  ///
  /// In en, this message translates to:
  /// **'Styled card with your watch stats'**
  String get styledCardWithWatchStats;

  /// Titles analyzed label
  ///
  /// In en, this message translates to:
  /// **'Titles Analyzed'**
  String get titlesAnalyzed;

  /// Retry suggestion
  ///
  /// In en, this message translates to:
  /// **'Try again after a moment.'**
  String get tryAgainAfterMoment;

  /// Watch analytics title
  ///
  /// In en, this message translates to:
  /// **'Watch Analytics'**
  String get watchAnalytics;

  /// Genre distribution description
  ///
  /// In en, this message translates to:
  /// **'What genres dominate your watch history'**
  String get whatGenresDominateHistory;

  /// Movies toggle label
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get toggleMovies;

  /// TV toggle label
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get toggleTv;

  /// No more titles in keyword screen
  ///
  /// In en, this message translates to:
  /// **'No more titles found.'**
  String get noMoreTitlesFound;

  /// No titles for keyword
  ///
  /// In en, this message translates to:
  /// **'No titles found for this keyword'**
  String get noTitlesFoundForKeyword;

  /// View full episode
  ///
  /// In en, this message translates to:
  /// **'View Full'**
  String get viewFull;

  /// Accolade details dialog title
  ///
  /// In en, this message translates to:
  /// **'Accolade Details'**
  String get accoladeDetails;

  /// No awards details
  ///
  /// In en, this message translates to:
  /// **'No detailed awards info available.'**
  String get noDetailedAwardsInfo;

  /// Alert set confirmation
  ///
  /// In en, this message translates to:
  /// **'Alert Set!'**
  String get alertSet;

  /// Budget label
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Buy provider label
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// Hours input validation
  ///
  /// In en, this message translates to:
  /// **'Choose between 1 and {maxHours}'**
  String chooseBetweenHours(int maxHours);

  /// Delete note dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Note?'**
  String get deleteNoteConfirmationTitle;

  /// Episode reminder dialog title
  ///
  /// In en, this message translates to:
  /// **'Episode Reminder'**
  String get episodeReminder;

  /// Facebook social link
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// Free provider label
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Images section title
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// Instagram social link
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// Net profit label
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No notes yet message
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Add your thoughts!'**
  String get noNotesYet;

  /// Original language label
  ///
  /// In en, this message translates to:
  /// **'Original Language'**
  String get originalLanguage;

  /// Part of collection label
  ///
  /// In en, this message translates to:
  /// **'Part of the {collectionName}'**
  String partOfCollection(String collectionName);

  /// ROI label
  ///
  /// In en, this message translates to:
  /// **'ROI'**
  String get roi;

  /// Release alert set message
  ///
  /// In en, this message translates to:
  /// **'Release watch alert set for {date}. '**
  String releaseAlertSet(String date);

  /// Rent provider label
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// Revenue label
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// See all reviews button
  ///
  /// In en, this message translates to:
  /// **'See All ({count})'**
  String seeAllReviews(int count);

  /// Set reminder button
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Stream provider label
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get stream;

  /// TikTok social link
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get tikTok;

  /// X social link
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get twitterX;

  /// Yours label
  ///
  /// In en, this message translates to:
  /// **'YOURS'**
  String get yours;

  /// YouTube social link
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get youtube;

  /// Days abbreviation
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get durationDays;

  /// Hours abbreviation
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get durationHours;

  /// Minutes abbreviation
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get durationMinutes;

  /// Seconds abbreviation
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get durationSeconds;

  /// Season rating percentage
  ///
  /// In en, this message translates to:
  /// **'★ {score}%'**
  String seasonRating(String score);

  /// Localized string for we
  ///
  /// In en, this message translates to:
  /// **'We'**
  String get we;

  /// 16:9 aspect ratio
  ///
  /// In en, this message translates to:
  /// **'16:9'**
  String get aspect16x9;

  /// 9:16 aspect ratio
  ///
  /// In en, this message translates to:
  /// **'9:16'**
  String get aspect9x16;

  /// Background label
  ///
  /// In en, this message translates to:
  /// **'Bg'**
  String get background;

  /// Episode count
  ///
  /// In en, this message translates to:
  /// **'{count} Eps'**
  String episodeCount(int count);

  /// No episodes for season
  ///
  /// In en, this message translates to:
  /// **'No episodes found for this season.'**
  String get noEpisodesForSeason;

  /// Share option description
  ///
  /// In en, this message translates to:
  /// **'Beautiful styled card for social stories'**
  String get beautifulStyledCardForStories;

  /// Share option description
  ///
  /// In en, this message translates to:
  /// **'Clickable share link for WhatsApp and other apps'**
  String get clickableShareLink;

  /// Share option description
  ///
  /// In en, this message translates to:
  /// **'Place your favorite quote on a movie backdrop'**
  String get placeQuoteOnBackdrop;

  /// Share option description
  ///
  /// In en, this message translates to:
  /// **'Standard link to movie database'**
  String get standardLinkToMovieDatabase;

  /// Explore label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreLabel;

  /// Quote character attribution
  ///
  /// In en, this message translates to:
  /// **'— {character}'**
  String quoteCharacter(String character);

  /// AI tonight watch feature
  ///
  /// In en, this message translates to:
  /// **'AI Tonight Watch'**
  String get aiTonightWatch;

  /// AI query plan label
  ///
  /// In en, this message translates to:
  /// **'AI query plan'**
  String get aiQueryPlan;

  /// Airing today section
  ///
  /// In en, this message translates to:
  /// **'Airing Today'**
  String get airingToday;

  /// Explore section subtitle
  ///
  /// In en, this message translates to:
  /// **'Big crowd-pleasers with strong momentum'**
  String get bigCrowdPleasers;

  /// Mood label
  ///
  /// In en, this message translates to:
  /// **'Cinematic'**
  String get cinematic;

  /// Coming soon section
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Explore section subtitle
  ///
  /// In en, this message translates to:
  /// **'Current theatrical slate and near-future releases'**
  String get currentTheatricalSlate;

  /// Mood label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Discover spotlight title
  ///
  /// In en, this message translates to:
  /// **'Discover Spotlight'**
  String get discoverSpotlight;

  /// Mood label
  ///
  /// In en, this message translates to:
  /// **'Edge-of-your-seat'**
  String get edgeOfYourSeat;

  /// Mood label
  ///
  /// In en, this message translates to:
  /// **'Fast-paced'**
  String get fastPaced;

  /// Mood label
  ///
  /// In en, this message translates to:
  /// **'Feel-good'**
  String get feelGood;

  /// Explore section subtitle
  ///
  /// In en, this message translates to:
  /// **'Fresh picks updated continuously'**
  String get freshPicksContinuous;

  /// Hide title dialog title
  ///
  /// In en, this message translates to:
  /// **'Hide Title'**
  String get hideTitle;

  /// Explore section subtitle
  ///
  /// In en, this message translates to:
  /// **'High-rated titles most viewers skip'**
  String get highRatedSkipped;

  /// Explore section subtitle
  ///
  /// In en, this message translates to:
  /// **'Hot now across the audience feed'**
  String get hotNowAudience;

  /// In theaters section
  ///
  /// In en, this message translates to:
  /// **'In Theaters'**
  String get inTheaters;

  /// Mood label
  ///
  /// In en, this message translates to:
  /// **'Indie'**
  String get indie;

  /// Mood label
  ///
  /// In en, this message translates to:
  /// **'Mind-bending'**
  String get mindBending;

  /// Explore section subtitle
  ///
  /// In en, this message translates to:
  /// **'Most discussed shows this week'**
  String get mostDiscussedShowsThisWeek;

  /// Multiple picks feature chip
  ///
  /// In en, this message translates to:
  /// **'Multiple picks'**
  String get multiplePicks;

  /// On the air section
  ///
  /// In en, this message translates to:
  /// **'On The Air'**
  String get onTheAir;

  /// Explore section subtitle
  ///
  /// In en, this message translates to:
  /// **'Personalized from your watch behavior'**
  String get personalizedFromWatchBehavior;

  /// Explore section subtitle
  ///
  /// In en, this message translates to:
  /// **'Pick a vibe and get instant matching titles'**
  String get pickAVibe;

  /// See all button
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Explore section subtitle
  ///
  /// In en, this message translates to:
  /// **'Series currently airing with active episodes'**
  String get seriesCurrentlyAiring;

  /// This week filter
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Top rated section
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// Voice input feature chip
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInput;

  /// Match percentage
  ///
  /// In en, this message translates to:
  /// **'{matchPct}% Match'**
  String matchPercent(String matchPct);

  /// Runtime in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String runtimeMinutes(String minutes);

  /// Example prompt hint
  ///
  /// In en, this message translates to:
  /// **'Example: Something like Interstellar, but not sci-fi.'**
  String get examplePrompt;

  /// Finding recommendations loading
  ///
  /// In en, this message translates to:
  /// **'Finding your perfect watch{dots}'**
  String findingYourPerfectWatch(String dots);

  /// More like this button
  ///
  /// In en, this message translates to:
  /// **'More like this'**
  String get moreLikeThis;

  /// Not for me button
  ///
  /// In en, this message translates to:
  /// **'Not for me'**
  String get notForMe;

  /// Recent queries section
  ///
  /// In en, this message translates to:
  /// **'Recent queries'**
  String get recentQueries;

  /// Shuffling ideas loading
  ///
  /// In en, this message translates to:
  /// **'Shuffling ideas...'**
  String get shufflingIdeas;

  /// Too mainstream button
  ///
  /// In en, this message translates to:
  /// **'Too mainstream'**
  String get tooMainstream;

  /// Tonight feature title
  ///
  /// In en, this message translates to:
  /// **'What should I watch tonight?'**
  String get whatShouldIWatchTonight;

  /// Debug log entry
  ///
  /// In en, this message translates to:
  /// **'[{time}] {message}'**
  String debugLogEntry(String time, String message);

  /// From filter label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// To filter label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Removed from watchlist with countdown
  ///
  /// In en, this message translates to:
  /// **'Removed from watchlist ({seconds} s)'**
  String removedFromWatchlistCountdown(int seconds);

  /// Person credits count
  ///
  /// In en, this message translates to:
  /// **'{count} Credits'**
  String creditsCount(String count);

  /// Across filmography label
  ///
  /// In en, this message translates to:
  /// **'Across filmography'**
  String get acrossFilmography;

  /// Birthplace label
  ///
  /// In en, this message translates to:
  /// **'Birthplace'**
  String get birthplace;

  /// Born label
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get born;

  /// Credits label
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// Died label
  ///
  /// In en, this message translates to:
  /// **'Died'**
  String get died;

  /// Known for label
  ///
  /// In en, this message translates to:
  /// **'Known For'**
  String get knownFor;

  /// No shared titles available
  ///
  /// In en, this message translates to:
  /// **'No shared titles available.'**
  String get noSharedTitlesAvailable;

  /// Photos section
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// Rating column header
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get personRating;

  /// Tagged images section
  ///
  /// In en, this message translates to:
  /// **'Tagged Images'**
  String get taggedImages;

  /// Website link
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No quotes found
  ///
  /// In en, this message translates to:
  /// **'No quotes found.'**
  String get noQuotesFound;

  /// No sections found
  ///
  /// In en, this message translates to:
  /// **'No sections found.'**
  String get noSectionsFound;

  /// Clear all button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No collections found
  ///
  /// In en, this message translates to:
  /// **'No collections found'**
  String get noCollectionsFound;

  /// No companies found
  ///
  /// In en, this message translates to:
  /// **'No companies found'**
  String get noCompaniesFound;

  /// No keywords found
  ///
  /// In en, this message translates to:
  /// **'No keywords found'**
  String get noKeywordsFound;

  /// No more search results
  ///
  /// In en, this message translates to:
  /// **'No more results found.'**
  String get noMoreResultsFound;

  /// No search results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Delete list confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {listName}?'**
  String deleteListConfirmation(String listName);

  /// Delete list dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete List?'**
  String get deleteListTitle;

  /// Watchlist section description
  ///
  /// In en, this message translates to:
  /// **'Everything you plan to watch next.'**
  String get everythingYouPlanToWatch;

  /// Watched section description
  ///
  /// In en, this message translates to:
  /// **'Finished titles plus your history and stats.'**
  String get finishedTitlesAndHistory;

  /// No lists created
  ///
  /// In en, this message translates to:
  /// **'No lists created yet.'**
  String get noListsCreatedYet;

  /// Localized string for noNotesFound
  ///
  /// In en, this message translates to:
  /// **'No notes found'**
  String get noNotesFound;

  /// Rename list dialog title
  ///
  /// In en, this message translates to:
  /// **'Rename List'**
  String get renameList;

  /// Favourites section description
  ///
  /// In en, this message translates to:
  /// **'The titles you never want to lose.'**
  String get titlesYouNeverWantToLose;

  /// Notes section description
  ///
  /// In en, this message translates to:
  /// **'Your thoughts, reactions, and reminders.'**
  String get yourThoughtsReactions;

  /// Image counter
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String imageCounter(String current, String total);

  /// Remove from watched confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this from your watched list?'**
  String get removeFromWatchedConfirmation;

  /// Saved as watched without rating
  ///
  /// In en, this message translates to:
  /// **'This will be saved as watched without a personal rating.'**
  String get savedAsWatchedWithoutRating;

  /// No recommendation trailers
  ///
  /// In en, this message translates to:
  /// **'No additional recommendation trailers were found.'**
  String get noAdditionalRecommendationTrailers;

  /// Shared list items count
  ///
  /// In en, this message translates to:
  /// **'{count} {itemLabel}'**
  String sharedListItemsCount(int count, String itemLabel);

  /// Invalid shared list link
  ///
  /// In en, this message translates to:
  /// **'The link may be invalid, expired, or no longer accessible.'**
  String get invalidSharedListLink;

  /// No titles to import
  ///
  /// In en, this message translates to:
  /// **'There are no titles available to import.'**
  String get noTitlesAvailableToImport;

  /// Language name: All Languages
  ///
  /// In en, this message translates to:
  /// **'All Languages'**
  String get allLanguages;

  /// Language name: Arabic
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Language name: Bengali
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// Language name: Chinese
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// Language name: English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Language name: French
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Language name: German
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Language name: Gujarati
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get gujarati;

  /// Language name: Hindi
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// Language name: Indonesian
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// Language name: Italian
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// Language name: Japanese
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// Language name: Kannada
  ///
  /// In en, this message translates to:
  /// **'Kannada'**
  String get kannada;

  /// Language name: Korean
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// Language name: Malayalam
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get malayalam;

  /// Language name: Marathi
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get marathi;

  /// Language name: Persian
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get persian;

  /// Language name: Polish
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get polish;

  /// Language name: Portuguese
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// Language name: Punjabi
  ///
  /// In en, this message translates to:
  /// **'Punjabi'**
  String get punjabi;

  /// Language name: Russian
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// Language name: Spanish
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Language name: Swedish
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get swedish;

  /// Language name: Tamil
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// Language name: Telugu
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// Language name: Thai
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get thai;

  /// Language name: Turkish
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// Language name: Urdu
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// Language name: Vietnamese
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// Localized string for failedToLoadCollectionDetails
  ///
  /// In en, this message translates to:
  /// **'Failed to load collection details'**
  String get failedToLoadCollectionDetails;

  /// Localized string for franchiseProgress
  ///
  /// In en, this message translates to:
  /// **'Franchise Progress'**
  String get franchiseProgress;

  /// Localized string for officialSite
  ///
  /// In en, this message translates to:
  /// **'Official Site'**
  String get officialSite;

  /// Localized string for productions
  ///
  /// In en, this message translates to:
  /// **'Productions'**
  String get productions;

  /// Localized string for productionCompany
  ///
  /// In en, this message translates to:
  /// **'Production Company'**
  String get productionCompany;

  /// Localized string for failedToLoadCompanyInfo
  ///
  /// In en, this message translates to:
  /// **'Failed to load company info'**
  String get failedToLoadCompanyInfo;

  /// Localized string for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Localized string for guestViewer
  ///
  /// In en, this message translates to:
  /// **'Guest Viewer'**
  String get guestViewer;

  /// Localized string for yourProfileSyncStateRegionPreferences
  ///
  /// In en, this message translates to:
  /// **'Your profile, sync state, region, and visual preferences all live here.'**
  String get yourProfileSyncStateRegionPreferences;

  /// Localized string for signInToSync
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your watchlist, ratings, and preferences.'**
  String get signInToSync;

  /// Localized string for signedInAndSyncing
  ///
  /// In en, this message translates to:
  /// **'Signed in and syncing to the cloud.'**
  String get signedInAndSyncing;

  /// Localized string for developedBy
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// Localized string for couldNotAnalyzeWatchHistory
  ///
  /// In en, this message translates to:
  /// **'Could not analyze watch history right now.'**
  String get couldNotAnalyzeWatchHistory;

  /// Localized string for includeLocalLibrary
  ///
  /// In en, this message translates to:
  /// **'Include Local Library'**
  String get includeLocalLibrary;

  /// Localized string for useCloudOnly
  ///
  /// In en, this message translates to:
  /// **'Use Cloud Only'**
  String get useCloudOnly;

  /// Localized string for localLibrarySyncDescription
  ///
  /// In en, this message translates to:
  /// **'This device already has local library titles. Include them in your signed-in library, or replace local library data with your cloud library.'**
  String get localLibrarySyncDescription;

  /// Localized string for mergedLocalTitles
  ///
  /// In en, this message translates to:
  /// **'Merged local titles into your signed-in library.'**
  String get mergedLocalTitles;

  /// Localized string for replacedLocalLibrary
  ///
  /// In en, this message translates to:
  /// **'Replaced local library data with your cloud library.'**
  String get replacedLocalLibrary;

  /// Localized string for deleteAccountConfirmation
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your Lumi account and synced cloud data. Local data on this device will remain unless you remove the app data separately.'**
  String get deleteAccountConfirmation;

  /// Localized string for signedOutAndCleared
  ///
  /// In en, this message translates to:
  /// **'Signed out and cleared the local library on this device.'**
  String get signedOutAndCleared;

  /// Localized string for keepLocalLibrary
  ///
  /// In en, this message translates to:
  /// **'Keep Local Library'**
  String get keepLocalLibrary;

  /// Localized string for clearLocalLibrary
  ///
  /// In en, this message translates to:
  /// **'Clear Local Library'**
  String get clearLocalLibrary;

  /// Localized string for signOutChoiceDescription
  ///
  /// In en, this message translates to:
  /// **'Choose whether to keep the local library on this device after signing out.'**
  String get signOutChoiceDescription;

  /// Localized string for disable
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// Localized string for aiRecommendationsEnabled
  ///
  /// In en, this message translates to:
  /// **'AI recommendations data sharing enabled.'**
  String get aiRecommendationsEnabled;

  /// Localized string for aiRecommendationsDisabled
  ///
  /// In en, this message translates to:
  /// **'AI recommendations data sharing disabled.'**
  String get aiRecommendationsDisabled;

  /// Localized string for reviewAndManageConsent
  ///
  /// In en, this message translates to:
  /// **'Review and manage consent for sending library data to AI providers.'**
  String get reviewAndManageConsent;

  /// Localized string for aiRecommendationsEnabledSubtitle
  ///
  /// In en, this message translates to:
  /// **'Enabled. Recommend Tonight may send your library summary and recent queries to AI providers.'**
  String get aiRecommendationsEnabledSubtitle;

  /// Localized string for basedOnWatchedTitles
  ///
  /// In en, this message translates to:
  /// **'Based on {count} watched titles'**
  String basedOnWatchedTitles(String count);

  /// Localized string for lastUpdated
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// Localized string for chooseYourVibe
  ///
  /// In en, this message translates to:
  /// **'Choose your vibe'**
  String get chooseYourVibe;

  /// Localized string for appearanceDescription
  ///
  /// In en, this message translates to:
  /// **'Swap the app between cinematic personalities without changing any behavior.'**
  String get appearanceDescription;

  /// Localized string for exitAppConfirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit Lumi?'**
  String get exitAppConfirmation;

  /// Localized string for dismiss
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Localized string for generatingWatchAnalytics
  ///
  /// In en, this message translates to:
  /// **'Generating Watch Analytics'**
  String get generatingWatchAnalytics;

  /// Localized string for thisUsuallyTakesAFewSeconds
  ///
  /// In en, this message translates to:
  /// **'This usually takes a few seconds.'**
  String get thisUsuallyTakesAFewSeconds;

  /// Localized string for yourScreenStory
  ///
  /// In en, this message translates to:
  /// **'Your Screen Story'**
  String get yourScreenStory;

  /// Localized string for snapshotOfHowAndWhatYouWatch
  ///
  /// In en, this message translates to:
  /// **'A snapshot of how and what you watch'**
  String get snapshotOfHowAndWhatYouWatch;

  /// Localized string for yourFavoriteGenres
  ///
  /// In en, this message translates to:
  /// **'Your Favorite Genres'**
  String get yourFavoriteGenres;

  /// Localized string for genrePerformanceHighestRated
  ///
  /// In en, this message translates to:
  /// **'Genre Performance (Highest Rated)'**
  String get genrePerformanceHighestRated;

  /// Localized string for personalizedViewingPatterns
  ///
  /// In en, this message translates to:
  /// **'Personalized viewing patterns'**
  String get personalizedViewingPatterns;

  /// Localized string for builtWithLumi
  ///
  /// In en, this message translates to:
  /// **'Built with Lumi'**
  String get builtWithLumi;

  /// Localized string for sharedWithLumi
  ///
  /// In en, this message translates to:
  /// **'Shared with Lumi'**
  String get sharedWithLumi;

  /// Localized string for shareAnalytics
  ///
  /// In en, this message translates to:
  /// **'Share Analytics'**
  String get shareAnalytics;

  /// Localized string for analyzedTitlesUpdated
  ///
  /// In en, this message translates to:
  /// **'Analyzed {count} titles • Updated {date}'**
  String analyzedTitlesUpdated(String count, String date);

  /// Localized string for allSeasons
  ///
  /// In en, this message translates to:
  /// **'All Seasons'**
  String get allSeasons;

  /// Localized string for castAndCrew
  ///
  /// In en, this message translates to:
  /// **'Cast & Crew'**
  String get castAndCrew;

  /// Localized string for featuredCrew
  ///
  /// In en, this message translates to:
  /// **'Featured Crew'**
  String get featuredCrew;

  /// Localized string for stills
  ///
  /// In en, this message translates to:
  /// **'Stills'**
  String get stills;

  /// Localized string for accoladeSummary
  ///
  /// In en, this message translates to:
  /// **'Accolade Summary'**
  String get accoladeSummary;

  /// Localized string for awardsAndAccolades
  ///
  /// In en, this message translates to:
  /// **'Awards & Accolades'**
  String get awardsAndAccolades;

  /// Localized string for unableToLoadMovieDetails
  ///
  /// In en, this message translates to:
  /// **'Unable to load movie details'**
  String get unableToLoadMovieDetails;

  /// Localized string for overviewUnavailable
  ///
  /// In en, this message translates to:
  /// **'Overview unavailable for this title.'**
  String get overviewUnavailable;

  /// Localized string for openCompletePlot
  ///
  /// In en, this message translates to:
  /// **'Open complete plot and extra metadata from OMDb.'**
  String get openCompletePlot;

  /// Localized string for noOverviewForSeason
  ///
  /// In en, this message translates to:
  /// **'No overview available for this season.'**
  String get noOverviewForSeason;

  /// Localized string for userScore
  ///
  /// In en, this message translates to:
  /// **'User Score'**
  String get userScore;

  /// Localized string for playTrailer
  ///
  /// In en, this message translates to:
  /// **'Play Trailer'**
  String get playTrailer;

  /// Localized string for whereToWatch
  ///
  /// In en, this message translates to:
  /// **'Where to Watch'**
  String get whereToWatch;

  /// Localized string for availabilityDataByJustWatch
  ///
  /// In en, this message translates to:
  /// **'Availability data by JustWatch.'**
  String get availabilityDataByJustWatch;

  /// Localized string for reminderSaved
  ///
  /// In en, this message translates to:
  /// **'Reminder saved'**
  String get reminderSaved;

  /// Localized string for reminderForTitle
  ///
  /// In en, this message translates to:
  /// **'Reminder for {title}'**
  String reminderForTitle(String title);

  /// Localized string for pleaseSelectFutureTime
  ///
  /// In en, this message translates to:
  /// **'Please select a future time'**
  String get pleaseSelectFutureTime;

  /// Localized string for notifyAt
  ///
  /// In en, this message translates to:
  /// **'Notify at'**
  String get notifyAt;

  /// Localized string for notifyHoursBeforeAiring
  ///
  /// In en, this message translates to:
  /// **'Notify how many hours before airing?'**
  String get notifyHoursBeforeAiring;

  /// Localized string for enterNumberBetween
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 1 and {maxHours}'**
  String enterNumberBetween(String maxHours);

  /// Localized string for set
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// Localized string for selectedReminderTimePassed
  ///
  /// In en, this message translates to:
  /// **'Selected reminder time has already passed'**
  String get selectedReminderTimePassed;

  /// Localized string for episodeReminderSaved
  ///
  /// In en, this message translates to:
  /// **'Episode reminder saved for {date}'**
  String episodeReminderSaved(String date);

  /// Localized string for areYouSureDeleteNote
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get areYouSureDeleteNote;

  /// Localized string for noteAdded
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get noteAdded;

  /// Localized string for lastSeason
  ///
  /// In en, this message translates to:
  /// **'Last Season'**
  String get lastSeason;

  /// Localized string for currentSeason
  ///
  /// In en, this message translates to:
  /// **'Current Season'**
  String get currentSeason;

  /// Localized string for viewAllSeasons
  ///
  /// In en, this message translates to:
  /// **'View All Seasons'**
  String get viewAllSeasons;

  /// Localized string for removedFromFavourites
  ///
  /// In en, this message translates to:
  /// **'Removed from Favourites'**
  String get removedFromFavourites;

  /// Localized string for addedToFavourites
  ///
  /// In en, this message translates to:
  /// **'Added to Favourites'**
  String get addedToFavourites;

  /// Localized string for awardsAndNominations
  ///
  /// In en, this message translates to:
  /// **'Awards & Nominations'**
  String get awardsAndNominations;

  /// Localized string for viewAll
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Localized string for boxOfficeFinancials
  ///
  /// In en, this message translates to:
  /// **'Box Office Financials'**
  String get boxOfficeFinancials;

  /// Localized string for successMeter
  ///
  /// In en, this message translates to:
  /// **'Success Meter'**
  String get successMeter;

  /// Localized string for blockbuster
  ///
  /// In en, this message translates to:
  /// **'BLOCKBUSTER'**
  String get blockbuster;

  /// Localized string for hit
  ///
  /// In en, this message translates to:
  /// **'HIT'**
  String get hit;

  /// Localized string for breakEven
  ///
  /// In en, this message translates to:
  /// **'BREAK-EVEN'**
  String get breakEven;

  /// Localized string for underperformer
  ///
  /// In en, this message translates to:
  /// **'UNDERPERFORMER'**
  String get underperformer;

  /// Localized string for boxOfficeBomb
  ///
  /// In en, this message translates to:
  /// **'BOX OFFICE BOMB'**
  String get boxOfficeBomb;

  /// Localized string for episodeTracker
  ///
  /// In en, this message translates to:
  /// **'Episode Tracker'**
  String get episodeTracker;

  /// Localized string for setAiringReminder
  ///
  /// In en, this message translates to:
  /// **'Set airing reminder'**
  String get setAiringReminder;

  /// Localized string for nextEpisodeCountdown
  ///
  /// In en, this message translates to:
  /// **'Next Episode Countdown'**
  String get nextEpisodeCountdown;

  /// Localized string for nextEpisode
  ///
  /// In en, this message translates to:
  /// **'Next episode'**
  String get nextEpisode;

  /// Localized string for lastEpisodeToAir
  ///
  /// In en, this message translates to:
  /// **'Last Episode To Air'**
  String get lastEpisodeToAir;

  /// Localized string for unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Localized string for contentAdvisory
  ///
  /// In en, this message translates to:
  /// **'Content Advisory'**
  String get contentAdvisory;

  /// Localized string for violence
  ///
  /// In en, this message translates to:
  /// **'Violence'**
  String get violence;

  /// Localized string for sexAndNudity
  ///
  /// In en, this message translates to:
  /// **'Sex & Nudity'**
  String get sexAndNudity;

  /// Localized string for foulLanguage
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get foulLanguage;

  /// Localized string for substances
  ///
  /// In en, this message translates to:
  /// **'Substances'**
  String get substances;

  /// Localized string for fearAndHorror
  ///
  /// In en, this message translates to:
  /// **'Fear & Horror'**
  String get fearAndHorror;

  /// Localized string for familyFriendly
  ///
  /// In en, this message translates to:
  /// **'Family Friendly'**
  String get familyFriendly;

  /// Localized string for generalAudience
  ///
  /// In en, this message translates to:
  /// **'General Audience'**
  String get generalAudience;

  /// Localized string for releaseTimeline
  ///
  /// In en, this message translates to:
  /// **'Release Timeline'**
  String get releaseTimeline;

  /// Localized string for notifyMe
  ///
  /// In en, this message translates to:
  /// **'Notify Me'**
  String get notifyMe;

  /// Localized string for theatricalRelease
  ///
  /// In en, this message translates to:
  /// **'Theatrical Release'**
  String get theatricalRelease;

  /// Localized string for digitalStreaming
  ///
  /// In en, this message translates to:
  /// **'Digital / Streaming'**
  String get digitalStreaming;

  /// Localized string for physicalRelease
  ///
  /// In en, this message translates to:
  /// **'Physical (Blu-ray / DVD)'**
  String get physicalRelease;

  /// Localized string for awesome
  ///
  /// In en, this message translates to:
  /// **'Awesome'**
  String get awesome;

  /// Localized string for keywordsAndThemes
  ///
  /// In en, this message translates to:
  /// **'Keywords & Themes'**
  String get keywordsAndThemes;

  /// Localized string for videosAndBehindTheScenes
  ///
  /// In en, this message translates to:
  /// **'Videos & Behind-the-Scenes'**
  String get videosAndBehindTheScenes;

  /// Localized string for productionStudios
  ///
  /// In en, this message translates to:
  /// **'Production Studios'**
  String get productionStudios;

  /// Localized string for fetchingWatchLink
  ///
  /// In en, this message translates to:
  /// **'Fetching watch link'**
  String get fetchingWatchLink;

  /// Localized string for findingBestProviderPage
  ///
  /// In en, this message translates to:
  /// **'Finding the best provider page for this title.'**
  String get findingBestProviderPage;

  /// Localized string for episodeCode
  ///
  /// In en, this message translates to:
  /// **'S{season}E{episode} '**
  String episodeCode(String season, String episode);

  /// Localized string for error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Localized string for failedToLoadSeasonDetails
  ///
  /// In en, this message translates to:
  /// **'Failed to load season details'**
  String get failedToLoadSeasonDetails;

  /// Localized string for loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Localized string for runtimeSeparator
  ///
  /// In en, this message translates to:
  /// **'• {runtime}'**
  String runtimeSeparator(String runtime);

  /// Localized string for fullCastAndCrew
  ///
  /// In en, this message translates to:
  /// **'Full Cast & Crew'**
  String get fullCastAndCrew;

  /// Localized string for shareMovie
  ///
  /// In en, this message translates to:
  /// **'Share Movie'**
  String get shareMovie;

  /// Localized string for quotes
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quotes;

  /// Localized string for mayIncludeMismatches
  ///
  /// In en, this message translates to:
  /// **'May include occasional mismatches due to lexical quote search.'**
  String get mayIncludeMismatches;

  /// Localized string for movieApiConfigurationRequired
  ///
  /// In en, this message translates to:
  /// **'Movie API configuration required'**
  String get movieApiConfigurationRequired;

  /// Localized string for addMovieProxyBaseUrl
  ///
  /// In en, this message translates to:
  /// **'Add MOVIE_PROXY_BASE_URL to connect the app to the TMDB proxy.'**
  String get addMovieProxyBaseUrl;

  /// Localized string for cinematicPicksContext
  ///
  /// In en, this message translates to:
  /// **'Cinematic picks with instant vibe context. Roll for another surprise card.'**
  String get cinematicPicksContext;

  /// Localized string for curatedTonight
  ///
  /// In en, this message translates to:
  /// **'Curated Tonight'**
  String get curatedTonight;

  /// Localized string for curatedTonightTitle
  ///
  /// In en, this message translates to:
  /// **'Curated Tonight: {title}'**
  String curatedTonightTitle(String title);

  /// Localized string for describeItYourWay
  ///
  /// In en, this message translates to:
  /// **'Describe it your way.\nWe find the best matches.'**
  String get describeItYourWay;

  /// Localized string for hide
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// Localized string for hideTitleDescription
  ///
  /// In en, this message translates to:
  /// **'Hiding this title will prevent it from appearing in the Spotlight section in the future.'**
  String get hideTitleDescription;

  /// Localized string for dontAskAgain
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask again'**
  String get dontAskAgain;

  /// Localized string for imdbNa
  ///
  /// In en, this message translates to:
  /// **'IMDb NA'**
  String get imdbNa;

  /// Localized string for noDiscoverPicks
  ///
  /// In en, this message translates to:
  /// **'No discover picks available right now.'**
  String get noDiscoverPicks;

  /// Localized string for playPreview
  ///
  /// In en, this message translates to:
  /// **'Play Preview'**
  String get playPreview;

  /// Localized string for recommendedForYou
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// Localized string for spotlightCompleted
  ///
  /// In en, this message translates to:
  /// **'Spotlight Completed'**
  String get spotlightCompleted;

  /// Localized string for startAddingTitlesForRecommendations
  ///
  /// In en, this message translates to:
  /// **'Start adding titles for recommendations'**
  String get startAddingTitlesForRecommendations;

  /// Localized string for clearedAllChoices
  ///
  /// In en, this message translates to:
  /// **'You have swiped and cleared all choices in your discover feed.'**
  String get clearedAllChoices;

  /// Localized string for whatsPopular
  ///
  /// In en, this message translates to:
  /// **'What\'s Popular'**
  String get whatsPopular;

  /// Localized string for trending
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// Localized string for nowPlaying
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// Localized string for tvTrending
  ///
  /// In en, this message translates to:
  /// **'TV Trending'**
  String get tvTrending;

  /// Localized string for discoverByMood
  ///
  /// In en, this message translates to:
  /// **'Discover by Mood'**
  String get discoverByMood;

  /// Localized string for needSomethingToWatchTonight
  ///
  /// In en, this message translates to:
  /// **'Need something to watch tonight?'**
  String get needSomethingToWatchTonight;

  /// Localized string for needAMovieForTonight
  ///
  /// In en, this message translates to:
  /// **'Need a movie for tonight?'**
  String get needAMovieForTonight;

  /// Localized string for tryAiShows
  ///
  /// In en, this message translates to:
  /// **'Try AI Shows'**
  String get tryAiShows;

  /// Localized string for tryAiMovies
  ///
  /// In en, this message translates to:
  /// **'Try AI Movies'**
  String get tryAiMovies;

  /// Localized string for findShows
  ///
  /// In en, this message translates to:
  /// **'Find Shows'**
  String get findShows;

  /// Localized string for findMovies
  ///
  /// In en, this message translates to:
  /// **'Find Movies'**
  String get findMovies;

  /// Localized string for couldNotLoadThisRail
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this rail'**
  String get couldNotLoadThisRail;

  /// Localized string for temporaryIssueLoadingRail
  ///
  /// In en, this message translates to:
  /// **'There was a temporary issue loading this rail.'**
  String get temporaryIssueLoadingRail;

  /// Localized string for noTitlesHereYet
  ///
  /// In en, this message translates to:
  /// **'No titles here yet'**
  String get noTitlesHereYet;

  /// Localized string for noHiddenGemsForGenre
  ///
  /// In en, this message translates to:
  /// **'No hidden gems found for this genre yet. Try another genre.'**
  String get noHiddenGemsForGenre;

  /// Localized string for tryAnotherFilter
  ///
  /// In en, this message translates to:
  /// **'Try another filter or open this section for broader discovery.'**
  String get tryAnotherFilter;

  /// Localized string for seeAllFilters
  ///
  /// In en, this message translates to:
  /// **'See all filters'**
  String get seeAllFilters;

  /// Localized string for couldNotLoadCuratedPicks
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load curated picks'**
  String get couldNotLoadCuratedPicks;

  /// Localized string for temporaryIssueLoadingCurated
  ///
  /// In en, this message translates to:
  /// **'There was a temporary issue loading tonight\'s curated list.'**
  String get temporaryIssueLoadingCurated;

  /// Localized string for noCuratedPicksAvailable
  ///
  /// In en, this message translates to:
  /// **'No curated picks available'**
  String get noCuratedPicksAvailable;

  /// Localized string for tryAgainWhileRefresh
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment while we refresh tonight\'s TMDB list.'**
  String get tryAgainWhileRefresh;

  /// Localized string for fromSpotlight
  ///
  /// In en, this message translates to:
  /// **'From Spotlight'**
  String get fromSpotlight;

  /// Localized string for addShowsMoviesForRecommendations
  ///
  /// In en, this message translates to:
  /// **'Add TV shows/movies to your watchlist, favourites, or watched list to see titles you might love.'**
  String get addShowsMoviesForRecommendations;

  /// Localized string for allow
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// Localized string for notNow
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Localized string for allowAiDataSharingTitle
  ///
  /// In en, this message translates to:
  /// **'Allow AI data sharing?'**
  String get allowAiDataSharingTitle;

  /// Localized string for allowAiDataSharingDescription
  ///
  /// In en, this message translates to:
  /// **'Recommend Tonight sends the text you type for a movie recommendation request and temporary query-refinement context to Google Gemini and OpenRouter. Your full library and your sign-in credentials are not sent to those AI providers. Allow this data sharing for AI recommendations?'**
  String get allowAiDataSharingDescription;

  /// Localized string for liveProgress
  ///
  /// In en, this message translates to:
  /// **'Live progress'**
  String get liveProgress;

  /// Localized string for percentComplete
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(String percent);

  /// Localized string for describeIdealShowNight
  ///
  /// In en, this message translates to:
  /// **'Describe your ideal show night'**
  String get describeIdealShowNight;

  /// Localized string for describeIdealMovieNight
  ///
  /// In en, this message translates to:
  /// **'Describe your ideal movie night'**
  String get describeIdealMovieNight;

  /// Localized string for useNaturalLanguage
  ///
  /// In en, this message translates to:
  /// **'Use natural language. Mention what you want, what to avoid, and optional language/runtime hints.'**
  String get useNaturalLanguage;

  /// Localized string for listeningTapMicToStop
  ///
  /// In en, this message translates to:
  /// **'Listening... tap mic again to stop.'**
  String get listeningTapMicToStop;

  /// Localized string for voiceInputError
  ///
  /// In en, this message translates to:
  /// **'Voice input error: {error}'**
  String voiceInputError(String error);

  /// Localized string for tapMicToDictate
  ///
  /// In en, this message translates to:
  /// **'Tap mic to dictate your request.'**
  String get tapMicToDictate;

  /// Localized string for tapMicToEnableVoice
  ///
  /// In en, this message translates to:
  /// **'Tap mic to enable voice input.'**
  String get tapMicToEnableVoice;

  /// Localized string for findingShows
  ///
  /// In en, this message translates to:
  /// **'Finding Shows...'**
  String get findingShows;

  /// Localized string for findingMovies
  ///
  /// In en, this message translates to:
  /// **'Finding Movies...'**
  String get findingMovies;

  /// Localized string for tonightsLumiPicksFor
  ///
  /// In en, this message translates to:
  /// **'Tonight\'s Lumi picks for: {prompt}'**
  String tonightsLumiPicksFor(String prompt);

  /// Localized string for tonightsPicks
  ///
  /// In en, this message translates to:
  /// **'Tonight\'s Picks'**
  String get tonightsPicks;

  /// Localized string for sharedFromLumi
  ///
  /// In en, this message translates to:
  /// **'Shared from Lumi'**
  String get sharedFromLumi;

  /// Localized string for intent
  ///
  /// In en, this message translates to:
  /// **'Intent:'**
  String get intent;

  /// Localized string for genreLabel
  ///
  /// In en, this message translates to:
  /// **'Genre:'**
  String get genreLabel;

  /// Localized string for avoid
  ///
  /// In en, this message translates to:
  /// **'Avoid:'**
  String get avoid;

  /// Localized string for languageLabel
  ///
  /// In en, this message translates to:
  /// **'Language:'**
  String get languageLabel;

  /// Localized string for runtimeAtMost
  ///
  /// In en, this message translates to:
  /// **'Runtime <= {minutes} min'**
  String runtimeAtMost(String minutes);

  /// Localized string for runtimeAtLeast
  ///
  /// In en, this message translates to:
  /// **'Runtime >= {minutes} min'**
  String runtimeAtLeast(String minutes);

  /// Localized string for yearLabel
  ///
  /// In en, this message translates to:
  /// **'Year:'**
  String get yearLabel;

  /// Localized string for yearAfter
  ///
  /// In en, this message translates to:
  /// **'After {year}'**
  String yearAfter(String year);

  /// Localized string for yearBefore
  ///
  /// In en, this message translates to:
  /// **'Before {year}'**
  String yearBefore(String year);

  /// Localized string for like
  ///
  /// In en, this message translates to:
  /// **'Like:'**
  String get like;

  /// Localized string for signal
  ///
  /// In en, this message translates to:
  /// **'Signal:'**
  String get signal;

  /// Localized string for readingWatchedHistory
  ///
  /// In en, this message translates to:
  /// **'Reading your watched history...'**
  String get readingWatchedHistory;

  /// Localized string for findingTopGenres
  ///
  /// In en, this message translates to:
  /// **'Finding your top genres and patterns...'**
  String get findingTopGenres;

  /// Localized string for buildingTrends
  ///
  /// In en, this message translates to:
  /// **'Building monthly and rating trends...'**
  String get buildingTrends;

  /// Localized string for writingInsights
  ///
  /// In en, this message translates to:
  /// **'Writing your personalized insights...'**
  String get writingInsights;

  /// Localized string for applyFilters
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// Localized string for includeNotRated
  ///
  /// In en, this message translates to:
  /// **'Include Not Rated'**
  String get includeNotRated;

  /// Localized string for errorLoadingTvGenres
  ///
  /// In en, this message translates to:
  /// **'Error loading TV genres'**
  String get errorLoadingTvGenres;

  /// Localized string for alsoKnownAs
  ///
  /// In en, this message translates to:
  /// **'Also Known As'**
  String get alsoKnownAs;

  /// Localized string for biography
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biography;

  /// Localized string for careerStatistics
  ///
  /// In en, this message translates to:
  /// **'Career Statistics'**
  String get careerStatistics;

  /// Localized string for frequentlyCollaboratesWith
  ///
  /// In en, this message translates to:
  /// **'Frequently Collaborates With'**
  String get frequentlyCollaboratesWith;

  /// Localized string for notableQuotes
  ///
  /// In en, this message translates to:
  /// **'Notable Quotes'**
  String get notableQuotes;

  /// Localized string for primaryRole
  ///
  /// In en, this message translates to:
  /// **'Primary Role'**
  String get primaryRole;

  /// Localized string for averageRating
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// Localized string for topGenre
  ///
  /// In en, this message translates to:
  /// **'Top Genre'**
  String get topGenre;

  /// Localized string for peakBoxOffice
  ///
  /// In en, this message translates to:
  /// **'Peak Box Office'**
  String get peakBoxOffice;

  /// Localized string for percentOfTitles
  ///
  /// In en, this message translates to:
  /// **'{percent}% of titles'**
  String percentOfTitles(String percent);

  /// Localized string for sharedTitleCount
  ///
  /// In en, this message translates to:
  /// **'{count} shared title(s)'**
  String sharedTitleCount(String count);

  /// Localized string for billingOrder
  ///
  /// In en, this message translates to:
  /// **'Billed #{order}'**
  String billingOrder(String order);

  /// Localized string for startTypingToSearch
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get startTypingToSearch;

  /// Localized string for movieDiscoveryMadePersonal
  ///
  /// In en, this message translates to:
  /// **'Movie discovery, made personal'**
  String get movieDiscoveryMadePersonal;

  /// Localized string for allNotes
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get allNotes;

  /// Localized string for viewPersonalizedInsights
  ///
  /// In en, this message translates to:
  /// **'View personalized insights, charts, and trends.'**
  String get viewPersonalizedInsights;

  /// Localized string for curatedCollections
  ///
  /// In en, this message translates to:
  /// **'Curated collections'**
  String get curatedCollections;

  /// Localized string for list
  ///
  /// In en, this message translates to:
  /// **'list'**
  String get list;

  /// Localized string for openList
  ///
  /// In en, this message translates to:
  /// **'Open list'**
  String get openList;

  /// Localized string for thisListNoLongerExists
  ///
  /// In en, this message translates to:
  /// **'This list no longer exists'**
  String get thisListNoLongerExists;

  /// Localized string for listRenamed
  ///
  /// In en, this message translates to:
  /// **'List renamed to {name}'**
  String listRenamed(String name);

  /// Localized string for listDeleted
  ///
  /// In en, this message translates to:
  /// **'List {name} deleted'**
  String listDeleted(String name);

  /// Localized string for noFilterInWatchlist
  ///
  /// In en, this message translates to:
  /// **'No {filter} in your watchlist'**
  String noFilterInWatchlist(String filter);

  /// Localized string for noFilterInFavourites
  ///
  /// In en, this message translates to:
  /// **'No {filter} in your favourites'**
  String noFilterInFavourites(String filter);

  /// Localized string for noFilterInWatched
  ///
  /// In en, this message translates to:
  /// **'No {filter} in watched'**
  String noFilterInWatched(String filter);

  /// Localized string for noFilterInThisList
  ///
  /// In en, this message translates to:
  /// **'No {filter} in this list'**
  String noFilterInThisList(String filter);

  /// Localized string for noListsWithFilter
  ///
  /// In en, this message translates to:
  /// **'No lists with {filter}'**
  String noListsWithFilter(String filter);

  /// Localized string for importedInto
  ///
  /// In en, this message translates to:
  /// **'Imported into \"{name}\"'**
  String importedInto(String name);

  /// Localized string for couldNotImportList
  ///
  /// In en, this message translates to:
  /// **'Could not import list'**
  String get couldNotImportList;

  /// Localized string for importing
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// Localized string for couldNotLoadSharedList
  ///
  /// In en, this message translates to:
  /// **'Could not load this shared list'**
  String get couldNotLoadSharedList;

  /// Localized string for editWatchedInfo
  ///
  /// In en, this message translates to:
  /// **'Edit Watched Info'**
  String get editWatchedInfo;

  /// Localized string for watchDate
  ///
  /// In en, this message translates to:
  /// **'Watch Date'**
  String get watchDate;

  /// Localized string for rewatchCount
  ///
  /// In en, this message translates to:
  /// **'Rewatch Count'**
  String get rewatchCount;

  /// Localized string for watchedInfoUpdated
  ///
  /// In en, this message translates to:
  /// **'Watched info updated'**
  String get watchedInfoUpdated;

  /// Localized string for removedFromList
  ///
  /// In en, this message translates to:
  /// **'Removed from {listName}'**
  String removedFromList(String listName);

  /// Localized string for addedToList
  ///
  /// In en, this message translates to:
  /// **'Added to {listName}'**
  String addedToList(String listName);

  /// Localized string for addedToListAndWatchlist
  ///
  /// In en, this message translates to:
  /// **'Added to {listName} and Watchlist'**
  String addedToListAndWatchlist(String listName);

  /// Localized string for moreTrailersLikeThis
  ///
  /// In en, this message translates to:
  /// **'More Trailers Like This'**
  String get moreTrailersLikeThis;

  /// Localized string for noDescriptionForTrailer
  ///
  /// In en, this message translates to:
  /// **'No description available for this trailer.'**
  String get noDescriptionForTrailer;

  /// Localized string for closeTrailer
  ///
  /// In en, this message translates to:
  /// **'Close trailer'**
  String get closeTrailer;

  /// Localized string for recommendedSeries
  ///
  /// In en, this message translates to:
  /// **'Recommended Series'**
  String get recommendedSeries;

  /// Localized string for recommendedMovie
  ///
  /// In en, this message translates to:
  /// **'Recommended Movie'**
  String get recommendedMovie;

  /// Localized string for notEnoughDataYet
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get notEnoughDataYet;

  /// Localized string for addAndRateMoreTitles
  ///
  /// In en, this message translates to:
  /// **'Add and rate at least {count} titles to unlock analytics.'**
  String addAndRateMoreTitles(String count);

  /// Localized string for addMoreTitlesToUnlock
  ///
  /// In en, this message translates to:
  /// **'You have {watchedCount}/{requiredCount} watched titles. Add {remaining} more to unlock analytics.'**
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  );

  /// Localized string for moviesPerMonth
  ///
  /// In en, this message translates to:
  /// **'Movies Per Month'**
  String get moviesPerMonth;

  /// Localized string for genreDistribution
  ///
  /// In en, this message translates to:
  /// **'Genre Distribution'**
  String get genreDistribution;

  /// Localized string for ratingTrends
  ///
  /// In en, this message translates to:
  /// **'Rating Trends'**
  String get ratingTrends;

  /// Localized string for noData
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// Localized string for myLatestWatchAnalytics
  ///
  /// In en, this message translates to:
  /// **'My latest watch analytics on Lumi'**
  String get myLatestWatchAnalytics;

  /// Localized string for myWatchInsights
  ///
  /// In en, this message translates to:
  /// **'My watch insights on Lumi'**
  String get myWatchInsights;

  /// Localized string for infographicsCard
  ///
  /// In en, this message translates to:
  /// **'Infographics Card'**
  String get infographicsCard;

  /// Localized string for watchInsightsSnapshot
  ///
  /// In en, this message translates to:
  /// **'Watch Insights Snapshot'**
  String get watchInsightsSnapshot;

  /// Localized string for availableOnceInsightsReady
  ///
  /// In en, this message translates to:
  /// **'Available once insights are ready'**
  String get availableOnceInsightsReady;

  /// Localized string for shareYourWatchInsights
  ///
  /// In en, this message translates to:
  /// **'Share your watch insights card'**
  String get shareYourWatchInsights;

  /// Localized string for recentlyWatchedVibe
  ///
  /// In en, this message translates to:
  /// **'Recently Watched Vibe'**
  String get recentlyWatchedVibe;

  /// Localized string for mixedAcrossGenres
  ///
  /// In en, this message translates to:
  /// **'Mixed across genres'**
  String get mixedAcrossGenres;

  /// Localized string for moviesPerMonthShort
  ///
  /// In en, this message translates to:
  /// **'Movies / Month'**
  String get moviesPerMonthShort;

  /// Localized string for ratingTrend
  ///
  /// In en, this message translates to:
  /// **'Rating Trend'**
  String get ratingTrend;

  /// Localized string for balanced
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// Localized string for noWatchNextSuggestionsYet
  ///
  /// In en, this message translates to:
  /// **'No watch-next suggestions yet'**
  String get noWatchNextSuggestionsYet;

  /// Localized string for upcomingFromLibrary
  ///
  /// In en, this message translates to:
  /// **'Upcoming from your library'**
  String get upcomingFromLibrary;

  /// Localized string for removeReminder
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get removeReminder;

  /// Localized string for remindMe
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// Localized string for titleReleasesToday
  ///
  /// In en, this message translates to:
  /// **'{title} releases today.'**
  String titleReleasesToday(String title);

  /// Localized string for titleAirsSoon
  ///
  /// In en, this message translates to:
  /// **'{title} {subtitle} airs soon.'**
  String titleAirsSoon(String title, String subtitle);

  /// Localized string for controlPremiereAlerts
  ///
  /// In en, this message translates to:
  /// **'Control premiere alerts and release reminders.'**
  String get controlPremiereAlerts;

  /// Localized string for upcomingReleasesCount
  ///
  /// In en, this message translates to:
  /// **'{count} upcoming release(s) across your library.'**
  String upcomingReleasesCount(String count);

  /// Localized string for sittingInWatchlist
  ///
  /// In en, this message translates to:
  /// **'Sitting in your watchlist for {days} days'**
  String sittingInWatchlist(String days);

  /// Localized string for alreadyOnWatchlist
  ///
  /// In en, this message translates to:
  /// **'Already on your watchlist'**
  String get alreadyOnWatchlist;

  /// Localized string for favouritedButNotWatched
  ///
  /// In en, this message translates to:
  /// **'You favourited this but have not marked it watched yet'**
  String get favouritedButNotWatched;

  /// Localized string for savedInListReady
  ///
  /// In en, this message translates to:
  /// **'Saved in one of your lists and ready to watch'**
  String get savedInListReady;

  /// Localized string for matchesTitlesYouTrack
  ///
  /// In en, this message translates to:
  /// **'Matches titles you already track'**
  String get matchesTitlesYouTrack;

  /// Localized string for noOfficialSite
  ///
  /// In en, this message translates to:
  /// **'No official site'**
  String get noOfficialSite;

  /// Localized string for episodeAiring
  ///
  /// In en, this message translates to:
  /// **'Episode Airing'**
  String get episodeAiring;

  /// Localized string for general
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Localized string for scheduledFor
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {date}'**
  String scheduledFor(String date);

  /// Localized string for wasScheduledFor
  ///
  /// In en, this message translates to:
  /// **'Was scheduled for {date}'**
  String wasScheduledFor(String date);

  /// Localized string for noOverviewAvailable
  ///
  /// In en, this message translates to:
  /// **'No overview available.'**
  String get noOverviewAvailable;

  /// Localized string for searchHistoryCleared
  ///
  /// In en, this message translates to:
  /// **'Search history cleared'**
  String get searchHistoryCleared;

  /// Localized string for visualMovieCard
  ///
  /// In en, this message translates to:
  /// **'Visual Movie Card'**
  String get visualMovieCard;

  /// Localized string for smartLumiLink
  ///
  /// In en, this message translates to:
  /// **'Smart Lumi Link'**
  String get smartLumiLink;

  /// Localized string for directTmdbLink
  ///
  /// In en, this message translates to:
  /// **'Direct TMDB Link'**
  String get directTmdbLink;

  /// Localized string for recommendedOnLumi
  ///
  /// In en, this message translates to:
  /// **'Recommended on Lumi: {title}'**
  String recommendedOnLumi(String title);

  /// Localized string for checkOutOnLumi
  ///
  /// In en, this message translates to:
  /// **'Check out {title} on Lumi!\n\n{link}\n\nGet Lumi: {appLink}'**
  String checkOutOnLumi(String title, String link, String appLink);

  /// Localized string for checkOutOnTmdb
  ///
  /// In en, this message translates to:
  /// **'Check out {title} on TMDB: {link}'**
  String checkOutOnTmdb(String title, String link);

  /// Localized string for releaseAlertTitle
  ///
  /// In en, this message translates to:
  /// **'{title} release alert'**
  String releaseAlertTitle(String title);

  /// Localized string for releaseAlertFullMessage
  ///
  /// In en, this message translates to:
  /// **'Release watch alert set for {date}. We will notify you when it is out.'**
  String releaseAlertFullMessage(String date);

  /// Localized string for releaseSuccessDialogContent
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you as soon as \"{title}\" is released digitally or on Blu-ray/DVD!'**
  String releaseSuccessDialogContent(String title);

  /// Localized string for episodeAlreadyDueToAir
  ///
  /// In en, this message translates to:
  /// **'This episode is already due to air'**
  String get episodeAlreadyDueToAir;

  /// Localized string for reminderSetSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Reminder set successfully'**
  String get reminderSetSuccessfully;

  /// Localized string for speechRecognitionNotAvailable
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available on this device.'**
  String get speechRecognitionNotAvailable;

  /// Localized string for describeShowMood
  ///
  /// In en, this message translates to:
  /// **'Describe what show you are in the mood for, and we will return a ranked list.'**
  String get describeShowMood;

  /// Localized string for describeMovieMood
  ///
  /// In en, this message translates to:
  /// **'Describe what movie you are in the mood for, and we will return a ranked list.'**
  String get describeMovieMood;

  /// Localized string for aiLauncherDescription
  ///
  /// In en, this message translates to:
  /// **'Type or speak a natural-language request. Lumi builds an AI plan, runs vector search, and returns multiple show/movie picks.'**
  String get aiLauncherDescription;

  /// Localized string for yearRange
  ///
  /// In en, this message translates to:
  /// **'{from}-{to}'**
  String yearRange(String from, String to);

  /// Localized string for remindersCountScheduled
  ///
  /// In en, this message translates to:
  /// **'{count} reminder(s) scheduled.'**
  String remindersCountScheduled(String count);

  /// Localized string for regionAutoDetected
  ///
  /// In en, this message translates to:
  /// **'Auto-detected: {region}'**
  String regionAutoDetected(String region);

  /// Localized string for regionSelected
  ///
  /// In en, this message translates to:
  /// **'Selected: {region}'**
  String regionSelected(String region);

  /// Localized string for allLanguagesSubtitle
  ///
  /// In en, this message translates to:
  /// **'All languages'**
  String get allLanguagesSubtitle;

  /// Localized string for currentlySetToLanguage
  ///
  /// In en, this message translates to:
  /// **'Currently set to {language}'**
  String currentlySetToLanguage(String language);

  /// Localized string for availabilities
  ///
  /// In en, this message translates to:
  /// **'Availabilities'**
  String get availabilities;

  /// Localized string for mood
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// Localized string for people
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// Localized string for ads
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get ads;

  /// Localized string for theatricalLimited
  ///
  /// In en, this message translates to:
  /// **'Theatrical Limited'**
  String get theatricalLimited;

  /// Localized string for premier
  ///
  /// In en, this message translates to:
  /// **'Premier'**
  String get premier;

  /// Localized string for mediaType
  ///
  /// In en, this message translates to:
  /// **'Media Type'**
  String get mediaType;

  /// Localized string for couldNotLoadAnalytics
  ///
  /// In en, this message translates to:
  /// **'Could not load analytics'**
  String get couldNotLoadAnalytics;

  /// Localized string for viewAllAwards
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllAwards;

  /// Localized string for win
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get win;

  /// Localized string for wins
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// Localized string for nomination
  ///
  /// In en, this message translates to:
  /// **'Nomination'**
  String get nomination;

  /// Localized string for nominations
  ///
  /// In en, this message translates to:
  /// **'Nominations'**
  String get nominations;

  /// Localized string for sharedBy
  ///
  /// In en, this message translates to:
  /// **'Shared by {name}'**
  String sharedBy(String name);

  /// Localized string for titleCount
  ///
  /// In en, this message translates to:
  /// **'{count} title(s)'**
  String titleCount(String count);

  /// Localized string for savedTitlesAcrossLists
  ///
  /// In en, this message translates to:
  /// **'{count} saved titles across your lists'**
  String savedTitlesAcrossLists(String count);

  /// Localized string for curatedCollectionsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Curated collections you can organize and share.'**
  String get curatedCollectionsSubtitle;

  /// Localized string for shareListMessage
  ///
  /// In en, this message translates to:
  /// **'Import \"{name}\" into Lumi ({count} {itemLabel}): {link}'**
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  );

  /// Localized string for notEnoughData
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get notEnoughData;

  /// Localized string for shareQuote
  ///
  /// In en, this message translates to:
  /// **'Check out this quote from \"{title}\" on Lumi!'**
  String shareQuote(String title);

  /// Localized string for shareMovieMessage
  ///
  /// In en, this message translates to:
  /// **'Recommended on Lumi: {title}\n\n{link}'**
  String shareMovieMessage(String title, String link);

  /// Localized string for aiLauncherDescriptionShow
  ///
  /// In en, this message translates to:
  /// **'Type or speak a natural-language request. Lumi builds an AI plan, runs vector search, and returns multiple show picks.'**
  String get aiLauncherDescriptionShow;

  /// Localized string for aiLauncherDescriptionMovie
  ///
  /// In en, this message translates to:
  /// **'Type or speak a natural-language request. Lumi builds an AI plan, runs vector search, and returns multiple movie picks.'**
  String get aiLauncherDescriptionMovie;

  /// Localized string for warmingUpMovieSearch
  ///
  /// In en, this message translates to:
  /// **'Warming up your movie search'**
  String get warmingUpMovieSearch;

  /// Localized string for connectingToRecommendationEngine
  ///
  /// In en, this message translates to:
  /// **'Connecting to the recommendation engine'**
  String get connectingToRecommendationEngine;

  /// Localized string for understandingYourTaste
  ///
  /// In en, this message translates to:
  /// **'Understanding what you are in the mood for'**
  String get understandingYourTaste;

  /// Localized string for buildingCustomSearch
  ///
  /// In en, this message translates to:
  /// **'Building a custom search from your request'**
  String get buildingCustomSearch;

  /// Localized string for tinyNetworkHiccup
  ///
  /// In en, this message translates to:
  /// **'Tiny network hiccup, trying again'**
  String get tinyNetworkHiccup;

  /// Localized string for planLocked
  ///
  /// In en, this message translates to:
  /// **'Plan locked: genre, style, language, and runtime'**
  String get planLocked;

  /// Localized string for scanningTmdb
  ///
  /// In en, this message translates to:
  /// **'Scanning TMDB for strong matches'**
  String get scanningTmdb;

  /// Localized string for collectingDetails
  ///
  /// In en, this message translates to:
  /// **'Collecting posters, ratings, and runtime for top picks'**
  String get collectingDetails;

  /// Localized string for shortlistingPicksCount
  ///
  /// In en, this message translates to:
  /// **'Shortlisting picks ({current}/{total})'**
  String shortlistingPicksCount(String current, String total);

  /// Localized string for shortlistingBestPicks
  ///
  /// In en, this message translates to:
  /// **'Shortlisting the best picks'**
  String get shortlistingBestPicks;

  /// Localized string for finalPolish
  ///
  /// In en, this message translates to:
  /// **'Final polish on your recommendations'**
  String get finalPolish;

  /// Localized string for retryingAfterIssue
  ///
  /// In en, this message translates to:
  /// **'Retrying after a temporary issue'**
  String get retryingAfterIssue;

  /// Region label for United States
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get regionUnitedStates;

  /// Region label for India
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get regionIndia;

  /// Region label for United Kingdom
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get regionUnitedKingdom;

  /// Region label for Canada
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get regionCanada;

  /// Region label for Australia
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get regionAustralia;

  /// Region label for New Zealand
  ///
  /// In en, this message translates to:
  /// **'New Zealand'**
  String get regionNewZealand;

  /// Region label for Germany
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get regionGermany;

  /// Region label for France
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get regionFrance;

  /// Region label for Spain
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get regionSpain;

  /// Region label for Italy
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get regionItaly;

  /// Region label for Japan
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get regionJapan;

  /// Region label for South Korea
  ///
  /// In en, this message translates to:
  /// **'South Korea'**
  String get regionSouthKorea;

  /// Region label for Brazil
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get regionBrazil;

  /// Region label for Mexico
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get regionMexico;

  /// Region label for Singapore
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get regionSingapore;

  /// Region label for Philippines
  ///
  /// In en, this message translates to:
  /// **'Philippines'**
  String get regionPhilippines;

  /// Region label for Indonesia
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get regionIndonesia;

  /// Region label for United Arab Emirates
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates'**
  String get regionUnitedArabEmirates;

  /// Region label for Saudi Arabia
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get regionSaudiArabia;

  /// Region label for Turkey
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get regionTurkey;

  /// Subtitle when region is auto-detected
  ///
  /// In en, this message translates to:
  /// **'Auto-detected region: {regionLabel} ({regionCode}). Select a region to override for localized movie queries and watch-provider lookups.'**
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode);

  /// Subtitle when region is manually selected
  ///
  /// In en, this message translates to:
  /// **'Selected region: {regionLabel} ({regionCode}). Supported movie queries and watch-provider lookups will reuse this automatically next time.'**
  String regionSelectedSubtitle(String regionLabel, String regionCode);

  /// Tooltip prompting sign in to sync library
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync with cloud'**
  String get syncSignInTooltip;

  /// Tooltip shown when library sync failed
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Tap to retry.'**
  String get syncFailedTooltip;

  /// Tooltip shown when library is synced
  ///
  /// In en, this message translates to:
  /// **'Library synced with cloud'**
  String get syncedTooltip;

  /// Tooltip to share a quote
  ///
  /// In en, this message translates to:
  /// **'Share quote'**
  String get shareQuoteTooltip;

  /// Tooltip to copy a quote
  ///
  /// In en, this message translates to:
  /// **'Copy quote'**
  String get copyQuoteTooltip;

  /// Toast message after copying a quote
  ///
  /// In en, this message translates to:
  /// **'Quote copied to clipboard'**
  String get quoteCopiedToast;

  /// Tooltip to share a dialogue
  ///
  /// In en, this message translates to:
  /// **'Share dialogue'**
  String get shareDialogueTooltip;

  /// Tooltip to copy a dialogue
  ///
  /// In en, this message translates to:
  /// **'Copy dialogue'**
  String get copyDialogueTooltip;

  /// Toast message after copying a dialogue
  ///
  /// In en, this message translates to:
  /// **'Dialogue copied to clipboard'**
  String get dialogueCopiedToast;

  /// Notification title for a TV episode airing in one hour
  ///
  /// In en, this message translates to:
  /// **'{title} airs in 1 hour'**
  String tvAirsInOneHourTitle(String title);

  /// Notification body for a TV episode airing in one hour
  ///
  /// In en, this message translates to:
  /// **'{episodeLabel} \"{episodeName}\" airs at {localAirTime}.'**
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  );

  /// Notification title for a movie releasing today
  ///
  /// In en, this message translates to:
  /// **'{title} releases today'**
  String movieReleasesTodayTitle(String title);

  /// Notification body for a movie releasing today
  ///
  /// In en, this message translates to:
  /// **'A movie in your library is releasing on {localDate}.'**
  String movieReleasesTodayBody(String localDate);

  /// Curated collection title
  ///
  /// In en, this message translates to:
  /// **'Neo-noir Nights'**
  String get curatedNeoNoirNights;

  /// Curated collection title
  ///
  /// In en, this message translates to:
  /// **'Pulse-Pounding Rush'**
  String get curatedPulsePoundingRush;

  /// Curated collection title
  ///
  /// In en, this message translates to:
  /// **'Feel-Good Escape'**
  String get curatedFeelGoodEscape;

  /// Curated collection title
  ///
  /// In en, this message translates to:
  /// **'Mind-Benders'**
  String get curatedMindBenders;

  /// Curated collection title
  ///
  /// In en, this message translates to:
  /// **'Epic Worlds'**
  String get curatedEpicWorlds;

  /// Curated collection title
  ///
  /// In en, this message translates to:
  /// **'Human Stories'**
  String get curatedHumanStories;

  /// Curated collection title
  ///
  /// In en, this message translates to:
  /// **'Dark Detective Files'**
  String get curatedDarkDetectiveFiles;

  /// Curated collection description
  ///
  /// In en, this message translates to:
  /// **'Rain-soaked tension, morally gray leads, and atmospheric city stories.'**
  String get curatedNeoNoirNightsDescription;

  /// Curated collection description
  ///
  /// In en, this message translates to:
  /// **'High-stakes chases, escalating danger, and no-time-to-breathe pacing.'**
  String get curatedPulsePoundingRushDescription;

  /// Curated collection description
  ///
  /// In en, this message translates to:
  /// **'Warm stories, uplifting arcs, and comforting picks for a relaxed night.'**
  String get curatedFeelGoodEscapeDescription;

  /// Curated collection description
  ///
  /// In en, this message translates to:
  /// **'Reality-warping concepts, twisty plotting, and big-idea storytelling.'**
  String get curatedMindBendersDescription;

  /// Curated collection description
  ///
  /// In en, this message translates to:
  /// **'Big-universe adventures, mythic stakes, and cinematic scale.'**
  String get curatedEpicWorldsDescription;

  /// Curated collection description
  ///
  /// In en, this message translates to:
  /// **'Character-first dramas with emotional pull and memorable performances.'**
  String get curatedHumanStoriesDescription;

  /// Curated collection description
  ///
  /// In en, this message translates to:
  /// **'Cold clues, layered suspects, and slow-burn investigations.'**
  String get curatedDarkDetectiveFilesDescription;

  /// App language setting title
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// Label for using the system language
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get appLanguageSystemDefault;

  /// Subtitle when an app language is selected
  ///
  /// In en, this message translates to:
  /// **'App language set to {language}. This only changes the app interface, not the movie and show language.'**
  String appLanguageSelectedSubtitle(String language);

  /// Subtitle when app language follows system
  ///
  /// In en, this message translates to:
  /// **'App language follows your device settings. Change it to keep the interface in a different language.'**
  String get appLanguageSystemSubtitle;

  /// Subtitle when content language is set to all languages
  ///
  /// In en, this message translates to:
  /// **'All languages. Movies and TV tabs stay broad, while Explore can still prefer stronger local fits when available.'**
  String get contentLanguageAllSubtitle;

  /// Subtitle when a specific content language is selected
  ///
  /// In en, this message translates to:
  /// **'Currently set to {language}. Movies and TV tabs will stay strict, while Explore will prefer this language first.'**
  String contentLanguageSelectedSubtitle(String language);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'gu',
    'hi',
    'it',
    'ja',
    'kn',
    'ko',
    'ml',
    'mr',
    'pa',
    'pt',
    'ru',
    'ta',
    'te',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
