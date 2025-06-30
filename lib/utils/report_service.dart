import 'package:flutter/foundation.dart';
import '../models/travel_blogger.dart';
import 'storage_util.dart';

enum ReportType {
  user,    // 举报用户
  content, // 举报游记内容
}

enum ReportStatus {
  pending,   // 举报内容核实中，请耐心等待处理结果
  processed, // 已处理
}

class ReportItem {
  final String id;
  final ReportType type;
  final String targetId; // 用户ID或游记ID
  final String targetName; // 用户名或游记标题
  final String reason;
  final DateTime reportTime;
  final ReportStatus status;

  ReportItem({
    required this.id,
    required this.type,
    required this.targetId,
    required this.targetName,
    required this.reason,
    required this.reportTime,
    this.status = ReportStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'targetId': targetId,
      'targetName': targetName,
      'reason': reason,
      'reportTime': reportTime.millisecondsSinceEpoch,
      'status': status.toString(),
    };
  }

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      id: json['id'],
      type: ReportType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      targetId: json['targetId'],
      targetName: json['targetName'],
      reason: json['reason'],
      reportTime: DateTime.fromMillisecondsSinceEpoch(json['reportTime']),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReportStatus.pending,
      ),
    );
  }
}

class ReportService extends ChangeNotifier {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  static ReportService get instance => _instance;

  List<ReportItem> _reports = [];
  static const String _storageKey = 'user_reports';

  List<ReportItem> get reports => List.unmodifiable(_reports);

  /// 初始化，从本地存储加载举报记录
  Future<void> initialize() async {
    try {
      final List<String>? reportJsonList = await StorageUtil.getStringList(_storageKey);
      if (reportJsonList != null) {
        _reports = reportJsonList.map((jsonStr) {
          final Map<String, dynamic> json = 
              Map<String, dynamic>.from(Uri.splitQueryString(jsonStr));
          return ReportItem.fromJson(json);
        }).toList();
      }
    } catch (e) {
      print('加载举报记录失败: $e');
      _reports = [];
    }
  }

  /// 保存举报记录到本地存储
  Future<void> _saveToStorage() async {
    try {
      final List<String> reportJsonList = _reports.map((report) {
        return Uri(queryParameters: report.toJson().map(
          (key, value) => MapEntry(key, value.toString()),
        )).query;
      }).toList();
      
      await StorageUtil.setStringList(_storageKey, reportJsonList);
    } catch (e) {
      print('保存举报记录失败: $e');
    }
  }

  /// 举报用户
  Future<bool> reportUser({
    required String userId,
    required String userName,
    required String reason,
  }) async {
    try {
      // 检查是否已经举报过这个用户
      final existingReport = _reports.firstWhere(
        (report) => report.type == ReportType.user && 
                   report.targetId == userId &&
                   report.status == ReportStatus.pending,
        orElse: () => ReportItem(
          id: '',
          type: ReportType.user,
          targetId: '',
          targetName: '',
          reason: '',
          reportTime: DateTime.now(),
        ),
      );

      if (existingReport.id.isNotEmpty) {
        return false; // 已经举报过了
      }

      final report = ReportItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: ReportType.user,
        targetId: userId,
        targetName: userName,
        reason: reason,
        reportTime: DateTime.now(),
      );

      _reports.add(report);
      await _saveToStorage();
      notifyListeners();
      return true;
    } catch (e) {
      print('举报用户失败: $e');
      return false;
    }
  }

  /// 举报游记内容
  Future<bool> reportContent({
    required String contentId,
    required String contentTitle,
    required String reason,
  }) async {
    try {
      // 检查是否已经举报过这个内容
      final existingReport = _reports.firstWhere(
        (report) => report.type == ReportType.content && 
                   report.targetId == contentId &&
                   report.status == ReportStatus.pending,
        orElse: () => ReportItem(
          id: '',
          type: ReportType.content,
          targetId: '',
          targetName: '',
          reason: '',
          reportTime: DateTime.now(),
        ),
      );

      if (existingReport.id.isNotEmpty) {
        return false; // 已经举报过了
      }

      final report = ReportItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: ReportType.content,
        targetId: contentId,
        targetName: contentTitle,
        reason: reason,
        reportTime: DateTime.now(),
      );

      _reports.add(report);
      await _saveToStorage();
      notifyListeners();
      return true;
    } catch (e) {
      print('举报内容失败: $e');
      return false;
    }
  }

  /// 检查是否已经举报过用户
  bool hasReportedUser(String userId) {
    return _reports.any(
      (report) => report.type == ReportType.user && 
                 report.targetId == userId &&
                 report.status == ReportStatus.pending,
    );
  }

  /// 检查是否已经举报过内容
  bool hasReportedContent(String contentId) {
    return _reports.any(
      (report) => report.type == ReportType.content && 
                 report.targetId == contentId &&
                 report.status == ReportStatus.pending,
    );
  }

  /// 获取举报状态文本
  String getReportStatusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return '举报内容核实中，请耐心等待处理结果';
      case ReportStatus.processed:
        return '已处理';
    }
  }

  /// 获取用户的举报记录
  List<ReportItem> getUserReports() {
    return _reports.where((report) => report.type == ReportType.user).toList();
  }

  /// 获取内容的举报记录
  List<ReportItem> getContentReports() {
    return _reports.where((report) => report.type == ReportType.content).toList();
  }

  /// 清空所有举报记录（测试用）
  Future<void> clearAllReports() async {
    _reports.clear();
    await _saveToStorage();
    notifyListeners();
  }
} 