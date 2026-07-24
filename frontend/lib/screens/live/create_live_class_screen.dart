import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class CreateLiveClassScreen extends StatefulWidget {
  const CreateLiveClassScreen({super.key});
  @override
  State<CreateLiveClassScreen> createState() => _CreateLiveClassScreenState();
}

class _CreateLiveClassScreenState extends State<CreateLiveClassScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Schedule Live Class', style: AppTypography.headlineSmMobile.copyWith(
          color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
        )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class details
            _buildLabel('CLASS TITLE'),
            _buildInput(hint: 'Enter class title', brightness: brightness),
            const SizedBox(height: 16),
            _buildLabel('DESCRIPTION'),
            _buildInput(hint: 'Brief description of the session', brightness: brightness, maxLines: 3),
            const SizedBox(height: 16),
            _buildLabel('SELECT COURSE'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest(brightness),
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: AppColors.border(brightness)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('Advanced Autonomous Robotics', style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textOnSurface(brightness),
                  ))),
                  Icon(Icons.chevron_right_rounded, color: AppColors.outline(brightness)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Date and time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('DATE'),
                      GestureDetector(
                        onTap: () => showDatePicker(
                          context: context, initialDate: _selectedDate,
                          firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
                        ).then((d) { if (d != null) setState(() => _selectedDate = d); }),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest(brightness),
                            borderRadius: AppRadius.mdAll,
                            border: Border.all(color: AppColors.border(brightness)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 12),
                              Text('${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                                style: AppTypography.bodyMd.copyWith(color: AppColors.textOnSurface(brightness))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('TIME'),
                      GestureDetector(
                        onTap: () => showTimePicker(
                          context: context, initialTime: _selectedTime,
                        ).then((t) { if (t != null) setState(() => _selectedTime = t); }),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest(brightness),
                            borderRadius: AppRadius.mdAll,
                            border: Border.all(color: AppColors.border(brightness)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 12),
                              Text(_selectedTime.format(context),
                                style: AppTypography.bodyMd.copyWith(color: AppColors.textOnSurface(brightness))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('DURATION'),
            Row(
              children: ['30 min', '45 min', '1 hour', '1.5 hours'].map((d) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: d == '1 hour' ? AppColors.primary : AppColors.surfaceContainerLowest(brightness),
                    borderRadius: AppRadius.chipAll,
                    border: Border.all(color: d == '1 hour' ? AppColors.primary : AppColors.border(brightness)),
                  ),
                  child: Text(d, textAlign: TextAlign.center, style: AppTypography.labelCaps.copyWith(
                    color: d == '1 hour' ? Colors.white : AppColors.textOnSurfaceVariant(brightness),
                    fontWeight: FontWeight.w500,
                  )),
                ),
              )).toList(),
            ),
            const SizedBox(height: 32),
            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                ),
                child: Text('Schedule Class', style: AppTypography.headlineSmMobile.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTypography.labelCaps.copyWith(
        color: AppColors.outline(Theme.of(context).brightness), fontWeight: FontWeight.w700,
      )),
    );
  }

  Widget _buildInput({required String hint, required Brightness brightness, int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline(brightness)),
          border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: AppTypography.bodyMd.copyWith(color: AppColors.textOnSurface(brightness)),
      ),
    );
  }
}
