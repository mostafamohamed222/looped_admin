import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders dashboard HTML reports in a WebView with mobile-first layout overrides.
class AiReportWebView extends StatefulWidget {
  const AiReportWebView({
    super.key,
    required this.html,
    required this.maxWidth,
    this.previewHeight = 200,
  });

  final String html;
  final double maxWidth;

  /// Compact thumbnail height in the chat bubble.
  final double previewHeight;

  @override
  State<AiReportWebView> createState() => _AiReportWebViewState();
}

class _AiReportWebViewState extends State<AiReportWebView> {
  static const _mobileCss = '''
html, body {
  margin: 0 !important;
  padding: 0 !important;
  width: 100% !important;
  max-width: 100% !important;
  overflow-x: auto !important;
  overflow-y: auto !important;
  -webkit-overflow-scrolling: touch;
  -webkit-text-size-adjust: 100%;
  word-wrap: break-word;
}
main.wrap, .wrap, main, body > div:first-child {
  min-width: 0 !important;
  max-width: 100% !important;
  width: 100% !important;
  box-sizing: border-box !important;
  padding-left: 12px !important;
  padding-right: 12px !important;
}
.grid, .cards, .kpi-row, .stats, .metrics, .row-cards,
[style*="grid-template-columns"] {
  display: flex !important;
  flex-direction: column !important;
  gap: 10px !important;
  width: 100% !important;
  max-width: 100% !important;
}
.grid > *, .cards > *, .kpi-row > *, .stats > *, .metrics > *,
[style*="grid-template-columns"] > * {
  width: 100% !important;
  max-width: 100% !important;
  min-width: 0 !important;
}
h1 { font-size: 1.35rem !important; line-height: 1.3 !important; }
h2 { font-size: 1.15rem !important; line-height: 1.3 !important; }
h3 { font-size: 1rem !important; }
p, li, td, th, span, div { max-width: 100%; }
img, svg, canvas { max-width: 100% !important; height: auto !important; }
.flutter-table-scroll {
  overflow-x: auto !important;
  -webkit-overflow-scrolling: touch;
  max-width: 100% !important;
  margin-bottom: 8px;
}
.flutter-table-scroll table {
  min-width: 0 !important;
  width: auto !important;
  font-size: 12px !important;
}
th, td { padding: 6px 8px !important; white-space: normal !important; }
''';

  static const _previewClipCss = '''
html, body {
  overflow: hidden !important;
}
''';

  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = _createController(widget.html)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            await _injectMobileLayout(
              _controller,
              preview: true,
              viewportWidth: widget.maxWidth,
            );
            if (mounted) setState(() => _loading = false);
          },
        ),
      );
  }

  static WebViewController _createController(String html) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..loadHtmlString(
        _prepareHtmlForMobile(html),
        baseUrl: 'https://fonts.googleapis.com/',
      );
  }

  static String _prepareHtmlForMobile(String html) {
    const viewport =
        '<meta name="viewport" content="width=device-width, initial-scale=1, '
        'maximum-scale=5, user-scalable=yes">';
    final lower = html.toLowerCase();
    if (lower.contains('name="viewport"') ||
        lower.contains("name='viewport'")) {
      return html;
    }
    final headMatch = RegExp(r'<head[^>]*>', caseSensitive: false).firstMatch(html);
    if (headMatch != null) {
      return html.replaceFirst(headMatch.group(0)!, '${headMatch.group(0)}$viewport');
    }
    final htmlMatch =
        RegExp(r'<html[^>]*>', caseSensitive: false).firstMatch(html);
    if (htmlMatch != null) {
      return html.replaceFirst(
        htmlMatch.group(0)!,
        '${htmlMatch.group(0)}<head>$viewport</head>',
      );
    }
    return '<!DOCTYPE html><html><head>$viewport</head><body>$html</body></html>';
  }

  static Future<void> _injectMobileLayout(
    WebViewController controller, {
    required bool preview,
    required double viewportWidth,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final css = preview ? '$_mobileCss\n$_previewClipCss' : _mobileCss;
    try {
      await controller.runJavaScript('''
(function() {
  var css = ${jsonEncode(css)};
  var existing = document.getElementById('flutter-scroll-assist');
  if (existing) existing.remove();
  var s = document.createElement('style');
  s.id = 'flutter-scroll-assist';
  s.textContent = css;
  document.head.appendChild(s);

  document.querySelectorAll('table').forEach(function(table) {
    var parent = table.parentElement;
    if (!parent || parent.classList.contains('flutter-table-scroll')) return;
    var wrap = document.createElement('div');
    wrap.className = 'flutter-table-scroll';
    parent.insertBefore(wrap, table);
    wrap.appendChild(table);
  });

  var root = document.querySelector('main.wrap')
    || document.querySelector('.wrap')
    || document.querySelector('main')
    || document.body;
  var contentW = Math.max(
    root.scrollWidth, root.offsetWidth,
    document.documentElement.scrollWidth,
    document.body.scrollWidth,
    window.innerWidth || 0
  );
  var viewW = ${viewportWidth.toString()};
  var vp = document.querySelector('meta[name="viewport"]');
  if (!vp) {
    vp = document.createElement('meta');
    vp.name = 'viewport';
    document.head.appendChild(vp);
  }
  var preview = ${preview ? 'true' : 'false'};
  if (preview) {
    var scale = Math.min(1, viewW / Math.max(contentW, 1));
    vp.content = 'width=' + Math.round(contentW)
      + ', initial-scale=' + scale.toFixed(4)
      + ', maximum-scale=5, user-scalable=yes';
  } else {
    vp.content = 'width=device-width, initial-scale=1, maximum-scale=5, user-scalable=yes';
  }
})()
''');
    } catch (_) {}
  }

  void _openFullscreen() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => AiReportFullscreenPage(html: widget.html),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loading ? null : _openFullscreen,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: widget.maxWidth,
          height: widget.previewHeight,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: IgnorePointer(
                  child: WebViewWidget(controller: _controller),
                ),
              ),
              if (!_loading)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        stops: const [0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              if (!_loading)
                PositionedDirectional(
                  start: 10,
                  end: 10,
                  bottom: 10,
                  child: Row(
                    children: [
                      Icon(
                        Icons.open_in_full_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'ai_chat_report_tap_open'.tr(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_loading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0xFF0F172A),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen report viewer — entire response scrollable vertically and horizontally.
class AiReportFullscreenPage extends StatefulWidget {
  const AiReportFullscreenPage({super.key, required this.html});

  final String html;

  @override
  State<AiReportFullscreenPage> createState() => _AiReportFullscreenPageState();
}

class _AiReportFullscreenPageState extends State<AiReportFullscreenPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = _AiReportWebViewState._createController(widget.html)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            if (!mounted) return;
            final width = MediaQuery.sizeOf(context).width;
            await _AiReportWebViewState._injectMobileLayout(
              _controller,
              preview: false,
              viewportWidth: width,
            );
            if (mounted) setState(() => _loading = false);
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text('ai_chat_report_fullscreen'.tr()),
        backgroundColor: ColorManager.whiteColor,
        foregroundColor: ColorManager.mainColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
            gestureRecognizers:
                <Factory<OneSequenceGestureRecognizer>>{
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
              Factory<HorizontalDragGestureRecognizer>(
                () => HorizontalDragGestureRecognizer(),
              ),
            },
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
        ],
      ),
    );
  }
}

bool isFullHtmlDocument(String html) {
  final trimmed = html.trimLeft().toLowerCase();
  if (trimmed.startsWith('<!doctype') || trimmed.startsWith('<html')) {
    return true;
  }
  return trimmed.contains('<head') &&
      (trimmed.contains('<style') || trimmed.contains('<link'));
}
