class Booking {
  final int id;
  final int groundId;
  final int userId;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final double totalPrice;
  final String paymentStatus;
  final String? groundName; // Computed or joined
  final String? groundImage;

  Booking({
    required this.id,
    required this.groundId,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
    required this.paymentStatus,
    this.groundName,
    this.groundImage,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      groundId: json['ground_id'],
      userId: json['user_id'],
      date: json['booking_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      paymentStatus: json['payment_status'],
      groundName: json['ground']?['name'],
      groundImage: json['ground']?['main_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ground_id': groundId,
      'booking_date': date,
      'start_time': startTime,
      'end_time': endTime,
      'total_price': totalPrice,
    };
  }
}
