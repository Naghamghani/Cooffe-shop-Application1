import 'package:flutter/material.dart';

void main() {
  runApp(CoffeeShopApp());
}

class CoffeeShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coffee Shop',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: CoffeeMenuScreen(),
    );
  }
}

class CoffeeMenuScreen extends StatefulWidget {
  @override
  _CoffeeMenuScreenState createState() => _CoffeeMenuScreenState();
}

class _CoffeeMenuScreenState extends State<CoffeeMenuScreen> {
  List<MenuItem> menuItems = [
    MenuItem(name: 'Espresso', price: 3.00),
    MenuItem(name: 'Cappuccino', price: 4.50),
    MenuItem(name: 'Latte', price: 4.00),
    MenuItem(name: 'Mocha', price: 4.75),
    MenuItem(name: 'Americano', price: 3.50),
  ];

  Map<MenuItem, int> cartItems = {};

  void addToCart(MenuItem item, int quantity) {
    setState(() {
      if (cartItems.containsKey(item)) {
        cartItems[item] = cartItems[item]! + quantity;
      } else {
        cartItems[item] = quantity;
      }
    });
  }

  void removeFromCart(MenuItem item) {
    setState(() {
      if (cartItems.containsKey(item) && cartItems[item]! > 1) {
        cartItems[item] = cartItems[item]! - 1;
      } else {
        cartItems.remove(item);
      }
    });
  }

  double get totalAmount {
    return cartItems.entries.fold(0, (sum, entry) => sum + entry.key.price * entry.value);
  }

  void showAddToCartDialog(MenuItem item) {
    int selectedQuantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Quantity for ${item.name}', style: TextStyle(fontFamily: 'Georgia', color: Colors.brown[700])),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Price: \$${item.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, color: Colors.brown[500])),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Colors.brown[700], size: 30),
                        onPressed: () {
                          if (selectedQuantity > 1) {
                            setState(() {
                              selectedQuantity--;
                            });
                          }
                        },
                      ),
                      Text('$selectedQuantity', style: TextStyle(fontSize: 24, fontFamily: 'Georgia', color: Colors.brown[700])),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: Colors.brown[700], size: 30),
                        onPressed: () {
                          setState(() {
                            selectedQuantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: Colors.brown[700])),
                ),
                TextButton(
                  onPressed: () {
                    addToCart(item, selectedQuantity);
                    Navigator.of(context).pop();
                  },
                  child: Text('Add to Cart', style: TextStyle(color: Colors.brown[700])),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Caffe Shop Menu', style: TextStyle(fontFamily: 'Georgia',fontWeight: FontWeight.bold , color: Colors.brown[700])),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.brown[700]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.brown[200]!)),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(Icons.local_cafe, color: Colors.brown[700], size: 40),
                    title: Text(item.name, style: TextStyle(fontSize: 20, fontFamily: 'Georgia', color: Colors.brown[700])),
                    subtitle: Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: Colors.brown[500])),
                    trailing: IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.brown[700], size: 30),
                      onPressed: () => showAddToCartDialog(item),
                    ),
                  ),
                );
              },
            ),
          ),
          OrderSummary(cartItems: cartItems, totalAmount: totalAmount, removeFromCart: removeFromCart),
        ],
      ),
    );
  }


}

class OrderSummary extends StatefulWidget {
  final Map<MenuItem, int> cartItems;
  final double totalAmount;
  final Function(MenuItem) removeFromCart;

  OrderSummary({required this.cartItems, required this.totalAmount, required this.removeFromCart});

  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  void _handleCheckout() {
    if (widget.cartItems.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Empty Cart'),
            content: Text('Please add items to your cart before checking out.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckoutScreen(totalAmount: widget.totalAmount)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.brown[100],
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Order:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[800])),
              Divider(color: Colors.brown, height: 20, thickness: 2),
              Table(
                columnWidths: {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Qty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Price', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(),
                    ],
                  ),
                  ...widget.cartItems.entries.map((entry) {
                    final item = entry.key;
                    final quantity = entry.value;
                    return TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(item.name, style: TextStyle(fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('$quantity', style: TextStyle(fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('\$${(item.price * quantity).toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => widget.removeFromCart(item),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              Divider(color: Colors.brown, height: 20, thickness: 2),
              Text('Total: \$${widget.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _handleCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,  // Set the text color to white
                  ),
                  child: Text('Checkout', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  final double totalAmount;

  CheckoutScreen({required this.totalAmount});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController tableNumberController = TextEditingController();

  void _placeOrder(BuildContext context) {
    final name = nameController.text.trim();
    final tableNumber = tableNumberController.text.trim();

    if (name.isEmpty || tableNumber.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Missing Information'),
            content: Text('Please enter both your name and table number to place the order.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Order Confirmed'),
            content: Text('Your order has been placed successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          color: Colors.brown[50],
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: tableNumberController,
                  decoration: InputDecoration(
                    labelText: 'Table Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _placeOrder(context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Place Order', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class MenuItem {
  final String name;
  final double price;

  MenuItem({required this.name, required this.price});
}