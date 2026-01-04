abstract class ApiConsumer {
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});

  Future<dynamic> post(String path,
      {Map<String, dynamic>? body,
      Map<String, dynamic>? queryParameters});
  // Future<dynamic> post(
  //     String path, {
  //       Map<String, dynamic>? body,
  //       Map<String, dynamic>? queryParameters,
  //       Map<String, MultipartFile>? files,
  //     });

  Future<dynamic> postWithImage(String path,
      {Map<String, dynamic>? body,
      Map<String, dynamic>? queryParameters,
      dynamic params});

  Future<dynamic> postCreateService(String path,
      {Map<String, dynamic>? body,
        Map<String, dynamic>? queryParameters,
        dynamic params});

  Future<dynamic> postRegister(String path,
      {Map<String, dynamic>? body,
      Map<String, dynamic>? queryParameters,
      dynamic params});

  Future<dynamic> put(String path,
      {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters});

  Future<dynamic> delete(String path,
      {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters});
}
