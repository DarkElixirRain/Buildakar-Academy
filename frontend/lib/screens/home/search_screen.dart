import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _hasQuery = false;

  final _recentSearches = ['Robotics basics', 'Python for engineers', 'BIM tools'];
  final _trending = ['Machine Learning', 'Structural Design', 'IoT Systems', 'CAD Modeling'];

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
          color: AppColors.background(brightness),
          child: TextField(
            controller: _ctrl,
            focusNode: _focus,
            onChanged: (v) => setState(() => _hasQuery = v.isNotEmpty),
            style: AppTypography.bodyMd.copyWith(color: AppColors.textOnSurface(brightness)),
            decoration: InputDecoration(
              hintText: 'Search courses, instructors...',
              prefixIcon: IconButton(
                icon: Icon(_hasQuery ? Icons.arrow_back : Icons.search,
                  color: AppColors.outline(brightness)),
                onPressed: () {
                  if (_hasQuery) { _ctrl.clear(); setState(() => _hasQuery = false); }
                },
              ),
              suffixIcon: _hasQuery
                  ? IconButton(
                      icon: Icon(Icons.close, color: AppColors.outline(brightness), size: 20),
                      onPressed: () { _ctrl.clear(); setState(() => _hasQuery = false); },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceContainerLowest(brightness),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
        // Content
        Expanded(
          child: _hasQuery ? _buildSuggestions(brightness) : _buildEmpty(brightness),
        ),
      ],
    );
  }

  Widget _buildEmpty(Brightness brightness) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Text('RECENT SEARCHES', style: AppTypography.labelCaps.copyWith(
              color: AppColors.outline(brightness), letterSpacing: 0.5,
            )),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _recentSearches.map((s) => GestureDetector(
                onTap: () { _ctrl.text = s; setState(() => _hasQuery = true); },
                onLongPress: () => setState(() => _recentSearches.remove(s)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer(brightness),
                    borderRadius: AppRadius.chipAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s, style: AppTypography.bodySm.copyWith(
                        color: AppColors.textOnSurfaceVariant(brightness),
                      )),
                      const SizedBox(width: 4),
                      Icon(Icons.close, size: 14, color: AppColors.outline(brightness)),
                    ],
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 32),
          ],
          // Trending
          Text('TRENDING', style: AppTypography.labelCaps.copyWith(
            color: AppColors.outline(brightness), letterSpacing: 0.5,
          )),
          const SizedBox(height: 12),
          ...ListTile.divideTiles(
            color: AppColors.border(brightness),
            tiles: _trending.map((t) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.trending_up, color: AppColors.secondaryContainer, size: 20),
              title: Text(t, style: AppTypography.bodyMd.copyWith(
                color: AppColors.textOnSurface(brightness),
              )),
              onTap: () { _ctrl.text = t; setState(() => _hasQuery = true); },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(Brightness brightness) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionLabel('COURSES'),
        _SuggestionTile(icon: Icons.school_outlined, title: 'Advanced Robotics', subtitle: 'Course'),
        _SuggestionTile(icon: Icons.school_outlined, title: 'Robotics Fundamentals', subtitle: 'Course'),
        const SizedBox(height: 16),
        _SectionLabel('INSTRUCTORS'),
        _SuggestionTile(icon: Icons.person_outline, title: 'Dr. Marcus Chen', subtitle: 'Robotics Expert'),
        const SizedBox(height: 16),
        _SectionLabel('CATEGORIES'),
        _SuggestionTile(icon: Icons.category_outlined, title: 'Robotics', subtitle: '12 courses'),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: AppTypography.labelCaps.copyWith(
        color: AppColors.outline(Theme.of(context).brightness),
        letterSpacing: 0.5,
      )),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _SuggestionTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(brightness),
          borderRadius: AppRadius.smAll,
        ),
        child: Icon(icon, color: AppColors.outline(brightness), size: 20),
      ),
      title: Text(title, style: AppTypography.bodyMd.copyWith(
        color: AppColors.textOnSurface(brightness),
      )),
      subtitle: Text(subtitle, style: AppTypography.bodySm.copyWith(
        color: AppColors.textOnSurfaceVariant(brightness), fontSize: 12,
      )),
      onTap: () {},
    );
  }
}
