import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../theme/app_colors.dart';

import 'create_order_screen.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});

  final OrderController controller = Get.put(OrderController());

  // === Colors matching staff board ===
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _goldLight = Color(0xFFe6c27a);
  static const Color _cardBg = Color(0xFF282828);
  static const Color _darkBg = Color(0xFF1a1a1a);
  static const Color _borderColor = Color(0xFF3a3a3a);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => CreateOrderScreen()),
        backgroundColor: _gold,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('طلب جديد',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    color: _gold,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 16),
                Text('جاري تحميل الطلبات...',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          );
        }

        final orders = controller.orders;
        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        // Separate active and past orders
        final activeOrders = orders
            .where((o) =>
                o['status'] == 'pending' ||
                o['status'] == 'prep' ||
                o['status'] == 'ready')
            .toList();
        final pastOrders = orders
            .where((o) =>
                o['status'] == 'delivered' ||
                o['status'] == 'completed' ||
                o['status'] == 'cancelled')
            .toList();

        return RefreshIndicator(
          onRefresh: controller.fetchOrders,
          color: _gold,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // === Summary Stats Row ===
              _buildStatsRow(orders),
              const SizedBox(height: 20),

              // === Active Orders Section ===
              if (activeOrders.isNotEmpty) ...[
                _buildSectionTitle('الطلبات النشطة', Icons.pending_actions, Colors.orange),
                const SizedBox(height: 12),
                ...activeOrders.map((o) => _buildOrderCard(o, isActive: true)),
                const SizedBox(height: 20),
              ],

              // === Past Orders Section ===
              _buildSectionTitle('الطلبات السابقة', Icons.history, Colors.grey),
              const SizedBox(height: 12),
              if (pastOrders.isEmpty)
                _buildEmptySection('لا توجد طلبات سابقة')
              else
                ...pastOrders.map((o) => _buildOrderCard(o, isActive: false)),

              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  // === Empty State ===
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(45),
            ),
            child: const Icon(Icons.receipt_long, size: 40, color: _gold),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد طلبات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _goldLight,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اضغط على "طلب جديد" لإنشاء أول طلب لك',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // === Stats Row (matching screenshot grid style) ===
  Widget _buildStatsRow(List orders) {
    int pending = orders.where((o) => o['status'] == 'pending').length;
    int prep = orders.where((o) => o['status'] == 'prep').length;
    int ready = orders.where((o) => o['status'] == 'ready').length;
    int done = orders
        .where(
            (o) => o['status'] == 'delivered' || o['status'] == 'completed')
        .length;

    return Row(
      children: [
        _buildStatCard('انتظار', pending, Colors.orange, Icons.hourglass_bottom),
        const SizedBox(width: 10),
        _buildStatCard('تحضير', prep, Colors.blue, Icons.local_fire_department),
        const SizedBox(width: 10),
        _buildStatCard('جاهز', ready, Colors.green, Icons.check_circle_outline),
        const SizedBox(width: 10),
        _buildStatCard('مكتمل', done, Colors.grey, Icons.done_all),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: count > 0 ? color.withValues(alpha: 0.4) : _borderColor,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: count > 0 ? color : Colors.grey, size: 20),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                color: count > 0 ? color : Colors.grey,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: count > 0 ? color.withValues(alpha: 0.8) : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Section Title ===
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: color.withValues(alpha: 0.2)),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ),
    );
  }

  // === Order Card (matching staff board style) ===
  Widget _buildOrderCard(dynamic order, {required bool isActive}) {
    // Time
    String timeAgo = '';
    if (order['created_at'] != null) {
      try {
        DateTime date = DateTime.parse(order['created_at']);
        final diff = DateTime.now().difference(date);
        if (diff.inMinutes < 1) {
          timeAgo = 'الآن';
        } else if (diff.inMinutes < 60) {
          timeAgo = 'منذ ${diff.inMinutes} د';
        } else if (diff.inHours < 24) {
          timeAgo = 'منذ ${diff.inHours} ساعة';
        } else {
          timeAgo = 'منذ ${diff.inDays} يوم';
        }
      } catch (_) {}
    }

    String statusText = _getStatusText(order['status']);
    Color statusColor = _getStatusColor(order['status']);
    IconData statusIcon = _getStatusIcon(order['status']);

    String kitchenLabel = _getKitchenLabel(order['target_kitchen']);
    Color kitchenColor = _getKitchenColor(order['target_kitchen']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? statusColor.withValues(alpha: 0.35) : _borderColor,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // === Header Row ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? statusColor.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.02),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                // Order ID badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${order['id']}',
                    style: const TextStyle(
                      color: _goldLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Item name
                Expanded(
                  child: Text(
                    '${order['quantity'] ?? 1}x ${order['shisha_type'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // === Content ===
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              children: [
                // Notes
                if (order['notes'] != null &&
                    order['notes'].toString().isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE040FB).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              const Color(0xFFE040FB).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.label_outline,
                            size: 14,
                            color: const Color(0xFFE040FB)
                                .withValues(alpha: 0.8)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order['notes'].toString(),
                            style: TextStyle(
                              color: const Color(0xFFE040FB)
                                  .withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Info chips row
                Row(
                  children: [
                    // Kitchen badge
                    if (order['target_kitchen'] != null &&
                        kitchenLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kitchenColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: kitchenColor.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          kitchenLabel,
                          style: TextStyle(
                            color: kitchenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),

                    if (order['target_kitchen'] != null)
                      const SizedBox(width: 8),

                    // Table badge
                    if (order['table_id'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.table_restaurant,
                                size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'طاولة ${order['table_id']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Time
                    if (timeAgo.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          // === Progress Steps (active only) ===
          if (isActive) _buildProgressBar(order['status']),
        ],
      ),
    );
  }

  // === Progress Bar ===
  Widget _buildProgressBar(String? status) {
    final steps = ['pending', 'prep', 'ready', 'delivered'];
    final labels = ['انتظار', 'تحضير', 'جاهز', 'تسليم'];
    int current = steps.indexOf(status ?? 'pending');
    if (current < 0) current = 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          bool isDone = i <= current;
          bool isLast = i == steps.length - 1;
          Color c = isDone ? _getStatusColor(steps[i]) : Colors.grey.withValues(alpha: 0.3);

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isDone ? c.withValues(alpha: 0.2) : Colors.transparent,
                        border: Border.all(color: c, width: isDone ? 2 : 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(
                                i == current
                                    ? _getStatusIcon(steps[i])
                                    : Icons.check,
                                size: 10,
                                color: c,
                              )
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                    color: c,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      labels[i],
                      style: TextStyle(
                        color: isDone ? c : Colors.grey.withValues(alpha: 0.4),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 14),
                      color: i < current
                          ? _getStatusColor(steps[i + 1]).withValues(alpha: 0.4)
                          : Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // === Helpers ===
  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'prep':
        return 'جاري التحضير';
      case 'ready':
        return 'جاهز';
      case 'delivered':
      case 'completed':
        return 'تم التسليم';
      case 'cancelled':
        return 'ملغي';
      default:
        return status ?? 'غير معروف';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'prep':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'delivered':
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_bottom;
      case 'prep':
        return Icons.local_fire_department;
      case 'ready':
        return Icons.check_circle;
      case 'delivered':
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  String _getKitchenLabel(String? kitchen) {
    switch (kitchen) {
      case 'shisha':
        return 'شيشة';
      case 'kitchen':
        return 'مطبخ';
      case 'bar':
        return 'بار';
      case 'grill':
        return 'مشويات';
      default:
        return kitchen ?? '';
    }
  }

  Color _getKitchenColor(String? kitchen) {
    switch (kitchen) {
      case 'shisha':
        return _gold;
      case 'kitchen':
        return const Color(0xFF4CAF50);
      case 'bar':
        return const Color(0xFF2196F3);
      case 'grill':
        return const Color(0xFFFF5722);
      default:
        return Colors.grey;
    }
  }
}
