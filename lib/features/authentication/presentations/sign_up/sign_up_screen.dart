import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/core/utils/error.dart';
import 'package:varsight/features/authentication/notifiers/auth_notifier.dart';
import 'package:varsight/features/authentication/providers/auth_provider.dart';

import '../../../../core/utils/validators.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, state) {
      state.whenOrNull(
        error: (err, stack) {
          ErrorUtils.showErrorSnackBar(context, ErrorUtils.getErrorMessage(err));
        },
        data: (authState) {
          if (authState is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/registration_success');
          }
        },
      );
    });
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcoming message
            Text(
              "Hello, welcome to Varsight!",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: Sizes.spaceBtwItems),

            Text(
              "Create an account to get started",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: Sizes.spaceBtwSections),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    validator:
                        (value) => Validators.validateEmail(context, value),
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your email",
                      prefixIcon: const Icon(Iconsax.direct_right),
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwInputFields),
                  TextFormField(
                    controller: passwordController,
                    validator:
                        (value) =>
                            Validators.validateNewPassword(context, value),
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your password",
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        onPressed:
                            () => setState(
                              () => _passwordVisible = !_passwordVisible,
                            ),
                        icon: Icon(
                          _passwordVisible ? Iconsax.eye : Iconsax.eye_slash,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwInputFields),
                  TextFormField(
                    controller: confirmPasswordController,
                    validator:
                        (value) => Validators.validateConfirmPassword(
                          context,
                          value,
                          passwordController.text,
                        ),
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Re-enter your password",
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        onPressed:
                            () => setState(
                              () =>
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible,
                            ),
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Iconsax.eye
                              : Iconsax.eye_slash,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (_formKey.currentState!.validate()) {
                                  final email = emailController.text.trim();
                                  final password =
                                      passwordController.text.trim();
                                  await ref
                                      .read(authNotifierProvider.notifier)
                                      .register(email, password);
                                }
                              },
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text("Register"),
                    ),
                  ),
                  SizedBox(height: Sizes.spaceBtwItems),
                  // Register option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${"Already have an account?"} '),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          "Login",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Divider

                  // Social Sign in
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
