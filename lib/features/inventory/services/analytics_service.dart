import 'package:flutter/foundation.dart';

/// Demo/Analytics tracking events
/// These events track demo mode lifecycle and user interactions
enum DemoAnalyticsEvent {
  demo_started,
  demo_exit_clicked,
  demo_exit_confirmed,
  demo_ended_screen_viewed,
  feedback_form_opened,
  demo_resumed,
  view_plans_clicked,
  talk_to_sales_clicked,
  back_to_home_clicked,
}

/// Analytics service for tracking demo mode and other events
/// 
/// This service is structured to be compatible with Firebase Analytics
/// but defaults to console logging for development.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  /// Log a demo analytics event
  /// 
  /// [reason] can be 'timeExpired' or 'manualExit' for demo ended events
  void logDemoEvent(
    DemoAnalyticsEvent event, {
    String? reason,
    Map<String, dynamic>? customParams,
  }) {
    final params = <String, dynamic>{
      if (reason != null) 'reason': reason,
      if (customParams != null) ...customParams,
    };

    _logEvent(event.name, params);
  }

  /// Internal method to log events to appropriate backend
  void _logEvent(String eventName, Map<String, dynamic> params) {
    // In production, this would send to Firebase Analytics:
    // FirebaseAnalytics.instance.logEvent(
    //   name: eventName,
    //   parameters: params,
    // );

    // For now, log to console for development
    debugPrint('[Analytics] Event: $eventName | Params: $params');
  }

  /// Log demo session started
  void logDemoStarted() {
    logDemoEvent(DemoAnalyticsEvent.demo_started);
  }

  /// Log user clicked exit demo button
  void logDemoExitClicked() {
    logDemoEvent(DemoAnalyticsEvent.demo_exit_clicked);
  }

  /// Log user confirmed exit
  void logDemoExitConfirmed() {
    logDemoEvent(DemoAnalyticsEvent.demo_exit_confirmed);
  }

  /// Log demo ended screen viewed
  void logDemoEndedScreenViewed(String reason) {
    logDemoEvent(
      DemoAnalyticsEvent.demo_ended_screen_viewed,
      reason: reason,
    );
  }

  /// Log feedback form opened
  void logFeedbackFormOpened(String reason) {
    logDemoEvent(
      DemoAnalyticsEvent.feedback_form_opened,
      reason: reason,
    );
  }

  /// Log demo resumed
  void logDemoResumed() {
    logDemoEvent(DemoAnalyticsEvent.demo_resumed);
  }

  /// Log user clicked "View Plans & Upgrade"
  void logViewPlansClicked() {
    logDemoEvent(DemoAnalyticsEvent.view_plans_clicked);
  }

  /// Log user clicked "Talk to Sales"
  void logTalkToSalesClicked() {
    logDemoEvent(DemoAnalyticsEvent.talk_to_sales_clicked);
  }

  /// Log user clicked "Back to Home"
  void logBackToHomeClicked() {
    logDemoEvent(DemoAnalyticsEvent.back_to_home_clicked);
  }
}
