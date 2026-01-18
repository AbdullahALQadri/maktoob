import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Model representing a package in the Golden Scenario flow
class GoldenPackageModel extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String price;
  final String emoji;
  final List<String> features;
  final List<String> featuresAr;
  final List<Color> gradientColors;
  final bool isHighlighted;
  final bool isFree;

  const GoldenPackageModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    required this.emoji,
    required this.features,
    required this.featuresAr,
    required this.gradientColors,
    this.isHighlighted = false,
    this.isFree = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        price,
        emoji,
        features,
        featuresAr,
        gradientColors,
        isHighlighted,
        isFree,
      ];

  /// Predefined packages for the Golden Scenario
  static List<GoldenPackageModel> get packages => [
        const GoldenPackageModel(
          id: 'basic',
          name: 'Basic Organization',
          nameAr: 'تنظيم أساسي',
          price: 'Free',
          emoji: '🟢',
          features: [
            'Invitation link + QR code',
            'RSVP confirmation tracking',
            'Basic entry management',
            'Ideal for small events',
          ],
          featuresAr: [
            'رابط الدعوة + رمز QR',
            'تتبع تأكيد الحضور',
            'إدارة دخول أساسية',
            'مثالي للمناسبات الصغيرة',
          ],
          gradientColors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          isFree: true,
        ),
        const GoldenPackageModel(
          id: 'comfortable',
          name: 'Comfortable Organization',
          nameAr: 'تنظيم مريح',
          price: '299',
          emoji: '⭐',
          features: [
            'No watermark on invitation',
            'Detailed attendance reports',
            'Secure QR (one-time entry)',
            'WhatsApp support',
          ],
          featuresAr: [
            'بدون علامة مائية',
            'تقارير حضور مفصلة',
            'QR آمن (دخول مرة واحدة)',
            'دعم واتساب',
          ],
          gradientColors: [Color(0xFF9333EA), Color(0xFFDB2777)],
          isHighlighted: true,
        ),
        const GoldenPackageModel(
          id: 'full',
          name: 'Full Organization',
          nameAr: 'تنظيم كامل',
          price: '599',
          emoji: '👑',
          features: [
            'QR-based entry management',
            'Door staff coordination',
            'Photographer coordination',
            'Bulk discounts & priority support',
          ],
          featuresAr: [
            'إدارة دخول بـ QR',
            'تنسيق موظفي الباب',
            'تنسيق المصور',
            'خصومات وأولوية الدعم',
          ],
          gradientColors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
        ),
      ];

  /// Get package by ID
  static GoldenPackageModel? getById(String id) {
    try {
      return packages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
