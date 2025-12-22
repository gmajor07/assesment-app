import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final itemsProvider = FutureProvider<List<Item>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchItems();
});
