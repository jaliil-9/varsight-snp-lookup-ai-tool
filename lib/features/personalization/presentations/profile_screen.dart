import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/personalization/providers/profile_providers.dart';
import 'package:varsight/features/personalization/notifiers/theme_notifier.dart';
import 'package:varsight/core/utils/helpers.dart';
import 'package:varsight/features/authentication/providers/auth_provider.dart';
import 'package:varsight/features/authentication/notifiers/auth_notifier.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool notifications = false;
  String language = 'English';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return authState.when(
      loading:
          () => Scaffold(
            appBar: AppBar(
              title: Text(
                'Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stackTrace) => Scaffold(
            appBar: AppBar(
              title: Text(
                'Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: Center(child: Text('Error: $error')),
          ),
      data: (data) {
        final profileAsync = ref.watch(profileProvider);
        final isGuest = data is AuthGuest;
        final isAuthenticated = data is AuthAuthenticated;
        final userName =
            isAuthenticated
                ? (profileAsync.value?.firstname ?? 'User')
                : 'Guest User';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              const SizedBox(height: 24),
              profileAsync.when(
                data:
                    (profile) => CircleAvatar(
                      radius: 56,
                      backgroundImage: Helpers.getImageProvider(
                        profile?.profilePicture,
                      ),
                    ),
                loading:
                    () => const CircleAvatar(
                      radius: 56,
                      child: CircularProgressIndicator(),
                    ),
                error:
                    (err, stack) => const CircleAvatar(
                      radius: 56,
                      child: Icon(Iconsax.user),
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              TextButton(
                onPressed: () {
                  if (isGuest) {
                    Navigator.pushNamed(context, '/login');
                  } else {
                    Navigator.pushNamed(context, '/edit-profile');
                  }
                },
                child: Text(
                  isGuest ? 'Sign In' : 'Edit Profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // App Settings Header with vertical line
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'App Settings',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    // App Settings Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Notifications'),
                              value: notifications,
                              onChanged:
                                  (val) => setState(() => notifications = val),
                            ),
                            SwitchListTile(
                              title: const Text('Dark Mode'),
                              value: themeMode == ThemeMode.dark,
                              onChanged:
                                  (isDarkMode) => ref
                                      .read(themeNotifierProvider.notifier)
                                      .setTheme(isDarkMode),
                            ),
                            ListTile(
                              title: const Text('Language'),
                              trailing: Text(
                                language,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Other Header with vertical line
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Other',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    // Other Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Help Center'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                              onTap: () {},
                            ),
                            ListTile(
                              title: const Text('Terms of Service'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                              onTap: () {},
                            ),
                            ListTile(
                              title: const Text('Privacy Policy'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Log Out or Log In Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 8,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isGuest
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.red,
                            side: BorderSide(
                              color:
                                  isGuest
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.red,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Sizes.borderRadiusLg,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            if (isGuest) {
                              Navigator.pushNamed(context, '/login');
                            } else {
                              final bool? shouldLogout = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Log Out'),
                                      content: const Text(
                                        'Are you sure you want to log out?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text('Log Out'),
                                        ),
                                      ],
                                    ),
                              );
                              if (shouldLogout == true && context.mounted) {
                                await ref
                                    .read(authNotifierProvider.notifier)
                                    .logout();
                              }
                            }
                          },
                          child: Text(
                            isGuest ? 'Log In' : 'Log Out',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isGuest ? Colors.blue : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
