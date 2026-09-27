import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'models/catalog_entry.dart';

class CatalogService {
  final Dio _dio;
  static const String defaultGistUrl =
      'https://gist.githubusercontent.com/placeholder/catalog.json';

  CatalogService({Dio? dio}) : _dio = dio ?? Dio();

  Future<CatalogData> fetchCatalog({String? customUrl}) async {
    final url = customUrl ?? defaultGistUrl;
    try {
      final response = await _dio.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data is String ? jsonDecode(response.data) : response.data;
        return CatalogData.fromJson(data);
      }
    } catch (_) {
      // Fallback to local asset if network or Gist fails
    }
    return loadBundledCatalog();
  }

  Future<CatalogData> loadBundledCatalog() async {
    final jsonStr = await rootBundle.loadString('assets/sample_catalog/catalog.json');
    final Map<String, dynamic> data = jsonDecode(jsonStr);
    return CatalogData.fromJson(data);
  }
}
