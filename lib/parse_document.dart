import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements
import 'package:collection/collection.dart';
import 'package:string_similarity/string_similarity.dart';

Map<String, dynamic> getItemDetails(
    {required Document document,
    required String host,
    required int h1Position}) {
  Map<String, dynamic> data = {
    'title': '???',
    'imageURL': '???',
    'price': '???'
  };

  // Get the item name from h1 element
  List<Element> h1s = document.getElementsByTagName('h1');
  print('Number of h1s found: ${h1s.length}');

  String itemTitle =
      h1s[h1Position].text.replaceAll(RegExp(r"\s+"), " ").trim();
  print('removeMultiSpace from title: $itemTitle');
  data["title"] = itemTitle;

  // TODO refactor the whole get image and put in separate function
  if (data["title"] != '???') {
    data['imageURL'] =
        getImageURL(document: document, title: data["title"], host: host);
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

// Function for getting the image source URL
// TODO refactor this whole thing... its pants
String getImageURL(
    {required Document document, required String title, required String host}) {
  String? rawImageUrl = '???';
  String imageUrl = '???';

  // Find the image URL
  var images = document.getElementsByTagName('img');
  Element altSimilarImage = images.reduce((curr, next) =>
      curr.attributes['alt'].similarityTo(title) >=
              next.attributes['alt'].similarityTo(title)
          ? curr
          : next);

  print(
      'alt property of Element most similar to title: ${altSimilarImage.attributes['alt']}');
  print(
      'src property of Element most similar to title: ${altSimilarImage.attributes['src']}');

  // Now get the source value
  if (altSimilarImage != null) {
    print('now checking the source attribute of the productImage...');

    if (altSimilarImage.attributes.containsKey('src')) {
      rawImageUrl = altSimilarImage.attributes['src']!;
    } else if (altSimilarImage.attributes.containsKey('data-src')) {
      rawImageUrl = altSimilarImage.attributes['data-src']!;
    } else {
      print('src or data-src was not found.. returning nothing - \'???\'');
      return '????';
    }

    if (rawImageUrl != '???') {
      print('Raw URL found: $rawImageUrl');

      // Account for Protocol Relative URL
      // parse the URL to see if it has an origin....
      Uri myURI = Uri.parse(rawImageUrl);
      print('myURI.host: ${myURI.host}');
      // print('myURI.origin: ${myURI.origin}');
      print('myURI.hasScheme: ${myURI.hasScheme}');
      print('myURI.scheme: ${myURI.scheme}');

      // Add the host if it is missing - e.g. woodies.ie
      if (myURI.host == "") {
        print('host is missing... adding the origin');
        rawImageUrl = host + rawImageUrl;
      }

      // adding the protocol is its missin - e.g. fitpink / shopify
      if (myURI.hasScheme == false) {
        if (rawImageUrl.substring(0, 2) != '//') {
          rawImageUrl = 'https://' + rawImageUrl;
        } else {
          rawImageUrl = 'https:' + rawImageUrl;
        }
      }

      // now add to data map
      print('final image url: $rawImageUrl');
    }
  } else {
    print('altSimilarImage element wasn\'t found.......');
  }

  return rawImageUrl;
}
