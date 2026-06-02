import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/ffmpeg_service.dart';
import '../../models/audio_effect.dart';
import '../../l10n/app_strings.dart';
import '../../providers/audio_provider.dart';
import '../../theme/app_theme.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _format = ExportFormat.mp3;
  ExportQuality _quality = ExportQuality.high;
  bool _applyEffects = true;
  bool _isProcessing = false;
  String? _outputPath;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(audioProjectProvider);
    final hasEffects = project?.effects.isNotEmpty ?? false;
    final enabledEffects = project?.enabledEffects ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.exportTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project != null) ...[
                _InfoCard(fileName: project.fileName, duration: project.duration),
                const SizedBox(height: 20),
              ],
              _SectionLabel(AppStrings.exportFormat),
              const SizedBox(height: 8),
              _FormatSelector(value: _format, onChanged: (v) => setState(() => _format = v)),
              const SizedBox(height: 20),
              _SectionLabel(AppStrings.exportQuality),
              const SizedBox(height: 8),
              _QualitySelector(value: _quality, onChanged: (v) => setState(() => _quality = v)),
              const SizedBox(height: 20),
              if (hasEffects) ...[
                _EffectsToggle(
                  value: _applyEffects,
                  effectCount: enabledEffects.length,
                  onChanged: (v) => setState(() => _applyEffects = v),
                ),
                const SizedBox(height: 20),
              ],
              if (_errorMessage != null)
                _ErrorBanner(message: _errorMessage!),
              if (_outputPath != null && !_isProcessing)
                _SuccessBanner(
                  outputPath: _outputPath!,
                  onShare: _share,
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_rounded),
                  label: Text(_isProcessing ? AppStrings.exportProcessing : AppStrings.export),
                  onPressed: _isProcessing ? null : _export,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _export() async {
    final project = ref.read(audioProjectProvider);
    if (project == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _outputPath = null;
    });

    try {
      final effects = _applyEffects ? project.enabledEffects : <AudioEffect>[];
      final path = await FfmpegService.instance.applyAndExport(
        inputPath: project.filePath,
        effects: effects,
        format: _format,
        quality: _quality,
      );
      setState(() => _outputPath = path);
    } catch (e) {
      setState(() => _errorMessage = '${AppStrings.exportError}: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _share() async {
    if (_outputPath == null) return;
    await Share.shareXFiles([XFile(_outputPath!)]);
  }
}

// ─── Sub-widgets

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.fileName, required this.duration});
  final String fileName;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.audio_file_rounded, color: AppColors.primary, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text('$m:$s', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.value, required this.onChanged});
  final ExportFormat value;
  final ValueChanged<ExportFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    final formats = [
      (ExportFormat.mp3, 'MP3', Icons.audio_file_rounded),
      (ExportFormat.wav, 'WAV', Icons.audiotrack_rounded),
      (ExportFormat.flac, 'FLAC', Icons.music_note_rounded),
    ];
    return Row(
      children: formats.map((f) {
        final selected = value == f.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _SelectChip(
              label: f.$2,
              icon: f.$3,
              selected: selected,
              onTap: () => onChanged(f.$1),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QualitySelector extends StatelessWidget {
  const _QualitySelector({required this.value, required this.onChanged});
  final ExportQuality value;
  final ValueChanged<ExportQuality> onChanged;

  @override
  Widget build(BuildContext context) {
    final qualities = [
      (ExportQuality.high, AppStrings.exportQualityHigh),
      (ExportQuality.medium, AppStrings.exportQualityMedium),
      (ExportQuality.low, AppStrings.exportQualityLow),
    ];
    return Material(
      color: Colors.transparent,
      child: Column(
        children: qualities.map((q) {
          final selected = value == q.$1;
          return ListTile(
            onTap: () => onChanged(q.$1),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.textDisabled,
            ),
            title: Text(q.$2,
                style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary)),
          );
        }).toList(),
      ),
    );
  }
}

class _EffectsToggle extends StatelessWidget {
  const _EffectsToggle({
    required this.value,
    required this.effectCount,
    required this.onChanged,
  });
  final bool value;
  final int effectCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.applyEffects, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text('$effectCount ${AppStrings.effects.toLowerCase()} ${AppStrings.effectEnabled.toLowerCase()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withAlpha(30) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorColor.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorColor),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.errorColor, fontSize: 13))),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.outputPath, required this.onShare});
  final String outputPath;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final name = outputPath.split('/').last;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.success),
              const SizedBox(width: 8),
              Text(AppStrings.exportSuccess, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.share_rounded),
            label: Text(AppStrings.share),
            onPressed: onShare,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: const BorderSide(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
