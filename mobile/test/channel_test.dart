import 'package:flutter_test/flutter_test.dart';
import 'package:tv_stream/models/channel.dart';

void main() {
  test('parses a verified HLS channel', () {
    final channel = Channel.fromJson({
      'id': 1,
      'name': 'اختبار HLS',
      'slug': 'hls-test',
      'description': 'مصدر اختبار',
      'country': 'Test',
      'category': 'Educational',
      'logo_url': null,
      'stream_type': 'HLS',
      'language': 'العربية',
      'is_active': true,
      'is_featured': false,
      'source_url': 'https://test-streams.mux.dev/',
      'rights_status': 'verified',
      'health_status': 'online',
      'has_playable_stream': true,
      'stream_url': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    });

    expect(channel.streamType, StreamType.hls);
    expect(channel.rightsStatus, RightsStatus.verified);
    expect(channel.hasPlayableStream, isTrue);
    expect(channel.streamUrl, endsWith('.m3u8'));
  });

  test('does not mark an official page as playable', () {
    final channel = Channel.fromJson({
      'id': 2,
      'name': 'مصدر رسمي',
      'slug': 'official',
      'description': null,
      'country': 'المغرب',
      'category': 'General',
      'logo_url': null,
      'stream_type': 'WEB',
      'language': 'العربية',
      'is_active': true,
      'is_featured': false,
      'source_url': 'https://snrtlive.ma/ar/al-aoula',
      'rights_status': 'official_source',
      'health_status': 'unknown',
      'has_playable_stream': false,
      'stream_url': null,
    });

    expect(channel.hasPlayableStream, isFalse);
    expect(channel.streamUrl, isNull);
  });
}
