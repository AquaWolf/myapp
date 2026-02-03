import 'package:flutter/material.dart';

class AiRichDataCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AiRichDataCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF192233) : Colors.white;

    final trainId = data['trainId'] ?? 'Unbekannt';
    final route = data['route'] ?? 'Unbekannte Route';
    final delay = data['delayMinutes'] ?? 0;
    final status = data['status'] ?? 'ON TIME';
    final scheduled = data['scheduledTime'] ?? '--:--';
    final expected = data['expectedTime'] ?? '--:--';
    final platform = data['platformInfo'] ?? '-';

    final Color statusColor = delay > 0 ? Colors.red : Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF135BEC), Color(0xFF0A2E7A)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 12,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trainId,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                Text(route, style: TextStyle(color: Colors.grey[300], fontSize: 12)),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                              child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule, color: statusColor, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                delay > 0 ? '+$delay min Verspätung' : 'Pünktlich',
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Planmäßiger Halt', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  Text(scheduled, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Gleis', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  Text(platform, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
