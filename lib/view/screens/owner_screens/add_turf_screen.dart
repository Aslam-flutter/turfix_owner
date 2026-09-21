import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix_owner/model/turf_model.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_main_screen.dart';
import 'package:turfix_owner/view_model/add_turf_provider.dart';
import 'package:turfix_owner/view_model/common_provider.dart';
import 'package:turfix_owner/view_model/geo_locator_provider.dart';
import 'package:turfix_owner/view_model/sports_selecting_provider.dart';
import 'package:turfix_owner/widgets/scaffold_messanger.dart';

class AddTurfScreen extends StatelessWidget {
  AddTurfScreen({super.key});
  final turfNameCtr = TextEditingController();
  final descCtr = TextEditingController();
  final locationCtr = TextEditingController();
  final priceCtr = TextEditingController();
  // final closingTimeCtr = TextEditingController();
  final phoneNumberCtr = TextEditingController();
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);
    final addturfProvider = context.watch<SportsSelectingProvider>();
    final provider = context.watch<CommonProvider>();
    final addProvider = context.watch<AddTurfProvider>();
    final locationProvider = context.watch<GeoLocatorProvider>();
    locationCtr.text = locationProvider.address;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: const Text(
          "Add New Turf",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Turf Images",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Row(
            //   children: const [
            //     Expanded(child: UploadImageBox()),
            //     SizedBox(width: 12),
            //     Expanded(child: UploadImageBox()),
            //     SizedBox(width: 12),
            //     Expanded(child: UploadImageBox()),
            //   ],
            // ),
            Consumer<AddTurfProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: List.generate(3, (index) {
                    final image = provider.selectedImages[index];

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                        child: GestureDetector(
                          onTap: () {
                            provider.pickAndUploadImage(index);
                          },
                          child: Container(
                            height: 62,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: image == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Upload',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : FutureBuilder(
                                    future: image.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        );
                                      }

                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(
                                          snapshot.data!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              "Turf Name",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: turfNameCtr,
              decoration: InputDecoration(
                hintText: 'Enter turf name',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xff16A34A), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: descCtr,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter description',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xff16A34A), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: locationCtr,
              readOnly: true,
              decoration: InputDecoration(
                // hintText: 'select location on map',
                helperText: '* Please make sure you are at the turf location.',
                helperStyle: TextStyle(color: Colors.red),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    locationProvider.getCurrentLocation();
                  },
                  icon: locationProvider.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: primary),
                        )
                      : Icon(Icons.location_on),
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xff16A34A), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Sport Type",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Consumer<SportsSelectingProvider>(
              builder: (_, provider, _) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(provider.sports.length, (index) {
                    final sport = provider.sports[index];

                    return FilterChip(
                      selected: sport.selected,
                      label: Text(sport.name),
                      avatar: Icon(
                        sport.icon,
                        size: 18,
                        color: sport.selected
                            ? Colors.white
                            : const Color(0xff16A34A),
                      ),
                      selectedColor: const Color(0xff16A34A),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: sport.selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      side: const BorderSide(color: Color(0xff16A34A)),
                      onSelected: (_) {
                        provider.toggleSport(index);
                      },
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text(
              "Available Game Formats",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),
            Consumer<SportsSelectingProvider>(
              builder: (_, provider, _) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(provider.gameFormats.length, (index) {
                    final gameType = provider.gameFormats[index];

                    return FilterChip(
                      selected: gameType.selected,
                      label: Text(gameType.name),
                      avatar: Icon(
                        gameType.icon,
                        size: 18,
                        color: gameType.selected
                            ? Colors.white
                            : const Color(0xff7C3AED),
                      ),
                      selectedColor: const Color(0xff7C3AED),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: gameType.selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      side: const BorderSide(color: Color(0xff7C3AED)),
                      onSelected: (_) {
                        provider.toggleGameFormats(index);
                      },
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 20),

            const Text(
              "Facilites",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),
            Consumer<SportsSelectingProvider>(
              builder: (context, provider, child) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(provider.facilities.length, (index) {
                    final facility = provider.facilities[index];

                    return FilterChip(
                      selected: facility.selected,
                      label: Text(facility.name),
                      avatar: Icon(
                        facility.icon,
                        size: 18,
                        color: facility.selected
                            ? Colors.white
                            : const Color(0xff2563EB),
                      ),
                      selectedColor: const Color(0xff2563EB),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: facility.selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      side: const BorderSide(color: Color(0xff2563EB)),
                      onSelected: (_) {
                        provider.toggleFacilities(index);
                      },
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Price Per Hour",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: priceCtr,
              decoration: InputDecoration(
                hintText: "₹ Enter price",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xff16A34A), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Opening Time",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            CustomTextField(
              onTap: () {
                addProvider.selectOpeningTime(context);
              },
              hint: addProvider.openigTime,
              suffixIcon: Icons.access_time,
            ),

            const SizedBox(height: 20),

            const Text(
              "Closing Time",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            CustomTextField(
              onTap: () {
                addProvider.selectClosingTime(context);
              },
              hint: addProvider.closingTime,
              suffixIcon: Icons.access_time,
            ),

            const SizedBox(height: 20),

            const Text(
              "Phone Number",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: phoneNumberCtr,
              decoration: InputDecoration(
                hintText: 'Enter contact number',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),

                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xff16A34A), width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () async {
              provider.load(true);
              final providerr = context.read<AddTurfProvider>();

              if (!providerr.hasThreeImages) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please upload all 3 turf images'),
                  ),
                );

                return;
              }
              TurfModel turfModel = TurfModel(
                ownerId: FirebaseAuth.instance.currentUser!.uid,
                turfName: turfNameCtr.text.trim(),
                description: descCtr.text.trim(),
                location: locationCtr.text.trim(),
                pricePerHour: double.parse(priceCtr.text.trim()),
                openingTime: addProvider
                    .parseTime(addProvider.openigTime)
                    .format(context),

                closingTime: addProvider
                    .parseTime(addProvider.closingTime)
                    .format(context),

                phoneNumber: phoneNumberCtr.text.trim(),
                turfImages: providerr.uploadedImageUrls,
                sportTypes: addturfProvider.selectedSports,
                facilities: addturfProvider.selectedFacilities,
                gameFomats: addturfProvider.selectedGameFormats,
                isTurfActive: true,
                bookingCount: 0,
                rating: 0.00,
                reviewCount: 0,
                latitude: locationProvider.latitude,
                longtitude: locationProvider.longitude,
              );

              //////////////////////////////////////////////////////////////////
              final firestore = FirebaseFirestore.instance;

              final turfRef = firestore.collection('turfs').doc();

              await turfRef.set(turfModel.toJson());

              await addProvider.createTurfSlots(
                turfId: turfRef.id,
                openingTime: turfModel.openingTime,
                closingTime: turfModel.closingTime,
                pricePerHour: turfModel.pricePerHour,
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => OwnerMainScreen()),
                (route) => false,
              );
              AppMessenger.customScaffoldMessenger(
                context,
                message: 'Turf added successfully',
                backgroundColor: Colors.green,
              );

              ///////////////////////////////////////////////////////////////////
              provider.load(false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: provider.isLoading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text(
                    "Save Turf",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// class UploadImageBox extends StatelessWidget {
//   const UploadImageBox({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AddTurfProvider>();
//     return InkWell(
//       onTap: () {
//         provider.pickAndUploadImages(context);
//       },
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.add_a_photo_outlined,
//               size: 28,
//               color: Colors.grey.shade600,
//             ),

//             const SizedBox(height: 8),

//             Text(
//               "Upload",
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  const CustomTextField({
    super.key,
    required this.hint,
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,

        suffixIcon: suffixIcon == null
            ? null
            : Icon(suffixIcon, color: const Color(0xff16A34A)),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xff16A34A), width: 2),
        ),
      ),
    );
  }
}
