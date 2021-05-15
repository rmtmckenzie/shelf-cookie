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

  Iterable<Cookie> get secureCookies => cookies.where((cookie) => cookie.secure == true);

  /// Whether to only deal with secure cookies. When set to true,
  /// any attempt to add an insecure cookie will result in an exception,
  /// and no insecure cookies will be written out to the 'Set-Cookie' header.
  bool secureOnly = false;

  /// Creates a new [CookieParser] by parsing the `Cookie` header [value].
  CookieParser.fromCookieValue(String? value) {
    if (value != null) {
      cookies.addAll(parseCookieString(value, (name, value) => ShelfCookie.fromSetCookieValue(value)));
    }
  }

  /// Factory constructor to create a new instance from request [headers].
  factory CookieParser.fromHeader(Map<String, dynamic> headers) {
    return CookieParser.fromCookieValue(headers[HttpHeaders.cookieHeader]);
  }

  /// Denotes whether the [cookies] list is empty.
  bool get isEmpty => cookies.isEmpty;

  /// Retrieves a cookie by [name].
  Cookie? get(String name) =>
      cookies.cast<Cookie?>().firstWhere((Cookie? cookie) => cookie!.name == name, orElse: () => null);

  operator [](String name) => get(name);

  Cookie setCookie(Cookie cookie) {
    if (secureOnly && !cookie.secure) {
      throw UnsupportedError("Cookies must be secure when cookie set to secure");
    }

    // Update existing cookie, or append new one to list.
    var index = cookies.indexWhere((item) => item.name == cookie.name);
    if (index != -1) {
      cookies.replaceRange(index, index + 1, [cookie]);
    } else {
      cookies.add(cookie);
    }
    return cookie;
  }

  /// Adds a new cookie to [cookies] list.
  Cookie set(
    String name,
    String value, {
    String? domain,
    String? path,
    DateTime? expires,
    bool? httpOnly,
    bool? secure,
    int? maxAge,
  }) {
    final cookie = ShelfCookie(
      name: name,
      value: value,
      domain: domain,
      path: path,
      expires: expires,
      httpOnly: httpOnly ?? true,
      secure: secure ?? true,
      maxAge: maxAge,
    );

    setCookie(cookie);
    return cookie;
  }

  /// Removes a cookie from list by [name].
  void remove(String name) => cookies.removeWhere((Cookie cookie) => cookie.name == name);

  /// Clears the cookie list.
  void clear() => cookies.clear();

  /// Converts the cookies to a string value to use in a `Set-Cookie` header.
  ///
  /// This implements the old RFC 2109 spec, which allowed for multiple
  /// cookies to be folded into a single `Set-Cookie` header value,
  /// separated by commas.
  ///
  /// As of RFC 6265, this folded mechanism is deprecated in favour of
  /// a multi-header approach.
  ///
  /// Unfortunately, Shelf doesn't currently support multiple headers
  /// of the same type. This is an ongoing issue, but once resolved,
  /// this method can be deprecated.
  ///
  /// https://github.com/dart-lang/shelf/issues/44
  String toString() {
    return (secureOnly ? cookies : secureCookies).fold(
      '',
      (prev, element) => prev.isEmpty ? element.toString() : '${prev.toString()}, ${element.toString()}',
    );
  }

  /// Converts the cookies to a list of string values to use in
  /// `Set-Cookie` headers.
  Iterable<String> toStrings() {
    return (secureOnly ? cookies : secureCookies).map((cookie) => cookie.toString());
  }
}
