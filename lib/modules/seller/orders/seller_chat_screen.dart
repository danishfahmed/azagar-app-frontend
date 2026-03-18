import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/modules/seller/orders/seller_orders_screen.dart';

class SellerChatScreen extends StatefulWidget {
  final SellerOrder order;
  const SellerChatScreen({super.key, required this.order});

  @override
  State<SellerChatScreen> createState() => _SellerChatScreenState();
}

class _SellerChatScreenState extends State<SellerChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Hello Joe', isSeller: true, time: '1:15 PM'),
    _ChatMessage(
      text: 'How can we help you today?',
      isSeller: true,
      time: '1:15 PM',
    ),
    _ChatMessage(
      text: "I'm having issues with my order",
      isSeller: false,
      time: '1:20 PM',
    ),
    _ChatMessage(
      text: 'Can you tell me more about your problem?',
      isSeller: true,
      time: '1:22 PM',
    ),
    _ChatMessage(text: 'okay sure!', isSeller: false, time: '1:25 PM'),
  ];

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isSeller: true,
          time: TimeOfDay.now().format(context),
        ),
      );
      _msgCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Message list ─────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final showTime =
                    i == _messages.length - 1 ||
                    _messages[i + 1].isSeller != msg.isSeller;
                return _BubbleTile(msg: msg, showTime: showTime);
              },
            ),
          ),

          // ── Input bar ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Plus button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mic / send button
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mic, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Model ─────────────────────────────

class _ChatMessage {
  final String text;
  final bool isSeller;
  final String time;
  const _ChatMessage({
    required this.text,
    required this.isSeller,
    required this.time,
  });
}

// ──────────────────────── Bubble ─────────────────────────────

class _BubbleTile extends StatelessWidget {
  final _ChatMessage msg;
  final bool showTime;
  const _BubbleTile({required this.msg, required this.showTime});

  @override
  Widget build(BuildContext context) {
    final isSeller = msg.isSeller;
    return Column(
      crossAxisAlignment: isSeller
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: isSeller
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (isSeller) ...[
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Text(
                  'S',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSeller ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isSeller ? 4 : 16),
                    bottomRight: Radius.circular(isSeller ? 16 : 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSeller
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            if (!isSeller) const SizedBox(width: 8),
          ],
        ),
        if (showTime)
          Padding(
            padding: EdgeInsets.fromLTRB(
              isSeller ? 36 : 0,
              4,
              isSeller ? 0 : 8,
              10,
            ),
            child: Text(
              msg.time,
              style: TextStyle(fontSize: 10, color: AppColors.grey),
            ),
          )
        else
          const SizedBox(height: 4),
      ],
    );
  }
}
