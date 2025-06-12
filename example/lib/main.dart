// example/lib/main.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fly_to_cart/fly_to_cart.dart';

void main() => runApp(const MyApp());

// Step 1: Define your data models.
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  const Product({required this.id, required this.name, required this.price, required this.imageUrl});
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fly To Cart Example',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Step 2: Manage your state.
  // This can be done with setState, Riverpod, BLoC, GetX, etc.
  final List<CartItem> _cartItems = [];
  final Set<String> _processingIds = {}; // Used for loading indicators

  // Dummy product list
  final List<Product> _products = List.generate(
    20,
        (index) => Product(
      id: 'prod_$index',
      name: 'Product $index',
      price: (index + 1) * 5.25,
      imageUrl: 'https://picsum.photos/id/${100 + index}/200',
    ),
  );

  // Your business logic for adding to cart.
  void _addToCart(Product product) {
    setState(() {
      _processingIds.add(product.id);
    });

    // Simulate a network request
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        final existingItem = _cartItems.where((item) => item.product.id == product.id).firstOrNull;
        if (existingItem != null) {
          existingItem.quantity++;
        } else {
          _cartItems.add(CartItem(product: product));
        }
        _processingIds.remove(product.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Step 3: Wrap your page with the FlyToCartController.
    return FlyToCartController<CartItem>(
      // Provide the state from your state management solution.
      basketItems: _cartItems,
      processingItemIds: _processingIds,
      // Provide callbacks for UI interactions.
      onViewBasket: () => _showCartDialog(),
      totalCalculator: (items) {
        final total = items.fold<double>(0.0, (sum, item) => sum + (item.product.price * item.quantity));
        return '\$${total.toStringAsFixed(2)}';
      },
      basketItemBuilder: (context, item) {
        // Build the small preview widgets for the basket.
        return CachedNetworkImage(
          imageUrl: item.product.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fly To Cart Demo'),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return ProductCard(
              product: product,
              isProcessing: _processingIds.contains(product.id),
              onAddToCart: () => _addToCart(product),
            );
          },
        ),
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Cart'),
        content: Text('You have ${_cartItems.length} unique items in your cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}

// A "smart" widget that knows how to interact with the controller and app state.
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isProcessing;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.isProcessing,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final addButtonKey = GlobalKey();
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: isProcessing
                        ? null
                        : () {
                      // Step 4: Call your business logic and trigger the animation.
                      onAddToCart();
                      FlyToCartController.of(context).triggerAnimation(
                        itemKey: addButtonKey,
                        imageUrl: product.imageUrl,
                      );
                    },
                    child: Container(
                      key: addButtonKey,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.add_shopping_cart, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1),
                Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}