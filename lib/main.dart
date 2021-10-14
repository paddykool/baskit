import 'package:baskit/boxes.dart';
import 'package:baskit/parse_document.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'models/item.dart';
import 'network.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ItemAdapter());
  await Hive.openBox<Item>('items');

  runApp(MyApp());
}

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

    // // create a ItemCard from the model
    // ItemCard itemCard = ItemCard(item: item);

    // // add the ItemCard to the ItemCard list
    // setState(() {
    //   itemList.add(itemCard);
    // });
    // print('length of itemList: ${itemList.length}');

    final box = Boxes.getItems();
    box.add(item);
  }

  Future<void> clearItemBox() async {
    print('inside clearItemBox()');
    final box = Boxes.getItems();
    await box.clear();
  }

  @override
  Widget build(BuildContext context) {
    const textStyleBold = const TextStyle(fontWeight: FontWeight.bold);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Baskit'),
        ),
        body: ValueListenableBuilder<Box<Item>>(
          valueListenable: Boxes.getItems().listenable(),
          builder: (context, box, _) {
            final items = box.values.toList().cast<Item>();
            return buildItemCardList(items);
          },
        ),
      ),
    );
  }

  //take list of item model objcts
  // and return a list view of the cards
  Widget buildItemCardList(List<Item> items) {
    if (items.isEmpty) {
      return Center(
        child: Text('No items yet'),
      );
    } else {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              clearItemBox();
            },
            child: Text('Clear list'),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return ItemCard(item: item);
              },
            ),
          )
        ],
      );
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription!.cancel();
    Hive.box('items').close();
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
