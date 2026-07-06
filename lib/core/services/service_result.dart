class ServiceResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const ServiceResult({this.data, this.error, required this.isSuccess});

  bool get isFailure => !isSuccess;

  String? get errorMessage => error;

  factory ServiceResult.success([T? data]) {
    return ServiceResult<T>(data: data, isSuccess: true);
  }

  factory ServiceResult.failure(String error) {
    return ServiceResult<T>(error: error, isSuccess: false);
  }
}
