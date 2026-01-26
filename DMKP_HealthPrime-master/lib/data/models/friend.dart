class Friend {
  final int id;
  final String name;
  final String email;
  final String avatar;
  final String status;
  final Map<String, double> stats;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.status,
    required this.stats,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      status: json['status'],
      stats: Map<String, double>.from(json['stats']),
    );
  }
}