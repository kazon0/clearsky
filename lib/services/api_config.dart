const String baseUrl = 'http://127.0.0.1:4523/m1/7226423-6952858-default';

Map<String, String> jsonHeaders({String? token}) => {
  'Content-Type': 'application/json',
  if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
};
