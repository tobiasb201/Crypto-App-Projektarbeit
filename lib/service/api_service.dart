import 'package:crypto_app/models/assetstats.dart';
import 'package:crypto_app/models/pricemodel.dart';
import 'package:crypto_app/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:hive/hive.dart';

class ApiService {
  List<Pricemodel> priceList = <Pricemodel>[];
  final box = Hive.box('fetchingCurrency'); //saved currency from hive-box
  final homepageData = Hive.box('homepageData');//price model Hive-Box

  Future<List<Pricemodel>> getprices(bool refresh) async {
    String currency = box.get('fetchingCurrency');
    Pricemodel pricemodel;
    if (homepageData.isEmpty || refresh == true) {
      homepageData.deleteAll(homepageData.keys); //deletes all outdated price models in hive-box
      print("From inet");
      for (var currencies in Constant.currencies) {
        var response = await http.get(Uri.parse(
            "https://api.coinbase.com/v2/prices/$currencies-$currency/spot"));
        if (response.statusCode == 200) { //connection established
          String jsonString = response.body;
          pricemodel = pricemodelFromJson(jsonString);
          homepageData.add(jsonString); //saves new jsonString in hive-box
          priceList.add(pricemodel);
        }
      }
      return priceList;
    } else {
      print("From DB");
      for (var i = 0; i < homepageData.length; i++) {
        String jsonString = await homepageData.getAt(i) as String;
        pricemodel = pricemodelFromJson(jsonString);
        priceList.add(pricemodel);
      }
      return priceList;
    }
  }

  Future<AssetStats> getstats(String assetid) async {
    String currency = box.get('fetchingCurrency');
    AssetStats stats;
    var response = await http.get(Uri.parse(
        "https://api.pro.coinbase.com/products/$assetid-$currency/stats"));
    if (response.statusCode == 200) {
      String jsonString = response.body;
      stats = assetStatsFromJson(jsonString);
    }
    return stats;
  }
}
