// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ルミ';

  @override
  String get navExplore => '探索';

  @override
  String get navMovies => '映画';

  @override
  String get navTvShows => 'テレビ番組';

  @override
  String get navLibrary => 'ライブラリ';

  @override
  String get navAccount => 'アカウント';

  @override
  String get searchHint => '映画、テレビ番組、会社を検索...';

  @override
  String get searchForPerson => '人物を検索...';

  @override
  String get searchLanguages => '言語を検索';

  @override
  String get searchNameOrRole => '名前または役割を検索...';

  @override
  String get retry => '再試行';

  @override
  String get tryAgain => '再試行';

  @override
  String get clear => 'クリア';

  @override
  String get cancel => 'キャンセル';

  @override
  String get ok => 'わかりました';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get share => '共有';

  @override
  String get undo => '元に戻す';

  @override
  String get close => '閉じる';

  @override
  String get apply => '適用';

  @override
  String get reset => 'リセット';

  @override
  String get done => '完了';

  @override
  String get signInWithGoogle => 'Google でサインイン';

  @override
  String get signInWithApple => 'Apple でサインイン';

  @override
  String get signOut => 'サインアウト';

  @override
  String get deleteAccount => 'アカウントの削除';

  @override
  String get accountDeletedSuccessfully => 'アカウントが正常に削除されました。';

  @override
  String get appearance => '外観';

  @override
  String get appearanceSubtitle => 'テーマを選択し、アプリの外観をカスタマイズします。';

  @override
  String get notifications => '通知';

  @override
  String get releaseCalendar => 'リリース カレンダー';

  @override
  String get hiddenTitles => '非表示のタイトル';

  @override
  String get aiRecommendationsPrivacy => 'AI 推奨事項 プライバシー';

  @override
  String get contentRegion => 'コンテンツ リージョン';

  @override
  String get contentLanguage => 'コンテンツ言語';

  @override
  String get watchlist => 'ウォッチリスト';

  @override
  String get notes => 'メモ';

  @override
  String get deleteNote => 'メモの削除';

  @override
  String get addNoteHint => 'メモの追加...';

  @override
  String get addBriefNoteHint => '簡単なメモを追加します (オプション)...';

  @override
  String get enterNewName => '新しい名前を入力してください...';

  @override
  String get importSharedList => '共有リストをインポート';

  @override
  String get discoverOnLumi => 'LUMI を発見';

  @override
  String get filtered => 'フィルター済み';

  @override
  String get fullPlot => '全プロット';

  @override
  String get userReviews => 'ユーザー レビュー';

  @override
  String get noReviewsYet => 'まだレビューはありません。';

  @override
  String get openInYouTube => 'YouTube で開く';

  @override
  String get hiddenGems => '隠れた宝石';

  @override
  String get resetSpotlight => 'スポットライトをリセット';

  @override
  String get clearPreferences => '設定をクリア';

  @override
  String get refreshPicks => '選択を更新';

  @override
  String get shareBoard => 'ボードを共有';

  @override
  String get exploreDetails => '詳細を調べる';

  @override
  String get searchWikiquotes => 'ウィキクォートを検索';

  @override
  String get selectAQuote => '引用を選択';

  @override
  String get tooltipShareQuote => '引用を共有';

  @override
  String get tooltipCopyQuote => '引用をコピー';

  @override
  String get tooltipShareDialogue => 'ダイアログを共有';

  @override
  String get tooltipCopyDialogue => 'ダイアログをコピー';

  @override
  String get tooltipUnhide => '再表示';

  @override
  String get tooltipOpenPrivacyPolicy => 'プライバシー ポリシーを開く';

  @override
  String get tooltipRefreshInsights => 'インサイトを更新';

  @override
  String get tooltipSortTitles => 'タイトルを並べ替え';

  @override
  String get tooltipSearch => '検索';

  @override
  String get tooltipFilters => 'フィルター';

  @override
  String get tooltipSaveToGallery => 'ギャラリーに保存';

  @override
  String get tooltipShare => '共有';

  @override
  String get tooltipShareAnalytics => '分析を共有';

  @override
  String get tooltipSetAiringReminder => '放送リマインダーを設定';

  @override
  String get tooltipLibrarySynced => 'ライブラリがクラウドと同期';

  @override
  String get noMoreEntries => '応募締め切り';

  @override
  String get noItemsFound => 'アイテムが見つかりませんでした';

  @override
  String errorLoadingGenres(String error) {
    return 'ジャンルの読み込みエラー: $error';
  }

  @override
  String errorGeneric(String error) {
    return 'エラー: $error';
  }

  @override
  String get errorLoadingLists => 'リストの読み込みエラー';

  @override
  String errorLoadingQuotes(Object error) {
    return '引用の読み込みに失敗しました: $error';
  }

  @override
  String get errorCouldNotShareAnalytics => '分析カードを共有できませんでした。';

  @override
  String get errorCouldNotShareRecommendations => '推奨ボードを共有できませんでした。';

  @override
  String get errorCouldNotShareInsights => '時計の分析情報を共有できませんでした。';

  @override
  String get watchInsightsNotReady => 'Watch の分析情報はまだ準備ができていません。';

  @override
  String titleRestoredToSpotlight(String title) {
    return '\"$title\" が Spotlight に復元されました';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '\"$title\" は非表示になりました';
  }

  @override
  String hiddenDate(String date) {
    return '非表示: $date';
  }

  @override
  String get moviesInThisCollection => 'このコレクション内の映画';

  @override
  String get searchPlanReady => '検索プランの準備ができました';

  @override
  String get hoursBeforeAirTime => '放送時間の数時間前';

  @override
  String get noUpcomingReleases => '今後のリリースはありません';

  @override
  String get noRemindersSet => 'リマインダーは設定されていません';

  @override
  String get noHiddenTitles => '非表示のタイトルはありません';

  @override
  String get hiddenTitlesDescription =>
      '「注目作品」セクションから非表示にした作品はここに表示され、いつでも復元できます。';

  @override
  String get tvShow => 'テレビ番組';

  @override
  String get movie => '映画';

  @override
  String get aiConsentGranted =>
      'オプトインしました。ライブラリ データは、おすすめをパーソナライズするために使用されます。';

  @override
  String get aiConsentNotGranted => 'オプトインしない限り、ライブラリ データは決して共有されません。';

  @override
  String get languageSettingExplanation =>
      '映画とテレビのタブではこれが厳密に使用されます。 Explore は最初にそれを優先し、レールがまばらになるとフォールバックします。';

  @override
  String get filterScreenTitle => 'フィルター';

  @override
  String get sortBy => '並べ替え';

  @override
  String get genres => 'ジャンル';

  @override
  String get year => '年';

  @override
  String get rating => '評価';

  @override
  String get runtime => 'ランタイム';

  @override
  String get withPeople => '参加者';

  @override
  String get voteCount => '投票数';

  @override
  String get today => '今日';

  @override
  String get tomorrow => '明日';

  @override
  String get yesterday => '昨日';

  @override
  String get minutes => '分';

  @override
  String get hours => 'このアプリのラベルを ja に翻訳します: h';

  @override
  String get cast => 'キャスト';

  @override
  String get crew => 'スタッフ';

  @override
  String get director => 'F@ キャスト @G@ スタッフ @H@ 監督';

  @override
  String get seasons => 'シーズン';

  @override
  String get episodes => 'エピソード';

  @override
  String get overview => '概要';

  @override
  String get similar => '類似';

  @override
  String get recommendations => 'おすすめ';

  @override
  String get addedToWatchlist => 'ウォッチリストに追加';

  @override
  String get removedFromWatchlist => 'ウォッチリストから削除';

  @override
  String get popularity => '人気';

  @override
  String get releaseDate => '発売日';

  @override
  String get revenueLabel => '収益';

  @override
  String get originalTitle => '原題';

  @override
  String get voteAverage => '投票平均';

  @override
  String get favourites => 'お気に入り';

  @override
  String get lists => 'リスト';

  @override
  String get watched => '視聴済み';

  @override
  String get all => '全て';

  @override
  String get tv => 'テレビ';

  @override
  String get librarySubtitle => 'コレクション、お気に入り、メモ、視聴履歴ごとに整理しておきましょう。';

  @override
  String get selectRegion => '地域を選択';

  @override
  String get selectRegionDescription =>
      '地域認識クエリをサポートするTMDbエンドポイントのみが、この選択を使用します。';

  @override
  String get useAutoDetectedRegion => '自動検出された領域を使用する';

  @override
  String get reminderRemoved => 'リマインダーが削除されました';

  @override
  String releaseReminderSet(String title) {
    return '$title のリリースリマインダーが設定されました。';
  }

  @override
  String episodeReminderSet(String title) {
    return 'エピソードのリマインダーが$titleに設定されました。';
  }

  @override
  String get filteredResults => '絞り込み結果';

  @override
  String get genreResults => 'ジャンル別検索結果';

  @override
  String couldNotLoadContent(String error) {
    return 'コンテンツを読み込めませんでした。$error';
  }

  @override
  String get noContentAvailableForThisSelection => 'この選択肢にはコンテンツがありません。';

  @override
  String get writer => '作家';

  @override
  String get actors => '俳優';

  @override
  String get noteNotFound => 'メモが見つかりませんでした。';

  @override
  String yourNotesCount(int count) {
    return 'あなたのメモ（$count）';
  }

  @override
  String get noteDeleted => 'メモは削除されました';

  @override
  String noteDeletedWithCount(int count) {
    return 'メモが削除されました ($count 秒)';
  }

  @override
  String get loadMore => 'もっと読み込む';

  @override
  String get noMoreProductionsFound => 'これ以上の作品は見つかりませんでした。';

  @override
  String get noProductionsFound => '該当する作品は見つかりませんでした。';

  @override
  String get watchInsights => '視聴分析';

  @override
  String get analyzingWatchHistory => 'ウォッチ履歴を分析しています...';

  @override
  String get manageHiddenTitlesDescription => 'スポットライトセクションから非表示にしたタイトルを管理します。';

  @override
  String get tmdbLanguageMetadataNote =>
      'このモードでは、カタログの一部についてTMDBの言語メタデータが不完全なため、一部のレールがまばらに見える場合があります。これは、必ずしもそれらのタイトルが存在しないという意味ではありません。';

  @override
  String get tmdbDisclaimer => 'この製品はTMDB APIを使用していますが、TMDBによる承認または認証を受けていません。';

  @override
  String get useLocalLibraryForSync => '同期にローカルライブラリを使用しますか？';

  @override
  String get themePresets => 'テーマプリセット';

  @override
  String get exitApp => 'アプリを終了する';

  @override
  String get popular => '人気のある';

  @override
  String couldNotLoadReminders(String error) {
    return 'リマインダーを読み込めませんでした。\n\n$error';
  }

  @override
  String get noRemindersSetYet =>
      'まだリマインダーは設定されていません。\n\nエピソードトラッカーまたは映画の詳細から作成してください。';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return 'エピソード S$seasonNumber • E$episodeNumber';
  }

  @override
  String get movieRelease => '映画公開';

  @override
  String voteAverageStars(String voteAverage) {
    return 'このアプリのラベルを日本語に翻訳してください: $voteAverage ★';
  }

  @override
  String get addMoreTrackedContent => 'ウォッチリスト、お気に入り、またはリストに、映画や番組を追加しましょう。';

  @override
  String get fastPicksDescription => '既に保存した商品に基づいて、素早くおすすめ商品を表示します。';

  @override
  String get releaseCalendarDescription => '映画の公開情報や次回のテレビ番組のエピソードを、ワンタップで通知。';

  @override
  String get staleWatchlist => '古いウォッチリスト';

  @override
  String get tracked => '追跡';

  @override
  String get upcoming => '近日公開';

  @override
  String get upcomingEmptyDescription =>
      '追跡対象の映画の公開日や番組の新エピソードの放送予定が決定すると、ここに表示されます。';

  @override
  String get howManyMoviesWatchedEachMonth => '毎月何本の映画を観ましたか？';

  @override
  String get howPersonalRatingsShifting => 'あなたの個人評価が時間とともにどのように変化しているか';

  @override
  String get keepWatchingToBuildProfile =>
      'ビジュアルプロフィールを構築するために、引き続き視聴を続けてください。';

  @override
  String get lumiWatchAnalytics => 'ルミウォッチ分析';

  @override
  String get noGenreDistributionYet => 'ジャンル別の配信はまだありません。';

  @override
  String get noMovieWatchHistoryRecentMonths => 'ここ数ヶ月の映画視聴履歴はありません。';

  @override
  String get noRatingTrendDataYet => '現時点では、評価動向データは入手できません。';

  @override
  String get preferredRuntime => '推奨ランタイム';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return '推奨実行時間は約$minutes分（$label）です';
  }

  @override
  String get styledCardWithWatchStats => 'ウォッチ統計情報が表示されるスタイリッシュなカード';

  @override
  String get titlesAnalyzed => '分析対象タイトル';

  @override
  String get tryAgainAfterMoment => 'しばらくしてからもう一度お試しください。';

  @override
  String get watchAnalytics => 'ウォッチアナリティクス';

  @override
  String get whatGenresDominateHistory => 'あなたのウォッチリストにはどんなジャンルが集中していますか？';

  @override
  String get toggleMovies => '映画';

  @override
  String get toggleTv => 'テレビ';

  @override
  String get noMoreTitlesFound => 'これ以上タイトルは見つかりませんでした。';

  @override
  String get noTitlesFoundForKeyword => 'このキーワードに該当するタイトルは見つかりませんでした。';

  @override
  String get viewFull => '全文を表示';

  @override
  String get accoladeDetails => '受賞の詳細';

  @override
  String get noDetailedAwardsInfo => '受賞に関する詳細情報は入手できません。';

  @override
  String get alertSet => 'アラート設定完了！';

  @override
  String get budget => '予算';

  @override
  String get buy => '買う';

  @override
  String chooseBetweenHours(int maxHours) {
    return '1～$maxHoursから選択してください。';
  }

  @override
  String get deleteNoteConfirmationTitle => 'メモを削除しますか？';

  @override
  String get episodeReminder => 'エピソードリマインダー';

  @override
  String get facebook => 'Facebook';

  @override
  String get free => '無料';

  @override
  String get images => '画像';

  @override
  String get instagram => 'インスタグラム';

  @override
  String get netProfit => '純利益';

  @override
  String get noNotesYet => 'まだコメントはありません。ぜひご意見をお聞かせください！';

  @override
  String get originalLanguage => '原文';

  @override
  String partOfCollection(String collectionName) {
    return '$collectionNameの一部';
  }

  @override
  String get roi => '投資対効果（ROI）';

  @override
  String releaseAlertSet(String date) {
    return '$date のリリース監視アラートが設定されました。';
  }

  @override
  String get rent => '家賃';

  @override
  String get revenue => '収益';

  @override
  String seeAllReviews(int count) {
    return 'すべて表示 ($count)';
  }

  @override
  String get setReminder => 'リマインダーを設定する';

  @override
  String get status => '状態';

  @override
  String get stream => 'ストリーム';

  @override
  String get tikTok => 'TikTok';

  @override
  String get twitterX => 'X';

  @override
  String get yours => 'あなたの';

  @override
  String get youtube => 'YouTube';

  @override
  String get durationDays => 'このアプリのラベルを ja に翻訳してください: d';

  @override
  String get durationHours => 'このアプリのラベルを ja に翻訳します: h';

  @override
  String get durationMinutes => 'このアプリのラベルを ja: m に翻訳してください';

  @override
  String get durationSeconds => 'このアプリのラベルを日本語に翻訳してください: s';

  @override
  String seasonRating(String score) {
    return 'このアプリのラベルを日本語に翻訳してください: ★ $score%';
  }

  @override
  String get we => '私たちは';

  @override
  String get aspect16x9 => 'このアプリのラベルを日本語に翻訳してください: 16:9';

  @override
  String get aspect9x16 => 'このアプリのラベルを日本語に翻訳してください: 9:16';

  @override
  String get background => '背景';

  @override
  String episodeCount(int count) {
    return 'このアプリのラベルを日本語に翻訳してください: $count Eps';
  }

  @override
  String get noEpisodesForSeason => '今シーズンのエピソードは見つかりませんでした。';

  @override
  String get beautifulStyledCardForStories => 'ソーシャルストーリー用の美しいスタイルのカード';

  @override
  String get clickableShareLink => 'WhatsAppやその他のアプリで共有できるクリック可能なリンク';

  @override
  String get placeQuoteOnBackdrop => 'お気に入りの名言を映画の背景に配置しましょう';

  @override
  String get standardLinkToMovieDatabase => '映画データベースへの標準リンク';

  @override
  String get exploreLabel => '探検する';

  @override
  String quoteCharacter(String character) {
    return 'このアプリのラベルを日本語に翻訳してください: — $character';
  }

  @override
  String get aiTonightWatch => 'AI トゥナイトウォッチ';

  @override
  String get aiQueryPlan => 'AIクエリプラン';

  @override
  String get airingToday => '本日放送';

  @override
  String get bigCrowdPleasers => '勢いのある人気作品';

  @override
  String get cinematic => '映画のような';

  @override
  String get comingSoon => '近日公開';

  @override
  String get currentTheatricalSlate => '現在公開中の劇場公開作品と近々公開予定の作品';

  @override
  String get dark => '暗い';

  @override
  String get discoverSpotlight => '注目のスポットライトを発見しよう';

  @override
  String get edgeOfYourSeat => 'ハラハラドキドキ';

  @override
  String get fastPaced => 'ペースの速い';

  @override
  String get feelGood => '気分が良くなる';

  @override
  String get freshPicksContinuous => '厳選アイテムは随時更新されます';

  @override
  String get hideTitle => 'タイトルを非表示にする';

  @override
  String get highRatedSkipped => '高評価を得ているにもかかわらず、ほとんどの視聴者が見過ごしている作品';

  @override
  String get hotNowAudience => '視聴者フィードで今話題沸騰中';

  @override
  String get inTheaters => '劇場公開中';

  @override
  String get indie => 'インディー';

  @override
  String get mindBending => '心を揺さぶる';

  @override
  String get mostDiscussedShowsThisWeek => '今週最も話題になった番組';

  @override
  String get multiplePicks => '複数選択可';

  @override
  String get onTheAir => 'オンエア中';

  @override
  String get personalizedFromWatchBehavior => 'あなたの時計の行動に基づいてパーソナライズされます';

  @override
  String get pickAVibe => '雰囲気を選んで、ぴったりのタイトルを即座にゲット';

  @override
  String get seeAll => 'すべて表示';

  @override
  String get seriesCurrentlyAiring => '現在放送中のシリーズ（エピソード配信中）';

  @override
  String get thisWeek => '今週';

  @override
  String get topRated => '最高評価';

  @override
  String get voiceInput => '音声入力';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% 一致';
  }

  @override
  String runtimeMinutes(String minutes) {
    return '$minutes分';
  }

  @override
  String get examplePrompt => '例：『インターステラー』のような作品だが、SFではないもの。';

  @override
  String findingYourPerfectWatch(String dots) {
    return 'あなたにぴったりの時計を見つけよう$dots';
  }

  @override
  String get moreLikeThis => 'もっと見る';

  @override
  String get notForMe => '私には合わない';

  @override
  String get recentQueries => '最近の検索';

  @override
  String get shufflingIdeas => 'アイデアを整理中…';

  @override
  String get tooMainstream => '主流すぎる';

  @override
  String get whatShouldIWatchTonight => '今夜は何を見ようか？';

  @override
  String debugLogEntry(String time, String message) {
    return 'このアプリのラベルを日本語に翻訳してください: [$time] $message';
  }

  @override
  String get from => 'から';

  @override
  String get to => 'に';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return 'ウォッチリストから削除されました（$seconds 秒）';
  }

  @override
  String creditsCount(String count) {
    return '$count クレジット';
  }

  @override
  String get acrossFilmography => 'フィルモグラフィー全体を通して';

  @override
  String get birthplace => '出生地';

  @override
  String get born => '生まれる';

  @override
  String get credits => 'クレジット';

  @override
  String get died => '亡くなった';

  @override
  String get knownFor => '特徴としては';

  @override
  String get noSharedTitlesAvailable => '共有タイトルはありません。';

  @override
  String get photos => '写真';

  @override
  String get personRating => '評価';

  @override
  String get taggedImages => 'タグ付き画像';

  @override
  String get website => 'Webサイト';

  @override
  String get noQuotesFound => '引用文は見つかりませんでした。';

  @override
  String get noSectionsFound => '該当するセクションが見つかりませんでした。';

  @override
  String get clearAll => 'すべてクリア';

  @override
  String get noCollectionsFound => 'コレクションは見つかりませんでした';

  @override
  String get noCompaniesFound => '該当する企業は見つかりませんでした';

  @override
  String get noKeywordsFound => 'キーワードが見つかりませんでした';

  @override
  String get noMoreResultsFound => 'これ以上の結果は見つかりませんでした。';

  @override
  String get noResultsFound => '検索結果が見つかりませんでした';

  @override
  String deleteListConfirmation(String listName) {
    return '本当に$listNameを削除しますか？';
  }

  @override
  String get deleteListTitle => 'リストを削除しますか？';

  @override
  String get everythingYouPlanToWatch => '次に視聴予定の作品すべて。';

  @override
  String get finishedTitlesAndHistory => '完成作品、履歴、統計情報。';

  @override
  String get noListsCreatedYet => 'リストはまだ作成されていません。';

  @override
  String get noNotesFound => 'メモが見つかりませんでした';

  @override
  String get renameList => 'リスト名の変更';

  @override
  String get titlesYouNeverWantToLose => '絶対に失いたくないタイトル。';

  @override
  String get yourThoughtsReactions => 'あなたの考え、反応、そして思い出。';

  @override
  String imageCounter(String current, String total) {
    return 'このアプリのラベルを日本語に翻訳してください: $current / $total';
  }

  @override
  String get removeFromWatchedConfirmation => '本当にこの商品をウォッチリストから削除しますか？';

  @override
  String get savedAsWatchedWithoutRating => 'これは個人評価なしで視聴済みとして保存されます。';

  @override
  String get noAdditionalRecommendationTrailers => '他に推奨トレーラーは見つかりませんでした。';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return 'このアプリのラベルを日本語に翻訳してください: $count $itemLabel';
  }

  @override
  String get invalidSharedListLink => 'リンクが無効、期限切れ、またはアクセスできなくなっている可能性があります。';

  @override
  String get noTitlesAvailableToImport => 'インポート可能なタイトルはありません。';

  @override
  String get allLanguages => 'すべての言語';

  @override
  String get arabic => 'アラビア語';

  @override
  String get bengali => 'ベンガル語';

  @override
  String get chinese => '中国';

  @override
  String get english => '英語';

  @override
  String get french => 'フランス語';

  @override
  String get german => 'ドイツ語';

  @override
  String get gujarati => 'グジャラート語';

  @override
  String get hindi => 'ヒンディー語';

  @override
  String get indonesian => 'インドネシア語';

  @override
  String get italian => 'イタリア語';

  @override
  String get japanese => '日本語';

  @override
  String get kannada => 'カンナダ語';

  @override
  String get korean => '韓国語';

  @override
  String get malayalam => 'マラヤーラム語';

  @override
  String get marathi => 'マラーティー語';

  @override
  String get persian => 'ペルシャ語';

  @override
  String get polish => '研磨';

  @override
  String get portuguese => 'ポルトガル語';

  @override
  String get punjabi => 'パンジャブ語';

  @override
  String get russian => 'ロシア';

  @override
  String get spanish => 'スペイン語';

  @override
  String get swedish => 'スウェーデン語';

  @override
  String get tamil => 'タミル語';

  @override
  String get telugu => 'テルグ語';

  @override
  String get thai => 'タイ';

  @override
  String get turkish => 'トルコ語';

  @override
  String get urdu => 'ウルドゥー語';

  @override
  String get vietnamese => 'ベトナム語';

  @override
  String get failedToLoadCollectionDetails => 'コレクションの詳細の読み込みに失敗しました';

  @override
  String get franchiseProgress => 'フランチャイズの進捗状況';

  @override
  String get officialSite => '公式サイト';

  @override
  String get productions => 'プロダクションズ';

  @override
  String get productionCompany => '制作会社';

  @override
  String get failedToLoadCompanyInfo => '会社情報の読み込みに失敗しました';

  @override
  String get profile => 'プロフィール';

  @override
  String get guestViewer => 'ゲスト視聴者';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      'あなたのプロフィール、同期状態、地域、および表示設定はすべてここに保存されます。';

  @override
  String get signInToSync => 'サインインして、ウォッチリスト、評価、設定を同期してください。';

  @override
  String get signedInAndSyncing => 'ログインしてクラウドと同期中です。';

  @override
  String get developedBy => '開発元';

  @override
  String get couldNotAnalyzeWatchHistory => '現在、ウォッチ履歴を分析できません。';

  @override
  String get includeLocalLibrary => '地元の図書館を含める';

  @override
  String get useCloudOnly => 'クラウドのみを使用する';

  @override
  String get localLibrarySyncDescription =>
      'このデバイスには既にローカルライブラリのタイトルが保存されています。それらをサインインしたライブラリに追加するか、ローカルライブラリのデータをクラウドライブラリのデータに置き換えてください。';

  @override
  String get mergedLocalTitles => 'ローカルタイトルを、ログイン済みのライブラリに統合しました。';

  @override
  String get replacedLocalLibrary => 'ローカルライブラリのデータをクラウドライブラリのデータに置き換えました。';

  @override
  String get deleteAccountConfirmation =>
      'これにより、Lumiアカウントと同期されたクラウドデータが完全に削除されます。アプリデータを別途削除しない限り、このデバイス上のローカルデータは残ります。';

  @override
  String get signedOutAndCleared => 'このデバイスからログアウトし、ローカルライブラリをクリアしました。';

  @override
  String get keepLocalLibrary => '地元の図書館を守ろう';

  @override
  String get clearLocalLibrary => 'クリアローカルライブラリ';

  @override
  String get signOutChoiceDescription =>
      'サインアウト後もこのデバイスにローカルライブラリを保持するかどうかを選択してください。';

  @override
  String get disable => '無効にする';

  @override
  String get aiRecommendationsEnabled => 'AIによる推奨事項に関するデータ共有が有効になりました。';

  @override
  String get aiRecommendationsDisabled => 'AIによる推奨事項のデータ共有は無効になっています。';

  @override
  String get reviewAndManageConsent => '図書館データをAIプロバイダーに送信する際の同意事項を確認し、管理する。';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      '有効になっています。Recommend Tonightは、あなたのライブラリの概要と最近の検索クエリをAIプロバイダーに送信する場合があります。';

  @override
  String basedOnWatchedTitles(String count) {
    return '視聴されたタイトル数$countに基づいています';
  }

  @override
  String lastUpdated(String date) {
    return '最終更新日: $date';
  }

  @override
  String get chooseYourVibe => 'お好みの雰囲気をお選びください';

  @override
  String get appearanceDescription =>
      'アプリのキャラクターを映画的な個性を持つキャラクターに切り替えても、動作は一切変わりません。';

  @override
  String get exitAppConfirmation => 'Lumiを終了してもよろしいですか？';

  @override
  String get dismiss => '却下する';

  @override
  String get generatingWatchAnalytics => 'ウォッチアナリティクスの生成';

  @override
  String get thisUsuallyTakesAFewSeconds => '通常は数秒で済みます。';

  @override
  String get yourScreenStory => 'あなたのスクリーンストーリー';

  @override
  String get snapshotOfHowAndWhatYouWatch => 'あなたがどのように、そして何を見ているかのスナップショット';

  @override
  String get yourFavoriteGenres => 'あなたの好きなジャンル';

  @override
  String get genrePerformanceHighestRated => 'ジャンル別パフォーマンス（最高評価）';

  @override
  String get personalizedViewingPatterns => 'パーソナライズされた視聴パターン';

  @override
  String get builtWithLumi => 'Lumiで構築';

  @override
  String get sharedWithLumi => 'Lumiと共有';

  @override
  String get shareAnalytics => 'シェア分析';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return '$count タイトルを分析 • $date を更新';
  }

  @override
  String get allSeasons => 'オールシーズン';

  @override
  String get castAndCrew => 'キャスト＆スタッフ';

  @override
  String get featuredCrew => '注目のクルー';

  @override
  String get stills => '静止画';

  @override
  String get accoladeSummary => '受賞歴の概要';

  @override
  String get awardsAndAccolades => '受賞歴と栄誉';

  @override
  String get unableToLoadMovieDetails => '映画の詳細を読み込めません';

  @override
  String get overviewUnavailable => 'このタイトルに関する概要情報は提供されていません。';

  @override
  String get openCompletePlot => 'OMDbから完全なあらすじと追加のメタデータを開く。';

  @override
  String get noOverviewForSeason => '今シーズンの概要は利用できません。';

  @override
  String get userScore => 'ユーザー評価';

  @override
  String get playTrailer => '予告編を再生する';

  @override
  String get whereToWatch => '視聴方法';

  @override
  String get availabilityDataByJustWatch => 'JustWatchによる在庫状況データ。';

  @override
  String get reminderSaved => 'リマインダーが保存されました';

  @override
  String reminderForTitle(String title) {
    return '$title へのリマインダー';
  }

  @override
  String get pleaseSelectFutureTime => '未来の時間を選択してください';

  @override
  String get notifyAt => '通知先:';

  @override
  String get notifyHoursBeforeAiring => '放送の何時間前に通知しますか？';

  @override
  String enterNumberBetween(String maxHours) {
    return '1から$maxHoursまでの数字を入力してください';
  }

  @override
  String get set => 'セット';

  @override
  String get selectedReminderTimePassed => '選択したリマインダー時間は既に過ぎています';

  @override
  String episodeReminderSaved(String date) {
    return 'エピソードのリマインダーが$dateに保存されました';
  }

  @override
  String get areYouSureDeleteNote => 'このメモを削除してもよろしいですか？';

  @override
  String get noteAdded => '追記';

  @override
  String get lastSeason => '昨シーズン';

  @override
  String get currentSeason => '今シーズン';

  @override
  String get viewAllSeasons => '全シーズンを見る';

  @override
  String get removedFromFavourites => 'お気に入りから削除されました';

  @override
  String get addedToFavourites => 'お気に入りに追加しました';

  @override
  String get awardsAndNominations => '受賞歴とノミネート';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get boxOfficeFinancials => '興行収入に関する財務情報';

  @override
  String get successMeter => '成功度メーター';

  @override
  String get blockbuster => '大ヒット作';

  @override
  String get hit => '打つ';

  @override
  String get breakEven => 'とんとん';

  @override
  String get underperformer => '期待外れ';

  @override
  String get boxOfficeBomb => '興行的に大失敗';

  @override
  String get episodeTracker => 'エピソードトラッカー';

  @override
  String get setAiringReminder => '放送リマインダーを設定する';

  @override
  String get nextEpisodeCountdown => '次回の放送までのカウントダウン';

  @override
  String get nextEpisode => '次回のエピソード';

  @override
  String get lastEpisodeToAir => '最終回放送';

  @override
  String get unknown => '未知';

  @override
  String get contentAdvisory => 'コンテンツに関する注意喚起';

  @override
  String get violence => '暴力';

  @override
  String get sexAndNudity => 'セックスとヌード';

  @override
  String get foulLanguage => '言語';

  @override
  String get substances => '物質';

  @override
  String get fearAndHorror => '恐怖とホラー';

  @override
  String get familyFriendly => '家族向け';

  @override
  String get generalAudience => '一般向け';

  @override
  String get releaseTimeline => 'リリーススケジュール';

  @override
  String get notifyMe => '通知を受け取る';

  @override
  String get theatricalRelease => '劇場公開';

  @override
  String get digitalStreaming => 'デジタル／ストリーミング';

  @override
  String get physicalRelease => '物理メディア（ブルーレイ／DVD）';

  @override
  String get awesome => '素晴らしい';

  @override
  String get keywordsAndThemes => 'キーワードとテーマ';

  @override
  String get videosAndBehindTheScenes => '動画と舞台裏映像';

  @override
  String get productionStudios => '制作スタジオ';

  @override
  String get fetchingWatchLink => 'ウォッチリンクを取得中';

  @override
  String get findingBestProviderPage => 'このタイトルに最適なプロバイダーページを見つける。';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode';
  }

  @override
  String get error => 'エラー';

  @override
  String get failedToLoadSeasonDetails => 'シーズン詳細の読み込みに失敗しました';

  @override
  String get loading => '読み込み中…';

  @override
  String runtimeSeparator(String runtime) {
    return 'このアプリのラベルを日本語に翻訳してください： • $runtime';
  }

  @override
  String get fullCastAndCrew => 'キャスト＆スタッフ一覧';

  @override
  String get shareMovie => '映画を共有する';

  @override
  String get quotes => '名言集';

  @override
  String get mayIncludeMismatches => '語彙検索による引用の不一致が時折発生する場合があります。';

  @override
  String get movieApiConfigurationRequired => '映画APIの設定が必要です';

  @override
  String get addMovieProxyBaseUrl =>
      'アプリをTMDBプロキシに接続するには、MOVIE_PROXY_BASE_URLを追加してください。';

  @override
  String get cinematicPicksContext =>
      '映画のような雰囲気をすぐに感じ取れるような、印象的なシーンが満載。さらにサプライズカードを引いてみよう。';

  @override
  String get curatedTonight => '今夜のおすすめ';

  @override
  String curatedTonightTitle(String title) {
    return '今夜のおすすめ：$title';
  }

  @override
  String get describeItYourWay => 'あなたらしく説明してください。\n\n最適なマッチングを見つけます。';

  @override
  String get hide => '隠れる';

  @override
  String get hideTitleDescription => 'このタイトルを非表示にすると、今後「注目記事」セクションに表示されなくなります。';

  @override
  String get dontAskAgain => '二度と聞かないで';

  @override
  String get imdbNa => 'IMDb 該当なし';

  @override
  String get noDiscoverPicks => '現在、おすすめの作品はありません。';

  @override
  String get playPreview => '再生プレビュー';

  @override
  String get recommendedForYou => 'あなたへのおすすめ';

  @override
  String get spotlightCompleted => 'スポットライト特集完了';

  @override
  String get startAddingTitlesForRecommendations => 'おすすめ記事のタイトルを追加し始めましょう';

  @override
  String get clearedAllChoices => '発見フィード内のすべての選択肢をスワイプしてクリアしました。';

  @override
  String get whatsPopular => '人気商品';

  @override
  String get trending => 'トレンド';

  @override
  String get nowPlaying => '再生中';

  @override
  String get tvTrending => 'テレビのトレンド';

  @override
  String get discoverByMood => '気分別に探す';

  @override
  String get needSomethingToWatchTonight => '今夜見るものをお探しですか？';

  @override
  String get needAMovieForTonight => '今夜観る映画をお探しですか？';

  @override
  String get tryAiShows => 'AIショーを試してみる';

  @override
  String get tryAiMovies => 'AI映画を試してみる';

  @override
  String get findShows => '番組を探す';

  @override
  String get findMovies => '映画を探す';

  @override
  String get couldNotLoadThisRail => 'このレールをロードできませんでした';

  @override
  String get temporaryIssueLoadingRail => 'このレールへの積載に一時的な問題が発生しました。';

  @override
  String get noTitlesHereYet => 'まだタイトルはありません';

  @override
  String get noHiddenGemsForGenre =>
      'このジャンルではまだ隠れた名作は見つかっていません。別のジャンルをお試しください。';

  @override
  String get tryAnotherFilter => '別のフィルターを試すか、このセクションを開いてより幅広い情報を見つけてください。';

  @override
  String get seeAllFilters => 'すべてのフィルターを表示';

  @override
  String get couldNotLoadCuratedPicks => '厳選されたおすすめ商品を読み込めませんでした';

  @override
  String get temporaryIssueLoadingCurated => '今夜の厳選リストの読み込みに一時的な問題が発生しました。';

  @override
  String get noCuratedPicksAvailable => 'おすすめ商品はありません';

  @override
  String get tryAgainWhileRefresh => '今夜のTMDBリストを更新中です。しばらくしてからもう一度お試しください。';

  @override
  String get fromSpotlight => 'スポットライトより';

  @override
  String get addShowsMoviesForRecommendations =>
      'お気に入りの番組や映画、視聴済みリストにテレビ番組や映画を追加すると、気に入るかもしれない作品が表示されます。';

  @override
  String get allow => '許可する';

  @override
  String get notNow => '今じゃない';

  @override
  String get allowAiDataSharingTitle => 'AIとのデータ共有を許可しますか？';

  @override
  String get allowAiDataSharingDescription =>
      'Recommend Tonightは、映画のおすすめリクエストのために入力したテキストと、一時的な検索条件をGoogle GeminiとOpenRouterに送信します。あなたのライブラリ全体とログイン認証情報は、これらのAIプロバイダーには送信されません。AIによるおすすめのために、このデータ共有を許可しますか？';

  @override
  String get liveProgress => 'ライブ進捗状況';

  @override
  String percentComplete(String percent) {
    return '$percent%完了';
  }

  @override
  String get describeIdealShowNight => 'あなたにとって理想的なショーナイトとはどのようなものですか？';

  @override
  String get describeIdealMovieNight => 'あなたにとって理想的な映画鑑賞の夜とは？';

  @override
  String get useNaturalLanguage =>
      '自然言語を使用してください。希望する内容、避けたい内容、および必要に応じて言語/実行時に関するヒントを記載してください。';

  @override
  String get listeningTapMicToStop => '再生中…停止するにはマイクをもう一度タップしてください。';

  @override
  String voiceInputError(String error) {
    return '音声入力エラー: $error';
  }

  @override
  String get tapMicToDictate => 'マイクをタップしてリクエストを音声入力してください。';

  @override
  String get tapMicToEnableVoice => 'マイクをタップして音声入力を有効にします。';

  @override
  String get findingShows => '番組を探す...';

  @override
  String get findingMovies => '映画を探す...';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return '今夜のLumiのおすすめ：$prompt';
  }

  @override
  String get tonightsPicks => '今夜のおすすめ';

  @override
  String get sharedFromLumi => 'Lumiから共有されました';

  @override
  String get intent => '意図:';

  @override
  String get genreLabel => 'ジャンル：';

  @override
  String get avoid => '避ける：';

  @override
  String get languageLabel => '言語：';

  @override
  String runtimeAtMost(String minutes) {
    return '実行時間 <= $minutes 分';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return '実行時間 >= $minutes 分';
  }

  @override
  String get yearLabel => '年：';

  @override
  String yearAfter(String year) {
    return '$yearの後';
  }

  @override
  String yearBefore(String year) {
    return '$year の前';
  }

  @override
  String get like => 'のように：';

  @override
  String get signal => '信号：';

  @override
  String get readingWatchedHistory => 'あなたの視聴履歴を読んでいます…';

  @override
  String get findingTopGenres => 'お気に入りのジャンルやパターンを見つけよう…';

  @override
  String get buildingTrends => '月次データと評価トレンドの構築…';

  @override
  String get writingInsights => 'あなただけの洞察を書き込んでください...';

  @override
  String get applyFilters => 'フィルターを適用する';

  @override
  String get includeNotRated => '評価なしを含める';

  @override
  String get errorLoadingTvGenres => 'テレビ番組のジャンルの読み込みエラー';

  @override
  String get alsoKnownAs => '別名';

  @override
  String get biography => 'バイオグラフィー';

  @override
  String get careerStatistics => 'キャリア統計';

  @override
  String get frequentlyCollaboratesWith => '頻繁にコラボレーションする';

  @override
  String get notableQuotes => '印象的な名言';

  @override
  String get primaryRole => '主な役割';

  @override
  String get averageRating => '平均評価';

  @override
  String get topGenre => '人気ジャンル';

  @override
  String get peakBoxOffice => 'ピーク時の興行収入';

  @override
  String percentOfTitles(String percent) {
    return 'タイトルの $percent%';
  }

  @override
  String sharedTitleCount(String count) {
    return '$count が共有したタイトル';
  }

  @override
  String billingOrder(String order) {
    return '請求番号 #$order';
  }

  @override
  String get startTypingToSearch => '検索するには入力してください';

  @override
  String get movieDiscoveryMadePersonal => '映画との出会いを、よりパーソナルに。';

  @override
  String get allNotes => 'すべてのノート';

  @override
  String get viewPersonalizedInsights => 'パーソナライズされた分析結果、グラフ、トレンドをご覧ください。';

  @override
  String get curatedCollections => '厳選されたコレクション';

  @override
  String get list => 'リスト';

  @override
  String get openList => 'オープンリスト';

  @override
  String get thisListNoLongerExists => 'このリストはもう存在しません';

  @override
  String listRenamed(String name) {
    return 'リスト名が$nameに変更されました';
  }

  @override
  String listDeleted(String name) {
    return 'リスト $name が削除されました';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return 'ウォッチリストに$filterがありません';
  }

  @override
  String noFilterInFavourites(String filter) {
    return 'お気に入りに$filterはありません';
  }

  @override
  String noFilterInWatched(String filter) {
    return '監視対象に $filter はありません';
  }

  @override
  String noFilterInThisList(String filter) {
    return 'このリストには $filter はありません';
  }

  @override
  String noListsWithFilter(String filter) {
    return '$filter を含むリストはありません';
  }

  @override
  String importedInto(String name) {
    return '「$name」にインポートされました';
  }

  @override
  String get couldNotImportList => 'リストをインポートできませんでした';

  @override
  String get importing => 'インポート中...';

  @override
  String get couldNotLoadSharedList => 'この共有リストを読み込むことができませんでした';

  @override
  String get editWatchedInfo => '視聴済み情報を編集';

  @override
  String get watchDate => '視聴日';

  @override
  String get rewatchCount => '再視聴回数';

  @override
  String get watchedInfoUpdated => '視聴情報が更新されました';

  @override
  String removedFromList(String listName) {
    return '$listNameから削除されました';
  }

  @override
  String addedToList(String listName) {
    return '$listNameに追加されました';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return '$listNameとウォッチリストに追加されました';
  }

  @override
  String get moreTrailersLikeThis => 'このような予告編をもっと見る';

  @override
  String get noDescriptionForTrailer => 'この予告編には説明がありません。';

  @override
  String get closeTrailer => 'クローズドトレーラー';

  @override
  String get recommendedSeries => 'おすすめシリーズ';

  @override
  String get recommendedMovie => 'おすすめ映画';

  @override
  String get notEnoughDataYet => 'データはまだ十分ではありません';

  @override
  String addAndRateMoreTitles(String count) {
    return '分析機能を有効にするには、少なくとも$count件のタイトルを追加して評価してください。';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return 'あなたは$watchedCount/$requiredCount本のタイトルを視聴しました。分析機能を有効にするには、さらに$remaining本を追加してください。';
  }

  @override
  String get moviesPerMonth => '月間映画数';

  @override
  String get genreDistribution => 'ジャンル別分布';

  @override
  String get ratingTrends => '評価動向';

  @override
  String get noData => 'データなし';

  @override
  String get myLatestWatchAnalytics => 'Lumiの最新時計分析';

  @override
  String get myWatchInsights => 'ルミの時計に関する私の見解';

  @override
  String get infographicsCard => 'インフォグラフィックカード';

  @override
  String get watchInsightsSnapshot => '視聴インサイトスナップショット';

  @override
  String get availableOnceInsightsReady => '分析結果が準備でき次第利用可能になります。';

  @override
  String get shareYourWatchInsights => 'ウォッチインサイトカードを共有してください';

  @override
  String get recentlyWatchedVibe => '最近観た映画『Vivo』';

  @override
  String get mixedAcrossGenres => '様々なジャンルをミックス';

  @override
  String get moviesPerMonthShort => '映画 / 月間';

  @override
  String get ratingTrend => '評価トレンド';

  @override
  String get balanced => 'バランスの取れた';

  @override
  String get noWatchNextSuggestionsYet => '次に視聴する動画のおすすめはまだありません';

  @override
  String get upcomingFromLibrary => '図書館からの近日発売予定';

  @override
  String get removeReminder => 'リマインダーを削除する';

  @override
  String get remindMe => '思い出させてください';

  @override
  String titleReleasesToday(String title) {
    return '$titleは本日発売です。';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle は近日放送予定です。';
  }

  @override
  String get controlPremiereAlerts => 'プレミア公開のお知らせやリリースリマインダーを管理します。';

  @override
  String upcomingReleasesCount(String count) {
    return 'ライブラリ全体で近日リリース予定の$count。';
  }

  @override
  String sittingInWatchlist(String days) {
    return '$days日間、あなたのウォッチリストに入っています';
  }

  @override
  String get alreadyOnWatchlist => '既にウォッチリストに追加済み';

  @override
  String get favouritedButNotWatched => 'お気に入りに追加しましたが、まだ視聴済みとしてマークしていません。';

  @override
  String get savedInListReady => 'リストに保存され、視聴準備完了です';

  @override
  String get matchesTitlesYouTrack => '既に追跡しているタイトルに一致します';

  @override
  String get noOfficialSite => '公式サイトはありません';

  @override
  String get episodeAiring => 'エピソード放送';

  @override
  String get general => '一般的な';

  @override
  String scheduledFor(String date) {
    return '$dateに予定されています';
  }

  @override
  String wasScheduledFor(String date) {
    return '$dateに予定されていました';
  }

  @override
  String get noOverviewAvailable => '概要は利用できません。';

  @override
  String get searchHistoryCleared => '検索履歴が削除されました';

  @override
  String get visualMovieCard => 'ビジュアルムービーカード';

  @override
  String get smartLumiLink => 'スマートルミリンク';

  @override
  String get directTmdbLink => 'TMDBへの直接リンク';

  @override
  String recommendedOnLumi(String title) {
    return 'Lumiで推奨されているもの：$title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return 'Lumiで$titleをチェック！\n\n$link\n\nLumiを入手：$appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return 'TMDBで$titleをチェックしてください：$link';
  }

  @override
  String releaseAlertTitle(String title) {
    return '$title リリースアラート';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return '$dateのリリース通知を設定しました。リリースされたらお知らせします。';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return '「$title」がデジタル配信またはBlu-ray/DVDでリリースされ次第、お知らせいたします！';
  }

  @override
  String get episodeAlreadyDueToAir => 'このエピソードは既に放送予定となっている';

  @override
  String get reminderSetSuccessfully => 'リマインダーの設定に成功しました';

  @override
  String get speechRecognitionNotAvailable => 'この端末では音声認識機能は利用できません。';

  @override
  String get describeShowMood => '見たい番組の種類を教えてください。ランキング形式でリストアップしてお送りします。';

  @override
  String get describeMovieMood => '見たい映画のジャンルを教えてください。ランキング形式でリストアップしてお送りします。';

  @override
  String get aiLauncherDescription =>
      '自然言語でリクエストを入力するか、音声で入力してください。LumiがAIプランを作成し、ベクトル検索を実行して、複数の番組や映画の候補を返します。';

  @override
  String yearRange(String from, String to) {
    return 'このアプリのラベルを日本語に翻訳してください: $from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return '$count リマインダーがスケジュールされました。';
  }

  @override
  String regionAutoDetected(String region) {
    return '自動検出: $region';
  }

  @override
  String regionSelected(String region) {
    return '選択済み: $region';
  }

  @override
  String get allLanguagesSubtitle => 'すべての言語';

  @override
  String currentlySetToLanguage(String language) {
    return '現在$languageに設定されています';
  }

  @override
  String get availabilities => '空き状況';

  @override
  String get mood => '気分';

  @override
  String get people => '人々';

  @override
  String get ads => '広告';

  @override
  String get theatricalLimited => 'シアトリカル・リミテッド';

  @override
  String get premier => 'プレミア';

  @override
  String get mediaType => 'メディアタイプ';

  @override
  String get couldNotLoadAnalytics => '分析データを読み込むことができませんでした';

  @override
  String get viewAllAwards => 'すべて表示';

  @override
  String get win => '勝つ';

  @override
  String get wins => '勝利';

  @override
  String get nomination => '指名';

  @override
  String get nominations => 'ノミネート';

  @override
  String sharedBy(String name) {
    return '$name によって共有されました';
  }

  @override
  String titleCount(String count) {
    return '$count タイトル';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count は、リスト全体でタイトルを保存しました';
  }

  @override
  String get curatedCollectionsSubtitle => '整理して共有できる、厳選されたコレクション。';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return 'Lumiに「$name」をインポートします（$count $itemLabel）：$link';
  }

  @override
  String get notEnoughData => 'データが不足しています';

  @override
  String shareQuote(String title) {
    return 'Lumi の「$title」さんのこの引用文をチェックしてみてください！';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Lumiのおすすめ：$title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      '自然言語でリクエストを入力するか、音声で入力してください。LumiがAIプランを作成し、ベクトル検索を実行して、複数の番組候補を返します。';

  @override
  String get aiLauncherDescriptionMovie =>
      '自然言語でリクエストを入力するか、音声で入力してください。LumiがAIプランを作成し、ベクトル検索を実行して、複数の映画候補を返します。';

  @override
  String get warmingUpMovieSearch => '映画検索の準備を始めよう';

  @override
  String get connectingToRecommendationEngine => 'レコメンデーションエンジンに接続中';

  @override
  String get understandingYourTaste => '自分が何をしたい気分なのかを理解する';

  @override
  String get buildingCustomSearch => 'お客様のご要望に基づいたカスタム検索の構築';

  @override
  String get tinyNetworkHiccup => 'ネットワークにわずかな不具合が発生しました。再度試してみます。';

  @override
  String get planLocked => 'プランが確定しました：ジャンル、スタイル、言語、および実行時間';

  @override
  String get scanningTmdb => 'TMDBをスキャンして強力な一致を探す';

  @override
  String get collectingDetails => '人気作品のポスター、評価、上映時間を収集';

  @override
  String shortlistingPicksCount(String current, String total) {
    return '候補リスト（$current/$total）';
  }

  @override
  String get shortlistingBestPicks => '最有力候補を絞り込む';

  @override
  String get finalPolish => 'ご提案内容の最終調整';

  @override
  String get retryingAfterIssue => '一時的な問題発生後に再試行します';

  @override
  String get regionUnitedStates => 'アメリカ合衆国';

  @override
  String get regionIndia => 'インド';

  @override
  String get regionUnitedKingdom => 'イギリス';

  @override
  String get regionCanada => 'カナダ';

  @override
  String get regionAustralia => 'オーストラリア';

  @override
  String get regionNewZealand => 'ニュージーランド';

  @override
  String get regionGermany => 'ドイツ';

  @override
  String get regionFrance => 'フランス';

  @override
  String get regionSpain => 'スペイン';

  @override
  String get regionItaly => 'イタリア';

  @override
  String get regionJapan => '日本';

  @override
  String get regionSouthKorea => '韓国';

  @override
  String get regionBrazil => 'ブラジル';

  @override
  String get regionMexico => 'メキシコ';

  @override
  String get regionSingapore => 'シンガポール';

  @override
  String get regionPhilippines => 'フィリピン';

  @override
  String get regionIndonesia => 'インドネシア';

  @override
  String get regionUnitedArabEmirates => 'アラブ首長国連邦';

  @override
  String get regionSaudiArabia => 'サウジアラビア';

  @override
  String get regionTurkey => '七面鳥';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return '自動検出された地域: $regionLabel ($regionCode)。ローカライズされた映画検索や視聴プロバイダー検索のために、上書きする地域を選択してください。';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return '選択された地域: $regionLabel ($regionCode)。サポートされている映画検索および視聴プロバイダー検索では、次回以降、この地域が自動的に再利用されます。';
  }

  @override
  String get syncSignInTooltip => 'クラウドと同期するにはサインインしてください';

  @override
  String get syncFailedTooltip => '同期に失敗しました。タップして再試行してください。';

  @override
  String get syncedTooltip => 'ライブラリはクラウドと同期されています';

  @override
  String get shareQuoteTooltip => '引用を共有する';

  @override
  String get copyQuoteTooltip => '引用文をコピー';

  @override
  String get quoteCopiedToast => '引用文がクリップボードにコピーされました';

  @override
  String get shareDialogueTooltip => '対話を共有する';

  @override
  String get copyDialogueTooltip => 'セリフをコピーする';

  @override
  String get dialogueCopiedToast => '会話文がクリップボードにコピーされました';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$titleは1時間後に放送されます';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel \"$episodeName\" は $localAirTime に放送されます。';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$titleが本日リリースされます';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return 'あなたのライブラリにある映画が$localDateに公開されます。';
  }

  @override
  String get curatedNeoNoirNights => 'ネオノワール・ナイツ';

  @override
  String get curatedPulsePoundingRush => '心臓がドキドキするような高揚感';

  @override
  String get curatedFeelGoodEscape => '気分爽快な逃避行';

  @override
  String get curatedMindBenders => 'マインドベンダーズ';

  @override
  String get curatedEpicWorlds => '壮大な世界';

  @override
  String get curatedHumanStories => '人間ドラマ';

  @override
  String get curatedDarkDetectiveFiles => 'ダーク探偵ファイル';

  @override
  String get curatedNeoNoirNightsDescription =>
      '雨に濡れた緊張感、道徳的に曖昧な主人公たち、そして雰囲気のある都市の物語。';

  @override
  String get curatedPulsePoundingRushDescription =>
      '緊迫感あふれる追跡劇、エスカレートする危険、そして息つく暇もないほどの展開。';

  @override
  String get curatedFeelGoodEscapeDescription =>
      '心温まる物語、感動的な展開、そして心地よい選曲で、リラックスした夜をお過ごしください。';

  @override
  String get curatedMindBendersDescription =>
      '現実を歪めるような概念、複雑な筋書き、そして壮大なアイデアに満ちたストーリーテリング。';

  @override
  String get curatedEpicWorldsDescription =>
      '広大な宇宙を舞台にした冒険、神話的な危機、そして映画のようなスケール。';

  @override
  String get curatedHumanStoriesDescription =>
      '登場人物の描写を重視し、感情に訴えかける力と印象的な演技が光るドラマ。';

  @override
  String get curatedDarkDetectiveFilesDescription =>
      '手がかりは乏しく、容疑者は複雑に絡み合い、捜査は時間をかけて進められる。';

  @override
  String get appLanguage => 'アプリの言語';

  @override
  String get appLanguageSystemDefault => 'システムデフォルト';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return 'アプリの言語設定が$languageになりました。これはアプリのインターフェースのみを変更し、映画や番組の言語は変更しません。';
  }

  @override
  String get appLanguageSystemSubtitle =>
      'アプリの言語設定は、デバイスの設定に従います。別の言語でインターフェースを表示したい場合は、設定を変更してください。';

  @override
  String get contentLanguageAllSubtitle =>
      'すべての言語に対応。映画とテレビ番組のタブは引き続き幅広い内容で表示されますが、「探索」では、利用可能な場合はより地域に特化したコンテンツを優先的に表示します。';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return '現在$languageに設定されています。映画とテレビのタブは引き続き厳格な設定を維持し、エクスプローラーではこの言語が優先されます。';
  }
}
