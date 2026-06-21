// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Lumi';

  @override
  String get navExplore => 'Explorar';

  @override
  String get navMovies => 'Filmes';

  @override
  String get navTvShows => 'Programas de TV';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navAccount => 'Conta';

  @override
  String get searchHint => 'Pesquisar filmes, programas de TV, empresas...';

  @override
  String get searchForPerson => 'Pesquisar uma pessoa...';

  @override
  String get searchLanguages => 'Pesquisar idiomas';

  @override
  String get searchNameOrRole => 'Pesquisar nome ou função...';

  @override
  String get retry => 'Repetir';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get clear => 'Limpar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get share => 'Compartilhar';

  @override
  String get undo => 'Desfazer';

  @override
  String get close => 'Fechar';

  @override
  String get apply => 'Aplicar';

  @override
  String get reset => 'Redefinir';

  @override
  String get done => 'Concluído';

  @override
  String get signInWithGoogle => 'Faça login com Google';

  @override
  String get signInWithApple => 'Faça login com Apple';

  @override
  String get signOut => 'Sair';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get accountDeletedSuccessfully => 'Conta excluída com sucesso.';

  @override
  String get appearance => 'Aparência';

  @override
  String get appearanceSubtitle =>
      'Escolha seu tema e personalize a aparência do aplicativo.';

  @override
  String get notifications => 'Notificações';

  @override
  String get releaseCalendar => 'Calendário de lançamento';

  @override
  String get hiddenTitles => 'Títulos ocultos';

  @override
  String get aiRecommendationsPrivacy => 'Recomendações de IA Privacidade';

  @override
  String get contentRegion => 'Região de conteúdo';

  @override
  String get contentLanguage => 'Idioma do conteúdo';

  @override
  String get watchlist => 'Lista de observação';

  @override
  String get notes => 'Notas';

  @override
  String get deleteNote => 'Excluir nota';

  @override
  String get addNoteHint => 'Adicionar uma nota...';

  @override
  String get addBriefNoteHint => 'Adicione uma breve nota (opcional)...';

  @override
  String get enterNewName => 'Digite o novo nome...';

  @override
  String get importSharedList => 'Importar lista compartilhada';

  @override
  String get discoverOnLumi => 'DESCUBRA NO LUMI';

  @override
  String get filtered => 'Filtrado';

  @override
  String get fullPlot => 'Gráfico completo';

  @override
  String get userReviews => 'Avaliações de usuários';

  @override
  String get noReviewsYet => 'Ainda não há comentários.';

  @override
  String get openInYouTube => 'Abrir no YouTube';

  @override
  String get hiddenGems => 'Tesouros Escondidos';

  @override
  String get resetSpotlight => 'Redefinir Spotlight';

  @override
  String get clearPreferences => 'Limpar preferências';

  @override
  String get refreshPicks => 'Atualizar escolhas';

  @override
  String get shareBoard => 'Compartilhar quadro';

  @override
  String get exploreDetails => 'Explorar detalhes';

  @override
  String get searchWikiquotes => 'Pesquisar Wikiquotes';

  @override
  String get selectAQuote => 'Selecionar uma citação';

  @override
  String get tooltipShareQuote => 'Compartilhar citação';

  @override
  String get tooltipCopyQuote => 'Copiar citação';

  @override
  String get tooltipShareDialogue => 'Compartilhar diálogo';

  @override
  String get tooltipCopyDialogue => 'Copiar diálogo';

  @override
  String get tooltipUnhide => 'Mostrar';

  @override
  String get tooltipOpenPrivacyPolicy => 'Abrir política de privacidade';

  @override
  String get tooltipRefreshInsights => 'Atualizar insights';

  @override
  String get tooltipSortTitles => 'Classificar títulos';

  @override
  String get tooltipSearch => 'Pesquisar';

  @override
  String get tooltipFilters => 'Filtros';

  @override
  String get tooltipSaveToGallery => 'Salvar na Galeria';

  @override
  String get tooltipShare => 'Compartilhar';

  @override
  String get tooltipShareAnalytics => 'Compartilhar análises';

  @override
  String get tooltipSetAiringReminder => 'Definir lembrete de exibição';

  @override
  String get tooltipLibrarySynced => 'Biblioteca sincronizada com nuvem';

  @override
  String get noMoreEntries => 'Não há mais inscrições.';

  @override
  String get noItemsFound => 'Nenhum item encontrado';

  @override
  String errorLoadingGenres(String error) {
    return 'Erro ao carregar gêneros: $error';
  }

  @override
  String errorGeneric(String error) {
    return 'Erro: $error';
  }

  @override
  String get errorLoadingLists => 'Erro ao carregar listas';

  @override
  String errorLoadingQuotes(Object error) {
    return 'Falha ao carregar aspas: $error';
  }

  @override
  String get errorCouldNotShareAnalytics =>
      'Não foi possível compartilhar o cartão de análise.';

  @override
  String get errorCouldNotShareRecommendations =>
      'Não foi possível compartilhar o quadro de recomendações.';

  @override
  String get errorCouldNotShareInsights =>
      'Não foi possível compartilhar insights do relógio.';

  @override
  String get watchInsightsNotReady =>
      'Os insights do Watch ainda não estão prontos.';

  @override
  String titleRestoredToSpotlight(String title) {
    return '\"$title\" restaurado para o Spotlight';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '\"$title\" foi oculto';
  }

  @override
  String hiddenDate(String date) {
    return 'Oculto: $date';
  }

  @override
  String get moviesInThisCollection => 'Os filmes nesta coleção';

  @override
  String get searchPlanReady => 'O plano de pesquisa está pronto';

  @override
  String get hoursBeforeAirTime => 'Horas antes da transmissão';

  @override
  String get noUpcomingReleases => 'Nenhum lançamento futuro';

  @override
  String get noRemindersSet => 'Nenhum lembrete definido';

  @override
  String get noHiddenTitles => 'Nenhum título oculto';

  @override
  String get hiddenTitlesDescription =>
      'Os títulos que você ocultar da seção Destaques aparecerão aqui e você poderá restaurá-los a qualquer momento.';

  @override
  String get tvShow => 'PROGRAMA DE TV';

  @override
  String get movie => 'FILME';

  @override
  String get aiConsentGranted =>
      'Você ativou. Os dados da sua biblioteca são usados ​​para personalizar recomendações.';

  @override
  String get aiConsentNotGranted =>
      'Os dados da sua biblioteca nunca são compartilhados, a menos que você aceite.';

  @override
  String get languageSettingExplanation =>
      'As guias Filmes e TV usam isso estritamente. Explore prefere primeiro e recua quando um trilho fica escasso.';

  @override
  String get filterScreenTitle => 'Filtros';

  @override
  String get sortBy => 'Classificar por';

  @override
  String get genres => 'Gêneros';

  @override
  String get year => 'Ano';

  @override
  String get rating => 'Classificação';

  @override
  String get runtime => 'Tempo de execução';

  @override
  String get withPeople => 'Com pessoas';

  @override
  String get voteCount => 'Contagem de votos';

  @override
  String get today => 'Hoje';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get yesterday => 'Ontem';

  @override
  String get minutes => 'Traduza este rótulo do aplicativo para pt: min';

  @override
  String get hours => 'Traduza este rótulo do aplicativo para pt: h';

  @override
  String get cast => 'Elenco';

  @override
  String get crew => 'Equipe';

  @override
  String get director => 'F@ Elenco @G@ Equipe @H@ Diretor';

  @override
  String get seasons => 'Temporadas';

  @override
  String get episodes => 'Episódios';

  @override
  String get overview => 'Visão geral';

  @override
  String get similar => 'Semelhante';

  @override
  String get recommendations => 'Recomendações';

  @override
  String get addedToWatchlist => 'Adicionado à lista de observação';

  @override
  String get removedFromWatchlist => 'Removido da lista de observação';

  @override
  String get popularity => 'Popularidade';

  @override
  String get releaseDate => 'Data de lançamento';

  @override
  String get revenueLabel => 'Receita';

  @override
  String get originalTitle => 'Título original';

  @override
  String get voteAverage => 'Média de votos';

  @override
  String get favourites => 'Favoritos';

  @override
  String get lists => 'listas';

  @override
  String get watched => 'Assistido';

  @override
  String get all => 'Todos';

  @override
  String get tv => 'TV';

  @override
  String get librarySubtitle =>
      'Mantenha tudo organizado por coleção, favoritos, anotações e histórico de visualização.';

  @override
  String get selectRegion => 'Selecione a região';

  @override
  String get selectRegionDescription =>
      'Somente os endpoints do TMDb que suportam consultas com reconhecimento de região usarão essa seleção.';

  @override
  String get useAutoDetectedRegion => 'Usar região detectada automaticamente';

  @override
  String get reminderRemoved => 'Lembrete removido';

  @override
  String releaseReminderSet(String title) {
    return 'Lembrete de lançamento definido para $title.';
  }

  @override
  String episodeReminderSet(String title) {
    return 'Lembrete de episódio definido para $title.';
  }

  @override
  String get filteredResults => 'Resultados filtrados';

  @override
  String get genreResults => 'Resultados por gênero';

  @override
  String couldNotLoadContent(String error) {
    return 'Não foi possível carregar o conteúdo. $error';
  }

  @override
  String get noContentAvailableForThisSelection =>
      'Não há conteúdo disponível para esta seleção.';

  @override
  String get writer => 'Escritor';

  @override
  String get actors => 'Atores';

  @override
  String get noteNotFound => 'Nota não encontrada.';

  @override
  String yourNotesCount(int count) {
    return 'Suas anotações ($count)';
  }

  @override
  String get noteDeleted => 'Nota excluída';

  @override
  String noteDeletedWithCount(int count) {
    return 'Nota excluída ($count s)';
  }

  @override
  String get loadMore => 'Carregar mais';

  @override
  String get noMoreProductionsFound => 'Nenhuma outra produção encontrada.';

  @override
  String get noProductionsFound => 'Nenhuma produção encontrada.';

  @override
  String get watchInsights => 'Análises de vídeo';

  @override
  String get analyzingWatchHistory =>
      'Analisando seu histórico de visualização...';

  @override
  String get manageHiddenTitlesDescription =>
      'Gerencie os títulos que você ocultou da seção Destaques.';

  @override
  String get tmdbLanguageMetadataNote =>
      'Algumas seções podem parecer vazias neste modo porque os metadados de idioma do TMDB estão incompletos para partes do catálogo, e não necessariamente porque esses títulos não existem.';

  @override
  String get tmdbDisclaimer =>
      'Este produto utiliza a API do TMDB, mas não é endossado nem certificado pelo TMDB.';

  @override
  String get useLocalLibraryForSync =>
      'Usar biblioteca local para sincronização?';

  @override
  String get themePresets => 'Predefinições de tema';

  @override
  String get exitApp => 'Sair do aplicativo';

  @override
  String get popular => 'Traduza este rótulo de aplicativo para pt: Popular';

  @override
  String couldNotLoadReminders(String error) {
    return 'Não foi possível carregar os lembretes.\n$error';
  }

  @override
  String get noRemindersSetYet =>
      'Nenhum lembrete foi definido ainda.\nCrie um a partir do Rastreador de Episódios ou dos Detalhes do Filme.';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return 'Episódio S$seasonNumber • E$episodeNumber';
  }

  @override
  String get movieRelease => 'Lançamento do filme';

  @override
  String voteAverageStars(String voteAverage) {
    return 'Traduza este rótulo do aplicativo para pt: $voteAverage ★';
  }

  @override
  String get addMoreTrackedContent =>
      'Adicione mais filmes ou séries à sua lista de favoritos, listas de reprodução ou listas em geral.';

  @override
  String get fastPicksDescription =>
      'Seleções rápidas com base no que você já economizou.';

  @override
  String get releaseCalendarDescription =>
      'Lançamentos de filmes e próximos episódios de séries com lembretes de um toque.';

  @override
  String get staleWatchlist => 'Lista de observação desatualizada';

  @override
  String get tracked => 'Rastreado';

  @override
  String get upcoming => 'Por vir';

  @override
  String get upcomingEmptyDescription =>
      'Quando filmes que estão sendo monitorados tiverem datas de lançamento ou séries com novos episódios programados, eles aparecerão aqui.';

  @override
  String get howManyMoviesWatchedEachMonth =>
      'Quantos filmes você assistiu por mês?';

  @override
  String get howPersonalRatingsShifting =>
      'Como suas avaliações pessoais estão mudando ao longo do tempo';

  @override
  String get keepWatchingToBuildProfile =>
      'Continue assistindo para construir seu perfil visual.';

  @override
  String get lumiWatchAnalytics => 'ANÁLISE DE RELÓGIOS LUMI';

  @override
  String get noGenreDistributionYet =>
      'Ainda não há distribuição por gênero disponível.';

  @override
  String get noMovieWatchHistoryRecentMonths =>
      'Não há histórico de visualização de filmes nos últimos meses.';

  @override
  String get noRatingTrendDataYet =>
      'Ainda não há dados disponíveis sobre a tendência de avaliações.';

  @override
  String get preferredRuntime => 'Tempo de execução preferencial';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return 'O tempo de execução preferencial é de aproximadamente $minutes minutos ($label)';
  }

  @override
  String get styledCardWithWatchStats =>
      'Cartão estilizado com as estatísticas do seu relógio';

  @override
  String get titlesAnalyzed => 'Títulos analisados';

  @override
  String get tryAgainAfterMoment => 'Tente novamente daqui a pouco.';

  @override
  String get watchAnalytics => 'Análises do Watch';

  @override
  String get whatGenresDominateHistory =>
      'Quais gêneros predominam no seu histórico de visualizações?';

  @override
  String get toggleMovies => 'Filmes';

  @override
  String get toggleTv => 'TV';

  @override
  String get noMoreTitlesFound => 'Nenhum outro título encontrado.';

  @override
  String get noTitlesFoundForKeyword =>
      'Nenhum título encontrado para esta palavra-chave.';

  @override
  String get viewFull => 'Ver tudo';

  @override
  String get accoladeDetails => 'Detalhes da premiação';

  @override
  String get noDetailedAwardsInfo =>
      'Não há informações detalhadas disponíveis sobre os prêmios.';

  @override
  String get alertSet => 'Alerta ativado!';

  @override
  String get budget => 'Orçamento';

  @override
  String get buy => 'Comprar';

  @override
  String chooseBetweenHours(int maxHours) {
    return 'Escolha entre 1 e $maxHours';
  }

  @override
  String get deleteNoteConfirmationTitle => 'Apagar nota?';

  @override
  String get episodeReminder => 'Lembrete do episódio';

  @override
  String get facebook => 'Facebook';

  @override
  String get free => 'Livre';

  @override
  String get images => 'Imagens';

  @override
  String get instagram => 'Instagram';

  @override
  String get netProfit => 'Lucro líquido';

  @override
  String get noNotesYet => 'Ainda não há comentários. Adicione suas ideias!';

  @override
  String get originalLanguage => 'Língua original';

  @override
  String partOfCollection(String collectionName) {
    return 'Parte do $collectionName';
  }

  @override
  String get roi => 'ROI';

  @override
  String releaseAlertSet(String date) {
    return 'Alerta de liberação do relógio configurado para $date.';
  }

  @override
  String get rent => 'Aluguel';

  @override
  String get revenue => 'Receita';

  @override
  String seeAllReviews(int count) {
    return 'Ver tudo ($count)';
  }

  @override
  String get setReminder => 'Definir lembrete';

  @override
  String get status => 'Status';

  @override
  String get stream => 'Fluxo';

  @override
  String get tikTok => 'TikTok';

  @override
  String get twitterX => 'X';

  @override
  String get yours => 'SEU';

  @override
  String get youtube => 'YouTube';

  @override
  String get durationDays => 'Traduza este rótulo do aplicativo para pt: d';

  @override
  String get durationHours => 'Traduza este rótulo do aplicativo para pt: h';

  @override
  String get durationMinutes => 'Traduza este rótulo do aplicativo para pt: m';

  @override
  String get durationSeconds => 'Traduza este rótulo do aplicativo para pt: s';

  @override
  String seasonRating(String score) {
    return 'Traduza este rótulo do aplicativo para pt: ★ $score%';
  }

  @override
  String get we => 'Nós';

  @override
  String get aspect16x9 => 'Traduza este rótulo do aplicativo para pt: 16:9';

  @override
  String get aspect9x16 => 'Traduza este rótulo do aplicativo para pt: 9:16';

  @override
  String get background => 'Traduza este rótulo do aplicativo para pt: Bg';

  @override
  String episodeCount(int count) {
    return 'Traduza este rótulo do aplicativo para pt: $count Eps';
  }

  @override
  String get noEpisodesForSeason =>
      'Nenhum episódio encontrado para esta temporada.';

  @override
  String get beautifulStyledCardForStories =>
      'Cartão com design elegante para stories nas redes sociais';

  @override
  String get clickableShareLink =>
      'Link clicável para compartilhar no WhatsApp e em outros aplicativos.';

  @override
  String get placeQuoteOnBackdrop =>
      'Coloque sua citação favorita em um cenário de filme.';

  @override
  String get standardLinkToMovieDatabase =>
      'Link padrão para o banco de dados de filmes';

  @override
  String get exploreLabel => 'Explorar';

  @override
  String quoteCharacter(String character) {
    return 'Traduza este rótulo do aplicativo para pt: — $character';
  }

  @override
  String get aiTonightWatch => 'Assista ao AI Tonight';

  @override
  String get aiQueryPlan => 'plano de consulta de IA';

  @override
  String get airingToday => 'Exibido hoje';

  @override
  String get bigCrowdPleasers =>
      'Grandes sucessos de público com forte impulso.';

  @override
  String get cinematic => 'Cinematográfico';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get currentTheatricalSlate =>
      'Programação atual de filmes em cartaz e lançamentos futuros próximos.';

  @override
  String get dark => 'Escuro';

  @override
  String get discoverSpotlight => 'Descubra o Spotlight';

  @override
  String get edgeOfYourSeat => 'De tirar o fôlego';

  @override
  String get fastPaced => 'ritmo acelerado';

  @override
  String get feelGood => 'Sensação de bem-estar';

  @override
  String get freshPicksContinuous => 'Novidades atualizadas continuamente';

  @override
  String get hideTitle => 'Ocultar título';

  @override
  String get highRatedSkipped =>
      'Títulos bem avaliados que a maioria dos espectadores pula';

  @override
  String get hotNowAudience => 'Agora em alta em todo o feed do público';

  @override
  String get inTheaters => 'Nos cinemas';

  @override
  String get indie => 'Traduza este rótulo de aplicativo para pt: Indie';

  @override
  String get mindBending => 'Alucinante';

  @override
  String get mostDiscussedShowsThisWeek =>
      'Programas mais comentados desta semana';

  @override
  String get multiplePicks => 'Múltiplas escolhas';

  @override
  String get onTheAir => 'No ar';

  @override
  String get personalizedFromWatchBehavior =>
      'Personalizado com base no seu comportamento de uso do relógio';

  @override
  String get pickAVibe =>
      'Escolha um estilo e obtenha títulos correspondentes instantaneamente.';

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get seriesCurrentlyAiring =>
      'Séries atualmente em exibição com episódios ativos';

  @override
  String get thisWeek => 'Essa semana';

  @override
  String get topRated => 'Mais bem avaliado';

  @override
  String get voiceInput => 'Entrada de voz';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% de correspondência';
  }

  @override
  String runtimeMinutes(String minutes) {
    return 'Traduza este rótulo do aplicativo para pt: $minutes min';
  }

  @override
  String get examplePrompt =>
      'Exemplo: Algo como Interestelar, mas não ficção científica.';

  @override
  String findingYourPerfectWatch(String dots) {
    return 'Encontrando o relógio perfeito$dots';
  }

  @override
  String get moreLikeThis => 'Mais como isto';

  @override
  String get notForMe => 'Não é para mim.';

  @override
  String get recentQueries => 'Consultas recentes';

  @override
  String get shufflingIdeas => 'Embaralhando ideias...';

  @override
  String get tooMainstream => 'Muito convencional';

  @override
  String get whatShouldIWatchTonight => 'O que devo assistir hoje à noite?';

  @override
  String debugLogEntry(String time, String message) {
    return 'Traduza este rótulo do aplicativo para pt: [$time] $message';
  }

  @override
  String get from => 'De';

  @override
  String get to => 'Para';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return 'Removido da lista de observação ($seconds s)';
  }

  @override
  String creditsCount(String count) {
    return 'Créditos $count';
  }

  @override
  String get acrossFilmography => 'Ao longo da filmografia';

  @override
  String get birthplace => 'Local de nascimento';

  @override
  String get born => 'Nascer';

  @override
  String get credits => 'Créditos';

  @override
  String get died => 'Morreu';

  @override
  String get knownFor => 'Conhecido por';

  @override
  String get noSharedTitlesAvailable =>
      'Não há títulos compartilhados disponíveis.';

  @override
  String get photos => 'Fotos';

  @override
  String get personRating => 'Avaliação';

  @override
  String get taggedImages => 'Imagens marcadas';

  @override
  String get website => 'Site';

  @override
  String get noQuotesFound => 'Nenhuma citação encontrada.';

  @override
  String get noSectionsFound => 'Nenhuma seção encontrada.';

  @override
  String get clearAll => 'Limpar tudo';

  @override
  String get noCollectionsFound => 'Nenhuma coleção encontrada';

  @override
  String get noCompaniesFound => 'Nenhuma empresa encontrada';

  @override
  String get noKeywordsFound => 'Nenhuma palavra-chave encontrada';

  @override
  String get noMoreResultsFound => 'Nenhum outro resultado encontrado.';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado';

  @override
  String deleteListConfirmation(String listName) {
    return 'Tem certeza de que deseja excluir $listName?';
  }

  @override
  String get deleteListTitle => 'Excluir lista?';

  @override
  String get everythingYouPlanToWatch =>
      'Tudo o que você planeja assistir em seguida.';

  @override
  String get finishedTitlesAndHistory =>
      'Títulos concluídos, além do seu histórico e estatísticas.';

  @override
  String get noListsCreatedYet => 'Nenhuma lista foi criada ainda.';

  @override
  String get noNotesFound => 'Nenhuma nota encontrada';

  @override
  String get renameList => 'Lista de renomeação';

  @override
  String get titlesYouNeverWantToLose =>
      'Os títulos que você nunca quer perder.';

  @override
  String get yourThoughtsReactions => 'Seus pensamentos, reações e lembretes.';

  @override
  String imageCounter(String current, String total) {
    return 'Traduza este rótulo do aplicativo para pt: $current / $total';
  }

  @override
  String get removeFromWatchedConfirmation =>
      'Tem certeza de que deseja remover isso da sua lista de observados?';

  @override
  String get savedAsWatchedWithoutRating =>
      'Este vídeo será salvo como assistido, sem uma avaliação pessoal.';

  @override
  String get noAdditionalRecommendationTrailers =>
      'Não foram encontrados trailers de recomendação adicionais.';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return 'Traduza este rótulo do aplicativo para pt: $count $itemLabel';
  }

  @override
  String get invalidSharedListLink =>
      'O link pode ser inválido, expirado ou não estar mais acessível.';

  @override
  String get noTitlesAvailableToImport =>
      'Não há títulos disponíveis para importação.';

  @override
  String get allLanguages => 'Todos os idiomas';

  @override
  String get arabic => 'árabe';

  @override
  String get bengali => 'bengali';

  @override
  String get chinese => 'chinês';

  @override
  String get english => 'Inglês';

  @override
  String get french => 'Francês';

  @override
  String get german => 'Alemão';

  @override
  String get gujarati => 'Traduza este rótulo do aplicativo para pt: Gujarati';

  @override
  String get hindi => 'hindi';

  @override
  String get indonesian => 'indonésio';

  @override
  String get italian => 'italiano';

  @override
  String get japanese => 'japonês';

  @override
  String get kannada => 'Traduza este rótulo do aplicativo para pt: Kannada';

  @override
  String get korean => 'coreano';

  @override
  String get malayalam =>
      'Traduza este rótulo do aplicativo para pt: Malayalam';

  @override
  String get marathi => 'Traduza este rótulo do aplicativo para pt: Marathi';

  @override
  String get persian => 'persa';

  @override
  String get polish => 'polonês';

  @override
  String get portuguese => 'Português';

  @override
  String get punjabi => 'Traduza este rótulo do aplicativo para pt: Punjabi';

  @override
  String get russian => 'russo';

  @override
  String get spanish => 'Espanhol';

  @override
  String get swedish => 'sueco';

  @override
  String get tamil => 'tâmil';

  @override
  String get telugu => 'Traduza este rótulo do aplicativo para pt: Telugu';

  @override
  String get thai => 'Tailandês';

  @override
  String get turkish => 'turco';

  @override
  String get urdu => 'urdu';

  @override
  String get vietnamese => 'vietnamita';

  @override
  String get failedToLoadCollectionDetails =>
      'Falha ao carregar os detalhes da coleção';

  @override
  String get franchiseProgress => 'Progresso da Franquia';

  @override
  String get officialSite => 'Site oficial';

  @override
  String get productions => 'Produções';

  @override
  String get productionCompany => 'Empresa de Produção';

  @override
  String get failedToLoadCompanyInfo =>
      'Não foi possível carregar as informações da empresa.';

  @override
  String get profile => 'Perfil';

  @override
  String get guestViewer => 'Espectador convidado';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      'Seu perfil, estado de sincronização, região e preferências visuais estão todos aqui.';

  @override
  String get signInToSync =>
      'Inicie sessão para sincronizar sua lista de favoritos, avaliações e preferências.';

  @override
  String get signedInAndSyncing =>
      'Login efetuado e sincronizando com a nuvem.';

  @override
  String get developedBy => 'Desenvolvido por';

  @override
  String get couldNotAnalyzeWatchHistory =>
      'Não foi possível analisar o histórico de visualizações neste momento.';

  @override
  String get includeLocalLibrary => 'Incluir a biblioteca local';

  @override
  String get useCloudOnly => 'Usar somente na nuvem';

  @override
  String get localLibrarySyncDescription =>
      'Este dispositivo já possui títulos da biblioteca local. Inclua-os na sua biblioteca em que iniciou sessão ou substitua os dados da biblioteca local pela sua biblioteca na nuvem.';

  @override
  String get mergedLocalTitles =>
      'Títulos locais mesclados à sua biblioteca após o login.';

  @override
  String get replacedLocalLibrary =>
      'Substituí os dados da biblioteca local pela sua biblioteca na nuvem.';

  @override
  String get deleteAccountConfirmation =>
      'Isso exclui permanentemente sua conta Lumi e os dados sincronizados na nuvem. Os dados locais neste dispositivo permanecerão, a menos que você remova os dados do aplicativo separadamente.';

  @override
  String get signedOutAndCleared =>
      'Saí da minha conta e limpei a biblioteca local neste dispositivo.';

  @override
  String get keepLocalLibrary => 'Mantenha a biblioteca local';

  @override
  String get clearLocalLibrary => 'Biblioteca Local Limpa';

  @override
  String get signOutChoiceDescription =>
      'Escolha se deseja manter a biblioteca local neste dispositivo após sair da sessão.';

  @override
  String get disable => 'Desativar';

  @override
  String get aiRecommendationsEnabled =>
      'Compartilhamento de dados de recomendações de IA ativado.';

  @override
  String get aiRecommendationsDisabled =>
      'Compartilhamento de dados de recomendações de IA desativado.';

  @override
  String get reviewAndManageConsent =>
      'Analisar e gerir o consentimento para o envio de dados da biblioteca a fornecedores de IA.';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      'Ativado. O recurso Recomendar Hoje à Noite pode enviar o resumo da sua biblioteca e as suas consultas recentes para fornecedores de IA.';

  @override
  String basedOnWatchedTitles(String count) {
    return 'Com base em $count títulos assistidos';
  }

  @override
  String lastUpdated(String date) {
    return 'Última atualização: $date';
  }

  @override
  String get chooseYourVibe => 'Escolha a sua vibe';

  @override
  String get appearanceDescription =>
      'Alterne entre personalidades cinematográficas no aplicativo sem alterar nenhum comportamento.';

  @override
  String get exitAppConfirmation => 'Tem certeza de que deseja sair do Lumi?';

  @override
  String get dismiss => 'Liberar';

  @override
  String get generatingWatchAnalytics => 'Geração de análises de relógios';

  @override
  String get thisUsuallyTakesAFewSeconds =>
      'Isso geralmente leva alguns segundos.';

  @override
  String get yourScreenStory => 'Sua história na tela';

  @override
  String get snapshotOfHowAndWhatYouWatch =>
      'Um resumo de como e o que você assiste';

  @override
  String get yourFavoriteGenres => 'Seus gêneros favoritos';

  @override
  String get genrePerformanceHighestRated =>
      'Desempenho no gênero (Melhor avaliado)';

  @override
  String get personalizedViewingPatterns =>
      'padrões de visualização personalizados';

  @override
  String get builtWithLumi => 'Construído com Lumi';

  @override
  String get sharedWithLumi => 'Compartilhado com Lumi';

  @override
  String get shareAnalytics => 'Compartilhar análises';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return 'Títulos analisados: $count • $date atualizado';
  }

  @override
  String get allSeasons => 'Todas as estações';

  @override
  String get castAndCrew => 'Elenco e equipe';

  @override
  String get featuredCrew => 'Equipe em destaque';

  @override
  String get stills => 'Fotos';

  @override
  String get accoladeSummary => 'Resumo dos Prêmios';

  @override
  String get awardsAndAccolades => 'Prêmios e Reconhecimentos';

  @override
  String get unableToLoadMovieDetails =>
      'Não foi possível carregar os detalhes do filme.';

  @override
  String get overviewUnavailable =>
      'Visão geral não disponível para este título.';

  @override
  String get openCompletePlot =>
      'Abra o gráfico completo e os metadados adicionais do OMDb.';

  @override
  String get noOverviewForSeason =>
      'Não há resumo disponível para esta temporada.';

  @override
  String get userScore => 'Pontuação do usuário';

  @override
  String get playTrailer => 'Reproduzir trailer';

  @override
  String get whereToWatch => 'Onde assistir';

  @override
  String get availabilityDataByJustWatch =>
      'Dados de disponibilidade fornecidos pela JustWatch.';

  @override
  String get reminderSaved => 'Lembrete salvo';

  @override
  String reminderForTitle(String title) {
    return 'Lembrete para $title';
  }

  @override
  String get pleaseSelectFutureTime =>
      'Por favor, selecione um horário futuro.';

  @override
  String get notifyAt => 'Notifique em';

  @override
  String get notifyHoursBeforeAiring =>
      'Com quantas horas de antecedência devo avisar antes da transmissão?';

  @override
  String enterNumberBetween(String maxHours) {
    return 'Digite um número entre 1 e $maxHours';
  }

  @override
  String get set => 'Definir';

  @override
  String get selectedReminderTimePassed =>
      'O tempo de lembrete selecionado já passou.';

  @override
  String episodeReminderSaved(String date) {
    return 'Lembrete de episódio salvo para $date';
  }

  @override
  String get areYouSureDeleteNote =>
      'Tem certeza de que deseja excluir esta nota?';

  @override
  String get noteAdded => 'Nota adicionada';

  @override
  String get lastSeason => 'Última temporada';

  @override
  String get currentSeason => 'Temporada atual';

  @override
  String get viewAllSeasons => 'Ver todas as temporadas';

  @override
  String get removedFromFavourites => 'Removido dos favoritos';

  @override
  String get addedToFavourites => 'Adicionado aos favoritos';

  @override
  String get awardsAndNominations => 'Prêmios e Indicações';

  @override
  String get viewAll => 'Ver tudo';

  @override
  String get boxOfficeFinancials => 'Dados financeiros da bilheteria';

  @override
  String get successMeter => 'Medidor de sucesso';

  @override
  String get blockbuster => 'SUCESSO DE BILHETERIA';

  @override
  String get hit => 'BATER';

  @override
  String get breakEven => 'EMPATAR';

  @override
  String get underperformer => 'DESEMPENHO INFERIOR';

  @override
  String get boxOfficeBomb => 'FRACASSO DE BILHETERIA';

  @override
  String get episodeTracker => 'Rastreador de Episódios';

  @override
  String get setAiringReminder => 'Defina o lembrete de exibição';

  @override
  String get nextEpisodeCountdown =>
      'Contagem regressiva para o próximo episódio';

  @override
  String get nextEpisode => 'Próximo episódio';

  @override
  String get lastEpisodeToAir => 'Último episódio a ser exibido';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get contentAdvisory => 'Aviso de conteúdo';

  @override
  String get violence => 'Violência';

  @override
  String get sexAndNudity => 'Sexo e nudez';

  @override
  String get foulLanguage => 'Linguagem';

  @override
  String get substances => 'Substâncias';

  @override
  String get fearAndHorror => 'Medo e Horror';

  @override
  String get familyFriendly => 'Ideal para famílias';

  @override
  String get generalAudience => 'Público em geral';

  @override
  String get releaseTimeline => 'Cronograma de lançamento';

  @override
  String get notifyMe => 'Avise-me';

  @override
  String get theatricalRelease => 'Lançamento nos cinemas';

  @override
  String get digitalStreaming =>
      'Traduza este rótulo do aplicativo para pt: Digital / Streaming';

  @override
  String get physicalRelease => 'Formato físico (Blu-ray / DVD)';

  @override
  String get awesome => 'Incrível';

  @override
  String get keywordsAndThemes => 'Palavras-chave e temas';

  @override
  String get videosAndBehindTheScenes => 'Vídeos e bastidores';

  @override
  String get productionStudios => 'Estúdios de Produção';

  @override
  String get fetchingWatchLink => 'Buscando link do relógio';

  @override
  String get findingBestProviderPage =>
      'Encontrando a melhor página de fornecedores para este título.';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode';
  }

  @override
  String get error => 'Erro';

  @override
  String get failedToLoadSeasonDetails =>
      'Não foi possível carregar os detalhes da temporada.';

  @override
  String get loading => 'Carregando...';

  @override
  String runtimeSeparator(String runtime) {
    return 'Traduza este rótulo do aplicativo para pt: • $runtime';
  }

  @override
  String get fullCastAndCrew => 'Elenco e equipe completos';

  @override
  String get shareMovie => 'Compartilhar Filme';

  @override
  String get quotes => 'Citações';

  @override
  String get mayIncludeMismatches =>
      'Pode incluir eventuais incompatibilidades devido à pesquisa por citação lexical.';

  @override
  String get movieApiConfigurationRequired =>
      'Configuração da API de filmes necessária';

  @override
  String get addMovieProxyBaseUrl =>
      'Adicione MOVIE_PROXY_BASE_URL para conectar o aplicativo ao proxy do TMDB.';

  @override
  String get cinematicPicksContext =>
      'Escolhas cinematográficas com contexto de atmosfera instantâneo. Role os dados para ver outra carta surpresa.';

  @override
  String get curatedTonight => 'Selecionado para hoje à noite';

  @override
  String curatedTonightTitle(String title) {
    return 'Selecionado para hoje: $title';
  }

  @override
  String get describeItYourWay =>
      'Descreva do seu jeito.\nNós encontramos as melhores opções.';

  @override
  String get hide => 'Esconder';

  @override
  String get hideTitleDescription =>
      'Ocultar este título impedirá que ele apareça na seção Destaques no futuro.';

  @override
  String get dontAskAgain => 'Não pergunte novamente.';

  @override
  String get imdbNa => 'Traduzir este rótulo do aplicativo para pt: IMDb NA';

  @override
  String get noDiscoverPicks =>
      'Nenhuma sugestão de descoberta disponível no momento.';

  @override
  String get playPreview => 'Reproduzir pré-visualização';

  @override
  String get recommendedForYou => 'Recomendado para você';

  @override
  String get spotlightCompleted => 'Destaque Concluído';

  @override
  String get startAddingTitlesForRecommendations =>
      'Comece a adicionar títulos para recomendações.';

  @override
  String get clearedAllChoices =>
      'Você deslizou e limpou todas as opções no seu feed Descobrir.';

  @override
  String get whatsPopular => 'O que é popular';

  @override
  String get trending => 'Tendências';

  @override
  String get trendingPeople => 'Personalidades em alta';

  @override
  String get starringTodayOrThisWeek => 'Estrelas em alta hoje ou esta semana';

  @override
  String get nowPlaying => 'Tocando agora';

  @override
  String get tvTrending => 'Tendências da TV';

  @override
  String get discoverByMood => 'Descubra pelo seu humor';

  @override
  String get needSomethingToWatchTonight =>
      'Procurando algo para assistir hoje à noite?';

  @override
  String get needAMovieForTonight => 'Procurando um filme para hoje à noite?';

  @override
  String get tryAiShows => 'Experimente programas de IA';

  @override
  String get tryAiMovies => 'Experimente o AI Movies';

  @override
  String get findShows => 'Encontre programas';

  @override
  String get findMovies => 'Encontre filmes';

  @override
  String get couldNotLoadThisRail => 'Não foi possível carregar este trilho.';

  @override
  String get temporaryIssueLoadingRail =>
      'Houve um problema temporário no carregamento deste trilho.';

  @override
  String get noTitlesHereYet => 'Ainda não há títulos aqui.';

  @override
  String get noHiddenGemsForGenre =>
      'Ainda não encontramos nenhuma joia escondida neste gênero. Tente outro gênero.';

  @override
  String get tryAnotherFilter =>
      'Experimente outro filtro ou abra esta seção para uma descoberta mais ampla.';

  @override
  String get seeAllFilters => 'Ver todos os filtros';

  @override
  String get couldNotLoadCuratedPicks =>
      'Não foi possível carregar as seleções escolhidas.';

  @override
  String get temporaryIssueLoadingCurated =>
      'Houve um problema temporário ao carregar a lista selecionada de hoje à noite.';

  @override
  String get noCuratedPicksAvailable => 'Nenhuma seleção disponível';

  @override
  String get tryAgainWhileRefresh =>
      'Tente novamente em instantes enquanto atualizamos a lista do TMDB de hoje.';

  @override
  String get fromSpotlight => 'Em destaque';

  @override
  String get addShowsMoviesForRecommendations =>
      'Adicione séries/filmes à sua lista de favoritos, à sua lista de favoritos ou à sua lista de assistidos para ver títulos que você pode gostar.';

  @override
  String get allow => 'Permitir';

  @override
  String get notNow => 'Agora não';

  @override
  String get allowAiDataSharingTitle =>
      'Permitir o compartilhamento de dados de IA?';

  @override
  String get allowAiDataSharingDescription =>
      'O Recommend Tonight envia o texto que você digita para solicitar uma recomendação de filme e um contexto temporário de refinamento da consulta para o Google Gemini e o OpenRouter. Sua biblioteca completa e suas credenciais de login não são enviadas para esses provedores de IA. Você permite esse compartilhamento de dados para recomendações de IA?';

  @override
  String get liveProgress => 'Progresso ao vivo';

  @override
  String percentComplete(String percent) {
    return '$percent% concluído';
  }

  @override
  String get describeIdealShowNight =>
      'Descreva a sua noite de espetáculo ideal.';

  @override
  String get describeIdealMovieNight => 'Descreva a sua noite de cinema ideal.';

  @override
  String get useNaturalLanguage =>
      'Use linguagem natural. Mencione o que deseja, o que deve evitar e dicas opcionais de idioma/tempo de execução.';

  @override
  String get listeningTapMicToStop =>
      'Ouvindo... toque no microfone novamente para parar.';

  @override
  String voiceInputError(String error) {
    return 'Erro de entrada de voz: $error';
  }

  @override
  String get tapMicToDictate =>
      'Toque no microfone para ditar sua solicitação.';

  @override
  String get tapMicToEnableVoice =>
      'Toque no microfone para ativar a entrada de voz.';

  @override
  String get findingShows => 'Encontrando programas...';

  @override
  String get findingMovies => 'Encontrando filmes...';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return 'As escolhas da Lumi para hoje à noite são: $prompt';
  }

  @override
  String get tonightsPicks => 'Palpites de hoje à noite';

  @override
  String get sharedFromLumi => 'Compartilhado de Lumi';

  @override
  String get intent => 'Intenção:';

  @override
  String get genreLabel => 'Gênero:';

  @override
  String get avoid => 'Evitar:';

  @override
  String get languageLabel => 'Linguagem:';

  @override
  String runtimeAtMost(String minutes) {
    return 'Tempo de execução <= $minutes min';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return 'Tempo de execução >= $minutes min';
  }

  @override
  String get yearLabel => 'Ano:';

  @override
  String yearAfter(String year) {
    return 'Após $year';
  }

  @override
  String yearBefore(String year) {
    return 'Antes de $year';
  }

  @override
  String get like => 'Como:';

  @override
  String get signal => 'Sinal:';

  @override
  String get readingWatchedHistory => 'Lendo seu histórico de visualizações...';

  @override
  String get findingTopGenres => 'Descubra seus gêneros e padrões favoritos...';

  @override
  String get buildingTrends =>
      'Construindo tendências mensais e de classificação...';

  @override
  String get writingInsights => 'Escreva suas ideias personalizadas...';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get includeNotRated => 'Incluir Não Avaliado';

  @override
  String get errorLoadingTvGenres => 'Erro ao carregar gêneros de TV';

  @override
  String get alsoKnownAs => 'Também conhecido como';

  @override
  String get biography => 'Biografia';

  @override
  String get careerStatistics => 'Estatísticas de carreira';

  @override
  String get frequentlyCollaboratesWith => 'Colabora frequentemente com';

  @override
  String get notableQuotes => 'Citações Notáveis';

  @override
  String get primaryRole => 'Função principal';

  @override
  String get averageRating => 'Classificação média';

  @override
  String get topGenre => 'Gênero principal';

  @override
  String get peakBoxOffice => 'Bilheteria de pico';

  @override
  String percentOfTitles(String percent) {
    return '$percent% dos títulos';
  }

  @override
  String sharedTitleCount(String count) {
    return '$count título(s) compartilhado(s)';
  }

  @override
  String billingOrder(String order) {
    return 'Faturado nº $order';
  }

  @override
  String get startTypingToSearch => 'Comece a digitar para pesquisar';

  @override
  String get movieDiscoveryMadePersonal =>
      'Descoberta de filmes, tornada pessoal';

  @override
  String get allNotes => 'Todas as notas';

  @override
  String get viewPersonalizedInsights =>
      'Veja informações, gráficos e tendências personalizados.';

  @override
  String get curatedCollections => 'Coleções selecionadas';

  @override
  String get list => 'lista';

  @override
  String get openList => 'Lista aberta';

  @override
  String get thisListNoLongerExists => 'Esta lista já não existe.';

  @override
  String listRenamed(String name) {
    return 'Lista renomeada para $name';
  }

  @override
  String listDeleted(String name) {
    return 'Lista $name excluída';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return 'Não há nenhum $filter na sua lista de observação.';
  }

  @override
  String noFilterInFavourites(String filter) {
    return 'Não há $filter nos seus favoritos';
  }

  @override
  String noFilterInWatched(String filter) {
    return 'Nenhum $filter foi assistido';
  }

  @override
  String noFilterInThisList(String filter) {
    return 'Não há nenhum $filter nesta lista';
  }

  @override
  String noListsWithFilter(String filter) {
    return 'Nenhuma lista com $filter';
  }

  @override
  String importedInto(String name) {
    return 'Importado para \"$name\"';
  }

  @override
  String get couldNotImportList => 'Não foi possível importar a lista.';

  @override
  String get importing => 'Importando...';

  @override
  String get couldNotLoadSharedList =>
      'Não foi possível carregar esta lista compartilhada.';

  @override
  String get editWatchedInfo => 'Editar Informações assistidas';

  @override
  String get watchDate => 'Data de visualização';

  @override
  String get rewatchCount => 'Contagem de reprises';

  @override
  String get watchedInfoUpdated => 'Informações assistidas atualizadas';

  @override
  String removedFromList(String listName) {
    return 'Removido de $listName';
  }

  @override
  String addedToList(String listName) {
    return 'Adicionado a $listName';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return 'Adicionado a $listName e à Lista de Observação';
  }

  @override
  String get moreTrailersLikeThis => 'Mais trailers como este';

  @override
  String get noDescriptionForTrailer =>
      'Não há descrição disponível para este trailer.';

  @override
  String get closeTrailer => 'Fechar trailer';

  @override
  String get recommendedSeries => 'Séries recomendadas';

  @override
  String get recommendedMovie => 'Filme recomendado';

  @override
  String get notEnoughDataYet => 'Ainda não há dados suficientes.';

  @override
  String addAndRateMoreTitles(String count) {
    return 'Adicione e avalie pelo menos $count títulos para desbloquear as análises.';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return 'Você assistiu a $watchedCount/$requiredCount títulos. Adicione mais $remaining para desbloquear as análises.';
  }

  @override
  String get moviesPerMonth => 'Filmes por mês';

  @override
  String get genreDistribution => 'Distribuição por gênero';

  @override
  String get ratingTrends => 'Tendências de classificação';

  @override
  String get noData => 'Sem dados';

  @override
  String get myLatestWatchAnalytics =>
      'Minha análise mais recente do relógio Lumi';

  @override
  String get myWatchInsights => 'Minhas impressões sobre o Lumi';

  @override
  String get infographicsCard => 'Cartão de infográfico';

  @override
  String get watchInsightsSnapshot => 'Resumo de informações do Watch Insights';

  @override
  String get availableOnceInsightsReady =>
      'Disponível assim que as informações estiverem prontas.';

  @override
  String get shareYourWatchInsights =>
      'Compartilhe suas impressões sobre relógios (cartão)';

  @override
  String get recentlyWatchedVibe => 'Vibe assistido recentemente';

  @override
  String get mixedAcrossGenres => 'Mistura de gêneros';

  @override
  String get moviesPerMonthShort => 'Filmes por mês';

  @override
  String get ratingTrend => 'Tendência de classificação';

  @override
  String get balanced => 'Equilibrado';

  @override
  String get noWatchNextSuggestionsYet =>
      'Ainda não há sugestões para assistir a seguir.';

  @override
  String get upcomingFromLibrary => 'Em breve, da sua biblioteca';

  @override
  String get removeReminder => 'Remover lembrete';

  @override
  String get remindMe => 'Lembre-me';

  @override
  String titleReleasesToday(String title) {
    return '$title será lançado hoje.';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle vai ao ar em breve.';
  }

  @override
  String get controlPremiereAlerts =>
      'Controle alertas de estreia e lembretes de lançamento.';

  @override
  String upcomingReleasesCount(String count) {
    return '$count próximos lançamentos em sua biblioteca.';
  }

  @override
  String sittingInWatchlist(String days) {
    return 'Na sua lista de observação há $days dias';
  }

  @override
  String get alreadyOnWatchlist => 'Já está na sua lista de observação';

  @override
  String get favouritedButNotWatched =>
      'Você adicionou este post aos seus favoritos, mas ainda não o marcou como assistido.';

  @override
  String get savedInListReady =>
      'Salvo em uma de suas listas e pronto para assistir.';

  @override
  String get matchesTitlesYouTrack =>
      'Títulos de partidas que você já acompanha';

  @override
  String get noOfficialSite => 'Não há site oficial.';

  @override
  String get episodeAiring => 'Exibição do episódio';

  @override
  String get general => 'Em geral';

  @override
  String scheduledFor(String date) {
    return 'Programado para $date';
  }

  @override
  String wasScheduledFor(String date) {
    return 'Estava agendado para $date';
  }

  @override
  String get noOverviewAvailable => 'Nenhuma visão geral disponível.';

  @override
  String get searchHistoryCleared => 'Histórico de pesquisa apagado';

  @override
  String get visualMovieCard => 'Cartão de filme visual';

  @override
  String get smartLumiLink =>
      'Traduza este rótulo do aplicativo para pt: Smart Lumi Link';

  @override
  String get directTmdbLink => 'Link direto para o TMDB';

  @override
  String recommendedOnLumi(String title) {
    return 'Recomendado no Lumi: $title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return 'Confira o $title no Lumi!\n\n$link\n\nObtenha o Lumi: $appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return 'Confira $title no TMDB: $link';
  }

  @override
  String releaseAlertTitle(String title) {
    return 'Alerta de lançamento $title';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return 'Alerta de lançamento configurado para $date. Notificaremos você quando estiver disponível.';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return 'Avisaremos você assim que \"$title\" for lançado digitalmente ou em Blu-ray/DVD!';
  }

  @override
  String get episodeAlreadyDueToAir =>
      'Este episódio já está programado para ir ao ar.';

  @override
  String get reminderSetSuccessfully => 'Lembrete configurado com sucesso';

  @override
  String get speechRecognitionNotAvailable =>
      'O reconhecimento de voz não está disponível neste dispositivo.';

  @override
  String get describeShowMood =>
      'Descreva qual série você está com vontade de assistir e nós retornaremos uma lista com as séries em ordem de preferência.';

  @override
  String get describeMovieMood =>
      'Descreva o filme que você está com vontade de assistir e nós retornaremos uma lista com as opções em ordem de preferência.';

  @override
  String get aiLauncherDescription =>
      'Digite ou fale um pedido em linguagem natural. O Lumi cria um plano de IA, executa uma busca vetorial e retorna várias opções de séries/filmes.';

  @override
  String yearRange(String from, String to) {
    return 'Traduza este rótulo do aplicativo para pt: $from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return '$count lembrete(s) agendado(s).';
  }

  @override
  String regionAutoDetected(String region) {
    return 'Detecção automática: $region';
  }

  @override
  String regionSelected(String region) {
    return 'Selecionado: $region';
  }

  @override
  String get allLanguagesSubtitle => 'Todos os idiomas';

  @override
  String currentlySetToLanguage(String language) {
    return 'Atualmente configurado para $language';
  }

  @override
  String get availabilities => 'Disponibilidade';

  @override
  String get mood => 'Humor';

  @override
  String get people => 'Pessoas';

  @override
  String get ads => 'Anúncios';

  @override
  String get theatricalLimited => 'Edição Limitada para Cinemas';

  @override
  String get premier => 'Primeiro';

  @override
  String get mediaType => 'Tipo de mídia';

  @override
  String get couldNotLoadAnalytics => 'Não foi possível carregar as análises.';

  @override
  String get viewAllAwards => 'Ver tudo';

  @override
  String get win => 'Ganhar';

  @override
  String get wins => 'Vitórias';

  @override
  String get nomination => 'Nomeação';

  @override
  String get nominations => 'Indicações';

  @override
  String sharedBy(String name) {
    return 'Compartilhado por $name';
  }

  @override
  String titleCount(String count) {
    return '$count título(s)';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count títulos salvos em suas listas';
  }

  @override
  String get curatedCollectionsSubtitle =>
      'Coleções selecionadas que você pode organizar e compartilhar.';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return 'Importe \"$name\" para o Lumi ($count $itemLabel): $link';
  }

  @override
  String get notEnoughData => 'Dados insuficientes';

  @override
  String shareQuote(String title) {
    return 'Confira esta citação de \"$title\" no Lumi!';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Recomendado no Lumi: $title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      'Digite ou fale um pedido em linguagem natural. O Lumi cria um plano de IA, executa uma busca vetorial e retorna várias opções de programas.';

  @override
  String get aiLauncherDescriptionMovie =>
      'Digite ou fale um pedido em linguagem natural. O Lumi cria um plano de IA, executa uma busca vetorial e retorna várias opções de filmes.';

  @override
  String get warmingUpMovieSearch => 'Aquecendo sua busca por filmes';

  @override
  String get connectingToRecommendationEngine =>
      'Conectando-se ao mecanismo de recomendação';

  @override
  String get understandingYourTaste =>
      'Entender o que você está com vontade de fazer';

  @override
  String get buildingCustomSearch =>
      'Criando uma pesquisa personalizada a partir da sua solicitação.';

  @override
  String get tinyNetworkHiccup => 'Pequena falha na rede, tentando novamente';

  @override
  String get planLocked => 'Plano definido: gênero, estilo, idioma e duração.';

  @override
  String get scanningTmdb =>
      'Analisando o TMDB em busca de correspondências relevantes.';

  @override
  String get collectingDetails =>
      'Coletando pôsteres, avaliações e duração dos melhores jogos.';

  @override
  String shortlistingPicksCount(String current, String total) {
    return 'Selecionando os finalistas ($current/$total)';
  }

  @override
  String get shortlistingBestPicks => 'Selecionando as melhores opções';

  @override
  String get finalPolish => 'Últimos retoques nas suas recomendações.';

  @override
  String get retryingAfterIssue =>
      'Tentando novamente após um problema temporário';

  @override
  String get regionUnitedStates => 'Estados Unidos';

  @override
  String get regionIndia => 'Índia';

  @override
  String get regionUnitedKingdom => 'Reino Unido';

  @override
  String get regionCanada => 'Canadá';

  @override
  String get regionAustralia => 'Austrália';

  @override
  String get regionNewZealand => 'Nova Zelândia';

  @override
  String get regionGermany => 'Alemanha';

  @override
  String get regionFrance => 'França';

  @override
  String get regionSpain => 'Espanha';

  @override
  String get regionItaly => 'Itália';

  @override
  String get regionJapan => 'Japão';

  @override
  String get regionSouthKorea => 'Coréia do Sul';

  @override
  String get regionBrazil => 'Brasil';

  @override
  String get regionMexico => 'México';

  @override
  String get regionSingapore => 'Cingapura';

  @override
  String get regionPhilippines => 'Filipinas';

  @override
  String get regionIndonesia => 'Indonésia';

  @override
  String get regionUnitedArabEmirates => 'Emirados Árabes Unidos';

  @override
  String get regionSaudiArabia => 'Arábia Saudita';

  @override
  String get regionTurkey => 'Peru';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return 'Região detectada automaticamente: $regionLabel ($regionCode). Selecione uma região para substituir nas consultas de filmes localizados e nas pesquisas de provedores de exibição.';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return 'Região selecionada: $regionLabel ($regionCode). As consultas de filmes e as pesquisas de provedores de exibição compatíveis reutilizarão isso automaticamente na próxima vez.';
  }

  @override
  String get syncSignInTooltip => 'Inicie sessão para sincronizar com a nuvem.';

  @override
  String get syncFailedTooltip =>
      'A sincronização falhou. Toque para tentar novamente.';

  @override
  String get syncedTooltip => 'Biblioteca sincronizada com a nuvem';

  @override
  String get shareQuoteTooltip => 'Compartilhar citação';

  @override
  String get copyQuoteTooltip => 'Copiar citação';

  @override
  String get quoteCopiedToast => 'Citação copiada para a área de transferência';

  @override
  String get shareDialogueTooltip => 'Compartilhar diálogo';

  @override
  String get copyDialogueTooltip => 'Copiar diálogo';

  @override
  String get dialogueCopiedToast =>
      'Diálogo copiado para a área de transferência';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$title vai ao ar em 1 hora';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel \"$episodeName\" vai ao ar em $localAirTime.';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$title será lançado hoje';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return 'Um filme em sua biblioteca será lançado em $localDate.';
  }

  @override
  String get curatedNeoNoirNights => 'Noites Neo-noir';

  @override
  String get curatedPulsePoundingRush => 'Uma sensação de palpitação intensa';

  @override
  String get curatedFeelGoodEscape => 'Uma Escapada para se Sentir Bem';

  @override
  String get curatedMindBenders => 'Manipuladores da Mente';

  @override
  String get curatedEpicWorlds => 'Mundos Épicos';

  @override
  String get curatedHumanStories => 'Histórias Humanas';

  @override
  String get curatedDarkDetectiveFiles => 'Arquivos do Detetive Sombrio';

  @override
  String get curatedNeoNoirNightsDescription =>
      'Tensão sob chuva torrencial, protagonistas moralmente ambíguos e histórias urbanas com atmosfera envolvente.';

  @override
  String get curatedPulsePoundingRushDescription =>
      'Perseguições de alto risco, perigo crescente e ritmo frenético, sem tempo para respirar.';

  @override
  String get curatedFeelGoodEscapeDescription =>
      'Histórias comoventes, tramas inspiradoras e sugestões reconfortantes para uma noite relaxante.';

  @override
  String get curatedMindBendersDescription =>
      'Conceitos que distorcem a realidade, tramas cheias de reviravoltas e narrativas com grandes ideias.';

  @override
  String get curatedEpicWorldsDescription =>
      'Aventuras em um universo vasto, apostas míticas e escala cinematográfica.';

  @override
  String get curatedHumanStoriesDescription =>
      'Dramas focados nos personagens, com forte apelo emocional e atuações memoráveis.';

  @override
  String get curatedDarkDetectiveFilesDescription =>
      'Pistas frias, suspeitos complexos e investigações de ritmo lento.';

  @override
  String get appLanguage => 'Idioma do aplicativo';

  @override
  String get appLanguageSystemDefault => 'Padrão do sistema';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return 'O idioma do aplicativo foi definido como $language. Isso altera apenas a interface do aplicativo, não o idioma dos filmes e programas.';
  }

  @override
  String get appLanguageSystemSubtitle =>
      'O idioma do aplicativo segue as configurações do seu dispositivo. Altere-o para manter a interface em um idioma diferente.';

  @override
  String get contentLanguageAllSubtitle =>
      'Todos os idiomas. As abas Filmes e TV permanecem amplas, enquanto a aba Explorar ainda pode priorizar resultados locais mais relevantes, quando disponíveis.';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return 'Atualmente configurado para $language. As abas Filmes e TV permanecerão restritas, enquanto a aba Explorar dará preferência a este idioma.';
  }
}
