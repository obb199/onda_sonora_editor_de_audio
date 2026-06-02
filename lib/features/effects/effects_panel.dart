import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../models/audio_effect.dart';
import '../../providers/audio_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/effect_slider.dart';

class EffectsPanel extends ConsumerWidget {
  const EffectsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(audioProjectProvider);
    if (project == null) return const SizedBox.shrink();

    final effects = project.effects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelHeader(effectCount: effects.length),
        if (effects.isEmpty)
          _EmptyEffects()
        else
          ...effects.asMap().entries.map(
                (entry) => _EffectCard(
                  index: entry.key,
                  effect: entry.value,
                ),
              ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PanelHeader extends ConsumerWidget {
  const _PanelHeader({required this.effectCount});
  final int effectCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
      child: Row(
        children: [
          Text(
            AppStrings.effectsPanel,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (effectCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$effectCount',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
            tooltip: AppStrings.addEffect,
            onPressed: () => _showEffectPicker(context, ref),
          ),
        ],
      ),
    );
  }

  void _showEffectPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _EffectPickerSheet(),
    );
  }
}

class _EmptyEffects extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.textDisabled, size: 48),
            const SizedBox(height: 12),
            Text(
              AppStrings.noEffectsActive,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _EffectCard extends ConsumerStatefulWidget {
  const _EffectCard({required this.index, required this.effect});
  final int index;
  final AudioEffect effect;

  @override
  ConsumerState<_EffectCard> createState() => _EffectCardState();
}

class _EffectCardState extends ConsumerState<_EffectCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final effect = widget.effect;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: effect.enabled ? AppColors.primary.withAlpha(60) : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              _EffectCardHeader(
                effect: effect,
                index: widget.index,
                expanded: _expanded,
                onToggle: () => setState(() => _expanded = !_expanded),
              ),
              if (_expanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _EffectControls(index: widget.index, effect: effect),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EffectCardHeader extends ConsumerWidget {
  const _EffectCardHeader({
    required this.effect,
    required this.index,
    required this.expanded,
    required this.onToggle,
  });
  final AudioEffect effect;
  final int index;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _colorForType(effect.type).withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          _iconForType(effect.type),
          color: _colorForType(effect.type),
          size: 20,
        ),
      ),
      title: Text(
        _nameForType(effect.type),
        style: TextStyle(
          color: effect.enabled ? AppColors.textPrimary : AppColors.textDisabled,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: effect.enabled,
            onChanged: (_) {
              ref
                  .read(audioProjectProvider.notifier)
                  .updateEffect(index, effect.toggled());
            },
          ),
          IconButton(
            icon: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.textSecondary,
            ),
            onPressed: onToggle,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.errorColor, size: 20),
            onPressed: () {
              ref.read(audioProjectProvider.notifier).removeEffect(index);
            },
          ),
        ],
      ),
    );
  }
}

class _EffectControls extends ConsumerWidget {
  const _EffectControls({required this.index, required this.effect});
  final int index;
  final AudioEffect effect;

  void _update(WidgetRef ref, String key, double value) {
    ref
        .read(audioProjectProvider.notifier)
        .updateEffect(index, effect.withParam(key, value));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = effect.parameters;
    final enabled = effect.enabled;

    switch (effect.type) {
      case EffectType.reverb:
        return Column(children: [
          EffectSlider(label: AppStrings.paramRoomSize, value: p['roomSize'] ?? 0.5, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'roomSize', v)),
          EffectSlider(label: AppStrings.paramWetness, value: p['wetness'] ?? 0.3, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'wetness', v)),
          EffectSlider(label: AppStrings.paramFeedback, value: p['feedback'] ?? 0.4, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'feedback', v)),
        ]);

      case EffectType.delay:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDelayTime, value: p['delayMs'] ?? 500, min: 50, max: 2000, divisions: 195, enabled: enabled, valueFormatter: (v) => '${v.toInt()} ms', onChanged: (v) => _update(ref, 'delayMs', v)),
          EffectSlider(label: AppStrings.paramFeedback, value: p['feedback'] ?? 0.5, min: 0.0, max: 0.95, enabled: enabled, onChanged: (v) => _update(ref, 'feedback', v)),
          EffectSlider(label: AppStrings.paramWetness, value: p['wetness'] ?? 0.4, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'wetness', v)),
        ]);

      case EffectType.equalizer:
        return Column(children: [
          EffectSlider(label: AppStrings.paramBass, value: p['bass'] ?? 0.0, min: -12, max: 12, divisions: 24, enabled: enabled, valueFormatter: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} dB', onChanged: (v) => _update(ref, 'bass', v)),
          EffectSlider(label: AppStrings.paramMid, value: p['mid'] ?? 0.0, min: -12, max: 12, divisions: 24, enabled: enabled, valueFormatter: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} dB', onChanged: (v) => _update(ref, 'mid', v)),
          EffectSlider(label: AppStrings.paramTreble, value: p['treble'] ?? 0.0, min: -12, max: 12, divisions: 24, enabled: enabled, valueFormatter: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} dB', onChanged: (v) => _update(ref, 'treble', v)),
        ]);

      case EffectType.distortion:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDrive, value: p['drive'] ?? 0.3, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'drive', v)),
          EffectSlider(label: AppStrings.paramWetness, value: p['wetness'] ?? 0.5, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'wetness', v)),
        ]);

      case EffectType.chorus:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDepth, value: p['depth'] ?? 0.5, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'depth', v)),
          EffectSlider(label: AppStrings.paramRate, value: p['rate'] ?? 1.0, min: 0.1, max: 5.0, enabled: enabled, valueFormatter: (v) => '${v.toStringAsFixed(1)} Hz', onChanged: (v) => _update(ref, 'rate', v)),
          EffectSlider(label: AppStrings.paramWetness, value: p['wetness'] ?? 0.5, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'wetness', v)),
        ]);

      case EffectType.flanger:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDepth, value: p['depth'] ?? 0.5, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'depth', v)),
          EffectSlider(label: AppStrings.paramRate, value: p['rate'] ?? 0.5, min: 0.1, max: 5.0, enabled: enabled, valueFormatter: (v) => '${v.toStringAsFixed(1)} Hz', onChanged: (v) => _update(ref, 'rate', v)),
          EffectSlider(label: AppStrings.paramFeedback, value: p['feedback'] ?? 0.5, min: 0.0, max: 0.95, enabled: enabled, onChanged: (v) => _update(ref, 'feedback', v)),
        ]);

      case EffectType.phaser:
        return Column(children: [
          EffectSlider(label: AppStrings.paramDepth, value: p['depth'] ?? 0.5, min: 0.0, max: 1.0, enabled: enabled, onChanged: (v) => _update(ref, 'depth', v)),
          EffectSlider(label: AppStrings.paramRate, value: p['rate'] ?? 0.5, min: 0.1, max: 4.0, enabled: enabled, valueFormatter: (v) => '${v.toStringAsFixed(1)} Hz', onChanged: (v) => _update(ref, 'rate', v)),
        ]);

      case EffectType.bitcrusher:
        return EffectSlider(label: AppStrings.paramBits, value: p['bits'] ?? 8.0, min: 1.0, max: 16.0, divisions: 15, enabled: enabled, valueFormatter: (v) => '${v.toInt()} bits', onChanged: (v) => _update(ref, 'bits', v));

      case EffectType.lowPass:
        return EffectSlider(label: AppStrings.paramCutoff, value: p['cutoff'] ?? 3000.0, min: 200, max: 20000, enabled: enabled, valueFormatter: (v) => '${v.toInt()} Hz', onChanged: (v) => _update(ref, 'cutoff', v));

      case EffectType.highPass:
        return EffectSlider(label: AppStrings.paramCutoff, value: p['cutoff'] ?? 200.0, min: 20, max: 8000, enabled: enabled, valueFormatter: (v) => '${v.toInt()} Hz', onChanged: (v) => _update(ref, 'cutoff', v));

      case EffectType.normalize:
        return EffectSlider(label: '${AppStrings.paramGain} (LUFS)', value: p['targetLufs'] ?? -14.0, min: -30, max: -6, divisions: 24, enabled: enabled, valueFormatter: (v) => '${v.toStringAsFixed(1)} LUFS', onChanged: (v) => _update(ref, 'targetLufs', v));

      case EffectType.reverse:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Inverte a faixa no processamento final.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        );

      case EffectType.fadeIn:
        return EffectSlider(label: AppStrings.paramDuration, value: p['durationSec'] ?? 2.0, min: 0.1, max: 10.0, enabled: enabled, valueFormatter: (v) => '${v.toStringAsFixed(1)}s', onChanged: (v) => _update(ref, 'durationSec', v));

      case EffectType.fadeOut:
        return EffectSlider(label: AppStrings.paramDuration, value: p['durationSec'] ?? 2.0, min: 0.1, max: 10.0, enabled: enabled, valueFormatter: (v) => '${v.toStringAsFixed(1)}s', onChanged: (v) => _update(ref, 'durationSec', v));

      case EffectType.compressor:
        return Column(children: [
          EffectSlider(label: AppStrings.paramThreshold, value: p['threshold'] ?? -20.0, min: -60, max: 0, divisions: 60, enabled: enabled, valueFormatter: (v) => '${v.toStringAsFixed(1)} dB', onChanged: (v) => _update(ref, 'threshold', v)),
          EffectSlider(label: AppStrings.paramRatio, value: p['ratio'] ?? 4.0, min: 1.0, max: 20.0, enabled: enabled, valueFormatter: (v) => '${v.toStringAsFixed(1)}:1', onChanged: (v) => _update(ref, 'ratio', v)),
        ]);
    }
  }
}

// ─── Effect picker bottom sheet

class _EffectPickerSheet extends ConsumerWidget {
  const _EffectPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = EffectType.values;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppStrings.addEffect,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: available.length,
              itemBuilder: (_, i) {
                final type = available[i];
                return ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: _colorForType(type).withAlpha(30), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_iconForType(type), color: _colorForType(type), size: 22),
                  ),
                  title: Text(_nameForType(type), style: const TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    ref.read(audioProjectProvider.notifier).addEffect(AudioEffect.defaultFor(type));
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          // Extra padding for Android navigation bar
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
        ],
      ),
    );
  }
}

// ─── Helper mappers

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
    case EffectType.normalize: return Icons.compress_rounded;
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
