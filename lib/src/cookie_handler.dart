import 'dart:io';

import 'package:shelf_cookie/shelf_cookie.dart';
import 'package:shelf_cookie/src/cookie_changes.dart';

import 'cookie_location.dart';

extension Expired on Cookie {
  Cookie get asExpired => ShelfCookie.expiredFromCookie(this);
}

class CookieHandler {
  final CookieChanges? _changes;
  final Map<CookieLocation, Cookie> _actual = {};

  CookieHandler(this._changes) {
    if (_changes != null) {
      _changes!.toRemove.forEach((location) => _actual.remove(location));
      _actual.addAll(_changes!.cookies);
    }
  }

  Cookie? getCookie(
    String name, {
    String? domain,
    String? path,
  }) =>
      _actual[CookieLocation(
        name,
        domain: domain,
        path: path,
      )];

  List<String> get asList => _actual.values.map((cookie) => cookie.toString()).toList();

  bool get hasValues => _actual.isNotEmpty;
}
