// authenticated_client.dart
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final Future<Map<String, String>> Function() _getHeaders;

  AuthenticatedClient(this._inner, this._getHeaders);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(await _getHeaders());
    return _inner.send(request);
  }
}