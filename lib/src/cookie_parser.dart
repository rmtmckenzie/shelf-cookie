import 'dart:io';

import 'package:shelf/shelf.dart';

import 'parse_cookie_string.dart';
import 'shelf_cookie.dart';

Cookie makeCookie(
  String name,
  String value, {
  String? domain,
  String? path,
  DateTime? expires,
  bool? httpOnly,
  bool? secure,
  int? maxAge,
}) {
  final cookie = Cookie(name, value);
  if (domain != null) cookie.domain = domain;
  if (path != null) cookie.path = path;
  if (expires != null) cookie.expires = expires;
  if (httpOnly != null) cookie.httpOnly = httpOnly;
  if (secure != null) cookie.secure = secure;
  if (maxAge != null) cookie.maxAge = maxAge;

  return cookie;
}

/// Parses cookies from the `Cookie` header of a [Request].
///
/// Stores all cookies in a [cookies] list, and has convenience
/// methods to manipulate this list.
///
/// `toString()` method converts list items to a `Set-Cookie`
/// HTTP header value according to RFC 2109 spec (deprecated).
///
/// `toStrings()` method converts list items to a set of
/// `Set-Cookie` HTTP header values according to RFC
class CookieParser {
  /// A list of parsed cookies.
  final List<Cookie> cookies = [];

  List<Cookie> get secureCookies => cookies.where((cookie) => cookie.secure == true).toList();

  List<Cookie> get inSecureCookies => cookies.where((cookie) => cookie.secure != true).toList();

  /// Creates a new [CookieParser] by parsing the `Cookie` header [value].
  CookieParser.fromCookieValue(String? value) {
    if (value != null) {
      cookies.addAll(parseCookieString(value, (name, value) => ShelfCookie.fromSetCookieValue("$name=$value")));
    }
  }

  /// Factory constructor to create a new instance from request [headers].
  factory CookieParser.fromHeaders(Map<String, dynamic> headers) {
    return CookieParser.fromCookieValue(headers[HttpHeaders.cookieHeader]);
  }

  /// Denotes whether the [cookies] list is empty.
  bool get isEmpty => cookies.isEmpty;

  /// Retrieves a cookie by [name].
  Cookie? get(String name) =>
      cookies.cast<Cookie?>().firstWhere((Cookie? cookie) => cookie!.name == name, orElse: () => null);

  operator [](String name) => get(name);
}
