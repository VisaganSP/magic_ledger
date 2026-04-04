import 'package:get/get.dart';

import '../data/services/period_service.dart';
import '../data/services/recurring_service.dart';
import '../data/services/sms_transaction_service.dart';
import '../modules/account/controllers/account_controller.dart';
import '../modules/analytics/controllers/analytics_controller.dart';
import '../modules/category/controllers/category_controller.dart';
import '../modules/debt/controllers/debt_controller.dart';
import '../modules/expense/controllers/expense_controller.dart';
import '../modules/expense/controllers/autocomplete_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/income/controllers/income_controller.dart';
import '../modules/notifications/controllers/notification_inbox_controller.dart';
import '../modules/savings/controllers/savings_controller.dart';
import '../modules/settings/controllers/settings_controller.dart';
import '../modules/split/controllers/split_controller.dart';
import '../modules/subscription/controllers/subscription_controller.dart';
import '../modules/todo/controllers/todo_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services (must be registered first)
    Get.put<PeriodService>(PeriodService(), permanent: true);
    Get.put<SmsTransactionService>(SmsTransactionService(), permanent: true);

    // Account must be registered before expense/income controllers
    Get.lazyPut<AccountController>(() => AccountController(), fenix: true);

    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<ExpenseController>(() => ExpenseController(), fenix: true);
    Get.lazyPut<AutocompleteController>(() => AutocompleteController(), fenix: true);
    Get.lazyPut<TodoController>(() => TodoController(), fenix: true);
    Get.lazyPut<IncomeController>(() => IncomeController(), fenix: true);
    Get.lazyPut<AnalyticsController>(() => AnalyticsController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.put<RecurringService>(RecurringService(), permanent: true);
    Get.lazyPut<SavingsController>(() => SavingsController(), fenix: true);
    Get.lazyPut<DebtController>(() => DebtController(), fenix: true);
    Get.put<NotificationInboxController>(NotificationInboxController(), permanent: true);
    Get.lazyPut<SplitController>(() => SplitController());
    Get.lazyPut<SubscriptionController>(() => SubscriptionController());
  }
}