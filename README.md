# Fly To Cart

[![pub package](https://img.shields.io/pub/v/fly_to_cart.svg)](https://pub.dev/packages/fly_to_cart)
[![likes](https://img.shields.io/pub/likes/fly_to_cart)](https://pub.dev/packages/fly_to_cart)
[![popularity](https://img.shields.io/pub/popularity/fly_to_cart)](https://pub.dev/packages/fly_to_cart)
[![pub points](https://img.shields.io/pub/points/fly_to_cart)](https://pub.dev/packages/fly_to_cart)

A highly customizable widget that provides a "fly to cart" animation and a floating basket, designed to be independent of any state management solution (works with Riverpod, BLoC, GetX, Provider, setState, etc.).

*(Here you should add a cool GIF of your animation in action. Use a tool like LiceCAP or Kap to record your screen.)*

![Fly To Cart Animation Demo](assets/fly_to_cart.gif)
## Features

- **State-Management Agnostic:** You provide the state, the widget provides the UI.
- **Highly Customizable:** Control the basket's contents and total calculation.
- **Smooth Animation:** Built-in "fly-to" animation using `OverlayEntry`.
- **Simple API:** Wrap your page, provide the data, and trigger the animation from anywhere.
- **Well-Documented & Tested.**

## Usage

1.  **Wrap your page** with the `FlyToCartController`. This is typically done around your `Scaffold`.
2.  **Provide state** to the controller from your state management solution (`basketItems`, `processingItemIds`).
3.  **Provide callbacks and builders** for UI interaction (`onViewBasket`, `basketItemBuilder`, `totalCalculator`).
4.  From a child widget (like a button's `onPressed`), **call the animation trigger** and **your business logic**.

### Complete Example (`setState`):

```dart
// main.dart (Full code in the package's /example folder)
import 'package:flutter/material.dart';
import 'package:fly_to_cart/fly_to_cart.dart';

// Your models
class Product { /* ... */ }
class CartItem { /* ... */ }

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Your app's state
  final List<CartItem> _cartItems = [];
  final Set<String> _processingIds = {};

  // Your business logic
  void _addToCart(Product product) { /* ... setState logic ... */ }

  @override
  Widget build(BuildContext context) {
    // Wrap the Scaffold with the controller
    return FlyToCartController<CartItem>(
      basketItems: _cartItems,
      processingItemIds: _processingIds,
      onViewBasket: () { /* Show cart */ },
      totalCalculator: (items) { /* Calculate total string */ },
      basketItemBuilder: (context, item) { /* Build item preview */ },
      child: Scaffold(
        appBar: AppBar(title: const Text('Fly To Cart Demo')),
        body: GridView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              // Let the card know if it's loading
              isProcessing: _processingIds.contains(product.id),
              onAddToCart: () {
                // In the card's tap handler:
                // 1. Call your business logic
                _addToCart(product);

                // 2. Trigger the animation
                FlyToCartController.of(context).triggerAnimation(
                  itemKey: aGlobalKeyOnTheAddButton,
                  imageUrl: product.imageUrl,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
```

## Additional information

Feel free to contribute to this package, file issues, or suggest new features!