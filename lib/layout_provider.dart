// ignore_for_file: unused_field

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:layout_manager/layout_manager.dart';
import 'package:layout_manager/loading_mixin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutProvider extends StatefulWidget {
  final Color backgroundColor;
  final Widget responseWidget;
  final Widget offlineWidget;
  final Widget? splashWidget;
  final Function(bool)? onLimitedLayoutChanged;

  const LayoutProvider({
    required this.responseWidget,
    required this.backgroundColor,
    required this.offlineWidget,
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
  bool onStart = false;

  bool isOffline = false;
  String? fetchData;

  Future<void> _loadConnectionChecker() async {
    _onSubscription =
        Connectivity().onConnectivityChanged.listen((connectivityResult) async {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet)) {
        setState(() {
          reload();

          isOffline = false;
        });
      }

      if (connectivityResult.contains(ConnectivityResult.none)) {
        setState(() {
          reload();

          isOffline = true;
        });
      }
    });

    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet)) {
      setState(() {
        isOffline = false;
      });
    }

    if (result.contains(ConnectivityResult.none)) {
      setState(() {
        isOffline = true;
      });
    }
  }

  @override
  Future<void> load() async {
    fetchData = await LayoutManager.instance.configurateLayout();

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
              setState(() {
                onStart = true;
              });
            },
            onPageFinished: (String url) async {
              final status = await LayoutManager.instance.getLayoutLimiter(
                url,
              );

              if (!status) {
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
              }

              isLimitedLayout = status;
              onStart = false;
              if (widget.onLimitedLayoutChanged != null) {
                widget.onLimitedLayoutChanged!.call(status);
              }
              setState(() {});
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isOffline
        ? widget.offlineWidget
        : Scaffold(
            backgroundColor: widget.backgroundColor,
            body: LayoutBuilder(
              builder: (context, snapshot) {
                if (loading) {
                  return widget.splashWidget ??
                      SizedBox.expand(
                        child: ColoredBox(
                          color: widget.backgroundColor,
                          child: const Center(
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      );
                }

                if (webViewController == null) {
                  return widget.responseWidget;
                }

                if (isOffline) {
                  return widget.offlineWidget;
                }

                if (onStart) {
                  return SizedBox.expand(
                    child: ColoredBox(
                      color: widget.backgroundColor,
                      child: const Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  );
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
