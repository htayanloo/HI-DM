class DownloadCategory {
  final int? id;
  final String name;
  final String fileExtensions; // comma-separated: ".pdf,.doc,.docx"
  final String defaultSavePath;
  final String icon; // material icon name

  const DownloadCategory({
    this.id,
    required this.name,
    required this.fileExtensions,
    required this.defaultSavePath,
    this.icon = 'folder',
  });

  List<String> get extensionList =>
      fileExtensions.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();

  bool matchesExtension(String fileName) {
    final ext = '.${fileName.split('.').last}'.toLowerCase();
    return extensionList.contains(ext);
  }

  DownloadCategory copyWith({
    int? id,
    String? name,
    String? fileExtensions,
    String? defaultSavePath,
    String? icon,
  }) => DownloadCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    fileExtensions: fileExtensions ?? this.fileExtensions,
    defaultSavePath: defaultSavePath ?? this.defaultSavePath,
    icon: icon ?? this.icon,
  );
}
