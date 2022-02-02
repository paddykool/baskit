import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';
import 'models/item.dart';
import 'navigation/routes.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({Key? key}) : super(key: key);

  static Page page({LocalKey? key}) => MaterialPage(
        key: key,
        child: ItemScreen(),
      );

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  // @override
  // void dispose() {
  //   Hive.box('items').close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baskit Item Screen'),
      ),
      body: ValueListenableBuilder<Box<Item>>(
        valueListenable: Boxes.getItems().listenable(),
        builder: (context, box, _) {
          final items = box.values.toList().cast<Item>();
          return buildItemCardList(items);
        },
      ),
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
  final box = Boxes.getItems();
  await box.clear();
}

class ItemCard extends StatelessWidget {
  final Item item;

  ItemCard({required this.item});

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
      ),
    );
  }
}
