import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:layout_manager/layout_manager.dart';
import 'package:layout_manager/loading_mixin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutProvider extends StatefulWidget {
  final String uuid;
  final String limiter;
  final String? label;
  final Color backgroundColor;
  final Widget responseWidget;
  final Widget? splashWidget;
  final Function(bool)? onLimitedLayoutChanged;

  const LayoutProvider({
    required this.uuid,
    required this.responseWidget,
    required this.backgroundColor,
    required this.limiter,
    this.label,
    this.onLimitedLayoutChanged,
    this.splashWidget,
    super.key,
  });

  @override
  State<LayoutProvider> createState() => _LayoutProviderState();
}

class _LayoutProviderState extends State<LayoutProvider>
    with LoadingMixin<LayoutProvider> {
  WebViewController? webViewController;
  late final StreamSubscription _onSubscription;
  bool isLimitedLayout = false;

  bool isOffline = false;
  String? fetchData;

  Future<void> _loadConnectionChecker() async {
    _onSubscription =
        Connectivity().onConnectivityChanged.listen((connectivityResult) async {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.ethernet) {
        setState(() {
          reload();

          isOffline = false;
        });
      }

      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          reload();

          isOffline = true;
        });
      }
    });

    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet) {
      setState(() {
        isOffline = false;
      });
    }

    if (result == ConnectivityResult.none) {
      setState(() {
        isOffline = true;
      });
    }
  }

  @override
  Future<void> load() async {
    fetchData = await LayoutManager.configurateLayout(
      functionName: widget.label,
      uuid: widget.uuid,
    );

    if (fetchData != null) {
      if (widget.onLimitedLayoutChanged != null) {
        widget.onLimitedLayoutChanged!.call(false);
      }

      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(widget.backgroundColor)
        ..loadRequest(Uri.parse(fetchData!))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) async {
              final status = await LayoutManager.getLayoutLimiter(
                widget.label,
                widget.limiter,
                url,
              );

              setState(() {
                isLimitedLayout = status;

                if (widget.onLimitedLayoutChanged != null) {
                  widget.onLimitedLayoutChanged!.call(status);
                }
              });
            },
            onPageFinished: (String url) async {
              final status = await LayoutManager.getLayoutLimiter(
                widget.label,
                widget.limiter,
                url,
              );

              setState(() {
                isLimitedLayout = status;

                if (widget.onLimitedLayoutChanged != null) {
                  widget.onLimitedLayoutChanged!.call(status);
                }
              });
            },
          ),
        );

      return;
    }

    if (widget.onLimitedLayoutChanged != null) {
      widget.onLimitedLayoutChanged!.call(true);
    }

    await _loadConnectionChecker();

    return;
  }

  @override
  void dispose() {
    _onSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: LayoutBuilder(
        builder: (context, snapshot) {
          if (loading) {
            return widget.splashWidget ?? const SizedBox();
          }

          if (webViewController == null) {
            return widget.responseWidget;
          }

          if (isOffline) {
            return widget.responseWidget;
          }

          if (isLimitedLayout) {
            return widget.responseWidget;
          } else {
            return WebViewWidget(controller: webViewController!);
          }
        },
      ),
    );
  }
}
