import 'dart:convert';
import 'package:cipher_pay/views/components/single_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TransactionViewCard extends StatefulWidget {
  final dynamic transaction;
  const TransactionViewCard({super.key,required this.transaction});

  @override
  State<TransactionViewCard> createState() => _TransactionViewCardState(transaction);
}

class _TransactionViewCardState extends State<TransactionViewCard> {
  dynamic transaction;
  String url = "";
  _TransactionViewCardState(this.transaction);

  @override
  void initState() {
    super.initState();
    transaction = widget.transaction;
    if (transaction['status'] == 'pending') {
      _checkTransactionStatus(transaction['coinType'], transaction['transactionHash']);
    }
  }

  @override
  void didUpdateWidget(covariant TransactionViewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transaction != oldWidget.transaction) {
      setState(() {
        transaction = widget.transaction;
      });

      if (transaction['status'] == 'pending') {
        _checkTransactionStatus(transaction['coinType'], transaction['transactionHash']);
      }
    }
  }

  Future<void> _checkTransactionStatus(String coinType,String transactionHash) async {
    try {
        if (coinType == 'Solana') {
          url = 'https://api.devnet.solana.com';
          final jsonData = json.encode({
            "jsonrpc": "2.0",
            "id": 1,
            "method": "getTransaction",
            "params": [transactionHash, "json"]
          });

          final response = await http.post(
            Uri.parse(url),
            headers: { "Content-Type": "application/json"},
            body: jsonData,
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['result'] != null) {
              String newStatus = data['result']['meta'] != null &&
                  data['result']['meta']['err'] == null ? 'success' : 'failed';
              await _updateTransactionStatus(transactionHash, newStatus);
            } else {
              print('Transaction status could not be retrieved for Solana');
            }
          } else {
            print('Error fetching transaction status for Solana: ${response
                .statusCode}');
          }
          return;
      }
      else{
      final apiKey = dotenv.env['Etherscan_api_key'];
      if (coinType == 'Holesky') {
        url =
        'https://api-holesky.etherscan.io/api?module=transaction&action=gettxreceiptstatus&txhash=$transactionHash&apikey=$apiKey';
      }
      else if (coinType == 'SEPOLIAETH') {
        url =
        'https://api-sepolia.etherscan.io/api?module=transaction&action=gettxreceiptstatus&txhash=$transactionHash&apikey=$apiKey';
      }
      else if (coinType == 'ETH') {
        url =
        'https://api.etherscan.io/api?module=transaction&action=gettxreceiptstatus&txhash=$transactionHash&apikey=$apiKey';
      }
      else if(coinType == 'LineaETH'){
        url =
        'https://api-sepolia.lineascan.build/api?module=transaction&action=gettxreceiptstatus&txhash=$transactionHash&apikey=$apiKey';
      }
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['result'] != null) {
          String newStatus = data['result']['status'] == '1' ? 'success' : 'failed';
          await _updateTransactionStatus(transactionHash, newStatus);
        } else {
          print('Transacton status could not be retrieved');
        }
      } else {
        print('Error fetching transaction status: ${response.statusCode}');
      }
    }
    } catch (e) {
      print('Error checking transaction status: $e');
    }
  }

  Future<void> _updateTransactionStatus(String transactionHash, String newStatus) async {
    try {
      final apiUrl = 'https://crypto-payment-api-xw9u.onrender.com/transaction/$transactionHash';
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': newStatus,
          'confirmationCount': transaction['confirmationCount']+1
        }),
      );

      if (response.statusCode == 200) {
        // Handle success
        print('Transaction status updated successfully: ${response.body}');
        // setState(() {
        //   transaction['status'] = newStatus;
        // });
      } else {
        // Handle errors
        print('Error updating transaction status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating API: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SingleTransactionView(transaction: transaction,)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10)
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transaction Hash: ${widget.transaction['transactionHash'].substring(0, 6)}...${widget.transaction['transactionHash'].substring(widget.transaction['transactionHash'].length - 4)}'),
                  Text('Amount: ${widget.transaction['amount']} ${widget.transaction['coinType']}'),
                ],
              ),
              Container(
                child: Text(widget.transaction['status']),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
