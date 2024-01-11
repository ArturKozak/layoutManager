// ignore_for_file: unused_field

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:layout_manager/layout_manager.dart';
import 'package:layout_manager/layout_provider.dart';
import 'package:layout_manager/loading_mixin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutOfferProvider extends StatefulWidget {
  final Color backgroundColor;
  final Widget responseWidget;
  final Widget? offerWidget;
  final Widget? offerDialog;
  final bool isRedirect;
  final Function(bool)? onLimitedLayoutChanged;

  const LayoutOfferProvider({
    required this.responseWidget,
    required this.backgroundColor,
    this.onLimitedLayoutChanged,
    this.offerDialog,
    this.offerWidget,
    this.isRedirect = false,
    super.key,
  });

  @override
  State<LayoutOfferProvider> createState() => _LayoutOfferProviderState();
}

class _LayoutOfferProviderState extends State<LayoutOfferProvider>
    with LoadingMixin<LayoutOfferProvider> {
  WebViewController? webViewController;
  late final StreamSubscription _onSubscription;
  bool isLimitedLayout = false;
  bool onStart = false;

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

                if (widget.onLimitedLayoutChanged != null) {
                  widget.onLimitedLayoutChanged!.call(false);
                }
              });
            },
            onPageFinished: (String url) async {
              final status = await LayoutManager.instance.getLayoutLimiter(
                url,
              );

              setState(() {
                isLimitedLayout = status;
                onStart = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: LayoutBuilder(
        builder: (context, snapshot) {
          if (loading) {
            return SizedBox.expand(
              child: ColoredBox(
                color: widget.backgroundColor,
              ),
            );
          }

          if (webViewController == null) {
            return LayoutProvider(
              responseWidget: widget.responseWidget,
              backgroundColor: widget.backgroundColor,
            );
          }

          if (isOffline) {
            return LayoutProvider(
              responseWidget: widget.responseWidget,
              backgroundColor: widget.backgroundColor,
            );
          }

          if (onStart) {
            return SizedBox.expand(
              child: ColoredBox(
                color: widget.backgroundColor,
              ),
            );
          }

          if (isLimitedLayout) {
            return LayoutProvider(
              responseWidget: widget.responseWidget,
              backgroundColor: widget.backgroundColor,
            );
          } else {
            return 
            !widget.isRedirect ?
            widget.offerWidget ??
                LayoutProvider(
                  responseWidget: widget.responseWidget,
                  backgroundColor: widget.backgroundColor,
                ):  LayoutProvider(
                  responseWidget: widget.responseWidget,
                  backgroundColor: widget.backgroundColor,
                );
          }
        },
      ),
    );
  }
}
