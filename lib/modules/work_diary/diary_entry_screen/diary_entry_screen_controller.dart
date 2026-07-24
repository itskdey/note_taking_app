part of 'diary_entry_screen_view.dart';

enum DiarySaveStatus { idle, saving, saved, error }

class DiaryEntryController extends GetxController {
  DiaryEntryController({DiaryEntryModel? initialEntry}) : entry = initialEntry;

  /// Pass an existing entry to edit, or null to create a new one.
  final DiaryEntryModel? entry;

  late final TextEditingController titleController;
  late final TextEditingController contentController;
  final FocusNode contentFocusNode = FocusNode();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rxn<String> location = Rxn<String>();
  final RxList<String> tags = <String>[].obs;
  final Rxn<String> moodEmoji = Rxn<String>();
  final RxList<String> attachmentPaths = <String>[].obs;

  final RxBool isBold = false.obs;
  final RxBool isItalic = false.obs;
  final RxBool isUnderline = false.obs;
  final Rx<DiarySaveStatus> saveStatus = DiarySaveStatus.idle.obs;
  final RxBool isLocked = false.obs;
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// New entries ("+") open directly in edit mode.
  /// Existing entries open as a read-only preview until the user
  /// explicitly asks to edit.
  final RxBool isEditing = true.obs;

  String? _id;
  DateTime? _lastSavedAt;
  Timer? _autosaveDebounce;
  bool _isDeleted = false;
  String? _newBlockFocusId;
  static const Duration _autosaveDelay = Duration(milliseconds: 900);

  final RxList<DiaryBlock> blocks = <DiaryBlock>[].obs;

  DiaryBlock? _blockById(String blockId) {
    for (final b in blocks) {
      if (b.id == blockId) return b;
    }
    return null;
  }

  void enterEditMode() {
    if (isEditing.value) return;
    isEditing.value = true;
    // Give the content field focus once the editable fields are mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      contentFocusNode.requestFocus();
    });
  }

  /// Drops back into the read-only preview instead of leaving the screen.
  /// Only applies to existing entries — new entries have no preview state
  /// to fall back to, so back always exits them directly.
  Future<void> exitEditMode() async {
    if (!isEditing.value || entry == null) return;
    contentFocusNode.unfocus();
    _autosaveDebounce?.cancel();
    await save();
    isEditing.value = false;
  }

  void addBlock(DiaryBlockType type) {
    final block = DiaryBlock(id: generateDiaryBlockId(), type: type);
    switch (type) {
      case DiaryBlockType.checklist:
      case DiaryBlockType.radio:
      case DiaryBlockType.bullet:
      case DiaryBlockType.numbered:
        block.options.add(DiaryBlockOption(id: generateDiaryBlockId()));
        break;
      case DiaryBlockType.quote:
      case DiaryBlockType.heading:
      case DiaryBlockType.callout:
        block.text = '';
        break;
      case DiaryBlockType.divider:
      case DiaryBlockType.image:
      case DiaryBlockType.voice:
        break;
    }
    _newBlockFocusId = block.id;
    blocks.add(block);
    _onEdited();
  }

  bool takeNewBlockFocus(String blockId) {
    if (_newBlockFocusId != blockId) return false;
    _newBlockFocusId = null;
    return true;
  }

  void removeBlock(String blockId) {
    final block = _blockById(blockId);
    blocks.removeWhere((b) => b.id == blockId);
    final audioPath = block?.audioPath;
    if (audioPath != null) {
      unawaited(_deleteLocalFile(audioPath));
    }
    _syncAttachmentPaths();
    _onEdited();
  }

  void updateVoiceBlock(String blockId, String path, Duration duration) {
    final block = _blockById(blockId);
    if (block == null || block.type != DiaryBlockType.voice) return;
    block.audioPath = path;
    block.audioDurationMs = duration.inMilliseconds;
    blocks.refresh();
    _onEdited();
  }

  void clearVoiceBlock(String blockId) {
    final block = _blockById(blockId);
    if (block == null || block.type != DiaryBlockType.voice) return;
    final audioPath = block.audioPath;
    block.audioPath = null;
    block.audioDurationMs = 0;
    blocks.refresh();
    _onEdited();
    if (audioPath != null) {
      unawaited(_deleteLocalFile(audioPath));
    }
  }

  Future<void> _deleteLocalFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> pickImages({bool fromCamera = false}) async {
    await _pickAndStoreImages(fromCamera: fromCamera);
  }

  Future<void> addImagesToBlock(String blockId) async {
    await _pickAndStoreImages(blockId: blockId);
  }

  Future<void> _pickAndStoreImages({
    bool fromCamera = false,
    String? blockId,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = fromCamera
          ? <XFile>[
              ?await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 90,
              ),
            ]
          : await picker.pickMultiImage(imageQuality: 90);
      if (picked.isEmpty) return;

      // Camera shots were just reviewed in the native camera UI.
      // Gallery picks weren't reviewed inside the app yet, so show a
      // preview first and let the user drop any before they're stored.
      final confirmed = fromCamera
          ? picked
          : await _showImagePreviewSheet(picked);
      if (confirmed == null || confirmed.isEmpty) return;

      final storedPaths = <String>[];
      for (final image in confirmed) {
        storedPaths.add(await _storeDiaryImage(image));
      }

      final existingBlock = blockId == null ? null : _blockById(blockId);
      if (existingBlock != null && existingBlock.type == DiaryBlockType.image) {
        existingBlock.imagePaths.addAll(storedPaths);
        blocks.refresh();
      } else {
        blocks.add(
          DiaryBlock(
            id: generateDiaryBlockId(),
            type: DiaryBlockType.image,
            imagePaths: storedPaths,
          ),
        );
      }
      _syncAttachmentPaths();
      _onEdited();
    } catch (_) {
      Get.snackbar(
        'Unable to add images',
        'Please check photo access and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Shows a bottom sheet grid of the picked photos so the user can
  /// deselect any before they're copied into the diary. Returns the
  /// confirmed subset, or null if cancelled.
  Future<List<XFile>?> _showImagePreviewSheet(List<XFile> picked) {
    return Get.bottomSheet<List<XFile>>(
      ImagePreviewSheet(images: picked),
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  /// Placeholder hook for editing an already-added image (crop/rotate/etc.)
  /// on demand, any time after it's been added — not forced at insertion.
  /// Wire this to a real editor (e.g. image_cropper) when ready.
  Future<void> editImage(String blockId, String imagePath) async {
    // TODO: open crop/rotate UI, then replace imagePath in the block's
    // imagePaths list and call _onEdited().
    Get.snackbar(
      'diary_edit_image_coming_soon'.tr,
      '',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<String> _storeDiaryImage(XFile image) async {
    final documents = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(p.join(documents.path, 'diary_images'));
    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    final extension = p.extension(image.path).toLowerCase();
    final safeExtension = extension.isEmpty ? '.jpg' : extension;
    final fileName = '${generateDiaryBlockId()}$safeExtension';
    return (await File(
      image.path,
    ).copy(p.join(imageDirectory.path, fileName))).path;
  }

  void removeImage(String blockId, String imagePath) {
    final block = _blockById(blockId);
    if (block == null || block.type != DiaryBlockType.image) return;
    block.imagePaths.remove(imagePath);
    if (block.imagePaths.isEmpty) {
      blocks.removeWhere((item) => item.id == blockId);
    } else {
      blocks.refresh();
    }
    _syncAttachmentPaths();
    _onEdited();
  }

  void _syncAttachmentPaths() {
    attachmentPaths.assignAll(
      blocks
          .where((block) => block.type == DiaryBlockType.image)
          .expand((block) => block.imagePaths),
    );
  }

  void addOption(String blockId) {
    final block = _blockById(blockId);
    if (block == null) return;
    block.options.add(DiaryBlockOption(id: generateDiaryBlockId()));
    blocks.refresh();
    _onEdited();
  }

  void removeOption(String blockId, String optionId) {
    final block = _blockById(blockId);
    if (block == null) return;
    block.options.removeWhere((o) => o.id == optionId);
    blocks.refresh();
    _onEdited();
  }

  void updateOptionText(String blockId, String optionId, String text) {
    final block = _blockById(blockId);
    if (block == null) return;
    final idx = block.options.indexWhere((o) => o.id == optionId);
    if (idx == -1) return;
    block.options[idx] = block.options[idx].copyWith(text: text);
    _onEdited();
  }

  void toggleOption(String blockId, String optionId) {
    final block = _blockById(blockId);
    if (block == null) return;
    if (block.type == DiaryBlockType.radio) {
      for (final o in block.options) {
        o.checked = o.id == optionId;
      }
    } else {
      final idx = block.options.indexWhere((o) => o.id == optionId);
      if (idx == -1) return;
      block.options[idx] = block.options[idx].copyWith(
        checked: !block.options[idx].checked,
      );
    }
    blocks.refresh();
    _onEdited();
  }

  void updateBlockText(String blockId, String text) {
    final block = _blockById(blockId);
    if (block == null) return;
    block.text = text;
    _onEdited();
  }

  @override
  void onInit() {
    super.onInit();
    _id = entry?.id;
    isEditing.value = entry == null;

    titleController = TextEditingController(
      text: KhmerDateUtils.toKhmerNumber(entry?.title ?? ''),
    );
    contentController = TextEditingController(
      text: KhmerDateUtils.toKhmerNumber(entry?.content ?? ''),
    );
    selectedDate.value = entry?.date ?? DateTime.now();
    location.value = entry?.location == null
        ? null
        : KhmerDateUtils.toKhmerNumber(entry!.location);
    tags.assignAll((entry?.tags ?? []).map(KhmerDateUtils.toKhmerNumber));
    moodEmoji.value = entry?.moodEmoji;
    isLocked.value = entry?.isLocked ?? false;

    blocks.assignAll(entry?.blocks ?? []);
    final blockImagePaths = blocks
        .where((block) => block.type == DiaryBlockType.image)
        .expand((block) => block.imagePaths)
        .toSet();
    final legacyImagePaths = (entry?.imagePaths ?? [])
        .where((path) => !blockImagePaths.contains(path))
        .toList();
    if (legacyImagePaths.isNotEmpty) {
      blocks.insert(
        0,
        DiaryBlock(
          id: generateDiaryBlockId(),
          type: DiaryBlockType.image,
          imagePaths: legacyImagePaths,
        ),
      );
    }
    _syncAttachmentPaths();

    titleController.addListener(_onEdited);
    contentController.addListener(_onEdited);
  }

  @override
  void onClose() {
    _autosaveDebounce?.cancel();
    titleController.dispose();
    contentController.dispose();
    contentFocusNode.dispose();
    super.onClose();
  }

  String get monthName => KhmerDateUtils.monthName(selectedDate.value.month);

  String get lastSavedLabel {
    final savedAt = _lastSavedAt;
    if (savedAt == null) return '';

    final diff = DateTime.now().difference(savedAt);
    if (diff.inSeconds < 10) return 'saved_just_now'.tr;
    if (diff.inMinutes < 1) {
      return 'saved_seconds_ago'.trParams({
        'seconds': KhmerDateUtils.toKhmerNumber(diff.inSeconds),
      });
    }
    if (diff.inHours < 1) {
      return 'saved_minutes_ago'.trParams({
        'minutes': KhmerDateUtils.toKhmerNumber(diff.inMinutes),
      });
    }
    return 'saved_at'.trParams({'time': KhmerDateUtils.formatTime(savedAt)});
  }

  void _onEdited() {
    saveStatus.value = DiarySaveStatus.idle;
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(_autosaveDelay, save);
  }

  Future<void> pickDate(BuildContext context) async {
    if (!isEditing.value) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(selectedDate.value.year - 5),
      lastDate: DateTime(selectedDate.value.year + 5),
    );
    if (picked == null) return;
    selectedDate.value = DateTime(
      picked.year,
      picked.month,
      picked.day,
      selectedDate.value.hour,
      selectedDate.value.minute,
    );
    _onEdited();
  }

  void toggleBold() => isBold.toggle();
  void toggleItalic() => isItalic.toggle();
  void toggleUnderline() => isUnderline.toggle();

  Future<void> save() async {
    if (_isDeleted) return;
    if (titleController.text.trim().isEmpty &&
        contentController.text.trim().isEmpty &&
        blocks.isEmpty) {
      return;
    }

    saveStatus.value = DiarySaveStatus.saving;

    final payload = DiaryEntryModel(
      id: _id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      content: contentController.text,
      date: selectedDate.value,
      moodEmoji: moodEmoji.value,
      location: location.value,
      tags: tags.toList(),
      isLocked: isLocked.value,
      imagePaths: attachmentPaths.toList(),
      blocks: blocks.toList(),
    );
    // Publish the id before awaiting SQLite so a delete tapped during an
    // in-flight autosave can still target the newly-created row.
    _id = payload.id;

    try {
      await DiaryDatabaseService.instance.upsertEntry(payload);
      if (_isDeleted) return;
      _lastSavedAt = DateTime.now();
      saveStatus.value = DiarySaveStatus.saved;
    } catch (_) {
      saveStatus.value = DiarySaveStatus.error;
    }
  }

  Future<DiaryEntryDeleted> deleteEntry() async {
    _autosaveDebounce?.cancel();
    _isDeleted = true;

    final id = _id ?? entry?.id;
    if (id != null) {
      try {
        await DiaryDatabaseService.instance.deleteEntry(id);
        for (final block in blocks) {
          final audioPath = block.audioPath;
          if (audioPath != null) {
            await _deleteLocalFile(audioPath);
          }
        }
      } catch (_) {
        _isDeleted = false;
        rethrow;
      }
    }

    return DiaryEntryDeleted(id);
  }

  DiaryEntryModel _currentSnapshot() {
    return DiaryEntryModel(
      id: _id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      content: contentController.text,
      date: selectedDate.value,
      moodEmoji: moodEmoji.value,
      location: location.value,
      tags: tags.toList(),
      isLocked: isLocked.value,
      imagePaths: attachmentPaths.toList(),
      blocks: blocks.toList(),
    );
  }

  Future<DiaryEntryModel?> onWillPop() async {
    _autosaveDebounce?.cancel();
    if (titleController.text.trim().isEmpty &&
        contentController.text.trim().isEmpty &&
        blocks.isEmpty) {
      return null;
    }
    await save();
    return _currentSnapshot();
  }

  Future<DiaryEntryModel?> toggleLock() async {
    final nextLockState = !isLocked.value;
    final authenticated = await _authenticateForLock(nextLockState);
    if (!authenticated) return null;

    isLocked.value = nextLockState;
    await save();
    if (saveStatus.value != DiarySaveStatus.saved) {
      isLocked.value = entry?.isLocked ?? false;
      return null;
    }
    return _currentSnapshot();
  }

  Future<bool> _authenticateForLock(bool locking) async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics && !isDeviceSupported) {
        _showAuthMessage(
          'diary_lock_unavailable_title'.tr,
          'diary_lock_unavailable_message'.tr,
        );
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason:
            (locking ? 'diary_lock_auth_reason' : 'diary_unlock_auth_reason')
                .tr,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (error) {
      _showAuthMessage(
        'diary_lock_auth_failed_title'.tr,
        error.message ?? 'diary_lock_auth_failed_message'.tr,
      );
      return false;
    } catch (e) {
      debugPrint('LocalAuth error: $e');
      return false;
    }
  }

  void _showAuthMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
