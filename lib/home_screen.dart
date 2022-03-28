import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';
import 'models/baskit.dart';
import 'navigation/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static Page page({LocalKey? key}) => MaterialPage(
        key: key,
        child: HomeScreen(),
      );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baskits Screen'),
      ),
      body: ValueListenableBuilder<Box<Baskit>>(
        valueListenable: Boxes.getBaskits().listenable(),
        builder: (context, box, _) {
          final baskits = box.values.toList().cast<Baskit>();
          return buildBaskitCardList(baskits);
        },
      ),
    );
  }
}

Widget buildBaskitCardList(List<Baskit> baskits) {
  if (baskits.isEmpty) {
    return Center(
      child: Text('No Baskits created yet'),
    );
  } else {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: baskits.length,
            itemBuilder: (BuildContext context, int index) {
              final baskit = baskits[index];
              return BaskitCard(baskit: baskit);
            },
          ),
        )
      ],
    );
  }
}

class BaskitCard extends StatelessWidget {
  final Baskit baskit;

  BaskitCard({required this.baskit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        onTap: () {
          final key = baskit.key.toString();
          print('The key of the baskit is: $key');
          // go to the item screen - pass the baskit so it has the item list
          context.go('/baskit/$key');
        },
        title: Text(
          baskit.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// Future<void> clearItemBox() async {
//   print('inside clearItemBox()');
//   final box = Boxes.getItems();
//   await box.clear();
// }
