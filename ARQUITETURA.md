# Onda Sonora — Documentação de Arquitetura

## Visão Geral

**Onda Sonora** é um editor de áudio para Android desenvolvido em Flutter. A versão 1.0 implementa a **Fase 1 (MVP)** do planejamento original: reprodução com preview ao vivo de velocidade/pitch/volume via `just_audio`, e processamento de efeitos offline via FFmpeg para exportação.

---

## Estrutura de Pastas

```
lib/
├── main.dart                  # Ponto de entrada
├── app.dart                   # MaterialApp + shell de navegação
│
├── l10n/
│   └── app_strings.dart       # Todas as strings PT/EN centralizadas
│
├── theme/
│   └── app_theme.dart         # Tokens de design: cores, tipografia, ThemeData
│
├── models/
│   ├── audio_project.dart     # Estado da sessão de edição (faixa + efeitos + undo/redo)
│   ├── audio_effect.dart      # Tipos de efeito + parâmetros padrão
│   └── effect_preset.dart     # Presets salvos
│
├── core/
│   ├── audio_player_service.dart   # Wrapper do just_audio (play/pause/speed/pitch/volume)
│   ├── ffmpeg_service.dart         # Construção de filtros FFmpeg + execução de export
│   └── permissions_service.dart    # Permissões em tempo de execução (microfone, storage)
│
├── providers/
│   ├── audio_provider.dart    # Riverpod: projeto atual, streams de posição/duração
│   ├── effects_provider.dart  # Riverpod: presets persistidos
│   └── settings_provider.dart # Riverpod: idioma e tema
│
├── features/
│   ├── home/
│   │   └── home_screen.dart   # Tela inicial: importar arquivo, grade de recursos
│   ├── editor/
│   │   └── editor_screen.dart # Editor principal: forma de onda, controles ao vivo, abas
│   ├── effects/
│   │   └── effects_panel.dart # Painel de efeitos: cards expansíveis, seletor de efeitos
│   ├── export/
│   │   └── export_screen.dart # Tela de exportação: formato, qualidade, compartilhar
│   └── settings/
│       └── settings_screen.dart # Configurações: idioma, sobre
│
└── widgets/
    ├── app_logo.dart            # Logo desenhada com CustomPainter (sem arquivo de imagem)
    ├── waveform_painter.dart    # Visualizador de forma de onda + seek por toque
    ├── frequency_visualizer.dart # Barras de espectro animadas
    └── effect_slider.dart       # Slider parametrizado com label e valor formatado

test/
├── unit/
│   ├── audio_effect_test.dart       # Modelos de efeito: CRUD, serialização, parâmetros
│   ├── audio_project_test.dart      # Projeto: undo/redo, add/remove/update efeitos
│   ├── ffmpeg_service_test.dart     # Strings de filtros FFmpeg para cada tipo de efeito
│   └── app_strings_test.dart        # Bilíngue: PT e EN não vazios, locale comutável
└── widget/
    └── home_screen_test.dart        # Tela inicial: textos, navegação, botões
```

---

## Camadas da Arquitetura

```
┌─────────────────────────────────────────────────┐
│                   Flutter UI                    │
│  (Screens, Widgets, CustomPainters)             │
├─────────────────────────────────────────────────┤
│              Estado — Riverpod                  │
│  (Providers, StateNotifiers, StreamProviders)   │
├──────────────────────┬──────────────────────────┤
│   just_audio         │   FFmpegKit              │
│   (preview ao vivo)  │   (efeitos + exportação) │
│   speed/pitch/volume │   reverb/delay/EQ/etc.   │
└──────────────────────┴──────────────────────────┘
```

### Fluxo de Preview ao Vivo (Fase 1)
Apenas `speed`, `pitch` e `volume` têm preview ao vivo real. O usuário arrasta o slider → `AudioProjectNotifier` chama `AudioPlayerService.setSpeed/setPitch/setVolume` → `just_audio` aplica instantaneamente ao stream em reprodução.

### Fluxo de Efeitos + Exportação (Fase 1)
Os demais efeitos (reverb, delay, EQ, distorção etc.) são configurados na UI e armazenados no `AudioProject.effects`. Na exportação, `FfmpegService.applyAndExport` constrói uma cadeia de filtros FFmpeg `-af "filtro1,filtro2,..."` e processa o arquivo completo. O resultado é salvo em `Documents/onda_sonora/exports/`.

---

## Gerenciamento de Estado

Usa **Riverpod** com os seguintes providers:

| Provider | Tipo | Responsabilidade |
|---|---|---|
| `audioPlayerServiceProvider` | `Provider` | Singleton do `AudioPlayerService` |
| `audioProjectProvider` | `StateNotifierProvider` | Projeto atual (faixa, efeitos, undo/redo) |
| `playerStateProvider` | `StreamProvider` | Estado do player (playing/paused/loading) |
| `positionProvider` | `StreamProvider` | Posição atual de reprodução |
| `durationProvider` | `StreamProvider` | Duração total da faixa |
| `waveformSamplesProvider` | `FutureProvider.family` | Amostras da forma de onda |
| `presetsProvider` | `StateNotifierProvider` | Presets persistidos em JSON local |
| `settingsProvider` | `StateNotifierProvider` | Idioma e preferências |

---

## Internacionalização (i18n)

Todas as strings ficam em `lib/l10n/app_strings.dart`. A classe `AppStrings` é **estática e singleton de locale** — sem geração de código.

```dart
// Trocar idioma em tempo de execução:
AppStrings.setLocale(AppLocale.en);

// Acessar string:
Text(AppStrings.importAudio)
```

Para adicionar um novo idioma, basta estender o enum `AppLocale` e adicionar a entrada em cada `Map<AppLocale, String>`.

---

## Efeitos Disponíveis (Fase 1)

| Efeito | Filtro FFmpeg | Parâmetros |
|---|---|---|
| Reverb | `aecho` | roomSize, wetness, feedback |
| Delay / Eco | `aecho` | delayMs, feedback, wetness |
| Equalizador | `equalizer` | bass, mid, treble (dB) |
| Distorção | `acrusher` | drive, wetness |
| Chorus | `chorus` | depth, rate, wetness |
| Flanger | `flanger` | depth, rate, feedback |
| Phaser | `aphaser` | depth, rate |
| Bitcrusher | `acrusher` | bits (1–16) |
| Filtro Passa-Baixo | `lowpass` | cutoff (Hz) |
| Filtro Passa-Alto | `highpass` | cutoff (Hz) |
| Normalizar | `loudnorm` | targetLufs |
| Inverter | `areverse` | — |
| Fade In | `afade` | durationSec |
| Fade Out | `afade` | durationSec |
| Compressor | `acompressor` | threshold (dB), ratio |

---

## Configuração Android

- **minSdk**: 21 (requisito do `just_audio`)
- **targetSdk**: 36 (Android 16, última estável)
- **Permissões**: `RECORD_AUDIO`, `READ_MEDIA_AUDIO` (API 33+), `READ_EXTERNAL_STORAGE` (API ≤ 32)
- **Edge-to-edge**: `SystemUiMode.edgeToEdge` + `SafeArea` em todas as telas
- **Orientação**: Bloqueada em retrato para melhor UX do editor

---

## Dependências Principais

| Pacote | Versão | Uso |
|---|---|---|
| `just_audio` | ^0.9.40 | Reprodução + preview ao vivo |
| `ffmpeg_kit_flutter_new` | ^4.2.0 | Efeitos offline e exportação |
| `flutter_riverpod` | ^2.6.1 | Gerenciamento de estado |
| `file_picker` | ^8.0.0 | Importar arquivos do dispositivo |
| `share_plus` | ^10.0.0 | Compartilhar arquivo exportado |
| `permission_handler` | ^11.3.1 | Permissões em tempo de execução |
| `google_fonts` | ^6.2.1 | Fonte Inter |
| `record` | ^5.1.2 | Gravação via microfone (Fase 2) |
| `equatable` | ^2.0.5 | Igualdade de modelos |

---

## Roadmap Futuro

### Fase 2 — Motor Nativo (Tempo Real)
- Integrar **Oboe** (Android) via `dart:ffi` para preview ao vivo de todos os efeitos
- DSP em C++ compartilhado entre preview e exportação (mesmo som, garantido)
- Gravação, overdub e múltiplas faixas sincronizadas

### Fase 3 — Inteligência Artificial
- Separação de faixas (stems) com modelos como Demucs
- Remoção de vocal limpa via IA
- Pitch correction automático (estilo Auto-Tune)
- Mastering automático e redução de ruído
