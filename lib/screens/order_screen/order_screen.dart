import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:grid_practice/helpers/login_helper.dart';
import 'package:grid_practice/helpers/order_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int userId = 0;
  List<Map<String, dynamic>> orders = [];
  bool isReceived = false;

  void initData() async {
    var pref = await SharedPreferences.getInstance();
    var username = pref.getString('username') ?? "";
    var data = await LoginHelper.getUserDetails(username);
    setState(() {
      userId = data?['user_id'] ?? 0;
    });
    getOrders();
  }

  void getOrders() async {
    var data = await OrderHelper.getAllOrders(userId);
    if (data.isEmpty) {
      return;
    }
    setState(() {
      orders = data;
    });
  }

  Future<double> getPrice(String invoiceId) async {
    var products = await OrderHelper.getOrderItems(invoiceId, userId);
    return products.fold(
      0,
      (previousValue, element) =>
          (previousValue as double) + (element['price'] * element['quantity']),
    );
  }

  @override
  void initState() {
    super.initState();
    initData(); // Start by getting the user ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text("My Orders"),
          ),
          const SliverPadding(padding: EdgeInsets.all(8)),
          SliverList.separated(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              bool isCompleted = order['status'] == 'complete';
              return Bounceable(
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                                child: FutureBuilder(
                              future: OrderHelper.getOrder(
                                  order['invoice_id'], userId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return const SizedBox.shrink();
                                }
                                var items = snapshot.data!['items'];
                                return ListView.separated(
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    var item = items[index];
                                    return Row(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: item['image_url'],
                                          height: 80,
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['product_name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  height: 1,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                item['description'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                '\$${item['price']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(
                                      height: 16,
                                    );
                                  },
                                  itemCount: items.length,
                                );
                              },
                            )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order['status'].toString().toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted
                                            ? Colors.green
                                            : Colors.amber,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('hh:mm a, dd MMM yyyy').format(
                                          DateTime.parse(order['date'])),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildButtonMark(
                                  status: order['status'].toString(),
                                  onTap: () async {
                                    await OrderHelper.updateOrderStatus(
                                        order['invoice_id'],
                                        'complete',
                                        userId);
                                    Navigator.pop(context);
                                    initData();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "#${order['invoice_id']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder(
                            future: getPrice(order['invoice_id']),
                            builder: (context, snapshot) => Text(
                              '\$${snapshot.data ?? 0}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('hh:mm a, dd MMM yyyy')
                                .format(DateTime.parse(order['date'])),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            order['status'].toString().toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.green : Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          color: const Color.fromARGB(255, 182, 182, 182)
                              .withOpacity(0.2),
                        ),
                      ),
                      FutureBuilder(
                        future:
                            OrderHelper.getOrder(order['invoice_id'], userId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const SizedBox.shrink();
                          }
                          var items = snapshot.data!['items'];
                          return SizedBox(
                            height: 50,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                var image = items[index]['image_url'];
                                return CachedNetworkImage(imageUrl: image);
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  width: 16,
                                );
                              },
                              itemCount: items.length,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 20,
            ),
          ),
        ],
      ),
    );
  }

  Bounceable _buildButtonMark(
      {void Function()? onTap, required String status}) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: status == 'complete'
            ? BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              )
            : BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black,
                ),
              ),
        child: Center(
          child: Text(
            status != 'complete' ? "Mark as Received" : "Completed",
            style: TextStyle(
              fontSize: 15,
              color: status == 'complete' ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
