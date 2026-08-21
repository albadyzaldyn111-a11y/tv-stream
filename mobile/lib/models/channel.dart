enum RightsStatus {
  verified,
  officialSource,
  permissionRequired,
  unknown,
  unavailable
}

enum HealthStatus { online, offline, unknown }

enum StreamType { hls, dash, web, none }

class Channel {
  const Channel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.country,
    required this.category,
    required this.logoUrl,
    required this.streamType,
    required this.language,
    required this.isActive,
    required this.isFeatured,
    required this.sourceUrl,
    required this.rightsStatus,
    required this.healthStatus,
    required this.hasPlayableStream,
    this.streamUrl,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String country;
  final String category;
  final String? logoUrl;
  final StreamType streamType;
  final String language;
  final bool isActive;
  final bool isFeatured;
  final String sourceUrl;
  final RightsStatus rightsStatus;
  final HealthStatus healthStatus;
  final bool hasPlayableStream;
  final String? streamUrl;

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      country: json['country'] as String,
      category: json['category'] as String,
      logoUrl: json['logo_url'] as String?,
      streamType: _streamTypeFrom(json['stream_type'] as String?),
      language: json['language'] as String? ?? 'العربية',
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      sourceUrl: json['source_url'] as String,
      rightsStatus: _rightsFrom(json['rights_status'] as String?),
      healthStatus: _healthFrom(json['health_status'] as String?),
      hasPlayableStream: json['has_playable_stream'] as bool? ?? false,
      streamUrl: json['stream_url'] as String?,
    );
  }

  static StreamType _streamTypeFrom(String? value) {
    switch (value) {
      case 'HLS':
        return StreamType.hls;
      case 'DASH':
        return StreamType.dash;
      case 'WEB':
        return StreamType.web;
      default:
        return StreamType.none;
    }
  }

  static RightsStatus _rightsFrom(String? value) {
    switch (value) {
      case 'verified':
        return RightsStatus.verified;
      case 'official_source':
        return RightsStatus.officialSource;
      case 'permission_required':
        return RightsStatus.permissionRequired;
      case 'unavailable':
        return RightsStatus.unavailable;
      default:
        return RightsStatus.unknown;
    }
  }

  static HealthStatus _healthFrom(String? value) {
    switch (value) {
      case 'online':
        return HealthStatus.online;
      case 'offline':
        return HealthStatus.offline;
      default:
        return HealthStatus.unknown;
    }
  }
}
