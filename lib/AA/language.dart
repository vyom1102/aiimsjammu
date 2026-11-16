enum Language {
english('en'),
hindi('hi');

final String code;
const Language(this.code);

static Language fromString(String value) {
final v = value.toLowerCase();

return Language.values.firstWhere(
(lang) => lang.code == v || lang.name == v,
orElse: () => Language.english,
);
}

String toCode() => code;
}