import 'package:flutter/material.dart';
import 'package:flutter_mvvm/features/domain/entities/video.dart';

class VideoListItem extends StatelessWidget {
  final Video video;
  final VoidCallback onTapView;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  const VideoListItem({
    super.key,
    required this.video,
    required this.onTapView,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  String _formatViews(int views) {
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return '$views';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail & Duration Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Image.network(
                    video.thumbnailUrl,
                    width: 110,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 110,
                        height: 68,
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Icon(Icons.video_library, color: Colors.grey, size: 32),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 110,
                        height: 68,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(178),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Title & Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${video.category} • ${video.creator}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        _formatViews(video.views),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: onTapView,
                  icon: const Icon(Icons.visibility_outlined, color: Colors.teal),
                  tooltip: 'Xem',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  onPressed: onTapEdit,
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  tooltip: 'Sửa',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                IconButton(
                  onPressed: onTapDelete,
                  icon: const Icon(Icons.delete_outline_outlined, color: Colors.red),
                  tooltip: 'Xóa',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
