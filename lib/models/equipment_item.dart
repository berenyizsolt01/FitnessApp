class EquipmentItem {
  final int id;
  final String nameHU;
  bool isSelected;

  EquipmentItem({
    required this.id,
    required this.nameHU,
    this.isSelected = false,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json, {bool isSelected = false}) {
    return EquipmentItem(
      id: json['id'],
      nameHU: json['nameHU'] ?? json['nameEN'] ?? '',
      isSelected: isSelected,
    );
  }
}
