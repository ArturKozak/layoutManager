import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutLinkDisplay extends StatefulWidget {
  final String link;
  final PreferredSizeWidget? appBar;
  const LayoutLinkDisplay({required this.link, this.appBar, super.key});

  @override
  State<LayoutLinkDisplay> createState() => _LayoutLinkDisplayState();
}

class _LayoutLinkDisplayState extends State<LayoutLinkDisplay> {
  late WebViewController controller;
  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(),
      )
      ..loadRequest(Uri.parse(widget.link));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: WebViewWidget(controller: controller),
    );
  }
}
