import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/core/constants/sizes.dart';

class RegistrationSuccessPage extends StatelessWidget {
  const RegistrationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.tick_circle,
              size: 100,
              color:
                  isDarkMode
                      ? AppColors.secondaryDark
                      : AppColors.secondaryLight,
            ),
            const SizedBox(height: Sizes.spaceBtwSections),
            Text(
              "Registration Successful!",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            Text(
              "Your account has been created successfully. You can now log in to your account.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(context, '/search'),
                child: Text("Go to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
