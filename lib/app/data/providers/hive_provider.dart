import 'package:hive_flutter/hive_flutter.dart';

import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../models/receipt_model.dart';
import '../models/todo_model.dart';

class HiveProvider {
  static const String expenseBoxName = 'expenses';
  static const String categoryBoxName = 'categories';
  static const String todoBoxName = 'todos';
  static const String budgetBoxName = 'budgets';
  static const String receiptBoxName = 'receipts';
  static const String settingsBoxName = 'settings';
  static const String incomeBoxName = 'income';

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
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }

  static Future<void> clearAllData() async {
    // Use the already opened typed boxes instead of trying to reopen them
    try {
      // Clear typed boxes using the getter methods
      await getExpenseBox().clear();
      await getTodoBox().clear();
      await getBudgetBox().clear();
      await getReceiptBox().clear();
      await getIncomeBox().clear();

      // Don't clear categories and settings as per the original comment
      // await getCategoryBox().clear();
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
}
