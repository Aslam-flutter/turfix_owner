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

class AddTurfScreen extends StatefulWidget {
  const AddTurfScreen({super.key});

  @override
  State<AddTurfScreen> createState() => _AddTurfScreenState();
}

class _AddTurfScreenState extends State<AddTurfScreen> {
  final _formKey = GlobalKey<FormState>();

  final turfNameCtr = TextEditingController();
  final descCtr = TextEditingController();
  final locationCtr = TextEditingController();
  final phoneNumberCtr = TextEditingController();

  static const primary = Color(0xff16A34A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SportsSelectingProvider>().resetAll();
      context.read<AddTurfProvider>().resetMedia();
    });
  }

  @override
  void dispose() {
    turfNameCtr.dispose();
    descCtr.dispose();
    locationCtr.dispose();
    phoneNumberCtr.dispose();
    super.dispose();
  }

  // Dialog to add a custom sport (e.g. Carrom, Snooker, Table Tennis)
  void _showAddCustomSportDialog(BuildContext context) {
    final customSportCtr = TextEditingController();
    final customPriceCtr = TextEditingController(text: '300');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: primary),
              SizedBox(width: 8),
              Text(
                "Add Custom Sport",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customSportCtr,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Sport / Game Name",
                  hintText: "e.g. Carrom, Snooker, Pickleball",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.sports, color: primary),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: customPriceCtr,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Default Hourly Rate (₹)",
                  hintText: "e.g. 300",
                  prefixText: "₹ ",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.currency_rupee, color: primary),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = customSportCtr.text.trim();
                final price = customPriceCtr.text.trim();
                if (name.isNotEmpty) {
                  context.read<SportsSelectingProvider>().addCustomSport(
                        name,
                        defaultPrice: price.isNotEmpty ? price : '300',
                      );
                  Navigator.pop(dialogCtx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Add Sport", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Dialog to add a custom format for a sport
  void _showAddFormatDialog(BuildContext context, String sportName) {
    final formatCtr = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            "Add Format for $sportName",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: formatCtr,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Format Name",
              hintText: "e.g. 6s, Futsal, Board Rental",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final format = formatCtr.text.trim();
                if (format.isNotEmpty) {
                  context
                      .read<SportsSelectingProvider>()
                      .addCustomFormatForSport(sportName, format);
                  Navigator.pop(dialogCtx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sportsProvider = context.watch<SportsSelectingProvider>();
    final addProvider = context.watch<AddTurfProvider>();
    final commonProvider = context.watch<CommonProvider>();
    final locationProvider = context.watch<GeoLocatorProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: const Text(
          "Add New Turf",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // SECTION 1: TURF MEDIA & PHOTOS
              // ==========================================
              _buildSectionCard(
                title: "Turf Photos (Upload 3)",
                icon: Icons.photo_camera_back_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HERO COVER PHOTO (SLOT 0)
                    _buildImagePickerSlot(
                      context: context,
                      provider: addProvider,
                      index: 0,
                      isCoverPhoto: true,
                      height: 140,
                    ),
                    const SizedBox(height: 12),
                    // GALLERY PHOTOS (SLOTS 1 & 2)
                    Row(
                      children: [
                        Expanded(
                          child: _buildImagePickerSlot(
                            context: context,
                            provider: addProvider,
                            index: 1,
                            isCoverPhoto: false,
                            height: 85,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildImagePickerSlot(
                            context: context,
                            provider: addProvider,
                            index: 2,
                            isCoverPhoto: false,
                            height: 85,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "* 1 cover photo + 2 gallery photos required (${addProvider.uploadedCount}/3 uploaded)",
                      style: TextStyle(
                        fontSize: 11,
                        color: addProvider.hasThreeImages
                            ? primary
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // SECTION 2: BASIC DETAILS
              // ==========================================
              _buildSectionCard(
                title: "Basic Information",
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    // TURF NAME
                    TextFormField(
                      controller: turfNameCtr,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter the turf name";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Turf Name *",
                        hintText: "e.g. Green Valley Arena",
                        prefixIcon: const Icon(Icons.stadium_outlined, color: primary),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // CONTACT PHONE
                    TextFormField(
                      controller: phoneNumberCtr,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter contact phone number";
                        }
                        if (value.trim().length < 8) {
                          return "Enter a valid phone number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Contact Phone Number *",
                        hintText: "e.g. 9876543210",
                        prefixIcon: const Icon(Icons.phone_outlined, color: primary),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // DESCRIPTION
                    TextFormField(
                      controller: descCtr,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Description (Optional)",
                        hintText: "Tell players about turf quality, turf size, rules...",
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.notes_outlined, color: primary),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // SECTION 3: LOCATION & ADDRESS
              // ==========================================
              _buildSectionCard(
                title: "Location & Address",
                icon: Icons.location_on_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: locationCtr,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter the turf address or location";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Turf Address *",
                        hintText: "Enter full address or landmark",
                        prefixIcon: const Icon(Icons.place_outlined, color: primary),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // AUTO-DETECT CURRENT LOCATION BUTTON
                    InkWell(
                      onTap: locationProvider.isLoading
                          ? null
                          : () async {
                              await locationProvider.getCurrentLocation(context);
                              if (locationProvider.address.isNotEmpty &&
                                  !locationProvider.address
                                      .contains('not found')) {
                                locationCtr.text = locationProvider.address;
                              }
                            },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (locationProvider.isLoading)
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primary,
                                ),
                              )
                            else
                              const Icon(Icons.my_location,
                                  size: 16, color: primary),
                            const SizedBox(width: 8),
                            Text(
                              locationProvider.isLoading
                                  ? "Detecting location..."
                                  : "Use Current GPS Location",
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (locationProvider.latitude != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "GPS Coordinates: ${locationProvider.latitude!.toStringAsFixed(4)}, ${locationProvider.longitude!.toStringAsFixed(4)}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // SECTION 4: SPORTS, PRICING & FORMATS
              // ==========================================
              _buildSectionCard(
                title: "Sports, Formats & Pricing",
                icon: Icons.sports_soccer_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Supported Sports",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Choose all sports available at this turf. Each selected sport can have its own hourly price and game formats.",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),

                    // SPORTS CHIPS
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...sportsProvider.sports.map((sport) {
                          return FilterChip(
                            selected: sport.isSelected,
                            label: Text(sport.name),
                            avatar: Icon(
                              sport.icon,
                              size: 16,
                              color: sport.isSelected ? Colors.white : primary,
                            ),
                            selectedColor: primary,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: sport.isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            side: BorderSide(
                              color: sport.isSelected ? primary : Colors.grey.shade300,
                            ),
                            onSelected: (_) {
                              sportsProvider.toggleSportByName(sport.name);
                            },
                          );
                        }),
                        // ADD OTHER SPORT BUTTON
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16, color: primary),
                          label: const Text("Other Sport"),
                          labelStyle: const TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          backgroundColor: primary.withValues(alpha: 0.08),
                          side: BorderSide(color: primary.withValues(alpha: 0.4)),
                          onPressed: () => _showAddCustomSportDialog(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // DYNAMIC PER-SPORT CONFIGURATION CARDS
                    if (sportsProvider.selectedSportsList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Please select at least one sport above to set its price and game formats.",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      const Text(
                        "Configure Per-Sport Rates & Formats",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...sportsProvider.selectedSportsList.map((sport) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primary.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor:
                                            primary.withValues(alpha: 0.15),
                                        child: Icon(sport.icon,
                                            size: 16, color: primary),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${sport.name} Settings",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (sport.isCustom)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 20, color: Colors.red),
                                      onPressed: () {
                                        sportsProvider
                                            .removeCustomSport(sport.name);
                                      },
                                      tooltip: "Remove custom sport",
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // PRICE INPUT FOR THIS SPORT
                              TextFormField(
                                controller: sport.priceController,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (!sport.isSelected) return null;
                                  final num = double.tryParse(val ?? '');
                                  if (num == null || num <= 0) {
                                    return "Enter hourly rate for ${sport.name}";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "${sport.name} Price Per Hour (₹) *",
                                  hintText: "e.g. 1200",
                                  prefixText: "₹ ",
                                  prefixStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // FORMAT CHIPS FOR THIS SPORT
                              Text(
                                "Available ${sport.name} Formats:",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  ...sport.availableFormats.map((format) {
                                    final isFormatSelected =
                                        sport.selectedFormats.contains(format);
                                    return FilterChip(
                                      selected: isFormatSelected,
                                      label: Text(format),
                                      selectedColor:
                                          primary.withValues(alpha: 0.15),
                                      checkmarkColor: primary,
                                      labelStyle: TextStyle(
                                        color: isFormatSelected
                                            ? primary
                                            : Colors.grey.shade800,
                                        fontWeight: isFormatSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                      side: BorderSide(
                                        color: isFormatSelected
                                            ? primary
                                            : Colors.grey.shade300,
                                      ),
                                      onSelected: (_) {
                                        sportsProvider.toggleFormatForSport(
                                          sport.name,
                                          format,
                                        );
                                      },
                                    );
                                  }),
                                  // ADD CUSTOM FORMAT BUTTON
                                  ActionChip(
                                    avatar: const Icon(Icons.add,
                                        size: 14, color: primary),
                                    label: const Text("+ Format"),
                                    labelStyle: const TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: primary.withValues(alpha: 0.4),
                                    ),
                                    onPressed: () => _showAddFormatDialog(
                                      context,
                                      sport.name,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // SECTION 5: OPERATING HOURS & SLOTS
              // ==========================================
              _buildSectionCard(
                title: "Operating Hours & Slots",
                icon: Icons.access_time_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // OPENING TIME
                        Expanded(
                          child: InkWell(
                            onTap: () => addProvider.selectOpeningTime(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Opening Time",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.wb_sunny_outlined,
                                          size: 16, color: Colors.orange),
                                      const SizedBox(width: 6),
                                      Text(
                                        addProvider.openigTime,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // CLOSING TIME
                        Expanded(
                          child: InkWell(
                            onTap: () => addProvider.selectClosingTime(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Closing Time",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.nightlight_outlined,
                                          size: 16, color: Colors.indigo),
                                      const SizedBox(width: 6),
                                      Text(
                                        addProvider.closingTime,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // ESTIMATED SLOTS HELPER PILL
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: addProvider.isClosingAfterOpening()
                            ? primary.withValues(alpha: 0.08)
                            : Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            addProvider.isClosingAfterOpening()
                                ? Icons.schedule_rounded
                                : Icons.error_outline,
                            size: 16,
                            color: addProvider.isClosingAfterOpening()
                                ? primary
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              addProvider.isClosingAfterOpening()
                                  ? "Will generate ${addProvider.getEstimatedDailySlots()} slots/day (${addProvider.openigTime} to ${addProvider.closingTime}) for next 7 days"
                                  : "Closing time must be after opening time!",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: addProvider.isClosingAfterOpening()
                                    ? primary
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // SECTION 6: FACILITIES & AMENITIES
              // ==========================================
              _buildSectionCard(
                title: "Facilities & Amenities",
                icon: Icons.checklist_rounded,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(sportsProvider.facilities.length,
                      (index) {
                    final facility = sportsProvider.facilities[index];
                    return FilterChip(
                      selected: facility.selected,
                      label: Text(facility.name),
                      avatar: Icon(
                        facility.icon,
                        size: 16,
                        color: facility.selected ? Colors.white : Colors.blue,
                      ),
                      selectedColor: Colors.blue.shade600,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: facility.selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: facility.selected
                            ? Colors.blue.shade600
                            : Colors.grey.shade300,
                      ),
                      onSelected: (_) {
                        sportsProvider.toggleFacilities(index);
                      },
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // BOTTOM SAVE BUTTON
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: commonProvider.isLoading
                ? null
                : () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in first')),
                      );
                      return;
                    }

                    // 1. Validate Form Fields
                    if (!_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please correct the errors in the form'),
                        ),
                      );
                      return;
                    }

                    // 2. Validate Photos
                    if (!addProvider.hasThreeImages) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please upload all 3 turf photos (1 cover + 2 gallery)',
                          ),
                        ),
                      );
                      return;
                    }

                    // 3. Validate Sports Selection
                    if (sportsProvider.selectedSports.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select at least one sport'),
                        ),
                      );
                      return;
                    }

                    // 4. Validate Per-Sport Rates & Formats
                    for (final sport in sportsProvider.selectedSportsList) {
                      final price = sport.price;
                      if (price == null || price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please enter a valid hourly rate for ${sport.name}',
                            ),
                          ),
                        );
                        return;
                      }

                      if (sport.selectedFormats.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select at least one format for ${sport.name}',
                            ),
                          ),
                        );
                        return;
                      }
                    }

                    // 5. Validate Operating Hours
                    if (!addProvider.isClosingAfterOpening()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Closing time must be after opening time',
                          ),
                        ),
                      );
                      return;
                    }

                    commonProvider.load(true);

                    try {
                      final openingFormatted =
                          addProvider.openigTime.contains(':')
                              ? addProvider
                                  .parseTime(addProvider.openigTime)
                                  .format(context)
                              : '06:00 AM';

                      final closingFormatted =
                          addProvider.closingTime.contains(':')
                              ? addProvider
                                  .parseTime(addProvider.closingTime)
                                  .format(context)
                              : '11:00 PM';

                      final basePrice = sportsProvider.minPricePerHour;

                      final TurfModel turfModel = TurfModel(
                        isVerified: 0,
                        ownerId: user.uid,
                        turfName: turfNameCtr.text.trim(),
                        description: descCtr.text.trim(),
                        location: locationCtr.text.trim(),
                        pricePerHour: basePrice,
                        openingTime: openingFormatted,
                        closingTime: closingFormatted,
                        phoneNumber: phoneNumberCtr.text.trim(),
                        turfImages: addProvider.uploadedImageUrls,
                        sportTypes: sportsProvider.selectedSports,
                        facilities: sportsProvider.selectedFacilities,
                        gameFomats: sportsProvider.selectedGameFormats,
                        sportsConfig: sportsProvider.sportsConfig,
                        isTurfActive: true,
                        bookingCount: 0,
                        rating: 0.00,
                        reviewCount: 0,
                        latitude: locationProvider.latitude,
                        longtitude: locationProvider.longitude,
                      );

                      final firestore = FirebaseFirestore.instance;
                      final turfRef = firestore.collection('turfs').doc();

                      await turfRef.set(turfModel.toJson());

                      // Generate 7-day initial booking slots
                      await addProvider.createTurfSlots(
                        turfId: turfRef.id,
                        openingTime: turfModel.openingTime,
                        closingTime: turfModel.closingTime,
                        pricePerHour: basePrice,
                      );

                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OwnerMainScreen(),
                          ),
                          (route) => false,
                        );
                        AppMessenger.customScaffoldMessenger(
                          context,
                          message: 'Turf added successfully!',
                          backgroundColor: Colors.green,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add turf: $e')),
                        );
                      }
                    } finally {
                      commonProvider.load(false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: commonProvider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "Save Turf",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER CARD CONTAINER WIDGET
  // ==========================================
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: primary),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ==========================================
  // HELPER IMAGE PICKER SLOT
  // ==========================================
  Widget _buildImagePickerSlot({
    required BuildContext context,
    required AddTurfProvider provider,
    required int index,
    required bool isCoverPhoto,
    required double height,
  }) {
    final imageFile = provider.selectedImages[index];
    final isUploading = provider.isUploading[index];
    final isUploaded = provider.imageUrls[index] != null;

    return GestureDetector(
      onTap: isUploading
          ? null
          : () {
              provider.pickAndUploadImage(index);
            },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded ? primary : Colors.grey.shade300,
            width: isUploaded ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            // IMAGE PREVIEW OR PLACEHOLDER
            if (imageFile != null)
              FutureBuilder(
                future: imageFile.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      snapshot.data!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCoverPhoto
                          ? Icons.add_photo_alternate_outlined
                          : Icons.add_a_photo_outlined,
                      color: Colors.grey.shade400,
                      size: isCoverPhoto ? 32 : 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCoverPhoto ? "Upload Main Cover Photo" : "Gallery Photo ${index + 1}",
                      style: TextStyle(
                        fontSize: isCoverPhoto ? 12 : 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // UPLOADING OVERLAY
            if (isUploading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Uploading...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // COVER PHOTO BADGE
            if (isCoverPhoto && imageFile != null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        "Cover Photo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // DELETE BUTTON
            if (imageFile != null && !isUploading)
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  onTap: () => provider.removeImage(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // UPLOADED SUCCESS BADGE
            if (isUploaded && !isUploading)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 10, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        "Uploaded",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
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
