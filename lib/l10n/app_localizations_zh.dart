// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '卢米';

  @override
  String get navExplore => '探索';

  @override
  String get navMovies => '电影';

  @override
  String get navTvShows => '电视节目';

  @override
  String get navLibrary => '图书馆';

  @override
  String get navAccount => '帐户';

  @override
  String get searchHint => '搜索电影、电视节目、公司...';

  @override
  String get searchForPerson => '搜索人员...';

  @override
  String get searchLanguages => '搜索语言';

  @override
  String get searchNameOrRole => '搜索姓名或角色...';

  @override
  String get retry => '重试';

  @override
  String get tryAgain => '重试';

  @override
  String get clear => '清除';

  @override
  String get cancel => '取消';

  @override
  String get ok => '确定';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get share => '分享';

  @override
  String get undo => '撤消';

  @override
  String get close => '关闭';

  @override
  String get apply => '应用';

  @override
  String get reset => '重置';

  @override
  String get done => '完成';

  @override
  String get signInWithGoogle => '使用 Google 登录';

  @override
  String get signInWithApple => '使用 Apple 登录';

  @override
  String get signOut => '注销';

  @override
  String get deleteAccount => '删除帐户';

  @override
  String get accountDeletedSuccessfully => '帐户已成功删除。';

  @override
  String get appearance => '外观';

  @override
  String get appearanceSubtitle => '选择您的主题并自定义应用程序外观。';

  @override
  String get notifications => '通知';

  @override
  String get releaseCalendar => '发布日历';

  @override
  String get hiddenTitles => '隐藏标题';

  @override
  String get aiRecommendationsPrivacy => 'AI 建议 隐私';

  @override
  String get contentRegion => '内容区域';

  @override
  String get contentLanguage => '内容语言';

  @override
  String get watchlist => '监视列表';

  @override
  String get notes => '注释';

  @override
  String get deleteNote => '删除注释';

  @override
  String get addNoteHint => '添加注释...';

  @override
  String get addBriefNoteHint => '添加简短注释（可选）...';

  @override
  String get enterNewName => '输入新名称...';

  @override
  String get importSharedList => '导入共享列表';

  @override
  String get discoverOnLumi => '在 LUMI 上发现';

  @override
  String get filtered => '已过滤';

  @override
  String get fullPlot => '完整情节';

  @override
  String get userReviews => '用户评论';

  @override
  String get noReviewsYet => '尚无评论。';

  @override
  String get openInYouTube => '在 YouTube 中打开';

  @override
  String get hiddenGems => '隐藏的宝石';

  @override
  String get resetSpotlight => '重置聚光灯';

  @override
  String get clearPreferences => '清除首选项';

  @override
  String get refreshPicks => '刷新精选';

  @override
  String get shareBoard => '分享板';

  @override
  String get exploreDetails => '探索详细信息';

  @override
  String get searchWikiquotes => '搜索维基语录';

  @override
  String get selectAQuote => '选择报价';

  @override
  String get tooltipShareQuote => '分享报价';

  @override
  String get tooltipCopyQuote => '复制报价';

  @override
  String get tooltipShareDialogue => '分享对话';

  @override
  String get tooltipCopyDialogue => '复制对话';

  @override
  String get tooltipUnhide => '取消隐藏';

  @override
  String get tooltipOpenPrivacyPolicy => '打开隐私政策';

  @override
  String get tooltipRefreshInsights => '刷新见解';

  @override
  String get tooltipSortTitles => '排序标题';

  @override
  String get tooltipSearch => '搜索';

  @override
  String get tooltipFilters => '筛选';

  @override
  String get tooltipSaveToGallery => '保存到图库';

  @override
  String get tooltipShare => '分享';

  @override
  String get tooltipShareAnalytics => '分享分析';

  @override
  String get tooltipSetAiringReminder => '设置播放提醒';

  @override
  String get tooltipLibrarySynced => '与云同步的图书馆';

  @override
  String get noMoreEntries => '不再有其他条目';

  @override
  String get noItemsFound => '未找到任何物品';

  @override
  String errorLoadingGenres(String error) {
    return '加载流派时出错：$error';
  }

  @override
  String errorGeneric(String error) {
    return '错误：$error';
  }

  @override
  String get errorLoadingLists => '加载列表时出错';

  @override
  String errorLoadingQuotes(Object error) {
    return '加载引用失败：$error';
  }

  @override
  String get errorCouldNotShareAnalytics => '无法分享分析卡。';

  @override
  String get errorCouldNotShareRecommendations => '无法共享推荐板。';

  @override
  String get errorCouldNotShareInsights => '无法分享手表见解。';

  @override
  String get watchInsightsNotReady => '观看见解尚未准备好。';

  @override
  String titleRestoredToSpotlight(String title) {
    return '“$title”恢复到聚光灯';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '“$title”已隐藏';
  }

  @override
  String hiddenDate(String date) {
    return '已隐藏：$date';
  }

  @override
  String get moviesInThisCollection => '此收藏中的电影';

  @override
  String get searchPlanReady => '搜索计划已准备好';

  @override
  String get hoursBeforeAirTime => '播出时间前几小时';

  @override
  String get noUpcomingReleases => '没有即将上映的影片';

  @override
  String get noRemindersSet => '未设置提醒';

  @override
  String get noHiddenTitles => '无隐藏标题';

  @override
  String get hiddenTitlesDescription => '您在“精选”栏目中隐藏的影片将显示在此处，您可以随时恢复它们。';

  @override
  String get tvShow => '电视节目';

  @override
  String get movie => '电影';

  @override
  String get aiConsentGranted => '您已选择加入。您的图书馆数据用于个性化推荐。';

  @override
  String get aiConsentNotGranted => '除非您选择加入，否则您的图书馆数据永远不会共享。';

  @override
  String get languageSettingExplanation =>
      '电影和电视选项卡严格使用此功能。探索者首先喜欢它，当铁路变得稀疏时就会退缩。';

  @override
  String get filterScreenTitle => '过滤器';

  @override
  String get sortBy => '排序';

  @override
  String get genres => '流派';

  @override
  String get year => '年份';

  @override
  String get rating => '评分';

  @override
  String get runtime => '运行时间';

  @override
  String get withPeople => '与人';

  @override
  String get voteCount => '投票计数';

  @override
  String get today => '今天';

  @override
  String get tomorrow => '明天';

  @override
  String get yesterday => '昨天';

  @override
  String get minutes => '分钟';

  @override
  String get hours => '将此应用标签翻译成中文：h';

  @override
  String get cast => '演员';

  @override
  String get crew => '剧组';

  @override
  String get director => 'F@ 演员 @G@ 剧组 @H@ 导演';

  @override
  String get seasons => '季数';

  @override
  String get episodes => '剧集';

  @override
  String get overview => '概览';

  @override
  String get similar => '类似内容';

  @override
  String get recommendations => '推荐';

  @override
  String get addedToWatchlist => '已添加到观看列表';

  @override
  String get removedFromWatchlist => '已从观看列表中删除';

  @override
  String get popularity => '人气';

  @override
  String get releaseDate => '发行日期';

  @override
  String get revenueLabel => '收入';

  @override
  String get originalTitle => '原始标题';

  @override
  String get voteAverage => '投票平均值';

  @override
  String get favourites => '收藏夹';

  @override
  String get lists => '列表';

  @override
  String get watched => '观看';

  @override
  String get all => '全部';

  @override
  String get tv => '电视';

  @override
  String get librarySubtitle => '按收藏、收藏夹、笔记和腕表历史整理所有内容。';

  @override
  String get selectRegion => '选择区域';

  @override
  String get selectRegionDescription => '只有支持区域感知查询的 TMDb 端点才会使用此选择。';

  @override
  String get useAutoDetectedRegion => '使用自动检测区域';

  @override
  String get reminderRemoved => '提醒已移除';

  @override
  String releaseReminderSet(String title) {
    return '已为$title设置发布提醒。';
  }

  @override
  String episodeReminderSet(String title) {
    return '已为$title设置剧集提醒。';
  }

  @override
  String get filteredResults => '筛选结果';

  @override
  String get genreResults => '类型结果';

  @override
  String couldNotLoadContent(String error) {
    return '无法加载内容。$error';
  }

  @override
  String get noContentAvailableForThisSelection => '此选项暂无可用内容。';

  @override
  String get writer => '作家';

  @override
  String get actors => '演员';

  @override
  String get noteNotFound => '未找到笔记。';

  @override
  String yourNotesCount(int count) {
    return '您的笔记（$count）';
  }

  @override
  String get noteDeleted => '备注已删除';

  @override
  String noteDeletedWithCount(int count) {
    return '注释已删除（$count s）';
  }

  @override
  String get loadMore => '加载更多';

  @override
  String get noMoreProductionsFound => '未找到更多作品。';

  @override
  String get noProductionsFound => '未找到任何作品。';

  @override
  String get watchInsights => '观看洞察';

  @override
  String get analyzingWatchHistory => '分析您的手表历史记录……';

  @override
  String get manageHiddenTitlesDescription => '管理您已从“精选推荐”部分隐藏的影片。';

  @override
  String get tmdbLanguageMetadataNote =>
      '在这种模式下，某些轨道可能看起来比较稀疏，因为 TMDB 语言元数据对于部分目录来说不完整，但这并不一定是因为这些标题不存在。';

  @override
  String get tmdbDisclaimer => '本产品使用 TMDB API，但未获得 TMDB 的认可或认证。';

  @override
  String get useLocalLibraryForSync => '使用本地库进行同步？';

  @override
  String get themePresets => '主题预设';

  @override
  String get exitApp => '退出应用';

  @override
  String get popular => '受欢迎的';

  @override
  String couldNotLoadReminders(String error) {
    return '无法加载提醒。\n\n$error';
  }

  @override
  String get noRemindersSetYet => '尚未设置提醒。\n\n您可以从剧集追踪器或影片详情中创建提醒。';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return '第 S$seasonNumber 集 • E$episodeNumber 集';
  }

  @override
  String get movieRelease => '电影上映';

  @override
  String voteAverageStars(String voteAverage) {
    return '将此应用标签翻译成中文：$voteAverage ★';
  }

  @override
  String get addMoreTrackedContent => '将更多电影或剧集添加到您的观看列表、收藏夹或列表中。';

  @override
  String get fastPicksDescription => '根据您已保存的内容快速推荐。';

  @override
  String get releaseCalendarDescription => '一键提醒，随时掌握电影上映信息和即将播出的电视剧集。';

  @override
  String get staleWatchlist => '过期的观察名单';

  @override
  String get tracked => '已追踪';

  @override
  String get upcoming => '即将推出';

  @override
  String get upcomingEmptyDescription => '当追踪的电影确定上映日期或剧集安排了新剧集播出时，它们将显示在此处。';

  @override
  String get howManyMoviesWatchedEachMonth => '你每个月看了多少部电影';

  @override
  String get howPersonalRatingsShifting => '您的个人评分如何随时间变化';

  @override
  String get keepWatchingToBuildProfile => '持续关注，打造你的视觉形象。';

  @override
  String get lumiWatchAnalytics => 'LUMI 手表分析';

  @override
  String get noGenreDistributionYet => '目前尚无类型分类信息。';

  @override
  String get noMovieWatchHistoryRecentMonths => '最近几个月没有电影观看记录。';

  @override
  String get noRatingTrendDataYet => '目前尚无评分趋势数据。';

  @override
  String get preferredRuntime => '首选运行时';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return '建议运行时间为 ~$minutes 分钟（$label）';
  }

  @override
  String get styledCardWithWatchStats => '带有您手表统计数据的精美卡片';

  @override
  String get titlesAnalyzed => '分析的标题';

  @override
  String get tryAgainAfterMoment => '稍等片刻再试。';

  @override
  String get watchAnalytics => '观察分析';

  @override
  String get whatGenresDominateHistory => '你的观看历史中，哪些类型电影或电视剧占据主导地位？';

  @override
  String get toggleMovies => '电影';

  @override
  String get toggleTv => '电视';

  @override
  String get noMoreTitlesFound => '未找到更多标题。';

  @override
  String get noTitlesFoundForKeyword => '未找到与此关键词相关的标题';

  @override
  String get viewFull => '查看完整内容';

  @override
  String get accoladeDetails => '荣誉详情';

  @override
  String get noDetailedAwardsInfo => '暂无详细的获奖信息。';

  @override
  String get alertSet => '警报已设置！';

  @override
  String get budget => '预算';

  @override
  String get buy => '买';

  @override
  String chooseBetweenHours(int maxHours) {
    return '请从 1 和 $maxHours 中选择';
  }

  @override
  String get deleteNoteConfirmationTitle => '删除笔记？';

  @override
  String get episodeReminder => '剧集提醒';

  @override
  String get facebook => 'Facebook';

  @override
  String get free => '自由的';

  @override
  String get images => '图片';

  @override
  String get instagram => 'Instagram';

  @override
  String get netProfit => '纯利';

  @override
  String get noNotesYet => '暂无评论。欢迎添加您的想法！';

  @override
  String get originalLanguage => '原文';

  @override
  String partOfCollection(String collectionName) {
    return '$collectionName 的一部分';
  }

  @override
  String get roi => '投资回报率';

  @override
  String releaseAlertSet(String date) {
    return '已为$date设置发布监控警报。';
  }

  @override
  String get rent => '租';

  @override
  String get revenue => '收入';

  @override
  String seeAllReviews(int count) {
    return '查看全部 ($count)';
  }

  @override
  String get setReminder => '设置提醒';

  @override
  String get status => '地位';

  @override
  String get stream => '溪流';

  @override
  String get tikTok => 'TikTok';

  @override
  String get twitterX => 'X';

  @override
  String get yours => '你的';

  @override
  String get youtube => 'YouTube';

  @override
  String get durationDays => '将此应用标签翻译成中文：d';

  @override
  String get durationHours => '将此应用标签翻译成中文：h';

  @override
  String get durationMinutes => '米';

  @override
  String get durationSeconds => '将此应用标签翻译成中文：';

  @override
  String seasonRating(String score) {
    return '将此应用标签翻译成中文：★ $score%';
  }

  @override
  String get we => '我们';

  @override
  String get aspect16x9 => '将此应用标签翻译成中文：16:9';

  @override
  String get aspect9x16 => '将此应用标签翻译成中文：9:16';

  @override
  String get background => '背景';

  @override
  String episodeCount(int count) {
    return '将此应用标签翻译成中文：$count EPS';
  }

  @override
  String get noEpisodesForSeason => '本季暂无剧集。';

  @override
  String get beautifulStyledCardForStories => '精美的社交故事卡片';

  @override
  String get clickableShareLink => '可点击分享链接，适用于 WhatsApp 和其他应用程序';

  @override
  String get placeQuoteOnBackdrop => '将你最喜欢的名言印在电影背景板上';

  @override
  String get standardLinkToMovieDatabase => '电影数据库的标准链接';

  @override
  String get exploreLabel => '探索';

  @override
  String quoteCharacter(String character) {
    return '将此应用标签翻译成中文：— $character';
  }

  @override
  String get aiTonightWatch => '今晚人工智能观察';

  @override
  String get aiQueryPlan => 'AI查询计划';

  @override
  String get airingToday => '今天播出';

  @override
  String get bigCrowdPleasers => '势头强劲，深受观众喜爱。';

  @override
  String get cinematic => '电影';

  @override
  String get comingSoon => '即将推出';

  @override
  String get currentTheatricalSlate => '当前影院上映片单及近期上映影片';

  @override
  String get dark => '黑暗的';

  @override
  String get discoverSpotlight => '探索聚焦';

  @override
  String get edgeOfYourSeat => '令人屏息的';

  @override
  String get fastPaced => '快节奏';

  @override
  String get feelGood => '感觉良好';

  @override
  String get freshPicksContinuous => '最新精选持续更新';

  @override
  String get hideTitle => '隐藏标题';

  @override
  String get highRatedSkipped => '评分很高的影片，大多数观众都会跳过。';

  @override
  String get hotNowAudience => '现在观众群里很火';

  @override
  String get inTheaters => '影院上映';

  @override
  String get indie => '独立';

  @override
  String get mindBending => '令人费解';

  @override
  String get mostDiscussedShowsThisWeek => '本周最受关注的节目';

  @override
  String get multiplePicks => '多项选择';

  @override
  String get onTheAir => '空中直播';

  @override
  String get personalizedFromWatchBehavior => '根据您的手表行为进行个性化设置';

  @override
  String get pickAVibe => '选择一种风格，即可获得与之匹配的标题';

  @override
  String get seeAll => '查看全部';

  @override
  String get seriesCurrentlyAiring => '目前正在播出且有新剧集的剧集';

  @override
  String get thisWeek => '本星期';

  @override
  String get topRated => '评分最高';

  @override
  String get voiceInput => '语音输入';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% 匹配';
  }

  @override
  String runtimeMinutes(String minutes) {
    return '$minutes 分钟';
  }

  @override
  String get examplePrompt => '例如：类似《星际穿越》的电影，但不是科幻片。';

  @override
  String findingYourPerfectWatch(String dots) {
    return '找到您的完美腕表$dots';
  }

  @override
  String get moreLikeThis => '更多类似内容';

  @override
  String get notForMe => '不适合我';

  @override
  String get recentQueries => '近期查询';

  @override
  String get shufflingIdeas => '重新整理思路……';

  @override
  String get tooMainstream => '太主流了';

  @override
  String get whatShouldIWatchTonight => '今晚我该看什么？';

  @override
  String debugLogEntry(String time, String message) {
    return '将此应用标签翻译成中文：[$time] $message';
  }

  @override
  String get from => '从';

  @override
  String get to => '到';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return '已从观察名单中移除（$seconds s）';
  }

  @override
  String creditsCount(String count) {
    return '$count 学分';
  }

  @override
  String get acrossFilmography => '电影作品';

  @override
  String get birthplace => '出生地';

  @override
  String get born => '出生';

  @override
  String get credits => '鸣谢';

  @override
  String get died => '死亡';

  @override
  String get knownFor => '以……而闻名';

  @override
  String get noSharedTitlesAvailable => '没有可共享的标题。';

  @override
  String get photos => '照片';

  @override
  String get personRating => '等级';

  @override
  String get taggedImages => '标签图片';

  @override
  String get website => '网站';

  @override
  String get noQuotesFound => '未找到引用。';

  @override
  String get noSectionsFound => '未找到任何章节。';

  @override
  String get clearAll => '全部清除';

  @override
  String get noCollectionsFound => '未找到任何收藏集';

  @override
  String get noCompaniesFound => '未找到公司';

  @override
  String get noKeywordsFound => '未找到关键词';

  @override
  String get noMoreResultsFound => '没有找到更多结果。';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String deleteListConfirmation(String listName) {
    return '您确定要删除$listName吗？';
  }

  @override
  String get deleteListTitle => '删除列表？';

  @override
  String get everythingYouPlanToWatch => '你接下来打算看的所有影片。';

  @override
  String get finishedTitlesAndHistory => '已完成的头衔以及您的历史记录和统计数据。';

  @override
  String get noListsCreatedYet => '尚未创建任何列表。';

  @override
  String get noNotesFound => '未找到笔记';

  @override
  String get renameList => '重命名列表';

  @override
  String get titlesYouNeverWantToLose => '你永远不想失去的头衔。';

  @override
  String get yourThoughtsReactions => '你的想法、反应和提醒。';

  @override
  String imageCounter(String current, String total) {
    return '将此应用标签翻译成中文：$current / $total';
  }

  @override
  String get removeFromWatchedConfirmation => '您确定要将此项目从关注列表中移除吗？';

  @override
  String get savedAsWatchedWithoutRating => '本次观看记录将被保存为已观看，但不会给出个人评分。';

  @override
  String get noAdditionalRecommendationTrailers => '未找到其他推荐预告片。';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return '将此应用标签翻译成中文：$count $itemLabel';
  }

  @override
  String get invalidSharedListLink => '该链接可能无效、过期或无法访问。';

  @override
  String get noTitlesAvailableToImport => '没有可导入的标题。';

  @override
  String get allLanguages => '所有语言';

  @override
  String get arabic => '阿拉伯';

  @override
  String get bengali => '孟加拉';

  @override
  String get chinese => '中国人';

  @override
  String get english => '英语';

  @override
  String get french => '法语';

  @override
  String get german => '德语';

  @override
  String get gujarati => '古吉拉特语';

  @override
  String get hindi => '印地语';

  @override
  String get indonesian => '印度尼西亚';

  @override
  String get italian => '意大利语';

  @override
  String get japanese => '日本人';

  @override
  String get kannada => '卡纳达语';

  @override
  String get korean => '韩国人';

  @override
  String get malayalam => '马拉雅拉姆语';

  @override
  String get marathi => '马拉地语';

  @override
  String get persian => '波斯语';

  @override
  String get polish => '抛光';

  @override
  String get portuguese => '葡萄牙语';

  @override
  String get punjabi => '旁遮普语';

  @override
  String get russian => '俄语';

  @override
  String get spanish => '西班牙语';

  @override
  String get swedish => '瑞典';

  @override
  String get tamil => '泰米尔语';

  @override
  String get telugu => '泰卢固语';

  @override
  String get thai => '泰国';

  @override
  String get turkish => '土耳其';

  @override
  String get urdu => '乌尔都语';

  @override
  String get vietnamese => '越南语';

  @override
  String get failedToLoadCollectionDetails => '加载收藏详情失败';

  @override
  String get franchiseProgress => '特许经营进展';

  @override
  String get officialSite => '官方网站';

  @override
  String get productions => '制作';

  @override
  String get productionCompany => '生产公司';

  @override
  String get failedToLoadCompanyInfo => '公司信息加载失败';

  @override
  String get profile => '轮廓';

  @override
  String get guestViewer => '访客观众';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      '您的个人资料、同步状态、地区和视觉偏好都显示在这里。';

  @override
  String get signInToSync => '登录以同步您的观看列表、评分和偏好设置。';

  @override
  String get signedInAndSyncing => '已登录并正在同步到云端。';

  @override
  String get developedBy => '由……开发';

  @override
  String get couldNotAnalyzeWatchHistory => '目前无法分析手表历史记录。';

  @override
  String get includeLocalLibrary => '包括当地图书馆';

  @override
  String get useCloudOnly => '仅使用云端';

  @override
  String get localLibrarySyncDescription =>
      '此设备已存储本地图书馆资源。您可以将其添加到已登录的图书馆，或将本地图书馆数据替换为您的云端图书馆数据。';

  @override
  String get mergedLocalTitles => '已将本地图书合并到您已登录的图书库中。';

  @override
  String get replacedLocalLibrary => '已将本地库数据替换为您的云端库数据。';

  @override
  String get deleteAccountConfirmation =>
      '此操作将永久删除您的 Lumi 帐户和同步的云端数据。除非您单独删除应用数据，否则设备上的本地数据将保留。';

  @override
  String get signedOutAndCleared => '已注销并清除此设备上的本地库。';

  @override
  String get keepLocalLibrary => '保留本地图书馆';

  @override
  String get clearLocalLibrary => '清晰本地图书馆';

  @override
  String get signOutChoiceDescription => '选择退出登录后是否在此设备上保留本地库。';

  @override
  String get disable => '禁用';

  @override
  String get aiRecommendationsEnabled => '已启用人工智能推荐数据共享。';

  @override
  String get aiRecommendationsDisabled => '已禁用人工智能推荐数据共享。';

  @override
  String get reviewAndManageConsent => '审核并管理向人工智能提供商发送图书馆数据的许可协议。';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      '已启用。“今晚推荐”功能可能会将您的图书馆摘要和最近查询发送给人工智能提供商。';

  @override
  String basedOnWatchedTitles(String count) {
    return '根据$count观看次数计算';
  }

  @override
  String lastUpdated(String date) {
    return '最后更新时间：$date';
  }

  @override
  String get chooseYourVibe => '选择你的风格';

  @override
  String get appearanceDescription => '在不改变任何行为的情况下，在不同的电影角色之间切换应用程序。';

  @override
  String get exitAppConfirmation => '您确定要退出 Lumi 吗？';

  @override
  String get dismiss => '解雇';

  @override
  String get generatingWatchAnalytics => '生成手表分析';

  @override
  String get thisUsuallyTakesAFewSeconds => '这通常需要几秒钟。';

  @override
  String get yourScreenStory => '你的屏幕故事';

  @override
  String get snapshotOfHowAndWhatYouWatch => '简要介绍您的观看方式和内容';

  @override
  String get yourFavoriteGenres => '你最喜欢的类型';

  @override
  String get genrePerformanceHighestRated => '类型表现（最高评分）';

  @override
  String get personalizedViewingPatterns => '个性化观看模式';

  @override
  String get builtWithLumi => '基于 Lumi 构建';

  @override
  String get sharedWithLumi => '与 Lumi 共享';

  @override
  String get shareAnalytics => '分享分析';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return '分析了 $count 个标题 • 更新了 $date';
  }

  @override
  String get allSeasons => '四季';

  @override
  String get castAndCrew => '演员及工作人员';

  @override
  String get featuredCrew => '特邀嘉宾';

  @override
  String get stills => '剧照';

  @override
  String get accoladeSummary => '荣誉总结';

  @override
  String get awardsAndAccolades => '奖项与荣誉';

  @override
  String get unableToLoadMovieDetails => '无法加载影片详情';

  @override
  String get overviewUnavailable => '此标题暂无概述。';

  @override
  String get openCompletePlot => '从 OMDb 打开完整图表和额外元数据。';

  @override
  String get noOverviewForSeason => '本赛季暂无概览。';

  @override
  String get userScore => '用户评分';

  @override
  String get playTrailer => '播放预告片';

  @override
  String get whereToWatch => '观看渠道';

  @override
  String get availabilityDataByJustWatch => '可用性数据由 JustWatch 提供。';

  @override
  String get reminderSaved => '提醒已保存';

  @override
  String reminderForTitle(String title) {
    return '提醒 $title';
  }

  @override
  String get pleaseSelectFutureTime => '请选择未来的时间';

  @override
  String get notifyAt => '通知';

  @override
  String get notifyHoursBeforeAiring => '播出前多少小时通知？';

  @override
  String enterNumberBetween(String maxHours) {
    return '请输入 1 到 $maxHours 之间的数字';
  }

  @override
  String get set => '放';

  @override
  String get selectedReminderTimePassed => '所选提醒时间已过';

  @override
  String episodeReminderSaved(String date) {
    return '已为$date保存剧集提醒';
  }

  @override
  String get areYouSureDeleteNote => '您确定要删除此笔记吗？';

  @override
  String get noteAdded => '补充说明';

  @override
  String get lastSeason => '上个赛季';

  @override
  String get currentSeason => '本季';

  @override
  String get viewAllSeasons => '查看所有季节';

  @override
  String get removedFromFavourites => '已从收藏夹中移除';

  @override
  String get addedToFavourites => '已添加到收藏夹';

  @override
  String get awardsAndNominations => '奖项与提名';

  @override
  String get viewAll => '查看全部';

  @override
  String get boxOfficeFinancials => '票房财务数据';

  @override
  String get successMeter => '成功率';

  @override
  String get blockbuster => '大片';

  @override
  String get hit => '打';

  @override
  String get breakEven => '收支平衡';

  @override
  String get underperformer => '表现不佳者';

  @override
  String get boxOfficeBomb => '票房惨败';

  @override
  String get episodeTracker => '剧集追踪器';

  @override
  String get setAiringReminder => '设置播出提醒';

  @override
  String get nextEpisodeCountdown => '下一集倒计时';

  @override
  String get nextEpisode => '下一集';

  @override
  String get lastEpisodeToAir => '最后一集即将播出';

  @override
  String get unknown => '未知';

  @override
  String get contentAdvisory => '内容建议';

  @override
  String get violence => '暴力';

  @override
  String get sexAndNudity => '性与裸露';

  @override
  String get foulLanguage => '语言';

  @override
  String get substances => '物质';

  @override
  String get fearAndHorror => '恐惧与惊悚';

  @override
  String get familyFriendly => '适合家庭';

  @override
  String get generalAudience => '普通观众';

  @override
  String get releaseTimeline => '发布时间表';

  @override
  String get notifyMe => '通知我';

  @override
  String get theatricalRelease => '院线发行';

  @override
  String get digitalStreaming => '数字/流媒体';

  @override
  String get physicalRelease => '实体版（蓝光/DVD）';

  @override
  String get awesome => '惊人的';

  @override
  String get keywordsAndThemes => '关键词和主题';

  @override
  String get videosAndBehindTheScenes => '视频和幕后花絮';

  @override
  String get productionStudios => '制作工作室';

  @override
  String get fetchingWatchLink => '正在获取手表链接';

  @override
  String get findingBestProviderPage => '找到该标题的最佳提供商页面。';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode';
  }

  @override
  String get error => '错误';

  @override
  String get failedToLoadSeasonDetails => '未能加载赛季详情';

  @override
  String get loading => '加载中...';

  @override
  String runtimeSeparator(String runtime) {
    return '将此应用标签翻译成中文：• $runtime';
  }

  @override
  String get fullCastAndCrew => '完整演员及工作人员名单';

  @override
  String get shareMovie => '分享电影';

  @override
  String get quotes => '引号';

  @override
  String get mayIncludeMismatches => '由于词法引用搜索，可能偶尔会出现不匹配的情况。';

  @override
  String get movieApiConfigurationRequired => '需要配置电影 API';

  @override
  String get addMovieProxyBaseUrl =>
      '添加 MOVIE_PROXY_BASE_URL 以将应用程序连接到 TMDB 代理。';

  @override
  String get cinematicPicksContext => '电影感十足的精选卡牌，瞬间营造氛围。再掷一次，看看有没有惊喜卡牌。';

  @override
  String get curatedTonight => '今晚精选';

  @override
  String curatedTonightTitle(String title) {
    return '今晚精选：$title';
  }

  @override
  String get describeItYourWay => '请用您喜欢的方式描述一下。\n\n我们会帮您找到最佳匹配。';

  @override
  String get hide => '隐藏';

  @override
  String get hideTitleDescription => '隐藏此标题将使其将来不再出现在“焦点”栏目中。';

  @override
  String get dontAskAgain => '不要再问了';

  @override
  String get imdbNa => '将此应用标签翻译成中文：IMDb NA';

  @override
  String get noDiscoverPicks => '目前暂无精选推荐。';

  @override
  String get playPreview => '播放预览';

  @override
  String get recommendedForYou => '为您推荐';

  @override
  String get spotlightCompleted => '聚光灯已完成';

  @override
  String get startAddingTitlesForRecommendations => '开始添加推荐标题';

  @override
  String get clearedAllChoices => '您已滑动并清除了发现信息流中的所有选项。';

  @override
  String get whatsPopular => '热门推荐';

  @override
  String get trending => '热门话题';

  @override
  String get trendingPeople => '热门人物';

  @override
  String get starringTodayOrThisWeek => '今天或本周的明星趋势';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get tvTrending => '电视热搜';

  @override
  String get discoverByMood => '按心情发现';

  @override
  String get needSomethingToWatchTonight => '今晚想看点什么吗？';

  @override
  String get needAMovieForTonight => '今晚想看部电影吗？';

  @override
  String get tryAiShows => '试试人工智能节目';

  @override
  String get tryAiMovies => '试试AI电影';

  @override
  String get findShows => '查找节目';

  @override
  String get findMovies => '查找电影';

  @override
  String get couldNotLoadThisRail => '无法加载此轨道';

  @override
  String get temporaryIssueLoadingRail => '这条铁轨的装载暂时出现了问题。';

  @override
  String get noTitlesHereYet => '这里暂无标题';

  @override
  String get noHiddenGemsForGenre => '目前尚未发现该类型中的佳作。不妨试试其他类型。';

  @override
  String get tryAnotherFilter => '尝试使用其他筛选条件，或打开此部分进行更广泛的探索。';

  @override
  String get seeAllFilters => '查看所有筛选条件';

  @override
  String get couldNotLoadCuratedPicks => '无法加载精选推荐';

  @override
  String get temporaryIssueLoadingCurated => '今晚的精选歌单加载时出现了一些暂时性问题。';

  @override
  String get noCuratedPicksAvailable => '暂无精选推荐';

  @override
  String get tryAgainWhileRefresh => '稍等片刻，我们正在刷新今晚的TMDB列表，请稍后再试。';

  @override
  String get fromSpotlight => '来自聚光灯';

  @override
  String get addShowsMoviesForRecommendations =>
      '将电视节目/电影添加到您的观看列表、收藏夹或已观看列表，即可查看您可能喜欢的作品。';

  @override
  String get allow => '允许';

  @override
  String get notNow => '现在不要';

  @override
  String get allowAiDataSharingTitle => '允许人工智能数据共享吗？';

  @override
  String get allowAiDataSharingDescription =>
      'Recommend Tonight 会将您输入的电影推荐请求文本和临时查询优化上下文发送给 Google Gemini 和 OpenRouter。您的完整片库和登录凭据不会发送给这些 AI 提供商。您是否允许此类数据共享用于 AI 推荐？';

  @override
  String get liveProgress => '实时进度';

  @override
  String percentComplete(String percent) {
    return '$percent% 完成';
  }

  @override
  String get describeIdealShowNight => '描述一下你理想中的演出之夜';

  @override
  String get describeIdealMovieNight => '描述一下你理想的电影之夜';

  @override
  String get useNaturalLanguage => '请使用自然语言。请说明您的需求、需要避免的问题，以及可选的语言/运行时提示。';

  @override
  String get listeningTapMicToStop => '正在监听……再次点击麦克风即可停止。';

  @override
  String voiceInputError(String error) {
    return '语音输入错误：$error';
  }

  @override
  String get tapMicToDictate => '点击麦克风说出您的请求。';

  @override
  String get tapMicToEnableVoice => '点击麦克风启用语音输入。';

  @override
  String get findingShows => '寻找节目……';

  @override
  String get findingMovies => '寻找电影……';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return '今晚 Lumi 的推荐：$prompt';
  }

  @override
  String get tonightsPicks => '今晚精选';

  @override
  String get sharedFromLumi => '分享自 Lumi';

  @override
  String get intent => '意图：';

  @override
  String get genreLabel => '类型：';

  @override
  String get avoid => '避免：';

  @override
  String get languageLabel => '语言：';

  @override
  String runtimeAtMost(String minutes) {
    return '运行时间 <= $minutes 分钟';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return '运行时间 >= $minutes 分钟';
  }

  @override
  String get yearLabel => '年：';

  @override
  String yearAfter(String year) {
    return '在 $year 之后';
  }

  @override
  String yearBefore(String year) {
    return '在$year之前';
  }

  @override
  String get like => '喜欢：';

  @override
  String get signal => '信号：';

  @override
  String get readingWatchedHistory => '正在读取您的观看记录……';

  @override
  String get findingTopGenres => '找到你最喜欢的类型和模式……';

  @override
  String get buildingTrends => '构建月度和评级趋势……';

  @override
  String get writingInsights => '撰写您的个性化见解……';

  @override
  String get applyFilters => '应用筛选条件';

  @override
  String get includeNotRated => '包含未评级';

  @override
  String get errorLoadingTvGenres => '加载电视节目类型时出错';

  @override
  String get alsoKnownAs => '又称';

  @override
  String get biography => '传';

  @override
  String get careerStatistics => '职业统计';

  @override
  String get frequentlyCollaboratesWith => '经常与……合作';

  @override
  String get notableQuotes => '名言';

  @override
  String get primaryRole => '主要职责';

  @override
  String get averageRating => '平均评分';

  @override
  String get topGenre => '热门类型';

  @override
  String get peakBoxOffice => '票房巅峰';

  @override
  String percentOfTitles(String percent) {
    return '$percent% 标题';
  }

  @override
  String sharedTitleCount(String count) {
    return '$count 共享标题';
  }

  @override
  String billingOrder(String order) {
    return '账单编号 #$order';
  }

  @override
  String get startTypingToSearch => '开始输入以进行搜索';

  @override
  String get movieDiscoveryMadePersonal => '电影发现，个性化体验';

  @override
  String get allNotes => '所有笔记';

  @override
  String get viewPersonalizedInsights => '查看个性化见解、图表和趋势。';

  @override
  String get curatedCollections => '精选系列';

  @override
  String get list => '列表';

  @override
  String get openList => '打开列表';

  @override
  String get thisListNoLongerExists => '此列表已不存在';

  @override
  String listRenamed(String name) {
    return '列表已重命名为$name';
  }

  @override
  String listDeleted(String name) {
    return '列表 $name 已删除';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return '您的关注列表中没有$filter';
  }

  @override
  String noFilterInFavourites(String filter) {
    return '您的收藏夹中没有$filter';
  }

  @override
  String noFilterInWatched(String filter) {
    return '没有$filter在观看';
  }

  @override
  String noFilterInThisList(String filter) {
    return '此列表中没有$filter';
  }

  @override
  String noListsWithFilter(String filter) {
    return '没有包含 $filter 的列表';
  }

  @override
  String importedInto(String name) {
    return '已导入到“$name”';
  }

  @override
  String get couldNotImportList => '无法导入列表';

  @override
  String get importing => '输入...';

  @override
  String get couldNotLoadSharedList => '无法加载此共享列表';

  @override
  String get editWatchedInfo => '编辑观看信息';

  @override
  String get watchDate => '观看日期';

  @override
  String get rewatchCount => '重看次数';

  @override
  String get watchedInfoUpdated => '观看信息已更新';

  @override
  String removedFromList(String listName) {
    return '已从$listName中移除';
  }

  @override
  String addedToList(String listName) {
    return '已添加到$listName';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return '已添加到$listName和观察名单';
  }

  @override
  String get moreTrailersLikeThis => '更多类似预告片';

  @override
  String get noDescriptionForTrailer => '此预告片暂无描述。';

  @override
  String get closeTrailer => '接近预告片';

  @override
  String get recommendedSeries => '推荐剧集';

  @override
  String get recommendedMovie => '推荐电影';

  @override
  String get notEnoughDataYet => '数据不足';

  @override
  String addAndRateMoreTitles(String count) {
    return '添加并评价至少 $count 个标题，即可解锁分析功能。';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return '您已观看$watchedCount/$requiredCount部影片。再观看$remaining部影片即可解锁分析功能。';
  }

  @override
  String get moviesPerMonth => '每月电影数量';

  @override
  String get genreDistribution => '类型分布';

  @override
  String get ratingTrends => '评分趋势';

  @override
  String get noData => '无数据';

  @override
  String get myLatestWatchAnalytics => '我最新的 Lumi 手表分析';

  @override
  String get myWatchInsights => '我对 Lumi 手表的见解';

  @override
  String get infographicsCard => '信息图表卡';

  @override
  String get watchInsightsSnapshot => '观看洞察快照';

  @override
  String get availableOnceInsightsReady => '一旦洞察结果准备就绪，即可使用。';

  @override
  String get shareYourWatchInsights => '分享您的腕表洞察卡';

  @override
  String get recentlyWatchedVibe => '最近观看的Vibe';

  @override
  String get mixedAcrossGenres => '融合多种风格';

  @override
  String get moviesPerMonthShort => '每月电影';

  @override
  String get ratingTrend => '评级趋势';

  @override
  String get balanced => '均衡';

  @override
  String get noWatchNextSuggestionsYet => '暂无观看建议';

  @override
  String get upcomingFromLibrary => '图书馆即将上线';

  @override
  String get removeReminder => '移除提醒';

  @override
  String get remindMe => '提醒我';

  @override
  String titleReleasesToday(String title) {
    return '$title今天发布。';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle 即将播出。';
  }

  @override
  String get controlPremiereAlerts => '控制首映提醒和发行提醒。';

  @override
  String upcomingReleasesCount(String count) {
    return '$count 即将在您的图书馆中发布。';
  }

  @override
  String sittingInWatchlist(String days) {
    return '已在您的关注列表中停留$days天';
  }

  @override
  String get alreadyOnWatchlist => '已在您的关注列表中';

  @override
  String get favouritedButNotWatched => '您已收藏此内容，但尚未标记为已观看。';

  @override
  String get savedInListReady => '已保存到您的某个列表中，随时可以观看';

  @override
  String get matchesTitlesYouTrack => '与您已关注的比赛标题';

  @override
  String get noOfficialSite => '没有官方网站';

  @override
  String get episodeAiring => '剧集播出';

  @override
  String get general => '一般的';

  @override
  String scheduledFor(String date) {
    return '计划于$date';
  }

  @override
  String wasScheduledFor(String date) {
    return '原定于$date';
  }

  @override
  String get noOverviewAvailable => '暂无概述。';

  @override
  String get searchHistoryCleared => '搜索历史记录已清除';

  @override
  String get visualMovieCard => '视觉电影卡';

  @override
  String get smartLumiLink => '将此应用标签翻译成中文：Smart Lumi Link';

  @override
  String get directTmdbLink => 'TMDB 直接链接';

  @override
  String recommendedOnLumi(String title) {
    return 'Lumi 推荐：$title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return '快来 Lumi 看看 $title！\n\n$link\n\n获取 Lumi：$appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return '请在TMDB上查看$title：$link';
  }

  @override
  String releaseAlertTitle(String title) {
    return '$title 释放警报';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return '已设置产品发布提醒，产品为$date。产品发布后，我们将通知您。';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return '“$title”一旦以数字版或蓝光/DVD形式发行，我们将立即通知您！';
  }

  @override
  String get episodeAlreadyDueToAir => '这一集已经预定播出。';

  @override
  String get reminderSetSuccessfully => '提醒设置成功';

  @override
  String get speechRecognitionNotAvailable => '此设备不支持语音识别功能。';

  @override
  String get describeShowMood => '描述一下你想看什么类型的节目，我们会返回一个排名列表。';

  @override
  String get describeMovieMood => '描述一下你想看的电影类型，我们会返回一个排名列表。';

  @override
  String get aiLauncherDescription =>
      '输入或说出自然语言请求。Lumi 会构建人工智能方案，运行向量搜索，并返回多个节目/电影推荐。';

  @override
  String yearRange(String from, String to) {
    return '将此应用标签翻译成中文：$from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return '已安排 $count 提醒。';
  }

  @override
  String regionAutoDetected(String region) {
    return '自动检测到：$region';
  }

  @override
  String regionSelected(String region) {
    return '已选择：$region';
  }

  @override
  String get allLanguagesSubtitle => '所有语言';

  @override
  String currentlySetToLanguage(String language) {
    return '当前设置为$language';
  }

  @override
  String get availabilities => '可用性';

  @override
  String get mood => '情绪';

  @override
  String get people => '人们';

  @override
  String get ads => '广告';

  @override
  String get theatricalLimited => '戏剧有限公司';

  @override
  String get premier => '总理';

  @override
  String get mediaType => '媒体类型';

  @override
  String get couldNotLoadAnalytics => '分析数据无法加载';

  @override
  String get viewAllAwards => '查看全部';

  @override
  String get win => '赢';

  @override
  String get wins => '胜利';

  @override
  String get nomination => '提名';

  @override
  String get nominations => '提名';

  @override
  String sharedBy(String name) {
    return '由 $name 分享';
  }

  @override
  String titleCount(String count) {
    return '$count 标题';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count 已保存到您的列表中';
  }

  @override
  String get curatedCollectionsSubtitle => '您可以整理和分享精选合集。';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return '将“$name”导入 Lumi（$count $itemLabel）：$link';
  }

  @override
  String get notEnoughData => '数据不足';

  @override
  String shareQuote(String title) {
    return '来看看 Lumi 上“$title”的这段话！';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Lumi 推荐：$title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      '输入或说出自然语言请求。Lumi 会构建人工智能方案，运行向量搜索，并返回多个节目推荐。';

  @override
  String get aiLauncherDescriptionMovie =>
      '输入或说出自然语言请求。Lumi 会构建人工智能方案，运行向量搜索，并返回多个电影推荐。';

  @override
  String get warmingUpMovieSearch => '为你的影片搜索热身';

  @override
  String get connectingToRecommendationEngine => '连接到推荐引擎';

  @override
  String get understandingYourTaste => '了解自己想做什么';

  @override
  String get buildingCustomSearch => '根据您的请求构建自定义搜索';

  @override
  String get tinyNetworkHiccup => '网络出现轻微故障，正在重试';

  @override
  String get planLocked => '计划已定：类型、风格、语言和时长';

  @override
  String get scanningTmdb => '正在扫描 TMDB 以查找强匹配项';

  @override
  String get collectingDetails => '收集热门影片的海报、评分和片长信息';

  @override
  String shortlistingPicksCount(String current, String total) {
    return '入围名单（$current/$total）';
  }

  @override
  String get shortlistingBestPicks => '筛选出最佳人选';

  @override
  String get finalPolish => '对您的建议进行最终完善';

  @override
  String get retryingAfterIssue => '暂时性问题后重试';

  @override
  String get regionUnitedStates => '美国';

  @override
  String get regionIndia => '印度';

  @override
  String get regionUnitedKingdom => '英国';

  @override
  String get regionCanada => '加拿大';

  @override
  String get regionAustralia => '澳大利亚';

  @override
  String get regionNewZealand => '新西兰';

  @override
  String get regionGermany => '德国';

  @override
  String get regionFrance => '法国';

  @override
  String get regionSpain => '西班牙';

  @override
  String get regionItaly => '意大利';

  @override
  String get regionJapan => '日本';

  @override
  String get regionSouthKorea => '韩国';

  @override
  String get regionBrazil => '巴西';

  @override
  String get regionMexico => '墨西哥';

  @override
  String get regionSingapore => '新加坡';

  @override
  String get regionPhilippines => '菲律宾';

  @override
  String get regionIndonesia => '印度尼西亚';

  @override
  String get regionUnitedArabEmirates => '阿拉伯联合酋长国';

  @override
  String get regionSaudiArabia => '沙特阿拉伯';

  @override
  String get regionTurkey => '火鸡';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return '自动检测到的区域：$regionLabel ($regionCode)。选择一个区域以覆盖本地化电影查询和观看提供商查找。';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return '已选择区域：$regionLabel ($regionCode)。支持的电影查询和观看提供商查找下次将自动重用此区域。';
  }

  @override
  String get syncSignInTooltip => '登录以与云端同步';

  @override
  String get syncFailedTooltip => '同步失败。点击重试。';

  @override
  String get syncedTooltip => '图书馆已与云端同步';

  @override
  String get shareQuoteTooltip => '分享报价';

  @override
  String get copyQuoteTooltip => '复制报价';

  @override
  String get quoteCopiedToast => '引用已复制到剪贴板';

  @override
  String get shareDialogueTooltip => '分享对话';

  @override
  String get copyDialogueTooltip => '复制对话';

  @override
  String get dialogueCopiedToast => '对话已复制到剪贴板';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$title 将于1小时后播出';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel “$episodeName”在 $localAirTime 播出。';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$title 今天发布';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return '您片库中的一部电影将于$localDate上映。';
  }

  @override
  String get curatedNeoNoirNights => '新黑色之夜';

  @override
  String get curatedPulsePoundingRush => '令人心跳加速的快感';

  @override
  String get curatedFeelGoodEscape => '令人愉悦的逃离';

  @override
  String get curatedMindBenders => '烧脑';

  @override
  String get curatedEpicWorlds => '史诗世界';

  @override
  String get curatedHumanStories => '人类故事';

  @override
  String get curatedDarkDetectiveFiles => '黑暗侦探档案';

  @override
  String get curatedNeoNoirNightsDescription =>
      '雨水浸透的紧张气氛，道德灰色地带的主角，以及充满氛围的城市故事。';

  @override
  String get curatedPulsePoundingRushDescription => '高风险追逐、不断升级的危险和令人喘不过气的节奏。';

  @override
  String get curatedFeelGoodEscapeDescription => '温馨的故事、振奋人心的情节和令人放松的夜晚必备佳作。';

  @override
  String get curatedMindBendersDescription => '颠覆现实的概念、曲折的情节和宏大的故事构思。';

  @override
  String get curatedEpicWorldsDescription => '宏大的宇宙冒险，史诗般的格局，以及电影般的规模。';

  @override
  String get curatedHumanStoriesDescription => '以人物塑造为主，情感饱满，表演令人难忘的剧集。';

  @override
  String get curatedDarkDetectiveFilesDescription => '冷冰冰的线索、错综复杂的嫌疑人和进展缓慢的调查。';

  @override
  String get appLanguage => '应用语言';

  @override
  String get appLanguageSystemDefault => '系统默认设置';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return '应用程序语言设置为$language。这只会更改应用程序界面，不会更改电影和节目的语言。';
  }

  @override
  String get appLanguageSystemSubtitle => '应用语言会跟随您的设备设置。更改应用语言即可使用其他语言显示界面。';

  @override
  String get contentLanguageAllSubtitle =>
      '所有语言。电影和电视节目标签页的内容依然广泛，而“探索”标签页在有更符合本地特色的内容时，仍会优先推荐。';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return '目前设置为$language。电影和电视标签页将保持严格设置，而探索页面将优先使用此语言。';
  }
}
