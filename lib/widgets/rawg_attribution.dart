import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RawgAttribution extends StatelessWidget {
  const RawgAttribution({super.key, this.openUrl, this.compact = false});

  final Future<bool> Function(Uri)? openUrl;
  final bool compact;

  static final Uri rawgUri = Uri.https('rawg.io');

  Future<void> _openRawg(BuildContext context) async {
    try {
      if (await (openUrl?.call(rawgUri) ??
          launchUrl(rawgUri, mode: LaunchMode.externalApplication))) {
        return;
      }
    } catch (_) {
      // Report failures without exposing platform-specific details.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Unable to open RAWG.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Center(
      widthFactor: compact ? 1 : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Game data by ', style: style),
          TextButton(
            onPressed: () => _openRawg(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              'RAWG',
              style: style?.copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
