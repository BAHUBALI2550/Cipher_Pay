import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';

class ConnectWallet extends StatefulWidget {
  late ReownAppKitModal _appKitModal;
  ConnectWallet(this._appKitModal);
  @override
  State<ConnectWallet> createState() => _ConnectWalletState(_appKitModal);
}

class _ConnectWalletState extends State<ConnectWallet> {
  ReownAppKitModal _appKitModal;
  _ConnectWalletState(this._appKitModal);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppKitModalNetworkSelectButton(appKit: _appKitModal),
            AppKitModalConnectButton(appKit: _appKitModal),
            Visibility(
              visible: _appKitModal.isConnected,
              child: AppKitModalAccountButton(
                appKitModal: _appKitModal,
                context: context,
              ),
            )
          ],
        ),
      ),
    );
  }
}
