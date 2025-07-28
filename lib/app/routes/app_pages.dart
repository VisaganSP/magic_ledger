import 'package:get/get.dart';

import '../bindings/expense_binding.dart';
import '../bindings/todo_binding.dart';
import '../modules/category/views/add_category_view.dart';
import '../modules/category/views/category_view.dart';
import '../modules/expense/views/add_expense_view.dart';
import '../modules/expense/views/expense_detail_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/todo/views/add_todo_view.dart';
import '../modules/todo/views/todo_detail_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(name: Routes.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(
      name: Routes.ADD_EXPENSE,
      page: () => AddExpenseView(),
      binding: ExpenseBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.EXPENSE_DETAIL,
      page: () => ExpenseDetailView(),
      binding: ExpenseBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.CATEGORIES,
      page: () => CategoryView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ADD_CATEGORY,
      page: () => AddCategoryView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ADD_TODO,
      page: () => AddTodoView(),
      binding: TodoBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.TODO_DETAIL,
      page: () => TodoDetailView(),
      binding: TodoBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => SettingsView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
