import 'package:dio/dio.dart';

class BirdeyeApi { static final Dio _dio = Dio();

static Future<double?> price(String mint) async { final res = await _dio.get('https://public-api.birdeye.so/public/price', queryParameters: { 'address': mint, }); return res.data?['data']?['value']?.toDouble(); } }