import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/download_category.dart';
import '../../data/repositories/category_repository.dart';
import 'download_providers.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(databaseProvider));
});

final allCategoriesProvider = StreamProvider<List<DownloadCategory>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAllCategories();
});
