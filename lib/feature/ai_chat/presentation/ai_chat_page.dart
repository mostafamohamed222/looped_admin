import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ChatMessage {
  ChatMessage._({this.text, this.voiceDuration, this.voicePath})
      : assert(text != null || voiceDuration != null);

  factory ChatMessage.text(String value) => ChatMessage._(text: value);

  factory ChatMessage.voice({
    required Duration duration,
    String? path,
  }) =>
      ChatMessage._(voiceDuration: duration, voicePath: path);

  final String? text;
  final Duration? voiceDuration;
  final String? voicePath;
}

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _voicePlayer = AudioPlayer();

  final List<ChatMessage> _messages = [];

  bool _isRecording = false;
  DateTime? _recordStartedAt;
  Timer? _recordingTicker;
  int? _playingMessageIndex;
  StreamSubscription<void>? _voiceCompleteSub;

  @override
  void initState() {
    super.initState();
    _voiceCompleteSub = _voicePlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingMessageIndex = null);
    });
  }

  @override
  void dispose() {
    _voiceCompleteSub?.cancel();
    unawaited(_voicePlayer.dispose());
    _recordingTicker?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    unawaited(_disposeRecorder());
    super.dispose();
  }

  Future<void> _disposeRecorder() async {
    try {
      if (_isRecording) {
        await _recorder.cancel();
      }
      await _recorder.dispose();
    } catch (_) {}
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

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Duration get _elapsedRecording {
    final start = _recordStartedAt;
    if (start == null) return Duration.zero;
    return DateTime.now().difference(start);
  }

  Future<void> _startRecording() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ai_chat_voice_web_unsupported'.tr())),
      );
      return;
    }
    try {
      final permitted = await _recorder.hasPermission();
      if (!permitted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ai_chat_mic_denied'.tr())),
        );
        return;
      }

      var encoder = AudioEncoder.aacLc;
      if (!await _recorder.isEncoderSupported(encoder)) {
        encoder = AudioEncoder.wav;
      }

      final dir = await getTemporaryDirectory();
      final ext = encoder == AudioEncoder.wav ? 'wav' : 'm4a';
      final path =
          '${dir.path}/ai_chat_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _recorder.start(RecordConfig(encoder: encoder), path: path);

      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _recordStartedAt = DateTime.now();
      });

      _recordingTicker?.cancel();
      _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ai_chat_record_error'.tr())),
      );
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    _recordingTicker?.cancel();
    final started = _recordStartedAt ?? DateTime.now();

    String? filePath;
    try {
      filePath = await _recorder.stop();
    } catch (_) {}

    if (!mounted) return;
    final duration = DateTime.now().difference(started);
    setState(() {
      _isRecording = false;
      _recordStartedAt = null;
      if (duration.inMilliseconds >= 400) {
        _messages.add(ChatMessage.voice(duration: duration, path: filePath));
      }
    });
    _scrollToBottom();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage.text(text));
      _textController.clear();
    });
    _scrollToBottom();
  }

  Future<void> _toggleVoicePlayback(int messageIndex, String path) async {
    if (path.isEmpty) return;
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ai_chat_playback_web_unsupported'.tr())),
      );
      return;
    }
    try {
      if (_playingMessageIndex == messageIndex) {
        await _voicePlayer.stop();
        if (mounted) setState(() => _playingMessageIndex = null);
        return;
      }
      await _voicePlayer.stop();
      await _voicePlayer.play(DeviceFileSource(path));
      if (!mounted) return;
      setState(() => _playingMessageIndex = messageIndex);
    } catch (_) {
      if (!mounted) return;
      setState(() => _playingMessageIndex = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ai_chat_playback_error'.tr())),
      );
    }
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
                      final path = m.voicePath;
                      final canPlayVoice =
                          !kIsWeb && path != null && path.isNotEmpty;
                      return _OutgoingBubble(
                        message: m,
                        formatDuration: _formatDuration,
                        isVoicePlaying: _playingMessageIndex == index,
                        canPlayVoice: canPlayVoice,
                        onVoicePlayTap: canPlayVoice
                            ? () => unawaited(
                                  _toggleVoicePlayback(index, path),
                                )
                            : null,
                      );
                    },
                  ),
          ),
          Material(
            elevation: 6,
            color: ColorManager.whiteColor,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: _isRecording
                          ? 'ai_chat_stop_recording'.tr()
                          : 'ai_chat_start_recording'.tr(),
                      onPressed: () => unawaited(_toggleRecording()),
                      icon: Icon(
                        _isRecording
                            ? Icons.stop_rounded
                            : Icons.mic_none_rounded,
                        size: 26,
                        color: _isRecording
                            ? Colors.red.shade700
                            : ColorManager.mainColor,
                      ),
                    ),
                    Expanded(
                      child: _isRecording
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fiber_manual_record,
                                    size: 14,
                                    color: Colors.red.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${'ai_chat_recording'.tr()} · ${_formatDuration(_elapsedRecording)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: ColorManager.mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : TextField(
                              controller: _textController,
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
                      onPressed: _isRecording ? null : _sendText,
                      icon: Icon(
                        Icons.send_rounded,
                        color: _isRecording
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

class _OutgoingBubble extends StatelessWidget {
  const _OutgoingBubble({
    required this.message,
    required this.formatDuration,
    required this.isVoicePlaying,
    required this.canPlayVoice,
    this.onVoicePlayTap,
  });

  final ChatMessage message;
  final String Function(Duration) formatDuration;
  final bool isVoicePlaying;
  final bool canPlayVoice;
  final VoidCallback? onVoicePlayTap;

  @override
  Widget build(BuildContext context) {
    final isVoice = message.voiceDuration != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            padding: const EdgeInsetsDirectional.only(
              start: 6,
              end: 10,
              top: 6,
              bottom: 6,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              child: isVoice
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: isVoicePlaying
                              ? 'ai_chat_stop_voice'.tr()
                              : 'ai_chat_play_voice'.tr(),
                          onPressed: canPlayVoice ? onVoicePlayTap : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: Icon(
                            isVoicePlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: canPlayVoice
                                ? ColorManager.whiteColor
                                : ColorManager.whiteColor
                                    .withValues(alpha: 0.45),
                            size: 28,
                          ),
                        ),
                        const Icon(
                          Icons.graphic_eq_rounded,
                          color: ColorManager.whiteColor,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ai_chat_voice_label'.tr(),
                                style: const TextStyle(
                                  color: ColorManager.whiteColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatDuration(message.voiceDuration!),
                                style: TextStyle(
                                  color: ColorManager.whiteColor
                                      .withValues(alpha: 0.92),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        message.text!,
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
      ),
    );
  }
}
