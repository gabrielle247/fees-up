import 'package:flutter/material.dart';
import '../view_models/student_ledger_view_model.dart';

class DataTableUtil extends StatelessWidget {
  final List<MonthlySummaryEntry> entries;

  const DataTableUtil({required this.entries, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 1. Handle Empty State cleanly
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            const Text(
              "No transaction history found.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 2. The Table
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 20, // Increased spacing for breathing room
        horizontalMargin: 12,
        headingRowHeight: 48,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 64, // Allow taller rows for wrapping text if needed
        
        // Header Styling
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface.withAlpha(70),
          fontSize: 13,
        ),
        
        columns: const [
          DataColumn(
            label: Text("Month"),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                "Paid",
                textAlign: TextAlign.end,
              ),
            ),
            numeric: true, // Forces right alignment
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                "Status / Balance",
                textAlign: TextAlign.end,
              ),
            ),
            numeric: true,
          ),
        ],
        
        rows: entries.map((entry) {
          return DataRow(
            cells: [
              // Col 1: Date (Description)
              DataCell(
                Text(
                  entry.description, // e.g. "Nov 2025"
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),

              // Col 2: Total Paid
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "\$${entry.totalPaid.toStringAsFixed(2)}",
                    style: TextStyle(
                      // Dim the text if 0.00, highlight if they paid something
                      color: entry.totalPaid > 0 ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Col 3: Status (Color Coded)
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        entry.statusLabel, // e.g. "Overdue ($50.00)"
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: entry.statusColor, // ✅ Use VM Color directly
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}