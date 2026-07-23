import 'package:note_taking_app/modules/work_diary/diary_shared/diary_block_model.dart';

class DiaryEntryModel {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String? moodEmoji;
  final String? location;
  final List<String> tags;
  final bool isBookmarked;
  final bool isLocked;
  final List<String> imagePaths;
  final List<DiaryBlock> blocks;

  DiaryEntryModel({
    required this.id,
    this.title = '',
    this.content = '',
    required this.date,
    this.moodEmoji,
    this.location,
    this.tags = const [],
    this.isBookmarked = false,
    this.isLocked = false,
    this.imagePaths = const [],
    this.blocks = const [],
  });

  DiaryEntryModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? moodEmoji,
    String? location,
    List<String>? tags,
    bool? isBookmarked,
    bool? isLocked,
    List<String>? imagePaths,
    List<DiaryBlock>? blocks,
  }) {
    return DiaryEntryModel(
      blocks: blocks ?? this.blocks,
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLocked: isLocked ?? this.isLocked,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      blocks: DiaryBlock.decodeList(json['blocks'] as String?),
      id: json['id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      moodEmoji: json['mood_emoji'],
      location: json['location'],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isBookmarked: json['is_bookmarked'] ?? false,
      isLocked: json['is_locked'] ?? false,
      imagePaths:
          (json['image_paths'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blocks': DiaryBlock.encodeList(blocks),
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'mood_emoji': moodEmoji,
      'location': location,
      'tags': tags,
      'is_bookmarked': isBookmarked,
      'is_locked': isLocked,
      'image_paths': imagePaths,
    };
  }
}
