import 'package:get/get.dart';

import '../modules/notifications/controllers/notification_inbox_controller.dart';

class NotificationInboxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationInboxController>(() => NotificationInboxController());
  }
}