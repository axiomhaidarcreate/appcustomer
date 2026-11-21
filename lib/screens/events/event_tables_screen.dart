import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import '../../theme/app_colors.dart';

class EventTablesScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventTablesScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<EventTablesScreen> createState() => _EventTablesScreenState();
}

class _EventTablesScreenState extends State<EventTablesScreen> {
  final DataController dataController = Get.find<DataController>();
  int? selectedTableId;
  int? selectedChairId;
  String selectedGender = 'ذكر';
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataController.fetchEventTables(widget.eventId);
    });
  }

  /// Check if ALL chairs in a table are booked
  bool _isTableFullyBooked(List chairs) {
    if (chairs.isEmpty) return false;
    for (var chair in chairs) {
      if (!dataController.bookedChairs.contains(chair['id'])) {
        return false; // At least one chair is available
      }
    }
    return true; // All chairs are booked
  }

  /// Count how many chairs are booked in a table
  int _bookedChairsCount(List chairs) {
    int count = 0;
    for (var chair in chairs) {
      if (dataController.bookedChairs.contains(chair['id'])) {
        count++;
      }
    }
    return count;
  }

  /// Show success dialog after booking
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'تم الإرسال بنجاح ✅',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'تم إرسال طلب الحجز إلى الاستقبال\nسيتم مراجعة طلبك وتأكيده',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Get.back(); // Return to events list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'حسناً',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز طاولات - ${widget.eventTitle}'),
      ),
      body: Obx(() {
        if (dataController.isLoading.value && dataController.eventTables.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (dataController.eventTables.isEmpty) {
          return const Center(child: Text('لا توجد طاولات متاحة في هذا القسم.'));
        }

        return Column(
          children: [
            // Legend
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('متاح', AppColors.primary),
                  _buildLegendItem('محجوز', Colors.red),
                  _buildLegendItem('محدد', Colors.green),
                ],
              ),
            ),
            // Gender/Section Selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('القسم:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedGender,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      items: const [
                        DropdownMenuItem(value: 'ذكر', child: Text('قسم الرجال')),
                        DropdownMenuItem(value: 'أنثى', child: Text('قسم العوائل')),
                      ],
                      onChanged: (value) {
                        setState(() => selectedGender = value!);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Tables List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dataController.eventTables.length,
                itemBuilder: (context, index) {
                  final table = dataController.eventTables[index];
                  final chairs = table['chairs'] ?? [];
                  final isFullyBooked = _isTableFullyBooked(chairs);
                  final bookedCount = _bookedChairsCount(chairs);
                  final totalChairs = chairs.length;

                  return Card(
                    key: ValueKey('card_${table['id']}'),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isFullyBooked ? Colors.red : (selectedTableId == table['id'] ? Colors.green : Colors.transparent),
                        width: 2,
                      ),
                    ),
                    color: isFullyBooked ? Colors.red.withOpacity(0.08) : null,
                    child: ExpansionTile(
                      key: PageStorageKey('table_${table['id']}'),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'طاولة ${table['number']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isFullyBooked ? Colors.red : null,
                              ),
                            ),
                          ),
                          if (isFullyBooked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'مكتملة',
                                style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        'الكراسي: $bookedCount محجوز من $totalChairs',
                        style: TextStyle(
                          color: isFullyBooked ? Colors.red.shade300 : AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      leading: Icon(
                        Icons.table_restaurant,
                        color: isFullyBooked ? Colors.red : AppColors.primary,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: chairs.map<Widget>((chair) {
                              final isBooked = dataController.bookedChairs.contains(chair['id']);
                              final isSelected = selectedChairId == chair['id'];

                              Color bgColor;
                              if (isBooked) {
                                bgColor = Colors.red.withOpacity(0.2);
                              } else if (isSelected) {
                                bgColor = Colors.green.withOpacity(0.2);
                              } else {
                                bgColor = AppColors.surface;
                              }

                              Color borderColor = isBooked 
                                  ? Colors.red 
                                  : isSelected ? Colors.green : AppColors.primary;

                              return InkWell(
                                onTap: isBooked ? null : () {
                                  setState(() {
                                    selectedTableId = table['id'];
                                    selectedChairId = chair['id'];
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    border: Border.all(color: borderColor, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chair, 
                                        size: 24, 
                                        color: isBooked ? Colors.red : AppColors.textLight
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${chair['number']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Selected Info + Book Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show selected table/chair info
                    if (selectedChairId != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Builder(builder: (context) {
                              // Find selected table & chair info
                              String tableNum = '?';
                              String chairNum = '?';
                              for (var table in dataController.eventTables) {
                                if (table['id'] == selectedTableId) {
                                  tableNum = '${table['number']}';
                                  for (var chair in (table['chairs'] ?? [])) {
                                    if (chair['id'] == selectedChairId) {
                                      chairNum = '${chair['number']}';
                                    }
                                  }
                                }
                              }
                              return Text(
                                'طاولة $tableNum - كرسي $chairNum',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (selectedChairId == null || _isBooking) ? null : () async {
                          setState(() => _isBooking = true);
                          bool success = await dataController.bookEvent(
                            widget.eventId, 
                            selectedGender, 
                            selectedTableId!, 
                            selectedChairId!
                          );
                          setState(() => _isBooking = false);
                          if (success) {
                            _showSuccessDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isBooking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'تأكيد الحجز',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
