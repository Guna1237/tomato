import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/messages_provider.dart';
import '../../data/models/delivery_message.dart';
import '../../shared/widgets/back_button_widget.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  late String _deliveryId;
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deliveryId =
        GoRouterState.of(context).uri.queryParameters['delivery_id'] ?? '';
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _textCtrl.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) return;
      await supabase.from('delivery_messages').insert({
        'delivery_id': _deliveryId,
        'sender_id': uid,
        'body': body,
      });
      _textCtrl.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final messagesAsync = ref.watch(messagesProvider(_deliveryId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // Top bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  const BackButtonWidget(),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery chat',
                          style: AppTextStyles.h3(color: fg1)),
                      Text('Delivery chat',
                          style: AppTextStyles.meta(
                              color: AppColors.lavenderGrey)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Message list
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet.\nSay hello to coordinate.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollCtrl.hasClients) {
                    _scrollCtrl.jumpTo(
                        _scrollCtrl.position.maxScrollExtent);
                  }
                });
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _MessageBubble(
                    message: messages[i],
                    isMe: messages[i].senderId == currentUserId,
                    showTime: i == 0 ||
                        messages[i]
                                .createdAt
                                .difference(messages[i - 1].createdAt)
                                .inMinutes >
                            5,
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.punchRed),
              ),
              error: (e, _) => Center(
                child: Text('Error loading messages',
                    style:
                        AppTextStyles.meta(color: AppColors.lavenderGrey)),
              ),
            ),
          ),

          // Input bar
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.lavenderGrey.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppTextStyles.body(color: fg1),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTextStyles.body(
                            color: AppColors.lavenderGrey
                                .withValues(alpha: 0.7)),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSunken
                            : const Color(0xFFF4F5F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sending ? null : _send,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _sending
                            ? AppColors.punchRed.withValues(alpha: 0.5)
                            : AppColors.punchRed,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _sending
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
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

class _MessageBubble extends StatelessWidget {
  final DeliveryMessage message;
  final bool isMe;
  final bool showTime;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? AppColors.punchRed
        : isDark
            ? AppColors.darkSurface
            : const Color(0xFFF0F1F5);
    final textColor = isMe ? Colors.white : (isDark ? AppColors.platinum : AppColors.spaceIndigo);
    final timeColor = AppColors.lavenderGrey.withValues(alpha: 0.7);

    final timeStr = _formatTime(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showTime) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: timeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                ),
                child: Text(
                  message.body,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final local = dt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    if (now.difference(local).inDays == 0) return '$h:$minute $ampm';
    if (now.difference(local).inDays == 1) return 'Yesterday $h:$minute $ampm';
    return '${local.day}/${local.month} $h:$minute $ampm';
  }
}
