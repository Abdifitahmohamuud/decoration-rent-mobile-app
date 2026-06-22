import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/cart_item_model.dart';
import 'auth/login_view.dart';
import 'checkout_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.items;
        
        double subtotal = cartProvider.totalPrice;
        double securityDeposit = subtotal * 0.2; // 20% deposit
        double total = subtotal + securityDeposit;

        return Scaffold(
          appBar: AppBar(
            title: const Text("My Rental Cart"),
            centerTitle: true,
          ),
          body: cartItems.isEmpty
              ? _buildEmptyCart(context)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return _buildCartItem(context, item, cartProvider);
                        },
                      ),
                    ),
                    _buildSummary(context, subtotal, securityDeposit, total, cartProvider),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shoppingCart, size: 80, color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 24),
          const Text(
            "Your cart is empty",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start exploring our premium collection.",
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.decoration.image != null
              ? (item.decoration.image!.startsWith('data:image')
                  ? Image.memory(
                      base64Decode(item.decoration.image!.split(',').last),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      item.decoration.image!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ))
              : Container(width: 80, height: 80, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.decoration.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item.decoration.price.toStringAsFixed(2)} / day",
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQuantitySelector(item, cartProvider),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        cartProvider.removeItem(item.decoration.id);
                      },
                      icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(CartItem item, CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              cartProvider.updateQuantity(item.decoration.id, item.quantity - 1);
            },
            icon: const Icon(LucideIcons.minus, size: 16),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Text(
            "${item.quantity}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              cartProvider.updateQuantity(item.decoration.id, item.quantity + 1);
            },
            icon: const Icon(LucideIcons.plus, size: 16),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, double subtotal, double deposit, double total, CartProvider cartProvider) {
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            _buildSummaryRow("Security Deposit (20%)", "\$${deposit.toStringAsFixed(2)}"),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppTheme.border),
            ),
            _buildSummaryRow("Total Price", "\$${total.toStringAsFixed(2)}", isTotal: true),
            const SizedBox(height: 24),
            CustomButton(text: "Proceed to Checkout", onPressed: () {
              final authProvider = context.read<AuthProvider>();
              if (!authProvider.isAuthenticated) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView()));
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutView()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 22 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
            color: isTotal ? AppTheme.primary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
