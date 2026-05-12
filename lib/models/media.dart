enum MediaType { video, audio, image }

class Media {
  final int id;
  final String url;
  final MediaType mediaType;
  final String filename;
  final int position;

  Media({
    required this.id,
    required this.url,
    required this.mediaType,
    required this.filename,
    required this.position,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    MediaType type;
    switch (json['media_type']) {
      case 'video':
        type = MediaType.video;
        break;
      case 'audio':
        type = MediaType.audio;
        break;
      case 'image':
      default:
        type = MediaType.image;
    }

    return Media(
      id: json['id'],
      url: json['url'],
      mediaType: type,
      filename: json['filename'],
      position: json['position'],
    );
  }
}
