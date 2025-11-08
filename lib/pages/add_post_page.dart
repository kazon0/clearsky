import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/community_view_model.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isAnonymous = false;
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
  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('标题和内容不能为空')));
      return;
    }

    final vm = Provider.of<CommunityViewModel>(context, listen: false);

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('正在发布中...')));

      await vm.createPost(
        title: title,
        content: content,
        isAnonymous: _isAnonymous,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('发布成功，等待审核')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发布失败：$e')));
    }
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
              // 标题
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '请输入标题...',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 240, 245, 246),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 内容
              TextField(
                controller: _contentController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: '写点什么吧...',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 240, 245, 246),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 匿名开关
              SwitchListTile(
                title: const Text('匿名发布'),
                activeColor: const Color(0xFF6F99BF),
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
              ),

              const SizedBox(height: 12),

              // 图片预览（UI 保留）
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
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // 添加图片按钮
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('添加图片（暂不上传，仅预览）'),
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
