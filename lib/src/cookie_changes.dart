import 'dart:io';

import 'package:shelf_cookie/shelf_cookie.dart';
import 'package:shelf_cookie/src/cookie_location.dart';

class CookieChanges {
  final Map<CookieLocation, Cookie> _cookies;
  final Set<CookieLocation> _toRemove;

  /// Whether to only deal with secure cookies. When set to true,
  /// any attempt to add an insecure cookie will result in an exception,
  /// no insecure cookies will be written out to the 'Set-Cookie' header,
  /// and any previous non-secure cookies will be removed
  final bool secureOnly;

  CookieChanges(
      {this.secureOnly = false,
      List<Cookie>? cookies,
      Map<CookieLocation, Cookie>? cookieMap,
      List<CookieLocation>? toRemove})
      : _cookies = (Map.from(cookieMap ?? {}))
          ..addEntries((cookies ?? []).map((cookie) => MapEntry(cookie.location, cookie))),
        _toRemove = Set.from(toRemove ?? []);

  factory CookieChanges.fromParser(CookieParser parser, {bool secureOnly = false, List<CookieLocation>? toRemove}) {
    return CookieChanges(
      secureOnly: secureOnly,
      cookies: secureOnly ? parser.secureCookies : parser.cookies,
      toRemove: toRemove,
    );
  }

  Map<CookieLocation, Cookie> get cookies => _cookies;

  List<CookieLocation> get toRemove => _toRemove.toList();

  bool get hasChanges => _toRemove.isNotEmpty || _cookies.isNotEmpty;

  Cookie setCookie(Cookie cookie) {
    if (secureOnly && !cookie.secure) {
      throw UnsupportedError("Cookies must be secure when cookie set to secure");
    }

    _cookies[cookie.location] = cookie;
    _toRemove.remove(cookie.location);
    return cookie;
  }

  /// Adds a new cookie to [_cookies] list.
  Cookie add(
    String name,
    String value, {
    String? domain,
    String? path,
    DateTime? expires,
    bool? httpOnly,
    bool? secure,
    int? maxAge,
    SameSite? sameSite,
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
      sameSite: sameSite,
    );

    setCookie(cookie);
    return cookie;
  }

  Cookie set(
    String name, {
    String? value,
    String? domain,
    String? path,
    DateTime? expires,
    bool? httpOnly,
    bool? secure,
    int? maxAge,
    SameSite? sameSite,
  }) {
    final existing = _cookies[CookieLocation(name, domain: domain, path: path)];
    if (existing == null) {
      return add(
        name,
        value ?? '',
        domain: domain,
        path: path,
        expires: expires,
        httpOnly: httpOnly,
        secure: secure,
        maxAge: maxAge,
        sameSite: sameSite,
      );
    }

    SameSite? existingSameSite;
    if (existing is ShelfCookie) {
      existingSameSite = existing.sameSite;
    }

    return add(
      name,
      value ?? existing.value,
      domain: domain,
      path: path,
      maxAge: maxAge ?? existing.maxAge,
      secure: secure ?? existing.secure,
      httpOnly: httpOnly ?? existing.httpOnly,
      expires: expires ?? existing.expires,
      sameSite: sameSite ?? existingSameSite,
    );
  }

  /// Removes a cookie from list by [name].
  void removeLocation(CookieLocation location) {
    _cookies.remove(location);
    _toRemove.add(location);
  }

  void removeCookie(Cookie cookie) => removeLocation(cookie.location);

  void remove(String name, {String? domain, String? path}) =>
      removeLocation(CookieLocation(name, domain: domain, path: path));

  void clear({bool removals = true, bool additions = true}) {
    assert(removals || additions, "At least one of removals or additions must be true");

    if (removals) {
      _toRemove.clear();
    }

    if (additions) {
      _cookies.clear();
    }
  }

  void clearSingle(String name, {String? domain, String? path, bool removal = true, bool addition = true}) {
    assert(removal || addition, "At least one of removal or addition must be true");

    final location = CookieLocation(name, domain: domain, path: path);

    if (removal) {
      _toRemove.remove(location);
    }
    if (addition) {
      _cookies.remove(location);
    }
  }
}
