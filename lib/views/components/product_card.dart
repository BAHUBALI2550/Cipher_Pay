import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/modal/appkit_modal_impl.dart';
import '../payment_crypto_select.dart';

class ProductCard extends StatelessWidget {
  final int id;
  final String name;
  final String imageurl;
  final double price;
  final String seller;
  final ReownAppKitModal appKitModal;
  ProductCard({super.key,required this.id, required this.name, required this.imageurl, required this.price, required this.seller,required this.appKitModal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentCryptoSelect(
            appKitModal: appKitModal,
            price: price,
            seller: seller,
            productId: id,
          ),));
        },
        child: Card(
          elevation: 10, // Adjust elevation value as needed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      child: Image.network(imageurl,fit: BoxFit.cover,),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child:
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Text(name, style: TextStyle(fontSize: 16),),),

                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: Text('\$$price', style: TextStyle(fontSize: 16)),),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
