class UpdateUserNameRequest {
  final String firstName;
  final String lastName;

  UpdateUserNameRequest({required this.firstName, required this.lastName});

  Map<String, dynamic> toJson() {
    return {'firstName': firstName, 'lastName': lastName};
  }
}
