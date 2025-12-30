import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cat_breed.dart';

class CatApi {
  static const _url = 'https://api.thecatapi.com/v1/breeds';
  static const _apiKey = 'live_99Qe4Ppj34NdplyLW67xCV7Ds0oSLKGgcWWYnSzMJY9C0QOu0HUR4azYxWkyW2nr';

  static Future<List<CatBreed>> getBreeds() async {
    final response = await http.get(
      Uri.parse(_url),
      headers: {
        'x-api-key': _apiKey,
      },
    );

    final List data = json.decode(response.body);
    return data.map((e) => CatBreed.fromJson(e)).toList();
  }
}
