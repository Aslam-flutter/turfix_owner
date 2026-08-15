enum SlotStatus { available, booked, unavailable }

class TimeSlotModel {
  final String startTime;
  final String endTime;
  final String price;
  final SlotStatus status;
  bool isSelected;

  TimeSlotModel({
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    this.isSelected = false,
  });
}
