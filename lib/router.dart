// loggedOut : routes for logged out users

// loggedIn : routes for logged in users

import 'package:flutter/material.dart';
import 'package:reddit_clone/features/auth/screens/login_screen.dart';
import 'package:reddit_clone/features/community/screens/add_mods_screen.dart';
import 'package:reddit_clone/features/community/screens/community_screen.dart';
import 'package:reddit_clone/features/community/screens/create_community_screen.dart';
import 'package:reddit_clone/features/community/screens/edit_community_screen.dart';
import 'package:reddit_clone/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_clone/features/home/home_screen.dart';
import 'package:reddit_clone/features/post/screens/add_post_type_screen.dart';
import 'package:reddit_clone/features/post/screens/post_comments_screen.dart';
import 'package:reddit_clone/features/user_profile/screens/edit_profile_screen.dart';
import 'package:reddit_clone/features/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter/scheduler.dart';

final loggedOutRoute = RouteMap(
  routes: {
    "/": (_) => MaterialPage(child: LoginScreen()),
  },
);

final loggedInRoute = RouteMap(
  routes: {
    "/": (_) => MaterialPage(child: HomeScreen()),
    "/create-community": (_) => MaterialPage(
          child: CreateCommunityScreen(),
        ),
    "/r/:name": (route) => MaterialPage(
          child: CommunityScreen(
            name: route.pathParameters["name"]!,
          ),
        ),
    "/mod-tools/:name": (route) => MaterialPage(
          child: ModToolsScreen(
            name: route.pathParameters["name"]!,
          ),
        ),
    "/edit-community/:name": (route) => MaterialPage(
          child: EditCommunityScreen(
            name: route.pathParameters["name"]!,
          ),
        ),
    '/add-mods/:name': (routeData) => MaterialPage(
          child: AddModsScreen(
            name: routeData.pathParameters['name']!,
          ),
        ),
    '/user-profile/:uid': (routeData) => MaterialPage(
          child: UserProfileScreen(
            uid: routeData.pathParameters['uid']!,
          ),
        ),
    '/edit-profile/:uid': (routeData) => MaterialPage(
          child: EditProfileScreen(
            uid: routeData.pathParameters['uid']!,
          ),
        ),
    '/add-post/:type': (routeData) => MaterialPage(
          child: AddPostTypeScreen(type: routeData.pathParameters["type"]!),
        ),
    '/post-comments/:postId': (routeData) => MaterialPage(
          child: CommentsScreen(postId: routeData.pathParameters["postId"]!),
        ),
  },
);
