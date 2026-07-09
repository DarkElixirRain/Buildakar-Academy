// lib/screens/notifications/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learnhub/providers/theme_provider.dart';
import 'package:learnhub/services/api_service.dart';
import '../../constants/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  
  List<Map<String, dynamic>> _notifications = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalNotifications = 0;
  int _unreadCount = 0;
  bool _hasMore = true;
  final int _limit = 20;
  
  final ApiService _apiService = ApiService();

  // Filter options
  final List<String> _filterOptions = ['All', 'Unread', 'Read'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadNotifications({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _notifications = [];
        _hasMore = true;
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _apiService.getNotifications(
        page: _currentPage,
        limit: _limit,
      );

      if (!mounted) return;

      if (response.success) {
        final data = response.data;
        final List<dynamic> notificationsData = data?['data'] ?? [];
        final meta = data?['meta'] ?? {};
        
        final transformed = notificationsData.map((n) => _transformNotification(n)).toList();

        setState(() {
          if (reset) {
            _notifications = transformed;
          } else {
            _notifications.addAll(transformed);
          }
          _totalNotifications = meta['total'] ?? 0;
          _unreadCount = meta['unreadCount'] ?? 0;
          _totalPages = meta['totalPages'] ?? 1;
          _hasMore = _currentPage < _totalPages;
          _isLoading = false;
          _isLoadingMore = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load notifications';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
      print('Error loading notifications: $e');
    }
  }

  Map<String, dynamic> _transformNotification(dynamic notification) {
    final type = notification['type']?.toString().toLowerCase() ?? 'general';
    final iconData = _getIconForType(type);
    final color = _getColorForType(type);
    
    final createdAt = notification['createdAt'];
    String timeAgo = 'Just now';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        timeAgo = _timeAgo(date);
      } catch (_) {
        timeAgo = 'Recently';
      }
    }

    return {
      'id': notification['id']?.toString() ?? '',
      'title': notification['title'] ?? 'Notification',
      'message': notification['body'] ?? notification['message'] ?? '',
      'time': timeAgo,
      'type': type,
      'isRead': notification['isRead'] ?? false,
      'icon': iconData,
      'color': color,
      'data': notification['data'] ?? {},
      'createdAt': createdAt,
    };
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'enrollment':
        return Icons.school_rounded;
      case 'payment_success':
        return Icons.payment_rounded;
      case 'payment_failed':
        return Icons.payment_rounded;
      case 'new_review':
        return Icons.star_rounded;
      case 'course_published':
        return Icons.rocket_launch_rounded;
      case 'course_approved':
        return Icons.verified_rounded;
      case 'system':
        return Icons.notifications_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'enrollment':
        return Colors.blue;
      case 'payment_success':
        return Colors.green;
      case 'payment_failed':
        return Colors.red;
      case 'new_review':
        return Colors.amber;
      case 'course_published':
        return Colors.purple;
      case 'course_approved':
        return Colors.teal;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _currentPage = 1;
    _loadNotifications(reset: true);
  }

  Future<void> _markAsRead(String id) async {
    try {
      final response = await _apiService.markNotificationAsRead(id);
      
      if (!mounted) return;
      
      if (response.success) {
        setState(() {
          final index = _notifications.indexWhere((n) => n['id'] == id);
          if (index != -1) {
            _notifications[index]['isRead'] = true;
            _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
          }
        });
        _showSnackBar('Marked as read', Colors.green);
      } else {
        _showSnackBar(response.error ?? 'Failed to mark as read', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsAsRead();
      
      if (!mounted) return;
      
      if (response.success) {
        setState(() {
          for (var notification in _notifications) {
            notification['isRead'] = true;
          }
          _unreadCount = 0;
        });
        _showSnackBar('All marked as read', Colors.green);
      } else {
        _showSnackBar(response.error ?? 'Failed to mark all as read', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      final response = await _apiService.deleteNotification(id);
      
      if (!mounted) return;
      
      if (response.success) {
        setState(() {
          final index = _notifications.indexWhere((n) => n['id'] == id);
          if (index != -1) {
            if (!_notifications[index]['isRead']) {
              _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
            }
            _notifications.removeAt(index);
          }
        });
        _showSnackBar('Notification deleted', Colors.green);
      } else {
        _showSnackBar(response.error ?? 'Failed to delete notification', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _loadMore() {
    if (!_isLoadingMore && _hasMore && !_isLoading) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _loadNotifications();
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
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filterOptions.map((filter) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildFilterChip(filter, isDark, brightness),
                  ),
                );
              }).toList(),
            ),
          ),
          // Notification List
          Expanded(
            child: _isLoading
                ? _buildLoadingState(isDark, brightness)
                : _error != null && _notifications.isEmpty
                    ? _buildErrorState(isDark, brightness)
                    : _notifications.isEmpty
                        ? _buildEmptyState(isDark, brightness)
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollEndNotification) {
                                final metrics = notification.metrics;
                                if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                                  _loadMore();
                                }
                              }
                              return false;
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _notifications.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _notifications.length && _hasMore) {
                                  return _buildLoadMoreIndicator(isDark, brightness);
                                }
                                final notification = _notifications[index];
                                
                                // Apply filter
                                if (_selectedFilter == 'Unread' && notification['isRead']) {
                                  return const SizedBox.shrink();
                                }
                                if (_selectedFilter == 'Read' && !notification['isRead']) {
                                  return const SizedBox.shrink();
                                }
                                
                                return _buildNotificationItem(
                                  notification,
                                  isDark,
                                  brightness,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark, Brightness brightness) {
    final isSelected = _selectedFilter == label;
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return GestureDetector(
      onTap: () => _applyFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : backgroundElementColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : backgroundSelectedColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    Map<String, dynamic> notification,
    bool isDark,
    Brightness brightness,
  ) {
    final isRead = notification['isRead'] ?? false;
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);
    final backgroundSelectedColor = AppColors.getBackgroundSelectedColor(brightness);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead
            ? backgroundElementColor
            : primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead
              ? backgroundSelectedColor
              : primaryColor.withValues(alpha: 0.2),
          width: isRead ? 1 : 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (notification['color'] as Color).withValues(alpha: 0.12),
            ),
            child: Icon(
              notification['icon'] as IconData? ?? Icons.notifications,
              color: notification['color'] as Color? ?? Colors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondaryColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      notification['time'],
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondaryColor,
                      ),
                    ),
                    const Spacer(),
                    if (!isRead)
                      TextButton(
                        onPressed: () => _markAsRead(notification['id']),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Mark read',
                          style: TextStyle(
                            fontSize: 11,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (isRead)
                      IconButton(
                        onPressed: () => _deleteNotification(notification['id']),
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: textSecondaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark, Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(brightness),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Brightness brightness) {
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Failed to load notifications',
            style: TextStyle(
              fontSize: 14,
              color: textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _currentPage = 1;
              _loadNotifications(reset: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimaryColor(brightness),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Brightness brightness) {
    final textColor = AppColors.getTextColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);
    final backgroundElementColor = AppColors.getBackgroundElementColor(brightness);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundElementColor,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? 'No notifications'
                : 'No ${_selectedFilter.toLowerCase()} notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedFilter == 'All'
                ? 'You\'re all caught up!'
                : 'Check back later for new notifications',
            style: TextStyle(
              fontSize: 14,
              color: textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isDark, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}