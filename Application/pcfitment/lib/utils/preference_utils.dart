import 'package:flutter/material.dart';
import 'package:pcfitment/screen/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class PreferenceUtils {
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> init() async {
    _prefsInstance ??= await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  static Future<void> clearAllPreferences() async {
    await _prefsInstance?.clear();
  }

  /*static Future<String> getIsLogin() async {
    _checkInitialized();
    String? isLogin = _prefsInstance?.getString(Constants.isLogin);
    return isLogin ?? 'false';
  }

  static Future<bool> setIsLogin(String isLogin) async {
    _checkInitialized();
    // Ensure isLogin is not null or empty here if necessary
    await _prefsInstance!.setString(Constants.isLogin, isLogin);
    return true; // Indicate success with a boolean value
  }*/

  static String getIsLogin() {
    return _prefsInstance?.getString(Constants.isLogin) ?? 'false';
  }

  static Future<bool> setIsLogin(String isLogin) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.isLogin, isLogin);
  }

  static String getFCMId() {
    return _prefsInstance?.getString(Constants.fcmId) ?? '';
  }

  static Future<bool> setFCMId(String fcmId) {
    //ArgumentError.checkNotNull(fcmId, Constants.fcmId);
    _checkInitialized();
    return _prefsInstance!.setString(Constants.fcmId, fcmId);
  }

  static String getMacAddress() {
    return _prefsInstance?.getString(Constants.macAddress) ?? '';
  }

  static Future<bool> setMacAddress(String macAddress) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.macAddress, macAddress);
  }

  static String getDeviceId() {
    return _prefsInstance?.getString(Constants.iemiNo) ?? '';
  }

  static Future<bool> setDeviceId(String iemiNo) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.iemiNo, iemiNo);
  }

  static String getLoginUserId() {
    _checkInitialized();
    return _prefsInstance?.getString(Constants.userId) ?? '';
  }

  static Future<bool> setLoginUserId(String userId) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.userId, userId);
  }

  static String getAuthToken() {
    _checkInitialized();
    return _prefsInstance?.getString(Constants.token) ?? '';
  }

  static Future<bool> setAuthToken(String token) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.token, token);
  }

  static String getLoginEmail() {
    _checkInitialized();
    return _prefsInstance?.getString(Constants.loginEmail) ?? '';
  }

  static Future<bool> setLoginEmail(String loginEmail) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.loginEmail, loginEmail);
  }

  static String getLoginPassword() {
    _checkInitialized();
    return _prefsInstance?.getString(Constants.loginPassword) ?? '';
  }

  static Future<bool> setLoginPassword(String loginPassword) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.loginPassword, loginPassword);
  }

  static String getEmpId() {
    return _prefsInstance?.getString(Constants.empId) ?? '';
  }

  static Future<bool> setEmpId(String empId) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.empId, empId);
  }

  static String getLoginUserName() {
    return _prefsInstance?.getString(Constants.userName) ?? '';
  }

  static Future<bool> setLoginUserName(String userName) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.userName, userName);
  }

  static String getSystemLangCode() {
    return _prefsInstance?.getString(Constants.systemLangCode) ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  }

  static Future<bool> setSystemLangCode(String systemLangCode) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.systemLangCode, systemLangCode);
  }

  static String getSystemCountryCode() {
    return _prefsInstance?.getString(Constants.systemCountryCode) ?? WidgetsBinding.instance.platformDispatcher.locale.countryCode!;
  }

  static Future<bool> setSystemCountryCode(String systemCountryCode) {
    _checkInitialized();
    return _prefsInstance!
        .setString(Constants.systemCountryCode, systemCountryCode);
  }

  static void _checkInitialized() {
    assert(_prefsInstance != null, 'SharedPreferences not initialized');
  }

  static String getLanguageCode() {
    return _prefsInstance?.getString(Constants.languageCode) ?? 'zh';
  }

  static Future<bool> setLanguageCode(String langCode) {
    ArgumentError.checkNotNull(langCode, Constants.languageCode);
    return _prefsInstance!.setString(Constants.languageCode, langCode);
  }

  static SelectedLanguage getSelectedLanguage() {
    final String? language =
        _prefsInstance!.getString(Constants.selectedLanguage);
    return language != null
        ? SelectedLanguage.values.firstWhere(
            (lang) => lang.toString() == language,
            orElse: () =>
                SelectedLanguage.english) // Set default as Chinese if not found
        : SelectedLanguage.english;
  }

  static Future<bool> setSelectedLanguage(String langSelect) {
    ArgumentError.checkNotNull(langSelect, Constants.selectedLanguage);
    return _prefsInstance!.setString(Constants.selectedLanguage, langSelect);
  }

  static String getTermsCondition() {
    return _prefsInstance?.getString(Constants.termsCondition) ?? '';
  }

  static Future<bool> setTermsCondition(String termsCondition) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.termsCondition, termsCondition);
  }

  static String getPrivacyPolicy() {
    return _prefsInstance?.getString(Constants.privacyPolicy) ?? '';
  }

  static Future<bool> setPrivacyPolicy(String privacyPolicy) {
    _checkInitialized();
    return _prefsInstance!.setString(Constants.privacyPolicy, privacyPolicy);
  }
}
