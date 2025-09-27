import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/network/network_info.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/station_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/station_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/station_repository.dart';
import '../../domain/usecases/authenticate_user.dart';
import '../../domain/usecases/get_stations.dart';
import '../../domain/usecases/get_user_location.dart';
import '../controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // External Dependencies
    Get.lazyPut<FirebaseAuth>(() => FirebaseAuth.instance);
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance);
    Get.lazyPut<Connectivity>(() => Connectivity());

    // Core
    Get.lazyPut<NetworkInfo>(
      () => NetworkInfoImpl(connectivity: Get.find()),
    );

    // Data Sources
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: Get.find(),
        firestore: Get.find(),
      ),
    );

    Get.lazyPut<StationRemoteDataSource>(
      () => StationRemoteDataSourceImpl(
        firestore: Get.find(),
      ),
    );

    // Repositories
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find(),
        networkInfo: Get.find(),
      ),
    );

    Get.lazyPut<StationRepository>(
      () => StationRepositoryImpl(
        remoteDataSource: Get.find(),
        authDataSource: Get.find(),
        networkInfo: Get.find(),
      ),
    );

    // Use Cases
    Get.lazyPut<AuthenticateUser>(
      () => AuthenticateUser(repository: Get.find()),
    );

    Get.lazyPut<GetStations>(
      () => GetStations(repository: Get.find()),
    );

    Get.lazyPut<GetUserLocation>(
      () => GetUserLocation(),
    );

    // Controllers
    Get.put<AuthController>(
      AuthController(authenticateUser: Get.find()),
    );
  }
}