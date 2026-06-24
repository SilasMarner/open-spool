import 'data/catalog.dart';
import 'data/loadout_repository.dart';
import 'services/settings.dart';

/// App-wide singletons. Kept tiny and explicit instead of pulling in a DI/state
/// package — the app has a single calculator screen plus pickers.
final settings = Settings();
final catalog = Catalog.instance;
final loadoutRepo = LoadoutRepository();
