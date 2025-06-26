import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

// 通用提示工具类
class ToastUtil {
  static OverlayEntry? _overlayEntry;

  /// 显示成功提示
  static void showSuccess(BuildContext context, String message) {
    _showCustomToast(context, message, AppConstants.successColor, Colors.white);
  }

  /// 显示错误提示
  static void showError(BuildContext context, String message) {
    _showCustomToast(context, message, AppConstants.errorColor, Colors.white);
  }

  /// 显示警告提示
  static void showWarning(BuildContext context, String message) {
    _showCustomToast(context, message, AppConstants.warningColor, AppConstants.textPrimary);
  }

  /// 显示信息提示
  static void showInfo(BuildContext context, String message) {
    _showCustomToast(context, message, AppConstants.infoColor, Colors.white);
  }

  /// 显示加载提示
  static void showLoading(BuildContext context, String message) {
    _showCustomToast(context, message, Colors.black87, Colors.white);
  }

  static void _showCustomToast(BuildContext context, String message, Color backgroundColor, Color textColor) {
    // 移除之前的提示
    _hideToast();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // 3秒后自动隐藏
    Future.delayed(const Duration(seconds: 3), () {
      _hideToast();
    });
  }

  static void _hideToast() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
} 