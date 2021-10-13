import 'package:flutter/material.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'models/item.dart';
import 'network_calls.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _intentDataStreamSubscription;

  // Need to create a list of itemCards

  List<ItemCard> itemList = [];

  String? _title;
  String? _imageURL;
  String? _price;

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

  void getItemDetails(String? url) async {
    if (url != null) {
      NetworkCalls networkCalls = NetworkCalls(url: url);
      await networkCalls.getResponseBody();

      // create a item Model
      Item item = Item(
          title: networkCalls.title, imageURL: networkCalls.urlOfImage, price: networkCalls.price);

      // create a ItemCard from the model
      ItemCard itemCard = ItemCard(item: item);

      print('length of itemList: ${itemList.length}');

      // add the ItemCard to the ItemCard list
      setState(() {
        itemList.add(itemCard);
      });
    } else {
      print('Value passed to getHeader was null...');
    }
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
