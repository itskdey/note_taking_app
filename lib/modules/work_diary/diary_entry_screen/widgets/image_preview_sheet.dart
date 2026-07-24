part of '../diary_entry_screen_view.dart';

/// Shown before gallery-picked photos are stored in the entry, so the
/// user can drop any they don't want. Camera shots skip this since
/// they're already reviewed in the native camera UI.
class ImagePreviewSheet extends StatefulWidget {
  const ImagePreviewSheet({super.key, required this.images});

  final List<XFile> images;

  @override
  State<ImagePreviewSheet> createState() => _ImagePreviewSheetState();
}

class _ImagePreviewSheetState extends State<ImagePreviewSheet> {
  late final Set<XFile> _selected = widget.images.toSet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.noteChipBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              '${_selected.length} / ${widget.images.length} selected',
              style: AppFonts.appStyle(
                fontWeight: FontWeight.w600,
                color: context.noteTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final image = widget.images[index];
                final isSelected = _selected.contains(image);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSelected ? _selected.remove(image) : _selected.add(image);
                  }),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(image.path), fit: BoxFit.cover),
                      ),
                      if (!isSelected)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Bounceable(
              onTap: _selected.isEmpty
                  ? null
                  : () => Get.back(result: _selected.toList()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _selected.isEmpty
                      ? context.noteChipBorderColor
                      : AppColors.appRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _selected.isEmpty
                        ? 'select_photos'.tr
                        : 'add_photos_count'.trParams({
                            'count': _selected.length.toString(),
                          }),
                    style: AppFonts.appStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Get.back(result: null),
                child: Text(
                  'cancel'.tr,
                  style: AppFonts.appStyle(
                    color: context.noteTextSecondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
