// lib/screens/instructor/course_edit_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../core/widgets/app_button.dart';

class CourseEditScreen extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic> courseData;

  const CourseEditScreen({
    super.key,
    required this.courseId,
    required this.courseData,
  });

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountPriceController;

  String _selectedCategory = '';
  String _selectedLevel = 'BEGINNER';
  String _selectedLanguage = 'English';

  File? _thumbnailFile;
  String? _existingThumbnailUrl;
  bool _isUploading = false;

  List<Map<String, dynamic>> _categories = [];

  final List<String> _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'ALL_LEVELS'];
  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Hindi'];

  @override
  void initState() {
    super.initState();

    final data = widget.courseData;

    _titleController = TextEditingController(text: data['title'] ?? '');
    _subtitleController = TextEditingController(text: data['subtitle'] ?? '');
    _descriptionController = TextEditingController(text: data['description'] ?? '');
    _priceController = TextEditingController(
      text: (data['price'] ?? 0.0).toString(),
    );
    _discountPriceController = TextEditingController(
      text: (data['originalPrice'] ?? data['discountPrice'] ?? '').toString(),
    );

    _selectedLevel = _normalizeLevel(data['level'] ?? 'BEGINNER');
    _selectedLanguage = data['language'] ?? 'English';
    _existingThumbnailUrl = data['thumbnail'];

    _loadCategories();
  }

  String _normalizeLevel(dynamic level) {
    if (level == null) return 'BEGINNER';
    final upper = level.toString().toUpperCase().replaceAll(' ', '_');
    if (_levels.contains(upper)) return upper;
    return 'BEGINNER';
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

  Future<void> _loadCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response.success && response.data != null) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response.data ?? []);
          final data = widget.courseData;
          final category = data['category'];
          if (category != null && category is Map) {
            final currentCategoryId = category['id']?.toString();
            if (currentCategoryId != null &&
                _categories.any((c) => c['id'].toString() == currentCategoryId)) {
              _selectedCategory = currentCategoryId;
            } else if (_categories.isNotEmpty) {
              _selectedCategory = _categories[0]['id'].toString();
            }
          } else if (_categories.isNotEmpty) {
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
            const SnackBar(
              content: Text('Thumbnail selected successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? thumbnailUrl = _existingThumbnailUrl;

      if (_thumbnailFile != null) {
        final uploadResponse = await _apiService.uploadThumbnail(_thumbnailFile!);
        if (!uploadResponse.success || uploadResponse.data == null) {
          throw Exception(uploadResponse.error ?? 'Failed to upload thumbnail');
        }
        thumbnailUrl = uploadResponse.data!['url'] as String?;
      }

      final courseData = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'categoryId': _selectedCategory,
        'level': _selectedLevel,
        'language': _selectedLanguage,
        'price': double.tryParse(_priceController.text.trim()) ?? 0,
      };

      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        courseData['thumbnail'] = thumbnailUrl;
      }

      if (_discountPriceController.text.trim().isNotEmpty) {
        final discountPrice = double.tryParse(_discountPriceController.text.trim());
        if (discountPrice != null) {
          courseData['originalPrice'] = discountPrice;
        }
      }

      final response = await _apiService.updateCourse(widget.courseId, courseData);

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.error ?? 'Failed to update course');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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
    final brightness = MediaQuery.of(context).platformBrightness;
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final cardColor = AppColors.getBackgroundElementColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Course',
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
            onPressed: _isUploading ? null : _updateCourse,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnailSection(
                brightness: brightness,
                cardColor: cardColor,
                primaryColor: primaryColor,
                textColor: textColor,
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _titleController,
                label: 'Course Title',
                hint: 'e.g. Complete Flutter Development Bootcamp',
                textColor: textColor,
                cardColor: cardColor,
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
              const SizedBox(height: 20),

              _buildTextField(
                controller: _subtitleController,
                label: 'Subtitle',
                hint: 'e.g. Learn Flutter from scratch to advanced',
                textColor: textColor,
                cardColor: cardColor,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'What will students learn in this course?',
                textColor: textColor,
                cardColor: cardColor,
                maxLines: 5,
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
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Category',
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'].toString(),
                    child: Text(
                      cat['name'] ?? 'Unknown',
                      style: GoogleFonts.inter(color: textColor),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
                textColor: textColor,
                cardColor: cardColor,
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Level',
                value: _selectedLevel,
                items: _levels.map((level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(
                      level.replaceAll('_', ' ').toUpperCase(),
                      style: GoogleFonts.inter(color: textColor),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedLevel = value!);
                },
                textColor: textColor,
                cardColor: cardColor,
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Language',
                value: _selectedLanguage,
                items: _languages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Text(
                      lang,
                      style: GoogleFonts.inter(color: textColor),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                },
                textColor: textColor,
                cardColor: cardColor,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _priceController,
                label: 'Price (USD)',
                hint: '0.00',
                textColor: textColor,
                cardColor: cardColor,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixText: 'रु ',
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
              const SizedBox(height: 20),

              _buildTextField(
                controller: _discountPriceController,
                label: 'Discount Price (Optional)',
                hint: '0.00',
                textColor: textColor,
                cardColor: cardColor,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixText: 'रु ',
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid discount price';
                    }
                    final price = double.tryParse(_priceController.text.trim()) ?? 0;
                    if (parsed >= price) {
                      return 'Discount price must be less than regular price';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              AppButton(
                title: 'Save Changes',
                onPressed: _updateCourse,
                isLoading: _isUploading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailSection({
    required Brightness brightness,
    required Color cardColor,
    required Color primaryColor,
    required Color textColor,
  }) {
    final hasExisting = _existingThumbnailUrl != null && _existingThumbnailUrl!.isNotEmpty;
    final hasNew = _thumbnailFile != null;

    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          image: _thumbnailFile != null
              ? DecorationImage(
                  image: FileImage(_thumbnailFile!),
                  fit: BoxFit.cover,
                )
              : (hasExisting
                  ? DecorationImage(
                      image: NetworkImage(_existingThumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                  : null),
        ),
        child: (!hasExisting && !hasNew)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: primaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Course Thumbnail',
                    style: GoogleFonts.inter(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select an image',
                    style: GoogleFonts.inter(
                      color: textColor.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 16),
                        onPressed: hasNew
                            ? () => setState(() => _thumbnailFile = null)
                            : () => setState(() => _existingThumbnailUrl = null),
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: textColor),
          decoration: InputDecoration(
            prefixText: prefixText,
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: textColor.withValues(alpha: 0.5),
            ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: textColor.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            style: GoogleFonts.inter(color: textColor),
            dropdownColor: cardColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            items: items,
            onChanged: onChanged,
            icon: Icon(Icons.arrow_drop_down, color: textColor),
          ),
        ),
      ],
    );
  }
}
