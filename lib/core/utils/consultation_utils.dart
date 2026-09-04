import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultationUtils {
  static void showConsultationDialog(BuildContext context, {String? plan}) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedRole;
        String selectedTimeline = 'Immediately';
        final Map<String, bool> communicationMethods = {
          'Email': false,
          'Whatsapp': false,
          'Phone': false,
          'SMS': false,
        };
        final formKey = GlobalKey<FormState>();

        // Controllers for form fields
        final nameController = TextEditingController();
        final emailController = TextEditingController();
        final phoneController = TextEditingController();
        final companyController = TextEditingController();
        final businessTypeController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: 700,
                constraints: const BoxConstraints(maxWidth: 700),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                plan != null
                                    ? 'Get Started with $plan Plan'
                                    : 'Book Your StockSense Consultation',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contact us to use our effective, solution-oriented software that will simplify work and amplify your impact',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 1: Personal Details
                        Text(
                          'Personal Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 500;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildTextField(
                                            'Name', 'e.g., John Doe', nameController)),
                                    if (isWide) ...[
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: _buildTextField('Email',
                                              'john.doe@gmail.com', emailController)),
                                    ],
                                  ],
                                ),
                                if (!isWide) ...[
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                      'Email', 'john.doe@gmail.com', emailController),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildTextField('Phone',
                                            '+254 759 585197', phoneController)),
                                    if (isWide) ...[
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: _buildTextField(
                                              'Company name',
                                              'e.g., Acme Corporation', companyController)),
                                    ],
                                  ],
                                ),
                                if (!isWide) ...[
                                  const SizedBox(height: 16),
                                  _buildTextField('Company name',
                                      'e.g., Acme Corporation', companyController),
                                ],
                                const SizedBox(height: 16),
                                _buildTextField('Business Type', 'e.g., Retail, Manufacturing', businessTypeController),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Section 2: Your Role
                        Text(
                          'Your Role *',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 500;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildRoleCard('Owner/Founder', selectedRole, (val) => setState(() => selectedRole = val))),
                                  if (isWide) ...[
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildRoleCard('Manager', selectedRole, (val) => setState(() => selectedRole = val))),
                                  ]
                                ],
                              ),
                              if (!isWide) ...[
                                const SizedBox(height: 16),
                                _buildRoleCard('Manager', selectedRole, (val) => setState(() => selectedRole = val)),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildRoleCard('Employee', selectedRole, (val) => setState(() => selectedRole = val))),
                                  if (isWide) ...[
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildRoleCard('Other', selectedRole, (val) => setState(() => selectedRole = val))),
                                  ]
                                ],
                              ),
                              if (!isWide) ...[
                                const SizedBox(height: 16),
                                _buildRoleCard('Other', selectedRole, (val) => setState(() => selectedRole = val)),
                              ],
                            ],
                          );
                        }),
                        const SizedBox(height: 24),

                        // Section 3: Implementation Timeline
                        Text(
                          'How soon would you like to start using these products? *',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 600;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildRadioOption('Immediately', selectedTimeline, (val) => setState(() => selectedTimeline = val!))),
                                  if (isWide) ...[
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildRadioOption('Within 1-3 months', selectedTimeline, (val) => setState(() => selectedTimeline = val!))),
                                  ]
                                ],
                              ),
                              if (!isWide) ...[
                                const SizedBox(height: 16),
                                _buildRadioOption('Within 1-3 months', selectedTimeline, (val) => setState(() => selectedTimeline = val!)),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildRadioOption('Just Exploring', selectedTimeline, (val) => setState(() => selectedTimeline = val!))),
                                  if (isWide) const Spacer(),
                                ]
                              )
                            ],
                          );
                        }),
                        const SizedBox(height: 24),

                        // Section 4: Preferred Communication
                        Text(
                          'What is your preferred communication method? *',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(builder: (context, constraints) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildCheckboxOption('Email', communicationMethods, (val) => setState(() => communicationMethods['Email'] = val!))),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildCheckboxOption('Whatsapp', communicationMethods, (val) => setState(() => communicationMethods['Whatsapp'] = val!))),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildCheckboxOption('Phone', communicationMethods, (val) => setState(() => communicationMethods['Phone'] = val!))),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildCheckboxOption('SMS', communicationMethods, (val) => setState(() => communicationMethods['SMS'] = val!))),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildCheckboxOption('Other', communicationMethods, (val) => setState(() {}))), // Simplified 'Other' for now
                                  const Spacer(),
                                ],
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Clear form
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF666666),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () async {
                                // Capture data
                                final name = nameController.text;
                                final email = emailController.text;
                                final phone = phoneController.text;
                                final company = companyController.text;
                                final businessType = businessTypeController.text;
                                final role = selectedRole ?? 'Not specified';
                                final timeline = selectedTimeline;
                                final preferredMethods = communicationMethods.entries
                                    .where((e) => e.value)
                                    .map((e) => e.key)
                                    .toList();

                                // Validation (Basic)
                                if (name.isEmpty || email.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please fill in required fields')),
                                  );
                                  return;
                                }

                                try {
                                  await FirebaseFirestore.instance.collection('consultations').add({
                                    'phone': phone,
                                    'companyName': company,
                                    'businessType': businessType,
                                    'role': role,
                                    'timeline': timeline,
                                    'preferredContact': preferredMethods,
                                    'submittedAt': FieldValue.serverTimestamp(),
                                    'source': 'demo_mode',
                                  });

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Thank you! Our team will be in touch.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error submitting consultation: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B00), // Cloudora Orange
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                plan != null ? 'Submit Request' : 'Book Consultation',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B00)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  static Widget _buildRoleCard(String title, String? groupValue, ValueChanged<String?> onChanged) {
    final isSelected = groupValue == title;
    return GestureDetector(
      onTap: () => onChanged(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildRadioOption(String title, String groupValue, ValueChanged<String?> onChanged) {
    final isSelected = groupValue == title;
    return GestureDetector(
      onTap: () => onChanged(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [ // Align content to center/left
            Center(child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF333333),
              ),
            )),
          ],
        ),
      ),
    );
  }

  static Widget _buildCheckboxOption(String title, Map<String, bool> values, ValueChanged<bool?> onChanged) {
    final isChecked = values[title] ?? false;
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked ? const Color(0xFFFF6B00) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: isChecked ? const Color(0xFFFF6B00) : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
