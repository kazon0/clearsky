import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';

const genderMapToCN = {"MALE": "男", "FEMALE": "女", "OTHER": "其他"};

const genderMapToEN = {"男": "MALE", "女": "FEMALE", "其他": "OTHER"};

const avatarList = [
  "assets/images/avatar1.jpg",
  "assets/images/avatar2.jpg",
  "assets/images/avatar3.jpg",
  "assets/images/avatar4.jpg",
  "assets/images/avatar5.jpg",
  "assets/images/avatar6.jpg",
  "assets/images/avatar7.jpg",
  "assets/images/avatar8.jpg",
  "assets/images/avatar9.jpg",
];

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  String gender = '男'; // 默认值
  String selectedAvatar = "assets/images/avatar1.jpg";

  @override
  void initState() {
    super.initState();
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final user = userVM.userInfo!;

    nameController = TextEditingController(text: user['realName'] ?? '');
    emailController = TextEditingController(text: user['email'] ?? '');
    phoneController = TextEditingController(text: user['phone'] ?? '');

    gender = genderMapToCN[user['gender']] ?? "其他";
    selectedAvatar = user['avatarUrl'] ?? "assets/images/avatar1.jpg";
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        title: const Text("修改个人信息"),
        backgroundColor: const Color(0xFFFFFCF7),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showAvatarSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade600),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage(selectedAvatar),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text("选择头像", style: TextStyle(fontSize: 16)),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade600,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _textField("姓名", nameController),
            const SizedBox(height: 15),
            _textField("邮箱", emailController),
            const SizedBox(height: 15),
            _textField("手机号", phoneController),
            const SizedBox(height: 15),

            // ------ 性别选择器 ------
            _genderSelector(),

            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // 更新头像
                  await userVM.updateAvatar(selectedAvatar);
                  final success = await userVM.updateUserInfo(
                    realName: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    gender: genderMapToEN[gender]!,
                  );

                  if (success) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("修改成功")));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF6F99BF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "保存修改",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _genderSelector() {
    return InkWell(
      onTap: _showGenderSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "性别",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            Text(
              gender,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // 底部弹出菜单
  void _showGenderSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // 允许更高的高度计算安全区
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_genderItem("男"), _genderItem("女"), _genderItem("其他")],
            ),
          ),
        );
      },
    );
  }

  void _showAvatarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "选择头像",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 网格头像
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: avatarList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (_, index) {
                    final path = avatarList[index];
                    final isSelected = selectedAvatar == path;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedAvatar = path);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(path),
                          radius: 35,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _genderItem(String value) {
    return ListTile(
      title: Text(value, style: const TextStyle(fontSize: 17)),
      onTap: () {
        setState(() => gender = value);
        Navigator.pop(context);
      },
    );
  }
}
