import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../domain/entities/station_entity.dart';

class StationCard extends StatelessWidget {
  final StationEntity station;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const StationCard({
    super.key,
    required this.station,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Station Image
                  _buildStationImage(),
                  const SizedBox(width: 12),
                  // Station Info
                  Expanded(
                    child: _buildStationInfo(),
                  ),
                  // Favorite Button
                  _buildFavoriteButton(),
                ],
              ),

              const SizedBox(height: 12),

              // Availability Status
              _buildAvailabilityStatus(),

              const SizedBox(height: 8),

              // Details Row
              _buildDetailsRow(),

              const SizedBox(height: 12),

              // Amenities
              if (station.amenities.isNotEmpty) _buildAmenities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.backgroundColor,
      ),
      child: station.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: station.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.ev_station,
                  color: AppColors.primaryColor,
                  size: 30,
                ),
              ),
            )
          : const Icon(
              Icons.ev_station,
              color: AppColors.primaryColor,
              size: 30,
            ),
    );
  }

  Widget _buildStationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          station.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          station.address,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: Colors.amber[600],
            ),
            const SizedBox(width: 4),
            Text(
              AppUtils.formatRating(station.rating),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${station.reviewsCount})',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (station.distance != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 2),
              Text(
                AppUtils.formatDistance(station.distance!),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      onPressed: onFavorite,
      icon: const Icon(
        Icons.favorite_border,
        color: AppColors.textLight,
        size: 24,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }

  Widget _buildAvailabilityStatus() {
    final Color statusColor = AppUtils.getAvailabilityColor(
      station.hasAvailablePoints,
      station.isOperational,
    );

    final String statusText = AppUtils.getAvailabilityText(
      station.availablePoints,
      station.totalPoints,
      station.isOperational,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow() {
    return Row(
      children: [
        // Price
        _buildDetailItem(
          icon: Icons.payment,
          label: AppUtils.formatPrice(station.pricePerUnit),
          color: AppColors.successColor,
        ),
        const SizedBox(width: 16),
        // Connector Types
        _buildDetailItem(
          icon: Icons.electrical_services,
          label: '${station.connectorTypes.length} types',
          color: AppColors.primaryColor,
        ),
        const Spacer(),
        // Navigate Button
        _buildNavigateButton(),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigateButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions,
            size: 14,
            color: AppColors.textWhite,
          ),
          SizedBox(width: 4),
          Text(
            'Navigate',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: station.amenities.take(4).map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppUtils.getAmenityIcon(amenity),
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                AppUtils.capitalizeFirst(amenity),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}