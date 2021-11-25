import 'package:baskit/boxes.dart';
import 'package:baskit/parse_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'item_screen.dart';
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
  int parserIndex = 0;
  StreamSubscription? _intentDataStreamSubscription;
  String? passedUrl;

  void setParserTop() {
    setState(() {
      parserIndex = 1;
    });
  }

  void setItemsTop() {
    setState(() {
      print("calling setItemsTop.....");
      parserIndex = 0;
    });
  }

  @override
  void initState() {
    super.initState();

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String url) {
      print('inside "ReceiveSharingIntent.getTextStream()"...');
      print('Value passed in from getTextStream() was $url... Setting passedUrl variable');
      passedUrl = url;
      setParserTop();
      // getItemDetails(passedURL);
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? url) {
      print('inside "ReceiveSharingIntent.getInitialText()"...');
      if (url != null) {
        print('Value passed in from getInitialText() was $url... Setting passedUrl variable');
        passedUrl = url;
        setParserTop();
        // getItemDetails(value);
      } else {
        print('Value passed in from getInitialText() was null');
      }
    });
  }

  Future<void> getItemDetails(String url) async {
    // setState(() {
    //   print('Setting openedBySharing = 1');
    //   openedBySharing = 1;
    // });

    NetworkCalls networkCalls = NetworkCalls(url: url);
    var jsonData = await networkCalls.getJsonResponseBodySTUB();

    // print(jsonData);
    // print(jsonData['title']);
    // print(jsonData['imageURL']);
    // print(jsonData['price']);

    // var document = await networkCalls.getResponseBody();

    // ParseDocument parseDocument = ParseDocument(document: document);
    //
    // create a item Model
    Item item =
        Item(title: jsonData['title'], imageURL: jsonData['imageURL'], price: jsonData['price']);

    final box = Boxes.getItems();
    box.add(item);

    // // Reset openedBySharing ???
    // setState(() {
    //   print('Setting openedBySharing = false');
    //   openedBySharing = 0;
    // });
  }

  Future<void> clearItemBox() async {
    print('inside clearItemBox()');
    final box = Boxes.getItems();
    await box.clear();
  }

  @override
  Widget build(BuildContext context) {
    print('This is the value of parserIndex at the start of the build method...');
    print('parserIndex: $parserIndex');
    print('passedUrl: $passedUrl');

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Baskit'),
          ),
          body: passedUrl == null
              ? ItemScreen()
              : IndexedStack(
                  index: parserIndex,
                  children: [
                    ItemScreen(),
                    ParseScreen(url: passedUrl!, setStackIndexCallback: setItemsTop),
                  ],
                )

          // openedBySharing == 0

          // ? Text("Balls")
          // : ValueListenableBuilder<Box<Item>>(
          //     valueListenable: Boxes.getItems().listenable(),
          //     builder: (context, box, _) {
          //       final items = box.values.toList().cast<Item>();
          //       return buildItemCardList(items);
          //     },
          //   ),
          ),
    );
  }

  // take list of item model objcts
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
