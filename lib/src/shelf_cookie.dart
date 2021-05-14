import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;

import 'cookie_parser.dart';

extension RequestCookie on shelf.Request {
  CookieParser get cookies {
    final cookies = context['cookies'] as CookieParser?;

    if (cookies == null) {
      throw StateError("cookieParser not added as middleware.");
    }

    return cookies;
  }
}

/// Creates a Shelf [Middleware] to parse cookies.
///
/// Adds a [CookieParser] instance to `request.context['cookies']`,
/// with convenience methods to manipulate cookies in request handlers.
///
/// Adds a `Set-Cookie` HTTP header to the response with all cookies.
shelf.Middleware cookieParser() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) {
      var cookies = CookieParser.fromHeader(request.headers);
      return Future.sync(() {
        return innerHandler(
          request.change(context: {'cookies': cookies}),
        );
      }).then((shelf.Response response) {
        if (cookies.isEmpty) {
          return response;
        }
        return response.change(
          headers: {HttpHeaders.setCookieHeader: cookies.toString()},
        );
      }, onError: (error, StackTrace stackTrace) {
        throw error;
      });
    };
  };
}
