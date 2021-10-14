import 'package:baskit/models/item.dart';
import 'package:hive/hive.dart';

class Boxes {
  static Box<Item> getItems() => Hive.box<Item>('items');
}
