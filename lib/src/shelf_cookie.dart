import 'dart:io';

enum SameSite { lax, strict, none }

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
    this.sameSite,
  });

  factory ShelfCookie.fromSetCookieValue(String value) {
    return ShelfCookie.fromCookie(Cookie.fromSetCookieValue(value));
  }

  factory ShelfCookie.fromCookie(Cookie cookie) {
    SameSite? sameSite;
    if (cookie is ShelfCookie) {
      sameSite = cookie.sameSite;
    }

    return ShelfCookie(
      name: cookie.name,
      value: cookie.value,
      domain: cookie.domain,
      secure: cookie.secure,
      maxAge: cookie.maxAge,
      httpOnly: cookie.httpOnly,
      expires: cookie.expires,
      path: cookie.path,
      sameSite: sameSite,
    );
  }

  factory ShelfCookie.expiredFromCookie(Cookie cookie) {
    SameSite? sameSite;
    if (cookie is ShelfCookie) {
      sameSite = cookie.sameSite;
    }

    return ShelfCookie(
      name: cookie.name,
      value: cookie.value,
      domain: cookie.domain,
      secure: cookie.secure,
      httpOnly: cookie.httpOnly,
      path: cookie.path,
      expires: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      maxAge: 0,
      sameSite: sameSite,
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

  @override
  final SameSite? sameSite;

  ShelfCookie copyWith(
    String? name,
    String? value,
    String? domain,
    DateTime? expires,
    bool? httpOnly,
    int? maxAge,
    String? path,
    bool? secure,
    SameSite? sameSite,
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
      sameSite: sameSite ?? this.sameSite,
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
    // copied from dart:io > http.dart cookie class
    StringBuffer sb = new StringBuffer();
    sb..write(name)..write("=")..write(value);
    var expires = this.expires;
    if (expires != null) {
      sb..write("; Expires=")..write(HttpDate.format(expires));
    }
    if (maxAge != null) {
      sb..write("; Max-Age=")..write(maxAge);
    }
    if (domain != null) {
      sb..write("; Domain=")..write(domain);
    }
    if (path != null) {
      sb..write("; Path=")..write(path);
    }
    // added to support samesite
    if (sameSite != null) {
      late String sameSiteString;
      switch (sameSite!) {
        case SameSite.lax:
          sameSiteString = "Lax";
          break;
        case SameSite.strict:
          sameSiteString = "Strict";
          break;
        case SameSite.none:
          sameSiteString = "None";
          break;
      }
      sb..write("; SameSite=")..write(sameSiteString);
    }
    if (secure) sb.write("; Secure");
    if (httpOnly) sb.write("; HttpOnly");
    return sb.toString();
  }
}
