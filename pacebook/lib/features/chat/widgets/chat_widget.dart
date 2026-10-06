class ChatInputBar extends StatefulWidget {
  final void Function(String text) onSend;
  final VoidCallback? onAttach;

  const ChatInputBar({super.key, required this.onSend, this.onAttach});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _ctrl.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.cyan,
              size: 22,
            ),
            onPressed: widget.onAttach ?? () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: TextField(
                controller: _ctrl,
                onChanged: (val) =>
                    setState(() => _hasText = val.trim().isNotEmpty),
                onSubmitted: (_) => _send(),
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: AppTypography.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: _send,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _hasText ? AppColors.cyan : AppColors.bgSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 20,
                color: _hasText ? AppColors.bgDeep : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageMediaPreview extends StatelessWidget {
  final String url;
  final bool isMine;
  const MessageMediaPreview({
    super.key,
    required this.url,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 200,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 200,
          height: 100,
          color: AppColors.bgSurface,
          child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
