import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Wraps the `record` package for microphone capture.
/// Instantiate via Riverpod — do not use as a singleton.
class RecorderService {
  RecorderService();

  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  bool _isPaused = false;
  String? _currentPath;

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  String? get currentPath => _currentPath;

  Stream<RecordState> get stateStream => _recorder.onStateChanged();
  Stream<Amplitude> get amplitudeStream =>
      _recorder.onAmplitudeChanged(const Duration(milliseconds: 100));

  /// Requests the microphone permission via permission_handler (which reliably
  /// shows the system dialog), then confirms with the record plugin.
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;
    return _recorder.hasPermission();
  }

  Future<String> _newRecordingPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final recDir = Directory('${dir.path}/onda_sonora/recordings');
    if (!recDir.existsSync()) recDir.createSync(recursive: true);
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${recDir.path}/rec_$ts.m4a';
  }

  Future<void> start() async {
    if (_isRecording) return;
    _currentPath = await _newRecordingPath();
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
        numChannels: 2,
      ),
      path: _currentPath!,
    );
    _isRecording = true;
    _isPaused = false;
  }

  Future<void> pause() async {
    if (!_isRecording || _isPaused) return;
    await _recorder.pause();
    _isPaused = true;
  }

  Future<void> resume() async {
    if (!_isRecording || !_isPaused) return;
    await _recorder.resume();
    _isPaused = false;
  }

  /// Stops recording and returns the file path.
  Future<String?> stop() async {
    if (!_isRecording) return null;
    final path = await _recorder.stop();
    _isRecording = false;
    _isPaused = false;
    return path ?? _currentPath;
  }

  Future<void> cancel() async {
    await _recorder.cancel();
    _isRecording = false;
    _isPaused = false;
    if (_currentPath != null) {
      final f = File(_currentPath!);
      if (f.existsSync()) f.deleteSync();
    }
    _currentPath = null;
  }

  Future<void> dispose() => _recorder.dispose();
}
