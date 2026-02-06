import 'dart:async';
import 'package:flutter/material.dart';

class NewsTicker extends StatefulWidget {
  final List<String> messages;

  const NewsTicker({super.key, required this.messages});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(currentScroll + 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 36,
      color: const Color(0xFFFFFBEB), // Very light amber
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // Disable user scroll
        itemBuilder: (context, index) {
          // Use modulo to loop through messages infinitely
          final message = widget.messages[index % widget.messages.length];
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.new_releases,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF78350F),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
