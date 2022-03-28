import 'package:hive/hive.dart';
import 'item.dart';

part 'baskit.g.dart';

@HiveType(typeId: 1)
class Baskit extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  List<Item> itemsList;

  Baskit({required this.title, required this.itemsList});
}
