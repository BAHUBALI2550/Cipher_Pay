import 'package:flutter/material.dart';

class SingleTransactionView extends StatelessWidget {
  final dynamic transaction;
  const SingleTransactionView({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://img.freepik.com/free-vector/creative-data-logo-template_23-2149213542.jpg'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Transaction Id: ${transaction['id']}'),
                SizedBox(
                  height: 10,
                ),
                Text('Transaction Hash: '+ transaction['transactionHash']),
                SizedBox(
                  height: 10,
                ),
                Text('Seller Address: ${transaction['sellerAddress']}'),
                SizedBox(
                  height: 10,
                ),
                Text('Product Id: ${transaction['productId']}'),
                SizedBox(
                  height: 10,
                ),
                Text('Coin Paid: ${transaction['coinType']}'),
                SizedBox(
                  height: 10,
                ),
                Text('Amount: ${transaction['amount']}'),
                SizedBox(
                  height: 10,
                ),
                Text('Status: '+ transaction['status']),
                SizedBox(
                  height: 10,
                ),
                Text('Shipping Details: '+ transaction['message']),
                SizedBox(
                  height: 10,
                ),
                Text('Confirmation Count: ${transaction['confirmationCount']}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
