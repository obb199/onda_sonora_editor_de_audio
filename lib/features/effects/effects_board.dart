import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/live_preview_service.dart';
import '../../l10n/app_strings.dart';
import '../../models/audio_effect.dart';
import '../../models/audio_project.dart';
import '../../providers/audio_provider.dart';
import '../../providers/editor_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/effect_slider.dart';

/// Shows every effect as a persistent card — always visible, all editable at once.
/// Each effect has an ON/OFF switch; turning it on immediately triggers a live preview.
class EffectsBoard extends ConsumerWidget {
  const EffectsBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(audioProjectProvider);
    if (project == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        _SectionHeader(AppStrings.livePreview, Icons.bolt_rounded, AppColors.secondary),
        const SizedBox(height: 8),
        _LiveControlsCard(),
        const SizedBox(height: 20),

        _SectionHeader(AppStrings.effectEqualizer, Icons.equalizer_rounded, const Color(0xFFFF6D00)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.equalizer, project: project),
        const SizedBox(height: 12),

        _SectionHeader('${AppStrings.effectReverb} & ${AppStrings.effectDelay}',
            Icons.waves_rounded, const Color(0xFF7C4DFF)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.reverb, project: project),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.delay, project: project),
        const SizedBox(height: 12),

        _SectionHeader(AppStrings.effectDistortion, Icons.electric_bolt_rounded,
            const Color(0xFFFF5252)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.distortion, project: project),
        const SizedBox(height: 12),

        _SectionHeader('${AppStrings.effectChorus} / ${AppStrings.effectFlanger} / ${AppStrings.effectPhaser}',
            Icons.rotate_left_rounded, const Color(0xFF9C27B0)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.chorus, project: project),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.flanger, project: project),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.phaser, project: project),
        const SizedBox(height: 12),

        _SectionHeader(AppStrings.effectLowPass, Icons.filter_alt_rounded,
            const Color(0xFF03A9F4)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.lowPass, project: project),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.highPass, project: project),
        const SizedBox(height: 12),

        _SectionHeader(AppStrings.effectBitcrusher, Icons.broken_image_rounded,
            const Color(0xFFFF9800)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.bitcrusher, project: project),
        const SizedBox(height: 12),

        _SectionHeader(AppStrings.effectCompressor, Icons.compress,
            const Color(0xFFFFC107)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.compressor, project: project),
        const SizedBox(height: 12),

        _SectionHeader(AppStrings.effectNormalize, Icons.auto_fix_high_rounded,
            const Color(0xFF00BCD4)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.normalize, project: project),
        const SizedBox(height: 12),

        _SectionHeader('${AppStrings.effectFadeIn} / ${AppStrings.effectFadeOut}',
            Icons.trending_up_rounded, const Color(0xFF795548)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.fadeIn, project: project),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.fadeOut, project: project),
        const SizedBox(height: 12),

        _SectionHeader(AppStrings.effectReverse, Icons.fast_rewind_rounded,
            const Color(0xFFFF5722)),
        const SizedBox(height: 8),
        _EffectCard(type: EffectType.reverse, project: project),
      ],
    );
  }
}

// ─── Section header

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ─── Live controls card (speed/pitch/volume — always-on, no toggle needed)

class _LiveControlsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(audioProjectProvider);
    if (project == null) return const SizedBox.shrink();
    final notifier = ref.read(audioProjectProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withAlpha(60)),
      ),
      child: Column(
        children: [
          EffectSlider(
            label: AppStrings.speed,
            value: project.speed,
            min: 0.25,
            max: 4.0,
            valueFormatter: (v) => '${v.toStringAsFixed(2)}x',
            onChanged: (v) => notifier.setSpeed(v),
          ),
          EffectSlider(
            label: AppStrings.pitch,
            value: project.pitch,
            min: 0.5,
            max: 2.0,
            valueFormatter: (v) => '${v.toStringAsFixed(2)}x',
            onChanged: (v) => notifier.setPitch(v),
          ),
          EffectSlider(
            label: AppStrings.volume,
            value: project.volume,
            min: 0.0,
            max: 1.5,
            valueFormatter: (v) => '${(v * 100).toInt()}%',
            onChanged: (v) => notifier.setVolume(v),
          ),
        ],
      ),
    );
  }
}

// ─── Individual effect card

class _EffectCard extends ConsumerWidget {
  const _EffectCard({required this.type, required this.project});
  final EffectType type;
  final AudioProject project;

  AudioEffect _effectForType() {
    return project.effects.firstWhere(
      (e) => e.type == type,
      orElse: () => AudioEffect.defaultFor(type).copyWith(enabled: false),
    );
  }

  int? _indexForType() {
    final idx = project.effects.indexWhere((e) => e.type == type);
    return idx >= 0 ? idx : null;
  }

  void _toggle(WidgetRef ref) {
    final notifier = ref.read(audioProjectProvider.notifier);
    final idx = _indexForType();
    final effect = _effectForType();

    if (idx == null) {
      // Effect not in chain yet — add it enabled
      notifier.addEffect(AudioEffect.defaultFor(type).copyWith(enabled: true));
    } else {
      notifier.updateEffect(idx, effect.toggled());
    }
    _triggerPreview(ref);
  }

  void _updateParam(WidgetRef ref, String key, double value) {
    final notifier = ref.read(audioProjectProvider.notifier);
    final idx = _indexForType();
    final effect = _effectForType();

    if (idx == null) {
      // Add the effect (enabled) with this param changed
      notifier.addEffect(AudioEffect.defaultFor(type)
          .copyWith(enabled: true)
          .withParam(key, value));
    } else {
      notifier.updateEffect(idx, effect.withParam(key, value));
    }
    _triggerPreview(ref);
  }

  void _triggerPreview(WidgetRef ref) {
    final liveEnabled = ref.read(editorUiProvider).livePreviewEnabled;
    if (!liveEnabled) return;
    final project = ref.read(audioProjectProvider);
    if (project == null) return;
    final pos = ref.read(positionProvider).value ?? Duration.zero;
    LivePreviewService.instance
      ..configure(sourcePath: project.filePath)
      ..schedulePreview(effects: project.enabledEffects, fromPosition: pos);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effect = _effectForType();
    final enabled = effect.enabled;
    final color = _colorForType(type);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? color.withAlpha(80) : AppColors.border,
          width: enabled ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header row: name + toggle
          _CardHeader(
            type: type,
            enabled: enabled,
            color: color,
            onToggle: () => _toggle(ref),
          ),
          // Sliders — always shown, dimmed when disabled
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Opacity(
              opacity: enabled ? 1.0 : 0.35,
              child: _buildControls(ref, effect),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(WidgetRef ref, AudioEffect effect) {
    final p = effect.parameters;

    switch (type) {
      case EffectType.equalizer:
        return Column(children: [
          EffectSlider(
            label: AppStrings.paramBass,
            value: p['bass'] ?? 0.0,
            min: -12, max: 12, divisions: 24,
            valueFormatter: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} dB',
            onChanged: (v) => _updateParam(ref, 'bass', v),
          ),
          EffectSlider(
            label: AppStrings.paramMid,
            value: p['mid'] ?? 0.0,
            min: -12, max: 12, divisions: 24,
            valueFormatter: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} dB',
            onChanged: (v) => _updateParam(ref, 'mid', v),
          ),
          EffectSlider(
            label: AppStrings.paramTreble,
            value: p['treble'] ?? 0.0,
            min: -12, max: 12, divisions: 24,
            valueFormatter: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} dB',
            onChanged: (v) => _updateParam(ref, 'treble', v),
          ),
        ]);

      case EffectType.reverb:
        return Column(children: [
          EffectSlider(label: AppStrings.paramRoomSize, value: p['roomSize'] ?? 0.5, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'roomSize', v)),
          EffectSlider(label: AppStrings.paramWetness, value: p['wetness'] ?? 0.3, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'wetness', v)),
          EffectSlider(label: AppStrings.paramFeedback, value: p['feedback'] ?? 0.4, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'feedback', v)),
        ]);

      case EffectType.delay:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDelayTime, value: p['delayMs'] ?? 500, min: 50, max: 2000, divisions: 195, valueFormatter: (v) => '${v.toInt()} ms', onChanged: (v) => _updateParam(ref, 'delayMs', v)),
          EffectSlider(label: AppStrings.paramFeedback, value: p['feedback'] ?? 0.5, min: 0.0, max: 0.95, onChanged: (v) => _updateParam(ref, 'feedback', v)),
          EffectSlider(label: AppStrings.paramWetness, value: p['wetness'] ?? 0.4, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'wetness', v)),
        ]);

      case EffectType.distortion:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDrive, value: p['drive'] ?? 0.3, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'drive', v)),
          EffectSlider(label: AppStrings.paramWetness, value: p['wetness'] ?? 0.5, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'wetness', v)),
        ]);

      case EffectType.chorus:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDepth, value: p['depth'] ?? 0.5, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'depth', v)),
          EffectSlider(label: AppStrings.paramRate, value: p['rate'] ?? 1.0, min: 0.1, max: 5.0, valueFormatter: (v) => '${v.toStringAsFixed(1)} Hz', onChanged: (v) => _updateParam(ref, 'rate', v)),
          EffectSlider(label: AppStrings.paramWetness, value: p['wetness'] ?? 0.5, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'wetness', v)),
        ]);

      case EffectType.flanger:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDepth, value: p['depth'] ?? 0.5, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'depth', v)),
          EffectSlider(label: AppStrings.paramRate, value: p['rate'] ?? 0.5, min: 0.1, max: 5.0, valueFormatter: (v) => '${v.toStringAsFixed(1)} Hz', onChanged: (v) => _updateParam(ref, 'rate', v)),
          EffectSlider(label: AppStrings.paramFeedback, value: p['feedback'] ?? 0.5, min: 0.0, max: 0.95, onChanged: (v) => _updateParam(ref, 'feedback', v)),
        ]);

      case EffectType.phaser:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDepth, value: p['depth'] ?? 0.5, min: 0.0, max: 1.0, onChanged: (v) => _updateParam(ref, 'depth', v)),
          EffectSlider(label: AppStrings.paramRate, value: p['rate'] ?? 0.5, min: 0.1, max: 4.0, valueFormatter: (v) => '${v.toStringAsFixed(1)} Hz', onChanged: (v) => _updateParam(ref, 'rate', v)),
        ]);

      case EffectType.bitcrusher:
        return EffectSlider(label: AppStrings.paramBits, value: p['bits'] ?? 8.0, min: 1.0, max: 16.0, divisions: 15, valueFormatter: (v) => '${v.toInt()} bits', onChanged: (v) => _updateParam(ref, 'bits', v));

      case EffectType.lowPass:
        return EffectSlider(label: AppStrings.paramCutoff, value: p['cutoff'] ?? 3000.0, min: 200, max: 20000, valueFormatter: (v) => '${v.toInt()} Hz', onChanged: (v) => _updateParam(ref, 'cutoff', v));

      case EffectType.highPass:
        return EffectSlider(label: AppStrings.paramCutoff, value: p['cutoff'] ?? 200.0, min: 20, max: 8000, valueFormatter: (v) => '${v.toInt()} Hz', onChanged: (v) => _updateParam(ref, 'cutoff', v));

      case EffectType.normalize:
        return EffectSlider(label: 'Target LUFS', value: p['targetLufs'] ?? -14.0, min: -30, max: -6, divisions: 24, valueFormatter: (v) => '${v.toStringAsFixed(1)} LUFS', onChanged: (v) => _updateParam(ref, 'targetLufs', v));

      case EffectType.reverse:
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Text(
            'Inverte o áudio no arquivo exportado.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        );

      case EffectType.fadeIn:
        return EffectSlider(label: AppStrings.paramDuration, value: p['durationSec'] ?? 2.0, min: 0.1, max: 10.0, valueFormatter: (v) => '${v.toStringAsFixed(1)}s', onChanged: (v) => _updateParam(ref, 'durationSec', v));

      case EffectType.fadeOut:
        return EffectSlider(label: AppStrings.paramDuration, value: p['durationSec'] ?? 2.0, min: 0.1, max: 10.0, valueFormatter: (v) => '${v.toStringAsFixed(1)}s', onChanged: (v) => _updateParam(ref, 'durationSec', v));

      case EffectType.compressor:
        return Column(children: [
          EffectSlider(label: AppStrings.paramThreshold, value: p['threshold'] ?? -20.0, min: -60, max: 0, divisions: 60, valueFormatter: (v) => '${v.toStringAsFixed(1)} dB', onChanged: (v) => _updateParam(ref, 'threshold', v)),
          EffectSlider(label: AppStrings.paramRatio, value: p['ratio'] ?? 4.0, min: 1.0, max: 20.0, valueFormatter: (v) => '${v.toStringAsFixed(1)}:1', onChanged: (v) => _updateParam(ref, 'ratio', v)),
        ]);
    }
  }
}

// ─── Card header with name + color + toggle

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.type,
    required this.enabled,
    required this.color,
    required this.onToggle,
  });
  final EffectType type;
  final bool enabled;
  final Color color;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: enabled ? color.withAlpha(30) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                _iconForType(type),
                color: enabled ? color : AppColors.textDisabled,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _nameForType(type),
                style: TextStyle(
                  color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            // Toggle chip
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: enabled ? color.withAlpha(25) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: enabled ? color.withAlpha(100) : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: enabled ? color : AppColors.textDisabled,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    enabled ? AppStrings.effectEnabled : 'OFF',
                    style: TextStyle(
                      color: enabled ? color : AppColors.textDisabled,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers

Color _colorForType(EffectType t) {
  switch (t) {
    case EffectType.reverb: return const Color(0xFF7C4DFF);
    case EffectType.delay: return const Color(0xFF00E5FF);
    case EffectType.equalizer: return const Color(0xFFFF6D00);
    case EffectType.distortion: return const Color(0xFFFF5252);
    case EffectType.chorus: return const Color(0xFF4CAF50);
    case EffectType.flanger: return const Color(0xFFE91E63);
    case EffectType.phaser: return const Color(0xFF9C27B0);
    case EffectType.bitcrusher: return const Color(0xFFFF9800);
    case EffectType.lowPass: return const Color(0xFF03A9F4);
    case EffectType.highPass: return const Color(0xFF8BC34A);
    case EffectType.normalize: return const Color(0xFF00BCD4);
    case EffectType.reverse: return const Color(0xFFFF5722);
    case EffectType.fadeIn: return const Color(0xFF795548);
    case EffectType.fadeOut: return const Color(0xFF607D8B);
    case EffectType.compressor: return const Color(0xFFFFC107);
  }
}

IconData _iconForType(EffectType t) {
  switch (t) {
    case EffectType.reverb: return Icons.waves_rounded;
    case EffectType.delay: return Icons.timer_rounded;
    case EffectType.equalizer: return Icons.equalizer_rounded;
    case EffectType.distortion: return Icons.electric_bolt_rounded;
    case EffectType.chorus: return Icons.music_note_rounded;
    case EffectType.flanger: return Icons.rotate_left_rounded;
    case EffectType.phaser: return Icons.rotate_right_rounded;
    case EffectType.bitcrusher: return Icons.broken_image_rounded;
    case EffectType.lowPass: return Icons.filter_alt_rounded;
    case EffectType.highPass: return Icons.filter_list_rounded;
    case EffectType.normalize: return Icons.auto_fix_high_rounded;
    case EffectType.reverse: return Icons.fast_rewind_rounded;
    case EffectType.fadeIn: return Icons.trending_up_rounded;
    case EffectType.fadeOut: return Icons.trending_down_rounded;
    case EffectType.compressor: return Icons.compress;
  }
}

String _nameForType(EffectType t) {
  switch (t) {
    case EffectType.reverb: return AppStrings.effectReverb;
    case EffectType.delay: return AppStrings.effectDelay;
    case EffectType.equalizer: return AppStrings.effectEqualizer;
    case EffectType.distortion: return AppStrings.effectDistortion;
    case EffectType.chorus: return AppStrings.effectChorus;
    case EffectType.flanger: return AppStrings.effectFlanger;
    case EffectType.phaser: return AppStrings.effectPhaser;
    case EffectType.bitcrusher: return AppStrings.effectBitcrusher;
    case EffectType.lowPass: return AppStrings.effectLowPass;
    case EffectType.highPass: return AppStrings.effectHighPass;
    case EffectType.normalize: return AppStrings.effectNormalize;
    case EffectType.reverse: return AppStrings.effectReverse;
    case EffectType.fadeIn: return AppStrings.effectFadeIn;
    case EffectType.fadeOut: return AppStrings.effectFadeOut;
    case EffectType.compressor: return AppStrings.effectCompressor;
  }
}
