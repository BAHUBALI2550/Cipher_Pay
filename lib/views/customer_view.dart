import 'dart:convert';
import 'package:cipher_pay/views/components/product_card.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:http/http.dart' as http;
import 'connect_wallet.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  late ReownAppKitModal _appKitModal;
  List<dynamic> _products = []; // List for storing products fetched from API
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeState();
    fetchProducts();
  }

  void initializeState() async {
    ReownAppKitModalNetworks.addSupportedNetworks('sepolia', [
      ReownAppKitModalNetworkInfo(
        name: 'Sepolia',
        chainId: '11155111',
        chainIcon: 'https://cryptologos.cc/logos/polkadot-new-dot-logo.png',
        currency: 'ETH',
        rpcUrl: 'https://rpc.sepolia.org/',
        explorerUrl: 'https://sepolia.etherscan.io/',
      ),
      ReownAppKitModalNetworkInfo(
        name: 'Westend',
        chainId: 'e143f23803ac50e8f6f8e62695d1ce9e',
        currency: 'DOT',
        rpcUrl: 'https://westend-rpc.polkadot.io',
        explorerUrl: 'https://westend.subscan.io',
        isTestNetwork: true,
      ),
      ReownAppKitModalNetworkInfo(
        name: 'LineaETH',
        chainId: '59141',
        chainIcon: 'https://cryptologos.cc/logos/sui-sui-logo.png?v=040',
        currency: 'ETH',
        rpcUrl: 'https://linea-sepolia.infura.io/v3/e4692313b8c14e9d8030e61a69dc531a',
        explorerUrl: 'https://sepolia.lineascan.build/',
      ),
    ]);
    _appKitModal = ReownAppKitModal(
      context: context,
      projectId: "0ad335651ea524af97b7cc720b1736a8",
      metadata: const PairingMetadata(
        name: 'cipherPay',
        description: 'Crypto Payment Gateway',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'exampleapp://',
          universal: 'https://reown.com/exampleapp',
        ),
      ),
      optionalNamespaces: {
        'eip155': RequiredNamespace.fromJson({
          'chains': ReownAppKitModalNetworks.getAllSupportedNetworks(
            namespace: 'eip155',
          ).map((chain) => 'eip155:${chain.chainId}').toList(),
          'methods': NetworkUtils.defaultNetworkMethods['eip155']!.toList(),
          'events': NetworkUtils.defaultNetworkEvents['eip155']!.toList(),
        }),
        'solana': RequiredNamespace.fromJson({
          'chains': ReownAppKitModalNetworks.getAllSupportedNetworks(
            namespace: 'solana',
          ).map((chain) => 'solana:${chain.chainId}').toList(),
          'methods': NetworkUtils.defaultNetworkMethods['solana']!.toList(),
          'events': [],
        }),
        'sepolia': RequiredNamespace.fromJson({
          'chains': ReownAppKitModalNetworks.getAllSupportedNetworks(
            namespace: 'sepolia',
          ).map((chain) => 'sepolia:${chain.chainId}').toList(),
          'methods': [
            'sepolia_signMessage',
            'sepolia_signTransaction',
          ],
          'events': []
        }),
      },
    );
    await _appKitModal.init().then((value) => setState(() {}));
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://crypto-payment-api-xw9u.onrender.com/products'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _products = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        // Handle failed response
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

@override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          _appKitModal.isConnected ? AppKitModalAccountButton(appKitModal: _appKitModal,context: context,) :
          ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectWallet(_appKitModal)));
              }, child: Text('Connect Wallet')) ,
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              ..._products.map((product) => ProductCard(
                id: product['id'],
                name: product['name'],
                imageurl: product['imageUrl'],
                price: product['price'],
                seller: product['sellerAddress'],
                appKitModal: _appKitModal,
              )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

