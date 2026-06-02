import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/effect_preset.dart';

// ─── Presets
final presetsProvider =
    StateNotifierProvider<PresetsNotifier, List<EffectPreset>>(
  (ref) => PresetsNotifier(),
);

class PresetsNotifier extends StateNotifier<List<EffectPreset>> {
  PresetsNotifier() : super([]) {
    _load();
  }

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/onda_sonora/presets.json');
  }

  Future<void> _load() async {
    try {
      final f = await _file;
      if (!f.existsSync()) return;
      final json = jsonDecode(f.readAsStringSync()) as List<dynamic>;
      state = json
          .map((e) => EffectPreset.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<void> _save() async {
    final f = await _file;
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(jsonEncode(state.map((p) => p.toJson()).toList()));
  }

  Future<void> add(EffectPreset preset) async {
    state = [...state, preset];
    await _save();
  }

  Future<void> remove(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _save();
  }
}

// ─── Effect picker visibility
final effectPickerVisibleProvider = StateProvider<bool>((ref) => false);
