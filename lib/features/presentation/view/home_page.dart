import 'package:flutter/material.dart';
import 'package:flutter_mvvm/app/routes/app_router.dart';
import 'package:flutter_mvvm/features/presentation/viewmodel/login_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<LoginViewModel>().logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.Login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginViewModel>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text('Không tìm thấy thông tin người dùng.'),
            )
          : Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundImage: user.imageUrl.isNotEmpty
                            ? NetworkImage(user.imageUrl)
                            : null,
                        child: user.imageUrl.isEmpty
                            ? const Icon(Icons.person, size: 44)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(user.email),
                      const SizedBox(height: 4),
                      Text('Username: ${user.username}'),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.UserList);
                        },
                        icon: const Icon(Icons.people_outline),
                        label: const Text('Quản lý người dùng'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.VideoList);
                        },
                        icon: const Icon(Icons.video_library_outlined),
                        label: const Text('Quản lý video'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
