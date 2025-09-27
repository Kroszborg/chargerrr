import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../domain/entities/station_entity.dart';
import '../../controllers/location_controller.dart';
import '../../widgets/common/custom_button.dart';

class StationDetailsScreen extends StatefulWidget {
  const StationDetailsScreen({super.key});

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  late StationEntity station;

  @override
  void initState() {
    super.initState();
    station = Get.arguments as StationEntity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(),

          // Content
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.textWhite),
          onPressed: () {
            // TODO: Toggle favorite
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.textWhite),
          onPressed: () {
            // TODO: Share station
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: station.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: station.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.backgroundColor,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.ev_station,
                      size: 80,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.ev_station,
                    size: 80,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          _buildHeaderInfo(),

          const SizedBox(height: 20),

          // Availability Status
          _buildAvailabilitySection(),

          const SizedBox(height: 20),

          // Pricing Info
          _buildPricingSection(),

          const SizedBox(height: 20),

          // Connector Types
          _buildConnectorSection(),

          const SizedBox(height: 20),

          // Amenities
          if (station.amenities.isNotEmpty) _buildAmenitiesSection(),

          const SizedBox(height: 20),

          // Map
          _buildMapSection(),

          const SizedBox(height: 20),

          // Operating Hours
          if (station.operatingHours != null) _buildOperatingHoursSection(),

          const SizedBox(height: 20),

          // Contact Info
          _buildContactSection(),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          station.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                station.address,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.star,
              size: 18,
              color: Colors.amber[600],
            ),
            const SizedBox(width: 4),
            Text(
              AppUtils.formatRating(station.rating),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${station.reviewsCount} reviews)',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (station.distance != null) ...[
              const SizedBox(width: 16),
              const Icon(
                Icons.directions_car,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                AppUtils.formatDistance(station.distance!),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    final Color statusColor = AppUtils.getAvailabilityColor(
      station.hasAvailablePoints,
      station.isOperational,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Availability',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppUtils.getAvailabilityText(
                  station.availablePoints,
                  station.totalPoints,
                  station.isOperational,
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: station.totalPoints > 0
                ? (station.totalPoints - station.availablePoints) / station.totalPoints
                : 0,
            backgroundColor: AppColors.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
          const SizedBox(height: 8),
          Text(
            '${station.totalPoints - station.availablePoints} of ${station.totalPoints} charging points in use',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payment,
            color: AppColors.successColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pricing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${AppUtils.formatPrice(station.pricePerUnit)} per kWh',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connector Types',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: station.connectorTypes.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppUtils.getConnectorIcon(type),
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amenities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: station.amenities.map((amenity) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppUtils.getAmenityIcon(amenity),
                    size: 20,
                    color: AppColors.secondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppUtils.capitalizeWords(amenity.replaceAll('_', ' ')),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(station.latitude, station.longitude),
            zoom: 16,
          ),
          markers: {
            Marker(
              markerId: MarkerId(station.id),
              position: LatLng(station.latitude, station.longitude),
              infoWindow: InfoWindow(title: station.name),
            ),
          },
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }

  Widget _buildOperatingHoursSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operating Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...station.operatingHours!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppUtils.capitalizeFirst(entry.key),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (station.operatorName != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.business,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  station.operatorName!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (station.operatorPhone != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  station.operatorPhone!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Get Directions',
                onPressed: () {
                  final locationController = Get.find<LocationController>();
                  locationController.animateToStation(station);
                },
                icon: const Icon(Icons.directions, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Start Charging',
                onPressed: station.hasAvailablePoints && station.isOperational
                    ? () {
                        // TODO: Implement start charging
                      }
                    : null,
                backgroundColor: AppColors.secondaryColor,
                icon: const Icon(Icons.electric_bolt, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}