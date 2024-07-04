// import 'dart:async';

// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

// class PaymentService {
//   PaymentService._internal();

//   static final PaymentService instance = PaymentService._internal();

//   late StreamSubscription<ConnectionResult> _connectionSubscription;

//   late StreamSubscription<PurchasedItem?> _purchaseUpdatedSubscription;

//   late StreamSubscription<PurchaseResult?> _purchaseErrorSubscription;

//   final ObserverList<Function> _proStatusChangedListeners =
//       ObserverList<Function>();

//   /// view of the app will subscribe to this to get errors of the purchase
//   final ObserverList<Function(String)> _errorListeners =
//       ObserverList<Function(String)>();

//   bool _isProUser = false;

//   final products = <IAPItem>[];

//   final pastPurchases = <PurchasedItem>[];

//   bool get isProUser => _isProUser;

//   addToProStatusChangedListeners(Function callback) {
//     _proStatusChangedListeners.add(callback);
//   }

//   removeFromProStatusChangedListeners(Function callback) {
//     _proStatusChangedListeners.remove(callback);
//   }

//   addToErrorListeners(Function(String) callback) {
//     _errorListeners.add(callback);
//   }

//   removeFromErrorListeners(Function(String) callback) {
//     _errorListeners.remove(callback);
//   }

//   void _callProStatusChangedListeners() {
//     for (var callback in _proStatusChangedListeners) {
//       callback();
//     }
//   }

//   /// Call this method to notify all the subsctibers of _errorListeners
//   void _callErrorListeners(String error) {
//     for (var callback in _errorListeners) {
//       callback(error);
//     }
//   }

//   Future<void> _getItems(List<String> productIds) async {
//     List<IAPItem> items =
//         await FlutterInappPurchase.instance.getProducts(productIds);
//     products.clear();
//     for (final item in items) {
//       products.add(item);
//     }
//   }

//   Future<void> initConnection(List<String> productIds) async {
//     await FlutterInappPurchase.instance.initialize();
//     _connectionSubscription =
//         FlutterInappPurchase.connectionUpdated.listen((connected) {});

//     _purchaseUpdatedSubscription =
//         FlutterInappPurchase.purchaseUpdated.listen(_handlePurchaseUpdate);

//     _purchaseErrorSubscription =
//         FlutterInappPurchase.purchaseError.listen(_handlePurchaseError);

//     _getItems(productIds);
//     _getPastPurchases();
//   }

//   void _handlePurchaseError(PurchaseResult? purchaseError) {
//     if (purchaseError == null) {
//       return;
//     }
//     _callErrorListeners(purchaseError.message ?? '');
//   }

//   void _handlePurchaseUpdate(PurchasedItem? productItem) async {
//     if (productItem == null) {
//       return;
//     }

//     if (Platform.isAndroid) {
//       await _handlePurchaseUpdateAndroid(productItem);
//     } else {
//       await _handlePurchaseUpdateIOS(productItem);
//     }
//   }

//   Future<void> _handlePurchaseUpdateIOS(PurchasedItem purchasedItem) async {
//     switch (purchasedItem.transactionStateIOS) {
//       case TransactionState.deferred:
//         // Edit: This was a bug that was pointed out here : https://github.com/dooboolab/flutter_inapp_purchase/issues/234
//         // FlutterInappPurchase.instance.finishTransaction(purchasedItem);
//         break;
//       case TransactionState.failed:
//         _callErrorListeners("Transaction Failed");
//         FlutterInappPurchase.instance.finishTransaction(purchasedItem);
//         break;
//       case TransactionState.purchased:
//         await _verifyAndFinishTransaction(purchasedItem);
//         break;
//       case TransactionState.purchasing:
//         break;
//       case TransactionState.restored:
//         FlutterInappPurchase.instance.finishTransaction(purchasedItem);
//         break;
//       default:
//     }
//   }

//   Future<void> _handlePurchaseUpdateAndroid(PurchasedItem purchasedItem) async {
//     switch (purchasedItem.purchaseStateAndroid) {
//       case PurchaseState.purchased:
//         if (!purchasedItem.isAcknowledgedAndroid!) {
//           await _verifyAndFinishTransaction(purchasedItem);
//         }
//         break;
//       default:
//         _callErrorListeners("Something went wrong");
//     }
//   }

//   _verifyAndFinishTransaction(PurchasedItem purchasedItem) async {
//     bool isValid = false;
//     try {
//       // Call API
//       isValid = true;
//     } on Exception {
//       _callErrorListeners("Something went wrong");
//       return;
//     }

//     if (isValid) {
//       FlutterInappPurchase.instance.finishTransaction(purchasedItem);
//       _isProUser = true;
//       // save in sharedPreference here
//       _callProStatusChangedListeners();
//     }
//   }

//   void _getPastPurchases() async {
//     List<PurchasedItem>? purchasedItems =
//         await FlutterInappPurchase.instance.getAvailablePurchases();

//     if (purchasedItems == null) {
//       pastPurchases.clear();
//       return;
//     }

//     for (var purchasedItem in purchasedItems) {
//       if (purchasedItem.transactionReceipt == null) {
//         return;
//       }

//       _isProUser = true;
//       _callProStatusChangedListeners();
//     }

//     pastPurchases.clear();
//     pastPurchases.addAll(purchasedItems);
//   }

//   Future<void> buyProduct(String id) {
//     return FlutterInappPurchase.instance.requestPurchase(id);
//   }

//   void dispose() {
//     _connectionSubscription.cancel();
//     _purchaseErrorSubscription.cancel();
//     _purchaseUpdatedSubscription.cancel();
//     FlutterInappPurchase.instance.finalize();
//   }
// }
