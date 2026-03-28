import 'package:get/get.dart';

import '../modules/budget/controllers/budget_controller.dart';
import '../modules/category/controllers/category_controller.dart';
import '../modules/expense/controllers/expense_controller.dart';

class BudgetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BudgetController>(() => BudgetController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<ExpenseController>(() => ExpenseController());
  }
}