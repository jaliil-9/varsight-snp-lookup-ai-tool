import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/core/utils/error.dart';
import 'package:varsight/core/utils/validators.dart';
import 'package:varsight/features/authentication/providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: Column(
          children: [
            Text(
              "Forgot your password? No worries, We'll help you reset it.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
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
                      prefixIcon: const Icon(Iconsax.direct_right),
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                if (!_formKey.currentState!.validate()) return;
                                setState(() => _isLoading = true);
                                try {
                                  await ref
                                      .read(authNotifierProvider.notifier)
                                      .sendPasswordResetEmail(
                                        emailController.text.trim(),
                                      );
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/reset-success',
                                    );
                                  }
                                } catch (e) {
                                  ErrorUtils.showErrorSnackBar(
                                    ErrorUtils.getErrorMessage(e),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text("Send Reset Link"),
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
