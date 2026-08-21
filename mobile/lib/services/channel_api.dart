import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/channel.dart';

class ChannelApiException implements Exception {
  const ChannelApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ChannelApi {
  ChannelApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue: 'http://localhost:8000',
                ))
            .replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final String baseUrl;

  Future<List<Channel>> fetchChannels({String? category, String? query}) async {
    final params = <String, String>{};
    if (category != null && category != 'all') params['category'] = category;
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();

    final uri =
        Uri.parse('$baseUrl/api/channels').replace(queryParameters: params);
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 12));
    _ensureSuccess(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['items'] as List<dynamic>)
        .map((item) => Channel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Channel> fetchChannel(int id) async {
    final uri = Uri.parse('$baseUrl/api/channels/$id');
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 12));
    _ensureSuccess(response);
    return Channel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('$baseUrl/api/categories');
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 12));
    _ensureSuccess(response);
    return (jsonDecode(response.body) as List<dynamic>).cast<String>();
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChannelApiException('تعذر تحميل القنوات (${response.statusCode}).');
    }
  }
}
