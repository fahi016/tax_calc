// lib/db/form_persistence_service.dart
//
// A thin service that reads / writes the single saved form entry.
// The app only ever needs one saved draft, so we use key 'draft'.

import 'package:hive_flutter/hive_flutter.dart';
import 'it_form_data_hive.dart';

class FormPersistenceService {
  static const String _boxName = 'it_form_box';
  static const String _draftKey = 'draft';

  // ── Initialisation ──────────────────────────────────────────────────────────
  // Call once from main() before runApp().
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ItFormDataHiveAdapter());
    await Hive.openBox<ItFormDataHive>(_boxName);
  }

  // ── Internal accessor ───────────────────────────────────────────────────────
  Box<ItFormDataHive> get _box => Hive.box<ItFormDataHive>(_boxName);

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns the previously saved form data, or null if nothing was saved yet.
  ItFormDataHive? load() => _box.get(_draftKey);

  /// Persists [data] under the single draft key (overwrites any prior save).
  Future<void> save(ItFormDataHive data) => _box.put(_draftKey, data);

  /// Removes the saved draft (e.g. on a "Clear form" action).
  Future<void> clear() => _box.delete(_draftKey);

  /// True if a draft exists.
  bool get hasSavedData => _box.containsKey(_draftKey);
}