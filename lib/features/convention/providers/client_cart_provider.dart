import 'package:uuid/uuid.dart';
import '../../../core/models/client_cart.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/repositories/client_cart_repository.dart';

const uuid = Uuid();

// Simple providers (pas de Riverpod, juste des helpers)
class ClientCartProvider {
  final ClientCartRepository _cartRepository = ClientCartRepository();

  Future<List<ClientCart>> getCartsByConvention(String conventionId) {
    return _cartRepository.getCartsByConvention(conventionId);
  }

  Future<ClientCart> createNewCart(String conventionId) async {
    final cartNumber = await _cartRepository.getNextCartNumber(conventionId);
    final cart = ClientCart(
      id: uuid.v4(),
      conventionId: conventionId,
      cartNumber: cartNumber,
      createdAt: DateTime.now(),
    );
    await _cartRepository.createCart(cart);
    return cart;
  }

  Future<void> markCartAsPaid(String cartId) {
    return _cartRepository.markCartAsPaid(cartId);
  }

  Future<void> deleteCart(String cartId) {
    return _cartRepository.deleteCart(cartId);
  }
}

// Simple providers (pas de Riverpod, juste des helpers)
class CartItemProvider {
  final CartItemRepository _cartItemRepository = CartItemRepository();

  Future<List<CartItem>> getCartItems(String cartId) {
    return _cartItemRepository.getCartItems(cartId);
  }

  Future<void> addItem(CartItem item) {
    return _cartItemRepository.addItemToCart(item);
  }

  Future<void> updateQuantity(String cartItemId, int quantity) {
    return _cartItemRepository.updateItemQuantity(cartItemId, quantity);
  }

  Future<void> removeItem(String cartItemId) {
    return _cartItemRepository.removeItemFromCart(cartItemId);
  }
}


