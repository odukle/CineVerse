// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Люми';

  @override
  String get navExplore => 'Исследовать';

  @override
  String get navMovies => 'Фильмы';

  @override
  String get navTvShows => 'Телепередачи';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navAccount => 'Учетная запись';

  @override
  String get searchHint => 'Поиск фильмов, телепередач, компаний...';

  @override
  String get searchForPerson => 'Поиск человека...';

  @override
  String get searchLanguages => 'Поиск языков';

  @override
  String get searchNameOrRole => 'Поиск по имени или роли...';

  @override
  String get retry => 'Повторить';

  @override
  String get tryAgain => 'Повторить попытку';

  @override
  String get clear => 'Очистить';

  @override
  String get cancel => 'Отмена';

  @override
  String get ok => 'ХОРОШО';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get share => 'Поделиться';

  @override
  String get undo => 'Отменить';

  @override
  String get close => 'Закрыть';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String get done => 'Готово';

  @override
  String get signInWithGoogle => 'Войти с помощью Google';

  @override
  String get signInWithApple => 'Войти с помощью Apple';

  @override
  String get signOut => 'Выйти';

  @override
  String get deleteAccount => 'Удалить учетную запись';

  @override
  String get accountDeletedSuccessfully => 'Учетная запись успешно удалена.';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get appearanceSubtitle =>
      'Выберите тему и настройте внешний вид приложения.';

  @override
  String get notifications => 'Уведомления';

  @override
  String get releaseCalendar => 'Календарь выпусков';

  @override
  String get hiddenTitles => 'Скрытые заголовки';

  @override
  String get aiRecommendationsPrivacy => 'Рекомендации AI Конфиденциальность';

  @override
  String get contentRegion => 'Регион контента';

  @override
  String get contentLanguage => 'Язык контента';

  @override
  String get watchlist => 'Список наблюдения';

  @override
  String get notes => 'Примечания';

  @override
  String get deleteNote => 'Удалить примечание';

  @override
  String get addNoteHint => 'Добавить примечание...';

  @override
  String get addBriefNoteHint =>
      'Добавьте краткое примечание (необязательно)...';

  @override
  String get enterNewName => 'Введите новое имя...';

  @override
  String get importSharedList => 'Импортировать общий список';

  @override
  String get discoverOnLumi => 'УЗНАЙТЕ О LUMI';

  @override
  String get filtered => 'Отфильтровано';

  @override
  String get fullPlot => 'Полный сюжет';

  @override
  String get userReviews => 'Отзывы пользователей';

  @override
  String get noReviewsYet => 'Обзоров пока нет.';

  @override
  String get openInYouTube => 'Открыть на YouTube';

  @override
  String get hiddenGems => 'Скрытые жемчужины';

  @override
  String get resetSpotlight => 'Сбросить прожектор';

  @override
  String get clearPreferences => 'Очистить предпочтения';

  @override
  String get refreshPicks => 'Обновить выбор';

  @override
  String get shareBoard => 'Поделиться доской';

  @override
  String get exploreDetails => 'Изучить детали';

  @override
  String get searchWikiquotes => 'Поиск в Викицитатах';

  @override
  String get selectAQuote => 'Выбрать цитату';

  @override
  String get tooltipShareQuote => 'Поделиться цитатой';

  @override
  String get tooltipCopyQuote => 'Копировать цитату';

  @override
  String get tooltipShareDialogue => 'Поделиться диалогом';

  @override
  String get tooltipCopyDialogue => 'Копировать диалог';

  @override
  String get tooltipUnhide => 'Показать';

  @override
  String get tooltipOpenPrivacyPolicy => 'Открыть политику конфиденциальности';

  @override
  String get tooltipRefreshInsights => 'Обновить информацию';

  @override
  String get tooltipSortTitles => 'Сортировать заголовки';

  @override
  String get tooltipSearch => 'Поиск';

  @override
  String get tooltipFilters => 'Фильтры';

  @override
  String get tooltipSaveToGallery => 'Сохранить в галерее';

  @override
  String get tooltipShare => 'Поделиться';

  @override
  String get tooltipShareAnalytics => 'Поделиться аналитикой';

  @override
  String get tooltipSetAiringReminder =>
      'Установить напоминание о выходе в эфир';

  @override
  String get tooltipLibrarySynced => 'Библиотека синхронизирована с облаком';

  @override
  String get noMoreEntries => 'Больше нет записей';

  @override
  String get noItemsFound => 'Товары не найдены';

  @override
  String errorLoadingGenres(String error) {
    return 'Ошибка загрузки жанров: $error';
  }

  @override
  String errorGeneric(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get errorLoadingLists => 'Ошибка загрузки списков';

  @override
  String errorLoadingQuotes(Object error) {
    return 'Не удалось загрузить кавычки: $error';
  }

  @override
  String get errorCouldNotShareAnalytics =>
      'Не удалось поделиться карточкой аналитики.';

  @override
  String get errorCouldNotShareRecommendations =>
      'Не удалось поделиться доской рекомендаций.';

  @override
  String get errorCouldNotShareInsights =>
      'Не удалось поделиться информацией о часах.';

  @override
  String get watchInsightsNotReady => 'Статистика просмотра еще не готова.';

  @override
  String titleRestoredToSpotlight(String title) {
    return '\"$title\" восстановлен в Spotlight';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '\"$title\" скрыт';
  }

  @override
  String hiddenDate(String date) {
    return 'Скрыто: $date';
  }

  @override
  String get moviesInThisCollection => 'Фильмы в этой коллекции';

  @override
  String get searchPlanReady => 'План поиска готов';

  @override
  String get hoursBeforeAirTime => 'За несколько часов до эфира';

  @override
  String get noUpcomingReleases => 'Предстоящих выпусков нет';

  @override
  String get noRemindersSet => 'Напоминаний не установлено';

  @override
  String get noHiddenTitles => 'Скрытых названий нет';

  @override
  String get hiddenTitlesDescription =>
      'Скрытые вами названия из раздела «В центре внимания» появятся здесь, и вы сможете восстановить их в любое время.';

  @override
  String get tvShow => 'ТВ-ШОУ';

  @override
  String get movie => 'ФИЛЬМ';

  @override
  String get aiConsentGranted =>
      'Вы согласились. Данные вашей библиотеки используются для персонализации рекомендаций.';

  @override
  String get aiConsentNotGranted =>
      'Данные вашей библиотеки никогда не будут переданы, если вы не дадите на это свое согласие.';

  @override
  String get languageSettingExplanation =>
      'Вкладки «Фильмы» и «ТВ» используют это строго. Explore предпочитает его первым и отступает, когда рельс становится редким.';

  @override
  String get filterScreenTitle => 'Фильтры';

  @override
  String get sortBy => 'Сортировка по';

  @override
  String get genres => 'Жанры';

  @override
  String get year => 'Год';

  @override
  String get rating => 'Рейтинг';

  @override
  String get runtime => 'Время выполнения';

  @override
  String get withPeople => 'С людьми';

  @override
  String get voteCount => 'Подсчет голосов';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get yesterday => 'Вчера';

  @override
  String get minutes => 'мин';

  @override
  String get hours => 'ч';

  @override
  String get cast => 'В ролях';

  @override
  String get crew => 'Съемочная группа';

  @override
  String get director => 'Режиссер';

  @override
  String get seasons => 'Сезоны';

  @override
  String get episodes => 'Эпизоды';

  @override
  String get overview => 'Обзор';

  @override
  String get similar => 'Похожие';

  @override
  String get recommendations => 'Рекомендации';

  @override
  String get addedToWatchlist => 'Добавлено в список наблюдения';

  @override
  String get removedFromWatchlist => 'Удалено из списка наблюдения';

  @override
  String get popularity => 'Популярность';

  @override
  String get releaseDate => 'Дата выхода';

  @override
  String get revenueLabel => 'Доход';

  @override
  String get originalTitle => 'Оригинальное название';

  @override
  String get voteAverage => 'Среднее количество голосов';

  @override
  String get favourites => 'Избранное';

  @override
  String get lists => 'списки';

  @override
  String get watched => 'Наблюдал';

  @override
  String get all => 'Все';

  @override
  String get tv => 'ТВ';

  @override
  String get librarySubtitle =>
      'Организуйте все по коллекциям, избранным, заметкам и истории просмотров.';

  @override
  String get selectRegion => 'Выберите регион';

  @override
  String get selectRegionDescription =>
      'Этот параметр будет использоваться только в тех конечных точках TMDb, которые поддерживают запросы с учетом региона.';

  @override
  String get useAutoDetectedRegion =>
      'Использовать автоматически определенный регион';

  @override
  String get reminderRemoved => 'Напоминание удалено';

  @override
  String releaseReminderSet(String title) {
    return 'Установлено напоминание о выпуске для $title.';
  }

  @override
  String episodeReminderSet(String title) {
    return 'Установлено напоминание о серии для $title.';
  }

  @override
  String get filteredResults => 'Отфильтрованные результаты';

  @override
  String get genreResults => 'Результаты по жанрам';

  @override
  String couldNotLoadContent(String error) {
    return 'Не удалось загрузить содержимое. $error';
  }

  @override
  String get noContentAvailableForThisSelection =>
      'Для этого раздела нет доступного контента.';

  @override
  String get writer => 'Писатель';

  @override
  String get actors => 'Актеры';

  @override
  String get noteNotFound => 'Примечание не найдено.';

  @override
  String yourNotesCount(int count) {
    return 'Ваши заметки ($count)';
  }

  @override
  String get noteDeleted => 'Примечание удалено';

  @override
  String noteDeletedWithCount(int count) {
    return 'Примечание удалено ($count s)';
  }

  @override
  String get loadMore => 'Загрузить ещё';

  @override
  String get noMoreProductionsFound => 'Больше постановок не найдено.';

  @override
  String get noProductionsFound => 'Постановок не найдено.';

  @override
  String get watchInsights => 'Аналитические данные о просмотре';

  @override
  String get analyzingWatchHistory => 'Анализ истории ваших часов...';

  @override
  String get manageHiddenTitlesDescription =>
      'Управляйте заголовками, скрытыми из раздела «В центре внимания».';

  @override
  String get tmdbLanguageMetadataNote =>
      'В этом режиме некоторые разделы могут выглядеть разреженными, поскольку метаданные языка в базе данных TMDB неполны для некоторых частей каталога, а не обязательно потому, что этих названий не существует.';

  @override
  String get tmdbDisclaimer =>
      'Данный продукт использует API TMDB, но не одобрен и не сертифицирован TMDB.';

  @override
  String get useLocalLibraryForSync =>
      'Использовать локальную библиотеку для синхронизации?';

  @override
  String get themePresets => 'Предварительные настройки тем';

  @override
  String get exitApp => 'Выйти из приложения';

  @override
  String get popular => 'Популярный';

  @override
  String couldNotLoadReminders(String error) {
    return 'Не удалось загрузить напоминания.\n\n$error';
  }

  @override
  String get noRemindersSetYet =>
      'Напоминания пока не установлены.\nСоздайте напоминание в разделе «Отслеживание эпизодов» или «Подробная информация о фильме».';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return 'Эпизод S$seasonNumber • E$episodeNumber';
  }

  @override
  String get movieRelease => 'Выход фильма';

  @override
  String voteAverageStars(String voteAverage) {
    return 'Переведите название этого приложения на ru: $voteAverage ★';
  }

  @override
  String get addMoreTrackedContent =>
      'Добавьте больше фильмов или сериалов в свой список просмотра, избранное или списки.';

  @override
  String get fastPicksDescription =>
      'Быстрый выбор на основе уже сохраненных вами данных.';

  @override
  String get releaseCalendarDescription =>
      'Уведомления о выходе новых фильмов и следующих сериях телесериалов одним касанием.';

  @override
  String get staleWatchlist => 'Устаревший список наблюдения';

  @override
  String get tracked => 'Отслеживаемый';

  @override
  String get upcoming => 'Предстоящие';

  @override
  String get upcomingEmptyDescription =>
      'Когда у отслеживаемых фильмов появятся даты выхода или будут запланированы новые серии сериалов, они появятся здесь.';

  @override
  String get howManyMoviesWatchedEachMonth =>
      'Сколько фильмов вы смотрели каждый месяц?';

  @override
  String get howPersonalRatingsShifting =>
      'Как меняется ваш личный рейтинг с течением времени';

  @override
  String get keepWatchingToBuildProfile =>
      'Продолжайте смотреть, чтобы создать свой визуальный образ.';

  @override
  String get lumiWatchAnalytics => 'АНАЛИТИКА ЧАСОВ LUMI';

  @override
  String get noGenreDistributionYet =>
      'Информация о распределении по жанрам пока отсутствует.';

  @override
  String get noMovieWatchHistoryRecentMonths =>
      'История просмотров фильмов за последние месяцы отсутствует.';

  @override
  String get noRatingTrendDataYet =>
      'Данные о тенденциях изменения рейтингов пока недоступны.';

  @override
  String get preferredRuntime => 'Предпочтительная среда выполнения';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return 'Предпочтительное время выполнения составляет примерно $minutes минут ($label)';
  }

  @override
  String get styledCardWithWatchStats =>
      'Стильная карточка со статистикой ваших часов.';

  @override
  String get titlesAnalyzed => 'Проанализированные заголовки';

  @override
  String get tryAgainAfterMoment => 'Попробуйте еще раз через мгновение.';

  @override
  String get watchAnalytics => 'Аналитика часов';

  @override
  String get whatGenresDominateHistory =>
      'Какие жанры доминируют в вашей истории часов?';

  @override
  String get toggleMovies => 'Фильмы';

  @override
  String get toggleTv => 'ТВ';

  @override
  String get noMoreTitlesFound => 'Больше названий не найдено.';

  @override
  String get noTitlesFoundForKeyword =>
      'Заголовки по этому ключевому слову не найдены.';

  @override
  String get viewFull => 'Просмотреть полностью';

  @override
  String get accoladeDetails => 'Подробности о награде';

  @override
  String get noDetailedAwardsInfo =>
      'Подробная информация о наградах отсутствует.';

  @override
  String get alertSet => 'Установлено оповещение!';

  @override
  String get budget => 'Бюджет';

  @override
  String get buy => 'Купить';

  @override
  String chooseBetweenHours(int maxHours) {
    return 'Выберите один из вариантов: 1 или $maxHours';
  }

  @override
  String get deleteNoteConfirmationTitle => 'Удалить заметку?';

  @override
  String get episodeReminder => 'Напоминание об эпизоде';

  @override
  String get facebook => 'Фейсбук';

  @override
  String get free => 'Бесплатно';

  @override
  String get images => 'Изображения';

  @override
  String get instagram => 'Инстаграм';

  @override
  String get netProfit => 'Чистая прибыль';

  @override
  String get noNotesYet => 'Пока нет заметок. Добавьте свои мысли!';

  @override
  String get originalLanguage => 'Оригинальный язык';

  @override
  String partOfCollection(String collectionName) {
    return 'Часть $collectionName';
  }

  @override
  String get roi => 'ROI';

  @override
  String releaseAlertSet(String date) {
    return 'Установлено оповещение о выпуске обновления для $date.';
  }

  @override
  String get rent => 'Арендовать';

  @override
  String get revenue => 'Доход';

  @override
  String seeAllReviews(int count) {
    return 'Посмотреть все ($count)';
  }

  @override
  String get setReminder => 'Установить напоминание';

  @override
  String get status => 'Статус';

  @override
  String get stream => 'Транслировать';

  @override
  String get tikTok => 'ТикТок';

  @override
  String get twitterX => 'X';

  @override
  String get yours => 'ВАШ';

  @override
  String get youtube => 'YouTube';

  @override
  String get durationDays => 'д';

  @override
  String get durationHours => 'час';

  @override
  String get durationMinutes => 'м';

  @override
  String get durationSeconds => 'с';

  @override
  String seasonRating(String score) {
    return 'Переведите название этого приложения на ru: ★ $score%';
  }

  @override
  String get we => 'Мы';

  @override
  String get aspect16x9 => 'Переведите это название приложения на ru: 16:9';

  @override
  String get aspect9x16 => 'Переведите название этого приложения на ru: 9:16';

  @override
  String get background => 'Бг';

  @override
  String episodeCount(int count) {
    return '$count Эпс';
  }

  @override
  String get noEpisodesForSeason => 'Эпизоды этого сезона не найдены.';

  @override
  String get beautifulStyledCardForStories =>
      'Красиво оформленная открытка для публикаций в социальных сетях.';

  @override
  String get clickableShareLink =>
      'Кликабельная ссылка для обмена в WhatsApp и других приложениях.';

  @override
  String get placeQuoteOnBackdrop =>
      'Разместите свою любимую цитату на фоне экрана кинотеатра.';

  @override
  String get standardLinkToMovieDatabase =>
      'Стандартная ссылка на базу данных фильмов';

  @override
  String get exploreLabel => 'Исследовать';

  @override
  String quoteCharacter(String character) {
    return 'Переведите это название приложения на ru: — $character';
  }

  @override
  String get aiTonightWatch => 'ИИ Сегодняшний просмотр';

  @override
  String get aiQueryPlan => 'план выполнения запроса ИИ';

  @override
  String get airingToday => 'В эфире сегодня';

  @override
  String get bigCrowdPleasers => 'Популярные хиты с сильным импульсом';

  @override
  String get cinematic => 'Кинематографический';

  @override
  String get comingSoon => 'Вскоре';

  @override
  String get currentTheatricalSlate => 'Текущий прокат и ближайшие премьеры';

  @override
  String get dark => 'Темный';

  @override
  String get discoverSpotlight => 'Откройте для себя Spotlight';

  @override
  String get edgeOfYourSeat => 'Захватывающий дух';

  @override
  String get fastPaced => 'Быстрый темп';

  @override
  String get feelGood => 'Приятные ощущения';

  @override
  String get freshPicksContinuous => 'Подборка постоянно обновляется.';

  @override
  String get hideTitle => 'Скрыть заголовок';

  @override
  String get highRatedSkipped =>
      'Фильмы с высоким рейтингом, которые большинство зрителей пропускают';

  @override
  String get hotNowAudience => 'Сейчас в тренде в ленте аудитории';

  @override
  String get inTheaters => 'В кинотеатрах';

  @override
  String get indie => 'Инди';

  @override
  String get mindBending => 'Умопомрачительный';

  @override
  String get mostDiscussedShowsThisWeek =>
      'Самые обсуждаемые шоу на этой неделе';

  @override
  String get multiplePicks => 'Несколько выборов';

  @override
  String get onTheAir => 'В эфире';

  @override
  String get personalizedFromWatchBehavior =>
      'Персонализированные настройки на основе поведения ваших часов.';

  @override
  String get pickAVibe =>
      'Выберите настроение и мгновенно получите подходящие названия.';

  @override
  String get seeAll => 'Посмотреть все';

  @override
  String get seriesCurrentlyAiring =>
      'Сериал, который в настоящее время транслируется и имеет активные эпизоды.';

  @override
  String get thisWeek => 'На этой неделе';

  @override
  String get topRated => 'Лучший рейтинг';

  @override
  String get voiceInput => 'Голосовой ввод';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% Совпадение';
  }

  @override
  String runtimeMinutes(String minutes) {
    return '$minutes мин';
  }

  @override
  String get examplePrompt =>
      'Пример: Что-то вроде «Интерстеллара», но не научная фантастика.';

  @override
  String findingYourPerfectWatch(String dots) {
    return 'Как найти идеальные часы$dots';
  }

  @override
  String get moreLikeThis => 'Больше похожих товаров';

  @override
  String get notForMe => 'Не для меня';

  @override
  String get recentQueries => 'Последние запросы';

  @override
  String get shufflingIdeas => 'Перетасовка идей...';

  @override
  String get tooMainstream => 'Слишком мейнстрим';

  @override
  String get whatShouldIWatchTonight => 'Что мне посмотреть сегодня вечером?';

  @override
  String debugLogEntry(String time, String message) {
    return 'Переведите это название приложения на язык ru: [$time] $message';
  }

  @override
  String get from => 'От';

  @override
  String get to => 'К';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return 'Удалено из списка наблюдения ($seconds s)';
  }

  @override
  String creditsCount(String count) {
    return '$count Кредиты';
  }

  @override
  String get acrossFilmography => 'В рамках фильмографии';

  @override
  String get birthplace => 'Место рождения';

  @override
  String get born => 'Рожденный';

  @override
  String get credits => 'Кредиты';

  @override
  String get died => 'Умер';

  @override
  String get knownFor => 'Известен благодаря';

  @override
  String get noSharedTitlesAvailable =>
      'Нет доступных для совместного использования названий.';

  @override
  String get photos => 'Фотографии';

  @override
  String get personRating => 'Рейтинг';

  @override
  String get taggedImages => 'Изображения с тегами';

  @override
  String get website => 'Веб-сайт';

  @override
  String get noQuotesFound => 'Цитаты не найдены.';

  @override
  String get noSectionsFound => 'Разделы не найдены.';

  @override
  String get clearAll => 'Очистить все';

  @override
  String get noCollectionsFound => 'Коллекции не найдены';

  @override
  String get noCompaniesFound => 'Компании не найдены';

  @override
  String get noKeywordsFound => 'Ключевые слова не найдены';

  @override
  String get noMoreResultsFound => 'Результаты больше не найдены.';

  @override
  String get noResultsFound => 'Результаты не найдены';

  @override
  String deleteListConfirmation(String listName) {
    return 'Вы уверены, что хотите удалить $listName?';
  }

  @override
  String get deleteListTitle => 'Удалить список?';

  @override
  String get everythingYouPlanToWatch =>
      'Всё, что вы планируете посмотреть в дальнейшем.';

  @override
  String get finishedTitlesAndHistory =>
      'Завершенные игры, а также ваша история и статистика.';

  @override
  String get noListsCreatedYet => 'Списки пока не созданы.';

  @override
  String get noNotesFound => 'Заметки не найдены';

  @override
  String get renameList => 'Переименовать список';

  @override
  String get titlesYouNeverWantToLose =>
      'Титулы, которые вы никогда не захотите потерять.';

  @override
  String get yourThoughtsReactions => 'Ваши мысли, реакции и напоминания.';

  @override
  String imageCounter(String current, String total) {
    return 'Переведите название этого приложения на язык ru: $current / $total';
  }

  @override
  String get removeFromWatchedConfirmation =>
      'Вы уверены, что хотите удалить это из списка отслеживаемых?';

  @override
  String get savedAsWatchedWithoutRating =>
      'Это видео будет сохранено как просмотренное без личной оценки.';

  @override
  String get noAdditionalRecommendationTrailers =>
      'Дополнительные рекомендательные трейлеры не найдены.';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return 'Переведите это название приложения на ru: $count $itemLabel';
  }

  @override
  String get invalidSharedListLink =>
      'Ссылка может быть недействительной, устаревшей или недоступной.';

  @override
  String get noTitlesAvailableToImport =>
      'В настоящее время нет доступных для импорта названий.';

  @override
  String get allLanguages => 'Все языки';

  @override
  String get arabic => 'арабский';

  @override
  String get bengali => 'бенгальский';

  @override
  String get chinese => 'китайский';

  @override
  String get english => 'Английский';

  @override
  String get french => 'Французский';

  @override
  String get german => 'немецкий';

  @override
  String get gujarati => 'гуджарати';

  @override
  String get hindi => 'хинди';

  @override
  String get indonesian => 'индонезийский';

  @override
  String get italian => 'итальянский';

  @override
  String get japanese => 'японский';

  @override
  String get kannada => 'Каннада';

  @override
  String get korean => 'корейский';

  @override
  String get malayalam => 'Малаялам';

  @override
  String get marathi => 'маратхи';

  @override
  String get persian => 'персидский';

  @override
  String get polish => 'польский';

  @override
  String get portuguese => 'португальский';

  @override
  String get punjabi => 'Пенджаби';

  @override
  String get russian => 'Русский';

  @override
  String get spanish => 'испанский';

  @override
  String get swedish => 'шведский';

  @override
  String get tamil => 'тамильский';

  @override
  String get telugu => 'телугу';

  @override
  String get thai => 'Тайский';

  @override
  String get turkish => 'турецкий';

  @override
  String get urdu => 'урду';

  @override
  String get vietnamese => 'вьетнамский';

  @override
  String get failedToLoadCollectionDetails =>
      'Не удалось загрузить данные о коллекции.';

  @override
  String get franchiseProgress => 'Прогресс франчайзинга';

  @override
  String get officialSite => 'Официальный сайт';

  @override
  String get productions => 'Производство';

  @override
  String get productionCompany => 'Производственная компания';

  @override
  String get failedToLoadCompanyInfo =>
      'Не удалось загрузить информацию о компании.';

  @override
  String get profile => 'Профиль';

  @override
  String get guestViewer => 'Гостевой зритель';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      'Здесь хранятся ваш профиль, состояние синхронизации, регион и визуальные настройки.';

  @override
  String get signInToSync =>
      'Войдите в систему, чтобы синхронизировать свой список просмотра, рейтинги и предпочтения.';

  @override
  String get signedInAndSyncing =>
      'Вход выполнен, синхронизация с облаком завершена.';

  @override
  String get developedBy => 'Разработано компанией';

  @override
  String get couldNotAnalyzeWatchHistory =>
      'В данный момент не могу проанализировать историю просмотров.';

  @override
  String get includeLocalLibrary => 'Включить местную библиотеку';

  @override
  String get useCloudOnly => 'Использовать только облачные технологии';

  @override
  String get localLibrarySyncDescription =>
      'На этом устройстве уже есть локальные библиотечные файлы. Добавьте их в свою авторизованную библиотеку или замените локальные данные облачной библиотекой.';

  @override
  String get mergedLocalTitles =>
      'Локальные игры объединены с вашей библиотекой, в которую вы вошли.';

  @override
  String get replacedLocalLibrary =>
      'Замените данные локальной библиотеки на данные вашей облачной библиотеки.';

  @override
  String get deleteAccountConfirmation =>
      'Это приведет к безвозвратному удалению вашей учетной записи Lumi и синхронизированных облачных данных. Локальные данные на этом устройстве сохранятся, если вы не удалите данные приложения отдельно.';

  @override
  String get signedOutAndCleared =>
      'Вышел из системы и очистил локальную библиотеку на этом устройстве.';

  @override
  String get keepLocalLibrary => 'Поддержите местные библиотеки!';

  @override
  String get clearLocalLibrary => 'Местная библиотека Клир';

  @override
  String get signOutChoiceDescription =>
      'Выберите, следует ли сохранять локальную библиотеку на этом устройстве после выхода из системы.';

  @override
  String get disable => 'Запрещать';

  @override
  String get aiRecommendationsEnabled =>
      'Включен обмен данными о рекомендациях ИИ.';

  @override
  String get aiRecommendationsDisabled =>
      'Обмен данными о рекомендациях ИИ отключен.';

  @override
  String get reviewAndManageConsent =>
      'Проверка и управление согласиями на отправку данных библиотеки поставщикам услуг искусственного интеллекта.';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      'Включено. Функция «Рекомендовать сегодня вечером» может отправлять сводку по вашей библиотеке и последние запросы поставщикам ИИ.';

  @override
  String basedOnWatchedTitles(String count) {
    return 'На основе просмотренных фильмов и сериалов ($count).';
  }

  @override
  String lastUpdated(String date) {
    return 'Последнее обновление: $date';
  }

  @override
  String get chooseYourVibe => 'Выберите свой стиль';

  @override
  String get appearanceDescription =>
      'Переключайте приложение между различными кинематографическими персонажами, не меняя при этом его поведения.';

  @override
  String get exitAppConfirmation => 'Вы уверены, что хотите выйти из Lumi?';

  @override
  String get dismiss => 'Увольнять';

  @override
  String get generatingWatchAnalytics => 'Генерация аналитики часов';

  @override
  String get thisUsuallyTakesAFewSeconds =>
      'Обычно это занимает несколько секунд.';

  @override
  String get yourScreenStory => 'Ваша экранная история';

  @override
  String get snapshotOfHowAndWhatYouWatch =>
      'Краткий обзор того, как и что вы смотрите.';

  @override
  String get yourFavoriteGenres => 'Ваши любимые жанры';

  @override
  String get genrePerformanceHighestRated =>
      'Жанровое исполнение (самый высокий рейтинг)';

  @override
  String get personalizedViewingPatterns =>
      'Персонализированные шаблоны просмотра';

  @override
  String get builtWithLumi => 'Создано с помощью Lumi';

  @override
  String get sharedWithLumi => 'Поделились с Люми';

  @override
  String get shareAnalytics => 'Аналитика акций';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return 'Проанализированы названия $count • Обновлены $date';
  }

  @override
  String get allSeasons => 'Все сезоны';

  @override
  String get castAndCrew => 'Актеры и съемочная группа';

  @override
  String get featuredCrew => 'Представленная команда';

  @override
  String get stills => 'Кадры';

  @override
  String get accoladeSummary => 'Краткое описание наград';

  @override
  String get awardsAndAccolades => 'Награды и почести';

  @override
  String get unableToLoadMovieDetails =>
      'Не удалось загрузить подробности о фильме.';

  @override
  String get overviewUnavailable => 'Обзор данного издания недоступен.';

  @override
  String get openCompletePlot =>
      'Откройте полный график и дополнительные метаданные из OMDb.';

  @override
  String get noOverviewForSeason => 'Обзор по данному сезону отсутствует.';

  @override
  String get userScore => 'Пользовательский рейтинг';

  @override
  String get playTrailer => 'Посмотреть трейлер';

  @override
  String get whereToWatch => 'Где посмотреть';

  @override
  String get availabilityDataByJustWatch =>
      'Данные о доступности предоставлены JustWatch.';

  @override
  String get reminderSaved => 'Напоминание сохранено';

  @override
  String reminderForTitle(String title) {
    return 'Напоминание для $title';
  }

  @override
  String get pleaseSelectFutureTime => 'Пожалуйста, выберите время в будущем.';

  @override
  String get notifyAt => 'Уведомить по адресу';

  @override
  String get notifyHoursBeforeAiring =>
      'За сколько часов до выхода в эфир следует уведомить?';

  @override
  String enterNumberBetween(String maxHours) {
    return 'Введите число от 1 до $maxHours';
  }

  @override
  String get set => 'Набор';

  @override
  String get selectedReminderTimePassed =>
      'Время, указанное в выбранном напоминании, уже истекло.';

  @override
  String episodeReminderSaved(String date) {
    return 'Напоминание о серии сохранено для $date';
  }

  @override
  String get areYouSureDeleteNote =>
      'Вы уверены, что хотите удалить эту заметку?';

  @override
  String get noteAdded => 'Примечание добавлено';

  @override
  String get lastSeason => 'Прошлый сезон';

  @override
  String get currentSeason => 'Текущий сезон';

  @override
  String get viewAllSeasons => 'Просмотреть все сезоны';

  @override
  String get removedFromFavourites => 'Удалено из Избранного';

  @override
  String get addedToFavourites => 'Добавлено в Избранное';

  @override
  String get awardsAndNominations => 'Награды и номинации';

  @override
  String get viewAll => 'Посмотреть все';

  @override
  String get boxOfficeFinancials => 'Финансовые показатели кассовых сборов';

  @override
  String get successMeter => 'Индикатор успеха';

  @override
  String get blockbuster => 'БЛОКБАСТЕР';

  @override
  String get hit => 'УДАРЯТЬ';

  @override
  String get breakEven => 'ТОЧКА БЕЗУБЫТОЧНОСТИ';

  @override
  String get underperformer => 'НЕУДАЧНИК';

  @override
  String get boxOfficeBomb => 'Кассовый провал';

  @override
  String get episodeTracker => 'Отслеживание эпизодов';

  @override
  String get setAiringReminder => 'Установить напоминание о показе';

  @override
  String get nextEpisodeCountdown => 'Обратный отсчет до следующей серии';

  @override
  String get nextEpisode => 'Следующая серия';

  @override
  String get lastEpisodeToAir => 'Последняя серия, которая выйдет в эфир';

  @override
  String get unknown => 'Неизвестный';

  @override
  String get contentAdvisory => 'Консультативное предупреждение о содержании';

  @override
  String get violence => 'Насилие';

  @override
  String get sexAndNudity => 'Секс и обнаженность';

  @override
  String get foulLanguage => 'Язык';

  @override
  String get substances => 'Вещества';

  @override
  String get fearAndHorror => 'Страх и ужас';

  @override
  String get familyFriendly => 'Подходит для семейного отдыха';

  @override
  String get generalAudience => 'Для широкой аудитории';

  @override
  String get releaseTimeline => 'Сроки выпуска';

  @override
  String get notifyMe => 'Уведомить меня';

  @override
  String get theatricalRelease => 'Театральный релиз';

  @override
  String get digitalStreaming => 'Цифровой / Стриминг';

  @override
  String get physicalRelease => 'Физический диск (Blu-ray / DVD)';

  @override
  String get awesome => 'Потрясающий';

  @override
  String get keywordsAndThemes => 'Ключевые слова и темы';

  @override
  String get videosAndBehindTheScenes => 'Видео и закулисные материалы';

  @override
  String get productionStudios => 'Производственные студии';

  @override
  String get fetchingWatchLink => 'Получение ссылки на часы';

  @override
  String get findingBestProviderPage =>
      'Поиск лучшей страницы поставщика для этого издания.';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode';
  }

  @override
  String get error => 'Ошибка';

  @override
  String get failedToLoadSeasonDetails =>
      'Не удалось загрузить данные о сезоне.';

  @override
  String get loading => 'Загрузка...';

  @override
  String runtimeSeparator(String runtime) {
    return 'Переведите это название приложения на язык ru: • $runtime';
  }

  @override
  String get fullCastAndCrew => 'Полный список актеров и съемочной группы';

  @override
  String get shareMovie => 'Поделиться фильмом';

  @override
  String get quotes => 'Кавычки';

  @override
  String get mayIncludeMismatches =>
      'Возможны случайные несоответствия из-за поиска по лексической цитате.';

  @override
  String get movieApiConfigurationRequired =>
      'Требуется настройка API для фильмов.';

  @override
  String get addMovieProxyBaseUrl =>
      'Добавьте MOVIE_PROXY_BASE_URL, чтобы подключить приложение к прокси-серверу TMDB.';

  @override
  String get cinematicPicksContext =>
      'Эффектные кадры, создающие неповторимую атмосферу. Бросайте кубик, чтобы получить еще одну карту-сюрприз.';

  @override
  String get curatedTonight => 'Подборка сегодня вечером';

  @override
  String curatedTonightTitle(String title) {
    return 'Подборка сегодня вечером: $title';
  }

  @override
  String get describeItYourWay =>
      'Опишите это по-своему.\n\nМы находим лучшие варианты.';

  @override
  String get hide => 'Скрывать';

  @override
  String get hideTitleDescription =>
      'Скрытие этого заголовка предотвратит его появление в разделе «В центре внимания» в будущем.';

  @override
  String get dontAskAgain => 'Больше не спрашивайте';

  @override
  String get imdbNa =>
      'Переведите название этого приложения на русский язык: IMDb NA';

  @override
  String get noDiscoverPicks =>
      'В настоящий момент нет доступных рекомендаций для программы Discover.';

  @override
  String get playPreview => 'Предварительный просмотр игры';

  @override
  String get recommendedForYou => 'Рекомендуем вам';

  @override
  String get spotlightCompleted => 'Программа Spotlight завершена.';

  @override
  String get startAddingTitlesForRecommendations =>
      'Начните добавлять заголовки для рекомендаций.';

  @override
  String get clearedAllChoices =>
      'Вы пролистали и очистили все понравившиеся вам варианты в ленте рекомендаций.';

  @override
  String get whatsPopular => 'Что популярно';

  @override
  String get trending => 'В тренде';

  @override
  String get nowPlaying => 'Сейчас играет';

  @override
  String get tvTrending => 'Телевизионные тренды';

  @override
  String get discoverByMood => 'Откройте для себя по настроению';

  @override
  String get needSomethingToWatchTonight =>
      'Хотите что-нибудь посмотреть сегодня вечером?';

  @override
  String get needAMovieForTonight => 'Ищете фильм на сегодня?';

  @override
  String get tryAiShows => 'Попробуйте шоу с искусственным интеллектом';

  @override
  String get tryAiMovies => 'Попробуйте фильмы, созданные с помощью ИИ.';

  @override
  String get findShows => 'Найти шоу';

  @override
  String get findMovies => 'Найти фильмы';

  @override
  String get couldNotLoadThisRail => 'Не удалось загрузить эту рельсу.';

  @override
  String get temporaryIssueLoadingRail =>
      'Возникла временная проблема с погрузкой этого рельса.';

  @override
  String get noTitlesHereYet => 'Здесь пока нет заголовков.';

  @override
  String get noHiddenGemsForGenre =>
      'В этом жанре пока не найдено ни одного скрытого шедевра. Попробуйте другой жанр.';

  @override
  String get tryAnotherFilter =>
      'Попробуйте другой фильтр или откройте этот раздел для более широкого поиска.';

  @override
  String get seeAllFilters => 'Посмотреть все фильтры';

  @override
  String get couldNotLoadCuratedPicks =>
      'Не удалось загрузить подборку лучших товаров.';

  @override
  String get temporaryIssueLoadingCurated =>
      'При загрузке сегодняшнего подборки возникла временная проблема.';

  @override
  String get noCuratedPicksAvailable =>
      'Подборка лучших рекомендаций отсутствует.';

  @override
  String get tryAgainWhileRefresh =>
      'Попробуйте еще раз через минуту, пока мы обновляем список TMDB за сегодняшний вечер.';

  @override
  String get fromSpotlight => 'Из рубрики «В центре внимания»';

  @override
  String get addShowsMoviesForRecommendations =>
      'Добавляйте телешоу/фильмы в свой список просмотра, избранное или список просмотренных, чтобы увидеть названия, которые могут вам понравиться.';

  @override
  String get allow => 'Позволять';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get allowAiDataSharingTitle =>
      'Разрешить обмен данными с использованием ИИ?';

  @override
  String get allowAiDataSharingDescription =>
      'Сервис Recommend Tonight отправляет введенный вами текст для запроса рекомендации фильма и временный контекст уточнения запроса в Google Gemini и OpenRouter. Ваша полная библиотека и учетные данные для входа в систему не отправляются этим поставщикам ИИ. Разрешить ли такой обмен данными для рекомендаций ИИ?';

  @override
  String get liveProgress => 'Текущий прогресс';

  @override
  String percentComplete(String percent) {
    return '$percent% завершено';
  }

  @override
  String get describeIdealShowNight =>
      'Опишите свой идеальный вечер для посещения спектакля.';

  @override
  String get describeIdealMovieNight =>
      'Опишите свой идеальный вечер за просмотром фильма.';

  @override
  String get useNaturalLanguage =>
      'Используйте естественный язык. Укажите, что вы хотите, чего следует избегать, а также необязательные подсказки по языку программирования/среде выполнения.';

  @override
  String get listeningTapMicToStop =>
      'Слушаю... Нажмите на микрофон еще раз, чтобы остановить.';

  @override
  String voiceInputError(String error) {
    return 'Ошибка ввода голоса: $error';
  }

  @override
  String get tapMicToDictate =>
      'Нажмите на микрофон, чтобы продиктовать свой запрос.';

  @override
  String get tapMicToEnableVoice =>
      'Нажмите на микрофон, чтобы включить голосовой ввод.';

  @override
  String get findingShows => 'Поиск шоу...';

  @override
  String get findingMovies => 'Поиск фильмов...';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return 'Сегодняшний выбор Lumi: $prompt';
  }

  @override
  String get tonightsPicks => 'Выбор на сегодня';

  @override
  String get sharedFromLumi => 'Опубликовано с Lumi';

  @override
  String get intent => 'Намерение:';

  @override
  String get genreLabel => 'Жанр:';

  @override
  String get avoid => 'Избегать:';

  @override
  String get languageLabel => 'Язык:';

  @override
  String runtimeAtMost(String minutes) {
    return 'Время выполнения <= $minutes мин';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return 'Время выполнения >= $minutes мин';
  }

  @override
  String get yearLabel => 'Год:';

  @override
  String yearAfter(String year) {
    return 'После $year';
  }

  @override
  String yearBefore(String year) {
    return 'Перед $year';
  }

  @override
  String get like => 'Нравиться:';

  @override
  String get signal => 'Сигнал:';

  @override
  String get readingWatchedHistory =>
      'Читая историю просмотренных вами фильмов...';

  @override
  String get findingTopGenres =>
      'Как определить ваши самые популярные жанры и шаблоны...';

  @override
  String get buildingTrends =>
      'Формирование ежемесячных и рейтинговых тенденций...';

  @override
  String get writingInsights => 'Напишите свои персональные выводы...';

  @override
  String get applyFilters => 'Применить фильтры';

  @override
  String get includeNotRated => 'Включить в список «Без рейтинга»';

  @override
  String get errorLoadingTvGenres => 'Ошибка загрузки жанров телесериалов.';

  @override
  String get alsoKnownAs => 'Также известен как';

  @override
  String get biography => 'Биография';

  @override
  String get careerStatistics => 'Статистика карьеры';

  @override
  String get frequentlyCollaboratesWith => 'Часто сотрудничает с';

  @override
  String get notableQuotes => 'Известные цитаты';

  @override
  String get primaryRole => 'Основная роль';

  @override
  String get averageRating => 'Средний рейтинг';

  @override
  String get topGenre => 'Топ жанров';

  @override
  String get peakBoxOffice => 'Пик кассовых сборов';

  @override
  String percentOfTitles(String percent) {
    return '$percent% названий';
  }

  @override
  String sharedTitleCount(String count) {
    return '$count общее название(я)';
  }

  @override
  String billingOrder(String order) {
    return 'Номер счета: #$order';
  }

  @override
  String get startTypingToSearch => 'Начните вводить текст для поиска.';

  @override
  String get movieDiscoveryMadePersonal =>
      'Индивидуальный подход к поиску фильмов.';

  @override
  String get allNotes => 'Все примечания';

  @override
  String get viewPersonalizedInsights =>
      'Просматривайте персонализированные аналитические данные, графики и тенденции.';

  @override
  String get curatedCollections => 'Подборки лучших образцов';

  @override
  String get list => 'список';

  @override
  String get openList => 'Открытый список';

  @override
  String get thisListNoLongerExists => 'Этот список больше не существует.';

  @override
  String listRenamed(String name) {
    return 'Список переименован в $name';
  }

  @override
  String listDeleted(String name) {
    return 'Список $name удален';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return 'В вашем списке наблюдения нет $filter';
  }

  @override
  String noFilterInFavourites(String filter) {
    return 'Нет $filter в избранном';
  }

  @override
  String noFilterInWatched(String filter) {
    return 'В списке просмотренных нет $filter';
  }

  @override
  String noFilterInThisList(String filter) {
    return 'В этом списке нет $filter';
  }

  @override
  String noListsWithFilter(String filter) {
    return 'Нет списков с $filter';
  }

  @override
  String importedInto(String name) {
    return 'Импортировано в \"$name\"';
  }

  @override
  String get couldNotImportList => 'Не удалось импортировать список.';

  @override
  String get importing => 'Импорт...';

  @override
  String get couldNotLoadSharedList =>
      'Не удалось загрузить этот общий список.';

  @override
  String get editWatchedInfo =>
      'Редактировать информацию о просмотренных товарах';

  @override
  String get watchDate => 'Дата просмотра';

  @override
  String get rewatchCount => 'Количество повторных просмотров';

  @override
  String get watchedInfoUpdated => 'Информация о просмотре обновлена.';

  @override
  String removedFromList(String listName) {
    return 'Удалено из $listName';
  }

  @override
  String addedToList(String listName) {
    return 'Добавлено в $listName';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return 'Добавлено в $listName и список наблюдения.';
  }

  @override
  String get moreTrailersLikeThis => 'Больше трейлеров, подобных этому';

  @override
  String get noDescriptionForTrailer => 'Описание этого трейлера отсутствует.';

  @override
  String get closeTrailer => 'Закрыть трейлер';

  @override
  String get recommendedSeries => 'Рекомендуемые серии';

  @override
  String get recommendedMovie => 'Рекомендуемый фильм';

  @override
  String get notEnoughDataYet => 'Пока недостаточно данных';

  @override
  String addAndRateMoreTitles(String count) {
    return 'Добавьте и оцените не менее $count названий, чтобы разблокировать аналитику.';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return 'У вас просмотрено $watchedCount/$requiredCount фильмов. Добавьте еще $remaining, чтобы разблокировать аналитику.';
  }

  @override
  String get moviesPerMonth => 'Фильмы в месяц';

  @override
  String get genreDistribution => 'Распределение по жанрам';

  @override
  String get ratingTrends => 'Тенденции рейтингов';

  @override
  String get noData => 'Нет данных';

  @override
  String get myLatestWatchAnalytics => 'Мой последний анализ часов Lumi.';

  @override
  String get myWatchInsights => 'Мои впечатления о часах Lumi.';

  @override
  String get infographicsCard => 'Карточка инфографики';

  @override
  String get watchInsightsSnapshot => 'Обзор аналитических данных';

  @override
  String get availableOnceInsightsReady =>
      'Доступно после получения аналитических данных.';

  @override
  String get shareYourWatchInsights =>
      'Поделитесь своей карточкой с информацией о часах.';

  @override
  String get recentlyWatchedVibe => 'Недавно просмотренные Vibe';

  @override
  String get mixedAcrossGenres => 'Разнообразные жанры';

  @override
  String get moviesPerMonthShort => 'Фильмы / месяц';

  @override
  String get ratingTrend => 'Тенденция рейтингов';

  @override
  String get balanced => 'Сбалансированный';

  @override
  String get noWatchNextSuggestionsYet =>
      'Пока нет предложений для просмотра следующих видео.';

  @override
  String get upcomingFromLibrary => 'Ожидается из вашей библиотеки';

  @override
  String get removeReminder => 'Удалить напоминание';

  @override
  String get remindMe => 'Напомни мне';

  @override
  String titleReleasesToday(String title) {
    return '$title выходит сегодня.';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle скоро выйдет в эфир.';
  }

  @override
  String get controlPremiereAlerts =>
      'Настройте оповещения о премьерах и напоминания о выходе новых версий.';

  @override
  String upcomingReleasesCount(String count) {
    return '$count предстоящие релизы в вашей библиотеке.';
  }

  @override
  String sittingInWatchlist(String days) {
    return 'Находится в вашем списке наблюдения уже $days дней';
  }

  @override
  String get alreadyOnWatchlist => 'Уже в вашем списке просмотра';

  @override
  String get favouritedButNotWatched =>
      'Вы добавили это в избранное, но еще не отметили как отслеживаемое.';

  @override
  String get savedInListReady =>
      'Сохранено в одном из ваших списков и готово к просмотру.';

  @override
  String get matchesTitlesYouTrack =>
      'Названия матчей, которые вы уже отслеживаете';

  @override
  String get noOfficialSite => 'Официального сайта нет.';

  @override
  String get episodeAiring => 'Выход эпизода в эфир';

  @override
  String get general => 'Общий';

  @override
  String scheduledFor(String date) {
    return 'Запланировано на $date';
  }

  @override
  String wasScheduledFor(String date) {
    return 'Было запланировано на $date';
  }

  @override
  String get noOverviewAvailable => 'Обзор отсутствует.';

  @override
  String get searchHistoryCleared => 'История поиска очищена';

  @override
  String get visualMovieCard => 'Визуальная кинокарта';

  @override
  String get smartLumiLink =>
      'Переведите название этого приложения на язык ru: Smart Lumi Link';

  @override
  String get directTmdbLink => 'Прямая ссылка на TMDB';

  @override
  String recommendedOnLumi(String title) {
    return 'Рекомендовано на Lumi: $title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return 'Посмотрите $title на Lumi!\n\n$link\n\nПриобрести Lumi: $appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return 'Посмотрите информацию о $title на TMDB: $link';
  }

  @override
  String releaseAlertTitle(String title) {
    return '$title оповещение о выпуске';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return 'Установлено оповещение о выходе новых часов $date. Мы уведомим вас, когда они поступят в продажу.';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return 'Мы уведомим вас, как только \"$title\" выйдет в цифровом формате или на Blu-ray/DVD!';
  }

  @override
  String get episodeAlreadyDueToAir => 'Эта серия уже должна выйти в эфир.';

  @override
  String get reminderSetSuccessfully => 'Напоминание успешно установлено.';

  @override
  String get speechRecognitionNotAvailable =>
      'Функция распознавания речи на этом устройстве недоступна.';

  @override
  String get describeShowMood =>
      'Опишите, какой сериал вам хочется посмотреть, и мы вышлем вам список, ранжированный по категориям.';

  @override
  String get describeMovieMood =>
      'Опишите, какой фильм вам хочется посмотреть, и мы вышлем вам список фильмов, ранжированных по качеству.';

  @override
  String get aiLauncherDescription =>
      'Введите или произнесите запрос на естественном языке. Lumi создаст план искусственного интеллекта, выполнит векторный поиск и вернет несколько вариантов фильмов/шоу.';

  @override
  String yearRange(String from, String to) {
    return 'Переведите название этого приложения на ru: $from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return 'Напоминание(я) $count запланировано.';
  }

  @override
  String regionAutoDetected(String region) {
    return 'Автоматически обнаружено: $region';
  }

  @override
  String regionSelected(String region) {
    return 'Выбрано: $region';
  }

  @override
  String get allLanguagesSubtitle => 'Все языки';

  @override
  String currentlySetToLanguage(String language) {
    return 'В данный момент установлено значение $language';
  }

  @override
  String get availabilities => 'Наличие';

  @override
  String get mood => 'Настроение';

  @override
  String get people => 'Люди';

  @override
  String get ads => 'Реклама';

  @override
  String get theatricalLimited => 'Театральный Лимитед';

  @override
  String get premier => 'Премьер';

  @override
  String get mediaType => 'Тип носителя';

  @override
  String get couldNotLoadAnalytics => 'Не удалось загрузить аналитику.';

  @override
  String get viewAllAwards => 'Посмотреть все';

  @override
  String get win => 'Победить';

  @override
  String get wins => 'Победы';

  @override
  String get nomination => 'Номинация';

  @override
  String get nominations => 'Номинации';

  @override
  String sharedBy(String name) {
    return 'Опубликовано пользователем $name';
  }

  @override
  String titleCount(String count) {
    return '$count название(я)';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count сохранил названия во всех ваших списках';
  }

  @override
  String get curatedCollectionsSubtitle =>
      'Подборки, которые вы можете организовывать и которыми можете делиться.';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return 'Импортируйте \"$name\" в Lumi ($count $itemLabel): $link';
  }

  @override
  String get notEnoughData => 'Недостаточно данных';

  @override
  String shareQuote(String title) {
    return 'Посмотрите эту цитату от \"$title\" на Lumi!';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Рекомендуемые товары на Lumi: $title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      'Введите или произнесите запрос на естественном языке. Lumi создаст план искусственного интеллекта, выполнит векторный поиск и вернет несколько вариантов выбора шоу.';

  @override
  String get aiLauncherDescriptionMovie =>
      'Введите или произнесите запрос на естественном языке. Lumi создаст план искусственного интеллекта, выполнит векторный поиск и вернет несколько вариантов фильмов.';

  @override
  String get warmingUpMovieSearch => 'Подготовка к поиску фильмов';

  @override
  String get connectingToRecommendationEngine =>
      'Подключение к системе рекомендаций';

  @override
  String get understandingYourTaste =>
      'Понимание того, чего вам хочется в данный момент';

  @override
  String get buildingCustomSearch =>
      'Создание пользовательского поиска на основе вашего запроса';

  @override
  String get tinyNetworkHiccup => 'Небольшая сбой в сети, пытаюсь снова.';

  @override
  String get planLocked =>
      'План заблокирован: жанр, стиль, язык и время выполнения.';

  @override
  String get scanningTmdb =>
      'Сканирование базы данных TMDB для поиска подходящих совпадений.';

  @override
  String get collectingDetails =>
      'Сбор информации о постерах, рейтингах и продолжительности лучших фильмов.';

  @override
  String shortlistingPicksCount(String current, String total) {
    return 'Предварительный отбор кандидатов ($current/$total)';
  }

  @override
  String get shortlistingBestPicks => 'Составление списка лучших вариантов';

  @override
  String get finalPolish => 'Завершающая доработка ваших рекомендаций.';

  @override
  String get retryingAfterIssue =>
      'Повторная попытка после временной проблемы.';

  @override
  String get regionUnitedStates => 'Соединенные Штаты';

  @override
  String get regionIndia => 'Индия';

  @override
  String get regionUnitedKingdom => 'Великобритания';

  @override
  String get regionCanada => 'Канада';

  @override
  String get regionAustralia => 'Австралия';

  @override
  String get regionNewZealand => 'Новая Зеландия';

  @override
  String get regionGermany => 'Германия';

  @override
  String get regionFrance => 'Франция';

  @override
  String get regionSpain => 'Испания';

  @override
  String get regionItaly => 'Италия';

  @override
  String get regionJapan => 'Япония';

  @override
  String get regionSouthKorea => 'Южная Корея';

  @override
  String get regionBrazil => 'Бразилия';

  @override
  String get regionMexico => 'Мексика';

  @override
  String get regionSingapore => 'Сингапур';

  @override
  String get regionPhilippines => 'Филиппины';

  @override
  String get regionIndonesia => 'Индонезия';

  @override
  String get regionUnitedArabEmirates => 'Объединенные Арабские Эмираты';

  @override
  String get regionSaudiArabia => 'Саудовская Аравия';

  @override
  String get regionTurkey => 'Турция';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return 'Автоматически определяемый регион: $regionLabel ($regionCode). Выберите регион, который будет использоваться для локализованных запросов фильмов и поиска поставщиков услуг просмотра.';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return 'Выбранный регион: $regionLabel ($regionCode). Поддерживаемые запросы к фильмам и поиск поставщиков просмотра будут автоматически использовать его в следующий раз.';
  }

  @override
  String get syncSignInTooltip =>
      'Войдите в систему для синхронизации с облаком.';

  @override
  String get syncFailedTooltip =>
      'Синхронизация не удалась. Нажмите, чтобы повторить попытку.';

  @override
  String get syncedTooltip => 'Библиотека синхронизирована с облаком';

  @override
  String get shareQuoteTooltip => 'Поделиться цитатой';

  @override
  String get copyQuoteTooltip => 'Скопировать цитату';

  @override
  String get quoteCopiedToast => 'Цитата скопирована в буфер обмена';

  @override
  String get shareDialogueTooltip => 'Обмен диалогом';

  @override
  String get copyDialogueTooltip => 'Скопировать диалог';

  @override
  String get dialogueCopiedToast => 'Диалог скопирован в буфер обмена';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$title выйдет в эфир через 1 час';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel \"$episodeName\" выходит в эфир в $localAirTime.';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$title выходит сегодня';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return 'В вашей библиотеке есть фильм, который выходит в прокат $localDate.';
  }

  @override
  String get curatedNeoNoirNights => 'Нео-нуарные ночи';

  @override
  String get curatedPulsePoundingRush => 'Захватывающий дух прилив адреналина';

  @override
  String get curatedFeelGoodEscape => 'Приятный отдых';

  @override
  String get curatedMindBenders => 'Загадки разума';

  @override
  String get curatedEpicWorlds => 'Эпические миры';

  @override
  String get curatedHumanStories => 'Человеческие истории';

  @override
  String get curatedDarkDetectiveFiles => 'Детективные дела из мира тьмы';

  @override
  String get curatedNeoNoirNightsDescription =>
      'Пропитанная дождем напряженность, морально неоднозначные главные герои и атмосферные городские истории.';

  @override
  String get curatedPulsePoundingRushDescription =>
      'Погони с высокими ставками, нарастающая опасность и непрекращающийся темп повествования.';

  @override
  String get curatedFeelGoodEscapeDescription =>
      'Теплые истории, вдохновляющие сюжетные линии и уютные мелодии для спокойного вечера.';

  @override
  String get curatedMindBendersDescription =>
      'Искажающие реальность концепции, запутанный сюжет и повествование, основанное на масштабных идеях.';

  @override
  String get curatedEpicWorldsDescription =>
      'Масштабные приключения во вселенной, мифические ставки и кинематографический размах.';

  @override
  String get curatedHumanStoriesDescription =>
      'Драмы, в которых на первом месте стоят характеры персонажей, с эмоциональным воздействием и запоминающимися актерскими работами.';

  @override
  String get curatedDarkDetectiveFilesDescription =>
      'Холодные улики, множество подозреваемых и затяжные расследования.';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get appLanguageSystemDefault => 'Системные настройки по умолчанию';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return 'Язык приложения установлен на $language. Это изменяет только интерфейс приложения, а не язык фильмов и сериалов.';
  }

  @override
  String get appLanguageSystemSubtitle =>
      'Язык приложения определяется настройками вашего устройства. Измените его, чтобы интерфейс отображался на другом языке.';

  @override
  String get contentLanguageAllSubtitle =>
      'Все языки. Вкладки «Фильмы» и «ТВ» остаются общими, а вкладка «Исследовать» по-прежнему может отдавать предпочтение более подходящим локальным вариантам, если таковые имеются.';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return 'В данный момент установлено значение $language. Вкладки «Фильмы» и «ТВ» останутся без изменений, а вкладка «Исследовать» будет отдавать предпочтение этому языку.';
  }
}
