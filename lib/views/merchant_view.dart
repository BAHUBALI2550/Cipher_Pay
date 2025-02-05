import 'dart:convert';
import 'package:cipher_pay/views/components/allTransactionPage.dart';
import 'package:cipher_pay/views/components/transaction_view_card.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'connect_wallet.dart';

class MerchantView extends StatefulWidget {
  const MerchantView({super.key});

  @override
  State<MerchantView> createState() => _MerchantViewState();
}

class _MerchantViewState extends State<MerchantView> {

  late ReownAppKitModal _appKitModal;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  late EthereumAddress seller;

  @override
  void initState() {
    super.initState();
    initializeState();
    fetchTransactions();
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

  Future<void> fetchTransactions() async {
      try {
        final session = _appKitModal.session!;
        final chainId = _appKitModal.selectedChain?.chainId ?? '';
        final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
        final seller = session.getAddress(namespace);
        final checksumSeller = EthereumAddress.fromHex(seller!).hexEip55;
        final url = 'https://crypto-payment-api-xw9u.onrender.com/transactions/$checksumSeller';
        final response = await http.get(
          Uri.parse(
              url),
        );
        if (response.statusCode == 200) {
          if(mounted){
          setState(() {
            _transactions = json.decode(response.body);
            print(_transactions);
            _isLoading = false;
          });}
        } else {
          throw Exception('Failed to load products: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetcing products: $e');
        if(mounted){
        setState(() {
          _isLoading = false;
        });
        }
      }

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_appKitModal.isConnected) {
          setState(() {
            fetchTransactions();
          });

        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            _appKitModal.isConnected ? AppKitModalAccountButton(appKitModal: _appKitModal,context: context,) :
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectWallet(_appKitModal)));
                }, child: Text('Connect Wallet')),
          ],
        ),
        body: _appKitModal.isConnected
            ? RefreshIndicator(
              onRefresh: () async{
                await fetchTransactions();
                setState(() {});
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 40.0, right: 40.0),
                    child: Container(
                              decoration: BoxDecoration(
                              color: Colors.lightGreen.shade100,
                                borderRadius: BorderRadius.circular(20)
                              ),
                              width: double.infinity,
                              child: Column(

                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/5853/5853761.png'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: _appKitModal.isConnected,
                            child: AppKitModalAccountButton(
                              appKitModal: _appKitModal,
                              context: context,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                              ),
                            ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Alltransactionpage(transactions: _transactions)));
                              } ,
                              child: Text('All transaction'),
                            style: TextButton.styleFrom(
                              elevation: 2,
                              backgroundColor: Colors.grey,
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Expanded(
                      child: ListView.builder(
                          itemCount: _transactions.length > 10 ? 10 : _transactions.length,
                          itemBuilder: (context, index) {
                            if (_transactions.isEmpty || _transactions[index] == null) {
                              return SizedBox.shrink();
                            }
                            final transaction = _transactions[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: TransactionViewCard(
                                key: ValueKey(transaction['transactionHash']),
                                transaction: transaction,)
                            );
                          },
                      ),
                    ),
                  ),
                ],
              ),
            )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No wallet connected'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConnectWallet(_appKitModal)),
                  ).then((value) {
                    if(_appKitModal.isConnected){
                      setState(() {
                        fetchTransactions();
                      });

                    }
                  });
                },
                child: Text('Connect Wallet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
