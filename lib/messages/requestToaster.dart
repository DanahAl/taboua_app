// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, file_names, unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastManager extends ChangeNotifier {
  Toastification toastification = Toastification();
  ToastificationItem? _previousNotification;

  bool _isToastVisible = false;

  bool get isToastVisible => _isToastVisible;

  set isToastVisible(bool newValue) {
    if (_isToastVisible != newValue) {
      _isToastVisible = newValue;

      if (!_isToastVisible && _previousNotification != null) {
        // Dismiss the previous toast
        toastification.dismiss(_previousNotification!);
        _previousNotification = null;
      }

      notifyListeners();
    }
  }

  void showCustomToast(BuildContext context) {
    _previousNotification = toastification.showCustom(
      context: context,
      autoCloseDuration: const Duration(seconds: 7),
      builder: (BuildContext context, ToastificationItem holder) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xfffe9b00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                              mainAxisAlignment: MainAxisAlignment.end, // Align to the right

                children: [
                  Text(
                    'الرجاء الالتزام بحدود الطرق عند طلب الحاوية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                                    SizedBox(width: 10),

                  Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  ),
                  
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void dismiss() {
    if (_isToastVisible) {
      _isToastVisible = false;
      toastification.dismiss(_previousNotification!);
      _previousNotification = null;
      notifyListeners();
    }
  }
}
