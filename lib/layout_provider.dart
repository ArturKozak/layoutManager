import 'package:flutter/material.dart';
import 'package:layout_manager/layout_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutProvider extends StatefulWidget {
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
  State<LayoutProvider> createState() => _LayoutProviderState();
}

class _LayoutProviderState extends State<LayoutProvider> {
  bool urlStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: FutureBuilder<String?>(
        future: LayoutManager.configurateLayout(widget.label, widget.uuid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }

          if (!snapshot.hasData) {
            return widget.responseWidget;
          }

          final data = snapshot.data;

          if (data == null) {
            return widget.responseWidget;
          }

          final url = Uri.tryParse(data);

          if (url == null) {
            return widget.responseWidget;
          }

          final webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(widget.backgroundColor)
            ..loadRequest(Uri.parse(data))
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (String url) async {
                  final status = await LayoutManager.getLayoutLimiter(
                    widget.label,
                    widget.limiter,
                    url,
                  );

                  setState(() {
                    urlStatus = status;
                  });
                },
                onPageFinished: (String url) async {
                  final status = await LayoutManager.getLayoutLimiter(
                    widget.label,
                    widget.limiter,
                    url,
                  );

                  setState(() {
                    urlStatus = status;
                  });
                },
              ),
            );

          if (urlStatus) {
            return widget.responseWidget;
          } else {
            return WebViewWidget(controller: webViewController);
          }
        },
      ),
    );
  }
}
