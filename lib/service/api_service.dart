import 'package:crypto_app/models/assetstats.dart';
import 'package:crypto_app/models/pricemodel.dart';
import 'package:crypto_app/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:hive/hive.dart';

class Api_Service{
  List<Pricemodel> priceList = <Pricemodel>[];
  final box=Hive.box('currency');
  final homepageData = Hive.box('homepageData');

  Future<List<Pricemodel>> getprices(bool refresh) async{
    String currency= box.get('currency');
    Pricemodel pricemodel;
    if(homepageData.isEmpty|| refresh==true){
      homepageData.deleteAll(homepageData.keys);
      print("From inet");
      for(var currencies in Constant.currencies){
        var response = await http.get(Uri.parse("https://api.coinbase.com/v2/prices/$currencies-$currency/spot"));
        String jsonString = response.body;
        pricemodel = pricemodelFromJson(jsonString);
        homepageData.add(jsonString);
        priceList.add(pricemodel);
      }
      return priceList;
    }else{
      print("From DB");
      for (var i = 0; i < homepageData.length; i++) {
        String jsonString =await homepageData.getAt(i) as String;
        pricemodel = pricemodelFromJson(jsonString);
        priceList.add(pricemodel);
      }
      return priceList;
    }
    }

  Future<AssetStats> getstats(String assetid) async{
    String currency= box.get('currency');
    AssetStats stats;
    var response= await http.get(Uri.parse("https://api.pro.coinbase.com/products/$assetid-$currency/stats"));
    String jsonString = response.body;
    stats = assetStatsFromJson(jsonString);
    return stats;
  }

}