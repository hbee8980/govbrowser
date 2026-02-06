/// App-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'GovBrowser';
  static const String appTagline = 'The Browser that knows you.';

  /// Default URLs
  static const String defaultHomePage = 'https://www.google.com';
  static const List<String> trustedDomains = [
    'ssc.nic.in',
    'upsc.gov.in',
    'ibps.in',
    'rrbcdg.gov.in',
    'sbi.co.in',
    'licindia.in',
    'ncs.gov.in',
    'naukri.com',
  ];

  /// Hive box names
  static const String userProfileBox = 'user_profile_box';
  static const String bookmarksBox = 'bookmarks_box';
  static const String historyBox = 'history_box';

  /// Image compression defaults
  static const int defaultTargetKB = 50;
  static const int minPhotoKB = 20;
  static const int maxPhotoKB = 200;
  static const int minSignatureKB = 10;
  static const int maxSignatureKB = 50;

  /// Category options for user profile
  static const List<String> categoryOptions = [
    'General',
    'OBC',
    'OBC-NCL',
    'SC',
    'ST',
    'EWS',
    'PwBD',
  ];

  /// Gender options
  static const List<String> genderOptions = ['Male', 'Female', 'Transgender'];

  /// Education levels
  static const List<String> educationLevels = [
    '10th',
    '12th',
    'Diploma',
    'ITI',
    'Graduation',
    'Post-Graduation',
    'Professional Degree',
    'PhD',
  ];

  /// Indian states
  static const List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];
}
