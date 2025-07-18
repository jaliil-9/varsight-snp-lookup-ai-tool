import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/core/constants/sizes.dart';
import 'package:varsight/core/utils/error.dart';
import 'package:varsight/core/utils/validators.dart';
import 'package:varsight/core/utils/storage.dart';
import 'package:varsight/features/authentication/notifiers/auth_notifier.dart';
import 'package:varsight/features/authentication/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  void _loadRememberedEmail() {
    final rememberedEmail = JLocalStorage.instance().readData<String>(
      'rememberedEmail',
    );
    if (rememberedEmail != null) {
      emailController.text = rememberedEmail;
      _rememberMe = true;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, state) {
      state.whenOrNull(
        error: (err, stack) {
          ErrorUtils.showErrorSnackBar(ErrorUtils.getErrorMessage(err));
        },
        data: (authState) {
          if (authState is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      );
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body:
      // Main login content
      Padding(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcoming message
            Text(
              "Welcome Back!",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            Text(
              "Sign in to continue",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: Sizes.spaceBtwSections),

            // Email textfield
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

                  const SizedBox(height: Sizes.spaceBtwItems),

                  // Password textfield
                  TextFormField(
                    controller: passwordController,
                    validator:
                        (value) =>
                            Validators.validateEmptyPassword(context, value),
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

                  // Remember me & Forgot Password
                  Row(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                          ),
                          Text("Remember me"),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              '/forgot-password',
                            ),
                        child: Text(
                          "Forgot Password?",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Sizes.spaceBtwItems),

                  // Login button
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

                                  // Save or remove email based on checkbox
                                  if (_rememberMe) {
                                    await JLocalStorage.instance().saveData(
                                      'rememberedEmail',
                                      email,
                                    );
                                  } else {
                                    await JLocalStorage.instance().removeData(
                                      'rememberedEmail',
                                    );
                                  }

                                  await ref
                                      .read(authNotifierProvider.notifier)
                                      .login(email, password);
                                }
                              },
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text("Login"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Sizes.spaceBtwItems),

            // Register option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${"Don't have an account?"} '),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: Text(
                    "Register",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
