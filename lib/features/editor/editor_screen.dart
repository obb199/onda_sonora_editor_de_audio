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
import '../effects/effects_board.dart';
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
    _tabController = TabController(length: 2, vsync: this);

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

    final isPlaying = ref.watch(playerStateProvider).value?.playing ?? false;
    final editorUi = ref.watch(editorUiProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _confirmClose(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedAppLogo(size: 26, isAnimating: isPlaying),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                project.fileName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Undo
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 22),
            tooltip: AppStrings.undo,
            onPressed: project.canUndo
                ? () => ref.read(audioProjectProvider.notifier).undo()
                : null,
          ),
          // Redo
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 22),
            tooltip: AppStrings.redo,
            onPressed: project.canRedo
                ? () => ref.read(audioProjectProvider.notifier).redo()
                : null,
          ),
          // Live preview toggle
          IconButton(
            icon: Icon(
              editorUi.livePreviewEnabled
                  ? Icons.hearing_rounded
                  : Icons.hearing_disabled_rounded,
              size: 22,
              color: editorUi.livePreviewEnabled
                  ? AppColors.secondary
                  : AppColors.textDisabled,
            ),
            tooltip: AppStrings.liveEffectPreview,
            onPressed: () =>
                ref.read(editorUiProvider.notifier).toggleLivePreview(),
          ),
          // Overdub
          IconButton(
            icon: const Icon(Icons.fiber_manual_record_rounded,
                color: AppColors.accentRecord, size: 22),
            tooltip: AppStrings.overdubTrack,
            onPressed: () => _startOverdub(context),
          ),
          // Export
          IconButton(
            icon: const Icon(Icons.upload_file_rounded,
                color: AppColors.primary, size: 22),
            tooltip: AppStrings.export,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExportScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Waveform + transport controls
            _WaveformSection(),
            // Live preview status bar
            _LivePreviewBar(),
            const Divider(height: 1, color: AppColors.border),
            // Tab bar: Effects | Loop & Markers
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Tab 1: All effects always visible
                  const EffectsBoard(),
                  // Tab 2: Loop & Markers
                  const SingleChildScrollView(child: _LoopMarkersPanel()),
                ],
              ),
            ),
          ],
        ),
      ),
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
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tune_rounded, size: 16),
              const SizedBox(width: 6),
              Text(AppStrings.effects),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.loop_rounded, size: 16),
              const SizedBox(width: 6),
              Text(AppStrings.loop),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _startOverdub(BuildContext context) async {
    await ref.read(audioPlayerServiceProvider).pause();
    ref.read(recorderProvider.notifier).reset();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RecorderScreen()),
    );
  }

  Future<void> _confirmClose(BuildContext context) async {
    final project = ref.read(audioProjectProvider);
    final hasActiveEffects = project?.enabledEffects.isNotEmpty ?? false;

    if (!hasActiveEffects) {
      _doClose(context);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.close),
        content: const Text(
            'Fechar sem exportar? Os efeitos ativos não serão salvos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.close)),
        ],
      ),
    );
    if (confirmed == true && context.mounted) _doClose(context);
  }

  void _doClose(BuildContext context) {
    ref.read(audioPlayerServiceProvider).stop();
    ref.read(editorUiProvider.notifier).reset();
    Navigator.of(context).pop();
  }
}

// ─── Live preview status bar

class _LivePreviewBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveEnabled = ref.watch(editorUiProvider).livePreviewEnabled;

    return StreamBuilder<LivePreviewState>(
      stream: LivePreviewService.instance.stateStream,
      builder: (_, snap) {
        final state = snap.data ?? LivePreviewState.idle;
        if (!liveEnabled) return const SizedBox.shrink();

        switch (state) {
          case LivePreviewState.rendering:
            return Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(children: [
                const SizedBox(
                    width: 12, height: 12,
                    child: CircularProgressIndicator(
                        color: AppColors.secondary, strokeWidth: 2)),
                const SizedBox(width: 8),
                Text(AppStrings.previewRendering,
                    style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
              ]),
            );
          case LivePreviewState.playing:
            return Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(children: [
                const Icon(Icons.graphic_eq_rounded,
                    color: AppColors.secondary, size: 14),
                const SizedBox(width: 8),
                Text(AppStrings.previewReady,
                    style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
              ]),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

// ─── Waveform + playback

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

    final samples = ref.watch(waveformSamplesProvider(project.filePath)).value ?? [];
    final editorUi = ref.watch(editorUiProvider);
    final isPlaying = ref.watch(playerStateProvider).value?.playing ?? false;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        children: [
          // Waveform
          Stack(
            children: [
              WaveformView(
                samples: samples,
                progress: progress,
                height: 72,
                loopRegion: editorUi.loopRegion,
                markers: editorUi.showMarkers ? editorUi.markers : [],
                totalDurationMs: duration.inMilliseconds,
                onSeek: (p) => ref.read(audioPlayerServiceProvider).seek(
                    Duration(milliseconds: (p * duration.inMilliseconds).toInt())),
              ),
              Positioned(
                top: 4, right: 4,
                child: _LoopPill(isLooping: editorUi.isLooping),
              ),
            ],
          ),
          // Time + frequency
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(position),
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 10)),
              if (editorUi.loopRegion != null)
                Text(
                  '⟳ ${_fmt(editorUi.loopRegion!.startDuration)}–${_fmt(editorUi.loopRegion!.endDuration)}',
                  style: const TextStyle(color: AppColors.secondary, fontSize: 10),
                ),
              Text(_fmt(duration),
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          FrequencyVisualizer(isActive: isPlaying, height: 36),
          const SizedBox(height: 4),
          _TransportRow(),
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
        ref.read(audioPlayerServiceProvider).setLoopMode(
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
                size: 11,
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

class _TransportRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.value?.playing ?? false;
    final isLoading = playerState.value?.processingState == ProcessingState.loading ||
        playerState.value?.processingState == ProcessingState.buffering;
    final player = ref.read(audioPlayerServiceProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TransportBtn(
          icon: Icons.skip_previous_rounded,
          size: 28,
          onTap: () => player.seek(Duration.zero),
        ),
        const SizedBox(width: 12),
        _BigPlayPause(
          isPlaying: isPlaying,
          isLoading: isLoading,
          onTap: () => isPlaying ? player.pause() : player.play(),
        ),
        const SizedBox(width: 12),
        _TransportBtn(
          icon: Icons.stop_rounded,
          size: 28,
          onTap: () => player.stop(),
        ),
      ],
    );
  }
}

class _TransportBtn extends StatelessWidget {
  const _TransportBtn({required this.icon, required this.size, required this.onTap});
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: AppColors.textSecondary),
      onPressed: onTap,
      padding: EdgeInsets.zero,
    );
  }
}

class _BigPlayPause extends StatelessWidget {
  const _BigPlayPause({
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withAlpha(80),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 30,
              ),
      ),
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
          _SectionLabel(AppStrings.loopRegion, Icons.loop_rounded, AppColors.secondary),
          const SizedBox(height: 10),
          if (editorUi.loopRegion != null)
            _LoopActiveCard(
                region: editorUi.loopRegion!,
                duration: duration,
                onClear: notifier.clearLoopRegion)
          else
            _LoopSetupCard(duration: duration, notifier: notifier),
          const SizedBox(height: 24),

          Row(
            children: [
              _SectionLabel(AppStrings.markers, Icons.flag_rounded, AppColors.accent),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Nenhum marcador. Toque em + para adicionar.',
                style: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
              ),
            )
          else
            ...editorUi.markers.map(
              (m) => _MarkerTile(
                marker: m,
                onDelete: () => notifier.removeMarker(m.id),
                onTap: () => ref.read(audioPlayerServiceProvider).seek(
                    Duration(milliseconds: m.timeMs)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addMarker(BuildContext context, WidgetRef ref, Duration position) async {
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(AppStrings.save)),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      ref.read(editorUiProvider.notifier).addMarker(name, position.inMilliseconds);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _LoopSetupCard extends StatefulWidget {
  const _LoopSetupCard({required this.duration, required this.notifier});
  final Duration duration;
  final EditorUiNotifier notifier;

  @override
  State<_LoopSetupCard> createState() => _LoopSetupCardState();
}

class _LoopSetupCardState extends State<_LoopSetupCard> {
  double _start = 0.0;
  double _end = 1.0;

  String _fmt(double ratio) {
    final ms = (ratio * widget.duration.inMilliseconds).toInt();
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Início: ${_fmt(_start)}',
                  style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
              Text('Fim: ${_fmt(_end)}',
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
              if (widget.duration.inMilliseconds > 0) {
                widget.notifier.setLoopRegion(LoopRegion(
                  startMs: (_start * widget.duration.inMilliseconds).toInt(),
                  endMs: (_end * widget.duration.inMilliseconds).toInt(),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _LoopActiveCard extends StatelessWidget {
  const _LoopActiveCard(
      {required this.region, required this.duration, required this.onClear});
  final LoopRegion region;
  final Duration duration;
  final VoidCallback onClear;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.loop_rounded, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_fmt(region.startDuration)} → ${_fmt(region.endDuration)}',
              style: const TextStyle(color: AppColors.secondary, fontSize: 14),
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
  const _MarkerTile(
      {required this.marker, required this.onDelete, required this.onTap});
  final CueMarker marker;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  String get _time {
    final d = Duration(milliseconds: marker.timeMs);
    return '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(30),
            borderRadius: BorderRadius.circular(9)),
        child: const Icon(Icons.flag_rounded, color: AppColors.accent, size: 18),
      ),
      title: Text(marker.name,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      subtitle: Text(_time,
          style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.errorColor, size: 18),
        onPressed: onDelete,
      ),
    );
  }
}
