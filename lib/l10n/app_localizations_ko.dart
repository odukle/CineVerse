// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '루미';

  @override
  String get navExplore => '탐색';

  @override
  String get navMovies => '영화';

  @override
  String get navTvShows => 'TV 쇼';

  @override
  String get navLibrary => '도서관';

  @override
  String get navAccount => '계정';

  @override
  String get searchHint => '영화, TV 프로그램, 회사 검색...';

  @override
  String get searchForPerson => '사람 검색...';

  @override
  String get searchLanguages => '언어 검색';

  @override
  String get searchNameOrRole => '이름 또는 역할 검색...';

  @override
  String get retry => '재시도';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get clear => '지우기';

  @override
  String get cancel => '취소';

  @override
  String get ok => '확인';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get share => '공유';

  @override
  String get undo => '실행 취소';

  @override
  String get close => '닫기';

  @override
  String get apply => '적용';

  @override
  String get reset => '재설정';

  @override
  String get done => '완료';

  @override
  String get signInWithGoogle => 'Google로 로그인';

  @override
  String get signInWithApple => 'Apple로 로그인';

  @override
  String get signOut => '로그아웃';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get accountDeletedSuccessfully => '계정이 삭제되었습니다.';

  @override
  String get appearance => '모양';

  @override
  String get appearanceSubtitle => '테마를 선택하고 앱 모양을 맞춤설정하세요.';

  @override
  String get notifications => '알림';

  @override
  String get releaseCalendar => '출시 일정';

  @override
  String get hiddenTitles => '숨겨진 제목';

  @override
  String get aiRecommendationsPrivacy => 'AI 추천 개인 정보 보호';

  @override
  String get contentRegion => '콘텐츠 영역';

  @override
  String get contentLanguage => '콘텐츠 언어';

  @override
  String get watchlist => '관심 목록';

  @override
  String get notes => '메모';

  @override
  String get deleteNote => '메모 삭제';

  @override
  String get addNoteHint => '메모 추가...';

  @override
  String get addBriefNoteHint => '간단한 메모 추가(선택 사항)...';

  @override
  String get enterNewName => '새 이름 입력...';

  @override
  String get importSharedList => '공유 목록 가져오기';

  @override
  String get discoverOnLumi => 'LUMI에서 발견';

  @override
  String get filtered => '필터링됨';

  @override
  String get fullPlot => '전체 플롯';

  @override
  String get userReviews => '사용자 리뷰';

  @override
  String get noReviewsYet => '아직 리뷰가 없습니다.';

  @override
  String get openInYouTube => 'YouTube에서 열기';

  @override
  String get hiddenGems => '숨겨진 보석';

  @override
  String get resetSpotlight => '스포트라이트 재설정';

  @override
  String get clearPreferences => '환경설정 지우기';

  @override
  String get refreshPicks => '추천 새로고침';

  @override
  String get shareBoard => '보드 공유';

  @override
  String get exploreDetails => '세부정보 탐색';

  @override
  String get searchWikiquotes => 'Wikiquotes 검색';

  @override
  String get selectAQuote => '견적 선택';

  @override
  String get tooltipShareQuote => '견적 공유';

  @override
  String get tooltipCopyQuote => '견적 복사';

  @override
  String get tooltipShareDialogue => '대화 공유';

  @override
  String get tooltipCopyDialogue => '대화 복사';

  @override
  String get tooltipUnhide => '숨기기 취소';

  @override
  String get tooltipOpenPrivacyPolicy => '개인 정보 보호 정책 열기';

  @override
  String get tooltipRefreshInsights => '통찰력 새로 고침';

  @override
  String get tooltipSortTitles => '제목 정렬';

  @override
  String get tooltipSearch => '검색';

  @override
  String get tooltipFilters => '필터';

  @override
  String get tooltipSaveToGallery => '갤러리에 저장';

  @override
  String get tooltipShare => '공유';

  @override
  String get tooltipShareAnalytics => '분석 공유';

  @override
  String get tooltipSetAiringReminder => '방송 알림 설정';

  @override
  String get tooltipLibrarySynced => '클라우드와 동기화된 라이브러리';

  @override
  String get noMoreEntries => '더 이상 참가 신청이 없습니다.';

  @override
  String get noItemsFound => '검색된 항목이 없습니다.';

  @override
  String errorLoadingGenres(String error) {
    return '장르 로드 오류: $error';
  }

  @override
  String errorGeneric(String error) {
    return '오류: $error';
  }

  @override
  String get errorLoadingLists => '목록 로드 오류';

  @override
  String errorLoadingQuotes(Object error) {
    return '인용문 로드 실패: $error';
  }

  @override
  String get errorCouldNotShareAnalytics => '공유할 수 없음 분석 카드.';

  @override
  String get errorCouldNotShareRecommendations => '추천게시판을 공유할 수 없습니다.';

  @override
  String get errorCouldNotShareInsights => '시계 통계를 공유할 수 없습니다.';

  @override
  String get watchInsightsNotReady => 'Watch 통계는 아직 준비되지 않았습니다.';

  @override
  String titleRestoredToSpotlight(String title) {
    return '\"$title\"이 Spotlight로 복원됨';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '\"$title\"이 숨겨졌습니다';
  }

  @override
  String hiddenDate(String date) {
    return '숨겨진: $date';
  }

  @override
  String get moviesInThisCollection => '이 컬렉션의 영화';

  @override
  String get searchPlanReady => '검색 계획이 준비되었습니다';

  @override
  String get hoursBeforeAirTime => '방송 시간 전 시간';

  @override
  String get noUpcomingReleases => '예정된 릴리스가 없습니다';

  @override
  String get noRemindersSet => '미리 알림이 설정되지 않았습니다';

  @override
  String get noHiddenTitles => '숨겨진 제목이 없습니다';

  @override
  String get hiddenTitlesDescription =>
      '스포트라이트 섹션에서 숨긴 타이틀은 여기에 표시되며, 언제든지 복원할 수 있습니다.';

  @override
  String get tvShow => 'TV 프로그램';

  @override
  String get movie => '영화';

  @override
  String get aiConsentGranted => '선택했습니다. 라이브러리 데이터는 추천을 개인화하는 데 사용됩니다.';

  @override
  String get aiConsentNotGranted => '귀하의 라이브러리 데이터는 귀하가 선택하지 않는 한 공유되지 않습니다.';

  @override
  String get languageSettingExplanation =>
      '영화 및 TV 탭에서는 이를 엄격하게 사용합니다. Explore는 먼저 이를 선호하고 레일이 희박해지면 뒤로 물러납니다.';

  @override
  String get filterScreenTitle => '필터';

  @override
  String get sortBy => '정렬 기준';

  @override
  String get genres => '장르';

  @override
  String get year => '연도';

  @override
  String get rating => '평가';

  @override
  String get runtime => '런타임';

  @override
  String get withPeople => '인물 포함';

  @override
  String get voteCount => '투표 수';

  @override
  String get today => '오늘';

  @override
  String get tomorrow => '내일';

  @override
  String get yesterday => '어제';

  @override
  String get minutes => '분';

  @override
  String get hours => '시간';

  @override
  String get cast => '출연진';

  @override
  String get crew => '제작진';

  @override
  String get director => 'F@ 출연진 @G@ 제작진 @H@ 감독';

  @override
  String get seasons => '시즌';

  @override
  String get episodes => '에피소드';

  @override
  String get overview => '개요';

  @override
  String get similar => '유사한';

  @override
  String get recommendations => '추천';

  @override
  String get addedToWatchlist => '관심 목록에 추가됨';

  @override
  String get removedFromWatchlist => '관심 목록에서 제거됨';

  @override
  String get popularity => '인기';

  @override
  String get releaseDate => '출시 날짜';

  @override
  String get revenueLabel => '수익';

  @override
  String get originalTitle => '원본 제목';

  @override
  String get voteAverage => '투표 평균';

  @override
  String get favourites => '즐겨찾기';

  @override
  String get lists => '기울기';

  @override
  String get watched => '봤어요';

  @override
  String get all => '모두';

  @override
  String get tv => 'TV';

  @override
  String get librarySubtitle => '컬렉션, 즐겨찾기, 메모, 시청 기록별로 모든 것을 정리하세요.';

  @override
  String get selectRegion => '지역을 선택하세요';

  @override
  String get selectRegionDescription =>
      '지역 인식 쿼리를 지원하는 TMDb 엔드포인트만 이 옵션을 사용합니다.';

  @override
  String get useAutoDetectedRegion => '자동 감지된 영역 사용';

  @override
  String get reminderRemoved => '알림이 삭제되었습니다';

  @override
  String releaseReminderSet(String title) {
    return '$title에 대한 릴리스 알림이 설정되었습니다.';
  }

  @override
  String episodeReminderSet(String title) {
    return '$title 에피소드에 대한 알림이 설정되었습니다.';
  }

  @override
  String get filteredResults => '필터링된 결과';

  @override
  String get genreResults => '장르별 결과';

  @override
  String couldNotLoadContent(String error) {
    return '콘텐츠를 불러올 수 없습니다. $error';
  }

  @override
  String get noContentAvailableForThisSelection => '해당 항목에 대한 콘텐츠가 없습니다.';

  @override
  String get writer => '작가';

  @override
  String get actors => '배우들';

  @override
  String get noteNotFound => '메모를 찾을 수 없습니다.';

  @override
  String yourNotesCount(int count) {
    return '귀하의 메모($count)';
  }

  @override
  String get noteDeleted => '메모 삭제됨';

  @override
  String noteDeletedWithCount(int count) {
    return '메모 삭제됨($count s)';
  }

  @override
  String get loadMore => '더 보기';

  @override
  String get noMoreProductionsFound => '더 이상 제작물을 찾을 수 없습니다.';

  @override
  String get noProductionsFound => '제작된 콘텐츠를 찾을 수 없습니다.';

  @override
  String get watchInsights => '이 앱 라벨을 ko로 번역하세요: Watch Insights';

  @override
  String get analyzingWatchHistory => '시청 기록을 분석합니다...';

  @override
  String get manageHiddenTitlesDescription => 'Spotlight 섹션에서 숨긴 타이틀을 관리하세요.';

  @override
  String get tmdbLanguageMetadataNote =>
      '이 모드에서 일부 항목이 드문드문 보일 수 있는데, 이는 해당 제목이 존재하지 않아서가 아니라 카탈로그의 일부에 대한 TMDB 언어 메타데이터가 불완전하기 때문입니다.';

  @override
  String get tmdbDisclaimer => '이 제품은 TMDB API를 사용하지만 TMDB의 승인이나 인증을 받지 않았습니다.';

  @override
  String get useLocalLibraryForSync => '동기화에 로컬 라이브러리를 사용하시겠습니까?';

  @override
  String get themePresets => '테마 사전 설정';

  @override
  String get exitApp => '앱 종료';

  @override
  String get popular => '인기 있는';

  @override
  String couldNotLoadReminders(String error) {
    return '미리 알림을 불러올 수 없습니다.\n\n$error';
  }

  @override
  String get noRemindersSetYet =>
      '아직 알림이 설정되지 않았습니다.\n에피소드 추적기 또는 영화 세부 정보에서 알림을 생성하세요.';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return '에피소드 S$seasonNumber • E$episodeNumber';
  }

  @override
  String get movieRelease => '영화 개봉';

  @override
  String voteAverageStars(String voteAverage) {
    return '이 앱 라벨을 ko로 번역하세요: $voteAverage ★';
  }

  @override
  String get addMoreTrackedContent => '시청 목록, 즐겨찾기 또는 기타 목록에 영화나 프로그램을 추가하세요.';

  @override
  String get fastPicksDescription => '이미 저장한 항목을 기반으로 빠르게 추천해 드립니다.';

  @override
  String get releaseCalendarDescription =>
      '영화 개봉일과 다음 TV 에피소드 방영 예정일을 한 번의 탭으로 알림을 받으세요.';

  @override
  String get staleWatchlist => '오래된 관심 목록';

  @override
  String get tracked => '추적됨';

  @override
  String get upcoming => '다가오는';

  @override
  String get upcomingEmptyDescription =>
      '추적 중인 영화의 개봉일이 확정되거나 프로그램의 새 에피소드 방영 일정이 잡히면 여기에 표시됩니다.';

  @override
  String get howManyMoviesWatchedEachMonth => '한 달에 영화를 몇 편이나 보셨나요?';

  @override
  String get howPersonalRatingsShifting => '개인 평점이 시간이 지남에 따라 어떻게 변화하는지 살펴보세요';

  @override
  String get keepWatchingToBuildProfile => '계속 시청하시면 시각적 프로필을 구축하는 데 도움이 됩니다.';

  @override
  String get lumiWatchAnalytics => '루미 워치 분석';

  @override
  String get noGenreDistributionYet => '장르별 분류 정보가 아직 제공되지 않았습니다.';

  @override
  String get noMovieWatchHistoryRecentMonths => '최근 몇 달간 영화 시청 기록이 없습니다.';

  @override
  String get noRatingTrendDataYet => '아직 시청률 추이 데이터가 없습니다.';

  @override
  String get preferredRuntime => '선호하는 런타임';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return '권장 실행 시간은 약 $minutes분($label)입니다.';
  }

  @override
  String get styledCardWithWatchStats => '시계 통계가 담긴 스타일리시한 카드';

  @override
  String get titlesAnalyzed => '분석된 제목';

  @override
  String get tryAgainAfterMoment => '잠시 후 다시 시도해 주세요.';

  @override
  String get watchAnalytics => '분석 보기';

  @override
  String get whatGenresDominateHistory =>
      '당신의 시계 시청 기록에서 가장 많은 부분을 차지하는 장르는 무엇인가요?';

  @override
  String get toggleMovies => '영화 산업';

  @override
  String get toggleTv => 'TV';

  @override
  String get noMoreTitlesFound => '더 이상 제목을 찾을 수 없습니다.';

  @override
  String get noTitlesFoundForKeyword => '해당 키워드로 검색된 제목이 없습니다.';

  @override
  String get viewFull => '전체 보기';

  @override
  String get accoladeDetails => '수상 내역';

  @override
  String get noDetailedAwardsInfo => '수상 관련 상세 정보는 없습니다.';

  @override
  String get alertSet => '경보 설정 완료!';

  @override
  String get budget => '예산';

  @override
  String get buy => '구입하다';

  @override
  String chooseBetweenHours(int maxHours) {
    return '1과 $maxHours 중에서 선택하세요';
  }

  @override
  String get deleteNoteConfirmationTitle => '메모를 삭제하시겠습니까?';

  @override
  String get episodeReminder => '에피소드 알림';

  @override
  String get facebook => '페이스북';

  @override
  String get free => '무료';

  @override
  String get images => '이미지';

  @override
  String get instagram => '인스타그램';

  @override
  String get netProfit => '순이익';

  @override
  String get noNotesYet => '아직 댓글이 없습니다. 여러분의 생각을 남겨주세요!';

  @override
  String get originalLanguage => '원어';

  @override
  String partOfCollection(String collectionName) {
    return '$collectionName의 일부';
  }

  @override
  String get roi => '투자수익률(ROI)';

  @override
  String releaseAlertSet(String date) {
    return '$date에 대한 릴리스 알림이 설정되었습니다.';
  }

  @override
  String get rent => '임차료';

  @override
  String get revenue => '수익';

  @override
  String seeAllReviews(int count) {
    return '모두 보기 ($count)';
  }

  @override
  String get setReminder => '알림 설정';

  @override
  String get status => '상태';

  @override
  String get stream => '개울';

  @override
  String get tikTok => '틱톡';

  @override
  String get twitterX => '엑스';

  @override
  String get yours => '당신 것';

  @override
  String get youtube => '유튜브';

  @override
  String get durationDays => '디';

  @override
  String get durationHours => '시간';

  @override
  String get durationMinutes => '중';

  @override
  String get durationSeconds => '에스';

  @override
  String seasonRating(String score) {
    return '이 앱 라벨을 ko로 번역하세요: ★ $score%';
  }

  @override
  String get we => '우리';

  @override
  String get aspect16x9 => '이 앱 라벨을 ko: 16:9로 번역하세요';

  @override
  String get aspect9x16 => '9시 16분';

  @override
  String get background => '배경';

  @override
  String episodeCount(int count) {
    return '이 앱 라벨을 ko로 번역하세요: $count Eps';
  }

  @override
  String get noEpisodesForSeason => '이번 시즌의 에피소드를 찾을 수 없습니다.';

  @override
  String get beautifulStyledCardForStories => '사회적 이야기를 위한 아름다운 디자인의 카드';

  @override
  String get clickableShareLink => 'WhatsApp 및 기타 앱에서 공유 가능한 클릭 가능한 링크';

  @override
  String get placeQuoteOnBackdrop => '좋아하는 명언을 영화 배경에 넣어보세요';

  @override
  String get standardLinkToMovieDatabase => '영화 데이터베이스에 대한 표준 링크';

  @override
  String get exploreLabel => '탐구하다';

  @override
  String quoteCharacter(String character) {
    return '이 앱 라벨을 ko로 번역하세요: — $character';
  }

  @override
  String get aiTonightWatch => '오늘 밤 AI 시청하기';

  @override
  String get aiQueryPlan => 'AI 쿼리 계획';

  @override
  String get airingToday => '오늘 방송되는';

  @override
  String get bigCrowdPleasers => '대중적인 인기를 얻으며 상승세를 타고 있는';

  @override
  String get cinematic => '시네마틱';

  @override
  String get comingSoon => '곧 출시 예정';

  @override
  String get currentTheatricalSlate => '현재 극장 개봉 예정작 및 가까운 시일 내에 개봉 예정작';

  @override
  String get dark => '어두운';

  @override
  String get discoverSpotlight => '스포트라이트를 만나보세요';

  @override
  String get edgeOfYourSeat => '손에 땀을 쥐게 하는';

  @override
  String get fastPaced => '빠른 속도';

  @override
  String get feelGood => '기분 좋은';

  @override
  String get freshPicksContinuous => '새로운 추천 상품이 지속적으로 업데이트됩니다.';

  @override
  String get hideTitle => '제목 숨기기';

  @override
  String get highRatedSkipped => '평점은 높지만 시청자들이 가장 많이 건너뛰는 작품들';

  @override
  String get hotNowAudience => '지금 시청자 피드에서 가장 인기 있는 콘텐츠입니다.';

  @override
  String get inTheaters => '극장에서 상영 중';

  @override
  String get indie => '인디';

  @override
  String get mindBending => '정신을 혼란스럽게 하는';

  @override
  String get mostDiscussedShowsThisWeek => '이번 주 가장 많이 언급된 프로그램';

  @override
  String get multiplePicks => '여러 선택';

  @override
  String get onTheAir => '방송 중';

  @override
  String get personalizedFromWatchBehavior => '사용자의 시계 사용 패턴을 기반으로 맞춤 설정됩니다.';

  @override
  String get pickAVibe => '원하는 분위기를 고르면 그에 맞는 제목을 바로 받아볼 수 있습니다.';

  @override
  String get seeAll => '모두 보기';

  @override
  String get seriesCurrentlyAiring => '현재 방영 중인 에피소드가 있는 시리즈';

  @override
  String get thisWeek => '이번 주';

  @override
  String get topRated => '최고 평점';

  @override
  String get voiceInput => '음성 입력';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% 일치';
  }

  @override
  String runtimeMinutes(String minutes) {
    return '$minutes 분';
  }

  @override
  String get examplePrompt => '예시: 영화 \'인터스텔라\' 같은 건데, SF는 아닌.';

  @override
  String findingYourPerfectWatch(String dots) {
    return '완벽한 시계 찾기$dots';
  }

  @override
  String get moreLikeThis => '이와 유사한 콘텐츠 더 보기';

  @override
  String get notForMe => '저한테는 안 맞네요';

  @override
  String get recentQueries => '최근 검색어';

  @override
  String get shufflingIdeas => '아이디어를 섞어보는 중...';

  @override
  String get tooMainstream => '너무 주류적이다';

  @override
  String get whatShouldIWatchTonight => '오늘 밤 뭐 볼까?';

  @override
  String debugLogEntry(String time, String message) {
    return '이 앱 라벨을 ko로 번역하세요: [$time] $message';
  }

  @override
  String get from => '에서';

  @override
  String get to => '에게';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return '관심 목록에서 삭제됨($seconds s)';
  }

  @override
  String creditsCount(String count) {
    return '$count 크레딧';
  }

  @override
  String get acrossFilmography => '영화 작품 전반에 걸쳐';

  @override
  String get birthplace => '출생지';

  @override
  String get born => '태어나다';

  @override
  String get credits => '크레딧';

  @override
  String get died => '죽었다';

  @override
  String get knownFor => '~로 알려져 있음';

  @override
  String get noSharedTitlesAvailable => '공유된 타이틀이 없습니다.';

  @override
  String get photos => '사진';

  @override
  String get personRating => '평가';

  @override
  String get taggedImages => '태그된 이미지';

  @override
  String get website => '웹사이트';

  @override
  String get noQuotesFound => '인용문을 찾을 수 없습니다.';

  @override
  String get noSectionsFound => '섹션을 찾을 수 없습니다.';

  @override
  String get clearAll => '모두 지우기';

  @override
  String get noCollectionsFound => '컬렉션을 찾을 수 없습니다.';

  @override
  String get noCompaniesFound => '회사 정보를 찾을 수 없습니다.';

  @override
  String get noKeywordsFound => '키워드를 찾을 수 없습니다.';

  @override
  String get noMoreResultsFound => '더 이상 검색 결과가 없습니다.';

  @override
  String get noResultsFound => '검색 결과가 없습니다.';

  @override
  String deleteListConfirmation(String listName) {
    return '$listName을 정말로 삭제하시겠습니까?';
  }

  @override
  String get deleteListTitle => '삭제 목록?';

  @override
  String get everythingYouPlanToWatch => '다음에 시청할 영상 목록입니다.';

  @override
  String get finishedTitlesAndHistory => '완료한 타이틀과 함께 플레이 기록 및 통계를 확인하세요.';

  @override
  String get noListsCreatedYet => '아직 생성된 목록이 없습니다.';

  @override
  String get noNotesFound => '메모를 찾을 수 없습니다.';

  @override
  String get renameList => '목록 이름 변경';

  @override
  String get titlesYouNeverWantToLose => '절대 잃고 싶지 않은 타이틀들.';

  @override
  String get yourThoughtsReactions => '여러분의 생각, 반응, 그리고 알림 사항입니다.';

  @override
  String imageCounter(String current, String total) {
    return '이 앱 라벨을 ko로 번역하세요: $current / $total';
  }

  @override
  String get removeFromWatchedConfirmation => '시청 목록에서 이 항목을 삭제하시겠습니까?';

  @override
  String get savedAsWatchedWithoutRating => '이 영상은 개인 평점 없이 시청한 것으로 저장됩니다.';

  @override
  String get noAdditionalRecommendationTrailers => '추가 추천 예고편을 찾을 수 없습니다.';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return '이 앱 라벨을 ko로 번역하세요: $count $itemLabel';
  }

  @override
  String get invalidSharedListLink =>
      '해당 링크는 유효하지 않거나, 만료되었거나, 더 이상 접속할 수 없을 수 있습니다.';

  @override
  String get noTitlesAvailableToImport => '현재 수입 가능한 타이틀이 없습니다.';

  @override
  String get allLanguages => '모든 언어';

  @override
  String get arabic => '아라비아 말';

  @override
  String get bengali => '벵골 사람';

  @override
  String get chinese => '중국인';

  @override
  String get english => '영어';

  @override
  String get french => '프랑스 국민';

  @override
  String get german => '독일 사람';

  @override
  String get gujarati => '구자라트어';

  @override
  String get hindi => '힌디 어';

  @override
  String get indonesian => '인도네시아 인';

  @override
  String get italian => '이탈리아 사람';

  @override
  String get japanese => '일본어';

  @override
  String get kannada => '칸나다어';

  @override
  String get korean => '한국인';

  @override
  String get malayalam => '말라얄람어';

  @override
  String get marathi => '마라티어';

  @override
  String get persian => '페르시아 인';

  @override
  String get polish => '광택';

  @override
  String get portuguese => '포르투갈 인';

  @override
  String get punjabi => '펀자브어';

  @override
  String get russian => '러시아인';

  @override
  String get spanish => '스페인 사람';

  @override
  String get swedish => '스웨덴어';

  @override
  String get tamil => '타밀 사람';

  @override
  String get telugu => '텔루구어';

  @override
  String get thai => '태국';

  @override
  String get turkish => '터키어';

  @override
  String get urdu => '우르두어';

  @override
  String get vietnamese => '베트남 사람';

  @override
  String get failedToLoadCollectionDetails => '컬렉션 세부 정보를 불러오는 데 실패했습니다.';

  @override
  String get franchiseProgress => '프랜차이즈 발전';

  @override
  String get officialSite => '공식 사이트';

  @override
  String get productions => '프로덕션';

  @override
  String get productionCompany => '제작사';

  @override
  String get failedToLoadCompanyInfo => '회사 정보를 불러오는 데 실패했습니다.';

  @override
  String get profile => '윤곽';

  @override
  String get guestViewer => '게스트 시청자';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      '사용자 프로필, 동기화 상태, 지역 및 시각적 설정이 모두 여기에 저장됩니다.';

  @override
  String get signInToSync => '로그인하여 시청 목록, 평점 및 선호 사항을 동기화하세요.';

  @override
  String get signedInAndSyncing => '로그인 후 클라우드와 동기화 중입니다.';

  @override
  String get developedBy => '개발자:';

  @override
  String get couldNotAnalyzeWatchHistory => '지금은 시청 기록을 분석할 수 없습니다.';

  @override
  String get includeLocalLibrary => '지역 도서관 포함';

  @override
  String get useCloudOnly => '클라우드 전용 사용';

  @override
  String get localLibrarySyncDescription =>
      '이 기기에는 이미 로컬 라이브러리에 저장된 도서가 있습니다. 로그인한 라이브러리에 추가하거나, 로컬 라이브러리 데이터를 클라우드 라이브러리 데이터로 교체하세요.';

  @override
  String get mergedLocalTitles => '로그인한 라이브러리에 로컬 타이틀을 통합했습니다.';

  @override
  String get replacedLocalLibrary => '로컬 라이브러리 데이터를 클라우드 라이브러리 데이터로 교체했습니다.';

  @override
  String get deleteAccountConfirmation =>
      '이렇게 하면 Lumi 계정과 동기화된 클라우드 데이터가 영구적으로 삭제됩니다. 기기에 저장된 로컬 데이터는 앱 데이터를 별도로 삭제하지 않는 한 유지됩니다.';

  @override
  String get signedOutAndCleared => '이 기기에서 로그아웃하고 로컬 라이브러리를 삭제했습니다.';

  @override
  String get keepLocalLibrary => '지역 도서관을 계속 이용하세요';

  @override
  String get clearLocalLibrary => '클리어 로컬 라이브러리';

  @override
  String get signOutChoiceDescription =>
      '로그아웃 후 이 기기에 로컬 라이브러리를 유지할지 여부를 선택하세요.';

  @override
  String get disable => '장애를 입히다';

  @override
  String get aiRecommendationsEnabled => 'AI 추천 데이터 공유 기능이 활성화되었습니다.';

  @override
  String get aiRecommendationsDisabled => 'AI 추천 데이터 공유가 비활성화되었습니다.';

  @override
  String get reviewAndManageConsent =>
      'AI 제공업체에 라이브러리 데이터를 전송하기 위한 동의를 검토하고 관리합니다.';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      '활성화됨. 오늘 밤 추천 기능은 사용자의 도서관 요약 정보와 최근 검색 내역을 AI 제공업체에 전송할 수 있습니다.';

  @override
  String basedOnWatchedTitles(String count) {
    return '$count개의 시청한 타이틀을 기준으로 함';
  }

  @override
  String lastUpdated(String date) {
    return '최종 업데이트: $date';
  }

  @override
  String get chooseYourVibe => '원하는 분위기를 선택하세요';

  @override
  String get appearanceDescription =>
      '앱의 동작 방식을 변경하지 않고 영화 속 캐릭터처럼 앱을 전환할 수 있습니다.';

  @override
  String get exitAppConfirmation => 'Lumi를 종료하시겠습니까?';

  @override
  String get dismiss => '해고하다';

  @override
  String get generatingWatchAnalytics => 'Watch 분석 생성';

  @override
  String get thisUsuallyTakesAFewSeconds => '이 과정은 보통 몇 초 정도 소요됩니다.';

  @override
  String get yourScreenStory => '당신의 스크린 스토리';

  @override
  String get snapshotOfHowAndWhatYouWatch => '당신이 무엇을 어떻게 시청하는지에 대한 간략한 개요';

  @override
  String get yourFavoriteGenres => '당신이 좋아하는 장르';

  @override
  String get genrePerformanceHighestRated => '장르별 성과 (최고 평점)';

  @override
  String get personalizedViewingPatterns => '개인 맞춤형 시청 패턴';

  @override
  String get builtWithLumi => 'Lumi로 제작되었습니다';

  @override
  String get sharedWithLumi => '루미와 공유함';

  @override
  String get shareAnalytics => '공유 분석';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return '$count 제목 분석 완료 • $date 업데이트 완료';
  }

  @override
  String get allSeasons => '모든 계절';

  @override
  String get castAndCrew => '출연진 및 제작진';

  @override
  String get featuredCrew => '주요 출연진';

  @override
  String get stills => '스틸컷';

  @override
  String get accoladeSummary => '수상 내역 요약';

  @override
  String get awardsAndAccolades => '수상 및 표창';

  @override
  String get unableToLoadMovieDetails => '영화 정보를 불러올 수 없습니다';

  @override
  String get overviewUnavailable => '이 작품에 대한 개요를 사용할 수 없습니다.';

  @override
  String get openCompletePlot => 'OMDb에서 전체 줄거리 및 추가 메타데이터를 확인하세요.';

  @override
  String get noOverviewForSeason => '이번 시즌에 대한 개요는 제공되지 않습니다.';

  @override
  String get userScore => '사용자 평점';

  @override
  String get playTrailer => '예고편 재생';

  @override
  String get whereToWatch => '어디서 시청할 수 있나요?';

  @override
  String get availabilityDataByJustWatch => 'JustWatch에서 제공하는 이용 가능 여부 데이터입니다.';

  @override
  String get reminderSaved => '알림이 저장되었습니다';

  @override
  String reminderForTitle(String title) {
    return '$title님께 드리는 알림입니다';
  }

  @override
  String get pleaseSelectFutureTime => '미래의 시간을 선택해 주세요.';

  @override
  String get notifyAt => '다음 주소로 알리세요';

  @override
  String get notifyHoursBeforeAiring => '방송 몇 시간 전에 알려줘야 하나요?';

  @override
  String enterNumberBetween(String maxHours) {
    return '1부터 $maxHours 사이의 숫자를 입력하세요.';
  }

  @override
  String get set => '세트';

  @override
  String get selectedReminderTimePassed => '선택하신 알림 시간이 이미 지났습니다.';

  @override
  String episodeReminderSaved(String date) {
    return '$date 에피소드 알림이 저장되었습니다.';
  }

  @override
  String get areYouSureDeleteNote => '이 메모를 정말 삭제하시겠습니까?';

  @override
  String get noteAdded => '메모 추가됨';

  @override
  String get lastSeason => '지난 시즌';

  @override
  String get currentSeason => '현재 시즌';

  @override
  String get viewAllSeasons => '모든 계절 보기';

  @override
  String get removedFromFavourites => '즐겨찾기에서 삭제됨';

  @override
  String get addedToFavourites => '즐겨찾기에 추가됨';

  @override
  String get awardsAndNominations => '수상 및 후보 지명';

  @override
  String get viewAll => '모두 보기';

  @override
  String get boxOfficeFinancials => '박스오피스 재무 정보';

  @override
  String get successMeter => '성공률 측정기';

  @override
  String get blockbuster => '블록버스터';

  @override
  String get hit => '때리다';

  @override
  String get breakEven => '손익분기점';

  @override
  String get underperformer => '실적 부진자';

  @override
  String get boxOfficeBomb => '흥행 참패';

  @override
  String get episodeTracker => '에피소드 추적기';

  @override
  String get setAiringReminder => '방송 알림 설정';

  @override
  String get nextEpisodeCountdown => '다음 에피소드 카운트다운';

  @override
  String get nextEpisode => '다음 에피소드';

  @override
  String get lastEpisodeToAir => '마지막 회 방송';

  @override
  String get unknown => '알려지지 않은';

  @override
  String get contentAdvisory => '콘텐츠 자문';

  @override
  String get violence => '폭행';

  @override
  String get sexAndNudity => '성 및 노출';

  @override
  String get foulLanguage => '언어';

  @override
  String get substances => '물질';

  @override
  String get fearAndHorror => '공포와 호러';

  @override
  String get familyFriendly => '가족 친화적';

  @override
  String get generalAudience => '일반 관객';

  @override
  String get releaseTimeline => '출시 일정';

  @override
  String get notifyMe => '알림 받기';

  @override
  String get theatricalRelease => '극장 개봉';

  @override
  String get digitalStreaming => '디지털/스트리밍';

  @override
  String get physicalRelease => '실물 (블루레이/DVD)';

  @override
  String get awesome => '엄청난';

  @override
  String get keywordsAndThemes => '키워드 및 테마';

  @override
  String get videosAndBehindTheScenes => '영상 및 비하인드 스토리';

  @override
  String get productionStudios => '프로덕션 스튜디오';

  @override
  String get fetchingWatchLink => '시계 링크 가져오는 중';

  @override
  String get findingBestProviderPage => '이 게임에 가장 적합한 제공업체 페이지를 찾고 있습니다.';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode';
  }

  @override
  String get error => '오류';

  @override
  String get failedToLoadSeasonDetails => '시즌 세부 정보를 불러오는 데 실패했습니다.';

  @override
  String get loading => '로딩 중...';

  @override
  String runtimeSeparator(String runtime) {
    return '이 앱 라벨을 ko로 번역하세요: • $runtime';
  }

  @override
  String get fullCastAndCrew => '전체 출연진 및 제작진';

  @override
  String get shareMovie => '영화 공유하기';

  @override
  String get quotes => '인용 부호';

  @override
  String get mayIncludeMismatches => '어휘 인용 검색으로 인해 간혹 불일치가 발생할 수 있습니다.';

  @override
  String get movieApiConfigurationRequired => '영화 API 구성이 필요합니다';

  @override
  String get addMovieProxyBaseUrl =>
      '앱을 TMDB 프록시에 연결하려면 MOVIE_PROXY_BASE_URL을 추가하세요.';

  @override
  String get cinematicPicksContext =>
      '즉각적인 분위기를 느낄 수 있는 영화 같은 장면들을 골라보세요. 또 다른 깜짝 카드를 위해 주사위를 굴려보세요.';

  @override
  String get curatedTonight => '오늘 밤 엄선된 콘텐츠';

  @override
  String curatedTonightTitle(String title) {
    return '오늘 밤 엄선된 콘텐츠: $title';
  }

  @override
  String get describeItYourWay => '원하는 방식으로 설명해 주세요.\n저희가 가장 적합한 결과를 찾아드립니다.';

  @override
  String get hide => '숨다';

  @override
  String get hideTitleDescription => '이 제목을 숨기면 향후 스포트라이트 섹션에 표시되지 않습니다.';

  @override
  String get dontAskAgain => '다시 묻지 마세요';

  @override
  String get imdbNa => 'IMDb 해당 없음';

  @override
  String get noDiscoverPicks => '현재 추천 상품이 없습니다.';

  @override
  String get playPreview => '플레이 미리보기';

  @override
  String get recommendedForYou => '추천 콘텐츠';

  @override
  String get spotlightCompleted => '스포트라이트 완료';

  @override
  String get startAddingTitlesForRecommendations => '추천 항목에 제목을 추가해 보세요';

  @override
  String get clearedAllChoices => '스와이프하여 디스커버 피드의 모든 항목을 지웠습니다.';

  @override
  String get whatsPopular => '인기 있는 것';

  @override
  String get trending => '인기 급상승';

  @override
  String get nowPlaying => '지금 재생 중';

  @override
  String get tvTrending => 'TV 인기';

  @override
  String get discoverByMood => '기분별로 찾아보세요';

  @override
  String get needSomethingToWatchTonight => '오늘 밤 볼 만한 거 찾으세요?';

  @override
  String get needAMovieForTonight => '오늘 밤 볼 영화 필요하세요?';

  @override
  String get tryAiShows => 'AI 쇼를 시청해 보세요';

  @override
  String get tryAiMovies => 'AI 영화를 시도해 보세요';

  @override
  String get findShows => '쇼 찾기';

  @override
  String get findMovies => '영화 찾기';

  @override
  String get couldNotLoadThisRail => '이 레일을 로드할 수 없습니다.';

  @override
  String get temporaryIssueLoadingRail => '이 레일을 적재하는 데 일시적인 문제가 발생했습니다.';

  @override
  String get noTitlesHereYet => '아직 제목이 없습니다';

  @override
  String get noHiddenGemsForGenre =>
      '이 장르에서는 아직 숨겨진 명작을 찾지 못했습니다. 다른 장르를 시도해 보세요.';

  @override
  String get tryAnotherFilter => '다른 필터를 사용하거나 이 섹션을 열어 더 폭넓은 검색 결과를 확인해 보세요.';

  @override
  String get seeAllFilters => '모든 필터 보기';

  @override
  String get couldNotLoadCuratedPicks => '엄선된 추천 항목을 불러올 수 없습니다.';

  @override
  String get temporaryIssueLoadingCurated =>
      '오늘 밤 엄선된 목록을 불러오는 데 일시적인 문제가 발생했습니다.';

  @override
  String get noCuratedPicksAvailable => '추천 상품이 없습니다.';

  @override
  String get tryAgainWhileRefresh =>
      '오늘 밤 TMDB 목록을 새로 고치는 동안 잠시 후에 다시 시도해 주세요.';

  @override
  String get fromSpotlight => '스포트라이트에서';

  @override
  String get addShowsMoviesForRecommendations =>
      'TV 프로그램/영화를 시청 목록, 즐겨찾기 또는 시청 완료 목록에 추가하여 좋아할 만한 작품들을 확인해 보세요.';

  @override
  String get allow => '허용하다';

  @override
  String get notNow => '지금은 안 돼';

  @override
  String get allowAiDataSharingTitle => 'AI 데이터 공유를 허용하시겠습니까?';

  @override
  String get allowAiDataSharingDescription =>
      '오늘 밤 추천 기능은 영화 추천 요청을 위해 입력한 텍스트와 임시 검색어 입력 정보를 Google Gemini 및 OpenRouter로 전송합니다. 사용자의 전체 라이브러리 정보와 로그인 정보는 이러한 AI 제공업체로 전송되지 않습니다. AI 추천을 위해 데이터 공유를 허용하시겠습니까?';

  @override
  String get liveProgress => '실시간 진행 상황';

  @override
  String percentComplete(String percent) {
    return '$percent% 완료';
  }

  @override
  String get describeIdealShowNight => '당신이 생각하는 이상적인 공연 관람 환경을 묘사해 보세요.';

  @override
  String get describeIdealMovieNight => '당신이 생각하는 이상적인 영화 감상 시간을 묘사해 보세요.';

  @override
  String get useNaturalLanguage =>
      '자연어를 사용하세요. 원하는 것, 피해야 할 것, 그리고 선택적으로 언어/실행 시간 힌트를 언급하세요.';

  @override
  String get listeningTapMicToStop => '듣는 중입니다... 마이크를 다시 탭하면 멈춥니다.';

  @override
  String voiceInputError(String error) {
    return '음성 입력 오류: $error';
  }

  @override
  String get tapMicToDictate => '마이크를 탭하여 요청 사항을 음성으로 전달하세요.';

  @override
  String get tapMicToEnableVoice => '마이크를 탭하여 음성 입력을 활성화하세요.';

  @override
  String get findingShows => '쇼 찾기...';

  @override
  String get findingMovies => '영화 찾기...';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return '오늘 밤 Lumi 추천 제품: $prompt';
  }

  @override
  String get tonightsPicks => '오늘 밤의 추천';

  @override
  String get sharedFromLumi => 'Lumi에서 공유함';

  @override
  String get intent => '의지:';

  @override
  String get genreLabel => '장르:';

  @override
  String get avoid => '피하다:';

  @override
  String get languageLabel => '언어:';

  @override
  String runtimeAtMost(String minutes) {
    return '실행 시간 <= $minutes분';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return '실행 시간 >= $minutes분';
  }

  @override
  String get yearLabel => '년도:';

  @override
  String yearAfter(String year) {
    return '$year 이후';
  }

  @override
  String yearBefore(String year) {
    return '$year 이전';
  }

  @override
  String get like => '좋다:';

  @override
  String get signal => '신호:';

  @override
  String get readingWatchedHistory => '시청 기록을 읽는 중...';

  @override
  String get findingTopGenres => '내가 가장 좋아하는 장르와 패턴을 찾아보세요...';

  @override
  String get buildingTrends => '월별 및 평점 추세 분석...';

  @override
  String get writingInsights => '나만의 개인적인 생각을 적어보세요...';

  @override
  String get applyFilters => '필터 적용';

  @override
  String get includeNotRated => '평가되지 않음 포함';

  @override
  String get errorLoadingTvGenres => 'TV 장르 불러오기 오류';

  @override
  String get alsoKnownAs => '다른 이름으로는 다음과 같습니다.';

  @override
  String get biography => '전기';

  @override
  String get careerStatistics => '경력 통계';

  @override
  String get frequentlyCollaboratesWith => '자주 협업하는 대상';

  @override
  String get notableQuotes => '주목할 만한 명언';

  @override
  String get primaryRole => '주요 역할';

  @override
  String get averageRating => '평균 평점';

  @override
  String get topGenre => '인기 장르';

  @override
  String get peakBoxOffice => '최고 박스오피스';

  @override
  String percentOfTitles(String percent) {
    return '$percent%의 제목';
  }

  @override
  String sharedTitleCount(String count) {
    return '$count 공유 제목(들)';
  }

  @override
  String billingOrder(String order) {
    return '청구 번호 #$order';
  }

  @override
  String get startTypingToSearch => '검색하려면 입력을 시작하세요.';

  @override
  String get movieDiscoveryMadePersonal => '개인적인 경험으로 거듭난 영화 발견';

  @override
  String get allNotes => '모든 메모';

  @override
  String get viewPersonalizedInsights => '개인 맞춤형 분석 정보, 차트 및 추세를 확인하세요.';

  @override
  String get curatedCollections => '엄선된 컬렉션';

  @override
  String get list => '목록';

  @override
  String get openList => '오픈 리스트';

  @override
  String get thisListNoLongerExists => '이 목록은 더 이상 존재하지 않습니다.';

  @override
  String listRenamed(String name) {
    return '목록 이름이 $name으로 변경되었습니다.';
  }

  @override
  String listDeleted(String name) {
    return '목록 $name이 삭제되었습니다.';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return '관심 목록에 $filter이 없습니다.';
  }

  @override
  String noFilterInFavourites(String filter) {
    return '즐겨찾기에 $filter이 없습니다.';
  }

  @override
  String noFilterInWatched(String filter) {
    return '$filter은 시청하지 않았습니다.';
  }

  @override
  String noFilterInThisList(String filter) {
    return '이 목록에는 $filter이 없습니다.';
  }

  @override
  String noListsWithFilter(String filter) {
    return '$filter이 포함된 목록이 없습니다.';
  }

  @override
  String importedInto(String name) {
    return '\"$name\"으로 수입됨';
  }

  @override
  String get couldNotImportList => '목록을 가져올 수 없습니다.';

  @override
  String get importing => '가져오는 중...';

  @override
  String get couldNotLoadSharedList => '공유 목록을 불러올 수 없습니다.';

  @override
  String get editWatchedInfo => '시청 정보 수정';

  @override
  String get watchDate => '시계 날짜';

  @override
  String get rewatchCount => '다시보기 횟수';

  @override
  String get watchedInfoUpdated => '시청 정보가 업데이트되었습니다.';

  @override
  String removedFromList(String listName) {
    return '$listName에서 제거됨';
  }

  @override
  String addedToList(String listName) {
    return '$listName에 추가되었습니다.';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return '$listName 및 관심 목록에 추가되었습니다.';
  }

  @override
  String get moreTrailersLikeThis => '이와 유사한 예고편 더 보기';

  @override
  String get noDescriptionForTrailer => '이 예고편에 대한 설명이 없습니다.';

  @override
  String get closeTrailer => '트레일러 닫기';

  @override
  String get recommendedSeries => '추천 시리즈';

  @override
  String get recommendedMovie => '추천 영화';

  @override
  String get notEnoughDataYet => '아직 데이터가 충분하지 않습니다.';

  @override
  String addAndRateMoreTitles(String count) {
    return '분석 기능을 사용하려면 최소 $count개의 타이틀을 추가하고 평가해 주세요.';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return '시청하신 타이틀은 $watchedCount/$requiredCount개입니다. 분석 기능을 사용하려면 $remaining개를 더 추가하세요.';
  }

  @override
  String get moviesPerMonth => '월별 영화 편수';

  @override
  String get genreDistribution => '장르 분포';

  @override
  String get ratingTrends => '평점 추세';

  @override
  String get noData => '데이터 없음';

  @override
  String get myLatestWatchAnalytics => 'Lumi에서 확인한 최신 시계 분석 정보입니다.';

  @override
  String get myWatchInsights => 'Lumi에 대한 제 시계 관련 의견입니다.';

  @override
  String get infographicsCard => '인포그래픽 카드';

  @override
  String get watchInsightsSnapshot => '시계 인사이트 스냅샷';

  @override
  String get availableOnceInsightsReady => '분석 결과가 준비되는 대로 이용 가능합니다.';

  @override
  String get shareYourWatchInsights => '시계에 대한 인사이트를 공유하세요';

  @override
  String get recentlyWatchedVibe => '최근 시청한 영상 Vibe';

  @override
  String get mixedAcrossGenres => '다양한 장르가 혼합되어 있습니다.';

  @override
  String get moviesPerMonthShort => '영화 편수 / 월';

  @override
  String get ratingTrend => '평점 추세';

  @override
  String get balanced => '균형 잡힌';

  @override
  String get noWatchNextSuggestionsYet => '아직 다음에 볼 콘텐츠 추천이 없습니다.';

  @override
  String get upcomingFromLibrary => '도서관에서 곧 출시될 예정';

  @override
  String get removeReminder => '알림 제거';

  @override
  String get remindMe => '다시 알려주세요';

  @override
  String titleReleasesToday(String title) {
    return '$title이 오늘 출시됩니다.';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle이 곧 방영됩니다.';
  }

  @override
  String get controlPremiereAlerts => '출시 알림 및 릴리스 미리 알림을 관리하세요.';

  @override
  String upcomingReleasesCount(String count) {
    return '라이브러리 전체에서 곧 출시될 $count개의 릴리스를 확인하세요.';
  }

  @override
  String sittingInWatchlist(String days) {
    return '관심 목록에 $days일 동안 머물러 있습니다.';
  }

  @override
  String get alreadyOnWatchlist => '이미 관심 목록에 추가했습니다';

  @override
  String get favouritedButNotWatched =>
      '이 게시물을 즐겨찾기에 추가했지만 아직 시청 완료로 표시하지는 않았습니다.';

  @override
  String get savedInListReady => '내 목록에 저장되어 시청할 준비가 되었습니다.';

  @override
  String get matchesTitlesYouTrack => '이미 추적 중인 제목과 일치합니다.';

  @override
  String get noOfficialSite => '공식 사이트 없음';

  @override
  String get episodeAiring => '에피소드 방영';

  @override
  String get general => '일반적인';

  @override
  String scheduledFor(String date) {
    return '$date에 예정됨';
  }

  @override
  String wasScheduledFor(String date) {
    return '$date으로 예정되어 있었습니다.';
  }

  @override
  String get noOverviewAvailable => '개요를 사용할 수 없습니다.';

  @override
  String get searchHistoryCleared => '검색 기록이 삭제되었습니다.';

  @override
  String get visualMovieCard => '비주얼 무비 카드';

  @override
  String get smartLumiLink => '스마트 루미 링크';

  @override
  String get directTmdbLink => 'TMDB 직접 링크';

  @override
  String recommendedOnLumi(String title) {
    return 'Lumi에서 추천: $title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return 'Lumi에서 $title을 확인해 보세요!\n\n$link\n\nLumi 다운로드: $appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return 'TMDB에서 $title을 확인해 보세요: $link';
  }

  @override
  String releaseAlertTitle(String title) {
    return '$title 릴리스 알림';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return '$date 릴리스 알림이 설정되었습니다. 릴리스가 완료되면 알려드리겠습니다.';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return '\"$title\"이 디지털 또는 블루레이/DVD로 출시되는 즉시 알려드리겠습니다!';
  }

  @override
  String get episodeAlreadyDueToAir => '이번 에피소드는 이미 방영 예정입니다.';

  @override
  String get reminderSetSuccessfully => '알림이 성공적으로 설정되었습니다.';

  @override
  String get speechRecognitionNotAvailable => '이 기기에서는 음성 인식 기능을 사용할 수 없습니다.';

  @override
  String get describeShowMood => '어떤 프로그램을 보고 싶은지 설명해 주시면, 순위별로 목록을 보내드리겠습니다.';

  @override
  String get describeMovieMood => '어떤 영화를 보고 싶은지 설명해 주시면, 순위별로 목록을 보내드리겠습니다.';

  @override
  String get aiLauncherDescription =>
      '자연어로 요청하거나 말하세요. Lumi는 AI 기반 검색 계획을 수립하고 벡터 검색을 실행하여 여러 개의 프로그램/영화 추천작을 제공합니다.';

  @override
  String yearRange(String from, String to) {
    return '이 앱 라벨을 ko로 번역하세요: $from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return '$count 알림이 예약되었습니다.';
  }

  @override
  String regionAutoDetected(String region) {
    return '자동 감지됨: $region';
  }

  @override
  String regionSelected(String region) {
    return '선택됨: $region';
  }

  @override
  String get allLanguagesSubtitle => '모든 언어';

  @override
  String currentlySetToLanguage(String language) {
    return '현재 $language으로 설정되어 있습니다.';
  }

  @override
  String get availabilities => '이용 가능 여부';

  @override
  String get mood => '분위기';

  @override
  String get people => '사람들';

  @override
  String get ads => '광고';

  @override
  String get theatricalLimited => '극장 유한회사';

  @override
  String get premier => '수상';

  @override
  String get mediaType => '미디어 유형';

  @override
  String get couldNotLoadAnalytics => '분석 정보를 불러올 수 없습니다.';

  @override
  String get viewAllAwards => '모두 보기';

  @override
  String get win => '이기다';

  @override
  String get wins => '승리';

  @override
  String get nomination => '지명';

  @override
  String get nominations => '후보 지명';

  @override
  String sharedBy(String name) {
    return '$name님이 공유함';
  }

  @override
  String titleCount(String count) {
    return '$count 제목(들)';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count은 목록 전체에 저장된 제목입니다.';
  }

  @override
  String get curatedCollectionsSubtitle => '엄선된 컬렉션을 정리하고 공유할 수 있습니다.';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return 'Lumi로 \"$name\" 가져오기 ($count $itemLabel): $link';
  }

  @override
  String get notEnoughData => '데이터가 부족합니다';

  @override
  String shareQuote(String title) {
    return 'Lumi의 \"$title\"님이 남긴 이 글을 확인해 보세요!';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Lumi 추천 제품: $title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      '자연어로 요청하거나 말하세요. Lumi는 AI 기반 계획을 수립하고 벡터 검색을 실행하여 여러 개의 프로그램 추천을 제공합니다.';

  @override
  String get aiLauncherDescriptionMovie =>
      '자연어로 요청하거나 말하세요. Lumi는 AI 기반 계획을 수립하고 벡터 탐색을 실행하여 여러 영화를 추천합니다.';

  @override
  String get warmingUpMovieSearch => '영화 검색을 위한 워밍업';

  @override
  String get connectingToRecommendationEngine => '추천 엔진에 연결 중';

  @override
  String get understandingYourTaste => '당신이 어떤 기분인지 파악하기';

  @override
  String get buildingCustomSearch => '귀하의 요청을 바탕으로 맞춤 검색을 생성합니다.';

  @override
  String get tinyNetworkHiccup => '네트워크에 약간의 문제가 발생했습니다. 다시 시도해 보겠습니다.';

  @override
  String get planLocked => '장르, 스타일, 언어, 러닝타임 모두 확정되었습니다.';

  @override
  String get scanningTmdb => 'TMDB에서 유사한 항목을 검색합니다.';

  @override
  String get collectingDetails => '최고의 작품들을 위해 포스터, 평점, 상영 시간을 수집했습니다.';

  @override
  String shortlistingPicksCount(String current, String total) {
    return '최종 후보 선정 ($current/$total)';
  }

  @override
  String get shortlistingBestPicks => '최고의 제품들을 추려내기';

  @override
  String get finalPolish => '추천 사항에 대한 최종 다듬기';

  @override
  String get retryingAfterIssue => '일시적인 문제 발생 후 재시도합니다';

  @override
  String get regionUnitedStates => '미국';

  @override
  String get regionIndia => '인도';

  @override
  String get regionUnitedKingdom => '영국';

  @override
  String get regionCanada => '캐나다';

  @override
  String get regionAustralia => '호주';

  @override
  String get regionNewZealand => '뉴질랜드';

  @override
  String get regionGermany => '독일';

  @override
  String get regionFrance => '프랑스';

  @override
  String get regionSpain => '스페인';

  @override
  String get regionItaly => '이탈리아';

  @override
  String get regionJapan => '일본';

  @override
  String get regionSouthKorea => '대한민국';

  @override
  String get regionBrazil => '브라질';

  @override
  String get regionMexico => '멕시코';

  @override
  String get regionSingapore => '싱가포르';

  @override
  String get regionPhilippines => '필리핀 제도';

  @override
  String get regionIndonesia => '인도네시아 공화국';

  @override
  String get regionUnitedArabEmirates => '아랍에미리트';

  @override
  String get regionSaudiArabia => '사우디아라비아';

  @override
  String get regionTurkey => '칠면조';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return '자동 감지된 지역: $regionLabel ($regionCode). 현지화된 영화 검색 및 시청 제공업체 조회를 위해 재정의할 지역을 선택하세요.';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return '선택된 지역: $regionLabel ($regionCode). 지원되는 영화 검색 및 시청 제공업체 조회 시 다음에 이 지역이 자동으로 재사용됩니다.';
  }

  @override
  String get syncSignInTooltip => '클라우드와 동기화하려면 로그인하세요.';

  @override
  String get syncFailedTooltip => '동기화에 실패했습니다. 다시 시도하려면 탭하세요.';

  @override
  String get syncedTooltip => '클라우드와 동기화된 라이브러리';

  @override
  String get shareQuoteTooltip => '인용문 공유';

  @override
  String get copyQuoteTooltip => '견적서 복사';

  @override
  String get quoteCopiedToast => '인용문이 클립보드에 복사되었습니다.';

  @override
  String get shareDialogueTooltip => '대화 공유';

  @override
  String get copyDialogueTooltip => '대화 내용을 복사합니다';

  @override
  String get dialogueCopiedToast => '대화 내용이 클립보드에 복사되었습니다.';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$title은 1시간 후에 방송됩니다.';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel \"$episodeName\"은 $localAirTime에 방송됩니다.';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$title이 오늘 출시됩니다';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return '라이브러리에 있는 영화가 $localDate에 개봉합니다.';
  }

  @override
  String get curatedNeoNoirNights => '네오 누아르 나이트';

  @override
  String get curatedPulsePoundingRush => '심장을 뛰게 하는 질주';

  @override
  String get curatedFeelGoodEscape => '기분 좋은 탈출';

  @override
  String get curatedMindBenders => '마인드벤더스';

  @override
  String get curatedEpicWorlds => '에픽 월드';

  @override
  String get curatedHumanStories => '인간 이야기';

  @override
  String get curatedDarkDetectiveFiles => '다크 디텍티브 파일즈';

  @override
  String get curatedNeoNoirNightsDescription =>
      '비에 젖은 긴장감, 도덕적으로 모호한 주인공들, 그리고 분위기 있는 도시 이야기.';

  @override
  String get curatedPulsePoundingRushDescription =>
      '숨 막히는 추격전, 점점 고조되는 위험, 숨 쉴 틈도 없는 긴장감.';

  @override
  String get curatedFeelGoodEscapeDescription =>
      '따뜻한 이야기, 희망적인 전개, 편안한 밤을 위한 위안이 되는 추천 콘텐츠.';

  @override
  String get curatedMindBendersDescription =>
      '현실을 뒤흔드는 개념, 예측 불가능한 줄거리, 그리고 심오한 주제를 다룬 스토리텔링.';

  @override
  String get curatedEpicWorldsDescription =>
      '광대한 우주를 배경으로 한 모험, 신화적인 긴장감, 그리고 영화 같은 스케일.';

  @override
  String get curatedHumanStoriesDescription =>
      '인물 중심의 드라마로, 감동적인 스토리와 기억에 남는 연기를 선보입니다.';

  @override
  String get curatedDarkDetectiveFilesDescription =>
      '확실한 단서, 얽히고설킨 용의자들, 그리고 더디게 진행되는 수사.';

  @override
  String get appLanguage => '앱 언어';

  @override
  String get appLanguageSystemDefault => '시스템 기본값';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return '앱 언어가 $language으로 설정되었습니다. 이는 앱 인터페이스만 변경하며 영화 및 프로그램 언어는 변경되지 않습니다.';
  }

  @override
  String get appLanguageSystemSubtitle =>
      '앱 언어는 기기 설정에 따라 적용됩니다. 다른 언어로 인터페이스를 유지하려면 설정을 변경하세요.';

  @override
  String get contentLanguageAllSubtitle =>
      '모든 언어를 지원합니다. 영화 및 TV 탭은 광범위한 콘텐츠를 제공하며, 탐색 탭에서는 가능한 경우 해당 지역 콘텐츠에 더 적합한 결과를 우선적으로 보여줍니다.';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return '현재 $language으로 설정되어 있습니다. 영화 및 TV 탭은 이 설정을 그대로 유지하지만, 탐색 탭에서는 이 언어를 우선적으로 사용합니다.';
  }
}
