const String baseUrl = 'http://8.148.213.29:8080/api/v1';
//const String baseUrl = 'http://localhost:8080/api/v1';
//const String baseUrl = 'http://10.0.2.2:8080/api/v1';
Map<String, String> jsonHeaders({String? token}) => {
  'Content-Type': 'application/json',
  if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
};
