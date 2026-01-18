import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

/// Smart stats dashboard card for guest tracking
class GuestStatsCard extends StatelessWidget {
  final int total;
  final int confirmed;
  final int declined;
  final int pending;

  const GuestStatsCard({
    super.key,
    required this.total,
    required this.confirmed,
    required this.declined,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple600, AppColors.pink600],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple600.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total guests - main stat
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    total.toString(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Guests',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    total == 0 ? 'Add your first guest' : 'invited to your event',
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          // Stats row
          Row(
            children: [
              _buildStatItem(
                context,
                count: confirmed,
                label: 'Confirmed',
                color: AppColors.green600,
                screenWidth: screenWidth,
              ),
              _buildStatItem(
                context,
                count: declined,
                label: 'Declined',
                color: AppColors.red500,
                screenWidth: screenWidth,
              ),
              _buildStatItem(
                context,
                count: pending,
                label: 'Waiting',
                color: AppColors.amber500,
                screenWidth: screenWidth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required int count,
    required String label,
    required Color color,
    required double screenWidth,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025),
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.02,
                  height: screenWidth * 0.02,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: screenWidth * 0.015),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.028,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
