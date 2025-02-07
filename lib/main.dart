import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DocViewer(),
    );
  }
}

class DocViewer extends StatefulWidget {
  const DocViewer({super.key});

  @override
  State<DocViewer> createState() => _DocViewerState();
}

class _DocViewerState extends State<DocViewer> {
  late WebViewController _controller;
  String? _fileUrl;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 1️⃣ Запрашиваем разрешения (только для Android)
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    // 2️⃣ Копируем .doc из assets в локальную папку
    final String filePath = await _copyAssetToLocal('assets/sample.doc');

    // 3️⃣ Формируем file:// URL
    setState(() {
      _fileUrl = 'file://$filePath';
    });

    // 4️⃣ Загружаем файл в WebView
    _controller.loadRequest(Uri.parse(_fileUrl!));
  }

  Future<String> _copyAssetToLocal(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/sample.doc');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DOC Viewer')),
      body: _fileUrl == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(
        controller: _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(_fileUrl!)),
      ),
    );
  }
}
