import 'package:flutter/material.dart';
import 'package:layout_manager/layout_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutProvider extends StatelessWidget {
  final String uuid;
  final String? label;
  final Color? backgroundCoor;
  final Widget responseWidget;
  const LayoutProvider({
    required this.uuid,
    required this.responseWidget,
    this.label,
    this.backgroundCoor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundCoor,
      body: FutureBuilder<String?>(
        future: LayoutManager.configurateLayout(label, uuid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }

          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final data = snapshot.data;

          if (data == null) {
            return responseWidget;
          }

          final webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(data));

          return WebViewWidget(controller: webViewController);
        },
      ),
    );
  }
}
