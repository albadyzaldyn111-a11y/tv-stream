import 'package:flutter/material.dart';

import '../models/channel.dart';
import '../core/app_theme.dart';

class ChannelCard extends StatelessWidget {
  const ChannelCard({
    required this.channel,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    super.key,
  });

  final Channel channel;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppTheme.surfaceElevated,
                    padding: const EdgeInsets.all(24),
                    child: channel.logoUrl == null
                        ? const Icon(Icons.live_tv_rounded,
                            size: 52, color: AppTheme.accent)
                        : Image.network(
                            channel.logoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.live_tv_rounded,
                              size: 52,
                              color: AppTheme.accent,
                            ),
                          ),
                  ),
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: IconButton.filledTonal(
                      onPressed: onFavorite,
                      icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                      tooltip: 'إضافة إلى المفضلة',
                    ),
                  ),
                  if (channel.isFeatured)
                    PositionedDirectional(
                      bottom: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('مميز',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        channel.hasPlayableStream
                            ? Icons.circle
                            : Icons.open_in_new,
                        color: channel.hasPlayableStream
                            ? Colors.greenAccent
                            : Colors.white54,
                        size: 10,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          channel.hasPlayableStream
                              ? 'متاح للمشاهدة'
                              : 'المصدر الرسمي',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ),
                      Text(channel.country,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
