part of '../diary_entry_screen_view.dart';

class DiaryBlockListView extends StatelessWidget {
  const DiaryBlockListView({super.key, required this.controller});
  final DiaryEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.blocks
            .map(
              (block) => _DiaryBlockWrapper(
                key: ValueKey(block.id),
                block: block,
                controller: controller,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DiaryBlockWrapper extends StatelessWidget {
  const _DiaryBlockWrapper({
    super.key,
    required this.block,
    required this.controller,
  });
  final DiaryBlock block;
  final DiaryEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss-${block.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.removeBlock(block.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 10),
        margin: const EdgeInsets.only(bottom: 14),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 20,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (block.type) {
      case DiaryBlockType.checklist:
        return _DiaryOptionListBlock(
          block: block,
          controller: controller,
          selectable: false,
        );
      case DiaryBlockType.radio:
        return _DiaryOptionListBlock(
          block: block,
          controller: controller,
          selectable: true,
        );
      case DiaryBlockType.bullet:
        return _DiaryPlainListBlock(
          block: block,
          controller: controller,
          numbered: false,
        );
      case DiaryBlockType.numbered:
        return _DiaryPlainListBlock(
          block: block,
          controller: controller,
          numbered: true,
        );
      case DiaryBlockType.quote:
        return _DiaryQuoteBlock(block: block, controller: controller);
      case DiaryBlockType.divider:
        return const _DiaryDividerBlock();
      case DiaryBlockType.image:
        return _DiaryImageBlock(block: block, controller: controller);
      case DiaryBlockType.heading:
        return _DiaryTextBlock(
          block: block,
          controller: controller,
          type: _DiaryTextBlockType.heading,
        );
      case DiaryBlockType.callout:
        return _DiaryTextBlock(
          block: block,
          controller: controller,
          type: _DiaryTextBlockType.callout,
        );
      case DiaryBlockType.voice:
        return _DiaryVoiceBlock(block: block, controller: controller);
    }
  }
}

// ---------- images ----------

class _DiaryImageBlock extends StatelessWidget {
  const _DiaryImageBlock({required this.block, required this.controller});

  final DiaryBlock block;
  final DiaryEntryController controller;

  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final images = block.imagePaths;
    if (images.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final visibleCount = images.length.clamp(1, 9);
        final height = _heightForCount(width, visibleCount);
        final rects = _rectsForCount(width, height, visibleCount);

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                for (int index = 0; index < visibleCount; index++)
                  Positioned.fromRect(
                    rect: rects[index],
                    child: _DiaryImageTile(
                      paths: images,
                      index: index,
                      extraCount: index == visibleCount - 1
                          ? images.length - visibleCount
                          : 0,
                      onRemove: () =>
                          controller.removeImage(block.id, images[index]),
                    ),
                  ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: _ImageActionButton(
                    icon: Icons.add_photo_alternate_outlined,
                    onTap: () => controller.addImagesToBlock(block.id),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _heightForCount(double width, int count) {
    return switch (count) {
      1 => width * 0.64,
      2 => width * 0.58,
      3 => width * 0.72,
      4 => width,
      5 => width * 0.76,
      6 => width * 0.67,
      _ => width * 0.78,
    };
  }

  List<Rect> _rectsForCount(double width, double height, int count) {
    Rect cell(double x, double y, double w, double h) => Rect.fromLTWH(
      x + (x > 0 ? _gap : 0),
      y + (y > 0 ? _gap : 0),
      w - (x > 0 ? _gap : 0),
      h - (y > 0 ? _gap : 0),
    );

    if (count == 1) return [cell(0, 0, width, height)];
    if (count == 2) {
      final column = width / 2;
      return [cell(0, 0, column, height), cell(column, 0, column, height)];
    }
    if (count == 3) {
      final mainWidth = width * 0.62;
      final sideWidth = width - mainWidth;
      final row = height / 2;
      return [
        cell(0, 0, mainWidth, height),
        cell(mainWidth, 0, sideWidth, row),
        cell(mainWidth, row, sideWidth, row),
      ];
    }
    if (count == 4) {
      final column = width / 2;
      final row = height / 2;
      return [
        cell(0, 0, column, row),
        cell(column, 0, column, row),
        cell(0, row, column, row),
        cell(column, row, column, row),
      ];
    }
    if (count == 5) {
      final column = width / 4;
      final row = height / 2;
      return [
        cell(0, 0, column * 2, height),
        cell(column * 2, 0, column, row),
        cell(column * 3, 0, column, row),
        cell(column * 2, row, column, row),
        cell(column * 3, row, column, row),
      ];
    }
    if (count == 6) {
      final column = width / 3;
      final row = height / 2;
      return List.generate(
        count,
        (index) => cell((index % 3) * column, (index ~/ 3) * row, column, row),
      );
    }

    final column = width / 4;
    final row = height / 3;
    if (count == 7) {
      return [
        cell(0, 0, column * 2, row * 2),
        cell(column * 2, 0, column, row),
        cell(column * 3, 0, column, row),
        cell(column * 2, row, column, row),
        cell(column * 3, row, column, row),
        cell(0, row * 2, column * 2, row),
        cell(column * 2, row * 2, column * 2, row),
      ];
    }
    if (count == 8) {
      return [
        cell(0, 0, column * 2, row * 2),
        cell(column * 2, 0, column, row),
        cell(column * 3, 0, column, row),
        cell(column * 2, row, column, row),
        cell(column * 3, row, column, row * 2),
        cell(0, row * 2, column, row),
        cell(column, row * 2, column, row),
        cell(column * 2, row * 2, column, row),
      ];
    }

    return [
      cell(0, 0, column * 2, row * 2),
      cell(column * 2, 0, column, row),
      cell(column * 3, 0, column, row),
      cell(column * 2, row, column, row),
      cell(column * 3, row, column, row),
      cell(0, row * 2, column, row),
      cell(column, row * 2, column, row),
      cell(column * 2, row * 2, column, row),
      cell(column * 3, row * 2, column, row),
    ];
  }
}

class _DiaryImageTile extends StatelessWidget {
  const _DiaryImageTile({
    required this.paths,
    required this.index,
    required this.extraCount,
    required this.onRemove,
  });

  final List<String> paths;
  final int index;
  final int extraCount;
  final VoidCallback onRemove;

  String get path => paths[index];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePreview(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: context.noteChipBackgroundColor,
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: context.noteTextSecondaryColor,
                ),
              ),
            ),
          ),
          if (extraCount > 0)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Text(
                  '+$extraCount',
                  style: AppFonts.appStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 7,
            top: 7,
            child: _ImageActionButton(
              icon: Icons.close_rounded,
              onTap: onRemove,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImagePreview(BuildContext context) async {
    final pageController = PageController(initialPage: index);
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: pageController,
                itemCount: paths.length,
                itemBuilder: (context, pageIndex) => InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Center(child: Image.file(File(paths[pageIndex]))),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _ImageActionButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    pageController.dispose();
  }
}

class _ImageActionButton extends StatelessWidget {
  const _ImageActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.58),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}

// ---------- checklist / radio ----------

class _DiaryOptionListBlock extends StatelessWidget {
  const _DiaryOptionListBlock({
    required this.block,
    required this.controller,
    required this.selectable,
  });
  final DiaryBlock block;
  final DiaryEntryController controller;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final option in block.options)
          _DiaryOptionRow(
            key: ValueKey(option.id),
            option: option,
            isRadio: selectable,
            onToggle: () => controller.toggleOption(block.id, option.id),
            onTextChanged: (v) =>
                controller.updateOptionText(block.id, option.id, v),
            onDelete: block.options.length > 1
                ? () => controller.removeOption(block.id, option.id)
                : null,
          ),
        _AddOptionRow(onTap: () => controller.addOption(block.id)),
      ],
    );
  }
}

class _DiaryOptionRow extends StatefulWidget {
  const _DiaryOptionRow({
    super.key,
    required this.option,
    required this.isRadio,
    required this.onToggle,
    required this.onTextChanged,
    this.onDelete,
  });

  final DiaryBlockOption option;
  final bool isRadio;
  final VoidCallback onToggle;
  final ValueChanged<String> onTextChanged;
  final VoidCallback? onDelete;

  @override
  State<_DiaryOptionRow> createState() => _DiaryOptionRowState();
}

class _DiaryOptionRowState extends State<_DiaryOptionRow> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.option.text);
    _text.addListener(() => widget.onTextChanged(_text.text));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checked = widget.option.checked;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onToggle,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: widget.isRadio
                  ? _RadioDot(selected: checked)
                  : _CheckSquare(checked: checked),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _text,
              maxLines: null,
              inputFormatters: [KhmerDateUtils.khmerDigitFormatter],
              style: AppFonts.appStyle(
                fontSize: 15,
                height: 1.5,
                color: checked && !widget.isRadio
                    ? context.noteTextSecondaryColor
                    : context.noteTextPrimaryColor,
                decoration: checked && !widget.isRadio
                    ? TextDecoration.lineThrough
                    : null,
                // decorationColor: context.noteChipBorderColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'block_item_hint'.tr,
                hintStyle: AppFonts.appStyle(
                  color: context.noteTextSecondaryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          if (widget.onDelete != null)
            GestureDetector(
              onTap: widget.onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 6, top: 3),
                child: Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: context.noteTextSecondaryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CheckSquare extends StatelessWidget {
  const _CheckSquare({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: checked ? AppColors.appRed : Colors.transparent,
        border: Border.all(
          color: checked ? AppColors.appRed : context.noteChipBorderColor,
          width: 1.6,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.appRed : context.noteChipBorderColor,
          width: 1.6,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.appRed,
                ),
              ),
            )
          : null,
    );
  }
}

class _AddOptionRow extends StatelessWidget {
  const _AddOptionRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 19,
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: context.noteTextSecondaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'add_item'.tr,
              style: AppFonts.appStyle(
                fontSize: 14,
                color: context.noteTextSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- bullet / numbered ----------

class _DiaryPlainListBlock extends StatelessWidget {
  const _DiaryPlainListBlock({
    required this.block,
    required this.controller,
    required this.numbered,
  });
  final DiaryBlock block;
  final DiaryEntryController controller;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < block.options.length; i++)
          _DiaryPlainListRow(
            key: ValueKey(block.options[i].id),
            option: block.options[i],
            marker: numbered ? '${i + 1}.' : '•',
            onTextChanged: (v) =>
                controller.updateOptionText(block.id, block.options[i].id, v),
            onDelete: block.options.length > 1
                ? () => controller.removeOption(block.id, block.options[i].id)
                : null,
          ),
        _AddOptionRow(onTap: () => controller.addOption(block.id)),
      ],
    );
  }
}

class _DiaryPlainListRow extends StatefulWidget {
  const _DiaryPlainListRow({
    super.key,
    required this.option,
    required this.marker,
    required this.onTextChanged,
    this.onDelete,
  });
  final DiaryBlockOption option;
  final String marker;
  final ValueChanged<String> onTextChanged;
  final VoidCallback? onDelete;

  @override
  State<_DiaryPlainListRow> createState() => _DiaryPlainListRowState();
}

class _DiaryPlainListRowState extends State<_DiaryPlainListRow> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.option.text);
    _text.addListener(() => widget.onTextChanged(_text.text));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.appRed.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 19,
            child: Text(
              widget.marker,
              textAlign: TextAlign.center,
              style: AppFonts.appStyle(
                fontSize: 13,
                color: context.noteTextSecondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _text,
              maxLines: null,
              inputFormatters: [KhmerDateUtils.khmerDigitFormatter],
              style: AppFonts.appStyle(
                fontSize: 15,
                height: 1.5,
                color: context.noteTextPrimaryColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'block_item_hint'.tr,
                hintStyle: AppFonts.appStyle(
                  color: context.noteTextSecondaryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          if (widget.onDelete != null)
            GestureDetector(
              onTap: widget.onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 6, top: 3),
                child: Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: context.noteTextSecondaryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------- heading / callout ----------

enum _DiaryTextBlockType { heading, callout }

class _DiaryTextBlock extends StatefulWidget {
  const _DiaryTextBlock({
    required this.block,
    required this.controller,
    required this.type,
  });

  final DiaryBlock block;
  final DiaryEntryController controller;
  final _DiaryTextBlockType type;

  @override
  State<_DiaryTextBlock> createState() => _DiaryTextBlockState();
}

class _DiaryTextBlockState extends State<_DiaryTextBlock> {
  late final TextEditingController _text;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.block.text ?? '');
    _focusNode = FocusNode();
    _text.addListener(
      () => widget.controller.updateBlockText(widget.block.id, _text.text),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.controller.takeNewBlockFocus(widget.block.id)) {
        return;
      }
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.type) {
      _DiaryTextBlockType.heading => TextField(
        controller: _text,
        focusNode: _focusNode,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: [KhmerDateUtils.khmerDigitFormatter],
        style: AppFonts.appStyle(
          fontSize: 21,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: context.noteTextPrimaryColor,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          hintText: 'block_heading_hint'.tr,
          hintStyle: AppFonts.appStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: context.noteTextSecondaryColor.withValues(alpha: 0.4),
          ),
        ),
      ),
      _DiaryTextBlockType.callout => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.appRed.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                size: 20,
                color: AppColors.appRed.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: TextField(
                controller: _text,
                focusNode: _focusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [KhmerDateUtils.khmerDigitFormatter],
                style: AppFonts.appStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: context.noteTextPrimaryColor,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: 'block_callout_hint'.tr,
                  hintStyle: AppFonts.appStyle(
                    color: context.noteTextSecondaryColor.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    };
  }
}

// ---------- quote ----------

class _DiaryQuoteBlock extends StatefulWidget {
  const _DiaryQuoteBlock({required this.block, required this.controller});
  final DiaryBlock block;
  final DiaryEntryController controller;

  @override
  State<_DiaryQuoteBlock> createState() => _DiaryQuoteBlockState();
}

class _DiaryQuoteBlockState extends State<_DiaryQuoteBlock> {
  late final TextEditingController _text;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.block.text ?? '');
    _focusNode = FocusNode();
    _text.addListener(
      () => widget.controller.updateBlockText(widget.block.id, _text.text),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.controller.takeNewBlockFocus(widget.block.id)) {
        return;
      }
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.accent.withValues(alpha: 0.14)
            : const Color.fromARGB(74, 221, 232, 240),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 10),
            child: Icon(
              Icons.format_quote_rounded,
              size: 24,
              color: AppColors.appRed.withValues(alpha: 0.72),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _text,
              focusNode: _focusNode,
              maxLines: null,
              inputFormatters: [KhmerDateUtils.khmerDigitFormatter],
              style: AppFonts.appStyle(
                fontSize: 16,
                height: 1.55,
                fontStyle: FontStyle.italic,
                color: context.noteTextPrimaryColor.withValues(alpha: 0.82),
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                contentPadding: const EdgeInsets.only(top: 1),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: 'block_quote_hint'.tr,
                hintStyle: AppFonts.appStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: context.noteTextSecondaryColor.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- voice ----------

class _DiaryVoiceBlock extends StatefulWidget {
  const _DiaryVoiceBlock({required this.block, required this.controller});

  final DiaryBlock block;
  final DiaryEntryController controller;

  @override
  State<_DiaryVoiceBlock> createState() => _DiaryVoiceBlockState();
}

class _DiaryVoiceBlockState extends State<_DiaryVoiceBlock> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final Stopwatch _recordingWatch = Stopwatch();

  Timer? _recordingTimer;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordingDuration = Duration.zero;
  Duration _position = Duration.zero;

  String? get _audioPath => widget.block.audioPath;

  Duration get _audioDuration =>
      Duration(milliseconds: widget.block.audioDurationMs);

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
      return;
    }

    try {
      if (!await _recorder.hasPermission()) {
        Get.snackbar(
          'block_voice_permission_title'.tr,
          'block_voice_permission_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _player.stop();
      final documents = await getApplicationDocumentsDirectory();
      final voiceDirectory = Directory(
        p.join(documents.path, 'diary_voice_notes'),
      );
      if (!await voiceDirectory.exists()) {
        await voiceDirectory.create(recursive: true);
      }
      final path = p.join(
        voiceDirectory.path,
        'voice_${widget.block.id}_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      _recordingWatch
        ..reset()
        ..start();
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (!mounted) return;
        setState(() => _recordingDuration = _recordingWatch.elapsed);
      });
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
    } catch (_) {
      _showRecordingError();
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      _recordingWatch.stop();
      _recordingTimer?.cancel();
      final duration = _recordingWatch.elapsed;
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      if (path == null) {
        _showRecordingError();
        return;
      }
      widget.controller.updateVoiceBlock(widget.block.id, path, duration);
    } catch (_) {
      _recordingWatch.stop();
      _recordingTimer?.cancel();
      if (mounted) {
        setState(() => _isRecording = false);
        _showRecordingError();
      }
    }
  }

  void _showRecordingError() {
    Get.snackbar(
      'block_voice_error_title'.tr,
      'block_voice_error_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _togglePlayback() async {
    final path = _audioPath;
    if (path == null) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(path), position: _position);
    }
  }

  Future<void> _deleteRecording() async {
    await _player.stop();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
    widget.controller.clearVoiceBlock(widget.block.id);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recordingWatch.stop();
    unawaited(_recorder.dispose());
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRecording = _audioPath != null;
    final shownDuration = _isRecording ? _recordingDuration : _audioDuration;
    final progress = _audioDuration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _audioDuration.inMilliseconds).clamp(
            0.0,
            1.0,
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: AppColors.appRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _VoiceActionButton(
            icon: _isRecording
                ? Icons.stop_rounded
                : hasRecording
                ? (_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded)
                : Icons.mic_rounded,
            active: _isRecording,
            onTap: _isRecording || !hasRecording
                ? _toggleRecording
                : _togglePlayback,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: hasRecording || _isRecording
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRecording
                            ? 'block_voice_recording'.tr
                            : 'block_voice'.tr,
                        style: AppFonts.appStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.noteTextPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _isRecording ? null : progress,
                          minHeight: 3,
                          backgroundColor: AppColors.appRed.withValues(
                            alpha: 0.16,
                          ),
                          color: AppColors.appRed.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'block_voice_record'.tr,
                    style: AppFonts.appStyle(
                      fontSize: 14,
                      color: context.noteTextSecondaryColor,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDuration(shownDuration),
            style: AppFonts.appStyle(
              fontSize: 12,
              color: context.noteTextSecondaryColor,
            ),
          ),
          if (hasRecording && !_isRecording) ...[
            const SizedBox(width: 4),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'delete'.tr,
              onPressed: _deleteRecording,
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: context.noteTextSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoiceActionButton extends StatelessWidget {
  const _VoiceActionButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.danger : AppColors.appRed,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
}

// ---------- divider ----------

class _DiaryDividerBlock extends StatelessWidget {
  const _DiaryDividerBlock();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: context.noteChipBorderColor),
        ),
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.noteChipBorderColor,
          ),
        ),
        Expanded(
          child: Container(height: 1, color: context.noteChipBorderColor),
        ),
      ],
    );
  }
}
