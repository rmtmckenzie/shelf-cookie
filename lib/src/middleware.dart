import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_cookie/src/cookie_changes.dart';
import 'package:shelf_cookie/src/cookie_handler.dart';

import 'cookie_parser.dart';

const _requestContextKey = 'cookies';
const _responseContextKey = 'cookies';

extension RequestCookie on shelf.Request {
  CookieParser get cookies {
    final cookies = context[_requestContextKey] as CookieParser?;

    if (cookies == null) {
      throw StateError("cookieParser not added as middleware.");
    }

    return cookies;
  }

  Cookie? cookie(String name) {
    return cookies[name];
  }
}

extension ContextWithCookies on Map<String, dynamic> {
  Map<String, dynamic> withCookies(CookieChanges cookies) {
    this[_responseContextKey] = cookies;
    return this;
  }
}

extension ResponseWithCookies on shelf.Response {
  shelf.Response withCookies(CookieChanges cookies) {
    return this.change(context: {_responseContextKey: cookies});
  }

  CookieChanges? get cookies {
    return context[_responseContextKey] as CookieChanges?;
  }
}

/// Creates a Shelf [Middleware] to parse cookies.
///
/// Adds a [CookieMiddleware] instance to `request.context['cookies']`,
/// with convenience methods to manipulate cookies in request handlers.
///
/// Adds a `Set-Cookie` HTTP header to the response with all cookies.
shelf.Middleware cookieMiddleware() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) {
      final requestCookies = CookieParser.fromHeaders(request.headers);
      return Future.sync(() {
        return innerHandler(
          request.change(context: {_requestContextKey: requestCookies}),
        );
      }).then((shelf.Response response) {
        final responseCookies = response.context[_responseContextKey] as CookieChanges?;

        final handler = CookieHandler(responseCookies);

        if (!handler.hasValues) {
          return response;
        }

        return response.change(
          headers: {HttpHeaders.setCookieHeader: handler.asList},
        );
      }, onError: (error, StackTrace stackTrace) {
        throw error;
      });
    };
  };
}
