import 'package:hive_flutter/hive_flutter.dart';

import '../models/account_model.dart'; // NEW
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/debt_model.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../models/receipt_model.dart';
import '../models/savings_goal_model.dart';
import '../models/todo_model.dart';
import '../models/transfer_model.dart'; // NEW

class HiveProvider {
  static const String expenseBoxName = 'expenses';
  static const String categoryBoxName = 'categories';
  static const String todoBoxName = 'todos';
  static const String budgetBoxName = 'budgets';
  static const String receiptBoxName = 'receipts';
  static const String settingsBoxName = 'settings';
  static const String incomeBoxName = 'income';
  static const String autocompleteBoxName = 'autocomplete';
  static const String accountBoxName = 'accounts'; // NEW
  static const String transferBoxName = 'transfers'; // NEW

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TodoModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ReceiptModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(IncomeModelAdapter());
    }
    // ─── NEW ADAPTERS (Phase 1) ────────────────────────────
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(AccountModelAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(TransferModelAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(SavingsGoalModelAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(DebtModelAdapter());
    }

    // Open Boxes
    await openBoxes();
  }

  static Future<void> openBoxes() async {
    await Hive.openBox<ExpenseModel>(expenseBoxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
    await Hive.openBox<TodoModel>(todoBoxName);
    await Hive.openBox<BudgetModel>(budgetBoxName);
    await Hive.openBox<ReceiptModel>(receiptBoxName);
    await Hive.openBox<IncomeModel>(incomeBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(autocompleteBoxName);
    await Hive.openBox<AccountModel>(accountBoxName); // NEW
    await Hive.openBox<TransferModel>(transferBoxName); // NEW
    await Hive.openBox<SavingsGoalModel>('savings_goals');
    await Hive.openBox<DebtModel>('debts');
    await Hive.openBox('recurring_tracking');
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }

  static Future<void> clearAllData() async {
    try {
      await getExpenseBox().clear();
      await getTodoBox().clear();
      await getBudgetBox().clear();
      await getReceiptBox().clear();
      await getIncomeBox().clear();
      await getTransferBox().clear(); // NEW
      // Don't clear autocomplete, categories, accounts, and settings
    } catch (e) {
      print('Error clearing data: $e');
      throw e;
    }
  }

  static Box<ExpenseModel> getExpenseBox() {
    return Hive.box<ExpenseModel>(expenseBoxName);
  }

  static Box<CategoryModel> getCategoryBox() {
    return Hive.box<CategoryModel>(categoryBoxName);
  }

  static Box<TodoModel> getTodoBox() {
    return Hive.box<TodoModel>(todoBoxName);
  }

  static Box<BudgetModel> getBudgetBox() {
    return Hive.box<BudgetModel>(budgetBoxName);
  }

  static Box<ReceiptModel> getReceiptBox() {
    return Hive.box<ReceiptModel>(receiptBoxName);
  }

  static Box<IncomeModel> getIncomeBox() {
    return Hive.box<IncomeModel>(incomeBoxName);
  }

  static Box getSettingsBox() {
    return Hive.box(settingsBoxName);
  }

  static Box getAutocompleteBox() {
    return Hive.box(autocompleteBoxName);
  }

  // ─── NEW BOXES (Phase 1) ────────────────────────────────

  static Box<AccountModel> getAccountBox() {
    return Hive.box<AccountModel>(accountBoxName);
  }

  static Box<TransferModel> getTransferBox() {
    return Hive.box<TransferModel>(transferBoxName);
  }
}