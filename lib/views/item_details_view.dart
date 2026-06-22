import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../models/decoration_model.dart';
import '../providers/cart_provider.dart';

class ItemDetailsView extends StatelessWidget {
  final DecorationModel item;

  const ItemDetailsView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPriceSection(),
                  const SizedBox(height: 32),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description.isNotEmpty ? item.description : "This premium decoration item is perfect for adding a touch of elegance to your special event.",
                    style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  _buildFeatures(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppTheme.primary,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(LucideIcons.chevronLeft, color: AppTheme.textPrimary, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: item.name,
          child: item.image != null
            ? (item.image!.startsWith('data:image')
                ? Image.memory(
                    base64Decode(item.image!.split(',').last),
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: item.image!,
                    fit: BoxFit.cover,
                  ))
            : Container(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.category,
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          item.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rental Price / Day",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              "\$${item.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.star, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                "4.9 (120+)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final features = [
      {"icon": LucideIcons.checkCircle, "text": "Premium Quality"},
      {"icon": LucideIcons.truck, "text": "Setup Included"},
      {"icon": LucideIcons.shieldCheck, "text": "Insured Item"},
      {"icon": LucideIcons.calendar, "text": "Flexible Booking"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 60,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Icon(features[index]['icon'] as IconData, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              features[index]['text'] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(LucideIcons.heart, color: Colors.pinkAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: "Add to Cart",
                onPressed: () {
                  context.read<CartProvider>().addItem(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Item added to cart!")),
                  );
                },
                icon: const Icon(LucideIcons.shoppingBag, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
