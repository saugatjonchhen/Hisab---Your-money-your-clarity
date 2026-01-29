import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/presentation/main_shell.dart';
import 'package:finance_app/features/profile/data/models/user_profile_model.dart';
import 'package:finance_app/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:finance_app/core/utils/string_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_app/core/theme/app_values.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileNotifierProvider).value;
      if (profile != null) {
        _nameController.text = profile.fullName;
        _ageController.text = profile.age.toString();
        _emailController.text = profile.email ?? '';
        setState(() {
          _selectedImagePath = profile.imagePath;
        });
      }
    });

    _nameController.addListener(() {
      if (_selectedImagePath == null || _selectedImagePath!.contains('ui-avatars.com')) {
        setState(() {
          // Trigger rebuild to update initials in avatar preview
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileAsync = ref.read(userProfileNotifierProvider);
      final isUpdate = profileAsync.value?.isSetupComplete ?? false;

      final profile = UserProfile(
        fullName: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        imagePath: _selectedImagePath,
        isSetupComplete: true,
      );

      await ref.read(userProfileNotifierProvider.notifier).completeSetup(profile);

      if (mounted) {
        if (isUpdate) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(userProfileNotifierProvider);
    final isUpdate = profileAsync.value?.isSetupComplete ?? false;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withValues(alpha: 0.9),
                    AppColors.primary.withValues(alpha: 0.1),
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.05),
                    AppColors.backgroundLight,
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppValues.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUpdate)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : AppColors.secondary,
                    ),
                  ),
                const SizedBox(height: AppValues.gapMedium),
                Text(
                  isUpdate ? 'Update Profile' : 'Welcome to Hisab',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.secondary,
                      ),
                ),
                const SizedBox(height: AppValues.gapSmall),
                Text(
                  isUpdate 
                      ? 'Keep your information up to date for better insights.'
                      : 'Let\'s build your profile to personalize your experience.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: AppValues.gapExtraLarge),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _buildMainAvatarContent(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildAvatarSelector(),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'e.g. John Doe',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _ageController,
                        label: 'Age',
                        hint: 'e.g. 25',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your age';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email (Optional)',
                        hint: 'e.g. john@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isUpdate ? 'Save Changes' : 'Get Started',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    final initials = _nameController.text.initials;
    final fallbackAvatars = [
      'https://ui-avatars.com/api/?name=$initials&background=6366f1&color=fff',
      'https://ui-avatars.com/api/?name=$initials&background=8b5cf6&color=fff',
      'https://ui-avatars.com/api/?name=$initials&background=ec4899&color=fff',
      'https://ui-avatars.com/api/?name=$initials&background=f59e0b&color=fff',
      'https://ui-avatars.com/api/?name=$initials&background=10b981&color=fff',
    ];

    final iconAvatars = [
      'icon:person_rounded',
      'icon:face_rounded',
      'icon:support_agent_rounded',
      'icon:psychology_rounded',
      'icon:engineering_rounded',
      'icon:pets_rounded',
      'icon:sports_esports_rounded',
      'icon:flight_rounded',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose an avatar source',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Initials',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fallbackAvatars.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final avatar = fallbackAvatars[index];
              final isSelected = _selectedImagePath == avatar;
              return GestureDetector(
                onTap: () => setState(() => _selectedImagePath = avatar),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                           child: Text(
                             initials,
                             style: TextStyle(
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                               color: AppColors.primary.withValues(alpha: 0.8),
                             ),
                           ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Icons',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: iconAvatars.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final iconPath = iconAvatars[index];
              final isSelected = _selectedImagePath == iconPath;
              final iconName = iconPath.substring(5);
              return GestureDetector(
                onTap: () => setState(() => _selectedImagePath = iconPath),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getIconFromName(iconName),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getIconFromName(String name) {
    switch (name) {
      case 'person_rounded': return Icons.person_rounded;
      case 'face_rounded': return Icons.face_rounded;
      case 'support_agent_rounded': return Icons.support_agent_rounded;
      case 'psychology_rounded': return Icons.psychology_rounded;
      case 'engineering_rounded': return Icons.engineering_rounded;
      case 'pets_rounded': return Icons.pets_rounded;
      case 'sports_esports_rounded': return Icons.sports_esports_rounded;
      case 'flight_rounded': return Icons.flight_rounded;
      default: return Icons.person_rounded;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.secondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildMainAvatarContent() {
    if (_selectedImagePath != null) {
      if (_selectedImagePath!.startsWith('http') || _selectedImagePath!.startsWith('blob:')) {
        return Image.network(
          _selectedImagePath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      } else if (!kIsWeb && !_selectedImagePath!.startsWith('icon:')) {
        return Image.file(
          File(_selectedImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      } else if (_selectedImagePath!.startsWith('icon:')) {
        return Center(
          child: Icon(
            _getIconFromName(_selectedImagePath!.substring(5)),
            size: 60,
            color: AppColors.primary,
          ),
        );
      }
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        _nameController.text.initials,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.primary.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
