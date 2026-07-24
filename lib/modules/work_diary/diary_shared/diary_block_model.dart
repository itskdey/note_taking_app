import 'dart:convert';

enum DiaryBlockType {
  checklist,
  radio,
  bullet,
  numbered,
  quote,
  divider,
  image,
  heading,
  callout,
  voice,
}

extension DiaryBlockTypeX on DiaryBlockType {
  String get key => name;

  static DiaryBlockType fromKey(String key) => DiaryBlockType.values.firstWhere(
    (e) => e.name == key,
    orElse: () => DiaryBlockType.bullet,
  );
}

String generateDiaryBlockId() =>
    DateTime.now().microsecondsSinceEpoch.toString();

class DiaryBlockOption {
  DiaryBlockOption({required this.id, this.text = '', this.checked = false});

  final String id;
  String text;
  bool checked;

  factory DiaryBlockOption.fromJson(Map<String, dynamic> json) {
    return DiaryBlockOption(
      id: json['id'] as String,
      text: json['text'] as String? ?? '',
      checked: json['checked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'checked': checked};

  DiaryBlockOption copyWith({String? text, bool? checked}) {
    return DiaryBlockOption(
      id: id,
      text: text ?? this.text,
      checked: checked ?? this.checked,
    );
  }
}

class DiaryBlock {
  DiaryBlock({
    required this.id,
    required this.type,
    List<DiaryBlockOption>? options,
    List<String>? imagePaths,
    this.text,
    this.audioPath,
    this.audioDurationMs = 0,
  }) : options = options ?? [],
       imagePaths = imagePaths ?? [];

  final String id;
  DiaryBlockType type;
  List<DiaryBlockOption> options; // checklist / radio / bullet / numbered
  String? text; // quote / heading / callout
  List<String> imagePaths; // image only
  String? audioPath; // voice only
  int audioDurationMs; // voice only

  factory DiaryBlock.fromJson(Map<String, dynamic> json) {
    return DiaryBlock(
      id: json['id'] as String,
      type: DiaryBlockTypeX.fromKey(json['type'] as String),
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => DiaryBlockOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      text: json['text'] as String?,
      audioPath: json['audioPath'] as String?,
      audioDurationMs: json['audioDurationMs'] as int? ?? 0,
      imagePaths: (json['imagePaths'] as List<dynamic>? ?? [])
          .map((path) => path.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.key,
    'options': options.map((e) => e.toJson()).toList(),
    'text': text,
    'imagePaths': imagePaths,
    'audioPath': audioPath,
    'audioDurationMs': audioDurationMs,
  };

  static String encodeList(List<DiaryBlock> blocks) =>
      jsonEncode(blocks.map((b) => b.toJson()).toList());

  static List<DiaryBlock> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => DiaryBlock.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
