import 'package:flutter/material.dart';
import '../services/counselor_service.dart';

class CounselorViewModel extends ChangeNotifier {
  // 咨询师列表
  List<Map<String, dynamic>> counselors = [];

  // 当前咨询师详情
  Map<String, dynamic>? selectedCounselor;

  // 当前咨询师可预约时间
  List<Map<String, dynamic>> schedules = [];

  // 我的预约列表
  List<Map<String, dynamic>> myAppointments = [];

  // 状态
  bool isLoading = false;
  String? errorMessage;

  // 筛选
  String selectedSpecialty = '';

  // ========== 咨询师列表 ==========
  Future<void> fetchCounselors({
    String? specialization,
    double? minRating,
  }) async {
    _setLoading(true);
    try {
      counselors = await CounselorService.fetchCounselors(
        specialization: specialization ?? selectedSpecialty,
        minRating: minRating,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = '$e';
    } finally {
      _setLoading(false);
    }
  }

  void updateSpecialty(String specialty) {
    selectedSpecialty = specialty;
    fetchCounselors();
  }

  // ========== 咨询师详情 ==========
  Future<void> loadConsultantDetail(int consultantId) async {
    _setLoading(true);
    try {
      selectedCounselor = await CounselorService.getConsultantDetail(
        consultantId,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = '$e';
    } finally {
      _setLoading(false);
    }
  }

  // ========== 可预约时间 ==========
  Future<void> fetchSchedules(
    int consultantId, {
    String? startDate,
    String? endDate,
  }) async {
    _setLoading(true);
    try {
      schedules = await CounselorService.getAvailableSchedules(
        consultantId,
        startDate: startDate,
        endDate: endDate,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = '$e';
    } finally {
      _setLoading(false);
    }
  }

  // ========== 创建预约 ==========
  Future<bool> createAppointment({
    required int consultantId,
    required int scheduleId,
    required String date,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      await CounselorService.createAppointment(
        consultantId: consultantId,
        scheduleId: scheduleId,
        appointmentDate: date,
        startTime: startTime,
        endTime: endTime,
        userNotes: notes,
      );
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = '$e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== 我的预约列表 ==========
  Future<void> fetchMyAppointments({String? status}) async {
    _setLoading(true);
    try {
      myAppointments = await CounselorService.getMyAppointments(status: status);
      errorMessage = null;
    } catch (e) {
      errorMessage = '$e';
    } finally {
      _setLoading(false);
    }
  }

  // ========== 取消预约 ==========
  Future<bool> cancelAppointment({
    required int appointmentId,
    required String reason,
  }) async {
    _setLoading(true);
    try {
      await CounselorService.cancelAppointment(
        appointmentId: appointmentId,
        reason: reason,
      );
      myAppointments.removeWhere((a) => a['id'] == appointmentId);
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = '$e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 内部
  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }
}
