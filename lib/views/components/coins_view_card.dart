import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:reown_appkit/reown_appkit.dart';

// class CoinsViewCard extends StatefulWidget {
//   final String title;
//   final String imageurl;
//   final double price;
//   final ReownAppKitModal appKitModal;
//   const CoinsViewCard({super.key, required this.title,required this.price, required this.imageurl, required this.appKitModal});
//
//   @override
//   State<CoinsViewCard> createState() => _CoinsViewCardState(title, price, imageurl, appKitModal);
// }
//
// class _CoinsViewCardState extends State<CoinsViewCard> {
//   final String title;
//   final double price;
//   final String imageurl;
//   final ReownAppKitModal _appKitModal;
//   late double convertedprice = 0;
//
//   String API_KEY = dotenv.env['api_key']!;
//   _CoinsViewCardState(this.title,this.price, this.imageurl, this._appKitModal);
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     getCurrencyConversionRate();
//     super.initState();
//   }
//
//   Future<void> sendEthereumTransaction(String to, double valueInEth, String chainId) async {
//     // final valueInWei = (double.parse(valueInEth) * 1e18).toStringAsFixed(0);
//     // final transaction = {
//     //   "to": to,
//     //   "value": valueInWei,
//     //   "gasPrice": "0x09184e72a000",
//     //   "gas": "0x2710",
//     // };
//     // final result = await _appKitModal.provider.request(
//     //   method: "eth_sendTransaction",
//     //   params: [transaction],
//     // );
//     // print("ETH Transaction Sent, Hash: $result");
//     final client = Web3Client("YOUR_RPC_URL", http.Client());
//
//     final privateKey = await Web3AuthFlutter.getPrivKey();
//     final credentials = EthPrivateKey.fromHex(privateKey);
//     final address = credentials.address;
//     print(await client.getBalance(address));
//
//     final signature = await client.signTransaction(
//       credentials,
//       Transaction(
//         from: address,
//         // Replace with the recipient address
//         to: EthereumAddress.fromHex(to),
//         // Replace with the amount of ETH to send
//         value: EtherAmount.fromInt(EtherUnit.ether, valueInEth as int),
//       ),
//     );
//
//     final receipt = await client.sendTransaction(
//       credentials,
//       Transaction(
//         from: address,
//         to: EthereumAddress.fromHex(to),
//         value: EtherAmount.fromInt(EtherUnit.ether, valueInEth as int),
//       ),
//     );
//     print(receipt);
//     await client.dispose();
//   }
//
//   Future<void> getCurrencyConversionRate() async {
//     String baseUrl = 'https://rest.coinapi.io/v1/exchangerate/$title';
//     try {
//       if (title == "SEPOLIAETH" || title == "LineaETH") {
//         setState(() {
//           convertedprice = 0.005;
//         });
//         return;
//       }
//
//       final response = await http.get(
//         Uri.parse(baseUrl),
//         headers: {
//           'X-CoinAPI-Key': API_KEY,
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         final List rates = json['rates'];
//
//         // Find ETH rate from the rates list
//         final usdRate = rates.firstWhere(
//               (rate) => rate['asset_id_quote'] == 'USD',
//           orElse: () => throw Exception('$title rate not found'),
//         )['rate'];
//
//         // Calculate conversion
//         setState(() {
//           convertedprice = price / usdRate;
//         });
//       } else {
//         print(response.reasonPhrase);
//         throw Exception('Failed to fetch exchange rates');
//       }
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10.0, bottom: 10, left: 20, right: 20),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: Colors.blue
//           )
//         ),
//         height: 80,
//         width: double.infinity,
//         child: Padding(
//           padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 50,
//                 backgroundImage: NetworkImage(imageurl),
//               ),
//               SizedBox(
//                 width: 0,
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                     Container(
//                       child: Text('Pay with $title', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
//                     ),
//                     Container(
//                       child: Text('${convertedprice.toStringAsPrecision(6)}'+' '+'$title',style: TextStyle(color: Colors.black.withOpacity(0.6)),),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class CoinsViewCard extends StatefulWidget {
  final String title;
  final String imageurl;
  final double price;
  final ReownAppKitModal appKitModal;
  final String? selectedCoin;
  final Function(String, double) onSelectCoin;

  const CoinsViewCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageurl,
    required this.appKitModal,
    required this.selectedCoin,
    required this.onSelectCoin,
  });

  @override
  State<CoinsViewCard> createState() => _CoinsViewCardState();
}

class _CoinsViewCardState extends State<CoinsViewCard> {
  late double convertedPrice;

  @override
  void initState() {
    super.initState();
    convertedPrice = 0;
    getCurrencyConversionRate();
  }

  Future<void> getCurrencyConversionRate() async {
    String API_KEY = dotenv.env['api_key']!;
    String baseUrl = 'https://rest.coinapi.io/v1/exchangerate/${widget.title}';

    try {
      if (widget.title == "SEPOLIAETH" || widget.title == "LineaETH" || widget.title == "Holesky") {
        setState(() {
          convertedPrice = 0.00005;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'X-CoinAPI-Key': API_KEY,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List rates = json['rates'];

        // Find USD rate from the rates list
        final usdRate = rates.firstWhere(
              (rate) => rate['asset_id_quote'] == 'USD',
          orElse: () => throw Exception('${widget.title} rate not found'),
        )['rate'];

        // Calculate conversion
        setState(() {
          convertedPrice = widget.price / usdRate;
        });
      } else {
        throw Exception('Failed to fetch exchange rates');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.selectedCoin == widget.title;

    return GestureDetector(
      onTap: () {
        widget.onSelectCoin(widget.title, convertedPrice);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.white, // Highlight selected card
              width: 1.5,
            ),
          ),
          height: 80,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.imageurl),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pay with ${widget.title}',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${convertedPrice.toStringAsPrecision(6)} ${widget.title}',
                              style: TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                          ],
                        ),
                        if(isSelected )
                          Icon(Icons.check_circle, color: Colors.blue,)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
