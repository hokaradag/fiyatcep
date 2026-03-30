import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/cart_notifier.dart';
import '../cart_comparison_page.dart';

/// AppBar icon showing a shopping cart with a red badge indicating item count.
///
/// Badge is hidden when cart is empty; icon turns green when cart has items.
/// Navigates to [CartComparisonPage] on tap.
class CartAppBarIcon extends ConsumerWidget {
  const CartAppBarIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount =
        ref.watch(cartNotifierProvider).valueOrNull?.length ?? 0;

    return Tooltip(
      message: 'Sepeti Aç',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: cartCount > 0 ? Colors.green : null,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartComparisonPage(),
                ),
              );
            },
          ),
          if (cartCount > 0)
            Positioned(
              right: 4,
              top: 4,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text(
                  '$cartCount',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
