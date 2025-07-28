import 'package:get/get.dart';

import '../modules/todo/controllers/todo_controller.dart';

class TodoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TodoController>(() => TodoController());
  }
}
