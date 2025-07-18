import 'package:varsight/features/authentication/presentations/oboarding/auth_gate_page.dart';
import 'package:varsight/features/authentication/presentations/sign_in/forgot_password_page.dart';
import 'package:varsight/features/authentication/presentations/sign_in/reset_success_page.dart';
import 'package:varsight/features/authentication/presentations/sign_in/sign_in_screen.dart';
import 'package:varsight/features/authentication/presentations/sign_up/registration_success_page.dart';
import 'package:varsight/features/authentication/presentations/sign_up/sign_up_screen.dart';
import 'package:varsight/features/snp_search/presentations/search_screen.dart';
import 'package:varsight/features/personalization/presentations/static_content_page.dart';
import 'package:varsight/features/personalization/presentations/edit_profile_screen.dart';
import 'package:varsight/features/personalization/presentations/profile_screen.dart';
import 'package:varsight/features/snp_search/presentations/favourites_screen.dart';
import 'package:varsight/main_nav.dart';

class AppRoutes {
  static final routes = {
    '/': (context) => const MainNavScreen(),
    '/auth': (context) => const AuthGatePage(),
    "/login": (context) => LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/reset-password': (context) => const ForgotPasswordPage(),
    '/reset-success': (context) => const ResetSuccessPage(),
    "/registration_success": (context) => const RegistrationSuccessPage(),
    '/search': (context) => const SearchScreen(),
    '/edit-profile': (context) => const EditProfileScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/favourites': (context) => const FavouritesScreen(),
    '/help-center':
        (context) => const StaticContentPage(
          title: 'Help Center',
          markdownFilePath: 'assets/text/help_center.md',
        ),
    '/terms-of-service':
        (context) => const StaticContentPage(
          title: 'Terms of Service',
          markdownFilePath: 'assets/text/terms_service.md',
        ),
    '/privacy-policy':
        (context) => const StaticContentPage(
          title: 'Privacy Policy',
          markdownFilePath: 'assets/text/privacy_policy.md',
        ),
  };
}
