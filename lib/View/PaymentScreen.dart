import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:get/get.dart';
import 'package:upipayment/Controller/payementController.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: <Widget>[
            _vpa(controller),
            Obx(() => controller.upiAddrError?.value != null ? _vpaError(controller) : Container()),
            _amount(controller),
            if (Platform.isIOS) _submitButton(controller),
            Platform.isAndroid ? _androidApps(controller) : _iosApps(controller),
          ],
        ),
      ),
    );
  }

  Widget _vpa(PaymentController controller) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: controller.upiAddressController,
              enabled: controller.isUpiEditable.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'address@upi',
                labelText: 'Receiving UPI Address',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8),
            child: Obx(() => IconButton(
              icon: Icon(
                controller.isUpiEditable.value ? Icons.check : Icons.edit,
              ),
              onPressed: () {
                controller.isUpiEditable.value = !controller.isUpiEditable.value;
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _vpaError(PaymentController controller) {
    return Container(
      margin: EdgeInsets.only(top: 4, left: 12),
      child: Obx(() => Text(
        controller.upiAddrError?.value ?? '',
        style: TextStyle(color: Colors.red),
      )),
    );
  }

  Widget _amount(PaymentController controller) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller.amountController,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(Icons.loop),
              onPressed: controller.generateAmount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(PaymentController controller) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: MaterialButton(
              onPressed: () async => await controller.onTap(controller.apps!.first),
              color: Get.theme.colorScheme.secondary,
              height: 48,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              child: Text(
                'Initiate Transaction',
                style: Get.theme.textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _androidApps(PaymentController controller) {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Text('Pay Using', style: Get.theme.textTheme.bodyLarge),
          ),
          Obx(() => controller.apps != null ? _appsGrid(controller.apps!) : Container()),
        ],
      ),
    );
  }

  Widget _iosApps(PaymentController controller) {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: Text(
              'One of these will be invoked automatically by your phone to make a payment',
              style: Get.theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Text('Detected Installed Apps', style: Get.theme.textTheme.bodyLarge),
          ),
          Obx(() => controller.apps != null ? _discoverableAppsGrid(controller) : Container()),
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 12),
            child: Text('Other Supported Apps (Cannot detect)', style: Get.theme.textTheme.bodyLarge),
          ),
          Obx(() => controller.apps != null ? _nonDiscoverableAppsGrid(controller) : Container()),
        ],
      ),
    );
  }

  GridView _discoverableAppsGrid(PaymentController controller) {
    final discoverableApps = controller.apps?.where((app) => app.upiApplication.discoveryCustomScheme != null).toList();
    return _appsGrid(discoverableApps ?? []);
  }

  GridView _nonDiscoverableAppsGrid(PaymentController controller) {
    final nonDiscoverableApps = controller.apps?.where((app) => app.upiApplication.discoveryCustomScheme == null).toList();
    return _appsGrid(nonDiscoverableApps ?? []);
  }

  GridView _appsGrid(List<ApplicationMeta> apps) {
    apps.sort((a, b) => a.upiApplication.getAppName().toLowerCase().compareTo(b.upiApplication.getAppName().toLowerCase()));
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: NeverScrollableScrollPhysics(),
      children: apps.map((app) {
        return Material(
          key: ObjectKey(app.upiApplication),
          child: InkWell(
            onTap: Platform.isAndroid ? () async => await Get.find<PaymentController>().onTap(app) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                app.iconImage(48),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  alignment: Alignment.center,
                  child: Text(app.upiApplication.getAppName(), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
