import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReportService {
  /// Generate the PDF document bytes
  static Future<Uint8List> generateBookingsPdf({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> bookings,
    String filterLabel = 'All Bookings',
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();

    // Summary calculations
    double totalRevenue = 0.0;
    int confirmedCount = 0;
    int completedCount = 0;
    int cancelledCount = 0;

    for (final b in bookings) {
      final data = b.data();
      final status = (data['status']?.toString() ?? '').toLowerCase();
      final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

      if (status == 'cancelled') {
        cancelledCount++;
      } else {
        totalRevenue += amount;
        if (status == 'completed') {
          completedCount++;
        } else {
          confirmedCount++;
        }
      }
    }

    final generatedOn =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    // Primary Colors
    final primaryColor = PdfColor.fromHex('#16A34A');
    final darkColor = PdfColor.fromHex('#111827');
    final greyColor = PdfColor.fromHex('#6B7280');
    final lightGrey = PdfColor.fromHex('#F3F4F6');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(28),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TURFIX PARTNER REPORT',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Bookings Summary & Financial Overview',
                        style: pw.TextStyle(color: greyColor, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: lightGrey,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Filter: $filterLabel',
                          style: pw.TextStyle(
                            color: darkColor,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Date: $generatedOn',
                          style: pw.TextStyle(color: greyColor, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: primaryColor, thickness: 1.5),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Turfix Partner Portal • Confidential Report',
                  style: pw.TextStyle(color: greyColor, fontSize: 9),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(
                    color: greyColor,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        build: (context) {
          return [
            // KPI Summary Cards
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightGrey,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildKpiCard(
                    title: 'Total Records',
                    value: '${bookings.length}',
                    color: darkColor,
                  ),
                  _buildKpiCard(
                    title: 'Gross Revenue',
                    value: 'Rs. ${totalRevenue.toStringAsFixed(0)}',
                    color: primaryColor,
                  ),
                  _buildKpiCard(
                    title: 'Confirmed / Active',
                    value: '$confirmedCount',
                    color: PdfColor.fromHex('#2563EB'),
                  ),
                  _buildKpiCard(
                    title: 'Cancelled',
                    value: '$cancelledCount',
                    color: PdfColor.fromHex('#DC2626'),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            pw.Text(
              'Detailed Bookings (${bookings.length})',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: darkColor,
              ),
            ),

            pw.SizedBox(height: 8),

            // Bookings Table
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.5,
              ),
              columnWidths: const {
                0: pw.FixedColumnWidth(42), // #ID
                1: pw.FlexColumnWidth(2.0), // Customer
                2: pw.FlexColumnWidth(1.4), // Sport
                3: pw.FlexColumnWidth(2.0), // Date & Time
                4: pw.FixedColumnWidth(42), // Duration
                5: pw.FixedColumnWidth(55), // Amount
                6: pw.FixedColumnWidth(55), // Status
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: darkColor),
                  children: [
                    _buildTableCell('#ID', isHeader: true),
                    _buildTableCell('Customer', isHeader: true),
                    _buildTableCell('Sport', isHeader: true),
                    _buildTableCell('Date & Slot', isHeader: true),
                    _buildTableCell('Hours',
                        isHeader: true, align: pw.TextAlign.center),
                    _buildTableCell('Amount',
                        isHeader: true, align: pw.TextAlign.right),
                    _buildTableCell('Status',
                        isHeader: true, align: pw.TextAlign.center),
                  ],
                ),

                // Table Rows
                ...bookings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final doc = entry.value;
                  final data = doc.data();

                  final bookingId = (data['bookingId']?.toString() ?? doc.id);
                  final shortId = bookingId.length > 6
                      ? bookingId.substring(bookingId.length - 6).toUpperCase()
                      : bookingId.toUpperCase();

                  final customerName =
                      data['customerName']?.toString() ?? 'Customer';
                  final sport = data['sport']?.toString() ?? 'Football';
                  final date = data['date']?.toString() ?? '';

                  String timeSlot = '';
                  if (data['startAt'] is Timestamp) {
                    final start = (data['startAt'] as Timestamp).toDate();
                    timeSlot = DateFormat('hh:mm a').format(start);
                    if (data['endAt'] is Timestamp) {
                      final end = (data['endAt'] as Timestamp).toDate();
                      timeSlot += ' - ${DateFormat('hh:mm a').format(end)}';
                    }
                  }

                  final duration = '${data['duration'] ?? 1}h';
                  final amount =
                      (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
                  final status = data['status']?.toString() ?? 'Confirmed';

                  final isEven = index % 2 == 0;
                  final rowColor =
                      isEven ? PdfColors.white : PdfColor.fromHex('#F9FAFB');

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: rowColor),
                    children: [
                      _buildTableCell('#$shortId', fontSize: 8),
                      _buildTableCell(customerName, fontSize: 8, isBold: true),
                      _buildTableCell(sport, fontSize: 8),
                      _buildTableCell(
                        date.isNotEmpty ? '$date\n$timeSlot' : timeSlot,
                        fontSize: 7.5,
                      ),
                      _buildTableCell(duration,
                          fontSize: 8, align: pw.TextAlign.center),
                      _buildTableCell('Rs. ${amount.toStringAsFixed(0)}',
                          fontSize: 8,
                          isBold: true,
                          align: pw.TextAlign.right),
                      _buildStatusCell(status),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildKpiCard({
    required String title,
    required String value,
    required PdfColor color,
  }) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            color: color,
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          title,
          style: pw.TextStyle(
            color: PdfColor.fromHex('#6B7280'),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
    double fontSize = 8.5,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          color: isHeader ? PdfColors.white : PdfColor.fromHex('#111827'),
          fontWeight:
              (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 8.5 : fontSize,
        ),
      ),
    );
  }

  static pw.Widget _buildStatusCell(String status) {
    PdfColor color;
    switch (status.toLowerCase()) {
      case 'cancelled':
        color = PdfColor.fromHex('#DC2626');
        break;
      case 'completed':
        color = PdfColor.fromHex('#6B7280');
        break;
      case 'playing':
        color = PdfColor.fromHex('#16A34A');
        break;
      default:
        color = PdfColor.fromHex('#D97706'); // Orange for confirmed
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(
        status.toUpperCase(),
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: color,
          fontWeight: pw.FontWeight.bold,
          fontSize: 7.5,
        ),
      ),
    );
  }

  /// Trigger native download / share sheet with the generated PDF
  static Future<void> downloadOrSharePdf({
    required BuildContext context,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> bookings,
    String filterLabel = 'All Bookings',
  }) async {
    try {
      final bytes = await generateBookingsPdf(
        bookings: bookings,
        filterLabel: filterLabel,
      );

      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final filename = 'Turfix_Bookings_Report_$dateStr.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open full-screen print & save as PDF preview dialog
  static Future<void> previewAndPrintPdf({
    required BuildContext context,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> bookings,
    String filterLabel = 'All Bookings',
  }) async {
    try {
      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final filename = 'Turfix_Bookings_Report_$dateStr.pdf';

      await Printing.layoutPdf(
        name: filename,
        onLayout: (pageFormat) => generateBookingsPdf(
          bookings: bookings,
          filterLabel: filterLabel,
          pageFormat: pageFormat,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open PDF preview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generate a single booking receipt PDF document
  static Future<Uint8List> generateSingleReceiptPdf({
    required DocumentSnapshot<Map<String, dynamic>> bookingDoc,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    final data = bookingDoc.data() ?? {};

    final rawBookingId = data['bookingId']?.toString() ?? bookingDoc.id;
    final bookingId = rawBookingId.toUpperCase();
    final customerName = data['customerName']?.toString() ?? 'Customer';
    final customerPhone = data['customerPhone']?.toString() ??
        data['phone']?.toString() ??
        data['userPhone']?.toString() ??
        'N/A';
    final turfName = data['turfName']?.toString() ?? 'Turf Ground';
    final location = data['turfLocation']?.toString() ??
        data['location']?.toString() ??
        '';
    final sport = data['sport']?.toString() ?? 'Football';
    final format =
        data['gameFormat']?.toString() ?? data['format']?.toString() ?? '';
    final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final status = data['status']?.toString() ?? 'Confirmed';
    final paymentMethod = data['paymentMethod']?.toString() ?? 'Venue';

    String dateStr = data['date']?.toString() ?? '';
    String timeStr = 'N/A';
    if (data['startAt'] is Timestamp) {
      final start = (data['startAt'] as Timestamp).toDate();
      timeStr = DateFormat('hh:mm a').format(start);
      if (dateStr.isEmpty) {
        dateStr = DateFormat('dd MMMM yyyy').format(start);
      }
      if (data['endAt'] is Timestamp) {
        final end = (data['endAt'] as Timestamp).toDate();
        timeStr += ' - ${DateFormat('hh:mm a').format(end)}';
      }
    }

    final duration = '${data['duration'] ?? 1} Hour(s)';
    final generatedOn =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    final primaryColor = PdfColor.fromHex('#16A34A');
    final darkColor = PdfColor.fromHex('#111827');
    final greyColor = PdfColor.fromHex('#6B7280');
    final lightGrey = PdfColor.fromHex('#F9FAFB');

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Top Brand Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TURFIX',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Official Booking Receipt',
                        style: pw.TextStyle(color: greyColor, fontSize: 11),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F0FDF4'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: primaryColor, width: 0.5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'BOOKING #$bookingId',
                          style: pw.TextStyle(
                            color: primaryColor,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Issued: $generatedOn',
                          style: pw.TextStyle(color: greyColor, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 14),
              pw.Divider(color: primaryColor, thickness: 1.5),
              pw.SizedBox(height: 14),

              // Venue & Customer Box
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: lightGrey,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'VENUE DETAILS',
                            style: pw.TextStyle(
                              color: greyColor,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            turfName,
                            style: pw.TextStyle(
                              color: darkColor,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (location.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              location,
                              style: pw.TextStyle(color: greyColor, fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'CUSTOMER DETAILS',
                            style: pw.TextStyle(
                              color: greyColor,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            customerName,
                            style: pw.TextStyle(
                              color: darkColor,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Phone: $customerPhone',
                            style: pw.TextStyle(color: greyColor, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Reservation Summary Section
              pw.Text(
                'Reservation Breakdown',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: darkColor,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(4),
                },
                children: [
                  _buildReceiptRow('Sport / Activity',
                      format.isNotEmpty ? '$sport ($format)' : sport),
                  _buildReceiptRow('Booking Date', dateStr),
                  _buildReceiptRow('Time Slot', timeStr),
                  _buildReceiptRow('Duration', duration),
                  _buildReceiptRow('Payment Mode', paymentMethod),
                  _buildReceiptRow('Booking Status', status.toUpperCase(),
                      isStatus: true, statusText: status),
                ],
              ),

              pw.SizedBox(height: 20),

              // Total Amount Card
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F0FDF4'),
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: primaryColor, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Amount',
                          style: pw.TextStyle(
                            color: darkColor,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Tax & facility charges included',
                          style: pw.TextStyle(color: greyColor, fontSize: 9),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Rs. ${amount.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer Note
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(top: 14),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for booking with Turfix!',
                      style: pw.TextStyle(
                        color: darkColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'For support or queries, contact the turf management or visit our app.',
                      style: pw.TextStyle(color: greyColor, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildReceiptRow(
    String label,
    String value, {
    bool isStatus = false,
    String statusText = '',
  }) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#4B5563'),
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: isStatus
              ? _buildStatusCell(statusText)
              : pw.Text(
                  value,
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#111827'),
                    fontSize: 10,
                  ),
                ),
        ),
      ],
    );
  }

  /// Download or share a single booking receipt PDF
  static Future<void> downloadSingleBookingReceipt({
    required BuildContext context,
    required DocumentSnapshot<Map<String, dynamic>> bookingDoc,
  }) async {
    try {
      final bytes = await generateSingleReceiptPdf(bookingDoc: bookingDoc);
      final bookingId = bookingDoc.id;
      final filename = 'Turfix_Receipt_$bookingId.pdf';

      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate receipt PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
