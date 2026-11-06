import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/community_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/community_post_card.dart';
import '../../widgets/empty_state_widget.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityProvider>(context, listen: false).loadPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCommentsBottomSheet(BuildContext context, CommunityPostModel post) {
    final commentController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final communityProv = Provider.of<CommunityProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final freshPost = communityProv.posts.firstWhere((p) => p.id == post.id, orElse: () => post);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.dividerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments (${freshPost.comments.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 1),

                    // Comments List
                    Expanded(
                      child: freshPost.comments.isEmpty
                          ? const Center(
                              child: Text(
                                'No comments yet. Start the conversation!',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: freshPost.comments.length,
                              separatorBuilder: (_, _) => const Divider(height: 16),
                              itemBuilder: (context, index) {
                                final c = freshPost.comments[index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.mintGreen,
                                      child: Text(
                                        c.userName.isNotEmpty ? c.userName[0].toUpperCase() : 'U',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.forestGreen),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                c.userName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                DateFormatter.timeAgo(c.createdAt),
                                                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            c.content,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: AppColors.textSecondary,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),

                    // Comment Input Field
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Write a supportive comment or advice...',
                                hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: AppColors.forestGreen,
                            child: IconButton(
                              icon: const Icon(Icons.send_rounded, size: 18, color: AppColors.white),
                              onPressed: () async {
                                final text = commentController.text.trim();
                                if (text.isEmpty) return;

                                await communityProv.addComment(
                                  postId: post.id,
                                  userId: auth.currentUser?.id ?? 'guest',
                                  userName: auth.currentUser?.name ?? 'Organic Farmer',
                                  userRole: auth.currentUser?.role ?? 'Farmer',
                                  content: text,
                                );
                                commentController.clear();
                                setModalState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final communityProv = Provider.of<CommunityProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentUserId = auth.currentUser?.id ?? '';
    final posts = communityProv.filteredPosts;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Organic Community Forum'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Category Chips
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search organic techniques, fertilizers, pests...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.forestGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                communityProv.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => communityProv.setSearchQuery(val),
                  ),
                  const SizedBox(height: 10),

                  // Category Filter Horizontal List
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: AppStrings.communityCategories.map((cat) {
                        final isSelected = communityProv.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppColors.forestGreen,
                            backgroundColor: AppColors.mintGreen.withOpacity(0.3),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              communityProv.setSelectedCategory(cat);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Posts List
            Expanded(
              child: posts.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.forum_outlined,
                      title: 'No Discussions Found',
                      subtitle: 'Be the pioneer! Share your natural organic farming success or technique with fellow farmers.',
                      buttonText: 'Create New Post',
                      onButtonPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.createPost);
                      },
                    )
                  : RefreshIndicator(
                      color: AppColors.forestGreen,
                      onRefresh: () => communityProv.loadPosts(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return CommunityPostCard(
                            post: post,
                            currentUserId: currentUserId,
                            isAdmin: auth.isAdmin,
                            onLike: () => communityProv.toggleLike(post.id, currentUserId),
                            onComment: () => _showCommentsBottomSheet(context, post),
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(auth.isAdmin && post.userId != currentUserId
                                      ? 'Moderate Post?'
                                      : 'Delete Post?'),
                                  content: const Text('Are you sure you want to permanently delete this post?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await communityProv.deletePost(post.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Post deleted successfully.')),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.createPost);
        },
        backgroundColor: AppColors.forestGreen,
        icon: const Icon(Icons.edit_note_rounded, color: AppColors.white),
        label: const Text(
          'New Post',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
