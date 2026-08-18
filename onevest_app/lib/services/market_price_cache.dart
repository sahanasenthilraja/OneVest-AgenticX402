import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MarketPriceCache {
  MarketPriceCache._();

  static final MarketPriceCache instance =
      MarketPriceCache._();

  final Map<String, double> _prices = {};
  final Map<String, double> _changes = {};

  DateTime? _lastUpdated;

  Future<void>? _refreshFuture;

  static const Duration cacheDuration =
      Duration(seconds: 50);

  String get _baseUrl {
    if (kIsWeb) {
      return "http://localhost:4021";
    }

    return "http://10.0.2.2:4021";
  }

  bool get _cacheIsValid {
    if (_lastUpdated == null) {
      return false;
    }

    return DateTime.now().difference(_lastUpdated!) <
        cacheDuration;
  }

  Future<void> refresh(
    Set<String> symbols,
  ) async {
    final normalizedSymbols = symbols
        .map(
          (symbol) =>
              symbol.trim().toUpperCase(),
        )
        .where(
          (symbol) => symbol.isNotEmpty,
        )
        .toSet();

    if (normalizedSymbols.isEmpty) {
      return;
    }

    // If another refresh is already running,
    // everyone waits for the SAME request.
    if (_refreshFuture != null) {
      await _refreshFuture;
      return;
    }

    // Use the same cached snapshot for both
    // Dashboard and Portfolio.
    if (_cacheIsValid &&
        normalizedSymbols.every(
          (symbol) => _prices.containsKey(symbol),
        )) {
      return;
    }

    final completer = Completer<void>();
    _refreshFuture = completer.future;

    try {
      final results = await Future.wait(
        normalizedSymbols.map(
          (symbol) async {
            try {
              debugPrint(
                "Market cache: fetching $symbol",
              );

              final response = await http
                  .get(
                    Uri.parse(
                      "$_baseUrl/api/market-price"
                      "?symbol=${Uri.encodeComponent(symbol)}",
                    ),
                  )
                  .timeout(
                    const Duration(seconds: 10),
                  );

              debugPrint(
                "Market cache: $symbol -> "
                "${response.statusCode}",
              );

              if (response.statusCode != 200) {
                return null;
              }

              final decoded =
                  jsonDecode(response.body)
                      as Map<String, dynamic>;

              if (decoded["success"] != true) {
                return null;
              }

              final market =
                  decoded["market"];

              if (market is! Map) {
                return null;
              }

              final price =
                  market["price"];

              final change =
                  market["changePercent"];

              return MapEntry(
                symbol,
                <String, double>{
                  if (price is num)
                    "price": price.toDouble(),
                  if (change is num)
                    "change": change.toDouble(),
                },
              );
            } catch (e) {
              debugPrint(
                "Market cache error for $symbol: $e",
              );

              return null;
            }
          },
        ),
      );

      for (final result in results) {
        if (result == null) {
          continue;
        }

        final symbol = result.key;
        final values = result.value;

        final price = values["price"];
        final change = values["change"];

        if (price != null) {
          _prices[symbol] = price;
        }

        if (change != null) {
          _changes[symbol] = change;
        }
      }

      _lastUpdated = DateTime.now();

      debugPrint(
        "Market cache updated at $_lastUpdated",
      );
    } finally {
      completer.complete();
      _refreshFuture = null;
    }
  }

  double? getPrice(String symbol) {
    final key =
        symbol.trim().toUpperCase();

    return _prices[key];
  }

  double? getChange(String symbol) {
    final key =
        symbol.trim().toUpperCase();

    return _changes[key];
  }

  DateTime? get lastUpdated =>
      _lastUpdated;

  void clear() {
    _prices.clear();
    _changes.clear();
    _lastUpdated = null;
  }
}