
import 'package:flutter/material.dart';
import 'package:vfarm/home.dart';

class SearchSchemesScreen extends StatelessWidget {
  const SearchSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainWrapper(
      currentRoute: '/searchSchemes',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Color(0xFF0A9D88)),
            SizedBox(height: 16),
            Text(
              "Search for Schemes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Find the perfect scheme for your needs",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
