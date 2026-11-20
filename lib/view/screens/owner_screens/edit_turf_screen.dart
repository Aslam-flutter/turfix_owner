import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTurfScreen extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> turfDoc;

  const EditTurfScreen({super.key, required this.turfDoc});

  @override
  State<EditTurfScreen> createState() => _EditTurfScreenState();
}

class _EditTurfScreenState extends State<EditTurfScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _phoneController;

  late String _openingTime;
  late String _closingTime;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.turfDoc.data() ?? {};

    _nameController = TextEditingController(text: data['turfName']?.toString() ?? '');
    _descController = TextEditingController(text: data['description']?.toString() ?? '');
    _locationController = TextEditingController(text: data['location']?.toString() ?? '');
    _priceController = TextEditingController(
      text: (data['pricePerHour'] as num?)?.toStringAsFixed(0) ?? '1000',
    );
    _phoneController = TextEditingController(text: data['phoneNumber']?.toString() ?? '');

    _openingTime = data['openingTime']?.toString() ?? '06:00 AM';
    _closingTime = data['closingTime']?.toString() ?? '11:00 PM';
    _isActive = data['isTurfActive'] == true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked.format(context);
        } else {
          _closingTime = picked.format(context);
        }
      });
    }
  }

  Future<void> _saveTurf() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price per hour')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.turfDoc.reference.update({
        'turfName': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'location': _locationController.text.trim(),
        'pricePerHour': price,
        'phoneNumber': _phoneController.text.trim(),
        'openingTime': _openingTime,
        'closingTime': _closingTime,
        'isTurfActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turf updated successfully'),
            backgroundColor: Color(0xff16A34A),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update turf: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);

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
          "Edit Turf Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveTurf,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active status card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isActive ? Icons.check_circle : Icons.pause_circle_outline,
                      color: _isActive ? primary : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isActive ? "Turf is Active" : "Turf is Inactive",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _isActive
                                ? "Customers can find and book your ground"
                                : "Ground is hidden from user bookings",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      activeColor: primary,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildFieldLabel("Turf Name"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Enter turf name"),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? "Turf name is required" : null,
              ),

              const SizedBox(height: 16),

              _buildFieldLabel("Description"),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: _inputDecoration("About your turf, pitch type, rules..."),
              ),

              const SizedBox(height: 16),

              _buildFieldLabel("Location / Address"),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration("e.g. Kozhikode, Kerala"),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? "Location is required" : null,
              ),

              const SizedBox(height: 16),

              _buildFieldLabel("Price Per Hour (₹)"),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("e.g. 1200"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Price is required";
                  final p = double.tryParse(val.trim());
                  if (p == null || p <= 0) return "Enter a valid positive price";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildFieldLabel("Contact Phone Number"),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("e.g. +91 9876543210"),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? "Contact number is required" : null,
              ),

              const SizedBox(height: 20),

              _buildFieldLabel("Operating Hours"),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Open Time",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _openingTime,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Close Time",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _closingTime,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: BorderSide(color: Color(0xff16A34A), width: 1.5),
      ),
    );
  }
}

