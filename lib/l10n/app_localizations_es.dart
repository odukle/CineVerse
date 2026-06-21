// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Lumi';

  @override
  String get navExplore => 'Explorar';

  @override
  String get navMovies => 'Películas';

  @override
  String get navTvShows => 'Programas de TV';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navAccount => 'Cuenta';

  @override
  String get searchHint => 'Buscar películas, programas de TV, empresas...';

  @override
  String get searchForPerson => 'Buscar una persona...';

  @override
  String get searchLanguages => 'Buscar idiomas';

  @override
  String get searchNameOrRole => 'Buscar nombre o rol...';

  @override
  String get retry => 'Reintentar';

  @override
  String get tryAgain => 'Intentar nuevamente';

  @override
  String get clear => 'Borrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'Aceptar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get share => 'Compartir';

  @override
  String get undo => 'Deshacer';

  @override
  String get close => 'Cerrar';

  @override
  String get apply => 'Aplicar';

  @override
  String get reset => 'Restablecer';

  @override
  String get done => 'Listo';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signInWithApple => 'Iniciar sesión con Apple';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get accountDeletedSuccessfully =>
      'La cuenta se eliminó correctamente.';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceSubtitle =>
      'Elige tu tema y personaliza la apariencia de la aplicación.';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get releaseCalendar => 'Calendario de lanzamiento';

  @override
  String get hiddenTitles => 'Títulos ocultos';

  @override
  String get aiRecommendationsPrivacy => 'Recomendaciones de IA Privacidad';

  @override
  String get contentRegion => 'Región del contenido';

  @override
  String get contentLanguage => 'Idioma del contenido';

  @override
  String get watchlist => 'Lista de seguimiento';

  @override
  String get notes => 'Notas';

  @override
  String get deleteNote => 'Eliminar nota';

  @override
  String get addNoteHint => 'Agregar una nota...';

  @override
  String get addBriefNoteHint => 'Añade una breve nota (opcional)...';

  @override
  String get enterNewName => 'Introduce un nuevo nombre...';

  @override
  String get importSharedList => 'Importar lista compartida';

  @override
  String get discoverOnLumi => 'DESCUBRE EN LUMI';

  @override
  String get filtered => 'Filtrado';

  @override
  String get fullPlot => 'Trama completa';

  @override
  String get userReviews => 'Reseñas de usuarios';

  @override
  String get noReviewsYet => 'Aún no hay reseñas.';

  @override
  String get openInYouTube => 'Abrir en YouTube';

  @override
  String get hiddenGems => 'Gemas ocultas';

  @override
  String get resetSpotlight => 'Restablecer Spotlight';

  @override
  String get clearPreferences => 'Borrar preferencias';

  @override
  String get refreshPicks => 'Actualizar selecciones';

  @override
  String get shareBoard => 'Compartir tablero';

  @override
  String get exploreDetails => 'Explorar detalles';

  @override
  String get searchWikiquotes => 'Buscar Wikiquotes';

  @override
  String get selectAQuote => 'Seleccionar una cita';

  @override
  String get tooltipShareQuote => 'Compartir cita';

  @override
  String get tooltipCopyQuote => 'Copiar cita';

  @override
  String get tooltipShareDialogue => 'Compartir diálogo';

  @override
  String get tooltipCopyDialogue => 'Copiar diálogo';

  @override
  String get tooltipUnhide => 'Mostrar';

  @override
  String get tooltipOpenPrivacyPolicy => 'Abrir política de privacidad';

  @override
  String get tooltipRefreshInsights => 'Actualizar información';

  @override
  String get tooltipSortTitles => 'Ordenar títulos';

  @override
  String get tooltipSearch => 'Buscar';

  @override
  String get tooltipFilters => 'Filtros';

  @override
  String get tooltipSaveToGallery => 'Guardar en galería';

  @override
  String get tooltipShare => 'Compartir';

  @override
  String get tooltipShareAnalytics => 'Compartir análisis';

  @override
  String get tooltipSetAiringReminder =>
      'Configurar recordatorio de transmisión';

  @override
  String get tooltipLibrarySynced => 'Biblioteca sincronizada con la nube';

  @override
  String get noMoreEntries => 'No hay más entradas';

  @override
  String get noItemsFound => 'No se encontraron artículos';

  @override
  String errorLoadingGenres(String error) {
    return 'Error al cargar géneros: $error';
  }

  @override
  String errorGeneric(String error) {
    return 'Traduzca esta etiqueta de la aplicación a es: Error: $error';
  }

  @override
  String get errorLoadingLists => 'Error al cargar listas';

  @override
  String errorLoadingQuotes(Object error) {
    return 'No se pudieron cargar las citas: $error';
  }

  @override
  String get errorCouldNotShareAnalytics => 'compartir tarjeta de análisis.';

  @override
  String get errorCouldNotShareRecommendations =>
      'No se pudo compartir el tablero de recomendaciones.';

  @override
  String get errorCouldNotShareInsights =>
      'No se pudo compartir la información del reloj.';

  @override
  String get watchInsightsNotReady =>
      'Las estadísticas del reloj aún no están listas.';

  @override
  String titleRestoredToSpotlight(String title) {
    return '\"$title\" restaurado en Spotlight';
  }

  @override
  String titleHasBeenHidden(String title) {
    return '\"$title\" ha sido oculto';
  }

  @override
  String hiddenDate(String date) {
    return 'Oculto: $date';
  }

  @override
  String get moviesInThisCollection => 'Películas en esta colección';

  @override
  String get searchPlanReady => 'El plan de búsqueda está listo';

  @override
  String get hoursBeforeAirTime => 'Horas antes del horario de emisión';

  @override
  String get noUpcomingReleases => 'No hay próximos estrenos';

  @override
  String get noRemindersSet => 'No hay recordatorios configurados';

  @override
  String get noHiddenTitles => 'No hay títulos ocultos';

  @override
  String get hiddenTitlesDescription =>
      'Los títulos que ocultes de la sección Destacados aparecerán aquí, y podrás restaurarlos en cualquier momento.';

  @override
  String get tvShow => 'PROGRAMA DE TELEVISIÓN';

  @override
  String get movie => 'PELÍCULA';

  @override
  String get aiConsentGranted =>
      'Ha optado por participar. Los datos de su biblioteca se utilizan para personalizar las recomendaciones.';

  @override
  String get aiConsentNotGranted =>
      'Los datos de tu biblioteca nunca se comparten a menos que tú lo aceptes.';

  @override
  String get languageSettingExplanation =>
      'Las pestañas de Películas y TV usan esto estrictamente. Explore lo prefiere primero y retrocede cuando un riel se vuelve escaso.';

  @override
  String get filterScreenTitle => 'Filtros';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get genres => 'Géneros';

  @override
  String get year => 'Año';

  @override
  String get rating => 'Clasificación';

  @override
  String get runtime => 'Tiempo de ejecución';

  @override
  String get withPeople => 'Con personas';

  @override
  String get voteCount => 'Recuento de votos';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get yesterday => 'Ayer';

  @override
  String get minutes => 'Traduce esta etiqueta de aplicación a es: min';

  @override
  String get hours => 'Traduzca esta etiqueta de aplicación a es: h';

  @override
  String get cast => 'Elenco';

  @override
  String get crew => 'Equipo';

  @override
  String get director => 'F@ Elenco @G@ Equipo @H@ Director';

  @override
  String get seasons => 'Temporadas';

  @override
  String get episodes => 'Episodios';

  @override
  String get overview => 'Descripción general';

  @override
  String get similar => 'Traduce esta etiqueta de aplicación a es: Similar';

  @override
  String get recommendations => 'Recomendaciones';

  @override
  String get addedToWatchlist => 'Agregado a la lista de seguimiento';

  @override
  String get removedFromWatchlist => 'Eliminado de la lista de seguimiento';

  @override
  String get popularity => 'Popularidad';

  @override
  String get releaseDate => 'Fecha de lanzamiento';

  @override
  String get revenueLabel => 'Ingresos';

  @override
  String get originalTitle => 'Título original';

  @override
  String get voteAverage => 'Promedio de votos';

  @override
  String get favourites => 'Favoritos';

  @override
  String get lists => 'liza';

  @override
  String get watched => 'Observó';

  @override
  String get all => 'Todo';

  @override
  String get tv => 'TELEVISOR';

  @override
  String get librarySubtitle =>
      'Mantén todo organizado por colección, favoritos, notas e historial de uso.';

  @override
  String get selectRegion => 'Seleccione una región';

  @override
  String get selectRegionDescription =>
      'Solo los puntos de acceso de TMDb que admitan consultas con reconocimiento de región utilizarán esta opción.';

  @override
  String get useAutoDetectedRegion =>
      'Utilizar región detectada automáticamente';

  @override
  String get reminderRemoved => 'Recordatorio eliminado';

  @override
  String releaseReminderSet(String title) {
    return 'Recordatorio de liberación configurado para $title.';
  }

  @override
  String episodeReminderSet(String title) {
    return 'Recordatorio de episodio configurado para $title.';
  }

  @override
  String get filteredResults => 'Resultados filtrados';

  @override
  String get genreResults => 'Resultados por género';

  @override
  String couldNotLoadContent(String error) {
    return 'No se pudo cargar el contenido. $error';
  }

  @override
  String get noContentAvailableForThisSelection =>
      'No hay contenido disponible para esta selección.';

  @override
  String get writer => 'Escritor';

  @override
  String get actors => 'Actores';

  @override
  String get noteNotFound => 'Nota no encontrada.';

  @override
  String yourNotesCount(int count) {
    return 'Tus notas ($count)';
  }

  @override
  String get noteDeleted => 'Nota eliminada';

  @override
  String noteDeletedWithCount(int count) {
    return 'Nota eliminada ($count s)';
  }

  @override
  String get loadMore => 'Cargar más';

  @override
  String get noMoreProductionsFound => 'No se encontraron más producciones.';

  @override
  String get noProductionsFound => 'No se encontraron producciones.';

  @override
  String get watchInsights => 'Ver análisis';

  @override
  String get analyzingWatchHistory => 'Analizando tu historial de uso...';

  @override
  String get manageHiddenTitlesDescription =>
      'Gestiona los títulos que has ocultado de la sección Destacados.';

  @override
  String get tmdbLanguageMetadataNote =>
      'Es posible que algunos rieles se vean incompletos en este modo porque los metadatos de idioma de TMDB están incompletos para partes del catálogo, no necesariamente porque esos títulos no existan.';

  @override
  String get tmdbDisclaimer =>
      'Este producto utiliza la API de TMDB, pero no está avalado ni certificado por TMDB.';

  @override
  String get useLocalLibraryForSync =>
      '¿Utilizar la biblioteca local para la sincronización?';

  @override
  String get themePresets => 'Preajustes de temas';

  @override
  String get exitApp => 'Salir de la aplicación';

  @override
  String get popular => 'Traduce esta etiqueta de aplicación a es: Popular';

  @override
  String couldNotLoadReminders(String error) {
    return 'No se pudieron cargar los recordatorios.\n\n$error';
  }

  @override
  String get noRemindersSetYet =>
      'Aún no hay recordatorios configurados.\n\nCrea uno desde el Rastreador de episodios o los Detalles de la película.';

  @override
  String episodeSeasonEpisode(int seasonNumber, int episodeNumber) {
    return 'Episodio S$seasonNumber • E$episodeNumber';
  }

  @override
  String get movieRelease => 'Estreno de película';

  @override
  String voteAverageStars(String voteAverage) {
    return 'Traduce esta etiqueta de la aplicación a es: $voteAverage ★';
  }

  @override
  String get addMoreTrackedContent =>
      'Agrega más películas o series a tu lista de seguimiento, favoritos o listas.';

  @override
  String get fastPicksDescription =>
      'Selecciones rápidas basadas en lo que ya has guardado.';

  @override
  String get releaseCalendarDescription =>
      'Estrenos de películas y próximos episodios de series de televisión con recordatorios con un solo toque.';

  @override
  String get staleWatchlist => 'Lista de seguimiento obsoleta';

  @override
  String get tracked => 'Rastreado';

  @override
  String get upcoming => 'Próximamente';

  @override
  String get upcomingEmptyDescription =>
      'Cuando las películas que seguimos tengan fecha de estreno o las series tengan nuevos episodios programados, aparecerán aquí.';

  @override
  String get howManyMoviesWatchedEachMonth =>
      '¿Cuántas películas viste cada mes?';

  @override
  String get howPersonalRatingsShifting =>
      'Cómo cambian tus calificaciones personales con el tiempo';

  @override
  String get keepWatchingToBuildProfile =>
      'Sigue atento para construir tu perfil visual.';

  @override
  String get lumiWatchAnalytics => 'ANÁLISIS DE RELOJES LUMI';

  @override
  String get noGenreDistributionYet =>
      'Aún no hay información disponible sobre la distribución por género.';

  @override
  String get noMovieWatchHistoryRecentMonths =>
      'No hay historial de películas vistas en los últimos meses.';

  @override
  String get noRatingTrendDataYet =>
      'Aún no hay datos disponibles sobre la tendencia de las calificaciones.';

  @override
  String get preferredRuntime => 'Tiempo de ejecución preferido';

  @override
  String preferredRuntimeLabel(String minutes, String label) {
    return 'El tiempo de ejecución preferido es de aproximadamente $minutes minutos ($label)';
  }

  @override
  String get styledCardWithWatchStats =>
      'Tarjeta con estilo que muestra las estadísticas de tu reloj.';

  @override
  String get titlesAnalyzed => 'Títulos analizados';

  @override
  String get tryAgainAfterMoment => 'Inténtalo de nuevo después de un momento.';

  @override
  String get watchAnalytics => 'Análisis de relojes';

  @override
  String get whatGenresDominateHistory =>
      '¿Qué géneros predominan en tu historial de visualización?';

  @override
  String get toggleMovies => 'Cine';

  @override
  String get toggleTv => 'TELEVISOR';

  @override
  String get noMoreTitlesFound => 'No se encontraron más títulos.';

  @override
  String get noTitlesFoundForKeyword =>
      'No se encontraron títulos para esta palabra clave.';

  @override
  String get viewFull => 'Ver completo';

  @override
  String get accoladeDetails => 'Detalles del galardón';

  @override
  String get noDetailedAwardsInfo =>
      'No hay información detallada sobre los premios.';

  @override
  String get alertSet => '¡Alerta activada!';

  @override
  String get budget => 'Presupuesto';

  @override
  String get buy => 'Comprar';

  @override
  String chooseBetweenHours(int maxHours) {
    return 'Elige entre 1 y $maxHours';
  }

  @override
  String get deleteNoteConfirmationTitle => '¿Eliminar nota?';

  @override
  String get episodeReminder => 'Recordatorio del episodio';

  @override
  String get facebook => 'Facebook';

  @override
  String get free => 'Gratis';

  @override
  String get images => 'Imágenes';

  @override
  String get instagram => 'Instagram';

  @override
  String get netProfit => 'Beneficio neto';

  @override
  String get noNotesYet => 'Aún no hay comentarios. ¡Añade tu opinión!';

  @override
  String get originalLanguage => 'Idioma original';

  @override
  String partOfCollection(String collectionName) {
    return 'Parte del $collectionName';
  }

  @override
  String get roi => 'Retorno de la inversión';

  @override
  String releaseAlertSet(String date) {
    return 'Alerta de vigilancia de liberación configurada para $date.';
  }

  @override
  String get rent => 'Alquilar';

  @override
  String get revenue => 'Ganancia';

  @override
  String seeAllReviews(int count) {
    return 'Ver todo ($count)';
  }

  @override
  String get setReminder => 'Establecer recordatorio';

  @override
  String get status => 'Estado';

  @override
  String get stream => 'Arroyo';

  @override
  String get tikTok => 'TikTok';

  @override
  String get twitterX => 'incógnita';

  @override
  String get yours => 'TUYO';

  @override
  String get youtube => 'YouTube';

  @override
  String get durationDays => 'Traduzca esta etiqueta de aplicación a es: d';

  @override
  String get durationHours => 'Traduzca esta etiqueta de aplicación a es: h';

  @override
  String get durationMinutes => 'metro';

  @override
  String get durationSeconds => 'Traduzca esta etiqueta de aplicación a es: s';

  @override
  String seasonRating(String score) {
    return 'Traduzca esta etiqueta de la aplicación al español: ★ $score%';
  }

  @override
  String get we => 'Nosotros';

  @override
  String get aspect16x9 => 'Traduce esta etiqueta de la aplicación a es: 16:9';

  @override
  String get aspect9x16 => 'Traduce esta etiqueta de la aplicación a es: 9:16';

  @override
  String get background =>
      'Traduzca esta etiqueta de aplicación al español: Bg';

  @override
  String episodeCount(int count) {
    return 'Traduzca esta etiqueta de aplicación a es: $count Eps';
  }

  @override
  String get noEpisodesForSeason =>
      'No se encontraron episodios para esta temporada.';

  @override
  String get beautifulStyledCardForStories =>
      'Tarjeta con un diseño precioso para historias en redes sociales.';

  @override
  String get clickableShareLink =>
      'Enlace para compartir en WhatsApp y otras aplicaciones';

  @override
  String get placeQuoteOnBackdrop =>
      'Coloca tu cita favorita en un fondo de película.';

  @override
  String get standardLinkToMovieDatabase =>
      'Enlace estándar a la base de datos de películas';

  @override
  String get exploreLabel => 'Explorar';

  @override
  String quoteCharacter(String character) {
    return 'Traduzca esta etiqueta de la aplicación al español: — $character';
  }

  @override
  String get aiTonightWatch => 'Vigilancia de IA esta noche';

  @override
  String get aiQueryPlan => 'plan de consulta de IA';

  @override
  String get airingToday => 'Emitido hoy';

  @override
  String get bigCrowdPleasers =>
      'Grandes éxitos de público con un fuerte impulso.';

  @override
  String get cinematic => 'Cinematográfico';

  @override
  String get comingSoon => 'Muy pronto';

  @override
  String get currentTheatricalSlate =>
      'Estrenos cinematográficos actuales y próximos estrenos';

  @override
  String get dark => 'Oscuro';

  @override
  String get discoverSpotlight => 'Descubre Spotlight';

  @override
  String get edgeOfYourSeat => 'Al borde del asiento';

  @override
  String get fastPaced => 'De ritmo rápido';

  @override
  String get feelGood => 'Sentirse bien';

  @override
  String get freshPicksContinuous =>
      'Nuevas selecciones actualizadas continuamente';

  @override
  String get hideTitle => 'Ocultar título';

  @override
  String get highRatedSkipped =>
      'Títulos mejor valorados que la mayoría de los espectadores se saltan';

  @override
  String get hotNowAudience =>
      'Lo más popular ahora en todo el feed de la audiencia';

  @override
  String get inTheaters => 'En cines';

  @override
  String get indie => 'Traduce esta etiqueta de aplicación a es: Indie';

  @override
  String get mindBending => 'Alucinante';

  @override
  String get mostDiscussedShowsThisWeek =>
      'Los programas más comentados esta semana';

  @override
  String get multiplePicks => 'Varias selecciones';

  @override
  String get onTheAir => 'En el aire';

  @override
  String get personalizedFromWatchBehavior =>
      'Personalizado según el comportamiento de tu reloj.';

  @override
  String get pickAVibe =>
      'Elige un estilo y obtén títulos que coincidan al instante.';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get seriesCurrentlyAiring =>
      'Series que se emiten actualmente con episodios activos.';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get topRated => 'Mejor valorados';

  @override
  String get voiceInput => 'Entrada de voz';

  @override
  String matchPercent(String matchPct) {
    return '$matchPct% Coincidencia';
  }

  @override
  String runtimeMinutes(String minutes) {
    return 'Traduzca esta etiqueta de la aplicación a es: $minutes min';
  }

  @override
  String get examplePrompt =>
      'Ejemplo: Algo parecido a Interstellar, pero que no sea de ciencia ficción.';

  @override
  String findingYourPerfectWatch(String dots) {
    return 'Encuentra tu reloj perfecto$dots';
  }

  @override
  String get moreLikeThis => 'Más artículos como este';

  @override
  String get notForMe => 'No para mí';

  @override
  String get recentQueries => 'Consultas recientes';

  @override
  String get shufflingIdeas => 'Barajando ideas...';

  @override
  String get tooMainstream => 'Demasiado convencional';

  @override
  String get whatShouldIWatchTonight => '¿Qué debería ver esta noche?';

  @override
  String debugLogEntry(String time, String message) {
    return 'Traduzca esta etiqueta de la aplicación al español: [$time] $message';
  }

  @override
  String get from => 'De';

  @override
  String get to => 'A';

  @override
  String removedFromWatchlistCountdown(int seconds) {
    return 'Eliminado de la lista de seguimiento ($seconds s)';
  }

  @override
  String creditsCount(String count) {
    return 'Créditos $count';
  }

  @override
  String get acrossFilmography => 'A lo largo de la filmografía';

  @override
  String get birthplace => 'Lugar de nacimiento';

  @override
  String get born => 'Nacido';

  @override
  String get credits => 'Créditos';

  @override
  String get died => 'Fallecido';

  @override
  String get knownFor => 'Conocido por';

  @override
  String get noSharedTitlesAvailable =>
      'No hay títulos compartidos disponibles.';

  @override
  String get photos => 'Fotos';

  @override
  String get personRating => 'Clasificación';

  @override
  String get taggedImages => 'Imágenes etiquetadas';

  @override
  String get website => 'Sitio web';

  @override
  String get noQuotesFound => 'No se encontraron citas.';

  @override
  String get noSectionsFound => 'No se encontraron secciones.';

  @override
  String get clearAll => 'Borrar todo';

  @override
  String get noCollectionsFound => 'No se encontraron colecciones';

  @override
  String get noCompaniesFound => 'No se encontraron empresas';

  @override
  String get noKeywordsFound => 'No se encontraron palabras clave';

  @override
  String get noMoreResultsFound => 'No se encontraron más resultados.';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String deleteListConfirmation(String listName) {
    return '¿Estás seguro de que quieres eliminar $listName?';
  }

  @override
  String get deleteListTitle => '¿Eliminar lista?';

  @override
  String get everythingYouPlanToWatch =>
      'Todo lo que planeas ver a continuación.';

  @override
  String get finishedTitlesAndHistory =>
      'Títulos finalizados, además de tu historial y estadísticas.';

  @override
  String get noListsCreatedYet => 'Aún no se han creado listas.';

  @override
  String get noNotesFound => 'No se encontraron notas';

  @override
  String get renameList => 'Renombrar lista';

  @override
  String get titlesYouNeverWantToLose =>
      'Los títulos que nunca querrás perder.';

  @override
  String get yourThoughtsReactions =>
      'Tus pensamientos, reacciones y recordatorios.';

  @override
  String imageCounter(String current, String total) {
    return 'Traduzca esta etiqueta de la aplicación a es: $current / $total';
  }

  @override
  String get removeFromWatchedConfirmation =>
      '¿Estás seguro de que quieres eliminar esto de tu lista de seguimiento?';

  @override
  String get savedAsWatchedWithoutRating =>
      'Esto se guardará como visto sin una calificación personal.';

  @override
  String get noAdditionalRecommendationTrailers =>
      'No se encontraron tráileres de recomendación adicionales.';

  @override
  String sharedListItemsCount(int count, String itemLabel) {
    return 'Traduzca esta etiqueta de aplicación a es: $count $itemLabel';
  }

  @override
  String get invalidSharedListLink =>
      'Es posible que el enlace no sea válido, haya caducado o ya no esté disponible.';

  @override
  String get noTitlesAvailableToImport =>
      'No hay títulos disponibles para importar.';

  @override
  String get allLanguages => 'Todos los idiomas';

  @override
  String get arabic => 'árabe';

  @override
  String get bengali => 'bengalí';

  @override
  String get chinese => 'Chino';

  @override
  String get english => 'Inglés';

  @override
  String get french => 'Francés';

  @override
  String get german => 'Alemán';

  @override
  String get gujarati =>
      'Traduzca esta etiqueta de la aplicación al español: Gujarati';

  @override
  String get hindi => 'hindi';

  @override
  String get indonesian => 'indonesio';

  @override
  String get italian => 'italiano';

  @override
  String get japanese => 'japonés';

  @override
  String get kannada =>
      'Traduzca esta etiqueta de la aplicación al es: Kannada';

  @override
  String get korean => 'coreano';

  @override
  String get malayalam =>
      'Traduzca esta etiqueta de la aplicación al español: Malayalam';

  @override
  String get marathi =>
      'Traduzca esta etiqueta de la aplicación al español: Marathi';

  @override
  String get persian => 'persa';

  @override
  String get polish => 'Polaco';

  @override
  String get portuguese => 'portugués';

  @override
  String get punjabi => 'punjabi';

  @override
  String get russian => 'ruso';

  @override
  String get spanish => 'Español';

  @override
  String get swedish => 'sueco';

  @override
  String get tamil =>
      'Traduzca esta etiqueta de la aplicación al español: Tamil';

  @override
  String get telugu =>
      'Traduzca esta etiqueta de la aplicación al español: telugu';

  @override
  String get thai => 'tailandés';

  @override
  String get turkish => 'turco';

  @override
  String get urdu => 'Traduzca esta etiqueta de la aplicación al español: Urdu';

  @override
  String get vietnamese => 'vietnamita';

  @override
  String get failedToLoadCollectionDetails =>
      'No se pudieron cargar los detalles de la colección.';

  @override
  String get franchiseProgress => 'Progreso de la franquicia';

  @override
  String get officialSite => 'Sitio oficial';

  @override
  String get productions => 'Producciones';

  @override
  String get productionCompany => 'Compañía productora';

  @override
  String get failedToLoadCompanyInfo =>
      'No se pudo cargar la información de la empresa.';

  @override
  String get profile => 'Perfil';

  @override
  String get guestViewer => 'Espectador invitado';

  @override
  String get yourProfileSyncStateRegionPreferences =>
      'Tu perfil, estado de sincronización, región y preferencias visuales se encuentran aquí.';

  @override
  String get signInToSync =>
      'Inicia sesión para sincronizar tu lista de seguimiento, calificaciones y preferencias.';

  @override
  String get signedInAndSyncing =>
      'Sesión iniciada y sincronizando con la nube.';

  @override
  String get developedBy => 'Desarrollado por';

  @override
  String get couldNotAnalyzeWatchHistory =>
      'No se pudo analizar el historial de visualización en este momento.';

  @override
  String get includeLocalLibrary => 'Incluir la biblioteca local';

  @override
  String get useCloudOnly => 'Utilizar solo la nube';

  @override
  String get localLibrarySyncDescription =>
      'Este dispositivo ya tiene títulos en su biblioteca local. Inclúyalos en su biblioteca personal o reemplace los datos de su biblioteca local con los de su biblioteca en la nube.';

  @override
  String get mergedLocalTitles =>
      'Se han añadido títulos locales a la biblioteca donde has iniciado sesión.';

  @override
  String get replacedLocalLibrary =>
      'Se han sustituido los datos de la biblioteca local por los de la biblioteca en la nube.';

  @override
  String get deleteAccountConfirmation =>
      'Esto eliminará permanentemente tu cuenta de Lumi y los datos sincronizados en la nube. Los datos locales de este dispositivo permanecerán a menos que elimines los datos de la aplicación por separado.';

  @override
  String get signedOutAndCleared =>
      'Cerré sesión y vacié la biblioteca local en este dispositivo.';

  @override
  String get keepLocalLibrary => 'Mantengamos la biblioteca local';

  @override
  String get clearLocalLibrary => 'Biblioteca local de Clear';

  @override
  String get signOutChoiceDescription =>
      'Elige si deseas conservar la biblioteca local en este dispositivo después de cerrar sesión.';

  @override
  String get disable => 'Desactivar';

  @override
  String get aiRecommendationsEnabled =>
      'Se ha habilitado el intercambio de datos de recomendaciones de IA.';

  @override
  String get aiRecommendationsDisabled =>
      'Se ha desactivado el intercambio de datos de recomendaciones de IA.';

  @override
  String get reviewAndManageConsent =>
      'Revisar y gestionar el consentimiento para el envío de datos de la biblioteca a proveedores de IA.';

  @override
  String get aiRecommendationsEnabledSubtitle =>
      'Activado. Recommend Tonight puede enviar el resumen de tu biblioteca y tus consultas recientes a proveedores de IA.';

  @override
  String basedOnWatchedTitles(String count) {
    return 'Basado en $count títulos vistos';
  }

  @override
  String lastUpdated(String date) {
    return 'Última actualización: $date';
  }

  @override
  String get chooseYourVibe => 'Elige tu estilo';

  @override
  String get appearanceDescription =>
      'Cambia la aplicación entre diferentes personajes cinematográficos sin modificar ningún comportamiento.';

  @override
  String get exitAppConfirmation =>
      '¿Estás seguro de que quieres salir de Lumi?';

  @override
  String get dismiss => 'Despedir';

  @override
  String get generatingWatchAnalytics => 'Generación de análisis de vigilancia';

  @override
  String get thisUsuallyTakesAFewSeconds => 'Esto suele tardar unos segundos.';

  @override
  String get yourScreenStory => 'Tu historia en la pantalla';

  @override
  String get snapshotOfHowAndWhatYouWatch =>
      'Una instantánea de cómo y qué ves.';

  @override
  String get yourFavoriteGenres => 'Tus géneros favoritos';

  @override
  String get genrePerformanceHighestRated =>
      'Rendimiento por género (Mejor valorado)';

  @override
  String get personalizedViewingPatterns =>
      'Patrones de visualización personalizados';

  @override
  String get builtWithLumi => 'Construido con Lumi';

  @override
  String get sharedWithLumi => 'Compartido con Lumi';

  @override
  String get shareAnalytics => 'Compartir análisis';

  @override
  String analyzedTitlesUpdated(String count, String date) {
    return 'Se analizaron los títulos de $count • Se actualizó $date';
  }

  @override
  String get allSeasons => 'Todas las estaciones';

  @override
  String get castAndCrew => 'Elenco y equipo';

  @override
  String get featuredCrew => 'Equipo destacado';

  @override
  String get stills => 'Imágenes fijas';

  @override
  String get accoladeSummary => 'Resumen de los galardones';

  @override
  String get awardsAndAccolades => 'Premios y reconocimientos';

  @override
  String get unableToLoadMovieDetails =>
      'No se pudieron cargar los detalles de la película.';

  @override
  String get overviewUnavailable =>
      'No hay información general disponible para este título.';

  @override
  String get openCompletePlot =>
      'Acceda al gráfico completo y a los metadatos adicionales desde OMDb.';

  @override
  String get noOverviewForSeason =>
      'No hay resumen disponible para esta temporada.';

  @override
  String get userScore => 'Puntuación del usuario';

  @override
  String get playTrailer => 'Reproducir tráiler';

  @override
  String get whereToWatch => 'Dónde ver';

  @override
  String get availabilityDataByJustWatch =>
      'Datos de disponibilidad proporcionados por JustWatch.';

  @override
  String get reminderSaved => 'Recordatorio guardado';

  @override
  String reminderForTitle(String title) {
    return 'Recordatorio para $title';
  }

  @override
  String get pleaseSelectFutureTime => 'Por favor, seleccione una hora futura.';

  @override
  String get notifyAt => 'Notificar en';

  @override
  String get notifyHoursBeforeAiring =>
      '¿Con cuántas horas de antelación debo avisar?';

  @override
  String enterNumberBetween(String maxHours) {
    return 'Introduzca un número entre 1 y $maxHours';
  }

  @override
  String get set => 'Colocar';

  @override
  String get selectedReminderTimePassed =>
      'El tiempo de recordatorio seleccionado ya ha transcurrido.';

  @override
  String episodeReminderSaved(String date) {
    return 'Recordatorio de episodio guardado para $date';
  }

  @override
  String get areYouSureDeleteNote =>
      '¿Estás seguro de que quieres eliminar esta nota?';

  @override
  String get noteAdded => 'Nota añadida';

  @override
  String get lastSeason => 'Temporada pasada';

  @override
  String get currentSeason => 'Temporada actual';

  @override
  String get viewAllSeasons => 'Ver todas las temporadas';

  @override
  String get removedFromFavourites => 'Eliminado de Favoritos';

  @override
  String get addedToFavourites => 'Añadido a favoritos';

  @override
  String get awardsAndNominations => 'Premios y nominaciones';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get boxOfficeFinancials => 'Resultados financieros de taquilla';

  @override
  String get successMeter => 'Medidor de éxito';

  @override
  String get blockbuster => 'ÉXITO DE TAQUILLA';

  @override
  String get hit => 'GOLPEAR';

  @override
  String get breakEven => 'PUNTO DE EQUILIBRIO';

  @override
  String get underperformer => 'RENDIMIENTO INFERIOR';

  @override
  String get boxOfficeBomb => 'FRACASO DE TAQUILLA';

  @override
  String get episodeTracker => 'Rastreador de episodios';

  @override
  String get setAiringReminder => 'Configurar recordatorio de emisión';

  @override
  String get nextEpisodeCountdown =>
      'Cuenta regresiva para el próximo episodio';

  @override
  String get nextEpisode => 'Próximo episodio';

  @override
  String get lastEpisodeToAir => 'Último episodio emitido';

  @override
  String get unknown => 'Desconocido';

  @override
  String get contentAdvisory => 'Aviso sobre el contenido';

  @override
  String get violence => 'Violencia';

  @override
  String get sexAndNudity => 'Sexo y desnudez';

  @override
  String get foulLanguage => 'Idioma';

  @override
  String get substances => 'Sustancias';

  @override
  String get fearAndHorror => 'Miedo y horror';

  @override
  String get familyFriendly => 'Apto para familias';

  @override
  String get generalAudience => 'Público general';

  @override
  String get releaseTimeline => 'Cronograma de lanzamiento';

  @override
  String get notifyMe => 'Notificarme';

  @override
  String get theatricalRelease => 'Estreno en cines';

  @override
  String get digitalStreaming =>
      'Traduzca esta etiqueta de aplicación al español: Digital / Streaming';

  @override
  String get physicalRelease => 'Formato físico (Blu-ray/DVD)';

  @override
  String get awesome => 'Impresionante';

  @override
  String get keywordsAndThemes => 'Palabras clave y temas';

  @override
  String get videosAndBehindTheScenes => 'Vídeos y detrás de cámaras';

  @override
  String get productionStudios => 'Estudios de producción';

  @override
  String get fetchingWatchLink => 'Obteniendo enlace del reloj';

  @override
  String get findingBestProviderPage =>
      'Encontrar la mejor página de proveedor para este título.';

  @override
  String episodeCode(String season, String episode) {
    return 'S${season}E$episode';
  }

  @override
  String get error => 'Traduzca esta etiqueta de la aplicación a es: Error';

  @override
  String get failedToLoadSeasonDetails =>
      'No se pudieron cargar los detalles de la temporada.';

  @override
  String get loading => 'Cargando...';

  @override
  String runtimeSeparator(String runtime) {
    return 'Traduzca esta etiqueta de la aplicación a es: • $runtime';
  }

  @override
  String get fullCastAndCrew => 'Reparto y equipo completo';

  @override
  String get shareMovie => 'Compartir película';

  @override
  String get quotes => 'Citas';

  @override
  String get mayIncludeMismatches =>
      'Puede contener errores ocasionales debido a la búsqueda de citas léxicas.';

  @override
  String get movieApiConfigurationRequired =>
      'Se requiere configuración de la API de películas';

  @override
  String get addMovieProxyBaseUrl =>
      'Agregue MOVIE_PROXY_BASE_URL para conectar la aplicación al proxy de TMDB.';

  @override
  String get cinematicPicksContext =>
      'Selecciones cinematográficas con contexto de ambiente instantáneo. Tira los dados para obtener otra carta sorpresa.';

  @override
  String get curatedTonight => 'Seleccionado para esta noche';

  @override
  String curatedTonightTitle(String title) {
    return 'Selección de esta noche: $title';
  }

  @override
  String get describeItYourWay =>
      'Descríbelo a tu manera.\nEncontramos las mejores coincidencias.';

  @override
  String get hide => 'Esconder';

  @override
  String get hideTitleDescription =>
      'Ocultar este título impedirá que aparezca en la sección Destacados en el futuro.';

  @override
  String get dontAskAgain => 'No lo preguntes de nuevo';

  @override
  String get imdbNa =>
      'Traduzca esta etiqueta de aplicación al español: IMDb NA';

  @override
  String get noDiscoverPicks =>
      'No hay recomendaciones de descubrimiento disponibles en este momento.';

  @override
  String get playPreview => 'Reproducir vista previa';

  @override
  String get recommendedForYou => 'Recomendado para ti';

  @override
  String get spotlightCompleted => 'Proyecto Spotlight finalizado';

  @override
  String get startAddingTitlesForRecommendations =>
      'Empieza a añadir títulos para recomendaciones';

  @override
  String get clearedAllChoices =>
      'Has deslizado y borrado todas las opciones en tu sección de descubrimiento.';

  @override
  String get whatsPopular => 'Lo que es popular';

  @override
  String get trending => 'Tendencias';

  @override
  String get trendingPeople => 'Personalidades de tendencia';

  @override
  String get starringTodayOrThisWeek =>
      'Estrellas que son tendencia hoy o esta semana';

  @override
  String get nowPlaying => 'Reproduciendo ahora';

  @override
  String get tvTrending => 'Tendencias en televisión';

  @override
  String get discoverByMood => 'Descubre según tu estado de ánimo';

  @override
  String get needSomethingToWatchTonight =>
      '¿Necesitas algo para ver esta noche?';

  @override
  String get needAMovieForTonight => '¿Necesitas una película para esta noche?';

  @override
  String get tryAiShows => 'Prueba los programas de IA';

  @override
  String get tryAiMovies => 'Prueba las películas con IA';

  @override
  String get findShows => 'Buscar espectáculos';

  @override
  String get findMovies => 'Buscar películas';

  @override
  String get couldNotLoadThisRail => 'No se pudo cargar este riel';

  @override
  String get temporaryIssueLoadingRail =>
      'Se produjo un problema temporal al cargar este riel.';

  @override
  String get noTitlesHereYet => 'Aún no hay títulos aquí';

  @override
  String get noHiddenGemsForGenre =>
      'Aún no se han encontrado joyas ocultas en este género. Prueba con otro.';

  @override
  String get tryAnotherFilter =>
      'Pruebe con otro filtro o abra esta sección para obtener más información.';

  @override
  String get seeAllFilters => 'Ver todos los filtros';

  @override
  String get couldNotLoadCuratedPicks =>
      'No se pudieron cargar las selecciones curadas.';

  @override
  String get temporaryIssueLoadingCurated =>
      'Se produjo un problema temporal al cargar la lista seleccionada de esta noche.';

  @override
  String get noCuratedPicksAvailable =>
      'No hay selecciones seleccionadas disponibles';

  @override
  String get tryAgainWhileRefresh =>
      'Inténtalo de nuevo en un momento mientras actualizamos la lista de TMDB de esta noche.';

  @override
  String get fromSpotlight => 'Desde el punto de vista del protagonista';

  @override
  String get addShowsMoviesForRecommendations =>
      'Agrega series o películas a tu lista de seguimiento, favoritos o vistos para ver títulos que podrían gustarte.';

  @override
  String get allow => 'Permitir';

  @override
  String get notNow => 'Ahora no';

  @override
  String get allowAiDataSharingTitle =>
      '¿Permitir el intercambio de datos de IA?';

  @override
  String get allowAiDataSharingDescription =>
      'Recommend Tonight envía el texto que escribes para solicitar una recomendación de película y el contexto temporal para refinar la consulta a Google Gemini y OpenRouter. Tu biblioteca completa y tus credenciales de inicio de sesión no se envían a estos proveedores de IA. ¿Permites que se compartan estos datos para las recomendaciones de IA?';

  @override
  String get liveProgress => 'Progreso en directo';

  @override
  String percentComplete(String percent) {
    return '$percent% completado';
  }

  @override
  String get describeIdealShowNight => 'Describe tu noche de espectáculo ideal';

  @override
  String get describeIdealMovieNight => 'Describe tu noche de cine ideal';

  @override
  String get useNaturalLanguage =>
      'Utilice un lenguaje natural. Mencione lo que desea, lo que debe evitar y sugerencias opcionales sobre el idioma o el entorno de ejecución.';

  @override
  String get listeningTapMicToStop =>
      'Escuchando... pulsa el micrófono de nuevo para detenerlo.';

  @override
  String voiceInputError(String error) {
    return 'Error de entrada de voz: $error';
  }

  @override
  String get tapMicToDictate => 'Pulsa el micrófono para dictar tu petición.';

  @override
  String get tapMicToEnableVoice =>
      'Pulsa el micrófono para activar la entrada de voz.';

  @override
  String get findingShows => 'Encontrar espectáculos...';

  @override
  String get findingMovies => 'Encontrar películas...';

  @override
  String tonightsLumiPicksFor(String prompt) {
    return 'Las recomendaciones de Lumi para esta noche: $prompt';
  }

  @override
  String get tonightsPicks => 'Pronósticos de esta noche';

  @override
  String get sharedFromLumi => 'Compartido desde Lumi';

  @override
  String get intent => 'Intención:';

  @override
  String get genreLabel => 'Género:';

  @override
  String get avoid => 'Evitar:';

  @override
  String get languageLabel => 'Idioma:';

  @override
  String runtimeAtMost(String minutes) {
    return 'Tiempo de ejecución <= $minutes min';
  }

  @override
  String runtimeAtLeast(String minutes) {
    return 'Tiempo de ejecución >= $minutes min';
  }

  @override
  String get yearLabel => 'Año:';

  @override
  String yearAfter(String year) {
    return 'Después de $year';
  }

  @override
  String yearBefore(String year) {
    return 'Antes de $year';
  }

  @override
  String get like => 'Como:';

  @override
  String get signal => 'Señal:';

  @override
  String get readingWatchedHistory =>
      'Leyendo tu historial de visualización...';

  @override
  String get findingTopGenres => 'Descubre tus géneros y patrones favoritos...';

  @override
  String get buildingTrends =>
      'Generando tendencias mensuales y de calificación...';

  @override
  String get writingInsights => 'Redacta tus ideas personalizadas...';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get includeNotRated => 'Incluir No clasificado';

  @override
  String get errorLoadingTvGenres => 'Error al cargar los géneros de TV';

  @override
  String get alsoKnownAs => 'También conocido como';

  @override
  String get biography => 'Biografía';

  @override
  String get careerStatistics => 'Estadísticas de carrera';

  @override
  String get frequentlyCollaboratesWith => 'Colabora frecuentemente con';

  @override
  String get notableQuotes => 'Citas destacadas';

  @override
  String get primaryRole => 'Función principal';

  @override
  String get averageRating => 'Calificación promedio';

  @override
  String get topGenre => 'Género principal';

  @override
  String get peakBoxOffice => 'Taquilla máxima';

  @override
  String percentOfTitles(String percent) {
    return '$percent% de títulos';
  }

  @override
  String sharedTitleCount(String count) {
    return 'Título(s) compartido(s) $count';
  }

  @override
  String billingOrder(String order) {
    return 'Facturado #$order';
  }

  @override
  String get startTypingToSearch => 'Empiece a escribir para buscar';

  @override
  String get movieDiscoveryMadePersonal =>
      'Descubrimiento de películas, hecho personal.';

  @override
  String get allNotes => 'Todas las notas';

  @override
  String get viewPersonalizedInsights =>
      'Consulta análisis, gráficos y tendencias personalizados.';

  @override
  String get curatedCollections => 'Colecciones seleccionadas';

  @override
  String get list => 'lista';

  @override
  String get openList => 'Lista abierta';

  @override
  String get thisListNoLongerExists => 'Esta lista ya no existe.';

  @override
  String listRenamed(String name) {
    return 'La lista ha sido renombrada a $name';
  }

  @override
  String listDeleted(String name) {
    return 'Lista $name eliminada';
  }

  @override
  String noFilterInWatchlist(String filter) {
    return 'No hay $filter en tu lista de seguimiento.';
  }

  @override
  String noFilterInFavourites(String filter) {
    return 'No hay $filter en tus favoritos';
  }

  @override
  String noFilterInWatched(String filter) {
    return 'No hay $filter en la vigilancia';
  }

  @override
  String noFilterInThisList(String filter) {
    return 'No hay $filter en esta lista.';
  }

  @override
  String noListsWithFilter(String filter) {
    return 'No hay listas con $filter';
  }

  @override
  String importedInto(String name) {
    return 'Importado en \"$name\"';
  }

  @override
  String get couldNotImportList => 'No se pudo importar la lista';

  @override
  String get importing => 'Importador...';

  @override
  String get couldNotLoadSharedList =>
      'No se pudo cargar esta lista compartida.';

  @override
  String get editWatchedInfo => 'Editar información de seguimiento';

  @override
  String get watchDate => 'Fecha de visualización';

  @override
  String get rewatchCount => 'Número de veces que se ha vuelto a ver';

  @override
  String get watchedInfoUpdated => 'Información actualizada';

  @override
  String removedFromList(String listName) {
    return 'Eliminado de $listName';
  }

  @override
  String addedToList(String listName) {
    return 'Añadido a $listName';
  }

  @override
  String addedToListAndWatchlist(String listName) {
    return 'Añadido a $listName y a la lista de seguimiento.';
  }

  @override
  String get moreTrailersLikeThis => 'Más tráileres como este';

  @override
  String get noDescriptionForTrailer =>
      'No hay descripción disponible para este tráiler.';

  @override
  String get closeTrailer => 'Cerrar tráiler';

  @override
  String get recommendedSeries => 'Series recomendadas';

  @override
  String get recommendedMovie => 'Película recomendada';

  @override
  String get notEnoughDataYet => 'Todavía no hay suficientes datos.';

  @override
  String addAndRateMoreTitles(String count) {
    return 'Agrega y califica al menos $count títulos para desbloquear las funciones de análisis.';
  }

  @override
  String addMoreTitlesToUnlock(
    String watchedCount,
    String requiredCount,
    String remaining,
  ) {
    return 'Has visto $watchedCount/$requiredCount títulos. Añade $remaining más para desbloquear las estadísticas.';
  }

  @override
  String get moviesPerMonth => 'Películas al mes';

  @override
  String get genreDistribution => 'Distribución por género';

  @override
  String get ratingTrends => 'Tendencias de calificación';

  @override
  String get noData => 'Sin datos';

  @override
  String get myLatestWatchAnalytics =>
      'Mis últimas estadísticas de reloj en Lumi';

  @override
  String get myWatchInsights => 'Mis impresiones sobre el reloj Lumi';

  @override
  String get infographicsCard => 'Tarjeta de infografía';

  @override
  String get watchInsightsSnapshot => 'Resumen de Insights de Watch';

  @override
  String get availableOnceInsightsReady =>
      'Disponible una vez que los análisis estén listos.';

  @override
  String get shareYourWatchInsights =>
      'Comparte tu tarjeta de información sobre el reloj';

  @override
  String get recentlyWatchedVibe => 'Vibe visto recientemente';

  @override
  String get mixedAcrossGenres => 'Mezclado de géneros';

  @override
  String get moviesPerMonthShort => 'Películas / Mes';

  @override
  String get ratingTrend => 'Tendencia de calificación';

  @override
  String get balanced => 'Equilibrado';

  @override
  String get noWatchNextSuggestionsYet =>
      'Aún no hay sugerencias para ver a continuación.';

  @override
  String get upcomingFromLibrary => 'Próximamente en tu biblioteca';

  @override
  String get removeReminder => 'Eliminar recordatorio';

  @override
  String get remindMe => 'Recuérdame';

  @override
  String titleReleasesToday(String title) {
    return '$title se lanza hoy.';
  }

  @override
  String titleAirsSoon(String title, String subtitle) {
    return '$title $subtitle se emitirá pronto.';
  }

  @override
  String get controlPremiereAlerts =>
      'Controla las alertas de estreno y los recordatorios de lanzamiento.';

  @override
  String upcomingReleasesCount(String count) {
    return '$count Próximos lanzamientos en tu biblioteca.';
  }

  @override
  String sittingInWatchlist(String days) {
    return 'En tu lista de seguimiento durante $days días';
  }

  @override
  String get alreadyOnWatchlist => 'Ya está en tu lista de seguimiento.';

  @override
  String get favouritedButNotWatched =>
      'Has añadido esto a tus favoritos, pero aún no lo has marcado como visto.';

  @override
  String get savedInListReady =>
      'Guardado en una de tus listas y listo para ver.';

  @override
  String get matchesTitlesYouTrack => 'Coincide con los títulos que ya sigues.';

  @override
  String get noOfficialSite => 'No hay sitio oficial';

  @override
  String get episodeAiring => 'Emisión del episodio';

  @override
  String get general => 'Traduzca esta etiqueta de aplicación a es: General';

  @override
  String scheduledFor(String date) {
    return 'Programado para $date';
  }

  @override
  String wasScheduledFor(String date) {
    return 'Estaba programado para $date';
  }

  @override
  String get noOverviewAvailable => 'No hay resumen disponible.';

  @override
  String get searchHistoryCleared => 'Historial de búsqueda borrado';

  @override
  String get visualMovieCard => 'Tarjeta de visualización de películas';

  @override
  String get smartLumiLink => 'Enlace inteligente Lumi Link';

  @override
  String get directTmdbLink => 'Enlace directo a TMDB';

  @override
  String recommendedOnLumi(String title) {
    return 'Recomendado en Lumi: $title';
  }

  @override
  String checkOutOnLumi(String title, String link, String appLink) {
    return '¡Descubre $title en Lumi!\n\n$link\n\nConsigue Lumi: $appLink';
  }

  @override
  String checkOutOnTmdb(String title, String link) {
    return 'Consulta $title en TMDB: $link';
  }

  @override
  String releaseAlertTitle(String title) {
    return 'Alerta de liberación de $title';
  }

  @override
  String releaseAlertFullMessage(String date) {
    return 'Se ha configurado una alerta de lanzamiento para $date. Le notificaremos cuando esté disponible.';
  }

  @override
  String releaseSuccessDialogContent(String title) {
    return '¡Te avisaremos en cuanto \"$title\" se lance en formato digital o en Blu-ray/DVD!';
  }

  @override
  String get episodeAlreadyDueToAir =>
      'Este episodio ya está programado para emitirse.';

  @override
  String get reminderSetSuccessfully =>
      'Recordatorio configurado correctamente';

  @override
  String get speechRecognitionNotAvailable =>
      'Este dispositivo no dispone de reconocimiento de voz.';

  @override
  String get describeShowMood =>
      'Describe qué programa te apetece ver y te enviaremos una lista clasificada.';

  @override
  String get describeMovieMood =>
      'Describe qué película te apetece ver y te enviaremos una lista clasificada.';

  @override
  String get aiLauncherDescription =>
      'Escribe o pronuncia una solicitud en lenguaje natural. Lumi crea un plan de IA, realiza una búsqueda vectorial y te ofrece varias recomendaciones de series o películas.';

  @override
  String yearRange(String from, String to) {
    return 'Traduzca esta etiqueta de la aplicación a es: $from-$to';
  }

  @override
  String remindersCountScheduled(String count) {
    return 'Se ha programado(n) el/los recordatorio(s) $count.';
  }

  @override
  String regionAutoDetected(String region) {
    return 'Detectado automáticamente: $region';
  }

  @override
  String regionSelected(String region) {
    return 'Seleccionado: $region';
  }

  @override
  String get allLanguagesSubtitle => 'Todos los idiomas';

  @override
  String currentlySetToLanguage(String language) {
    return 'Actualmente configurado en $language';
  }

  @override
  String get availabilities => 'Disponibilidad';

  @override
  String get mood => 'Ánimo';

  @override
  String get people => 'Gente';

  @override
  String get ads => 'Anuncios';

  @override
  String get theatricalLimited =>
      'Traduzca esta etiqueta de aplicación a es: Theatrical Limited';

  @override
  String get premier => 'Primer ministro';

  @override
  String get mediaType => 'Tipo de medio';

  @override
  String get couldNotLoadAnalytics => 'No se pudo cargar la analítica';

  @override
  String get viewAllAwards => 'Ver todo';

  @override
  String get win => 'Ganar';

  @override
  String get wins => 'Victorias';

  @override
  String get nomination => 'Nominación';

  @override
  String get nominations => 'Nominaciones';

  @override
  String sharedBy(String name) {
    return 'Compartido por $name';
  }

  @override
  String titleCount(String count) {
    return '$count título(s)';
  }

  @override
  String savedTitlesAcrossLists(String count) {
    return '$count guardó los títulos en todas tus listas';
  }

  @override
  String get curatedCollectionsSubtitle =>
      'Colecciones seleccionadas que puedes organizar y compartir.';

  @override
  String shareListMessage(
    String name,
    String count,
    String itemLabel,
    String link,
  ) {
    return 'Importar \"$name\" en Lumi ($count $itemLabel): $link';
  }

  @override
  String get notEnoughData => 'Datos insuficientes';

  @override
  String shareQuote(String title) {
    return '¡Mira esta cita de \"$title\" en Lumi!';
  }

  @override
  String shareMovieMessage(String title, String link) {
    return 'Recomendado en Lumi: $title\n\n$link';
  }

  @override
  String get aiLauncherDescriptionShow =>
      'Escribe o pronuncia una solicitud en lenguaje natural. Lumi crea un plan de IA, realiza una búsqueda vectorial y devuelve varias recomendaciones de programas.';

  @override
  String get aiLauncherDescriptionMovie =>
      'Escribe o pronuncia una solicitud en lenguaje natural. Lumi crea un plan de IA, realiza una búsqueda vectorial y te ofrece varias opciones de películas.';

  @override
  String get warmingUpMovieSearch => 'Calentando tu búsqueda de películas';

  @override
  String get connectingToRecommendationEngine =>
      'Conectando con el motor de recomendaciones';

  @override
  String get understandingYourTaste => 'Comprender qué es lo que te apetece';

  @override
  String get buildingCustomSearch =>
      'Creación de una búsqueda personalizada a partir de su solicitud.';

  @override
  String get tinyNetworkHiccup =>
      'Pequeño problema de red, intentándolo de nuevo.';

  @override
  String get planLocked => 'Plan definido: género, estilo, idioma y duración.';

  @override
  String get scanningTmdb => 'Buscando coincidencias sólidas en TMDB';

  @override
  String get collectingDetails =>
      'Recopilación de pósteres, calificaciones y duración de las mejores opciones.';

  @override
  String shortlistingPicksCount(String current, String total) {
    return 'Selección de candidatos ($current/$total)';
  }

  @override
  String get shortlistingBestPicks => 'Selección de las mejores opciones';

  @override
  String get finalPolish => 'Últimos retoques a sus recomendaciones';

  @override
  String get retryingAfterIssue => 'Reintentando tras un problema temporal.';

  @override
  String get regionUnitedStates => 'Estados Unidos';

  @override
  String get regionIndia => 'Traducir a es: India';

  @override
  String get regionUnitedKingdom => 'Reino Unido';

  @override
  String get regionCanada => 'Canadá';

  @override
  String get regionAustralia => 'Traducir a es: Australia';

  @override
  String get regionNewZealand => 'Nueva Zelanda';

  @override
  String get regionGermany => 'Alemania';

  @override
  String get regionFrance => 'Francia';

  @override
  String get regionSpain => 'España';

  @override
  String get regionItaly => 'Italia';

  @override
  String get regionJapan => 'Japón';

  @override
  String get regionSouthKorea => 'Corea del Sur';

  @override
  String get regionBrazil => 'Brasil';

  @override
  String get regionMexico => 'México';

  @override
  String get regionSingapore => 'Singapur';

  @override
  String get regionPhilippines => 'Filipinas';

  @override
  String get regionIndonesia => 'Traducir a es: Indonesia';

  @override
  String get regionUnitedArabEmirates => 'Emiratos Árabes Unidos';

  @override
  String get regionSaudiArabia => 'Arabia Saudita';

  @override
  String get regionTurkey => 'Pavo';

  @override
  String regionAutoDetectedSubtitle(String regionLabel, String regionCode) {
    return 'Región detectada automáticamente: $regionLabel ($regionCode). Seleccione una región para anular la configuración predeterminada en las consultas de películas localizadas y las búsquedas de proveedores de visualización.';
  }

  @override
  String regionSelectedSubtitle(String regionLabel, String regionCode) {
    return 'Región seleccionada: $regionLabel ($regionCode). Las consultas de películas y las búsquedas de proveedores de visualización compatibles reutilizarán esto automáticamente la próxima vez.';
  }

  @override
  String get syncSignInTooltip => 'Inicia sesión para sincronizar con la nube.';

  @override
  String get syncFailedTooltip =>
      'Error de sincronización. Toca para reintentar.';

  @override
  String get syncedTooltip => 'Biblioteca sincronizada con la nube.';

  @override
  String get shareQuoteTooltip => 'Compartir cita';

  @override
  String get copyQuoteTooltip => 'Copiar cita';

  @override
  String get quoteCopiedToast => 'Cita copiada al portapapeles';

  @override
  String get shareDialogueTooltip => 'Compartir diálogo';

  @override
  String get copyDialogueTooltip => 'Copiar diálogo';

  @override
  String get dialogueCopiedToast => 'Diálogo copiado al portapapeles';

  @override
  String tvAirsInOneHourTitle(String title) {
    return '$title se emite en 1 hora';
  }

  @override
  String tvAirsInOneHourBody(
    String episodeLabel,
    String episodeName,
    String localAirTime,
  ) {
    return '$episodeLabel \"$episodeName\" se emite en $localAirTime.';
  }

  @override
  String movieReleasesTodayTitle(String title) {
    return '$title se lanza hoy';
  }

  @override
  String movieReleasesTodayBody(String localDate) {
    return 'Una película de tu biblioteca se estrena el $localDate.';
  }

  @override
  String get curatedNeoNoirNights => 'Noches neo-noir';

  @override
  String get curatedPulsePoundingRush => 'Una descarga de adrenalina';

  @override
  String get curatedFeelGoodEscape => 'Escapada para sentirse bien';

  @override
  String get curatedMindBenders => 'Deformantes mentales';

  @override
  String get curatedEpicWorlds => 'Mundos épicos';

  @override
  String get curatedHumanStories => 'Historias humanas';

  @override
  String get curatedDarkDetectiveFiles => 'Archivos del detective oscuro';

  @override
  String get curatedNeoNoirNightsDescription =>
      'Tensión bajo la lluvia, protagonistas moralmente ambiguos e historias urbanas con una atmósfera envolvente.';

  @override
  String get curatedPulsePoundingRushDescription =>
      'Persecuciones de alto riesgo, peligro creciente y ritmo frenético que no da respiro.';

  @override
  String get curatedFeelGoodEscapeDescription =>
      'Historias conmovedoras, tramas inspiradoras y lecturas reconfortantes para una noche relajada.';

  @override
  String get curatedMindBendersDescription =>
      'Conceptos que desafían la realidad, tramas intrincadas y narración de historias con grandes ideas.';

  @override
  String get curatedEpicWorldsDescription =>
      'Aventuras en universos épicos, riesgos épicos y una escala cinematográfica.';

  @override
  String get curatedHumanStoriesDescription =>
      'Dramas centrados en los personajes, con gran carga emocional e interpretaciones memorables.';

  @override
  String get curatedDarkDetectiveFilesDescription =>
      'Pistas frías, sospechosos con múltiples facetas e investigaciones que se desarrollan lentamente.';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get appLanguageSystemDefault =>
      'Configuración predeterminada del sistema';

  @override
  String appLanguageSelectedSubtitle(String language) {
    return 'Idioma de la aplicación configurado en $language. Esto solo cambia la interfaz de la aplicación, no el idioma de las películas y series.';
  }

  @override
  String get appLanguageSystemSubtitle =>
      'El idioma de la aplicación se ajusta a la configuración de tu dispositivo. Cámbialo para mantener la interfaz en otro idioma.';

  @override
  String get contentLanguageAllSubtitle =>
      'Todos los idiomas. Las pestañas de Películas y TV siguen siendo generales, mientras que la función Explorar puede priorizar las opciones locales más adecuadas cuando estén disponibles.';

  @override
  String contentLanguageSelectedSubtitle(String language) {
    return 'Actualmente está configurado en $language. Las pestañas de Películas y TV seguirán siendo estrictas, mientras que la sección Explorar dará preferencia a este idioma primero.';
  }
}
