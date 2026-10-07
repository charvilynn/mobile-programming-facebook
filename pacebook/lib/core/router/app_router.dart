import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/complete_profile_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/feed/screens/create_post_screen.dart';
import '../../features/feed/screens/post_detail_screen.dart';
import '../../features/feed/screens/edit_post_screen.dart';
import '../../features/feed/screens/bookmarks_screen.dart';
import '../../features/feed/screens/notes_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/connections_list_screen.dart';
import '../../features/profile/screens/connection_requests_screen.dart';
import '../../features/chat/screens/chat_screens.dart';
import '../../features/community_event_market/screens/community_screens.dart';
import '../../features/community_event_market/screens/group_detail_screen.dart';
import '../../features/community_event_market/screens/event_detail_screen.dart';
import '../../features/community_event_market/screens/marketplace_item_detail_screen.dart';
import '../shell/main_shell.dart';
import '../providers/core_providers.dart';


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterListenable(ref),
    redirect: (context, state) {
      final isLoggedIn = ref.read(isLoggedInProvider);
      final onAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation.startsWith('/forgot') ||
          state.matchedLocation.startsWith('/otp') ||
          state.matchedLocation == '/complete-profile';

      if (!isLoggedIn && !onAuthPage) return '/login';
      if (isLoggedIn && onAuthPage && state.matchedLocation != '/splash') {
        return '/feed';
      }
      return null;
    },
    routes: [
 // AUTH ROUTES (no shell)
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/otp/:email',
        builder: (_, state) => OtpVerifyScreen(
          email: state.pathParameters['email']!,
        ),
      ),
      GoRoute(path: '/complete-profile', builder: (_, __) => const CompleteProfileScreen()),

 // MAIN APP (with bottom nav shell)
      ShellRoute(
        builder: (_, state, child) => MainShell(child: child),
        routes: [
 // Feed
          GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
          GoRoute(path: '/create-post', builder: (_, __) => const CreatePostScreen()),
          GoRoute(
            path: '/post/:id',
            builder: (_, state) => PostDetailScreen(
              postId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/edit-post/:id',
            builder: (_, state) => EditPostScreen(
              postId: int.parse(state.pathParameters['id']!),
            ),
          ),
 // Profile
          GoRoute(
            path: '/profile/:id',
            builder: (_, state) => ProfileScreen(
              userId: state.pathParameters['id'] == 'me'
                  ? null
                  : int.tryParse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (_, __) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/connections/:userId',
            builder: (_, state) => ConnectionsListScreen(
              userId: int.tryParse(state.pathParameters['userId'] ?? '1') ?? 1,
            ),
          ),
          GoRoute(
            path: '/connection-requests',
            builder: (_, __) => const ConnectionRequestsScreen(),
          ),
 // Chat
          GoRoute(path: '/chat', builder: (_, __) => const ChatListScreen()),
 // opens a direct message with a specific user
          GoRoute(
            path: '/chat/dm/:userId',
            builder: (_, state) {
              final targetUserId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
              final name = state.uri.queryParameters['name'];
              final avatar = state.uri.queryParameters['avatar'];
              return ChatRoomScreen(
                targetUserId: targetUserId,
                targetName: name,
                targetAvatar: avatar,
              );
            },
          ),
          GoRoute(
            path: '/chat/:roomId',
            builder: (_, state) {
              final id = int.tryParse(state.pathParameters['roomId']!) ?? 1;
              return ChatRoomScreen(roomId: id);
            },
          ),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationCenterScreen()),
 // Communities
          GoRoute(path: '/groups', builder: (_, __) => const GroupsListScreen()),
          GoRoute(
            path: '/groups/:id',
            builder: (_, state) => GroupDetailScreen(
              groupId: int.tryParse(state.pathParameters['id']!) ?? 1,
            ),
          ),
 // Events
          GoRoute(path: '/events', builder: (_, __) => const EventsListScreen()),
          GoRoute(
            path: '/events/:id',
            builder: (_, state) => EventDetailScreen(
              eventId: int.tryParse(state.pathParameters['id']!) ?? 1,
            ),
          ),
 // Marketplace
          GoRoute(path: '/marketplace', builder: (_, __) => const MarketplaceHomeScreen()),
          GoRoute(
            path: '/marketplace/:id',
            builder: (_, state) => MarketplaceItemDetailScreen(
              itemId: int.tryParse(state.pathParameters['id']!) ?? 1,
            ),
          ),
 // Search & Settings
          GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
 // Bookmarks
          GoRoute(path: '/bookmarks', builder: (_, __) => const BookmarksScreen()),
 // Notes
          GoRoute(path: '/notes', builder: (_, __) => const NotesScreen()),
          GoRoute(path: '/notes/create', builder: (_, __) => const CreateNoteScreen()),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text(
          'Halaman tidak ditemukan: ${state.uri}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
});

class _RouterListenable extends ChangeNotifier {
  _RouterListenable(Ref ref) {
    ref.listen<bool>(isLoggedInProvider, (_, __) => notifyListeners());
  }
}