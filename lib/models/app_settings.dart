import '../constants/app_constants.dart';

class AppSettings {
  final int id;
  final double cgstRate;
  final double sgstRate;

  const AppSettings({
    this.id = 1,
    this.cgstRate = AppConstants.defaultCgstRate,
    this.sgstRate = AppConstants.defaultSgstRate,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        id: map['id'] as int? ?? 1,
        cgstRate: (map['cgst_rate'] as num?)?.toDouble() ??
            AppConstants.defaultCgstRate,
        sgstRate: (map['sgst_rate'] as num?)?.toDouble() ??
            AppConstants.defaultSgstRate,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'cgst_rate': cgstRate,
        'sgst_rate': sgstRate,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      AppSettings.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  AppSettings copyWith({double? cgstRate, double? sgstRate}) => AppSettings(
        id: id,
        cgstRate: cgstRate ?? this.cgstRate,
        sgstRate: sgstRate ?? this.sgstRate,
      );
}
