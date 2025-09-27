import 'package:get/get.dart';
import '../controllers/station_controller.dart';
import '../controllers/location_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Station Controller
    Get.lazyPut<StationController>(
      () => StationController(getStations: Get.find()),
    );

    // Location Controller
    Get.lazyPut<LocationController>(
      () => LocationController(getUserLocation: Get.find()),
    );
  }
}