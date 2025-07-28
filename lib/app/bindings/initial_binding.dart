import 'package:get/get.dart';

import '../modules/analytics/controllers/analytics_controller.dart';
import '../modules/category/controllers/category_controller.dart';
import '../modules/expense/controllers/expense_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/settings/controllers/settings_controller.dart';
import '../modules/todo/controllers/todo_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<ExpenseController>(() => ExpenseController(), fenix: true);
    Get.lazyPut<TodoController>(() => TodoController(), fenix: true);
    Get.lazyPut<AnalyticsController>(() => AnalyticsController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
  }
}
