import 'package:get/get.dart';

import '../bindings/budget_binding.dart';
import '../bindings/expense_binding.dart';
import '../bindings/notification_inbox_binding.dart';
import '../bindings/todo_binding.dart';
import '../modules/achievements/views/achievements_view.dart';
import '../modules/analytics/views/financial_calendar_view.dart';
import '../modules/auth/views/lock_screen_view.dart';
import '../modules/auth/views/reset_pin_view.dart';
import '../modules/auth/views/setup_pin_view.dart';
import '../modules/backup/views/backup_restore_view.dart';
import '../modules/budget/views/add_budget_view.dart';
import '../modules/budget/views/budget_view.dart';
import '../modules/category/controllers/category_controller.dart';
import '../modules/category/views/add_category_view.dart';
import '../modules/category/views/category_view.dart';
import '../modules/coach/views/money_coach_view.dart';
import '../modules/debt/controllers/debt_controller.dart';
import '../modules/debt/views/add_debt_view.dart';
import '../modules/debt/views/debt_view.dart';
import '../modules/expense/views/add_expense_view.dart';
import '../modules/expense/views/expense_detail_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/income/bindings/income_binding.dart';
import '../modules/income/views/add_income_view.dart';
import '../modules/income/views/income_detail_view.dart';
import '../modules/insights/views/insights_view.dart';
import '../modules/mood/views/mood_journal_view.dart';
import '../modules/notifications/views/notification_inbox_view.dart';
import '../modules/savings/controllers/savings_controller.dart';
import '../modules/savings/views/add_savings_goal_view.dart';
import '../modules/savings/views/savings_view.dart';
import '../modules/search/views/smart_search_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/simulator/views/whatif_simulator_view.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/split/controllers/split_controller.dart';
import '../modules/split/views/add_split_view.dart';
import '../modules/split/views/split_view.dart';
import '../modules/story/views/money_story_view.dart';
import '../modules/subscription/controllers/subscription_controller.dart';
import '../modules/subscription/views/add_subscription_view.dart';
import '../modules/subscription/views/subscription_view.dart';
import '../modules/templates/views/expense_templates_view.dart';
import '../modules/todo/views/add_todo_view.dart';
import '../modules/todo/views/todo_detail_view.dart';
import '../bindings/account_binding.dart';
import '../modules/account/views/account_view.dart';
import '../modules/account/views/add_account_view.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashView()),
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
    GetPage(
      name: Routes.ADD_INCOME,
      page: () => AddIncomeView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.INCOME_DETAIL,
      page: () => IncomeDetailView(),
      binding: IncomeBinding(),
      transition: Transition.rightToLeft,
    ),
    // BUDGET ROUTES
    GetPage(
      name: Routes.categories,
      page: () => CategoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CategoryController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.budgets,
      page: () => BudgetView(),
      binding: BudgetBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ADD_BUDGET,
      page: () => AddBudgetView(),
      binding: BudgetBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.EDIT_BUDGET,
      page: () => AddBudgetView(),
      binding: BudgetBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/accounts',
      page: () => const AccountView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: '/add-account',
      page: () => const AddAccountView(),
      binding: AccountBinding(),
    ),
    // Savings
    GetPage(
      name: '/savings',
      page: () => const SavingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SavingsController>(() => SavingsController());
      }),
    ),
    GetPage(name: '/add-savings-goal', page: () => const AddSavingsGoalView()),

    // Debt
    GetPage(
      name: '/debt',
      page: () => const DebtView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DebtController>(() => DebtController());
      }),
    ),
    GetPage(name: '/add-debt', page: () => const AddDebtView()),

    // Financial Calendar
    GetPage(
      name: '/financial-calendar',
      page: () => const FinancialCalendarView(),
    ),
    GetPage(
      name: '/notifications',
      page: () => const NotificationInboxView(),
      binding: NotificationInboxBinding(),
    ),
    GetPage(name: '/insights', page: () => const InsightsView()),
    GetPage(
      name: '/splits',
      page: () => const SplitView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplitController>(() => SplitController());
      }),
    ),
    GetPage(name: '/add-split', page: () => const AddSplitView()),
    GetPage(name: '/search', page: () => const SmartSearchView()),
    GetPage(
      name: '/subscriptions',
      page: () => const SubscriptionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SubscriptionController>(() => SubscriptionController());
      }),
    ),
    GetPage(name: '/add-subscription', page: () => const AddSubscriptionView()),
    GetPage(name: '/money-coach', page: () => const MoneyCoachView()),
    GetPage(name: '/money-story', page: () => const MoneyStoryView()),
    GetPage(name: '/mood-journal', page: () => const MoodJournalView()),
    GetPage(name: '/what-if', page: () => const WhatIfSimulatorView()),
    GetPage(name: '/setup-pin', page: () => const SetupPinView()),
    GetPage(name: '/lock', page: () => const LockScreenView()),
    GetPage(name: '/reset-pin', page: () => const ResetPinView()),
    GetPage(name: '/backup', page: () => const BackupRestoreView()),
    GetPage(name: '/achievements', page: () => const AchievementsView()),
    GetPage(name: '/templates', page: () => const ExpenseTemplatesView()),
  ];
}
