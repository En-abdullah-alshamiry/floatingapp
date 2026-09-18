import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../l10n/app_localizations.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  UserModel? _user;
  File? _selectedImage;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE IMAGE LOCALLY (جديد)
  // ============================================================

  Future<String?> saveImageLocally(File imageFile, String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_$userId${p.extension(imageFile.path)}';
      final savedImage = File('${directory.path}/$fileName');

      // حذف الصورة القديمة إذا وجدت
      if (await savedImage.exists()) {
        await savedImage.delete();
      }

      await imageFile.copy(savedImage.path);
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      return null;
    }
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final user = await _authService.getUserProfile();

      if (!mounted) return;

      if (user != null) {
        setState(() {
          _user = user;

          _nameController.text = user.displayName ?? '';
          _emailController.text = user.email;
          _phoneController.text = user.phoneNumber ?? '';

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'تعذر تحميل بيانات الملف الشخصي',
        isError: true,
      );
    }
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _showImageOptions() async {
    if (_isUploadingImage || _isSaving) return;

    final loc = AppLocalizations.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Directionality(
          textDirection: loc.textDirection,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'تغيير صورة الملف الشخصي',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.gold,
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'التقاط صورة بالكاميرا',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),

                  const SizedBox(height: 8),

                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.gold,
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'اختيار صورة من المعرض',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      await _uploadImage();
    } catch (e) {
      _showMessage(
        'تعذر اختيار الصورة',
        isError: true,
      );
    }
  }

  // ============================================================
  // UPLOAD IMAGE (معدلة لتعمل محلياً)
  // ============================================================

  Future<void> _uploadImage() async {
    if (_selectedImage == null || _user == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    // حفظ الصورة محلياً بدلاً من رفعها لـ Firebase
    final localPath = await saveImageLocally(_selectedImage!, _user!.id);

    if (!mounted) return;

    setState(() {
      _isUploadingImage = false;
    });

    if (localPath != null) {
      // تحديث بيانات المستخدم في Firestore بالمسار المحلي
      await _authService.updateProfileImage(localPath);

      setState(() {
        if (_user != null) {
          _user = UserModel(
            id: _user!.id,
            email: _user!.email,
            displayName: _user!.displayName,
            photoURL: localPath,
            isEmailVerified: _user!.isEmailVerified,
            phoneNumber: _user!.phoneNumber,
          );
        }
      });

      _showMessage('تم تحديث صورة الملف الشخصي بنجاح');
    } else {
      _showMessage(
        'تعذر حفظ الصورة',
        isError: true,
      );
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedUser = await _authService.updateProfile(
      name: _nameController.text,
      phoneNumber: _phoneController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (updatedUser == null) {
      _showMessage(
        'تعذر حفظ بيانات الملف الشخصي',
        isError: true,
      );
      return;
    }

    _showMessage('تم حفظ التغييرات بنجاح');

    Navigator.pop(context, true);
  }

  // ============================================================
  // MESSAGE
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
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            loc.tr('edit_profile'),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
          ),
        )
            : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 8),

              _buildAvatarSection(colorScheme),

              const SizedBox(height: 40),

              _buildTextField(
                controller: _nameController,
                label: loc.tr('full_name'),
                icon: Icons.person_outline_rounded,
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: _emailController,
                label: loc.tr('email'),
                icon: Icons.email_outlined,
                colorScheme: colorScheme,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: _phoneController,
                label: loc.tr('phone'),
                icon: Icons.phone_outlined,
                colorScheme: colorScheme,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 40),

              _buildSaveButton(loc),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AVATAR (معدلة لعرض الصورة من الملف المحلي)
  // ============================================================

  Widget _buildAvatarSection(ColorScheme colorScheme) {
    final name = _nameController.text.trim();

    return Center(
      child: GestureDetector(
        onTap: _showImageOptions,
        child: Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _selectedImage == null &&
                    (_user?.photoURL == null ||
                        _user!.photoURL!.isEmpty)
                    ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gold,
                    AppColors.gold.withValues(alpha: 0.7),
                  ],
                )
                    : null,
                image: _selectedImage != null
                    ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                )
                    : (_user?.photoURL != null &&
                    _user!.photoURL!.isNotEmpty)
                    ? DecorationImage(
                  // استخدام FileImage بدلاً من NetworkImage
                  image: FileImage(File(_user!.photoURL!)),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // في حال فشل تحميل الصورة (مثلاً من جهاز آخر)
                    debugPrint('Error loading local image: $exception');
                  },
                )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _selectedImage == null &&
                  (_user?.photoURL == null ||
                      _user!.photoURL!.isEmpty)
                  ? Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
                  : null,
            ),

            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _isUploadingImage
                    ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold,
                  ),
                )
                    : const Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.gold.withValues(alpha: 0.7),
              size: 22,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant
                    .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.gold,
                width: 1.5,
              ),
            ),
          ),
          validator: (value) {
            if (!enabled) return null;

            if (value == null || value.trim().isEmpty) {
              return '$label مطلوب';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton(AppLocalizations loc) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving || _isUploadingImage
            ? null
            : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          AppColors.gold.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Text(
          loc.tr('save'),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}