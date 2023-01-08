class User {
  final String userName;
  final double fitPoints;

  User(this.userName, this.fitPoints);

  User.fromJson(Map<String, dynamic> json)
      : userName = json['user_name'],
        fitPoints = json['fit_points'];

  Map<String, dynamic> toJson() => {
        'user_name': userName,
        'fit_points': fitPoints,
      };
}
