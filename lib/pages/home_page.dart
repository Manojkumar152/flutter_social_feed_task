import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:social_feed/controller/authController.dart';
import 'package:social_feed/controller/feedController.dart';
import 'package:social_feed/model/post_model.dart';
import 'package:social_feed/pages/post_details_page.dart';

class HomePage extends StatelessWidget {
  final feed = Get.find<FeedController>();
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final scroll = ScrollController();

    scroll.addListener(() {
      if (scroll.position.pixels >= scroll.position.maxScrollExtent - 100) {
        feed.fetchPosts();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Social Feed',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent, size: 22.sp),
            onPressed: auth.logout,
          )
        ],
      ),
      body: Obx(() {
        if (feed.isLoading.value && feed.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          color: Colors.blueAccent,
          onRefresh: () => feed.fetchPosts(refresh: true),
          child: ListView.builder(
            controller: scroll,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            itemCount: feed.posts.length + (feed.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == feed.posts.length) {
                return Padding(
                  padding: EdgeInsets.all(12.w),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final post = feed.posts[index];
              return PostCard(post: post);
            },
          ),
        );
      }),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final feed = Get.find<FeedController>();

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () => Get.to(() => PostDetailsPage(post: post)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: Colors.blueAccent.shade100,
                    child: Text(
                      post.userName.toString().substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Hero(
                      tag: 'post_${post.id}',
                      child: Text(
                        post.userName.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // --- Title ---
              Text(
                post.title.toString().capitalizeFirst ?? '',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 6.h),

              // --- Body ---
              Text(
                post.body.toString().capitalizeFirst ?? '',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12.h),

              // --- Divider ---
              Container(
                height: 0.8.h,
                color: Colors.grey.shade300,
                margin: EdgeInsets.symmetric(vertical: 4.h),
              ),

              // --- Like + Comments Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Row(
                        children: [
                          IconButton(
                            iconSize: 22.sp,
                            icon: Icon(
                              post.liked.value
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: post.liked.value
                                  ? Colors.redAccent
                                  : Colors.grey.shade600,
                            ),
                            onPressed: () => feed.toggleLike(post),
                          ),
                          Text(
                            post.liked.value ? "Liked" : "Like",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                              color: post.liked.value
                                  ? Colors.redAccent
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      )),
                  Obx(() => Row(
                        children: [
                          Icon(Icons.comment,
                              size: 18.sp, color: Colors.grey.shade600),
                          SizedBox(width: 4.w),
                          Text(
                            '${post.comments.value} comments',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
