// test/fly_to_cart_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fly_to_cart/fly_to_cart.dart';

// A mock item class for testing purposes.
class MockCartItem {
  final String id;
  MockCartItem(this.id);
}

void main() {
  testWidgets('FlyToCartController provides itself to children via context',
          (WidgetTester tester) async {
        // ARRANGE: Build the controller with a child that needs to find it.
        await tester.pumpWidget(
          MaterialApp(
            home: FlyToCartController<MockCartItem>(
              basketItems: const [],
              onViewBasket: () {},
              basketItemBuilder: (context, item) => Text(item.id),
              totalCalculator: (items) => '',
              child: Builder(
                builder: (BuildContext context) {
                  // ACT: Try to find the controller.
                  FlyToCartController.of(context);
                  return const Text('Child Widget');
                },
              ),
            ),
          ),
        );

        // ASSERT: If no exception was thrown by `FlyToCartController.of(context)`, the test passes.
        expect(find.text('Child Widget'), findsOneWidget);
      });

  testWidgets('FloatingBasketView is not visible when basket is empty',
          (WidgetTester tester) async {
        // ARRANGE: Build the controller with empty state.
        await tester.pumpWidget(
          MaterialApp(
            home: FlyToCartController<MockCartItem>(
              basketItems: const [], // Empty basket
              processingItemIds: const {}, // No processing items
              onViewBasket: () {},
              basketItemBuilder: (context, item) => Text(item.id),
              totalCalculator: (items) => '\$0.00',
              child: const Scaffold(body: Text('My App')),
            ),
          ),
        );

        // ACT: Check the position of the floating basket. It should be off-screen.
        // We find it by its text content "View Basket".
        final basketFinder = find.text('View Basket');
        expect(basketFinder, findsOneWidget);

        // Get the Positioned widget that controls the basket's location.
        final positionedWidget = tester.widget<Positioned>(
          find.ancestor(
            of: basketFinder,
            matching: find.byType(Positioned),
          ),
        );

        // ASSERT: The 'bottom' property should be a negative value, meaning it's hidden.
        expect(positionedWidget.bottom, lessThan(0));
      });

  testWidgets('FloatingBasketView becomes visible when an item is added',
          (WidgetTester tester) async {
        // ARRANGE: Build the controller with empty state first.
        await tester.pumpWidget(
          MaterialApp(
            home: FlyToCartController<MockCartItem>(
              basketItems: const [], // Start empty
              onViewBasket: () {},
              basketItemBuilder: (context, item) => Text(item.id),
              totalCalculator: (items) => '\$10.00',
              child: const Scaffold(body: Text('My App')),
            ),
          ),
        );

        // ACT: Rebuild the widget with a non-empty list of basket items.
        await tester.pumpWidget(
          MaterialApp(
            home: FlyToCartController<MockCartItem>(
              basketItems: [MockCartItem('item1')], // Now has one item
              onViewBasket: () {},
              basketItemBuilder: (context, item) => Text(item.id),
              totalCalculator: (items) => '\$10.00',
              child: const Scaffold(body: Text('My App')),
            ),
          ),
        );

        // We need to wait for the animation to complete.
        await tester.pumpAndSettle();

        // ASSERT: Check the position again. It should now be visible.
        final basketFinder = find.text('View Basket');
        final positionedWidget = tester.widget<Positioned>(
          find.ancestor(
            of: basketFinder,
            matching: find.byType(Positioned),
          ),
        );

        // The 'bottom' property should now be a positive value (e.g., 20).
        expect(positionedWidget.bottom, greaterThanOrEqualTo(0));
      });

  testWidgets('FloatingBasketView shows processing indicator',
          (WidgetTester tester) async {
        // ARRANGE: Build the controller with a processing item ID.
        await tester.pumpWidget(
          MaterialApp(
            home: FlyToCartController<MockCartItem>(
              basketItems: const [],
              processingItemIds: const {'prod_1'}, // Item is processing
              onViewBasket: () {},
              basketItemBuilder: (context, item) => Text(item.id),
              totalCalculator: (items) => '\$0.00',
              child: const Scaffold(body: Text('My App')),
            ),
          ),
        );

        // ASSERT: The CircularProgressIndicator should be visible.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // The preview items (which would be built from basketItemBuilder) should not be present.
        expect(find.text('item1'), findsNothing);
      });
}