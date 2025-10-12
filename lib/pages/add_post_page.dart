import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _controller = TextEditingController();
  File? _selectedImage;

  /// 从相册选择图片
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  /// 发布帖子
  void _submit() {
    if (_controller.text.trim().isEmpty && _selectedImage == null) return;

    final newPost = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "author": "匿名用户",
      "avatar": "https://ui-avatars.com/api/?name=匿名用户&background=random",
      "content": _controller.text.trim(),
      "images": _selectedImage != null ? [_selectedImage!.path] : [],
      "likes": 0,
      "commentsCount": 0,
      "isLiked": false,
      "createdAt": DateTime.now().toIso8601String(),
    };

    Navigator.pop(context, newPost);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF7),
        title: const Text('发布帖子'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text(
              '发布',
              style: TextStyle(color: Color(0xFF6F99BF), fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: '写点什么吧...',
                  filled: true,
                  fillColor: Color.fromARGB(255, 240, 245, 246),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 图片预览
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 16),
                          onPressed: () => setState(() => _selectedImage = null),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // 选择图片按钮
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('添加图片'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
