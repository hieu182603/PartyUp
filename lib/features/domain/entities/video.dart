class Video {
  final String id;
  final String title;
  final String category;
  final String creator;
  final int views;
  final String duration;
  final String description;
  final String status;
  final String uploadDate;
  final String thumbnailUrl;
  final String videoUrl;

  const Video({
    required this.id,
    required this.title,
    required this.category,
    required this.creator,
    required this.views,
    required this.duration,
    required this.description,
    required this.status,
    required this.uploadDate,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  Video copyWith({
    String? id,
    String? title,
    String? category,
    String? creator,
    int? views,
    String? duration,
    String? description,
    String? status,
    String? uploadDate,
    String? thumbnailUrl,
    String? videoUrl,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      creator: creator ?? this.creator,
      views: views ?? this.views,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      status: status ?? this.status,
      uploadDate: uploadDate ?? this.uploadDate,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
