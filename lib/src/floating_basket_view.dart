import 'package:flutter/material.dart';

/// A private UI widget that displays the floating basket.
class FloatingBasketView extends StatelessWidget {
  final GlobalKey basketKey;
  final VoidCallback onViewBasket;
  final bool isVisible;
  final bool isProcessing;
  final String totalAmount;
  final List<Widget> itemPreviews;

  const FloatingBasketView({
    super.key,
    required this.basketKey,
    required this.onViewBasket,
    required this.isVisible,
    required this.isProcessing,
    required this.totalAmount,
    required this.itemPreviews,
  });

  @override
  Widget build(BuildContext context) {
    // Animate the appearance and disappearance of the widget by moving it.
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      bottom: isVisible ? 20 : -100, // Move it off-screen when not visible
      left: 20,
      right: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(50),
        child: InkWell(
          key: basketKey,
          onTap: onViewBasket,
          borderRadius: BorderRadius.circular(50),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isProcessing ? 0.8 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  if (isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    ...itemPreviews,
                  const SizedBox(width: 8),
                  const Text(
                    'View Basket',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_basket_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          totalAmount,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}