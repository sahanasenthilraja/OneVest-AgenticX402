import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LiveMarketWidget extends StatefulWidget {
  const LiveMarketWidget({super.key});

  @override
  State<LiveMarketWidget> createState() => _LiveMarketWidgetState();
}

class _LiveMarketWidgetState extends State<LiveMarketWidget> {
  static const String apiUrl =
      'http://10.0.2.2:4021/api/live-market';

  Timer? _timer;

  bool _loading = true;
  bool _hasError = false;

  String _errorMessage = '';

  DateTime? _lastUpdated;

  final Map<String, double> _prices = {};
  final Map<String, double> _changes = {};
  final Map<String, String> _currencies = {};

  @override
  void initState() {
    super.initState();

    _fetchMarketData();

    // Update automatically every 60 seconds.
    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _fetchMarketData(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMarketData() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned HTTP ${response.statusCode}',
        );
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body);

      if (json['success'] != true) {
        throw Exception(
          json['error']?.toString() ??
              'Market data request failed',
        );
      }

      final List<dynamic> markets =
          json['markets'] as List<dynamic>? ?? [];

      final newPrices = <String, double>{};
      final newChanges = <String, double>{};
      final newCurrencies = <String, String>{};

      for (final item in markets) {
        final market =
            item as Map<String, dynamic>;

        final name =
            market['name']?.toString();

        final price =
            (market['price'] as num?)?.toDouble();

        final change =
            (market['changePercent'] as num?)
                ?.toDouble();

        final currency =
            market['currency']?.toString() ?? '';

        if (name == null || price == null) {
          continue;
        }

        newPrices[name] = price;

        if (change != null) {
          newChanges[name] = change;
        }

        newCurrencies[name] = currency;
      }

      if (newPrices.isEmpty) {
        throw Exception(
          'No market data received',
        );
      }

      if (!mounted) return;

      setState(() {
        _prices
          ..clear()
          ..addAll(newPrices);

        _changes
          ..clear()
          ..addAll(newChanges);

        _currencies
          ..clear()
          ..addAll(newCurrencies);

        _lastUpdated = DateTime.now();

        _loading = false;
        _hasError = false;
        _errorMessage = '';
      });
    } catch (error) {
      debugPrint(
        'Live market error: $error',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage =
            'Unable to update market data';
      });
    }
  }

  double? _price(String name) {
    return _prices[name];
  }

  double? _change(String name) {
    return _changes[name];
  }

String _formatPrice(
  String name,
  double? value,
) {
  if (value == null) {
    return '--';
  }

  // NIFTY 50 and SENSEX are index values.
  // Do not add a currency symbol.
  if (name == 'NIFTY 50' ||
      name == 'SENSEX') {
    return value.toStringAsFixed(2);
  }

  final currency = _currencies[name] ?? '';

  if (currency == 'INR') {
    return '₹${value.toStringAsFixed(2)}';
  }

  if (currency == 'USD') {
    return '\$${value.toStringAsFixed(2)}';
  }

  return value.toStringAsFixed(2);
}

  String _formatChange(double? value) {
    if (value == null) {
      return '--';
    }

    final sign = value >= 0 ? '+' : '';

    return '$sign${value.toStringAsFixed(2)}%';
  }

  Color _changeColor(double? value) {
    if (value == null) {
      return Colors.white70;
    }

    if (value >= 0) {
      return Colors.greenAccent;
    }

    return Colors.redAccent;
  }

  String _formatUpdatedTime() {
    if (_lastUpdated == null) {
      return 'Updating...';
    }

    final time = _lastUpdated!;

    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    final second =
        time.second.toString().padLeft(2, '0');

    return 'Updated $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A2B45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.show_chart,
                  color: Colors.greenAccent,
                ),

                const SizedBox(width: 10),

                const Text(
                  'Live Market',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _hasError
                        ? Colors.orange
                        : Colors.green,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _hasError
                            ? 'ERROR'
                            : 'LIVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              _formatUpdatedTime(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 20),

            if (_loading)
              const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(20),
                  child:
                      CircularProgressIndicator(),
                ),
              )
            else if (_hasError &&
                _prices.isEmpty)
              _buildError()
            else ...[
              marketTile(
                'NIFTY 50',
                _formatPrice(
                  'NIFTY 50',
                  _price('NIFTY 50'),
                ),
                _formatChange(
                  _change('NIFTY 50'),
                ),
                _changeColor(
                  _change('NIFTY 50'),
                ),
              ),

              marketTile(
                'SENSEX',
                _formatPrice(
                  'SENSEX',
                  _price('SENSEX'),
                ),
                _formatChange(
                  _change('SENSEX'),
                ),
                _changeColor(
                  _change('SENSEX'),
                ),
              ),

              marketTile(
                'Gold',
                _formatPrice(
                  'Gold',
                  _price('Gold'),
                ),
                _formatChange(
                  _change('Gold'),
                ),
                Colors.orange,
              ),

              marketTile(
                'Bitcoin',
                _formatPrice(
                  'Bitcoin',
                  _price('Bitcoin'),
                ),
                _formatChange(
                  _change('Bitcoin'),
                ),
                _changeColor(
                  _change('Bitcoin'),
                ),
              ),

              marketTile(
                'Ethereum',
                _formatPrice(
                  'Ethereum',
                  _price('Ethereum'),
                ),
                _formatChange(
                  _change('Ethereum'),
                ),
                _changeColor(
                  _change('Ethereum'),
                ),
              ),
            ],

            const SizedBox(height: 8),

            if (!_loading)
              Align(
                alignment:
                    Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _fetchMarketData,
                  icon: const Icon(
                    Icons.refresh,
                    size: 18,
                  ),
                  label: const Text(
                    'Refresh',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Colors.greenAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.redAccent.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.redAccent,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Market data unavailable',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: _fetchMarketData,
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget marketTile(
    String name,
    String price,
    String change,
    Color color,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color,
        child: const Icon(
          Icons.trending_up,
          color: Colors.white,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        price,
        style: const TextStyle(
          color: Colors.white70,
        ),
      ),
      trailing: Text(
        change,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}