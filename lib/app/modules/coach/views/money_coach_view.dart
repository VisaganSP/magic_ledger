import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/money_coach_service.dart';
import '../../../theme/neo_brutalism_theme.dart';

class MoneyCoachView extends StatefulWidget {
  const MoneyCoachView({super.key});

  @override
  State<MoneyCoachView> createState() => _MoneyCoachViewState();
}

class _MoneyCoachViewState extends State<MoneyCoachView> {
  final MoneyCoachService _coach = MoneyCoachService();
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, String>> _messages = [];

  final _quickQuestions = [
    '📊 How am I doing?',
    '💸 Where is my money going?',
    '🔮 End of month projection',
    '💡 Give me tips',
    '📅 Today\'s spending',
    '💎 Biggest expense',
    '💰 Savings rate',
    '📋 Budget status',
  ];

  @override
  void initState() {
    super.initState();
    // Show greeting
    _addBotMessage(_coach.ask(''));
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text.trim()});
    });
    _inputCtrl.clear();

    // Small delay for "thinking" feel
    Future.delayed(const Duration(milliseconds: 300), () {
      final response = _coach.ask(text);
      _addBotMessage(response);
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'role': 'bot', 'text': text});
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _t(Color c, bool d) => NeoBrutalismTheme.getThemedColor(c, d);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length + 1, // +1 for quick questions
              itemBuilder: (ctx, i) {
                if (i == _messages.length) {
                  // Quick questions at the bottom
                  return _buildQuickQuestions(isDark);
                }
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildBubble(msg['text']!, isUser, isDark)
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .slideY(begin: 0.05, end: 0),
                );
              },
            ),
          ),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20, right: 20, bottom: 12,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryBlack,
        border: const Border(bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack, width: NeoBrutalismTheme.borderWidth)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(Get.context!).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Icon(Icons.arrow_back, size: 20,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 40, height: 40,
            decoration: NeoBrutalismTheme.neoBox(
              color: _t(NeoBrutalismTheme.accentGreen, isDark),
              offset: 3, borderColor: isDark ? Colors.grey[700]! : NeoBrutalismTheme.primaryBlack,
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MONEY COACH',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryWhite)),
                Text('Ask me anything about your finances',
                    style: TextStyle(fontSize: 10,
                        color: isDark ? Colors.grey[500] : Colors.grey[400])),
              ],
            ),
          ),
          // Clear chat
          GestureDetector(
            onTap: () {
              setState(() => _messages.clear());
              _addBotMessage(_coach.ask(''));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                offset: 2, borderColor: isDark ? Colors.grey[700]! : NeoBrutalismTheme.primaryBlack,
              ),
              child: Icon(Icons.refresh, size: 18,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildBubble(String text, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.all(14),
        decoration: isUser
            ? NeoBrutalismTheme.neoBox(
          color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
          offset: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        )
            : NeoBrutalismTheme.neoBox(
          color: isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
          offset: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: _t(NeoBrutalismTheme.accentGreen, isDark),
                        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
                      ),
                      child: const Center(child: Text('🤖', style: TextStyle(fontSize: 10))),
                    ),
                    const SizedBox(width: 6),
                    Text('COACH', style: TextStyle(fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.grey[500] : Colors.grey[600])),
                  ],
                ),
              ),
            Text(text, style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: isUser
                  ? NeoBrutalismTheme.primaryBlack
                  : (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuestions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: _quickQuestions.map((q) => GestureDetector(
          onTap: () => _send(q),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: NeoBrutalismTheme.neoBox(
              color: isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.primaryWhite,
              offset: 2,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Text(q, style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        border: const Border(top: BorderSide(
            color: NeoBrutalismTheme.primaryBlack, width: 2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[50]!,
                offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: TextField(
                controller: _inputCtrl,
                onSubmitted: _send,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                decoration: InputDecoration(
                  hintText: 'Ask about your money...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  hintStyle: TextStyle(fontSize: 13,
                      color: isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _send(_inputCtrl.text),
            child: Container(
              width: 48, height: 48,
              decoration: NeoBrutalismTheme.neoBox(
                color: NeoBrutalismTheme.accentGreen,
                offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: const Icon(Icons.send, size: 20,
                  color: NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
}