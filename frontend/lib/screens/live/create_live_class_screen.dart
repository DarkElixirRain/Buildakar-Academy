// lib/screens/live_class/create_live_class_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../core/widgets/app_error_banner.dart';
import '../../providers/theme_provider.dart';
import '../../providers/live_class_provider.dart';
import '../../models/course_model.dart';
import '../../services/api_service.dart';

class CreateLiveClassScreen extends StatefulWidget {
  const CreateLiveClassScreen({Key? key}) : super(key: key);

  @override
  State<CreateLiveClassScreen> createState() => _CreateLiveClassScreenState();
}

class _CreateLiveClassScreenState extends State<CreateLiveClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  
  String? _selectedCourseId;
  DateTime? _selectedDateTime;
  bool _isLoading = false;
  bool _isLoadingCourses = true;
  bool _attachToCourse = false;
  List<Course> _courses = [];
  int _totalCoursesCount = 0;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadInstructorCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructorCourses() async {
    setState(() {
      _isLoadingCourses = true;
      _errorMessage = null;
    });

    try {
      // ✅ Use getInstructorCourses from instructor service
      final response = await _apiService.getInstructorCourses();
      
      print('📡 Courses response success: ${response.success}');
      print('📡 Courses response data: ${response.data}');
      print('📡 Courses response error: ${response.error}');
      
      if (response.success && response.data != null) {
        final allCourses = response.data!;
        // Only show published courses — backend rejects draft courses
        final publishedCourses = allCourses.where((c) => c.isPublished).toList();
        setState(() {
          _courses = publishedCourses;
          _totalCoursesCount = allCourses.length;
          if (_attachToCourse && _courses.isNotEmpty) {
            _selectedCourseId = _courses.first.id;
          }
        });
        print('✅ Loaded ${allCourses.length} courses (${publishedCourses.length} published)');
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load courses';
        });
        print('❌ Failed to load courses: ${response.error}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading courses: ${e.toString()}';
      });
      print('❌ Error loading courses: $e');
    } finally {
      setState(() {
        _isLoadingCourses = false;
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(hours: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        final pickerBrightness = Provider.of<ThemeProvider>(context).isDarkMode ? Brightness.dark : Brightness.light;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.getPrimaryColor(pickerBrightness),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now().replacing(
          hour: TimeOfDay.now().hour + 1,
          minute: 0,
        ),
        builder: (context, child) {
          final pickerBrightness = Provider.of<ThemeProvider>(context).isDarkMode ? Brightness.dark : Brightness.light;
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.getPrimaryColor(pickerBrightness),
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _createLiveClass() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;
    
    // Validate date/time
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and time'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if selected time is in the future
    if (_selectedDateTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future date and time'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<LiveClassProvider>(context, listen: false);
      
      // Prepare data for API - MATCHING BACKEND EXPECTATIONS
      final liveClassData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        if (_attachToCourse && _selectedCourseId != null)
          'courseId': _selectedCourseId,
        'scheduledAt': _selectedDateTime!.toIso8601String(),
        'maxParticipants': _maxParticipantsController.text.isNotEmpty
            ? int.parse(_maxParticipantsController.text)
            : 100,
      };

      print('📝 Creating live class with data: $liveClassData');

      final success = await provider.createLiveClass(liveClassData);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Live class created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Return to previous screen
        Navigator.pop(context, true);
      } else {
        final errorMsg = provider.errorMessage.isNotEmpty
            ? provider.errorMessage
            : 'Failed to create live class. Please try again.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundColor = AppColors.getBackgroundColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Live Class',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Creating live class...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message
                      if (_errorMessage != null)
                        AppErrorBanner(message: _errorMessage!),

                      // Title Field
                      Text(
                        'Class Title *',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: textColor, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Enter class title',
                          hintStyle: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: backgroundElementColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description Field
                      Text(
                        'Description (Optional)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(color: textColor, fontSize: 16),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter class description',
                          hintStyle: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: backgroundElementColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Course — optional, controlled by switch
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: backgroundElementColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attach to Course',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _attachToCourse
                                        ? 'Enrollment required to join'
                                        : 'Anyone can join without enrollment',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _attachToCourse,
                              onChanged: (val) {
                                setState(() {
                                  _attachToCourse = val;
                                  if (val && _courses.isNotEmpty && _selectedCourseId == null) {
                                    _selectedCourseId = _courses.first.id;
                                  }
                                  if (!val) {
                                    _selectedCourseId = null;
                                  }
                                });
                              },
                              activeThumbColor: primaryColor,
                            ),
                          ],
                        ),
                      ),

                      if (_attachToCourse) ...[
                        const SizedBox(height: 12),
                        _isLoadingCourses
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: const Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            : DropdownButtonFormField<String>(
                                initialValue: _selectedCourseId,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: backgroundElementColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                hint: Text(
                                  _courses.isEmpty ? 'No courses available' : 'Select a course',
                                  style: TextStyle(
                                    color: textSecondaryColor,
                                    fontSize: 15,
                                  ),
                                ),
                                items: _courses.map((course) {
                                  return DropdownMenuItem<String>(
                                    value: course.id,
                                    child: Row(
                                      children: [
                                        if (course.thumbnail.isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.network(
                                              course.thumbnail,
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: Icon(Icons.image_outlined),
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: primaryColor.withAlpha(20),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.school,
                                              size: 16,
                                              color: primaryColor,
                                            ),
                                          ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            course.title,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 15,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCourseId = value;
                                  });
                                },
                              ),
                        if (_courses.isEmpty && !_isLoadingCourses)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.getWarningColor(brightness).withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.getWarningColor(brightness),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _totalCoursesCount > 0
                                          ? 'You have $_totalCoursesCount course${_totalCoursesCount > 1 ? 's' : ''} but none are published. Publish a course first to link it.'
                                          : 'You don\'t have any courses yet.',
                                      style: TextStyle(
                                        color: AppColors.getWarningColor(brightness),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 20),

                      // Date & Time Selection
                      Text(
                        'Date & Time *',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDateTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: backgroundElementColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedDateTime == null
                                  ? Colors.transparent
                                  : primaryColor.withAlpha(50),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: _selectedDateTime != null
                                    ? primaryColor
                                    : textSecondaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDateTime != null
                                      ? DateFormat('EEE, MMM d, yyyy • h:mm a').format(_selectedDateTime!)
                                      : 'Select date and time',
                                  style: TextStyle(
                                    color: _selectedDateTime != null
                                        ? textColor
                                        : textSecondaryColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: textSecondaryColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedDateTime != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: textSecondaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Class will start at ${DateFormat('h:mm a').format(_selectedDateTime!)} on ${DateFormat('MMM d, yyyy').format(_selectedDateTime!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Max Participants
                      Text(
                        'Max Participants (Optional)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _maxParticipantsController,
                        style: TextStyle(color: textColor, fontSize: 16),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter max participants (default: 100)',
                          hintStyle: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: backgroundElementColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixText: 'students',
                          suffixStyle: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final intValue = int.tryParse(value);
                            if (intValue == null || intValue < 1) {
                              return 'Please enter a valid number';
                            }
                            if (intValue > 1000) {
                              return 'Max participants cannot exceed 1000';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createLiveClass,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: textSecondaryColor.withAlpha(50),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Create Live Class',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(brightness).withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.getPrimaryColor(brightness).withAlpha(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.getPrimaryLightColor(brightness),
                          ),
                            const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Students will be notified when the class goes live. '
                                  'You can start the class from the Live Classes tab. '
                                  'Classes linked to a course require enrollment to join.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.getTextSecondaryColor(brightness),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}