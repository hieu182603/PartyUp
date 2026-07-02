import 'package:flutter/material.dart';
import 'package:flutter_mvvm/features/domain/entities/app_user.dart';

class UserListItem extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTapView;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTapView,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: user.imageUrl.isNotEmpty ? NetworkImage(user.imageUrl) : null,
              child: user.imageUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onTapView,
                  icon: const Icon(Icons.visibility_outlined, color: Colors.teal),
                  tooltip: 'Xem',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  onPressed: onTapEdit,
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  tooltip: 'Sửa',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  onPressed: onTapDelete,
                  icon: const Icon(Icons.delete_outline_outlined, color: Colors.red),
                  tooltip: 'Xóa',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
