class ActivityModel {
  final int id;
  final int user;
  final String userName;
  final String activityName;
  final String datetime;
  final String? imageIcon;
  final String createdAt;
  final String updatedAt;

  ActivityModel({
    required this.id,
    required this.user,
    required this.userName,
    required this.activityName,
    required this.datetime,
    this.imageIcon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      userName: json['user_name'] ?? '',
      activityName: json['activity_name'] ?? '',
      datetime: json['datetime'] ?? '',
      imageIcon: json['image_icon'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'user_name': userName,
      'activity_name': activityName,
      'datetime': datetime,
      'image_icon': imageIcon,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Returns formatted time string from datetime (e.g., "8:00 AM")
  String get formattedTime {
    try {
      final dt = DateTime.parse(datetime).toLocal();
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (_) {
      return datetime;
    }
  }

  /// Returns formatted date string (e.g., "Feb 24, 2026")
  String get formattedDate {
    try {
      final dt = DateTime.parse(datetime).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}