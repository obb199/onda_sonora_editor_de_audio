# Onda Sonora — Checklist de Testes Manuais

Use este documento para validar o app em um dispositivo ou emulador Android real antes de cada release. Marque cada item após confirmar que funciona corretamente.

---

## 1. Inicialização

- [ ] App abre sem crash
- [ ] Tela inicial exibe o logo, nome "Onda Sonora" e tagline "Editor de Áudio"
- [ ] A grade de 6 recursos (Velocidade, Tonalidade, Equalizador, Reverb, Delay, Exportar) é visível
- [ ] Barra de navegação inferior não sobrepõe os botões/gestos do Android
- [ ] Status bar e barra de navegação do sistema são transparentes (edge-to-edge)

---

## 2. Importação de Arquivo

- [ ] Tocar no card "Importar Áudio" abre o seletor de arquivos do sistema
- [ ] É possível selecionar um arquivo MP3
- [ ] É possível selecionar um arquivo WAV
- [ ] É possível selecionar um arquivo FLAC
- [ ] Após seleção, o app navega para a tela do Editor
- [ ] O nome do arquivo aparece na AppBar do editor
- [ ] Cancelar o seletor de arquivos não causa crash e volta à tela inicial

---

## 3. Tela do Editor — Forma de Onda

- [ ] A forma de onda é exibida após o carregamento do arquivo
- [ ] Tocar na forma de onda busca a posição correspondente
- [ ] Arrastar o dedo sobre a forma de onda faz seek em tempo real
- [ ] O cursor da forma de onda avança conforme a reprodução
- [ ] Os tempos (posição atual / duração total) são exibidos corretamente no formato `mm:ss`

---

## 4. Reprodução

- [ ] Botão Play inicia a reprodução
- [ ] Botão Pause pausa a reprodução; pressionar Play novamente retoma do ponto correto
- [ ] Botão Stop para e volta ao início (posição 00:00)
- [ ] Botão de retroceder (⏮) volta ao início
- [ ] Ícone animado do logo pulsa enquanto o áudio toca
- [ ] As barras de espectro (frequency visualizer) animam durante a reprodução e param quando pausado

---

## 5. Controles ao Vivo (Preview Instantâneo)

- [ ] Slider de **Velocidade**: arrastar para direita acelera o áudio, para esquerda desacelera — a mudança é ouvida instantaneamente
- [ ] Slider de **Tonalidade (Pitch)**: subir aumenta o tom, descer diminui — ouvido instantaneamente
- [ ] Slider de **Volume**: alterar o volume é imediato
- [ ] Os valores numéricos exibidos acima de cada slider atualizam em tempo real
- [ ] Os controles funcionam com o áudio tanto tocando quanto pausado

---

## 6. Efeitos — Adicionar

- [ ] Aba "Efeitos" mostra mensagem de "nenhum efeito" quando a lista está vazia
- [ ] Tocar no botão `+` abre o bottom sheet de seleção de efeitos
- [ ] O bottom sheet lista todos os 15 tipos de efeito
- [ ] Tocar em um efeito o adiciona à lista e fecha o sheet
- [ ] O contador de efeitos na header do painel atualiza
- [ ] Adicionar múltiplos efeitos funciona; todos aparecem na lista

---

## 7. Efeitos — Controlar

- [ ] Cada card de efeito pode ser expandido/colapsado tocando na seta
- [ ] Os sliders de cada efeito respondem ao toque e atualizam o valor em tempo real
- [ ] **Reverb**: sliders de Tamanho do Ambiente, Mistura (Wet) e Realimentação funcionam
- [ ] **Delay**: sliders de Tempo (ms), Realimentação e Mistura funcionam
- [ ] **Equalizador**: sliders de Graves, Médios e Agudos vão de -12 dB a +12 dB
- [ ] **Distorção**: sliders de Intensidade e Mistura funcionam
- [ ] **Bitcrusher**: slider de bits (1–16) funciona
- [ ] **Filtro Passa-Baixo / Passa-Alto**: slider de frequência de corte funciona
- [ ] **Fade In / Fade Out**: slider de duração em segundos funciona
- [ ] **Compressor**: sliders de Limiar e Razão funcionam
- [ ] O toggle (switch) de cada efeito ativa/desativa o efeito (fica acinzentado quando desabilitado)
- [ ] O botão de lixeira remove o efeito da lista

---

## 8. Undo / Redo

- [ ] Após adicionar um efeito, o botão Undo (↩) na AppBar fica habilitado
- [ ] Pressionar Undo remove o efeito adicionado
- [ ] Após desfazer, o botão Redo (↪) fica habilitado
- [ ] Pressionar Redo re-adiciona o efeito
- [ ] Undo/Redo funciona para operações de atualização e remoção de efeitos
- [ ] O histórico é limitado a 50 operações (não há overflow de memória)

---

## 9. Exportação

- [ ] Botão de upload (↑) na AppBar do editor navega para a tela de Exportar
- [ ] O card com nome do arquivo e duração é exibido
- [ ] Seleção de formato: MP3, WAV e FLAC funcionam (apenas um pode ser selecionado)
- [ ] Seleção de qualidade: Alta, Média e Baixa funcionam
- [ ] O toggle "Aplicar Efeitos" aparece quando há efeitos ativos
- [ ] Pressionar "Exportar" inicia o processamento (spinner visível)
- [ ] O banner verde de sucesso aparece após a exportação com o nome do arquivo
- [ ] O botão "Compartilhar" abre o share sheet do Android
- [ ] Exportar sem efeitos (toggle desabilitado) gera o arquivo sem processamento
- [ ] Exportar em WAV funciona e gera arquivo não comprimido
- [ ] Exportar em FLAC funciona

---

## 10. Configurações

- [ ] Aba "Configurações" na barra de navegação funciona
- [ ] Opção "Português" muda o idioma para português — todos os textos atualizam
- [ ] Opção "Inglês" muda para inglês — todos os textos atualizam (incluindo nomes de efeitos)
- [ ] Seção "Sobre" exibe o logo, o nome "Onda Sonora" e a versão 1.0.0
- [ ] Voltar para a aba "Início" após mudar o idioma mantém o idioma selecionado

---

## 11. Navegação e Borda de Segurança

- [ ] **Em todos os dispositivos**: nenhum elemento da UI fica atrás dos botões/gestos do Android (barra inferior)
- [ ] Bottom sheets (seletor de efeitos, diálogos) têm padding adequado para a barra de navegação
- [ ] A AppBar respeita a status bar (sem sobreposição)
- [ ] Em dispositivos com entalhe (notch), a interface não é cortada
- [ ] O teclado, ao aparecer para digitar nome de preset, não sobrepõe o campo de texto

---

## 12. Robustez

- [ ] Colocar o app em segundo plano e voltar não perde o estado do projeto
- [ ] Girar o dispositivo (se habilitado) não causa crash (app está em modo retrato por padrão)
- [ ] Fechar o editor com efeitos não salvos exibe diálogo de confirmação
- [ ] Selecionar "Cancelar" no diálogo de fechar mantém o editor aberto
- [ ] Selecionar "Fechar" descarta as alterações e volta à tela inicial

---

## 13. Testes Automatizados

Execute antes de qualquer release:

```bash
# Análise estática (deve retornar "No issues found")
flutter analyze

# Todos os testes (deve passar 49/49)
flutter test

# Testes unitários isolados
flutter test test/unit/

# Testes de widget
flutter test test/widget/ test/widget_test.dart
```

Resultado esperado: **49 testes passando, 0 falhas**.

---

## 14. Build de Release

```bash
# Gerar APK de release para instalação direta
flutter build apk --release

# Verificar o APK gerado
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

- [ ] O build de release completa sem erros
- [ ] O APK instala corretamente em um dispositivo físico
- [ ] O app funciona em release mode (sem modo debug)
