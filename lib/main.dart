import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOC Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DocViewer(),
    );
  }
}

class DocViewer extends StatefulWidget {
  const DocViewer({super.key});

  @override
  State<DocViewer> createState() => _DocViewerState();
}

class _DocViewerState extends State<DocViewer> {
  InAppWebViewController? webViewController;
  String? fileUrl;

  @override
  void initState() {
    super.initState();
    _loadDocFile();
  }

  Future<void> _loadDocFile() async {
    // Request storage permission (only required for Android)
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    // Get application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/sample.doc';

    // Copy sample.doc from assets to app storage (if needed)
    final file = File(filePath);
    if (!file.existsSync()) {
      final byteData = await DefaultAssetBundle.of(context).load("assets/sample.doc");
      final buffer = byteData.buffer;
      await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }

    // Set file URL for WebView
    setState(() {
      fileUrl = "file://$filePath";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DOC Viewer")),
      body: fileUrl == null
          ? const Center(child: CircularProgressIndicator())
          : InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(fileUrl!)),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
      ),
    );
  }
}
