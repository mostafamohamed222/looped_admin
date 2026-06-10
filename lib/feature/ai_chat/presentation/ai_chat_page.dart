import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:just_audio/just_audio.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/feature/ai_chat/data/ai_chat_service.dart';
import 'package:looped_admin/feature/ai_chat/presentation/widgets/ai_report_web_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

enum ChatMessageKind { userText, userAudio, aiThinking, aiHtml }

/// Vertical gap between consecutive chat rows.
const double _kChatMessageGap = 4;

class ChatMessage {
  ChatMessage._({
    required this.kind,
    this.text,
    this.html,
    this.audioPath,
    this.audioDuration,
  });

  factory ChatMessage.userText(String value) =>
      ChatMessage._(kind: ChatMessageKind.userText, text: value);

  factory ChatMessage.userAudio({
    required String path,
    required Duration duration,
  }) =>
      ChatMessage._(
        kind: ChatMessageKind.userAudio,
        audioPath: path,
        audioDuration: duration,
      );

  ChatMessage.aiThinking() : this._(kind: ChatMessageKind.aiThinking);

  factory ChatMessage.aiHtml(String value) =>
      ChatMessage._(kind: ChatMessageKind.aiHtml, html: value);

  final ChatMessageKind kind;
  final String? text;
  final String? html;
  final String? audioPath;
  final Duration? audioDuration;
}

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiChatService _chatService = AiChatService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<ChatMessage> _messages = [];
  String? _chatSessionId;
  bool _isAwaitingAiReply = false;
  bool _isRecording = false;
  Duration _recordingElapsed = Duration.zero;
  String? _playingAudioPath;
  int _replySeq = 0;
  Timer? _recordingTimer;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();
    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() => _playingAudioPath = null);
      }
    });
  }

  @override
  void dispose() {
    _replySeq++;
    _recordingTimer?.cancel();
    _playerStateSub?.cancel();
    _audioRecorder.dispose();
    unawaited(_audioPlayer.dispose());
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _removeThinkingIndicator() {
    _messages.removeWhere((m) => m.kind == ChatMessageKind.aiThinking);
  }

  String _errorHtml(Object error) {
    final isAr = context.locale.languageCode == 'ar';
    final message = switch (error) {
      FormatException(:final message) when message.startsWith('ai_chat_') =>
        message.tr(),
      Exception() =>
        error.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
      _ => 'ai_chat_error'.tr(),
    };
    final safe = message
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    if (isAr) {
      return '''
<div style="font-family: sans-serif; line-height: 1.5; color: #991b1b;">
  <p><strong>تعذّر الحصول على رد</strong></p>
  <p>$safe</p>
</div>
''';
    }
    return '''
<div style="font-family: sans-serif; line-height: 1.5; color: #991b1b;">
  <p><strong>Could not get a reply</strong></p>
  <p>$safe</p>
</div>
''';
  }

  Future<void> _fetchAiReply({
    required int seq,
    String? userText,
    File? audioFile,
  }) async {
    try {
      final reply = await _chatService.fetchHtmlReply(
        text: userText,
        audioFile: audioFile,
        language: context.locale.languageCode,
        sessionId: _chatSessionId,
      );
      if (!mounted || seq != _replySeq) return;
      setState(() {
        _removeThinkingIndicator();
        if (reply.sessionId != null) {
          _chatSessionId = reply.sessionId;
        }
        _messages.add(ChatMessage.aiHtml(reply.html));
        _isAwaitingAiReply = false;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted || seq != _replySeq) return;
      setState(() {
        _removeThinkingIndicator();
        _messages.add(ChatMessage.aiHtml(_errorHtml(error)));
        _isAwaitingAiReply = false;
      });
      _scrollToBottom();
    }
  }

  void _beginAiReply({String? userText, File? audioFile}) {
    setState(() {
      _messages.add(ChatMessage.aiThinking());
      _isAwaitingAiReply = true;
    });
    _scrollToBottom();
    final seq = ++_replySeq;
    unawaited(
      _fetchAiReply(seq: seq, userText: userText, audioFile: audioFile),
    );
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isAwaitingAiReply || _isRecording) return;
    setState(() {
      _messages.add(ChatMessage.userText(text));
      _textController.clear();
    });
    _scrollToBottom();
    _beginAiReply(userText: text);
  }

  Future<void> _toggleRecording() async {
    if (_isAwaitingAiReply) return;

    if (_isRecording) {
      await _stopRecordingAndSend();
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ai_chat_mic_denied'.tr())),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/ai_chat_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    _recordingTimer?.cancel();
    _recordingElapsed = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordingElapsed += const Duration(seconds: 1));
    });

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecordingAndSend() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    final path = await _audioRecorder.stop();
    final recordingPath = path;
    final elapsed = _recordingElapsed;

    setState(() {
      _isRecording = false;
      _recordingElapsed = Duration.zero;
    });

    if (recordingPath == null || !File(recordingPath).existsSync()) return;

    Duration duration = elapsed;
    if (duration == Duration.zero) {
      final probe = AudioPlayer();
      try {
        await probe.setFilePath(recordingPath);
        duration = probe.duration ?? Duration.zero;
      } finally {
        await probe.dispose();
      }
    }

    setState(() {
      _messages.add(
        ChatMessage.userAudio(path: recordingPath, duration: duration),
      );
    });
    _scrollToBottom();
    _beginAiReply(audioFile: File(recordingPath));
  }

  Future<void> _toggleAudioPlayback(String path) async {
    if (_playingAudioPath == path && _audioPlayer.playing) {
      await _audioPlayer.pause();
      setState(() => _playingAudioPath = null);
      return;
    }

    if (_playingAudioPath == path && !_audioPlayer.playing) {
      await _audioPlayer.play();
      setState(() => _playingAudioPath = path);
      return;
    }

    await _audioPlayer.stop();
    await _audioPlayer.setFilePath(path);
    await _audioPlayer.play();
    setState(() => _playingAudioPath = path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      appBar: AppBar(
        title: Text('ai_chat_title'.tr()),
        backgroundColor: ColorManager.whiteColor,
        foregroundColor: ColorManager.mainColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'ai_chat_empty'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: ColorManager.grayTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      if (m.kind == ChatMessageKind.aiThinking) {
                        return const _AiThinkingBubble();
                      }
                      if (m.kind == ChatMessageKind.aiHtml) {
                        return _AiHtmlBubble(html: m.html!);
                      }
                      if (m.kind == ChatMessageKind.userAudio) {
                        return _OutgoingAudioBubble(
                          filePath: m.audioPath!,
                          duration: m.audioDuration ?? Duration.zero,
                          isPlaying: _playingAudioPath == m.audioPath &&
                              _audioPlayer.playing,
                          onTogglePlay: () =>
                              unawaited(_toggleAudioPlayback(m.audioPath!)),
                          formatDuration: _formatDuration,
                        );
                      }
                      return _OutgoingBubble(text: m.text!);
                    },
                  ),
          ),
          Material(
            elevation: 6,
            color: ColorManager.whiteColor,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: _isRecording
                          ? 'ai_chat_stop_record'.tr()
                          : 'ai_chat_record'.tr(),
                      onPressed:
                          _isAwaitingAiReply ? null : () => unawaited(_toggleRecording()),
                      icon: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: _isRecording
                            ? Colors.red
                            : (_isAwaitingAiReply
                                ? ColorManager.grayTextColor
                                : ColorManager.mainColor),
                      ),
                    ),
                    if (_isRecording)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, right: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${'ai_chat_recording'.tr()} ${_formatDuration(_recordingElapsed)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        enabled: !_isAwaitingAiReply && !_isRecording,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'ai_chat_input_hint'.tr(),
                          filled: true,
                          fillColor: ColorManager.backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'ai_chat_send'.tr(),
                      onPressed:
                          (_isAwaitingAiReply || _isRecording) ? null : _sendText,
                      icon: Icon(
                        Icons.send_rounded,
                        color: _isAwaitingAiReply
                            ? ColorManager.grayTextColor
                            : ColorManager.mainColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiThinkingBubble extends StatefulWidget {
  const _AiThinkingBubble();

  @override
  State<_AiThinkingBubble> createState() => _AiThinkingBubbleState();
}

class _AiThinkingBubbleState extends State<_AiThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kChatMessageGap),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ColorManager.whiteColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: ColorManager.mainColor.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 8),
                Text(
                  'ai_chat_thinking'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.mainColor.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final phase = (_controller.value + i * 0.2) % 1.0;
                        final opacity = 0.35 + (phase < 0.5 ? phase : 1 - phase);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Opacity(
                            opacity: opacity.clamp(0.35, 1.0),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: ColorManager.mainColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AiHtmlBubble extends StatelessWidget {
  const _AiHtmlBubble({required this.html});

  final String html;

  static final RegExp _tableTagPattern = RegExp(
    r'<table\b',
    caseSensitive: false,
  );

  bool get _containsTable => _tableTagPattern.hasMatch(html);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final listPadding = 32.0;
    final reportWidth = screenWidth - listPadding;

    if (isFullHtmlDocument(html)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: _kChatMessageGap),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AiReportWebView(
            html: html,
            maxWidth: reportWidth,
          ),
        ),
      );
    }

    final maxBubbleWidth = screenWidth * 0.88;

    final htmlContent = HtmlWidget(
      html,
      textStyle: const TextStyle(
        fontSize: 15,
        height: 1.4,
        color: ColorManager.mainColor,
      ),
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'table':
            return {
              'border-collapse': 'collapse',
              'width': '100%',
              'min-width': '280px',
            };
          case 'th':
          case 'td':
            return {'vertical-align': 'top'};
          default:
            return null;
        }
      },
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: _kChatMessageGap),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ColorManager.whiteColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              child: _containsTable
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: maxBubbleWidth),
                        child: htmlContent,
                      ),
                    )
                  : htmlContent,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutgoingAudioBubble extends StatelessWidget {
  const _OutgoingAudioBubble({
    required this.filePath,
    required this.duration,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.formatDuration,
  });

  final String filePath;
  final Duration duration;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kChatMessageGap),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ColorManager.mainColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: ColorManager.mainColor.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.72,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: ColorManager.whiteColor.withValues(alpha: 0.2),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onTogglePlay,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: ColorManager.whiteColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ai_chat_voice_message'.tr(),
                        style: const TextStyle(
                          color: ColorManager.whiteColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDuration(duration),
                        style: TextStyle(
                          color: ColorManager.whiteColor.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutgoingBubble extends StatelessWidget {
  const _OutgoingBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kChatMessageGap),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ColorManager.mainColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: ColorManager.mainColor.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: ColorManager.whiteColor,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
