import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix_owner/core/constants/app_fuctions.dart';
import 'package:turfix_owner/view/screens/owner_screens/manage_slots_screen.dart';
import 'package:turfix_owner/view_model/common_provider.dart';

class OwnerTurfDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> _turfDetail;
  const OwnerTurfDetailsScreen({super.key, required this._turfDetail});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommonProvider>();
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
                    child: Image.network(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10', // Your Image
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
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

                          circleButton(Icons.share, () {}),
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
                          _turfDetail['turfName'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
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
                                  Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    _turfDetail['rating'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              _turfDetail['reviewCount'].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),

                            const Spacer(),

                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),

                            const SizedBox(width: 5),

                            const Text(
                              "2.5 km",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
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
            SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Sport & Price
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xff16A34A),
                          ),
                          label: const Text(
                            "Edit",
                            style: TextStyle(
                              color: Color(0xff16A34A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            side: const BorderSide(
                              color: Color(0xff16A34A),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageSlotsPage(),
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
                            minimumSize: const Size.fromHeight(54),
                            elevation: 0,
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
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _turfDetail['description'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                          maxLines: provider.isExpanded ? null : 4,
                          overflow: provider.isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          softWrap: true,
                        ),

                        const SizedBox(height: 12),

                        InkWell(
                          onTap: () {
                            provider.isExpand();
                          },
                          child: const Text(
                            "Read more",
                            style: TextStyle(
                              color: Color(0xff16A34A),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Sports
                      const Text(
                        "Sports Available",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(
                          _turfDetail['sportTypes'].length,
                          (index) {
                            final sport = _turfDetail['sportTypes'][index];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
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
                                    AppFuctions.getSportIcon(sport),
                                    size: 20,
                                    color: const Color(0xff16A34A),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    sport,
                                    style: const TextStyle(
                                      color: Color(0xff16A34A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Game Formats",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(
                          _turfDetail['gameFormats'].length,
                          (index) {
                            final gameFormat =
                                _turfDetail['gameFormats'][index];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
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
                                    Icons.group,
                                    size: 20,
                                    color: const Color(0xff16A34A),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    gameFormat,
                                    style: const TextStyle(
                                      color: Color(0xff16A34A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Facilities
                      const Text(
                        "Facilities",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 16,
                          childAspectRatio: .8,
                        ),
                        itemCount: _turfDetail['facilities'].length,
                        itemBuilder: (context, index) {
                          final facility = _turfDetail['facilities'][index];
                          return Column(
                            children: [
                              Icon(
                                AppFuctions.getFacilityIcon(facility),
                                color: const Color(0xff16A34A),
                                size: 30,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                facility,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 12),
                      const Text(
                        "Time",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InfoItem(
                            icon: Icons.access_time_rounded,
                            title: "Open Time",
                            value: _turfDetail['openingTime'],
                          ),
                          SizedBox(width: 10),
                          InfoItem(
                            icon: Icons.access_time_filled_rounded,
                            title: "Close Time",
                            value: _turfDetail['closingTime'],
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      const Text(
                        "Contact Number",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
                              color: Color(0xff16A34A).withValues(alpha: .1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.call_outlined,
                              color: Color(0xff16A34A),
                              size: 26,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            _turfDetail['phoneNumber'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  Widget circleButton(IconData icon, GestureTapCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primary, size: 30),
            ),

            SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
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
