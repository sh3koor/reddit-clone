import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/sign_in_button.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/responsive/responsive.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  void signInAsGuest(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          Constants.logoPath,
          height: 45,
        ),
        actions: [
          TextButton(
            onPressed: () {
              signInAsGuest(ref, context);
            },
            child: Text(
              "Skip",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Loader()
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    "Dive into anything",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(Constants.loginEmoge),
                ),
                flex: 8,
              ),
              Expanded(
                flex: 2,
                child: Responsive(child: SignInButton()),
              ),
              // Expanded(
              //   flex: 2,
              //   child: ElevatedButton(
              //     child: Text("Signout"),
              //     onPressed: () {
              //       ref.read(authControllerProvider.notifier).logout();
              //     },
              //   ),
              // ),
            ]),
    );
  }
}
