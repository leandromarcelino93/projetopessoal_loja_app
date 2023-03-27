class HttpExceptions implements Exception {
  final String msg;
  final int statusCode;

  HttpExceptions({required this.statusCode, required this.msg});

  @override
  String toString(){
    return msg;
  }
}