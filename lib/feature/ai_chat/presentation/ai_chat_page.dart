import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/feature/ai_chat/data/ai_chat_service.dart';
import 'package:looped_admin/feature/ai_chat/presentation/widgets/ai_report_web_view.dart';

enum ChatMessageKind { userText, aiThinking, aiHtml }

/// Vertical gap between consecutive chat rows.
const double _kChatMessageGap = 4;

class ChatMessage {
  ChatMessage._({required this.kind, this.text, this.html});

  factory ChatMessage.userText(String value) =>
      ChatMessage._(kind: ChatMessageKind.userText, text: value);

  ChatMessage.aiThinking() : this._(kind: ChatMessageKind.aiThinking);

  factory ChatMessage.aiHtml(String value) =>
      ChatMessage._(kind: ChatMessageKind.aiHtml, html: value);

  final ChatMessageKind kind;
  final String? text;
  final String? html;
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

  final List<ChatMessage> _messages = [];
  bool _isAwaitingAiReply = false;
  int _replySeq = 0;

  @override
  void dispose() {
    _replySeq++;
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _fetchAiReply(String userText, int seq) async {
    try {
      final html = await _chatService.fetchHtmlReply(
        text: userText,
        language: context.locale.languageCode,
      );
      if (!mounted || seq != _replySeq) return;
      setState(() {
        _removeThinkingIndicator();
        _messages.add(ChatMessage.aiHtml(html));
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

  void _beginAiReply(String userText) {
    setState(() {
      _messages.add(ChatMessage.aiThinking());
      _isAwaitingAiReply = true;
    });
    _scrollToBottom();
    final seq = ++_replySeq;
    unawaited(_fetchAiReply(userText, seq));
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isAwaitingAiReply) return;
    setState(() {
      _messages.add(ChatMessage.userText(text));
      _textController.clear();
    });
    _scrollToBottom();
    _beginAiReply(text);
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
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        enabled: !_isAwaitingAiReply,
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
                      onPressed: _isAwaitingAiReply ? null : _sendText,
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
