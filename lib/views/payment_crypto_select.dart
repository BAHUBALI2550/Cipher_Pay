import 'package:cipher_pay/views/checkout_screen.dart';
import 'package:cipher_pay/views/components/coins_view_card.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'connect_wallet.dart';

// class PaymentCryptoSelect extends StatefulWidget {
//   final double price;
//   final ReownAppKitModal appKitModal;
//   PaymentCryptoSelect({super.key, required this.appKitModal, required this.price});
//
//   @override
//   State<PaymentCryptoSelect> createState() => _PaymentCryptoSelectState(appKitModal,price);
// }
//
// class _PaymentCryptoSelectState extends State<PaymentCryptoSelect> {
//   final ReownAppKitModal _appKitModal;
//   final double price;
//   String? selectedCoin; // To store the selected coin
//   double selectedConvertedPrice = 0;
//   _PaymentCryptoSelectState(this._appKitModal,this.price);
//
//   void updateSelectedCoin(String coin, double convertedPrice) {
//     setState(() {
//       selectedCoin = coin;
//       selectedConvertedPrice = convertedPrice;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           actions: [
//             _appKitModal.isConnected ? AppKitModalAccountButton(appKitModal: _appKitModal,context: context,) :
//             ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectWallet(_appKitModal)));
//                 }, child: Text('Connect Wallet')) ,
//           ],
//         ),
//         body:
//             Column(
//               children: [
//                 CoinsViewCard(title: 'BTC', price: price, imageurl: 'https://www.brookings.edu/wp-content/uploads/2021/06/shutterstock_1708749826_small.jpg?quality=75', appKitModal: _appKitModal,),
//                 CoinsViewCard(title: 'ETH', price: price, imageurl: 'https://files.coinswitch.co/public/coins/eth.png', appKitModal: _appKitModal,),
//                 CoinsViewCard(title: 'SOL', price: price, imageurl: 'https://img.freepik.com/premium-vector/solana-coin_48203-257.jpg', appKitModal: _appKitModal,),
//                 CoinsViewCard(title: 'SEPOLIAETH', price: price, imageurl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJjnW5POcQ21SnK47twb8OGsyOn8S2dGR9CT8xBG7LTWzjNuaxqyWIuqV03VtV-UUQoMg&usqp=CAU', appKitModal: _appKitModal,),
//                 CoinsViewCard(title: 'LineaETH', price: price, imageurl: 'https://rdbk.rootdata.com/uploads/public/b6/1679995192513.jpg', appKitModal: _appKitModal,),
//               ],
//             ),
//       ),
//     );
//   }
// }

class PaymentCryptoSelect extends StatefulWidget {
  final int productId;
  final double price;
  final String seller;
  final ReownAppKitModal appKitModal;

  PaymentCryptoSelect({
    super.key,
    required this.appKitModal,
    required this.price,
    required this.seller,
    required this.productId,
  });

  @override
  State<PaymentCryptoSelect> createState() =>
      _PaymentCryptoSelectState(appKitModal, price, seller, productId);
}

class _PaymentCryptoSelectState extends State<PaymentCryptoSelect> {
  final ReownAppKitModal appKitModal;
  final double price;
  final String seller;
  final int productId;
  String? selectedCoin;
  double selectedConvertedPrice = 0;

  _PaymentCryptoSelectState(this.appKitModal, this.price, this.seller, this.productId);

  void updateSelectedCoin(String coin, double convertedPrice) {
    setState(() {
      selectedCoin = coin;
      selectedConvertedPrice = convertedPrice;
    });
  }


  Future<void> sendEthereumTransaction(String to, double valueInEth, String chainId) async {
    try {
      if (appKitModal.session == null) {
        print("No wallet connected.");
        return;
      }
      final approvedMethods = await appKitModal.getApprovedMethods();
      print("Approved Methods: $approvedMethods");
      print("Selected Chain ID: ${appKitModal.selectedChain!.chainId}");

      final session = widget.appKitModal.session!;
        final chainId = widget.appKitModal.selectedChain?.chainId ?? '';
        final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
        final accounts = session.getAccounts(namespace: namespace) ?? [];
        final addressList = accounts.map((account) {
          return account.split(':').last;
        }).toList();
        final address = EthereumAddress.fromHex(addressList[0]);
        print(address);

      final valueInWei = (valueInEth * 1e18).toInt().toString();

      // Construct the transaction object
      final transaction = {
        "from": address.hex,
        "to": to,
        "value": valueInWei,
        // "gasPrice": "0x3B9ACA00", // Optional: Customize this as needed
        // "gas": "0x5208", // Optional: Customize this gas limit if needed
      };

      // eth_signTransaction
      
      print("Sending transaction: $transaction");
      appKitModal.launchConnectedWallet();
      final hash = await appKitModal.request(
        topic: appKitModal.session!.topic,
        chainId: appKitModal.selectedChain!.chainId,
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            transaction,
          ],
        ),
      );


      print("ETH Transaction Sent, Hash: $hash");
    } catch (e) {

      print("Error sendng transaction: $e");
    }
  }


  // Future<void> sendEthereumTransaction(String to, double valueInEth, String coin) async {
  //   late String rpcUrl;
  //   if(coin == "BTC")
  //     {
  //       rpcUrl = 'https://sepolia.infura.io';
  //     }
  //   else if(coin == 'ETH')
  //     {
  //       rpcUrl = 'https://mainnet.infura.io/v3/e4692313b8c14e9d8030e61a69dc531a';
  //     }
  //   else if(coin == 'SOL')
  //   {
  //     rpcUrl = 'https://sepolia.infura.io';
  //   }
  //   else if(coin == 'SEPOLIAETH')
  //   {
  //     rpcUrl = 'https://sepolia.infura.io/v3/e4692313b8c14e9d8030e61a69dc531a';
  //   }
  //   else if(coin == 'LineaETH')
  //   {
  //     rpcUrl = 'https://linea-sepolia.infura.io/v3/e4692313b8c14e9d8030e61a69dc531a';
  //   }
  //
  //   final session = widget.appKitModal.session!;
  //   final chainId = widget.appKitModal.selectedChain?.chainId ?? '';
  //   final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
  //   final accounts = session.getAccounts(namespace: namespace) ?? [];
  //   final addressList = accounts.map((account) {
  //     return account.split(':').last;
  //   }).toList();
  //   // final address = EthereumAddress.fromHex(addressList[0]);
  //   final client = Web3Client(rpcUrl, http.Client());
  //   final privateKey = await Web3AuthFlutter.getPrivKey();
  //
  //   final credentials = EthPrivateKey.fromHex(privateKey);
  //   final address = credentials.address;
  //   final balance = await client.getBalance(address);
  //
  //   final signature = await client.signTransaction(
  //     credentials,
  //     Transaction(
  //       from: address,
  //       // Replace with the recipient address
  //       to: EthereumAddress.fromHex('0xf29382750A9D59c51b968ADB96982D85CA59a7BB'),
  //       // Replace with the amount of ETH to send
  //       value: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 500000000), // 0.05 ETH
  //
  //     ),
  //   );
  //
  //   final receipt = await client.sendTransaction(
  //     credentials,
  //     Transaction(
  //       from: address,
  //       to: EthereumAddress.fromHex('0xf29382750A9D59c51b968ADB96982D85CA59a7BB'),
  //       value: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 500000000), // 0.05 ETH
  //     ),
  //   );
  //
  //   await client.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            appKitModal.isConnected
                ? AppKitModalAccountButton(
              appKitModal: appKitModal,
              context: context,
            )
                : ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectWallet(appKitModal)));
              },
              child: Text('Connect Wallet'),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                children: [
                  CoinsViewCard(
                    title: 'BTC',
                    price: price,
                    imageurl: 'https://www.brookings.edu/wp-content/uploads/2021/06/shutterstock_1708749826_small.jpg?quality=75',
                    appKitModal: appKitModal,
                    selectedCoin: selectedCoin,
                    onSelectCoin: updateSelectedCoin,
                  ),
                  CoinsViewCard(
                    title: 'ETH',
                    price: price,
                    imageurl: 'https://files.coinswitch.co/public/coins/eth.png',
                    appKitModal: appKitModal,
                    selectedCoin: selectedCoin,
                    onSelectCoin: updateSelectedCoin,
                  ),
                  CoinsViewCard(
                    title: 'SOL',
                    price: price,
                    imageurl: 'https://img.freepik.com/premium-vector/solana-coin_48203-257.jpg',
                    appKitModal: appKitModal,
                    selectedCoin: selectedCoin,
                    onSelectCoin: updateSelectedCoin,
                  ),
                  CoinsViewCard(
                    title: 'SEPOLIAETH',
                    price: price,
                    imageurl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJjnW5POcQ21SnK47twb8OGsyOn8S2dGR9CT8xBG7LTWzjNuaxqyWIuqV03VtV-UUQoMg&usqp=CAU',
                    appKitModal: appKitModal,
                    selectedCoin: selectedCoin,
                    onSelectCoin: updateSelectedCoin,
                  ),
                  CoinsViewCard(
                    title: 'LineaETH',
                    price: price,
                    imageurl: 'https://rdbk.rootdata.com/uploads/public/b6/1679995192513.jpg',
                    appKitModal: appKitModal,
                    selectedCoin: selectedCoin,
                    onSelectCoin: updateSelectedCoin,
                  ),
                  CoinsViewCard(
                    title: 'Holesky',
                    price: price,
                    imageurl: 'https://rdbk.rootdata.com/uploads/public/b6/1679995192513.jpg',
                    appKitModal: appKitModal,
                    selectedCoin: selectedCoin,
                    onSelectCoin: updateSelectedCoin,
                  ),
                ],
              ),
            ),
            if (selectedCoin != null)
              Container(
                color: Colors.grey.shade200,
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hosting Payment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${selectedConvertedPrice.toStringAsPrecision(6)} $selectedCoin',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),

                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(price: selectedConvertedPrice, seller: seller, appKitModal: appKitModal, productId: productId, selectedCoin: selectedCoin),));
                      },
                      child: Text("Continue"),
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
    );
  }
}