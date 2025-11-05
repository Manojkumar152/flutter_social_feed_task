import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:social_feed/api_services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:social_feed/model/post_model.dart';

class PostDetailsPage extends StatefulWidget {
  final Post post;
  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final Box box = Hive.box('appBox');
  final commentController = TextEditingController();
  final RxList<Map<dynamic, dynamic>> comments = <Map<dynamic, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final cached = box.get('comments_post_${widget.post.id}');
      log(" Cached Comments: $cached");
      if (cached != null) {
        comments.assignAll(List<Map<dynamic, dynamic>>.from(cached));
      }

      final fetched = await ApiService.fetchComments(widget.post.id);
      comments.assignAll(List<Map<dynamic, dynamic>>.from(fetched));

      await box.put('comments_post_${widget.post.id}', comments);
    } catch (e) {
      final cached = box.get('comments_post_${widget.post.id}');
      if (cached != null) {
        comments.assignAll(List<Map<dynamic, dynamic>>.from(cached));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment() async {
    if (commentController.text.isEmpty) return;
    final box = await Hive.openBox('appBox');
    final userEmail = box.get('userEmail');

    final newComment = await ApiService.addComment(
      widget.post.id,
      'You',
      userEmail,
      commentController.text,
    );

    comments.insert(0, newComment);
    await box.put('comments_post_${widget.post.id}', comments);
    widget.post.comments.value++;

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "Post Details",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Post Card
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.08),
                      blurRadius: 10.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Header with Avatar ---
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22.r,
                            backgroundColor: Colors.blueAccent.shade100,
                            child: Text(
                              widget.post.userName
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            widget.post.userName.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      Text(
                        widget.post.title.toString().capitalizeFirst ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 15.sp,
                        ),
                      ),

                      SizedBox(height: 14.h),
                      Divider(color: Colors.grey.shade300, thickness: 0.6),

                      // --- Like + Comment Info ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        widget.post.liked.value =
                                            !widget.post.liked.value;
                                        widget.post.likes.value +=
                                            widget.post.liked.value ? 1 : -1;
                                      });
                                    },
                                    child: Icon(
                                      widget.post.liked.value
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 22.sp,
                                      color: widget.post.liked.value
                                          ? Colors.redAccent
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    widget.post.liked.value ? "Liked" : "Like",
                                    style: TextStyle(
                                      color: widget.post.liked.value
                                          ? Colors.redAccent
                                          : Colors.grey.shade700,
                                      fontSize: 13.5.sp,
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
                                    '${widget.post.comments.value} comments',
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13.5.sp),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Comments List
            Expanded(
              child: Obx(() => ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.05),
                              blurRadius: 6.r,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 20.r,
                            backgroundColor: Colors.blueAccent.shade100,
                            child: Text(
                              comment['name']
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          title: Text(
                            comment['name'].toString().capitalizeFirst ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.5.sp),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              comment['body'].toString().capitalizeFirst ?? '',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade800,
                                  height: 1.3),
                            ),
                          ),
                          trailing: Text(
                            comment['email'] ?? '',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 10.5.sp),
                          ),
                        ),
                      );
                    },
                  )),
            ),

            // Comment Input
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black12, width: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F6F9),
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: TextField(
                          controller: commentController,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(
                                color: Colors.grey, fontSize: 13.5.sp),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: addComment,
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlueAccent],
                          ),
                        ),
                        child:
                            Icon(Icons.send, color: Colors.white, size: 20.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
