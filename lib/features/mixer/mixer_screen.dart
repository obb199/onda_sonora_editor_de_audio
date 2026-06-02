import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/mixer_service.dart';
import '../../l10n/app_strings.dart';
import '../../models/audio_track.dart';
import '../../providers/mixer_provider.dart';
import '../../providers/recorder_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/effect_slider.dart';
import '../recorder/recorder_screen.dart';

class MixerScreen extends ConsumerWidget {
  const MixerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    final mixer = ref.watch(mixerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.mixer),
        actions: [
          if (mixer.tracks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.merge_type_rounded, color: AppColors.primary),
              tooltip: AppStrings.mixAndExport,
              onPressed: () => _mixAndExport(context, ref),
            ),
        ],
      ),
      body: SafeArea(
        child: mixer.tracks.isEmpty
            ? _EmptyMixer()
            : Column(
                children: [
                  _MasterVolumeBar(volume: mixer.masterVolume),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: mixer.tracks.length,
                      itemBuilder: (_, i) => _TrackCard(track: mixer.tracks[i]),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'record',
            backgroundColor: AppColors.accentRecord,
            tooltip: AppStrings.recordNewTrack,
            onPressed: () => _goToRecorder(context, ref),
            child: const Icon(Icons.mic_rounded, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'import',
            backgroundColor: AppColors.primary,
            tooltip: AppStrings.importAsTrack,
            onPressed: () => _importTrack(context, ref),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _importTrack(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    ref.read(mixerProvider.notifier).addTrack(file.path!, file.name);
  }

  void _goToRecorder(BuildContext context, WidgetRef ref) {
    ref.read(recorderProvider.notifier).reset();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _RecorderForMixer()),
    );
  }

  Future<void> _mixAndExport(BuildContext context, WidgetRef ref) async {
    final mixer = ref.read(mixerProvider);
    final active = mixer.activeTracks;
    if (active.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppStrings.noTracksYet)));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Text(AppStrings.mixProcessing),
        ]),
      ),
    );

    try {
      final path = await MixerService.instance.mixTracks(tracks: active);
      if (context.mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppStrings.exportSuccess)));
        await Share.shareXFiles([XFile(path)]);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppStrings.exportError}: $e')));
      }
    }
  }
}

// ─── Master volume bar

class _MasterVolumeBar extends ConsumerWidget {
  const _MasterVolumeBar({required this.volume});
  final double volume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.speaker_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(AppStrings.volume,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Slider(
              value: volume.clamp(0.0, 1.0),
              onChanged: (v) =>
                  ref.read(mixerProvider.notifier).updateMasterVolume(v),
            ),
          ),
          Text('${(volume * 100).toInt()}%',
              style: const TextStyle(color: AppColors.primary, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Empty state

class _EmptyMixer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.queue_music_rounded,
                color: AppColors.textDisabled, size: 72),
            const SizedBox(height: 16),
            Text(AppStrings.noTracksYet,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ─── Individual track card

class _TrackCard extends ConsumerStatefulWidget {
  const _TrackCard({required this.track});
  final AudioTrack track;

  @override
  ConsumerState<_TrackCard> createState() => _TrackCardState();
}

class _TrackCardState extends ConsumerState<_TrackCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.track;
    final notifier = ref.read(mixerProvider.notifier);
    final hasSolo = ref.watch(mixerProvider).tracks.any((tr) => tr.isSolo);
    final dimmed = hasSolo && !t.isSolo;

    return Opacity(
      opacity: dimmed ? 0.4 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: t.isMuted
                    ? AppColors.border
                    : AppColors.primary.withAlpha(50),
              ),
            ),
            child: Column(
              children: [
                // Header row
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.audiotrack_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text(t.name,
                      style: TextStyle(
                          color: t.isMuted
                              ? AppColors.textDisabled
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mute
                      _IconToggle(
                        icon: t.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        active: t.isMuted,
                        activeColor: AppColors.warning,
                        onTap: () => notifier.toggleMute(t.id),
                      ),
                      // Solo
                      _IconToggle(
                        icon: Icons.headphones_rounded,
                        active: t.isSolo,
                        activeColor: AppColors.secondary,
                        onTap: () => notifier.toggleSolo(t.id),
                      ),
                      // Expand
                      IconButton(
                        icon: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _expanded = !_expanded),
                      ),
                      // Remove
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.errorColor, size: 20),
                        onPressed: () => notifier.removeTrack(t.id),
                      ),
                    ],
                  ),
                ),
                if (_expanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        EffectSlider(
                          label: AppStrings.volume,
                          value: t.volume,
                          min: 0.0,
                          max: 1.5,
                          enabled: !t.isMuted,
                          valueFormatter: (v) => '${(v * 100).toInt()}%',
                          onChanged: (v) => notifier.updateVolume(t.id, v),
                        ),
                        EffectSlider(
                          label: AppStrings.pan,
                          value: t.pan,
                          min: -1.0,
                          max: 1.0,
                          divisions: 20,
                          valueFormatter: (v) => v == 0
                              ? 'C'
                              : v < 0
                                  ? 'L${(-v * 100).toInt()}'
                                  : 'R${(v * 100).toInt()}',
                          onChanged: (v) => notifier.updatePan(t.id, v),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconToggle extends StatelessWidget {
  const _IconToggle({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon,
          color: active ? activeColor : AppColors.textDisabled, size: 20),
      onPressed: onTap,
    );
  }
}

// ─── Recorder flow that returns file to mixer

class _RecorderForMixer extends ConsumerWidget {
  const _RecorderForMixer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recorderProvider);

    // When recording is done, offer adding to mixer
    if (state.isDone && state.filePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _showAddDialog(context, ref, state.filePath!);
      });
    }

    return const RecorderScreen();
  }

  Future<void> _showAddDialog(
      BuildContext context, WidgetRef ref, String path) async {
    final name = path.split('/').last;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.addTrack),
        content: Text('Adicionar "$name" ao mixer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.addTrack),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(mixerProvider.notifier).addTrack(path, name);
      ref.read(recorderProvider.notifier).reset();
      Navigator.pop(context);
    }
  }
}
