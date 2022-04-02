import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String imageURL;

  @HiveField(2)
  String price;

  @HiveField(3)
  String url;

  @HiveField(4)
  String host;

  Item({
    required this.title,
    required this.imageURL,
    required this.price,
    required this.url,
    required this.host,
  });
}
