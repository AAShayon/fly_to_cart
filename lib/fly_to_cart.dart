// lib/fly_to_cart.dart

import 'package:flutter/material.dart';
import 'src/floating_basket_view.dart';

/// A controller that provides a "fly to cart" animation and a floating basket UI.
///
/// Wrap your page (e.g., your Scaffold) with this widget. It will provide an
/// animation trigger function to all descendant widgets via `FlyToCartController.of(context)`.
class FlyToCartController<T_basket_item> extends StatefulWidget {
  /// The main content of your page.
  final Widget child;

  /// A list of items currently in the cart. This is used to display item
  /// previews and calculate the total amount.
  /// This list should be managed by your application's state management solution.
  final List<T_basket_item> basketItems;

  /// A set of unique IDs for items currently being processed (e.g., added to cart).
  /// When this set is not empty, the floating basket shows a loading indicator.
  /// This should be managed by your application's state management solution.
  final Set<String> processingItemIds;

  /// A function that is called when the floating basket is tapped.
  /// Use this to trigger showing your main cart page or modal.
  final VoidCallback onViewBasket;

  /// A builder function to create the small preview widgets for items
  /// displayed inside the floating basket. It receives the current `BuildContext`
  /// and the item from the `basketItems` list.
  ///
  /// Example:
  /// ```dart
  /// basketItemBuilder: (context, item) {
  ///   return CircleAvatar(
  ///     backgroundImage: NetworkImage(item.imageUrl),
  ///   );
  /// }
  /// ```
  final Widget Function(BuildContext context, T_basket_item item) basketItemBuilder;

  /// A function to calculate the total price/amount string to display in the basket.
  /// It receives the full list of `basketItems`.
  final String Function(List<T_basket_item> items) totalCalculator;

  const FlyToCartController({
    super.key,
    required this.child,
    required this.basketItems,
    required this.onViewBasket,
    required this.basketItemBuilder,
    required this.totalCalculator,
    this.processingItemIds = const {},
  });

  /// Finds the [FlyToCartControllerState] from the closest instance of this widget
  /// that encloses the given context.
  ///
  /// This is used by child widgets to trigger the animation.
  ///
  /// Example from a child widget's `onPressed` handler:
  /// ```dart
  /// FlyToCartController.of(context).triggerAnimation(
  ///   key: yourItemGlobalKey,
  ///   imageUrl: yourProduct.imageUrl,
  /// );
  /// ```
  static FlyToCartControllerState of(BuildContext context) {
    final state = context.findAncestorStateOfType<FlyToCartControllerState>();
    assert(state != null,
    'FlyToCartController not found in context. Did you forget to wrap your page with it?');
    return state!;
  }

  @override
  FlyToCartControllerState<T_basket_item> createState() =>
      FlyToCartControllerState<T_basket_item>();
}

class FlyToCartControllerState<T_basket_item>
    extends State<FlyToCartController<T_basket_item>> with SingleTickerProviderStateMixin {
  final GlobalKey _basketKey = GlobalKey();
  late AnimationController _animationController;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  /// Triggers the "fly to cart" animation from a child widget.
  ///
  /// - [itemKey]: A `GlobalKey` attached to the widget you are animating *from*
  ///   (e.g., the add button on your product card).
  /// - [imageUrl]: The URL of the image to be shown in the flying animation.
  void triggerAnimation({required GlobalKey itemKey, required String? imageUrl}) {
    if (imageUrl == null ||
        itemKey.currentContext == null ||
        _basketKey.currentContext == null) return;

    final itemRenderBox = itemKey.currentContext!.findRenderObject() as RenderBox;
    final basketRenderBox = _basketKey.currentContext!.findRenderObject() as RenderBox;
    final itemPosition = itemRenderBox.localToGlobal(Offset.zero);
    final basketPosition = basketRenderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final animation = CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOutCubic);
        final tween = Tween<Offset>(
          begin: itemPosition,
          end: Offset(basketPosition.dx + 20, basketPosition.dy + 10),
        ).animate(animation);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Positioned(
            left: tween.value.dx,
            top: tween.value.dy,
            child: Opacity(
              opacity: 1.0 - _animationController.value,
              child: Material(
                color: Colors.transparent,
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward().whenComplete(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isBasketVisible = widget.basketItems.isNotEmpty || widget.processingItemIds.isNotEmpty;
    final bool isAnyItemProcessing = widget.processingItemIds.isNotEmpty;

    // Build the preview widgets using the provided builder.
    final previews = widget.basketItems.take(4).map((item) {
      return Align(
        widthFactor: 0.6,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 16,
            child: ClipOval(
              child: widget.basketItemBuilder(context, item),
            ),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        widget.child,
        FloatingBasketView(
          basketKey: _basketKey,
          isVisible: isBasketVisible,
          isProcessing: isAnyItemProcessing,
          onViewBasket: widget.onViewBasket,
          totalAmount: widget.totalCalculator(widget.basketItems),
          itemPreviews: previews,
        ),
      ],
    );
  }
}