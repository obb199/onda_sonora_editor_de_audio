import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/live_preview_service.dart';
import '../../l10n/app_strings.dart';
import '../../models/audio_track.dart';
import '../../models/mixer_project.dart';
import '../../providers/audio_provider.dart';
import '../../providers/editor_provider.dart';
import '../../providers/recorder_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/frequency_visualizer.dart';
import '../../widgets/waveform_painter.dart';
import '../effects/effects_panel.dart';
import '../export/export_screen.dart';
import '../recorder/recorder_screen.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Configure live preview whenever project loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final project = ref.read(audioProjectProvider);
      if (project != null) {
        LivePreviewService.instance.configure(sourcePath: project.filePath);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    LivePreviewService.instance.stopPreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(audioProjectProvider);
    if (project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.value?.playing ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(project.fileName, isPlaying),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            _WaveformSection(),
            _LiveControlsSection(),
            const Divider(height: 1, color: AppColors.border),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const SingleChildScrollView(child: EffectsPanel()),
                  const SingleChildScrollView(child: _LoopMarkersPanel()),
                  _PresetsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(String fileName, bool isPlaying) {
    final editorUi = ref.watch(editorUiProvider);
    final project = ref.watch(audioProjectProvider);

    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
        onPressed: () => _confirmClose(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedAppLogo(size: 28, isAnimating: isPlaying),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              fileName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Undo
        IconButton(
          icon: const Icon(Icons.undo_rounded, color: AppColors.textSecondary),
          tooltip: AppStrings.undo,
          onPressed: project?.canUndo == true
              ? () => ref.read(audioProjectProvider.notifier).undo()
              : null,
        ),
        // Redo
        IconButton(
          icon: const Icon(Icons.redo_rounded, color: AppColors.textSecondary),
          tooltip: AppStrings.redo,
          onPressed: project?.canRedo == true
              ? () => ref.read(audioProjectProvider.notifier).redo()
              : null,
        ),
        // Live preview toggle
        IconButton(
          icon: Icon(
            editorUi.livePreviewEnabled ? Icons.preview_rounded : Icons.preview_outlined,
            color: editorUi.livePreviewEnabled ? AppColors.secondary : AppColors.textDisabled,
          ),
          tooltip: AppStrings.liveEffectPreview,
          onPressed: () =>
              ref.read(editorUiProvider.notifier).toggleLivePreview(),
        ),
        // Overdub
        IconButton(
          icon: const Icon(Icons.fiber_manual_record_rounded, color: AppColors.accentRecord),
          tooltip: AppStrings.overdubTrack,
          onPressed: () => _startOverdub(context),
        ),
        // Export
        IconButton(
          icon: const Icon(Icons.upload_rounded, color: AppColors.primary),
          tooltip: AppStrings.export,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExportScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      dividerColor: Colors.transparent,
      tabs: [
        Tab(text: AppStrings.effects),
        Tab(text: AppStrings.loop),
        Tab(text: AppStrings.presets),
      ],
    );
  }

  Future<void> _startOverdub(BuildContext context) async {
    // Pause playback, navigate to recorder, return result as new file
    await ref.read(audioPlayerServiceProvider).pause();
    ref.read(recorderProvider.notifier).reset();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RecorderScreen()),
    );
  }

  Future<void> _confirmClose(BuildContext context) async {
    final project = ref.read(audioProjectProvider);
    final hasEffects = project?.effects.isNotEmpty ?? false;

    if (!hasEffects) {
      Navigator.of(context).pop();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.close),
        content: const Text('Fechar sem exportar? As alterações não serão salvas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.close),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(audioPlayerServiceProvider).stop();
      ref.read(editorUiProvider.notifier).reset();
      Navigator.of(context).pop();
    }
  }
}

// ─── Waveform + playback controls + loop overlay

class _WaveformSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(audioProjectProvider);
    if (project == null) return const SizedBox.shrink();

    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = project.duration;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final samplesAsync = ref.watch(waveformSamplesProvider(project.filePath));
    final samples = samplesAsync.value ?? [];
    final editorUi = ref.watch(editorUiProvider);
    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.value?.playing ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              WaveformView(
                samples: samples,
                progress: progress,
                height: 80,
                loopRegion: editorUi.loopRegion,
                markers: editorUi.showMarkers ? editorUi.markers : [],
                totalDurationMs: duration.inMilliseconds,
                onSeek: (p) {
                  final target = Duration(
                    milliseconds: (p * duration.inMilliseconds).toInt(),
                  );
                  ref.read(audioPlayerServiceProvider).seek(target);
                },
              ),
              // Loop toggle pill
              Positioned(
                top: 4,
                right: 4,
                child: _LoopPill(isLooping: editorUi.isLooping),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(position),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              if (editorUi.loopRegion != null)
                Text(
                  '⟳ ${_fmt(editorUi.loopRegion!.startDuration)} – ${_fmt(editorUi.loopRegion!.endDuration)}',
                  style: const TextStyle(color: AppColors.secondary, fontSize: 11),
                ),
              Text(_fmt(duration),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          FrequencyVisualizer(isActive: isPlaying, height: 48),
          const SizedBox(height: 8),
          _PlaybackControls(),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _LoopPill extends ConsumerWidget {
  const _LoopPill({required this.isLooping});
  final bool isLooping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(editorUiProvider.notifier).toggleLoop();
        final player = ref.read(audioPlayerServiceProvider);
        player.setLoopMode(
            ref.read(editorUiProvider).isLooping ? LoopMode.one : LoopMode.off);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isLooping
              ? AppColors.secondary.withAlpha(40)
              : AppColors.surface.withAlpha(200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isLooping ? AppColors.secondary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.loop_rounded,
                size: 12,
                color: isLooping ? AppColors.secondary : AppColors.textDisabled),
            const SizedBox(width: 4),
            Text(
              AppStrings.loop,
              style: TextStyle(
                color: isLooping ? AppColors.secondary : AppColors.textDisabled,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaybackControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.value?.playing ?? false;
    final isLoading =
        playerState.value?.processingState == ProcessingState.loading ||
            playerState.value?.processingState == ProcessingState.buffering;

    final player = ref.read(audioPlayerServiceProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          color: AppColors.textSecondary,
          iconSize: 28,
          onPressed: () => player.seek(Duration.zero),
        ),
        const SizedBox(width: 8),
        _PlayPauseButton(
          isPlaying: isPlaying,
          isLoading: isLoading,
          onTap: () => isPlaying ? player.pause() : player.play(),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.stop_rounded),
          color: AppColors.textSecondary,
          iconSize: 28,
          onPressed: () => player.stop(),
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
  });
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
      ),
    );
  }
}

// ─── Live controls (speed, pitch, volume) with live-preview trigger

class _LiveControlsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(audioProjectProvider);
    if (project == null) return const SizedBox.shrink();

    final livePreviewEnabled = ref.watch(editorUiProvider).livePreviewEnabled;
    final notifier = ref.read(audioProjectProvider.notifier);
    final livePreview = LivePreviewService.instance;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.secondary, size: 16),
                const SizedBox(width: 6),
                Text(AppStrings.livePreview,
                    style: const TextStyle(
                        color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                // Live preview indicator (only shown when enabled)
                if (livePreviewEnabled)
                StreamBuilder<LivePreviewState>(
                  stream: livePreview.stateStream,
                  builder: (_, snap) {
                    final state = snap.data ?? LivePreviewState.idle;
                    if (state == LivePreviewState.rendering) {
                      return Row(children: [
                        const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                                color: AppColors.secondary, strokeWidth: 2)),
                        const SizedBox(width: 6),
                        Text(AppStrings.previewRendering,
                            style: const TextStyle(
                                color: AppColors.secondary, fontSize: 10)),
                      ]);
                    }
                    if (state == LivePreviewState.playing) {
                      return Row(children: [
                        const Icon(Icons.graphic_eq_rounded,
                            color: AppColors.secondary, size: 14),
                        const SizedBox(width: 4),
                        Text(AppStrings.previewReady,
                            style: const TextStyle(
                                color: AppColors.secondary, fontSize: 10)),
                      ]);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _LiveControl(
                    icon: Icons.speed_rounded,
                    label: AppStrings.speed,
                    value: project.speed,
                    min: 0.25,
                    max: 4.0,
                    displayValue: '${project.speed.toStringAsFixed(2)}x',
                    onChanged: (v) => notifier.setSpeed(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LiveControl(
                    icon: Icons.music_note_rounded,
                    label: AppStrings.pitch,
                    value: project.pitch,
                    min: 0.5,
                    max: 2.0,
                    displayValue: '${project.pitch.toStringAsFixed(2)}x',
                    onChanged: (v) => notifier.setPitch(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LiveControl(
                    icon: Icons.volume_up_rounded,
                    label: AppStrings.volume,
                    value: project.volume,
                    min: 0.0,
                    max: 1.0,
                    displayValue: '${(project.volume * 100).toInt()}%',
                    onChanged: (v) => notifier.setVolume(v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveControl extends StatelessWidget {
  const _LiveControl({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
            textAlign: TextAlign.center),
        Text(displayValue,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

// ─── Loop & Markers panel (Tab 2)

class _LoopMarkersPanel extends ConsumerWidget {
  const _LoopMarkersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorUi = ref.watch(editorUiProvider);
    final project = ref.watch(audioProjectProvider);
    final duration = project?.duration ?? Duration.zero;
    final notifier = ref.read(editorUiProvider.notifier);
    final pos = ref.watch(positionProvider).value ?? Duration.zero;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Loop region
          _SectionHeader(AppStrings.loopRegion, Icons.loop_rounded),
          const SizedBox(height: 8),
          if (editorUi.loopRegion != null)
            _LoopRegionCard(
              region: editorUi.loopRegion!,
              duration: duration,
              onClear: notifier.clearLoopRegion,
              notifier: notifier,
            )
          else
            _LoopSetupCard(
              position: pos,
              duration: duration,
              notifier: notifier,
            ),
          const SizedBox(height: 24),

          // ─── Markers
          Row(
            children: [
              _SectionHeader(AppStrings.markers, Icons.flag_rounded),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(AppStrings.addMarker),
                onPressed: () => _addMarker(context, ref, pos),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (editorUi.markers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Nenhum marcador. Toque em + para adicionar.',
                  style: const TextStyle(
                      color: AppColors.textDisabled, fontSize: 13),
                ),
              ),
            )
          else
            ...editorUi.markers.map((m) => _MarkerTile(
                  marker: m,
                  duration: duration,
                  onDelete: () => notifier.removeMarker(m.id),
                  onTap: () {
                    ref
                        .read(audioPlayerServiceProvider)
                        .seek(Duration(milliseconds: m.timeMs));
                  },
                )),
        ],
      ),
    );
  }

  Future<void> _addMarker(
      BuildContext context, WidgetRef ref, Duration position) async {
    final ctrl = TextEditingController(
        text: 'Marcador ${ref.read(editorUiProvider).markers.length + 1}');
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.addMarker),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: AppStrings.markerName),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(AppStrings.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: Text(AppStrings.save)),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      ref.read(editorUiProvider.notifier).addMarker(name, position.inMilliseconds);
    }
  }
}

class _LoopSetupCard extends StatelessWidget {
  const _LoopSetupCard({
    required this.position,
    required this.duration,
    required this.notifier,
  });
  final Duration position;
  final Duration duration;
  final EditorUiNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Text(
            'Defina o início e o fim para criar uma região de loop.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _LoopRangePicker(
            totalMs: duration.inMilliseconds,
            onSet: (start, end) => notifier.setLoopRegion(LoopRegion(startMs: start, endMs: end)),
          ),
        ],
      ),
    );
  }
}

class _LoopRangePicker extends StatefulWidget {
  const _LoopRangePicker({required this.totalMs, required this.onSet});
  final int totalMs;
  final void Function(int start, int end) onSet;

  @override
  State<_LoopRangePicker> createState() => _LoopRangePickerState();
}

class _LoopRangePickerState extends State<_LoopRangePicker> {
  double _start = 0.0;
  double _end = 1.0;

  String _fmt(double ratio) {
    final ms = (ratio * widget.totalMs).toInt();
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${AppStrings.setLoopStart}: ${_fmt(_start)}',
                style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
            Text('${AppStrings.setLoopEnd}: ${_fmt(_end)}',
                style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
          ],
        ),
        RangeSlider(
          values: RangeValues(_start, _end),
          activeColor: AppColors.secondary,
          inactiveColor: AppColors.border,
          onChanged: (v) => setState(() {
            _start = v.start;
            _end = v.end;
          }),
          onChangeEnd: (_) {
            if (widget.totalMs > 0) {
              widget.onSet(
                (_start * widget.totalMs).toInt(),
                (_end * widget.totalMs).toInt(),
              );
            }
          },
        ),
      ],
    );
  }
}

class _LoopRegionCard extends StatelessWidget {
  const _LoopRegionCard({
    required this.region,
    required this.duration,
    required this.onClear,
    required this.notifier,
  });
  final LoopRegion region;
  final Duration duration;
  final VoidCallback onClear;
  final EditorUiNotifier notifier;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.loop_rounded, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.loopRegion,
                    style: const TextStyle(
                        color: AppColors.secondary, fontWeight: FontWeight.w600)),
                Text(
                  '${_fmt(region.startDuration)} → ${_fmt(region.endDuration)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: Text(AppStrings.clearLoop,
                style: const TextStyle(color: AppColors.errorColor, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _MarkerTile extends StatelessWidget {
  const _MarkerTile({
    required this.marker,
    required this.duration,
    required this.onDelete,
    required this.onTap,
  });
  final CueMarker marker;
  final Duration duration;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  String get _timeLabel {
    final d = Duration(milliseconds: marker.timeMs);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.accent.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.flag_rounded, color: AppColors.accent, size: 18),
      ),
      title: Text(marker.name,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      subtitle: Text(_timeLabel,
          style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.errorColor, size: 18),
        onPressed: onDelete,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label, this.icon);
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Presets tab

class _PresetsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_outline_rounded,
                color: AppColors.textDisabled, size: 64),
            const SizedBox(height: 16),
            Text(AppStrings.presets,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Salve combinações de efeitos aqui.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded),
              label: Text(AppStrings.savePreset),
              onPressed: () => _savePreset(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreset(BuildContext context, WidgetRef ref) async {
    final project = ref.read(audioProjectProvider);
    if (project == null || project.effects.isEmpty) return;

    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.savePreset),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
              hintText: AppStrings.presetNameHint, labelText: AppStrings.presetName),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: Text(AppStrings.save)),
        ],
      ),
    );

    if (name != null && name.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppStrings.presets}: "$name" ${AppStrings.success.toLowerCase()}')),
      );
    }
  }
}
