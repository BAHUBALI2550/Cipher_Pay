import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  final double price;
  final String seller;
  final ReownAppKitModal appKitModal;
  final int productId;
  final String? selectedCoin;
  const CheckoutScreen({super.key, required this.price, required this.seller, required this.appKitModal, required this.productId, required this.selectedCoin});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState(price,seller,appKitModal,productId,selectedCoin);
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final double price;
  final String seller;
  final ReownAppKitModal appKitModal;
  final int productId;
  final String? selectedCoin;
  late String? message;

  _CheckoutScreenState( this.price, this.seller, this.appKitModal, this.productId, this.selectedCoin);

  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isButtonEnabled = false;
  late dynamic user = '';



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }








  void _validateInput() {
    setState(() {
      _isButtonEnabled = _controller.text.isNotEmpty;
    });
  }

  Future<void> postTransaction(String hash) async {
    final url = 'https://crypto-payment-api-xw9u.onrender.com/transactions';

    // Prepare the transaction data as a Map
    final Map<String, dynamic> transactionData = {
      'transactionHash': hash,
      'productId': productId,
      'sellerAddress': seller,
      'coinType': selectedCoin,
      'amount': price,
      'message': _controller.text,
      'status': 'pending',
      'confirmationCount': 5,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transactionData),
      );

      if (response.statusCode == 201) {
        // Successfully created transaction
        print('Transaction created successfully: ${response.body}');
      } else {
        // Handle error
        print('Failed to create transaction: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error posting transaction: $error');
    }
  }


  Future<void> sendEthereumTransaction(String to, double valueInEth) async {
    try {
      if (widget.appKitModal.session == null) {
        print("No wallet connected.");
        return;
      }
      final approvedMethods = await widget.appKitModal.getApprovedMethods();
      print("Approved Methods: $approvedMethods");
      print("Selected Chain ID: ${widget.appKitModal.selectedChain!.chainId}");

      final session = widget.appKitModal.session!;
      final chainId = widget.appKitModal.selectedChain?.chainId ?? '';
      final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
      final accounts = session.getAccounts(namespace: namespace) ?? [];
      final addressList = accounts.map((account) {
        return account.split(':').last;
      }).toList();
      final address = EthereumAddress.fromHex(addressList[0]);
      user = address;
      print(address);

      final valueInWei = (valueInEth * 1e18).toInt().toString();

      // Construct the transaction object
      final transaction = {
        "from": address.hex,
        "to": to,
        "value": valueInWei,
        // "gasPrice": "0x3B9ACA00",
        // "gas": "0x5208",
      };

      print("Sending transaction: $transaction");
      widget.appKitModal.launchConnectedWallet();
      final hash = await widget.appKitModal.request(
        topic: widget.appKitModal.session!.topic,
        chainId: widget.appKitModal.selectedChain!.chainId,
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            transaction,
          ],
        ),
      );

      postTransaction(hash);

      print("ETH Transaction Sent, Hash: $hash");
    } catch (e) {

      print("Error sending transaction: $e");
    }
  }

  // Future<void> initiateOfframpConv({required double cryptoAmount, required String cryptoAddress, required String transactionHash}) async {
  //   final String country = 'US'; // Adjust based on the seller location and requirements
  //   final String paymentMethod = 'CARD'; // Match the seller’s fiat payment method
  //   final String fiatCurrency = 'USD'; // Fiat currency for the conversion
  //
  //   try {
  //     print("Generating Offramp Quote...");
  //
  //     // Step 1: Get the Quote for Offramp
  //     final quote = await getSellQuote(
  //       sellCurrency: 'Ethereum',
  //       sellAmount: cryptoAmount,
  //       cashoutCurrency: fiatCurrency,
  //       paymentMethod: paymentMethod,
  //       country: country,
  //     );
  //
  //     if (quote == null) {
  //       throw Exception("Offramp quote generation failed.");
  //     }
  //
  //     print("Offramp Quote Generated: $quote");
  //
  //     // Step 2: Use the Offramp Quote to finalize the conversion and send fiat to the seller
  //     double fiatAmount = quote["cashout_total"]["amount"];
  //     double coinbaseFee = quote["coinbase_fee"]["amount"];
  //
  //     print("Fiat Amount after fees: $fiatAmount, Coinbase Fee: $coinbaseFee");
  //     _showToast("Crypto successfully converted to Fiat and sent to the seller!");
  //
  //   } catch (e) {
  //     print("Error during Offramp conversion: $e");
  //     _showToast("Offramp conversion failed.");
  //   }
  // }
  //
  // Future<Map<String, dynamic>?> getSellQuote({
  //   required String sellCurrency,
  //   String? sellNetwork,
  //   required double sellAmount,
  //   required String cashoutCurrency,
  //   required String paymentMethod,
  //   required String country,
  //   String? subdivision,
  // }) async {
  //   const endpoint = 'https://api.developer.coinbase.com/onramp/v1/sell/quote';
  //
  //   final body = {
  //     'sell_currency': sellCurrency,
  //     'sell_amount': sellAmount.toString(),
  //     'cashout_currency': cashoutCurrency,
  //     'payment_method': paymentMethod,
  //     'country': country,
  //     if (sellNetwork != null) 'sell_network': sellNetwork,
  //     if (subdivision != null) 'subdivision': subdivision,
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(endpoint),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer organizations/08c54025-bfaf-45b8-bec9-cc90c8e42680/apiKeys/30135752-24c2-4785-97b1-0be367e008b6", // Replace with your API Key
  //       },
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body)['data'];
  //     } else {
  //       print("Sell Quote Failed: ${response.statusCode} ${response.body}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Error fetching quote: $e");
  //     return null;
  //   }
  // }


  void _showToast(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.black,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }






  Future<void> generateOfframpURL(String address, String partnerUserId) async {
    final baseURL = 'https://pay.coinbase.com/v3/sell/input';
    final appId = 'b80bd3ad-d969-4ee5-b9f6-f5364b997d19';
    final redirectUrl =
        'https://help.usertesting.com/hc/en-us/articles/12435218164381-How-do-Success-URLs-work';
    final supportedNetworks = ["ethereum","base"]; // Modify based on supported networks

    // Construct the Offramp URL
    final offrampUrl =
        '$baseURL?appId=$appId&partnerUserId=$partnerUserId&addresses={"$address":${jsonEncode(supportedNetworks)}}&redirectUrl=$redirectUrl';

    _launchURL(offrampUrl);
  }

  void _launchURL(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      print("Could not lanch URL: $e");
    }
  }

      Future<void> initiateOfframp() async {
    try {
        if (widget.appKitModal.session == null) {
          print("No wallet connected.");
          return;
        }
        final session = widget.appKitModal.session!;
        final chainId = widget.appKitModal.selectedChain?.chainId ?? '';
        final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
        final accounts = session.getAccounts(namespace: namespace) ?? [];
        final addressList = accounts.map((account) {
          return account.split(':').last;
        }).toList();

        final address = addressList[0];
        final partnerUserId = address;
      await generateOfframpURL(address, partnerUserId);
    } catch (e) {
      print("Error during Offramp initiation: $e");
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://beleaftechnologies.com/static/media/crypto_coin.a0b6016af35ab23d2ee0.webp'),
                  ),
                  SizedBox(height: 10,),
                  Text('Currency: '+selectedCoin!),
                  SizedBox(height: 10,),
                  Text('Amount: '+price.toString()),
                  SizedBox(height: 10,),
                  Text('ProductId: ' + productId.toString()),
                  SizedBox(height: 10,),
                  Text('Seller: ' + seller),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter your Address',
                      border: OutlineInputBorder(),
                      errorText: _errorMessage,
                    ),
                    onChanged: (value) {
                      _validateInput();
                    },
                    onSubmitted: (value) {
                      _validateInput();
                    },
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      ElevatedButton(
                        onPressed: () {
                        // initiateOfframpConv(cryptoAmount: price, cryptoAddress: seller, transactionHash: '');
                          initiateOfframp();
                        },
                        child: const Text("Offramp (Fiat)"),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          if(_controller.text.isEmpty)
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please Enter your Address!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          else {
                            sendEthereumTransaction(seller, price);
                          }
                        },
                        child: Text("Pay Now"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
