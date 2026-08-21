import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../models/channel.dart';
import '../widgets/hls_player.dart';

class ChannelDetailsPage extends StatelessWidget {
  const ChannelDetailsPage({required this.channel, super.key});

  final Channel channel;

  Future<void> _openOfficialSource(BuildContext context) async {
    final uri = Uri.tryParse(channel.sourceUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر فتح المصدر الرسمي.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playable = channel.hasPlayableStream && channel.streamUrl != null;
    return Scaffold(
      appBar: AppBar(title: Text(channel.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (playable)
            HlsPlayer(url: channel.streamUrl!)
          else
            _OfficialSourceBanner(onOpen: () => _openOfficialSource(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Logo(channel: channel),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(channel.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(
                          '${channel.country} · ${_categoryLabel(channel.category)}',
                          style: const TextStyle(color: Colors.white60)),
                      const SizedBox(height: 10),
                      _RightsBadge(channel: channel),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (channel.description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(channel.description!,
                  style: const TextStyle(height: 1.5, color: Colors.white70)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: OutlinedButton.icon(
              onPressed: () => _openOfficialSource(context),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('فتح المصدر الرسمي'),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String value) {
    const labels = {
      'Kids': 'أطفال',
      'News': 'أخبار',
      'General': 'عامة',
      'Sports': 'رياضة',
      'Entertainment': 'ترفيه',
      'Religious': 'دينية',
      'Educational': 'تعليمية',
      'Culture': 'ثقافية',
      'International': 'دولية',
    };
    return labels[value] ?? value;
  }
}

class _OfficialSourceBanner extends StatelessWidget {
  const _OfficialSourceBanner({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user_outlined,
              color: AppTheme.accent, size: 42),
          const SizedBox(height: 12),
          const Text('المشاهدة من المصدر الرسمي',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
              'لم يتم تمرير رابط بث داخلي غير مصرح به. افتح صفحة القناة الرسمية للمشاهدة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, height: 1.4)),
          const SizedBox(height: 16),
          FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.launch),
              label: const Text('مشاهدة رسميًا')),
        ],
      ),
    );
  }
}

class _RightsBadge extends StatelessWidget {
  const _RightsBadge({required this.channel});
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final isVerified = channel.rightsStatus == RightsStatus.verified;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isVerified ? Colors.green : AppTheme.primary)
            .withValues(alpha: .18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(isVerified ? 'مصدر قابل للتشغيل' : 'مصدر رسمي',
          style: TextStyle(
              color: isVerified ? Colors.greenAccent : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.channel});
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(18)),
      child: channel.logoUrl == null
          ? const Icon(Icons.live_tv_rounded, color: AppTheme.accent, size: 36)
          : Image.network(channel.logoUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.live_tv_rounded,
                  color: AppTheme.accent, size: 36)),
    );
  }
}
