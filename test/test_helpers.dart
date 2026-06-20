import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Sets up a fake HTTP client for tests that returns empty but valid JSON
/// responses for any request. This prevents unmocked network calls from
/// throwing Dio 400 errors in the Flutter test environment.
///
/// Call inside a `setUp` block or at the start of a `testWidgets` body.
void setupFakeHttpClient() {
  HttpOverrides.global = _TestHttpOverrides();
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  Duration? connectionTimeout;

  @override
  int? maxConnectionsPerHost;

  @override
  bool autoUncompress = true;

  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _FakeHttpClientRequest(url);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.url);

  final Uri url;

  final Headers _headers = Headers();

  @override
  HttpHeaders get headers => _headers;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  int contentLength = -1;

  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  List<int> get _body => utf8.encode(jsonEncode(<String, dynamic>{}));

  @override
  int get statusCode => 200;

  @override
  String get reasonPhrase => 'OK';

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  int get contentLength => _body.length;

  @override
  HttpHeaders get headers => Headers();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    void Function()? onDone,
    Function? onError,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_body]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Headers implements HttpHeaders {
  final Map<String, List<String>> _headers = <String, List<String>>{};

  @override
  List<String>? operator [](String name) => _headers[name.toLowerCase()];

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers
        .putIfAbsent(
          preserveHeaderCase ? name : name.toLowerCase(),
          () => <String>[],
        )
        .add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[preserveHeaderCase ? name : name.toLowerCase()] = <String>[
      value.toString(),
    ];
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
