import 'dart:io';

import 'package:quiver/core.dart';

extension LocationForCookie on Cookie {
  CookieLocation get location => CookieLocation(name, domain: domain, path: path);
}

class CookieLocation {
  final String name;
  final String? domain;
  final String? path;

  CookieLocation(this.name, {this.domain, this.path});

  @override
  bool operator ==(Object other) {
    return (other is Cookie && other.name == name && other.domain == domain && other.path == path) ||
        (other is CookieLocation && other.name == name && other.domain == domain && other.path == path);
  }

  @override
  int get hashCode => hash3(name, domain, path);
}
