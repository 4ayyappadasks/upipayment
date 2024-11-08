import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PaymentController extends GetxController {
  var upiAddrError = "".obs;
  final upiAddressController = TextEditingController();
  final amountController = TextEditingController();
  RxBool isUpiEditable = false.obs;
  RxList<ApplicationMeta>? apps = RxList<ApplicationMeta>([]);

  @override
  void onInit() {
    super.onInit();
    upiAddressController.text = "ADD_UPI_ID_HERE";

    Future.delayed(Duration.zero, () async {
      apps?.addAll(await UpiPay.getInstalledUpiApplications(
          statusType: UpiApplicationDiscoveryAppStatusType.all));
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    upiAddressController.dispose();
    super.dispose();
  }


  Future<void> onTap(ApplicationMeta app) async {
    final err = _validateUpiAddress(upiAddressController.text);
    upiAddrError?.value = "${err}";

    if (err != null) return;

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    if (kDebugMode) {
      print("Starting transaction with id $transactionRef");
    }

    await UpiPay.initiateTransaction(
      amount: amountController.text,
      app: app.upiApplication,
      receiverName: 'Sharad',
      receiverUpiAddress: upiAddressController.text,
      transactionRef: transactionRef,
      transactionNote: 'UPI Payment',
    );
  }

  String? _validateUpiAddress(String value) {
    if (value.isEmpty) return 'UPI VPA is required.';
    if (value.split('@').length != 2) return 'Invalid UPI VPA';
    return null;
  }
}
