import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String userId;
  final String userEmail;
  final String? userName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? location;
  final double? latitude;
  final double? longitude;

  Complaint({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.status = 'Pending',
    required this.userId,
    required this.userEmail,
    this.userName,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.location,
    this.latitude,
    this.longitude,
  });

  // Convert Complaint to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Create Complaint from Firestore data
  factory Complaint.fromMap(String id, Map<String, dynamic> map) {
    // Handle different data types for createdAt (could be Timestamp or int)
    DateTime parseCreatedAt(dynamic createdAt) {
      if (createdAt == null) return DateTime.now();
      if (createdAt is int) {
        return DateTime.fromMillisecondsSinceEpoch(createdAt);
      } else if (createdAt is Timestamp) {
        return createdAt.toDate();
      } else {
        return DateTime.now();
      }
    }

    DateTime? parseUpdatedAt(dynamic updatedAt) {
      if (updatedAt == null) return null;
      if (updatedAt is int) {
        return DateTime.fromMillisecondsSinceEpoch(updatedAt);
      } else if (updatedAt is Timestamp) {
        return updatedAt.toDate();
      } else {
        return null;
      }
    }

    return Complaint(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      status: map['status']?.toString() ?? 'Pending',
      userId: map['userId']?.toString() ?? '',
      userEmail: map['userEmail']?.toString() ?? '',
      userName: map['userName']?.toString(),
      createdAt: parseCreatedAt(map['createdAt']),
      updatedAt: parseUpdatedAt(map['updatedAt']),
      imageUrl: map['imageUrl']?.toString(),
      location: map['location']?.toString(),
      latitude: map['latitude'] is double ? map['latitude'] : (map['latitude'] is int ? (map['latitude'] as int).toDouble() : null),
      longitude: map['longitude'] is double ? map['longitude'] : (map['longitude'] is int ? (map['longitude'] as int).toDouble() : null),
    );
  }

  // Copy with method for updates
  Complaint copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? status,
    String? userId,
    String? userEmail,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    return Complaint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Helper method to check if complaint has location
  bool get hasLocation => latitude != null && longitude != null;

  // Helper method to check if complaint has image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inSeconds > 10) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }

  // Get formatted time string (actual time)
  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final complaintDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    
    if (complaintDate == today) {
      // Today - show time
      return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (complaintDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else {
      // Older - show date
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

// Complaint categories with enhanced data
class ComplaintCategories {
  static const List<String> categories = [
    'Road Issues',
    'Water Supply',
    'Electricity',
    'Sanitation',
    'Public Safety',
    'Healthcare',
    'Education',
    'Transport',
    'Parks & Recreation',
    'Other'
  ];

  static const Map<String, String> categoryIcons = {
    'Road Issues': '🚧',
    'Water Supply': '💧',
    'Electricity': '⚡',
    'Sanitation': '🗑️',
    'Public Safety': '👮',
    'Healthcare': '🏥',
    'Education': '📚',
    'Transport': '🚌',
    'Parks & Recreation': '🌳',
    'Other': '📝',
  };

  static IconData getCategoryIcon(String category) {
    switch (category) {
       case 'Road Issues':
         return Icons.construction;
      case 'Water Supply':
        return Icons.water_drop;
      case 'Electricity':
        return Icons.bolt;
      case 'Sanitation':
        return Icons.delete;
      case 'Public Safety':
        return Icons.security;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Education':
        return Icons.school;
      case 'Transport':
        return Icons.directions_bus;
      case 'Parks & Recreation':
        return Icons.park;
      case 'Other':
      default:
        return Icons.report_problem;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Road Issues':
        return Colors.orange;
      case 'Water Supply':
        return Colors.blue;
      case 'Electricity':
        return Colors.yellow[700]!;
      case 'Sanitation':
        return Colors.brown;
      case 'Public Safety':
        return Colors.red;
      case 'Healthcare':
        return Colors.pink;
      case 'Education':
        return Colors.purple;
      case 'Transport':
        return Colors.deepPurple;
      case 'Parks & Recreation':
        return Colors.green;
      case 'Other':
      default:
        return Colors.grey;
    }
  }
}

// Complaint status with enhanced functionality
class ComplaintStatus {
  static const String pending = 'Pending';
  static const String inProgress = 'In Progress';
  static const String resolved = 'Resolved';
  static const String rejected = 'Rejected';

  static const List<String> allStatuses = [
    pending,
    inProgress,
    resolved,
    rejected,
  ];

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.access_time;
      case 'In Progress':
        return Icons.build;
      case 'Resolved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  static String getStatusDescription(String status) {
    switch (status) {
      case 'Pending':
        return 'Your complaint is waiting for review';
      case 'In Progress':
        return 'Your complaint is being addressed';
      case 'Resolved':
        return 'Your complaint has been resolved';
      case 'Rejected':
        return 'Your complaint was not accepted';
      default:
        return 'Unknown status';
    }
  }

  // Get next possible status for status progression
  static List<String> getNextPossibleStatus(String currentStatus) {
    switch (currentStatus) {
      case pending:
        return [inProgress, rejected];
      case inProgress:
        return [resolved, pending];
      case resolved:
        return [inProgress];
      case rejected:
        return [pending];
      default:
        return [pending];
    }
  }
}

// Add this import at the top of your file if using Timestamp
// import 'package:cloud_firestore/cloud_firestore.dart';