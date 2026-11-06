import 'package:flutter/material.dart';
import '../models/community_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPostModel post;
  final String currentUserId;
  final bool isAdmin;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onDelete;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.isAdmin,
    required this.onLike,
    required this.onComment,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = post.isLikedBy(currentUserId);
    final canDelete = isAdmin || post.userId == currentUserId;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.mintGreen,
                  child: Text(
                    post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'F',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: post.userRole == 'Administrator'
                                  ? AppColors.lavender.withOpacity(0.3)
                                  : AppColors.mintGreen.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              post.userRole,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: post.userRole == 'Administrator'
                                    ? AppColors.forestGreen
                                    : AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (post.userLocation.isNotEmpty) ...[
                            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                post.userLocation,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(' • ', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ],
                          Text(
                            DateFormatter.timeAgo(post.createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canDelete && onDelete != null)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                    onSelected: (value) {
                      if (value == 'delete') onDelete!();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.coral),
                            const SizedBox(width: 8),
                            Text(
                              isAdmin && post.userId != currentUserId ? 'Moderate / Remove' : 'Delete Post',
                              style: const TextStyle(color: AppColors.coral, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Category tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.freshLeafGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                post.category,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forestGreen,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Post Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Post Content
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),

            const Divider(height: 1, thickness: 0.6),

            // Actions Row (Likes & Comments)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: onLike,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 20,
                            color: isLiked ? AppColors.coral : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.likes}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isLiked ? AppColors.coral : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: onComment,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 19,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.comments.length} Comments',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
