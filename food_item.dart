class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
  });
}

List<FoodItem> sampleFoods = [
  FoodItem(id: '1', name: 'Cheese Burger', description: 'Juicy beef patty with melted cheese', price: 12.99, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400', category: 'Burgers'),
  FoodItem(id: '2', name: 'Double Smash Burger', description: 'Double patty with special sauce', price: 15.99, imageUrl: 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=400', category: 'Burgers'),
  FoodItem(id: '3', name: 'Mushroom Burger', description: 'Beef patty with sautéed mushrooms', price: 13.99, imageUrl: 'https://images.unsplash.com/photo-1683882330182-eb8f64d7231c?auto=format&fit=crop&w=400&q=80', category: 'Burgers'),

  FoodItem(id: '4', name: 'Pepperoni Pizza', description: 'Classic pizza with pepperoni', price: 15.99, imageUrl: 'https://images.unsplash.com/photo-1542282811-943ef1a977c3?auto=format&fit=crop&w=400&q=80', category: 'Pizza'),
  FoodItem(id: '5', name: 'BBQ Chicken Pizza', description: 'Smoky BBQ with grilled chicken', price: 17.99, imageUrl: 'https://images.unsplash.com/photo-1767065603670-d44bcdf1da5e?auto=format&fit=crop&w=400&q=80', category: 'Pizza'),
  FoodItem(id: '6', name: 'Margherita Pizza', description: 'Tomato sauce with fresh mozzarella', price: 14.99, imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400', category: 'Pizza'),
  FoodItem(id: '7', name: 'Veggie Pizza', description: 'Fresh vegetables on crispy crust', price: 13.99, imageUrl: 'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?w=400', category: 'Pizza'),

  FoodItem(id: '8', name: 'Chicken Wings', description: 'Crispy wings with choice of sauce', price: 10.99, imageUrl: 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=400', category: 'Chicken'),
  FoodItem(id: '9', name: 'Grilled Chicken', description: 'Tender grilled chicken breast', price: 13.99, imageUrl: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400', category: 'Chicken'),
  FoodItem(id: '10', name: 'Fried Chicken', description: 'Golden crispy fried chicken', price: 11.99, imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?w=400', category: 'Chicken'),
  FoodItem(id: '11', name: 'Chicken Sandwich', description: 'Crispy chicken with lettuce & mayo', price: 9.99, imageUrl: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400', category: 'Chicken'),

  FoodItem(id: '12', name: 'Caesar Salad', description: 'Fresh romaine with caesar dressing', price: 8.99, imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400', category: 'Salads'),
  FoodItem(id: '13', name: 'Greek Salad', description: 'Tomatoes, olives, feta cheese', price: 9.99, imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400', category: 'Salads'),
  FoodItem(id: '14', name: 'Avocado Salad', description: 'Fresh avocado with mixed greens', price: 10.99, imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400', category: 'Salads'),

  FoodItem(id: '15', name: 'Salmon Sushi', description: 'Fresh salmon nigiri sushi', price: 18.99, imageUrl: 'https://images.unsplash.com/photo-1553621042-f6e147245754?w=400', category: 'Sushi'),
  FoodItem(id: '16', name: 'Tuna Roll', description: 'Classic tuna maki roll', price: 14.99, imageUrl: 'https://images.unsplash.com/photo-1768326119762-20c2a9f5c1f2?auto=format&fit=crop&w=400&q=80', category: 'Sushi'),
  FoodItem(id: '17', name: 'Assorted Sushi Rolls', description: 'Fresh sushi rolls with avocado and seafood', price: 16.99, imageUrl: 'https://images.unsplash.com/photo-1563245370-cd55e7c95ff4?auto=format&fit=crop&w=400&q=80', category: 'Sushi'),

  FoodItem(id: '18', name: 'Chocolate Cake', description: 'Rich dark chocolate layer cake', price: 7.99, imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400', category: 'Desserts'),
  FoodItem(id: '19', name: 'Ice Cream Sundae', description: 'Vanilla ice cream with toppings', price: 6.99, imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400', category: 'Desserts'),
  FoodItem(id: '20', name: 'Cheesecake', description: 'Creamy New York style cheesecake', price: 8.99, imageUrl: 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=400', category: 'Desserts'),
  FoodItem(id: '21', name: 'Waffles', description: 'Fluffy waffles with maple syrup', price: 7.49, imageUrl: 'https://images.unsplash.com/photo-1562376552-0d160a2f238d?w=400', category: 'Desserts'),

  FoodItem(id: '22', name: 'Mango Smoothie', description: 'Fresh mango blended with yogurt', price: 5.99, imageUrl: 'https://www.cubesnjuliennes.com/wp-content/uploads/2021/04/Mango-Smoothie-2.jpg', category: 'Drinks'),
  FoodItem(id: '23', name: 'Iced Latte', description: 'Espresso with cold milk over ice', price: 4.99, imageUrl: 'https://images.unsplash.com/photo-1540620723565-7e32b1e40e94?auto=format&fit=crop&w=400&q=80', category: 'Drinks'),
  FoodItem(id: '24', name: 'Fresh Lemonade', description: 'Freshly squeezed lemonade', price: 3.99, imageUrl: 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=400', category: 'Drinks'),
];
