// lib/screens/instructor/course_creation_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../core/widgets/app_button.dart';

class CourseCreationScreen extends StatefulWidget {
  const CourseCreationScreen({super.key});

  @override
  State<CourseCreationScreen> createState() => _CourseCreationScreenState();
}

class _CourseCreationScreenState extends State<CourseCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();

  // Dropdown values
  String _selectedCategory = '';
  String _selectedLevel = 'BEGINNER';
  String _selectedLanguage = 'English';

  // File for thumbnail
  File? _thumbnailFile;
  bool _isUploading = false;

  // Categories list
  List<Map<String, dynamic>> _categories = [];

  // Levels
  final List<String> _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'ALL_LEVELS'];

  // Languages
  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Hindi'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response.success && response.data != null) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response.data ?? []);
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories[0]['id'].toString();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _thumbnailFile = File(image.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thumbnail selected successfully!'),
              backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
          ),
        );
      }
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a course thumbnail'),
          backgroundColor: AppColors.getWarningColor(Theme.of(context).brightness),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? thumbnailUrl;

      // Step 1: Upload thumbnail to Cloudinary
      final uploadResponse = await _apiService.uploadThumbnail(_thumbnailFile!);
      if (!uploadResponse.success || uploadResponse.data == null) {
        throw Exception(uploadResponse.error ?? 'Failed to upload thumbnail');
      }
      thumbnailUrl = uploadResponse.data!['url'] as String?;

      // Step 2: Create course with thumbnail URL
      final courseData = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'categoryId': _selectedCategory,
        'level': _selectedLevel,
        'language': _selectedLanguage,
        'price': double.tryParse(_priceController.text.trim()) ?? 0,
        'thumbnail': thumbnailUrl ?? '',
      };

      if (_discountPriceController.text.trim().isNotEmpty) {
        final discountPrice = double.tryParse(_discountPriceController.text.trim());
        if (discountPrice != null) {
          courseData['originalPrice'] = discountPrice;
        }
      }

      final response = await _apiService.post(
        '/courses',
        data: courseData,
        requireAuth: true,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Course created successfully!'),
              backgroundColor: AppColors.getSuccessColor(Theme.of(context).brightness),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.error ?? 'Failed to create course');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.getErrorColor(Theme.of(context).brightness),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final cardColor = AppColors.getBackgroundElementColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Course',
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _createCourse,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Publish',
                    style: GoogleFonts.inter(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 400;
            final padding = isSmallScreen ? 12.0 : 16.0;
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - kToolbarHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      _buildThumbnailSection(
                        brightness: brightness,
                        cardColor: cardColor,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // Title
                      _buildTextField(
                        controller: _titleController,
                        label: 'Course Title',
                        hint: 'e.g. Complete Flutter Development Bootcamp',
                        textColor: textColor,
                        cardColor: cardColor,
                        isSmallScreen: isSmallScreen,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a course title';
                          }
                          if (value.trim().length < 5) {
                            return 'Title should be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Subtitle
                      _buildTextField(
                        controller: _subtitleController,
                        label: 'Subtitle',
                        hint: 'e.g. Learn Flutter from scratch to advanced',
                        textColor: textColor,
                        cardColor: cardColor,
                        maxLines: 2,
                        isSmallScreen: isSmallScreen,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a subtitle';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'What will students learn in this course?',
                        textColor: textColor,
                        cardColor: cardColor,
                        maxLines: 5,
                        isSmallScreen: isSmallScreen,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          if (value.trim().length < 20) {
                            return 'Description should be at least 20 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Category Dropdown
                      _buildDropdown(
                        label: 'Category',
                        value: _selectedCategory,
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['id'].toString(),
                            child: Text(
                              cat['name'] ?? 'Unknown',
                              style: GoogleFonts.inter(color: textColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                        },
                        textColor: textColor,
                        cardColor: cardColor,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Level Dropdown
                      _buildDropdown(
                        label: 'Level',
                        value: _selectedLevel,
                        items: _levels.map((level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(
                              level.replaceAll('_', ' ').toUpperCase(),
                              style: GoogleFonts.inter(color: textColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedLevel = value!);
                        },
                        textColor: textColor,
                        cardColor: cardColor,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Language Dropdown
                      _buildDropdown(
                        label: 'Language',
                        value: _selectedLanguage,
                        items: _languages.map((lang) {
                          return DropdownMenuItem<String>(
                            value: lang,
                            child: Text(
                              lang,
                              style: GoogleFonts.inter(color: textColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedLanguage = value!);
                        },
                        textColor: textColor,
                        cardColor: cardColor,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Price - Changed from USD to NRS
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price (NRS)',
                        hint: '0.00',
                        textColor: textColor,
                        cardColor: cardColor,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixText: 'रु ',
                        isSmallScreen: isSmallScreen,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a price';
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed < 0) {
                            return 'Enter a valid price';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Discount Price (Optional) - Changed from USD to NRS
                      _buildTextField(
                        controller: _discountPriceController,
                        label: 'Discount Price (Optional)',
                        hint: '0.00',
                        textColor: textColor,
                        cardColor: cardColor,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixText: 'रु ',
                        isSmallScreen: isSmallScreen,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed < 0) {
                              return 'Enter a valid discount price';
                            }
                            final price = double.tryParse(_priceController.text.trim()) ?? 0;
                            if (parsed >= price && price > 0) {
                              return 'Discount price must be less than regular price';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 24 : 32),

                      // Submit Button
                      AppButton(
                        title: 'Create Course',
                        onPressed: _createCourse,
                        isLoading: _isUploading,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your course will be saved as a draft. You can publish it later after adding lessons.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThumbnailSection({
    required Brightness brightness,
    required Color cardColor,
    required Color primaryColor,
    required Color textColor,
    required bool isSmallScreen,
  }) {
    final height = isSmallScreen ? 140.0 : 180.0;
    
    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
          image: _thumbnailFile != null
              ? DecorationImage(
                  image: FileImage(_thumbnailFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _thumbnailFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: isSmallScreen ? 36 : 48,
                    color: primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Course Thumbnail',
                    style: GoogleFonts.inter(
                      color: textColor.withOpacity(0.5),
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select an image',
                    style: GoogleFonts.inter(
                      color: textColor.withOpacity(0.3),
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  // Image is shown via decoration
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 16),
                        onPressed: () {
                          setState(() => _thumbnailFile = null);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color textColor,
    required Color cardColor,
    required bool isSmallScreen,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    final fontSize = isSmallScreen ? 13.0 : 14.0;
    final verticalPadding = isSmallScreen ? 8.0 : 12.0;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            prefixText: prefixText,
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: textColor.withOpacity(0.5),
              fontSize: fontSize,
            ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: cardColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            isDense: true,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required Color textColor,
    required Color cardColor,
    required bool isSmallScreen,
  }) {
    final fontSize = isSmallScreen ? 13.0 : 14.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: textColor.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: fontSize,
            ),
            dropdownColor: cardColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: items,
            onChanged: onChanged,
            icon: Icon(Icons.arrow_drop_down, color: textColor),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }
}