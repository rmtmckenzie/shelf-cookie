import 'dart:io';

import 'package:shelf_cookie/shelf_cookie.dart';
import 'package:shelf_cookie/src/cookie_changes.dart';
import 'package:shelf_cookie/src/cookie_handler.dart';
import 'package:test/test.dart';

void main() {
  test('isEmpty is true if header is empty', () {
    var cookies = CookieParser.fromCookieValue(null);
    expect(cookies.isEmpty, isTrue);
  });

  test('parses cookies from `cookie` header value', () {
    var cookies = CookieParser.fromCookieValue('foo=bar; baz=qux');
    expect(cookies.isEmpty, isFalse);
    expect(cookies.get('foo')?.value, equals('bar'));
    expect(cookies.get('baz')?.value, equals('qux'));
  });

  test('parses cookies from raw headers map', () {
    var cookies = CookieParser.fromHeaders({HttpHeaders.cookieHeader: 'foo=bar; baz=qux'});
    expect(cookies.isEmpty, isFalse);
    expect(cookies.get('foo')?.value, equals('bar'));
    expect(cookies.get('baz')?.value, equals('qux'));
  });

  test('adds new cookie to cookies list', () {
    var cookies = CookieParser.fromCookieValue('foo=bar');
    expect(cookies.isEmpty, isFalse);
    expect(cookies.get('baz'), isNull);
    CookieChanges changes = CookieChanges();
    changes.add('baz', 'qux');

    final handler = CookieHandler(changes);
    expect(handler.getCookie('baz')?.value, 'qux');
  });

  test('removes cookie from cookies list by name', () {
    var parser = CookieParser.fromCookieValue('foo=bar; baz=qux');
    expect(parser.get('baz')?.value, equals('qux'));

    final changes = CookieChanges.fromParser(parser);

    changes.remove('baz');

    final handler = CookieHandler(changes);

    expect(handler.getCookie('baz'), isNull);
  });

  test('clears all cookies in list', () {
    var parser = CookieParser.fromCookieValue('foo=bar; baz=qux');
    expect(parser.get('baz')?.value, equals('qux'));

    final changes = CookieChanges.fromParser(parser);
    changes.clear();

    final handler = CookieHandler(changes);
    expect(handler.hasValues, isFalse);
  });

  test('folds all cookies into multiple set-cookie header values', () {
    var parser = CookieParser.fromCookieValue('foo=bar');
    final changes = CookieChanges.fromParser(parser);

    expect(CookieHandler(CookieChanges.fromParser(parser)).asList, equals(['foo=bar']));

    changes.add('baz', 'qux', secure: true);

    final handler = CookieHandler(changes);
    expect(
      handler.asList,
      equals(['foo=bar', 'baz=qux; Secure; HttpOnly']),
    );
  });

  test('not-set cookie is null', () {
    var cookies = CookieParser.fromCookieValue('foo=bar');
    expect(cookies.get('baz')?.value, equals(null));
  });
}
