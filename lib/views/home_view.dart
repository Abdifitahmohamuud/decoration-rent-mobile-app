import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/decoration_card.dart';
import '../providers/decoration_provider.dart';
import '../models/decoration_model.dart';
import 'item_details_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Categories", () {}),
                  const SizedBox(height: 16),
                  _buildCategories(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Featured Decorations", () {}),
                  const SizedBox(height: 16),
                  _buildFeaturedList(context),
                  const SizedBox(height: 32),
                  _buildBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      expandedHeight: 70,
      backgroundColor: AppTheme.background,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            "DecorRent",
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(LucideIcons.bell, color: AppTheme.textPrimary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
            children: [
              const TextSpan(text: "Elevate Your "),
              TextSpan(
                text: "Events",
                style: TextStyle(color: AppTheme.primary),
              ),
              const TextSpan(text: "\nwith Premium Decor"),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "The ultimate platform for renting high-end event decorations.",
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Browse Catalog",
                onPressed: () {},
                icon: const Icon(LucideIcons.arrowRight, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            "See All",
            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    final categories = [
      {"name": "Weddings", "icon": LucideIcons.heart},
      {"name": "Corporate", "icon": LucideIcons.briefcase},
      {"name": "Parties", "icon": LucideIcons.partyPopper},
      {"name": "Lighting", "icon": LucideIcons.lamp},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Icon(categories[index]['icon'] as IconData, color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                categories[index]['name'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeaturedList(BuildContext context) {
    return Consumer<DecorationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.error.isNotEmpty) {
          return Center(child: Text('Error: ${provider.error}', style: const TextStyle(color: Colors.red)));
        }

        if (provider.decorations.isEmpty) {
          return const Center(child: Text('No decorations available.'));
        }

        // Take only top 2 or whatever count for featured
        final featured = provider.decorations.take(4).toList();

        return Column(
          children: featured.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DecorationCard(
                title: item.name,
                imageUrl: item.image ?? 'https://via.placeholder.com/400',
                price: item.price,
                category: item.category,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsView(item: item),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Plan Your Next Event",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Get 20% off on your first rental booking.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
            ),
            child: const Text("Get Started"),
          ),
        ],
      ),
    );
  }
}
