class EndPoints {
  static String firstBaseUrlDev =
      "https://";
  static String secondBaseUrlDev =
      ".saas.loopedsol.com";

  // app version
  static const String getMobileApplicationVersionPath =
      "/lpd/get_mobile_application_version";

  // auth
  static String login = "/lpd/session/authenticate";


  // home 
  static String getUserInfo = "/lpd/hr/my_profile";

  static String changeAttendance = "/lpd/hr/create_attendance_log";

  static String getAttendanceSummary = "/lpd/hr.attendance/summary";

  static String getNotifications = "/lpd/hr/notifications";


  // vacation
  static String getVaction = "/lpd/hr/get_timeoff";

  static String getVactionType = "/lpd/hr.leave.type";

  static String addVacationRequest = "/lpd/hr/create_timeoff";

  // financial commitment
  static String getPetty = "/lpd/hr/get_petty_cash";

  static String getPettyType = "/lpd/petty.cash.type";

  static String addFcRequest = "/lpd/petty.cash";


  // salary
  static String getPayslip = "/lpd/hr/get_employee_payslips";


  // expenses
  static String getExpenses = "/lpd/hr/get_expenses";

  static String getExpensesType = "/lpd/hr/get_expense_products";

  static String createExpensesRequest = "/lpd/hr/create_expense";


  // custody
  static String getCustody = "/lpd/hr/get_custody";


  static String getCustodyType = "/lpd/hr/get_custody_properties";


  static String addCustodyRequest = "/lpd/hr/create_custody";

  // loan
  static String getLoanType = "/lpd/loans.type";

  static String getLoan = "/lpd/hr/get_loans";

  static String addLoanRequest = "/lpd/loan.request";

  // permissions
  static String getPermissions = "/lpd/excuse.request_type";

  static String getPermissionTypes = "/lpd/excuse.request_type";

  static String addPermissionRequest = "/lpd/excuse.request";

  static String getExcuseRequests = "/lpd/hr/excuse_requests";

  // adjustments
  static String getEditedAttendanceLogs = "/lpd/hr/get_edited_attendance_logs";
  static String getAttendanceLogsByDate = "/lpd/hr/get_attendance_logs_by_date";
  static String correctAttendanceLogs = "/lpd/hr/correct_attendance_logs";
  static String getAttendanceByMonth = "/lpd/hr/get_attendance_by_month";

  // overtime
  static String getOvertimeRequests = "/lpd/hr/get_overtime_requests";
  static String createOvertimeRequest = "/lpd/hr/create_overtime_request";

  // team requests
  static String getHrRequests = "/lpd/hr/hr_requests";
  static String approveRequest = "/lpd/hr/approve_request";

  // tasks
  static String getTaskTemplates = "/lpd/ops/task";
  static String getPendingTasks = "/lpd/ops/task";
  static String getPlanLines = "/lpd/ops/task";
  static String getSpecificPlanTasks = "/lpd/ops/task";
  static String taskAnswer = "/lpd/ops/task/answer";

  // letters
  static String getLetter = "/lpd/hr/get_letter_requests";
  static String getLetterTemplates = "/lpd/hr/get_all_letter_template";
  static String createLetterRequest = "/lpd/hr/create_letter_request";

  // end of service
  static String getGratuityReasons = "/lpd/hr/get_gratuity_reasons";
  static String getGratuityRequests = "/lpd/hr/get_gratuity_requests";
  static String createGratuityRequest = "/lpd/hr/create_gratuity_request";

  /// Inventory (Odoo JSON-RPC style over HTTP).
  static const String inventoryGetLocations = "/api/v1/inventory/get_locations";
  static const String inventoryGetProducts = "/api/v1/inventory/get_products";
  static const String inventoryCreateAdjustment =
      "/api/v1/inventory/create_adjustment";
  static const String inventoryUpdateLines = "/api/v1/inventory/update_lines";
  static const String inventoryGetAllAdjustments =
      "/api/v1/inventory/get_all_adjustments";
  static const String inventoryGetAdjustmentDetails =
      "/api/v1/inventory/get_adjustment_details";

  /// Stock / warehouse transfer (Odoo JSON-RPC style over HTTP).
  static const String stockGetAllRequests =
      "/api/v1/stock/get_all_requests";
  static const String stockGetRequestDetails =
      "/api/v1/stock/get_request_details";
  static const String stockGetWarehouses = "/api/v1/stock/get_warehouses";
  static const String stockGetLocations = "/api/v1/stock/get_locations";
  static const String stockCreateRequest = "/api/v1/stock/create_request";
  static const String stockSubmitRequest = "/api/v1/stock/submit_request";
  static const String stockAddRequestLines =
      "/api/v1/stock/add_request_lines";
  static const String stockDeleteRequestLines =
      "/api/v1/stock/delete_request_lines";
  static const String stockUpdateRequestLine =
      "/api/v1/stock/update_request_line";
  static const String stockGetRoutes = "/api/v1/stock/get_routes";
  static const String stockSetRoute = "/api/v1/stock/set_route";
  static const String stockConfirmRequest = "/api/v1/stock/confirm_request";
  static const String stockGetRequestTransfers =
      "/api/v1/stock/get_request_transfers";
  static const String stockGetTransferDetails =
      "/api/v1/get_transfer_details";
  static const String stockProcessTransfer = "/api/v1/process_transfer";
}
