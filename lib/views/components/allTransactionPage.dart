import 'package:cipher_pay/views/components/transaction_view_card.dart';
import 'package:flutter/material.dart';

class Alltransactionpage extends StatefulWidget {
  final List<dynamic> transactions;
  const Alltransactionpage({super.key, required this.transactions});

  @override
  State<Alltransactionpage> createState() => _AlltransactionpageState(transactions);
}

class _AlltransactionpageState extends State<Alltransactionpage> {
  final List<dynamic> transactions;
  _AlltransactionpageState(this.transactions);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Expanded(
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: TransactionViewCard(transaction: transaction,)
              );
            },
          ),
        ),
      )
    );
  }
}
