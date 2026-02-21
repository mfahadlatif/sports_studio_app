import 'package:get/get.dart';

class FavoritesController extends GetxController {
  final RxSet<int> favoriteIds = <int>{}.obs;
  final RxList<dynamic> favoriteGrounds = <dynamic>[].obs;

  bool isFavorite(int id) => favoriteIds.contains(id);

  void toggleFavorite(dynamic ground) {
    if (ground == null || ground['id'] == null) return;

    final id = int.tryParse(ground['id'].toString()) ?? 0;
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
      favoriteGrounds.removeWhere(
        (g) => int.tryParse(g['id'].toString()) == id,
      );
      Get.snackbar(
        'Removed',
        'Removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      favoriteIds.add(id);
      favoriteGrounds.add(ground);
      Get.snackbar(
        'Added',
        'Added to favorites!',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
