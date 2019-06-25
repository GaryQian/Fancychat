import 'dart:ui' as ui;
import "main_publish.dart" as entrypoint;

Future<void> main() async {
  await ui.webOnlyInitializePlatform();
  entrypoint.main();
}

