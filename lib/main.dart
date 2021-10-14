import 'package:baskit/parse_document.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'models/item.dart';
import 'network.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _intentDataStreamSubscription;

  // Need to create a list of itemCards
  List<ItemCard> itemList = [];

  @override
  void initState() {
    super.initState();

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String passedURL) {
      print('inside "ReceiveSharingIntent.getTextStream()"...');
      print('Value passed in from getTextStream() was $passedURL... calling getHeader()');
      getItemDetails(passedURL);
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      print('inside "ReceiveSharingIntent.getInitialText()"...');
      if (value != null) {
        print('Value passed in from getInitialText() was $value... calling getItemDetails()');
        getItemDetails(value);
      } else {
        print('Value passed in from getInitialText() was null');
      }
    });
  }

  void getItemDetails(String url) async {
    NetworkCalls networkCalls = NetworkCalls(url: url);
    var document = await networkCalls.getResponseBody();

    ParseDocument parseDocument = ParseDocument(document: document);

    // create a item Model
    Item item = Item(
        title: parseDocument.title, imageURL: parseDocument.imageURL, price: parseDocument.price);

    // create a ItemCard from the model
    ItemCard itemCard = ItemCard(item: item);

    // add the ItemCard to the ItemCard list
    setState(() {
      itemList.add(itemCard);
    });

    print('length of itemList: ${itemList.length}');
  }

  @override
  Widget build(BuildContext context) {
    const textStyleBold = const TextStyle(fontWeight: FontWeight.bold);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Baskit'),
        ),
        body: Column(children: itemList),
      ),
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription!.cancel();
    super.dispose();
  }
}

class ItemCard extends StatelessWidget {
  final Item item;

  ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        leading: Image.network(item.imageURL),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(item.price),
      ),
    );
  }
}
