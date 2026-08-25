// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Web-only scanner. It requests camera access before opening the preview and
/// uses the browser's native BarcodeDetector API when that API is available.
Future<String?> scanBarcode(BuildContext context) async {
  final mediaDevices = html.window.navigator.mediaDevices;
  if (mediaDevices == null || !js_util.hasProperty(html.window, 'BarcodeDetector')) {
    throw StateError('Camera barcode detection is not supported by this browser.');
  }

  final stream = await mediaDevices.getUserMedia({'video': true});
  final viewType = 'stocksense-barcode-video-${DateTime.now().microsecondsSinceEpoch}';
  final video = html.VideoElement()
    ..autoplay = true
    ..muted = true
    ..playsInline = true
    ..srcObject = stream
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.objectFit = 'cover';

  ui_web.platformViewRegistry.registerViewFactory(viewType, (_) => video);

  try {
    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _WebBarcodeScannerDialog(
        viewType: viewType,
        video: video,
      ),
    );
  } finally {
    for (final track in stream.getTracks()) {
      track.stop();
    }
    video.pause();
    video.srcObject = null;
  }
}

class _WebBarcodeScannerDialog extends StatefulWidget {
  const _WebBarcodeScannerDialog({
    required this.viewType,
    required this.video,
  });

  final String viewType;
  final html.VideoElement video;

  @override
  State<_WebBarcodeScannerDialog> createState() => _WebBarcodeScannerDialogState();
}

class _WebBarcodeScannerDialogState extends State<_WebBarcodeScannerDialog> {
  dynamic _detector;
  bool _isDetecting = false;
  bool _isClosed = false;

  @override
  void initState() {
    super.initState();
    _detector = js_util.callConstructor(
      js_util.getProperty(html.window, 'BarcodeDetector'),
      const [],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _detectBarcode());
  }

  Future<void> _detectBarcode() async {
    while (mounted && !_isClosed) {
      if (!_isDetecting && widget.video.readyState >= 2) {
        _isDetecting = true;
        try {
          final promise = js_util.callMethod<Object>(
            _detector,
            'detect',
            [widget.video],
          );
          final codes = await js_util.promiseToFuture<List<dynamic>>(promise);
          if (codes.isNotEmpty) {
            final rawValue = js_util.getProperty<String?>(codes.first, 'rawValue');
            if (rawValue != null && rawValue.trim().isNotEmpty && mounted) {
              _isClosed = true;
              Navigator.of(context).pop(rawValue.trim());
              return;
            }
          }
        } catch (_) {
          if (mounted) {
            _isClosed = true;
            Navigator.of(context).pop();
          }
          return;
        } finally {
          _isDetecting = false;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scan barcode'),
      content: SizedBox(
        width: 480,
        height: 320,
        child: HtmlElementView(viewType: widget.viewType),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _isClosed = true;
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
