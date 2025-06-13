// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'كاشيلو';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get currency => 'العملة';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get clearAllData => 'مسح جميع البيانات';

  @override
  String get about => 'حول التطبيق';

  @override
  String get noTransactionsToday => 'لا توجد معاملات اليوم.';

  @override
  String get monthlySavingGoalProgress => 'تقدم هدف التوفير الشهري';

  @override
  String get selectDateRange => 'حدد نطاق التاريخ لعرض تقاريرك المالية.';
  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get monthlySavingGoal => 'هدف التوفير الشهري';

  @override
  String get cancel => 'إلغاء';

  @override
  String get approve => 'تأكيد';

  @override
  String savingGoalAlert(String balance, String goal) =>
      'رصيدك ($balance) كافٍ لتغطية هدف التوفير الشهري المتبقي ($goal). هل ترغب في تحويل هذا المبلغ إلى أهداف التوفير الآن؟';

  @override
  String congratulationsMessage(String goal) =>
      '🎉 تهانينا! لقد حققت هدف التوفير الشهري ($goal).';

  @override
  String savingProgressMessage(String saved, String goal) =>
      'لقد قمت بتوفير $saved من أصل $goal.';
  @override
  String get noTransactions => 'لم يتم العثور على معاملات.';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get income => 'الدخل';

  @override
  String get expense => 'المصروفات';

  @override
  String get balance => 'الرصيد';

  @override
  String get saving => 'إجمالي التوفير';

  @override
  String get addToSaving => 'أضف إلى التوفير';

  @override
  String get withdraw => 'سحب';

  @override
  String get appDescription =>
      'كاشيلو هو تطبيق مالي شخصي يساعدك على تتبع دخلك ومصروفاتك وأهداف التوفير الخاصة بك.';
  @override
  String get myGoal => 'هدفي المالي';
  @override
  String get activeGoals => 'الأهداف النشطة';
  @override
  String get doneOrStoppedGoals => 'الأهداف المكتملة أو المتوقفة';
  @override
  String get noGoalsYet =>
      'لا توجد أهداف حتى الآن. ابدأ بتحديد هدف مالي جديد لتحقيقه.';
  @override
  String get transactions => 'المعاملات';
  @override
  String get myGoals => 'أهدافي المالية';
  @override
  String get reports => 'التقارير';
  @override
  List<String> get incomeCategories => [
        'الراتب',
        'مكافأة',
        'استثمار',
        'عمل حر',
        'هدية',
        'استرداد',
        'عمل جانبي',
        'منح',
        'أخرى'
      ];

  @override
  List<String> get expenseCategories => [
        'طعام',
        'تسوق',
        'فواتير',
        'نقل',
        'الصحة',
        'التعليم',
        'الترفيه',
        'السفر',
        'البقالة',
        'إيجار',
        'المرافق',
        'تأمين',
        'الاشتراكات',
        'الصدقة',
        'العناية الشخصية',
        'الضرائب',
        'سداد القروض',
        'الحيوانات الأليفة',
        'الهدايا',
        'أخرى'
      ];
  @override
  String get type => 'النوع';
  @override
  String get category => 'الفئة';
  @override
  String get amount => 'المبلغ';
  @override
  String get add => 'إضافة';
  @override
  String get enterValidAmount => 'يرجى إدخال مبلغ صحيح.';
  @override
  String get pickDate => 'اختر التاريخ';
  @override
  String get dGoals => 'توزيع المبلغ بين جميع الأهداف النشطة';
  @override
  String get sGoal => 'إضافة إلى هدف واحد ';
  @override
  String get withDraw => 'سحب من التوفير';
  @override
  String get withdrawFromAll => 'سحب من جميع الأهداف النشطة';
  @override
  String amountWithMax(String max) => 'مبلغ الحد الاقصى $max';
}
