import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/station_controller.dart';
import '../../controllers/location_controller.dart';
import '../../widgets/station_widgets/station_card.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final locationController = Get.find<LocationController>();
    await locationController.getCurrentLocation();

    if (locationController.hasCurrentLocation) {
      final stationController = Get.find<StationController>();
      stationController.setUserLocation(
        locationController.userLatitude!,
        locationController.userLongitude!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search Bar
            _buildSearchBar(),

            // Tab Bar
            _buildTabBar(),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNearbyTab(),
                  _buildAllStationsTab(),
                  _buildFavoritesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.map),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(
          Icons.map,
          color: AppColors.textWhite,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetBuilder<AuthController>(
                  builder: (controller) {
                    return Text(
                      'Hello, ${controller.userName.split(' ').first}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.findStations,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.profile),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.textWhite.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: AppColors.textWhite,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: CustomTextField(
        controller: _searchController,
        hintText: AppStrings.searchStations,
        prefixIcon: Icons.search,
        onChanged: (value) {
          final stationController = Get.find<StationController>();
          stationController.searchStations(value);
        },
        suffixIcon: IconButton(
          icon: const Icon(Icons.tune, color: AppColors.textSecondary),
          onPressed: () {
            _showFilterBottomSheet();
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            text: 'Nearby',
            icon: Icon(Icons.location_on, size: 20),
          ),
          Tab(
            text: 'All Stations',
            icon: Icon(Icons.list, size: 20),
          ),
          Tab(
            text: 'Favorites',
            icon: Icon(Icons.favorite, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyTab() {
    return GetBuilder<StationController>(
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () => controller.loadNearbyStations(),
          child: _buildStationsList(controller),
        );
      },
    );
  }

  Widget _buildAllStationsTab() {
    return GetBuilder<StationController>(
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () => controller.loadStations(refresh: true),
          child: _buildStationsList(controller),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return GetBuilder<StationController>(
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () => controller.loadFavoriteStations(),
          child: _buildFavoritesList(controller),
        );
      },
    );
  }

  Widget _buildStationsList(StationController controller) {
    if (controller.isLoading.value && controller.stationsList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      );
    }

    if (controller.hasError) {
      return _buildErrorState(controller);
    }

    if (!controller.hasStations) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.stationsList.length + (controller.isLoadingMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.stationsList.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
          );
        }

        final station = controller.stationsList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: StationCard(
            station: station,
            onTap: () {
              controller.selectStation(station);
              Get.toNamed(AppRoutes.stationDetails, arguments: station);
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoritesList(StationController controller) {
    if (controller.isLoading.value && controller.favoriteStations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      );
    }

    if (controller.favoriteStations.isEmpty) {
      return _buildEmptyFavoritesState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.favoriteStations.length,
      itemBuilder: (context, index) {
        final station = controller.favoriteStations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: StationCard(
            station: station,
            onTap: () {
              controller.selectStation(station);
              Get.toNamed(AppRoutes.stationDetails, arguments: station);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(StationController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.loadStations(refresh: true),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ev_station_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'No charging stations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFavoritesState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'No favorite stations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add stations to favorites to see them here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // Add filter options here
            const Text('Filter options will be implemented here'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final stationController = Get.find<StationController>();
                      stationController.clearFilters();
                      Get.back();
                    },
                    child: const Text('Clear Filters'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}