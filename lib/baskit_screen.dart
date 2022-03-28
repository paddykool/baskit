import 'package:baskit/models/baskit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';
import 'models/item.dart';
import 'navigation/routes.dart';

// TODO use a provider here to hold the baskit data so all widgets can access it

class BaskitScreen extends StatefulWidget {
  final String baskitKey;

  BaskitScreen({required this.baskitKey});

  static Page page({LocalKey? key, required String baskitKey}) => MaterialPage(
        key: key,
        child: BaskitScreen(baskitKey: baskitKey),
      );

  @override
  State<BaskitScreen> createState() => _BaskitScreenState();
}

class _BaskitScreenState extends State<BaskitScreen> {
  late final Baskit baskit;

  @override
  void initState() {
    super.initState();
    // Get the basket from hive
    baskit = Boxes.getBaskits().get(int.parse(widget.baskitKey))!;
    // baskit = Boxes.getBaskits().get(0)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${baskit.title} Baskit Item Screen'),
      ),
      body: buildItemCardList(baskit.itemsList),
    );
  }
}

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

Future<void> clearItemBox() async {
  print('inside clearItemBox()');
  // TODO - clear down the list<item> in the baskit
  // final box = Boxes.getItems();
  // await box.clear();
}

class ItemCard extends StatelessWidget {
  final Item item;

  ItemCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        leading: Image.network(
          item.imageURL,
          errorBuilder: (context, exception, stackTrace) {
            return Image.asset('assets/images/not_found.png');
          },
        ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(item.price),
        trailing: GestureDetector(
          onTap: () {
            // Remove the item from the list<items>
          },
          child: Icon(Icons.delete),
        ),
      ),
    );
  }
}
