import 'package:cineverse/app/app.dart';
import 'package:cineverse/presentation/providers/sync_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          // Initialize sync listener
          ref.watch(syncInitializationProvider);
          return const LumiApp();
        },
      ),
    ),
  );
}
