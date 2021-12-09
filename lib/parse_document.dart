import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements
import 'package:collection/collection.dart';
import 'package:string_similarity/string_similarity.dart';

Map<String, dynamic> getItemDetails({required Document document, required String domain}) {
  Map<String, dynamic> data = {'title': '???', 'imageURL': '???', 'price': '???'};

  // Get the item name
  List<Element> h1s = document.getElementsByTagName('h1');
  print('Number of h1s found: ${h1s.length}');

  if (h1s.length != 0) {
    String itemTitle = h1s[0].text.replaceAll(RegExp(r"\s+"), " ").trim();
    print('removeMultiSpace: $itemTitle');
    data["title"] = itemTitle;
  }

  // TODO refactor the while get image and put in separate function
  if (data["title"] != '???') {
    // Find the image URL
    var images = document.getElementsByTagName('img');
    Element altSimilarImage = images.reduce((curr, next) =>
        curr.attributes['alt'].similarityTo(data["title"]) >=
                next.attributes['alt'].similarityTo(data["title"])
            ? curr
            : next);

    print('alt property of Element most similar to title: ${altSimilarImage.attributes['alt']}');
    print('src property of Element most similar to title: ${altSimilarImage.attributes['src']}');

    // Now get the source value
    if (altSimilarImage != null) {
      print('now checking the source attribute of the productImage...');

      String? rawImageUrl;
      String? imageUrl;
      if (altSimilarImage.attributes.containsKey('src')) {
        rawImageUrl = altSimilarImage.attributes['src']!;
      } else if (altSimilarImage.attributes.containsKey('data-src')) {
        rawImageUrl = altSimilarImage.attributes['data-src']!;
      } else {
        print('src or data-src was not found');
      }

      if (rawImageUrl != null) {
        print('Raw URL found: $rawImageUrl');

        // Account for Protocol Relative URL
        if (!rawImageUrl.startsWith('http')) {
          // Add the domain to the start of the URL
          imageUrl = domain + rawImageUrl;
        } else {
          imageUrl = rawImageUrl;
        }

        // now add to data map
        print('now adading this to data map: $imageUrl');
        data['imageURL'] = imageUrl;
      }

      //   print('imageURL from src attribute: $imageURL');
      //   // Account for Protocol Relative URL
      //   imageURL.startsWith('http')
      //       ? data['imageURL'] = imageURL
      //       : data['imageURL'] = 'https:' + imageURL; // Hoping that it's https...
      //   print('URL of source is: ${data['imageURL']}');
      // } else if (altSimilarImage.attributes.containsKey('data-src')) {
      //   String imageURL = altSimilarImage.attributes['data-src']!;
      //   print('imageURL from data-src attribute: $imageURL');
      //   // Make sure there are
      // } else {
      //   print('No src found in image');
      // }
    } else {
      print('altSimilarImage element wasn\'t found.......');
    }
  }

  // Get Price
  String allText = document.body!.text;
  // TODO getting all text but would be better with innerText
  // TODO can't find innerText property.. but it is there....
  // TODO maybe can use xml library ?
  print('text length: ${allText.length}');

  // find the first element that has a '€' or '£' or '$' at the start
  final regex = RegExp(r'([\$|£|€]\d{1,6}\.\d{1,2})');
  final match = regex.firstMatch(allText);
  final matchedText = match?.group(0);
  if (matchedText != null) {
    data['price'] = matchedText;
    print('Price found: $matchedText');
  }

  return data;
}
