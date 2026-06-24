import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'unit_converter.dart';

/// App settings (currently just the unit system), persisted to shared_prefs and
/// exposed as a [ChangeNotifier] so the UI rebuilds on change.
class Settings extends ChangeNotifier {
  static const _unitsKey = 'unit_system';

  UnitSystem _units = UnitSystem.us;
  UnitSystem get units => _units;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_unitsKey);
    _units = v == 'metric' ? UnitSystem.metric : UnitSystem.us;
    notifyListeners();
  }

  Future<void> setUnits(UnitSystem units) async {
    if (units == _units) return;
    _units = units;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitsKey, units == UnitSystem.metric ? 'metric' : 'us');
  }
}
