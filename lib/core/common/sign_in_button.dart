import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/theme/pallete.dart';

class SignInButton extends ConsumerWidget {
  final isFromLogin;
  const SignInButton({super.key, this.isFromLogin = true});

  void signInWithGoogle(WidgetRef ref, BuildContext context) {
    ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle(context, isFromLogin);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 18),
      child: ElevatedButton.icon(
        onPressed: () => signInWithGoogle(ref, context),
        icon: Image.asset(
          Constants.googleImage,
          width: 35,
        ),
        label: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Continue with Google",
            style: TextStyle(fontSize: 18),
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Pallete.greyColor,
          minimumSize: Size(double.infinity, 30),
        ),
      ),
    );
  }
}
