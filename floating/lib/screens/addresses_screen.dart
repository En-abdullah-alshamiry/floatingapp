import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../config/app_colors.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;

  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  // ============================================================
  // تحميل العناوين من Firestore
  // ============================================================

  Future<void> _loadAddresses() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();

      final loadedAddresses = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'title': data['title'] ?? 'المنزل',
          'titleEn': data['titleEn'] ?? 'Home',
          'recipient': data['recipient'] ?? '',
          'recipientEn': data['recipientEn'] ?? '',
          'city': data['city'] ?? '',
          'cityEn': data['cityEn'] ?? '',
          'district': data['district'] ?? '',
          'districtEn': data['districtEn'] ?? '',
          'street': data['street'] ?? '',
          'streetEn': data['streetEn'] ?? '',
          'building': data['building'] ?? '',
          'buildingEn': data['buildingEn'] ?? '',
          'apartment': data['apartment'] ?? '',
          'apartmentEn': data['apartmentEn'] ?? '',
          'isDefault': data['isDefault'] ?? false,
        };
      }).toList();

      // ترتيب العنوان الافتراضي أولاً
      loadedAddresses.sort((a, b) {
        final aDefault = a['isDefault'] == true;
        final bDefault = b['isDefault'] == true;

        if (aDefault && !bDefault) return -1;
        if (!aDefault && bDefault) return 1;

        return 0;
      });

      if (mounted) {
        setState(() {
          _addresses = loadedAddresses;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showMessage(
          'حدث خطأ أثناء تحميل العناوين',
          isError: true,
        );
      }
    }
  }

  // ============================================================
  // إضافة عنوان
  // ============================================================

  Future<void> _showAddressDialog({
    Map<String, dynamic>? address,
  }) async {
    final loc = AppLocalizations.of(context);

    final isEditing = address != null;

    final titleController = TextEditingController(
      text: address?['title'] ?? '',
    );

    final recipientController = TextEditingController(
      text: address?['recipient'] ?? '',
    );

    final cityController = TextEditingController(
      text: address?['city'] ?? '',
    );

    final districtController = TextEditingController(
      text: address?['district'] ?? '',
    );

    final streetController = TextEditingController(
      text: address?['street'] ?? '',
    );

    final buildingController = TextEditingController(
      text: address?['building'] ?? '',
    );

    final apartmentController = TextEditingController(
      text: address?['apartment'] ?? '',
    );

    bool isDefault = address?['isDefault'] ?? false;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;

            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEditing
                    ? 'تعديل العنوان'
                    : loc.tr('add_address'),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          controller: titleController,
                          label: 'اسم العنوان',
                          hint: 'مثال: المنزل',
                          icon: Icons.label_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: recipientController,
                          label: 'اسم المستلم',
                          hint: 'اسم المستلم',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: cityController,
                          label: 'المدينة',
                          hint: 'مثال: صنعاء',
                          icon: Icons.location_city_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: districtController,
                          label: 'الحي',
                          hint: 'مثال: حي حدة',
                          icon: Icons.map_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: streetController,
                          label: 'الشارع',
                          hint: 'اسم الشارع',
                          icon: Icons.route_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: buildingController,
                          label: 'المبنى',
                          hint: 'رقم المبنى',
                          icon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: apartmentController,
                          label: 'الشقة',
                          hint: 'رقم الشقة / الدور',
                          icon: Icons.home_work_outlined,
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AppColors.gold,
                          title: Text(
                            'تعيين كعنوان افتراضي',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          value: isDefault,
                          onChanged: (value) {
                            setDialogState(() {
                              isDefault = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.inter(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    Navigator.pop(dialogContext);

                    await _saveAddress(
                      addressId: address?['id'],
                      title: titleController.text.trim(),
                      recipient: recipientController.text.trim(),
                      city: cityController.text.trim(),
                      district: districtController.text.trim(),
                      street: streetController.text.trim(),
                      building: buildingController.text.trim(),
                      apartment: apartmentController.text.trim(),
                      isDefault: isDefault,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'حفظ التعديل' : 'إضافة',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    recipientController.dispose();
    cityController.dispose();
    districtController.dispose();
    streetController.dispose();
    buildingController.dispose();
    apartmentController.dispose();
  }

  // ============================================================
  // حفظ العنوان في Firestore
  // ============================================================

  Future<void> _saveAddress({
    String? addressId,
    required String title,
    required String recipient,
    required String city,
    required String district,
    required String street,
    required String building,
    required String apartment,
    required bool isDefault,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      _showMessage(
        'يجب تسجيل الدخول أولاً',
        isError: true,
      );
      return;
    }

    try {
      final addressesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses');

      // إذا أصبح هذا العنوان افتراضيًا
      // نجعل جميع العناوين الأخرى غير افتراضية
      if (isDefault) {
        final existing = await addressesRef.get();

        for (final doc in existing.docs) {
          if (doc.id != addressId) {
            await doc.reference.update({
              'isDefault': false,
            });
          }
        }
      }

      final data = {
        'title': title,
        'titleEn': title,
        'recipient': recipient,
        'recipientEn': recipient,
        'city': city,
        'cityEn': city,
        'district': district,
        'districtEn': district,
        'street': street,
        'streetEn': street,
        'building': building,
        'buildingEn': building,
        'apartment': apartment,
        'apartmentEn': apartment,
        'isDefault': isDefault,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (addressId == null) {
        await addressesRef.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await addressesRef.doc(addressId).update(data);
      }

      await _loadAddresses();

      _showMessage(
        addressId == null
            ? 'تمت إضافة العنوان بنجاح'
            : 'تم تعديل العنوان بنجاح',
      );
    } catch (e) {
      debugPrint('Error saving address: $e');

      _showMessage(
        'حدث خطأ أثناء حفظ العنوان',
        isError: true,
      );
    }
  }

  // ============================================================
  // حذف العنوان
  // ============================================================

  Future<void> _deleteAddress(
      String id,
      AppLocalizations loc,
      ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'حذف العنوان',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذا العنوان؟',
            style: GoogleFonts.inter(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(id)
          .delete();

      await _loadAddresses();

      _showMessage('تم حذف العنوان');
    } catch (e) {
      debugPrint('Error deleting address: $e');

      _showMessage(
        'حدث خطأ أثناء حذف العنوان',
        isError: true,
      );
    }
  }

  // ============================================================
  // تحديد العنوان الافتراضي
  // ============================================================

  Future<void> _setDefault(
      String id,
      ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      final addressesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses');

      final snapshot = await addressesRef.get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'isDefault': doc.id == id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await _loadAddresses();

      _showMessage('تم تعيين العنوان الافتراضي');
    } catch (e) {
      debugPrint('Error setting default address: $e');

      _showMessage(
        'حدث خطأ أثناء تحديد العنوان الافتراضي',
        isError: true,
      );
    }
  }

  // ============================================================
  // TextFormField
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: AppColors.gold,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.25,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.gold,
            width: 1.3,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'هذا الحقل مطلوب';
        }

        return null;
      },
    );
  }

  // ============================================================
  // الرسائل
  // ============================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? Colors.red : AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            loc.tr('address_title'),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.gold,
              ),
              onPressed: () => _showAddressDialog(),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
          ),
        )
            : _addresses.isEmpty
            ? _buildEmptyState(context, loc)
            : Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.gold,
                onRefresh: _loadAddresses,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildAddressCard(
                      context,
                      _addresses[index],
                      loc,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddressDialog(),
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.gold,
                  ),
                  label: Text(
                    loc.tr('add_address'),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.gold,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // بطاقة العنوان
  // ============================================================

  Widget _buildAddressCard(
      BuildContext context,
      Map<String, dynamic> address,
      AppLocalizations loc,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDefault = address['isDefault'] == true;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault
              ? AppColors.gold.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isDefault
                        ? AppColors.goldGradient
                        : LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withValues(
                          alpha: 0.6,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDefault
                        ? Icons.home_rounded
                        : Icons.location_on_outlined,
                    color: isDefault
                        ? Colors.white
                        : colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address['title'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address['recipient'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      loc.tr('default_address'),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${address['street'] ?? ''}، '
                    '${address['building'] ?? ''}، '
                    '${address['apartment'] ?? ''}\n'
                    '${address['district'] ?? ''}، '
                    '${address['city'] ?? ''}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!isDefault)
                  _buildActionChip(
                    icon: Icons.check_circle_outline,
                    label: loc.tr('set_default'),
                    onTap: () => _setDefault(
                      address['id'].toString(),
                    ),
                    color: AppColors.gold,
                  ),
                const Spacer(),
                _buildActionChip(
                  icon: Icons.edit_outlined,
                  label: '',
                  onTap: () => _showAddressDialog(
                    address: address,
                  ),
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.delete_outline,
                  label: '',
                  onTap: () => _deleteAddress(
                    address['id'].toString(),
                    loc,
                  ),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // أزرار البطاقة
  // ============================================================

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: label.isNotEmpty
            ? const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        )
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الحالة الفارغة
  // ============================================================

  Widget _buildEmptyState(
      BuildContext context,
      AppLocalizations loc,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.15),
                    AppColors.gold.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.tr('no_addresses'),
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.tr('no_addresses_desc'),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showAddressDialog(),
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  loc.tr('add_address'),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}