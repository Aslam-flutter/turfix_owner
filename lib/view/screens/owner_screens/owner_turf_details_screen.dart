import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix_owner/core/constants/app_fuctions.dart';
import 'package:turfix_owner/view/screens/owner_screens/edit_turf_screen.dart';
import 'package:turfix_owner/view/screens/owner_screens/manage_slots_screen.dart';
import 'package:turfix_owner/view_model/common_provider.dart';

class OwnerTurfDetailsScreen extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> turfDetail;
  const OwnerTurfDetailsScreen({super.key, required this.turfDetail});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommonProvider>();
    final data = turfDetail.data() ?? {};

    final turfName = data['turfName']?.toString() ?? 'Turf';
    final description = data['description']?.toString() ?? 'No description provided.';
    final location = data['location']?.toString() ?? 'Location not specified';
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
    final openingTime = data['openingTime']?.toString() ?? '06:00 AM';
    final closingTime = data['closingTime']?.toString() ?? '11:00 PM';
    final phoneNumber = data['phoneNumber']?.toString() ?? 'Not provided';
    final List<dynamic> sportTypes = data['sportTypes'] is List ? data['sportTypes'] : [];
    final List<dynamic> gameFormats = data['gameFormats'] is List ? data['gameFormats'] : [];
    final List<dynamic> facilities = data['facilities'] is List ? data['facilities'] : [];
    final List<dynamic> images = data['turfImages'] is List ? data['turfImages'] : [];
    final String imageUrl = images.isNotEmpty ? images.first.toString() : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  /// IMAGE
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 280,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 280,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.stadium, size: 72, color: Colors.white54),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 280,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.stadium, size: 72, color: Colors.white54),
                          ),
                  ),

                  /// GRADIENT
                  Container(
                    height: 280,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),

                  /// TOP BUTTONS
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          circleButton(Icons.arrow_back, () {
                            Navigator.pop(context);
                          }),
                          Row(
                            children: [
                              circleButton(Icons.edit_outlined, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditTurfScreen(turfDoc: turfDetail),
                                  ),
                                );
                              }),
                              const SizedBox(width: 10),
                              circleButton(Icons.share, () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Sharing $turfName...')),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// DETAILS
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turfName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              '($reviewCount reviews)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),

                            const Spacer(),

                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 18,
                            ),

                            const SizedBox(width: 4),

                            Flexible(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ManageSlotsPage(turfDoc: turfDetail),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Manage Slots",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff16A34A),
                            minimumSize: const Size.fromHeight(52),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditTurfScreen(turfDoc: turfDetail),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xff16A34A),
                          ),
                          label: const Text(
                            "Edit Details",
                            style: TextStyle(
                              color: Color(0xff16A34A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xff16A34A),
                              width: 1.5,
                            ),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// About Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About Turf",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                          maxLines: provider.isExpanded ? null : 4,
                          overflow: provider.isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          softWrap: true,
                        ),

                        if (description.length > 100) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              provider.isExpand();
                            },
                            child: Text(
                              provider.isExpanded ? "Show less" : "Read more",
                              style: const TextStyle(
                                color: Color(0xff16A34A),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (sportTypes.isNotEmpty) ...[
                    const Text(
                      "Sports Available",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: sportTypes.map((sport) {
                        final sportStr = sport.toString();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppFuctions.getSportIcon(sportStr),
                                size: 18,
                                color: const Color(0xff16A34A),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                sportStr,
                                style: const TextStyle(
                                  color: Color(0xff16A34A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (gameFormats.isNotEmpty) ...[
                    const Text(
                      "Game Formats",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: gameFormats.map((gameFormat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.group,
                                size: 18,
                                color: Color(0xff16A34A),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                gameFormat.toString(),
                                style: const TextStyle(
                                  color: Color(0xff16A34A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (facilities.isNotEmpty) ...[
                    const Text(
                      "Facilities",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        childAspectRatio: .85,
                      ),
                      itemCount: facilities.length,
                      itemBuilder: (context, index) {
                        final facility = facilities[index].toString();
                        return Column(
                          children: [
                            Icon(
                              AppFuctions.getFacilityIcon(facility),
                              color: const Color(0xff16A34A),
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              facility,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text(
                    "Operating Hours",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InfoItem(
                        icon: Icons.access_time_rounded,
                        title: "Open Time",
                        value: openingTime,
                      ),
                      const SizedBox(width: 12),
                      InfoItem(
                        icon: Icons.access_time_filled_rounded,
                        title: "Close Time",
                        value: closingTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Contact Number",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xff16A34A).withValues(alpha: .1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_outlined,
                          color: Color(0xff16A34A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        phoneNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget circleButton(IconData icon, GestureTapCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
