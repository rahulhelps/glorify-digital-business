import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A notice bar with a fixed left badge and a continuously scrolling marquee
/// text on the right. Uses a [ScrollController] + [Timer.periodic] loop for
/// smooth, dependency-free animation. Fully disposes resources on removal.
class HomeNoticeBar extends StatefulWidget {
  /// The optional override text that scrolls inside the marquee area.
  /// If null, it dynamically streams from Firestore (`app_config/home_notice`).
  final String? text;

  /// How fast the text scrolls — pixels per second.
  final double scrollSpeed;

  const HomeNoticeBar({
    super.key,
    this.text,
    this.scrollSpeed = 60.0, // pixels per second
  });

  @override
  State<HomeNoticeBar> createState() => _HomeNoticeBarState();
}

class _HomeNoticeBarState extends State<HomeNoticeBar> {
  late final ScrollController _scrollController;
  Timer? _timer;

  // Tick every 16 ms ≈ 60 fps
  static const _tickMs = 16;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Start scrolling after the first frame so maxScrollExtent is available
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    _timer = Timer.periodic(
      const Duration(milliseconds: _tickMs),
      (_) {
        if (!_scrollController.hasClients) return;

        final max = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;

        if (max <= 0) return; // text shorter than viewport — nothing to scroll

        final nextOffset = current + (widget.scrollSpeed * _tickMs / 1000);

        if (nextOffset >= max) {
          // Seamless reset to start
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(nextOffset);
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Fixed Left Badge ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                bottomLeft: Radius.circular(9),
              ),
            ),
            child: const Text(
              'নোটিশ:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3B66),
                fontSize: 13,
              ),
            ),
          ),

          // ── Thin divider ─────────────────────────────────────────────────
          Container(width: 1, color: Colors.blue.shade100),

          // ── Scrolling Marquee Text ────────────────────────────────────────
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('app_config')
                  .doc('home_notice')
                  .snapshots(),
              builder: (context, snapshot) {
                const defaultFallbackText =
                    'Welcome to Glorify Digital Business. Stay connected for updates!';
                String marqueeText = widget.text ?? defaultFallbackText;

                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.exists) {
                  final data = snapshot.data!.data();
                  if (data != null &&
                      data['text'] != null &&
                      (data['text'] as String).trim().isNotEmpty) {
                    marqueeText = (data['text'] as String).trim();
                  }
                }

                return ClipRect(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        // Duplicate the text so the reset looks seamless
                        _MarqueeText(text: marqueeText),
                        const SizedBox(width: 40), // gap between repetitions
                        _MarqueeText(text: marqueeText),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Internal stateless text widget ──────────────────────────────────────────

class _MarqueeText extends StatelessWidget {
  final String text;
  const _MarqueeText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
