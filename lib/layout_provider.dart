import 'package:flutter/material.dart';
import 'package:layout_manager/layout_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutProvider extends StatelessWidget {
  final String uuid;
  final String limiter;
  final String? label;
  final Color backgroundColor;
  final Widget responseWidget;
  const LayoutProvider({
    required this.uuid,
    required this.responseWidget,
    required this.backgroundColor,
    required this.limiter,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<String?>(
        future: LayoutManager.configurateLayout(label, uuid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }

          if (!snapshot.hasData) {
            return responseWidget;
          }

          final data = snapshot.data;

          if (data == null) {
            return responseWidget;
          }

          final url = Uri.tryParse(data);

          if (url == null) {
            return responseWidget;
          }

          final webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(backgroundColor)
            ..loadRequest(Uri.parse(data));

          return FutureBuilder<bool>(
            future: LayoutManager.getLayoutLimiter(
              label,
              limiter,
              webViewController.currentUrl(),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }

              if (!snapshot.hasData) {
                return responseWidget;
              }

              final data = snapshot.data;

              if (data == null) {
                return responseWidget;
              }

              if (!data) {
                return responseWidget;
              }

              return WebViewWidget(controller: webViewController);
            },
          );
        },
      ),
    );
  }
}
