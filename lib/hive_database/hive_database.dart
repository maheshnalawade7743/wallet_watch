import 'package:hive/hive.dart';

class HiveDb {
  static Box? appData;

  createBox() async {
    appData = await Hive.openBox('appData');
  }

  static Future addData({key, value}) async {
    await appData?.put(key, value);
  }
  static Future<dynamic> getData({key}) async {
    return await appData?.get(key);
  }

  static Future<dynamic> getAllData() async {
    return appData?.toMap();
  }

  static deleteData(transaction, {key}) async {
    await appData?.delete(key);
  }

  static deleteAllData() async {
    await appData?.clear();
  }
}