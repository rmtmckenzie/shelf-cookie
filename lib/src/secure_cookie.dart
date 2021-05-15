import 'dart:io';

class SecureCookie implements Cookie {
  SecureCookie({
    required this.name,
    required this.value,
    this.domain,
    this.expires,
    this.httpOnly = true,
    this.maxAge,
    this.path,
  });

  factory SecureCookie.fromSetCookieValue(String value) {
    return SecureCookie.fromCookie(Cookie.fromSetCookieValue(value));
  }

  factory SecureCookie.fromCookie(Cookie cookie) {
    return SecureCookie(
      name: cookie.name,
      value: cookie.value,
      domain: cookie.domain,
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
  bool get secure => true;

  SecureCookie copyWith(
    String? name,
    String? value,
    String? domain,
    DateTime? expires,
    bool? httpOnly,
    int? maxAge,
    String? path,
  ) {
    return SecureCookie(
      name: name ?? this.name,
      value: value ?? this.value,
      domain: domain ?? this.domain,
      expires: expires ?? this.expires,
      httpOnly: httpOnly ?? this.httpOnly,
      maxAge: maxAge ?? this.maxAge,
      path: path ?? this.path,
    );
  }

  @override
  set domain(String? _domain) {
    throw UnsupportedError("SecureCookie doesn't support changing cookie options");
  }

  @override
  set expires(DateTime? _expires) {
    throw UnsupportedError("SecureCookie doesn't support changing cookie options");
  }

  @override
  set httpOnly(bool _httpOnly) {
    throw UnsupportedError("SecureCookie doesn't support changing cookie options");
  }

  @override
  set maxAge(int? _maxAge) {
    throw UnsupportedError("SecureCookie doesn't support changing cookie options");
  }

  @override
  set name(String _name) {
    throw UnsupportedError("SecureCookie doesn't support changing cookie options");
  }

  @override
  set path(String? _path) {
    throw UnsupportedError("SecureCookie doesn't support changing cookie options");
  }

  @override
  set secure(bool _secure) {
    throw UnsupportedError("SecureCookie doesn't support changing cookie options");
  }

  @override
  set value(String _value) {
    throw UnsupportedError("SecureCookie doesn't support changing cookie options");
  }

  @override
  String toString() {
    return (Cookie(name, value)
          ..expires = expires
          ..maxAge = maxAge
          ..domain = domain
          ..path = path
          ..secure = true
          ..httpOnly = httpOnly)
        .toString();
  }
}
