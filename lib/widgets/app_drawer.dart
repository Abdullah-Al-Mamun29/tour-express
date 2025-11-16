import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_service.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/cart_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Guest User'),
            accountEmail: Text(user?.email ?? 'No email'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.displayName?.substring(0, 1) ?? 'G',
                style: TextStyle(
                    fontSize: 40.0, color: Theme.of(context).primaryColor),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('My Cart'),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}
