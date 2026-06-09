// import 'dart:async';
// import 'dart:convert';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:looped_admin/core/res/color_manager.dart';
// import 'package:pointer_interceptor/pointer_interceptor.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// /// Renders a full HTML document (dashboard reports) using a real WebView so
// /// CSS grid, external fonts, and media queries match the web admin experience.
// class AiReportWebView extends StatefulWidget {
//   const AiReportWebView({
//     super.key,
//     required this.html,
//     required this.maxWidth,
//     this.maxHeightFactor = 0.72,
//   });

//   final String html;
//   final double maxWidth;
//   final double maxHeightFactor;

//   @override
//   State<AiReportWebView> createState() => _AiReportWebViewState();
// }

// class _AiReportWebViewState extends State<AiReportWebView> {
//   static const _scrollAssistCss = '''
// html, body {
//   margin: 0 !important;
//   overflow: auto !important;
//   -webkit-overflow-scrolling: touch;
//   height: auto !important;
//   min-height: 0 !important;
// }
// main.wrap, .wrap {
//   min-width: max(100%, 920px);
//   box-sizing: border-box;
// }
// table {
//   min-width: 640px;
// }
// ''';

//   static const _contentHeightScript = '''
// (function() {
//   var root = document.querySelector('main.wrap')
//     || document.querySelector('.wrap')
//     || document.querySelector('main')
//     || document.body;
//   var el = document.documentElement;
//   return Math.ceil(Math.max(
//     root.scrollHeight, root.offsetHeight,
//     el.scrollHeight, el.offsetHeight
//   ));
// })()
// ''';

//   late final WebViewController _controller;
//   double _height = 200;
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller = _createController(widget.html)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (_) async {
//             await _injectScrollAssist(_controller);
//             await _syncContentHeight();
//           },
//         ),
//       );
//   }

//   static WebViewController _createController(String html) {
//     return WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0xFF0F172A))
//       ..loadHtmlString(html, baseUrl: 'https://fonts.googleapis.com/');
//   }

//   static Future<void> _injectScrollAssist(WebViewController controller) async {
//     await Future<void>.delayed(const Duration(milliseconds: 350));
//     try {
//       await controller.runJavaScript('''
// (function() {
//   var existing = document.getElementById('flutter-scroll-assist');
//   if (existing) existing.remove();
//   var s = document.createElement('style');
//   s.id = 'flutter-scroll-assist';
//   s.textContent = ${jsonEncode(_scrollAssistCss)};
//   document.head.appendChild(s);
// })()
// ''');
//     } catch (_) {}
//   }

//   double get _maxHeight =>
//       MediaQuery.sizeOf(context).height * widget.maxHeightFactor;

//   Future<void> _syncContentHeight() async {
//     await Future<void>.delayed(const Duration(milliseconds: 150));
//     if (!mounted) return;

//     double measured = 320;
//     try {
//       final result = await _controller.runJavaScriptReturningResult(
//         _contentHeightScript,
//       );
//       measured = _parseJsNumber(result) ?? measured;
//     } catch (_) {}

//     if (!mounted) return;
//     setState(() {
//       _height = measured.clamp(120.0, _maxHeight);
//       _loading = false;
//     });
//   }

//   static double? _parseJsNumber(dynamic value) {
//     if (value == null) return null;
//     final cleaned = value.toString().replaceAll('"', '').trim();
//     return double.tryParse(cleaned);
//   }

//   void _openFullscreen() {
//     Navigator.of(context, rootNavigator: true).push<void>(
//       MaterialPageRoute<void>(
//         fullscreenDialog: true,
//         builder: (ctx) => AiReportFullscreenPage(html: widget.html),
//       ),
//     );
//   }

//   Widget _buildTapOverlay() {
//     return Positioned.fill(
//       child: PointerInterceptor(
//         child: InkWell(
//           onTap: _openFullscreen,
//           borderRadius: BorderRadius.circular(10),
//           child: Container(
//             height: 200,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Align(
//                   alignment: AlignmentDirectional.bottomCenter,
//                   child: DecoratedBox(
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.vertical(
//                         bottom: Radius.circular(10),
//                       ),
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withValues(alpha: 0.55),
//                         ],
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.open_in_full_rounded,
//                             color: Colors.white70,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 6),
//                           Expanded(
//                             child: Text(
//                               'ai_chat_report_tap_open'.tr(),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: widget.maxWidth,
//       height: _height,
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: IgnorePointer(
//               child: WebViewWidget(controller: _controller),
//             ),
//           ),
//           if (!_loading) _buildTapOverlay(),
//           if (_loading)
//             const Positioned.fill(
//               child: ColoredBox(
//                 color: Color(0xFF0F172A),
//                 child: Center(
//                   child: SizedBox(
//                     width: 28,
//                     height: 28,
//                     child: CircularProgressIndicator(strokeWidth: 2.5),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// /// Full-screen report viewer — entire response scrollable vertically and horizontally.
// class AiReportFullscreenPage extends StatefulWidget {
//   const AiReportFullscreenPage({super.key, required this.html});

//   final String html;

//   @override
//   State<AiReportFullscreenPage> createState() => _AiReportFullscreenPageState();
// }

// class _AiReportFullscreenPageState extends State<AiReportFullscreenPage> {
//   late final WebViewController _controller;
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller = _AiReportWebViewState._createController(widget.html)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (_) async {
//             await _AiReportWebViewState._injectScrollAssist(_controller);
//             if (mounted) setState(() => _loading = false);
//           },
//         ),
//       );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       appBar: AppBar(
//         title: Text('ai_chat_report_fullscreen'.tr()),
//         backgroundColor: ColorManager.whiteColor,
//         foregroundColor: ColorManager.mainColor,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(
//             controller: _controller,
//             gestureRecognizers:
//                 <Factory<OneSequenceGestureRecognizer>>{
//               Factory<VerticalDragGestureRecognizer>(
//                 () => VerticalDragGestureRecognizer(),
//               ),
//               Factory<HorizontalDragGestureRecognizer>(
//                 () => HorizontalDragGestureRecognizer(),
//               ),
//             },
//           ),
//           if (_loading)
//             const Center(
//               child: CircularProgressIndicator(strokeWidth: 2.5),
//             ),
//         ],
//       ),
//     );
//   }
// }

// bool isFullHtmlDocument(String html) {
//   final trimmed = html.trimLeft().toLowerCase();
//   if (trimmed.startsWith('<!doctype') || trimmed.startsWith('<html')) {
//     return true;
//   }
//   return trimmed.contains('<head') &&
//       (trimmed.contains('<style') || trimmed.contains('<link'));
// }
