import 'dart:io';

/// Parse a Cookie header value according to the rules in RFC 6265.
/// This function was adapted from `dart:io`.
List<Cookie> parseCookieString(String s, Cookie constructor(String name, String value)) {
  final cookies = <Cookie>[];

  int index = 0;

  bool done() => index == -1 || index == s.length;

  void skipWS() {
    while (!done()) {
      if (s[index] != " " && s[index] != "\t") return;
      index++;
    }
  }

  String parseName() {
    int start = index;
    while (!done()) {
      if (s[index] == " " || s[index] == "\t" || s[index] == "=") break;
      index++;
    }
    return s.substring(start, index);
  }

  String parseValue() {
    int start = index;
    while (!done()) {
      if (s[index] == " " || s[index] == "\t" || s[index] == ";") break;
      index++;
    }
    return s.substring(start, index);
  }

  bool expect(String expected) {
    if (done()) return false;
    if (s[index] != expected) return false;
    index++;
    return true;
  }

  while (!done()) {
    skipWS();
    if (done()) continue;
    String name = parseName();
    skipWS();
    if (!expect("=")) {
      index = s.indexOf(';', index);
      continue;
    }
    skipWS();
    String value = parseValue();
    try {
      cookies.add(constructor(name, value));
    } catch (_) {
      // Skip it, invalid cookie data.
    }
    skipWS();
    if (done()) continue;
    if (!expect(";")) {
      index = s.indexOf(';', index);
      continue;
    }
  }

  return cookies;
}
