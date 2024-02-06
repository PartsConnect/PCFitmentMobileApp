class LangModel {
  String? textContent;
  String? defaultLanguageCode;
  String? translated;

  LangModel({
    required this.textContent,
    required this.defaultLanguageCode,
    required this.translated,
  });

  factory LangModel.fromJson(Map<String, dynamic> json) {
    return LangModel(
      textContent: json['TextContent'],
      defaultLanguageCode: json['DefaultLanguageCode'],
      translated: json['Translated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TextContent': textContent,
      'DefaultLanguageCode': defaultLanguageCode,
      'Translated': translated,
    };
  }

  @override
  String toString() {
    return 'LangModel{TextContent: $textContent, DefaultLanguageCode: $defaultLanguageCode, Translated: $translated}';
  }
}
