import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  const outDirEnv = String.fromEnvironment(
    'SCREENSHOT_DIR',
    defaultValue: 'play_store_assets/screenshots/android-phone',
  );
  final Directory outDir = Directory(outDirEnv)..createSync(recursive: true);

  await integrationDriver(
    onScreenshot:
        (String name, List<int> image, [Map<String, Object?>? _]) async {
          final file = File('${outDir.path}/$name.png');
          await file.writeAsBytes(image, flush: true);
          return true;
        },
  );
}
