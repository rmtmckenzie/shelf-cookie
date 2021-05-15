import 'dart:io';

class ShelfCookie implements Cookie {
  ShelfCookie({
    required this.name,
    required this.value,
    this.domain,
    this.expires,
    this.httpOnly = true,
    this.maxAge,
    this.path,
    this.secure = true,
  });

  factory ShelfCookie.fromSetCookieValue(String value) {
    return ShelfCookie.fromCookie(Cookie.fromSetCookieValue(value));
  }

  factory ShelfCookie.fromCookie(Cookie cookie) {
    return ShelfCookie(
      name: cookie.name,
      value: cookie.value,
      domain: cookie.domain,
      secure: cookie.secure,
      maxAge: cookie.maxAge,
      httpOnly: cookie.httpOnly,
      expires: cookie.expires,
      path: cookie.path,
    );
  }

  @override
  final String name;

  @override
  final String value;

  @override
  final String? domain;

  @override
  final DateTime? expires;

  @override
  final bool httpOnly;

  @override
  final int? maxAge;

  @override
  final String? path;

  @override
  final bool secure;

  ShelfCookie copyWith(
    String? name,
    String? value,
    String? domain,
    DateTime? expires,
    bool? httpOnly,
    int? maxAge,
    String? path,
    bool? secure,
  ) {
    return ShelfCookie(
      name: name ?? this.name,
      value: value ?? this.value,
      domain: domain ?? this.domain,
      expires: expires ?? this.expires,
      httpOnly: httpOnly ?? this.httpOnly,
      maxAge: maxAge ?? this.maxAge,
      path: path ?? this.path,
      secure: secure ?? this.secure,
    );
  }

  @override
  set domain(String? _domain) {
    throw UnsupportedError("ShelfCookie doesn't support changing cookie options");
  }

  @override
  set expires(DateTime? _expires) {
    throw UnsupportedError("ShelfCookie doesn't support changing cookie options");
  }

  @override
  set httpOnly(bool _httpOnly) {
    throw UnsupportedError("ShelfCookie doesn't support changing cookie options");
  }

  @override
  set maxAge(int? _maxAge) {
    throw UnsupportedError("ShelfCookie doesn't support changing cookie options");
  }

  @override
  set name(String _name) {
    throw UnsupportedError("ShelfCookie doesn't support changing cookie options");
  }

  @override
  set path(String? _path) {
    throw UnsupportedError("ShelfCookie doesn't support changing cookie options");
  }

  @override
  set secure(bool _secure) {
    throw UnsupportedError("ShelfCookie doesn't support changing cookie options");
  }

  @override
  set value(String _value) {
    throw UnsupportedError("ShelfCookie doesn't support changing cookie options");
  }

  @override
  String toString() {
    return (Cookie(name, value)
          ..expires = expires
          ..maxAge = maxAge
          ..domain = domain
          ..path = path
          ..secure = secure
          ..httpOnly = httpOnly)
        .toString();
  }
}
