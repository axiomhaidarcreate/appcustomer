import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import '../../controllers/order_controller.dart';

class CreateOrderController extends GetxController {
  final DataController dataController = Get.find<DataController>();
  final OrderController orderController = Get.find<OrderController>();
  
  var selectedCategory = RxnString();
  var cart = <Map<String, dynamic>>[].obs;
  var tableIdStr = ''.obs;
  var ticketBarcode = ''.obs;
  var ticketRemaining = Rxn<int>();
  var isSubmitting = false.obs;
  var orderMode = 'ticket'.obs; // 'ticket' or 'normal'

  List<Map<String, dynamic>> get categoryStats {
    List<Map<String, dynamic>> stats = [];
    for (var cat in dataController.categories) {
      if (cat['name'] != null) {
        int count = cat['product_count'] ?? 
          dataController.products.where((p) => p['category'] == cat['name']).length;
        stats.add({
          'name': cat['name'],
          'count': count,
        });
      }
    }
    return stats;
  }

  List get filteredProducts {
    if (selectedCategory.value == null) return [];
    return dataController.products.where((p) => p['category'] == selectedCategory.value).toList();
  }

  void clearCategory() {
    selectedCategory.value = null;
  }

  void addToCart(dynamic product, {int qty = 1, String notes = ''}) {
    int index = cart.indexWhere((item) => item['product_id'] == product['id'] && item['notes'] == notes);
    if (index != -1) {
      cart[index]['quantity'] += qty;
      cart.refresh();
    } else {
      cart.add({
        'product_id': product['id'],
        'name': product['name'],
        'quantity': qty,
        'notes': notes,
        'price': double.tryParse(product['price'].toString()) ?? 0,
        'targetKitchen': product['target_kitchen'] ?? 'kitchen',
      });
    }
    Get.snackbar('نجاح', 'تمت إضافة ${product['name']}', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white, duration: const Duration(seconds: 1));
  }

  void removeFromCart(int index) {
    cart.removeAt(index);
  }

  void updateQty(int index, int qty) {
    if (qty > 0) {
      cart[index]['quantity'] = qty;
      cart.refresh();
    } else {
      removeFromCart(index);
    }
  }
  
  void updateNotes(int index, String notes) {
    cart[index]['notes'] = notes;
    cart.refresh();
  }

  double get cartTotal {
    double total = 0;
    for (var item in cart) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }
    return total;
  }
  
  int get cartTotalItems {
    int total = 0;
    for (var item in cart) {
      total += (item['quantity'] as int);
    }
    return total;
  }

  Future<void> checkTicket() async {
    if (ticketBarcode.value.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى إدخال باركود التذكرة أولاً');
      return;
    }
    var ticketData = await orderController.checkTicket(ticketBarcode.value);
    if (ticketData != null) {
      ticketRemaining.value = ticketData['remaining'];
      Get.snackbar('تم التحقق', 'التذكرة صالحة ومتبقي لك ${ticketData['remaining']} طلبات', backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
    } else {
      ticketRemaining.value = null;
    }
  }

  Future<void> submitOrder() async {
    if (cart.isEmpty) {
      Get.snackbar('تنبيه', 'السلة فارغة');
      return;
    }
    
    if (orderMode.value == 'ticket' && ticketRemaining.value != null) {
      int totalItems = cartTotalItems;
      if (totalItems > ticketRemaining.value!) {
        Get.snackbar('تنبيه', 'عدد المنتجات يتجاوز رصيد التذكرة (${ticketRemaining.value} متبقي)', backgroundColor: Colors.orange.withValues(alpha: 0.8), colorText: Colors.white);
        return;
      }
    }

    Get.defaultDialog(
      title: 'تأكيد الطلب',
      middleText: 'هل أنت متأكد من إرسال الطلب للمطبخ؟\nإجمالي الأصناف: $cartTotalItems',
      textConfirm: 'تأكيد',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () async {
        Get.back(); // close dialog
        isSubmitting.value = true;
        int? tableId = int.tryParse(tableIdStr.value);
        List<Map<String, dynamic>> itemsPayload = cart.map((item) => {
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'notes': item['notes'],
        }).toList();

        String? barcode = orderMode.value == 'ticket' ? ticketBarcode.value : null;
        bool success = await orderController.createOrder(itemsPayload, tableId: tableId, ticketBarcode: barcode);
        isSubmitting.value = false;
        if (success) {
          cart.clear();
          ticketBarcode.value = '';
          ticketRemaining.value = null;
          Get.back(); // go back to orders list
        }
      },
    );
  }
}

class CreateOrderScreen extends StatelessWidget {
  CreateOrderScreen({super.key});
  
  final CreateOrderController controller = Get.put(CreateOrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a), // Dark background matching staff board
      appBar: AppBar(
        title: const Text('تقديم طلب - مطعم/مقهى', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF222222),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Mode Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(bottom: 16),
              child: Obx(() => Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.orderMode.value = 'ticket',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.orderMode.value == 'ticket' ? const Color(0xFFD4AF37) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: controller.orderMode.value == 'ticket' ? [
                            BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                          ] : [],
                        ),
                        child: Center(
                          child: Text(
                            'طلب حفلة (بتذكرة)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.orderMode.value == 'ticket' ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.orderMode.value = 'normal',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.orderMode.value == 'normal' ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: controller.orderMode.value == 'normal' ? [
                            BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                          ] : [],
                        ),
                        child: Center(
                          child: Text(
                            'طلب عادي (بدون تذكرة)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.orderMode.value == 'normal' ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),

            // Order Details Card
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تفاصيل الطاولة والتذكرة', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => controller.tableIdStr.value = val,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'رقم الطاولة (اختياري)',
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF1a1a1a),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.table_restaurant, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (controller.orderMode.value == 'ticket') {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (val) => controller.ticketBarcode.value = val,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'باركود التذكرة',
                                  labelStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: const Color(0xFF1a1a1a),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  prefixIcon: const Icon(Icons.qr_code_scanner, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => controller.checkTicket(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('تحقق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),

            // Cart Summary Card (Like staff board table)
            Obx(() {
              if (controller.cart.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD4AF37)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shopping_cart, color: Color(0xFFD4AF37), size: 18),
                              const SizedBox(width: 8),
                              Text('الأصناف المختارة (${controller.cart.length})', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                            ],
                          ),
                          if (controller.orderMode.value == 'ticket' && controller.ticketRemaining.value != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: controller.cartTotalItems > controller.ticketRemaining.value! ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'العدد: ${controller.cartTotalItems} / المسموح: ${controller.ticketRemaining.value}',
                                style: TextStyle(
                                  color: controller.cartTotalItems > controller.ticketRemaining.value! ? Colors.redAccent : Colors.greenAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.cart.length,
                      itemBuilder: (context, index) {
                        var item = controller.cart[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => controller.updateQty(index, (item['quantity'] as int) - 1),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.red.withValues(alpha: 0.3))),
                                            child: const Icon(Icons.remove, color: Colors.redAccent, size: 16),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text('${item['quantity']}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                                        ),
                                        GestureDetector(
                                          onTap: () => controller.updateQty(index, (item['quantity'] as int) + 1),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
                                            child: const Icon(Icons.add, color: Colors.green, size: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('${(item['price'] * item['quantity'])} ريال', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                  ),
                                  GestureDetector(
                                    onTap: () => controller.removeFromCart(index),
                                    child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                onChanged: (val) => controller.updateNotes(index, val),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'ملاحظات إضافية (اختياري)',
                                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                                  filled: true,
                                  fillColor: Colors.black26,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${controller.cartTotal} ريال', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isSubmitting.value ? null : () => controller.submitOrder(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        child: controller.isSubmitting.value 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('إرسال الطلب للمطبخ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      )),
                    )
                  ],
                ),
              );
            }),

            // Categories / Products Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a), // Using same as background instead of 0xFF282828 to match screenshot
              ),
              child: Obx(() {
                if (controller.selectedCategory.value == null) {
                  // Show Categories
                  var stats = controller.categoryStats;
                  if (stats.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('لا توجد أقسام', style: TextStyle(color: Colors.grey))),
                    );
                  }
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('اختر الأصناف', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('اختر التصنيف', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: stats.length,
                          itemBuilder: (context, index) {
                            var cat = stats[index];
                            String catName = cat['name'] ?? '';
                            
                            IconData catIcon = Icons.category;
                            Color catBorder = const Color(0xFF3a3a3a);
                            Color catBg = const Color(0xFF2A2A2A);
                            
                            if (catName == 'الشيشة' || catName == 'معسل' || catName == 'الشيش') {
                              catIcon = Icons.air;
                              catBorder = const Color(0xFFD4AF37);
                              catBg = const Color(0xFFD4AF37).withValues(alpha: 0.1);
                            } else if (catName == 'رؤوس الشيشة' || catName == 'رأس شيشة') {
                              catIcon = Icons.local_fire_department;
                              catBorder = const Color(0xFFFF9800);
                              catBg = const Color(0xFFFF9800).withValues(alpha: 0.1);
                            } else if (catName == 'طبقات إضافية') {
                              catIcon = Icons.layers;
                              catBorder = const Color(0xFFE91E63);
                              catBg = const Color(0xFFE91E63).withValues(alpha: 0.1);
                            } else if (catName == 'مشروبات') {
                              catIcon = Icons.local_cafe;
                              catBorder = const Color(0xFF2196F3);
                              catBg = const Color(0xFF2196F3).withValues(alpha: 0.1);
                            } else if (catName == 'مستلزمات') {
                              catIcon = Icons.build;
                              catBorder = const Color(0xFF9C27B0);
                              catBg = const Color(0xFF9C27B0).withValues(alpha: 0.1);
                            }

                            return GestureDetector(
                              onTap: () => controller.selectedCategory.value = catName,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: catBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: catBorder,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(catIcon, color: catBorder, size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      catName,
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.2),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${cat['count']} صنف', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show Products
                  var products = controller.filteredProducts;
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('أصناف: ${controller.selectedCategory.value}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: () => controller.clearCategory(),
                              icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                              label: const Text('رجوع للتصنيفات', style: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (products.isEmpty)
                          const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('لا توجد منتجات', style: TextStyle(color: Colors.grey)))),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            var product = products[index];
                            String catName = controller.selectedCategory.value ?? '';
                            bool isShisha = catName == 'الشيشة' || catName == 'معسل' || catName == 'الشيش';

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () => controller.addToCart(product),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.horizontal(right: const Radius.circular(12), left: Radius.circular(isShisha ? 0 : 12)),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 24),
                                          const SizedBox(height: 4),
                                          Text(
                                            product['name'] ?? '',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${product['price'] ?? 0} ر.ي',
                                            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (isShisha)
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        var headProduct = Map<String, dynamic>.from(product);
                                        headProduct['name'] = '${product['name']} (رأس فقط)';
                                        controller.addToCart(headProduct);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                          border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'رأس\nفقط',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
