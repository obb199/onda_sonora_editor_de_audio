// Centralized bilingual strings for Onda Sonora.
// All user-visible text lives here — no hard-coded strings elsewhere.
// To add a new language, extend AppLocale and add entries below.

enum AppLocale { pt, en }

class AppStrings {
  AppStrings._();

  static AppLocale _locale = AppLocale.pt;

  static AppLocale get locale => _locale;

  static void setLocale(AppLocale locale) => _locale = locale;

  static String get(Map<AppLocale, String> map) =>
      map[_locale] ?? map[AppLocale.en] ?? '';

  // ─── App
  static String get appName => get({
        AppLocale.pt: 'Onda Sonora',
        AppLocale.en: 'Onda Sonora',
      });

  static String get appTagline => get({
        AppLocale.pt: 'Editor de Áudio',
        AppLocale.en: 'Audio Editor',
      });

  // ─── Home screen
  static String get homeTitle => get({
        AppLocale.pt: 'Início',
        AppLocale.en: 'Home',
      });

  static String get importAudio => get({
        AppLocale.pt: 'Importar Áudio',
        AppLocale.en: 'Import Audio',
      });

  static String get recentProjects => get({
        AppLocale.pt: 'Projetos Recentes',
        AppLocale.en: 'Recent Projects',
      });

  static String get noRecentProjects => get({
        AppLocale.pt: 'Nenhum projeto recente.\nImporte um arquivo para começar.',
        AppLocale.en: 'No recent projects.\nImport a file to get started.',
      });

  static String get recordAudio => get({
        AppLocale.pt: 'Gravar Áudio',
        AppLocale.en: 'Record Audio',
      });

  static String get tapToImport => get({
        AppLocale.pt: 'Toque para importar um arquivo de áudio',
        AppLocale.en: 'Tap to import an audio file',
      });

  static String get supportedFormats => get({
        AppLocale.pt: 'Formatos suportados: MP3, WAV, FLAC, AAC, OGG',
        AppLocale.en: 'Supported formats: MP3, WAV, FLAC, AAC, OGG',
      });

  // ─── Editor screen
  static String get editorTitle => get({
        AppLocale.pt: 'Editor',
        AppLocale.en: 'Editor',
      });

  static String get play => get({
        AppLocale.pt: 'Reproduzir',
        AppLocale.en: 'Play',
      });

  static String get pause => get({
        AppLocale.pt: 'Pausar',
        AppLocale.en: 'Pause',
      });

  static String get stop => get({
        AppLocale.pt: 'Parar',
        AppLocale.en: 'Stop',
      });

  static String get rewind => get({
        AppLocale.pt: 'Retroceder',
        AppLocale.en: 'Rewind',
      });

  static String get fastForward => get({
        AppLocale.pt: 'Avançar',
        AppLocale.en: 'Fast Forward',
      });

  static String get undo => get({
        AppLocale.pt: 'Desfazer',
        AppLocale.en: 'Undo',
      });

  static String get redo => get({
        AppLocale.pt: 'Refazer',
        AppLocale.en: 'Redo',
      });

  static String get speed => get({
        AppLocale.pt: 'Velocidade',
        AppLocale.en: 'Speed',
      });

  static String get pitch => get({
        AppLocale.pt: 'Tonalidade',
        AppLocale.en: 'Pitch',
      });

  static String get volume => get({
        AppLocale.pt: 'Volume',
        AppLocale.en: 'Volume',
      });

  static String get livePreview => get({
        AppLocale.pt: 'Preview ao Vivo',
        AppLocale.en: 'Live Preview',
      });

  static String get waveform => get({
        AppLocale.pt: 'Forma de Onda',
        AppLocale.en: 'Waveform',
      });

  static String get spectrum => get({
        AppLocale.pt: 'Espectro',
        AppLocale.en: 'Spectrum',
      });

  // ─── Effects panel
  static String get effects => get({
        AppLocale.pt: 'Efeitos',
        AppLocale.en: 'Effects',
      });

  static String get effectsPanel => get({
        AppLocale.pt: 'Painel de Efeitos',
        AppLocale.en: 'Effects Panel',
      });

  static String get addEffect => get({
        AppLocale.pt: 'Adicionar Efeito',
        AppLocale.en: 'Add Effect',
      });

  static String get removeEffect => get({
        AppLocale.pt: 'Remover Efeito',
        AppLocale.en: 'Remove Effect',
      });

  static String get resetEffect => get({
        AppLocale.pt: 'Restaurar Padrão',
        AppLocale.en: 'Reset to Default',
      });

  static String get effectEnabled => get({
        AppLocale.pt: 'Ativado',
        AppLocale.en: 'Enabled',
      });

  static String get noEffectsActive => get({
        AppLocale.pt: 'Nenhum efeito ativo.\nToque em + para adicionar.',
        AppLocale.en: 'No active effects.\nTap + to add one.',
      });

  // ─── Effect names
  static String get effectReverb => get({
        AppLocale.pt: 'Reverb',
        AppLocale.en: 'Reverb',
      });

  static String get effectDelay => get({
        AppLocale.pt: 'Delay / Eco',
        AppLocale.en: 'Delay / Echo',
      });

  static String get effectEqualizer => get({
        AppLocale.pt: 'Equalizador',
        AppLocale.en: 'Equalizer',
      });

  static String get effectDistortion => get({
        AppLocale.pt: 'Distorção',
        AppLocale.en: 'Distortion',
      });

  static String get effectChorus => get({
        AppLocale.pt: 'Chorus',
        AppLocale.en: 'Chorus',
      });

  static String get effectFlanger => get({
        AppLocale.pt: 'Flanger',
        AppLocale.en: 'Flanger',
      });

  static String get effectPhaser => get({
        AppLocale.pt: 'Phaser',
        AppLocale.en: 'Phaser',
      });

  static String get effectBitcrusher => get({
        AppLocale.pt: 'Bitcrusher',
        AppLocale.en: 'Bitcrusher',
      });

  static String get effectLowPass => get({
        AppLocale.pt: 'Filtro Passa-Baixo',
        AppLocale.en: 'Low-Pass Filter',
      });

  static String get effectHighPass => get({
        AppLocale.pt: 'Filtro Passa-Alto',
        AppLocale.en: 'High-Pass Filter',
      });

  static String get effectNormalize => get({
        AppLocale.pt: 'Normalizar',
        AppLocale.en: 'Normalize',
      });

  static String get effectReverse => get({
        AppLocale.pt: 'Inverter',
        AppLocale.en: 'Reverse',
      });

  static String get effectFadeIn => get({
        AppLocale.pt: 'Fade In',
        AppLocale.en: 'Fade In',
      });

  static String get effectFadeOut => get({
        AppLocale.pt: 'Fade Out',
        AppLocale.en: 'Fade Out',
      });

  static String get effectCompressor => get({
        AppLocale.pt: 'Compressor',
        AppLocale.en: 'Compressor',
      });

  // ─── Effect parameters
  static String get paramRoomSize => get({
        AppLocale.pt: 'Tamanho do Ambiente',
        AppLocale.en: 'Room Size',
      });

  static String get paramWetness => get({
        AppLocale.pt: 'Mistura (Wet)',
        AppLocale.en: 'Wet Mix',
      });

  static String get paramDelayTime => get({
        AppLocale.pt: 'Tempo (ms)',
        AppLocale.en: 'Delay Time (ms)',
      });

  static String get paramFeedback => get({
        AppLocale.pt: 'Realimentação',
        AppLocale.en: 'Feedback',
      });

  static String get paramFrequency => get({
        AppLocale.pt: 'Frequência (Hz)',
        AppLocale.en: 'Frequency (Hz)',
      });

  static String get paramGain => get({
        AppLocale.pt: 'Ganho (dB)',
        AppLocale.en: 'Gain (dB)',
      });

  static String get paramBass => get({
        AppLocale.pt: 'Graves',
        AppLocale.en: 'Bass',
      });

  static String get paramMid => get({
        AppLocale.pt: 'Médios',
        AppLocale.en: 'Mid',
      });

  static String get paramTreble => get({
        AppLocale.pt: 'Agudos',
        AppLocale.en: 'Treble',
      });

  static String get paramDrive => get({
        AppLocale.pt: 'Intensidade',
        AppLocale.en: 'Drive',
      });

  static String get paramDepth => get({
        AppLocale.pt: 'Profundidade',
        AppLocale.en: 'Depth',
      });

  static String get paramRate => get({
        AppLocale.pt: 'Taxa (Hz)',
        AppLocale.en: 'Rate (Hz)',
      });

  static String get paramBits => get({
        AppLocale.pt: 'Resolução (bits)',
        AppLocale.en: 'Bit Depth',
      });

  static String get paramDuration => get({
        AppLocale.pt: 'Duração (s)',
        AppLocale.en: 'Duration (s)',
      });

  static String get paramThreshold => get({
        AppLocale.pt: 'Limiar (dB)',
        AppLocale.en: 'Threshold (dB)',
      });

  static String get paramRatio => get({
        AppLocale.pt: 'Razão',
        AppLocale.en: 'Ratio',
      });

  static String get paramCutoff => get({
        AppLocale.pt: 'Frequência de Corte (Hz)',
        AppLocale.en: 'Cutoff Frequency (Hz)',
      });

  // ─── Export screen
  static String get export => get({
        AppLocale.pt: 'Exportar',
        AppLocale.en: 'Export',
      });

  static String get exportTitle => get({
        AppLocale.pt: 'Exportar Áudio',
        AppLocale.en: 'Export Audio',
      });

  static String get exportFormat => get({
        AppLocale.pt: 'Formato',
        AppLocale.en: 'Format',
      });

  static String get exportQuality => get({
        AppLocale.pt: 'Qualidade',
        AppLocale.en: 'Quality',
      });

  static String get exportQualityHigh => get({
        AppLocale.pt: 'Alta (320 kbps)',
        AppLocale.en: 'High (320 kbps)',
      });

  static String get exportQualityMedium => get({
        AppLocale.pt: 'Média (192 kbps)',
        AppLocale.en: 'Medium (192 kbps)',
      });

  static String get exportQualityLow => get({
        AppLocale.pt: 'Baixa (128 kbps)',
        AppLocale.en: 'Low (128 kbps)',
      });

  static String get exportProcessing => get({
        AppLocale.pt: 'Processando...',
        AppLocale.en: 'Processing...',
      });

  static String get exportSuccess => get({
        AppLocale.pt: 'Exportado com sucesso!',
        AppLocale.en: 'Export successful!',
      });

  static String get exportError => get({
        AppLocale.pt: 'Erro ao exportar.',
        AppLocale.en: 'Export failed.',
      });

  static String get share => get({
        AppLocale.pt: 'Compartilhar',
        AppLocale.en: 'Share',
      });

  static String get saveToDevice => get({
        AppLocale.pt: 'Salvar no Dispositivo',
        AppLocale.en: 'Save to Device',
      });

  static String get applyEffects => get({
        AppLocale.pt: 'Aplicar Efeitos',
        AppLocale.en: 'Apply Effects',
      });

  static String get applyEffectsHint => get({
        AppLocale.pt: 'Os efeitos ativos serão processados no arquivo final.',
        AppLocale.en: 'Active effects will be baked into the exported file.',
      });

  // ─── Presets
  static String get presets => get({
        AppLocale.pt: 'Presets',
        AppLocale.en: 'Presets',
      });

  static String get savePreset => get({
        AppLocale.pt: 'Salvar Preset',
        AppLocale.en: 'Save Preset',
      });

  static String get loadPreset => get({
        AppLocale.pt: 'Carregar Preset',
        AppLocale.en: 'Load Preset',
      });

  static String get deletePreset => get({
        AppLocale.pt: 'Excluir Preset',
        AppLocale.en: 'Delete Preset',
      });

  static String get presetName => get({
        AppLocale.pt: 'Nome do Preset',
        AppLocale.en: 'Preset Name',
      });

  static String get presetNameHint => get({
        AppLocale.pt: 'Ex.: Meu Preset de Reverb',
        AppLocale.en: 'e.g. My Reverb Preset',
      });

  // ─── Settings screen
  static String get settings => get({
        AppLocale.pt: 'Configurações',
        AppLocale.en: 'Settings',
      });

  static String get language => get({
        AppLocale.pt: 'Idioma',
        AppLocale.en: 'Language',
      });

  static String get languagePortuguese => get({
        AppLocale.pt: 'Português',
        AppLocale.en: 'Portuguese',
      });

  static String get languageEnglish => get({
        AppLocale.pt: 'Inglês',
        AppLocale.en: 'English',
      });

  static String get theme => get({
        AppLocale.pt: 'Tema',
        AppLocale.en: 'Theme',
      });

  static String get themeDark => get({
        AppLocale.pt: 'Escuro',
        AppLocale.en: 'Dark',
      });

  static String get themeLight => get({
        AppLocale.pt: 'Claro',
        AppLocale.en: 'Light',
      });

  static String get aboutApp => get({
        AppLocale.pt: 'Sobre o App',
        AppLocale.en: 'About',
      });

  static String get aboutText => get({
        AppLocale.pt:
            'Onda Sonora é um editor de áudio profissional desenvolvido em Flutter.\n\nVersão 1.0.0',
        AppLocale.en:
            'Onda Sonora is a professional audio editor built with Flutter.\n\nVersion 1.0.0',
      });

  static String get defaultOutputPath => get({
        AppLocale.pt: 'Pasta de Saída Padrão',
        AppLocale.en: 'Default Output Folder',
      });

  // ─── Recording
  static String get recording => get({
        AppLocale.pt: 'Gravando...',
        AppLocale.en: 'Recording...',
      });

  static String get startRecording => get({
        AppLocale.pt: 'Iniciar Gravação',
        AppLocale.en: 'Start Recording',
      });

  static String get stopRecording => get({
        AppLocale.pt: 'Parar Gravação',
        AppLocale.en: 'Stop Recording',
      });

  // ─── Permissions
  static String get permissionMicDenied => get({
        AppLocale.pt:
            'Permissão de microfone negada. Acesse as configurações para permitir.',
        AppLocale.en:
            'Microphone permission denied. Go to settings to allow it.',
      });

  static String get permissionStorageDenied => get({
        AppLocale.pt:
            'Permissão de armazenamento negada.',
        AppLocale.en:
            'Storage permission denied.',
      });

  static String get openSettings => get({
        AppLocale.pt: 'Abrir Configurações',
        AppLocale.en: 'Open Settings',
      });

  // ─── Generic
  static String get ok => get({
        AppLocale.pt: 'OK',
        AppLocale.en: 'OK',
      });

  static String get cancel => get({
        AppLocale.pt: 'Cancelar',
        AppLocale.en: 'Cancel',
      });

  static String get confirm => get({
        AppLocale.pt: 'Confirmar',
        AppLocale.en: 'Confirm',
      });

  static String get close => get({
        AppLocale.pt: 'Fechar',
        AppLocale.en: 'Close',
      });

  static String get delete => get({
        AppLocale.pt: 'Excluir',
        AppLocale.en: 'Delete',
      });

  static String get save => get({
        AppLocale.pt: 'Salvar',
        AppLocale.en: 'Save',
      });

  static String get error => get({
        AppLocale.pt: 'Erro',
        AppLocale.en: 'Error',
      });

  static String get success => get({
        AppLocale.pt: 'Sucesso',
        AppLocale.en: 'Success',
      });

  static String get loading => get({
        AppLocale.pt: 'Carregando...',
        AppLocale.en: 'Loading...',
      });

  static String get noFileSelected => get({
        AppLocale.pt: 'Nenhum arquivo selecionado',
        AppLocale.en: 'No file selected',
      });

  static String get fileLoadError => get({
        AppLocale.pt: 'Erro ao carregar o arquivo.',
        AppLocale.en: 'Failed to load the file.',
      });

  // ─── Phase 2: Recording
  static String get recorder => get({
        AppLocale.pt: 'Gravador',
        AppLocale.en: 'Recorder',
      });

  static String get recordNew => get({
        AppLocale.pt: 'Gravar Novo Áudio',
        AppLocale.en: 'Record New Audio',
      });

  static String get recordingInProgress => get({
        AppLocale.pt: 'Gravando...',
        AppLocale.en: 'Recording...',
      });

  static String get recordingPaused => get({
        AppLocale.pt: 'Gravação pausada',
        AppLocale.en: 'Recording paused',
      });

  static String get recordingStopped => get({
        AppLocale.pt: 'Gravação encerrada',
        AppLocale.en: 'Recording stopped',
      });

  static String get sendToEditor => get({
        AppLocale.pt: 'Enviar ao Editor',
        AppLocale.en: 'Send to Editor',
      });

  static String get tapToRecord => get({
        AppLocale.pt: 'Toque para gravar',
        AppLocale.en: 'Tap to record',
      });

  static String get micPermissionRequired => get({
        AppLocale.pt: 'Permissão de microfone necessária para gravar.',
        AppLocale.en: 'Microphone permission is required to record.',
      });

  // ─── Phase 2: Multi-track Mixer
  static String get mixer => get({
        AppLocale.pt: 'Mixer',
        AppLocale.en: 'Mixer',
      });

  static String get addTrack => get({
        AppLocale.pt: 'Adicionar Faixa',
        AppLocale.en: 'Add Track',
      });

  static String get removeTrack => get({
        AppLocale.pt: 'Remover Faixa',
        AppLocale.en: 'Remove Track',
      });

  static String get trackName => get({
        AppLocale.pt: 'Nome da Faixa',
        AppLocale.en: 'Track Name',
      });

  static String get mute => get({
        AppLocale.pt: 'Mudo',
        AppLocale.en: 'Mute',
      });

  static String get solo => get({
        AppLocale.pt: 'Solo',
        AppLocale.en: 'Solo',
      });

  static String get pan => get({
        AppLocale.pt: 'Pan',
        AppLocale.en: 'Pan',
      });

  static String get mixAndExport => get({
        AppLocale.pt: 'Mixar e Exportar',
        AppLocale.en: 'Mix & Export',
      });

  static String get mixProcessing => get({
        AppLocale.pt: 'Mixando faixas...',
        AppLocale.en: 'Mixing tracks...',
      });

  static String get noTracksYet => get({
        AppLocale.pt: 'Nenhuma faixa ainda.\nImporte ou grave para começar.',
        AppLocale.en: 'No tracks yet.\nImport or record to get started.',
      });

  static String get importAsTrack => get({
        AppLocale.pt: 'Importar como Faixa',
        AppLocale.en: 'Import as Track',
      });

  static String get recordNewTrack => get({
        AppLocale.pt: 'Gravar Nova Faixa',
        AppLocale.en: 'Record New Track',
      });

  static String get overdubTrack => get({
        AppLocale.pt: 'Overdub',
        AppLocale.en: 'Overdub',
      });

  static String get overdubHint => get({
        AppLocale.pt: 'Grava sobre as faixas existentes em reprodução',
        AppLocale.en: 'Records while existing tracks play back',
      });

  // ─── Phase 2: Loop & Markers
  static String get loop => get({
        AppLocale.pt: 'Loop',
        AppLocale.en: 'Loop',
      });

  static String get loopRegion => get({
        AppLocale.pt: 'Região de Loop',
        AppLocale.en: 'Loop Region',
      });

  static String get setLoopStart => get({
        AppLocale.pt: 'Definir Início do Loop',
        AppLocale.en: 'Set Loop Start',
      });

  static String get setLoopEnd => get({
        AppLocale.pt: 'Definir Fim do Loop',
        AppLocale.en: 'Set Loop End',
      });

  static String get clearLoop => get({
        AppLocale.pt: 'Limpar Loop',
        AppLocale.en: 'Clear Loop',
      });

  static String get markers => get({
        AppLocale.pt: 'Marcadores',
        AppLocale.en: 'Markers',
      });

  static String get addMarker => get({
        AppLocale.pt: 'Adicionar Marcador',
        AppLocale.en: 'Add Marker',
      });

  static String get markerName => get({
        AppLocale.pt: 'Nome do Marcador',
        AppLocale.en: 'Marker Name',
      });

  // ─── Phase 2: Live Preview
  static String get liveEffectPreview => get({
        AppLocale.pt: 'Preview de Efeitos',
        AppLocale.en: 'Effects Preview',
      });

  static String get previewRendering => get({
        AppLocale.pt: 'Renderizando preview...',
        AppLocale.en: 'Rendering preview...',
      });

  static String get previewReady => get({
        AppLocale.pt: 'Preview pronto',
        AppLocale.en: 'Preview ready',
      });

  static String get previewDuration => get({
        AppLocale.pt: 'Duração do Preview (s)',
        AppLocale.en: 'Preview Duration (s)',
      });

  // ─── Phase 2: Automation
  static String get automation => get({
        AppLocale.pt: 'Automação',
        AppLocale.en: 'Automation',
      });

  static String get automationPoint => get({
        AppLocale.pt: 'Ponto de Automação',
        AppLocale.en: 'Automation Point',
      });

  static String get clearAutomation => get({
        AppLocale.pt: 'Limpar Automação',
        AppLocale.en: 'Clear Automation',
      });
}
