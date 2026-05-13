import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/repositories/quotes_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaQuotesProvider = FutureProvider.family<List<MediaQuote>, ({String title, bool isTv})>((ref, args) {
  return ref.watch(quotesRepositoryProvider).fetchMediaQuotes(args.title, isTv: args.isTv);
});

final personQuotesProvider = FutureProvider.family<List<MediaQuote>, String>((ref, name) {
  return ref.watch(quotesRepositoryProvider).fetchPersonQuotes(name);
});

final fullWikiquoteProvider = FutureProvider.family<WikiquoteArticle?, ({String title, bool isTv, bool isSeason, String? pageName})>((ref, args) {
  return ref.watch(quotesRepositoryProvider).fetchFullWikiquoteArticle(
    args.title, 
    isTv: args.isTv, 
    isSeason: args.isSeason, 
    exactPageTitle: args.pageName
  );
});
