import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_br.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('br'),
    Locale('ca'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hu'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('sv'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Tuner'**
  String get appName;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'{value} %%'**
  String percent(Object value);

  /// No description provided for @hertz.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String hertz(Object value);

  /// No description provided for @hertz1f.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String hertz1f(Object value);

  /// No description provided for @hertzStr.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String hertzStr(Object value);

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{value} s'**
  String seconds(Object value);

  /// No description provided for @windowingFunction.
  ///
  /// In en, this message translates to:
  /// **'Windowing function'**
  String get windowingFunction;

  /// No description provided for @windowHamming.
  ///
  /// In en, this message translates to:
  /// **'Hamming window'**
  String get windowHamming;

  /// No description provided for @windowHann.
  ///
  /// In en, this message translates to:
  /// **'Hann window'**
  String get windowHann;

  /// No description provided for @noWindow.
  ///
  /// In en, this message translates to:
  /// **'No windowing function'**
  String get noWindow;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkAppearance.
  ///
  /// In en, this message translates to:
  /// **'Dark appearance'**
  String get darkAppearance;

  /// No description provided for @lightAppearance.
  ///
  /// In en, this message translates to:
  /// **'Light appearance'**
  String get lightAppearance;

  /// No description provided for @systemAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance follows system settings'**
  String get systemAppearance;

  /// No description provided for @darkAppearanceShort.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkAppearanceShort;

  /// No description provided for @lightAppearanceShort.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightAppearanceShort;

  /// No description provided for @systemAppearanceShort.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get systemAppearanceShort;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @overlap.
  ///
  /// In en, this message translates to:
  /// **'Window overlap'**
  String get overlap;

  /// No description provided for @windowSize.
  ///
  /// In en, this message translates to:
  /// **'Window size'**
  String get windowSize;

  /// No description provided for @minimumFrequency.
  ///
  /// In en, this message translates to:
  /// **'Minimum frequency: '**
  String get minimumFrequency;

  /// No description provided for @pitchHistoryDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration of pitch history'**
  String get pitchHistoryDuration;

  /// No description provided for @pitchHistoryNumFaultyValues.
  ///
  /// In en, this message translates to:
  /// **'Jump to new pitch'**
  String get pitchHistoryNumFaultyValues;

  /// No description provided for @numMovingAverage.
  ///
  /// In en, this message translates to:
  /// **'Moving average'**
  String get numMovingAverage;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutMessage.
  ///
  /// In en, this message translates to:
  /// **'Tuner app\nVersion: {value}\nLicense: GPLv3\nhttps://codeberg.org/thetwom/Tuner'**
  String aboutMessage(Object value);

  /// No description provided for @resetAllSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings'**
  String get resetAllSettings;

  /// No description provided for @resetSettingsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to reset all settings?'**
  String get resetSettingsPrompt;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @autocorrelation.
  ///
  /// In en, this message translates to:
  /// **'autocorrelation'**
  String get autocorrelation;

  /// No description provided for @pitchHistory.
  ///
  /// In en, this message translates to:
  /// **'pitch history'**
  String get pitchHistory;

  /// No description provided for @spectrum.
  ///
  /// In en, this message translates to:
  /// **'spectrum'**
  String get spectrum;

  /// No description provided for @cent.
  ///
  /// In en, this message translates to:
  /// **'{value} ¢'**
  String cent(Object value);

  /// No description provided for @centNosign.
  ///
  /// In en, this message translates to:
  /// **'{value} ¢'**
  String centNosign(Object value);

  /// No description provided for @cent1f.
  ///
  /// In en, this message translates to:
  /// **'{value} ¢'**
  String cent1f(Object value);

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepScreenOn;

  /// No description provided for @displayOnLockScreen.
  ///
  /// In en, this message translates to:
  /// **'Display on lock screen'**
  String get displayOnLockScreen;

  /// No description provided for @samples.
  ///
  /// In en, this message translates to:
  /// **'samples'**
  String get samples;

  /// No description provided for @scientificMode.
  ///
  /// In en, this message translates to:
  /// **'Scientific mode'**
  String get scientificMode;

  /// No description provided for @toleranceInCents.
  ///
  /// In en, this message translates to:
  /// **'Tolerance'**
  String get toleranceInCents;

  /// No description provided for @toleranceSummary.
  ///
  /// In en, this message translates to:
  /// **'±{value} ¢'**
  String toleranceSummary(Object value);

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @chromatic.
  ///
  /// In en, this message translates to:
  /// **'Chromatic'**
  String get chromatic;

  /// No description provided for @guitarEadgbe.
  ///
  /// In en, this message translates to:
  /// **'6-string guitar'**
  String get guitarEadgbe;

  /// No description provided for @bassEadg.
  ///
  /// In en, this message translates to:
  /// **'4-string bass'**
  String get bassEadg;

  /// No description provided for @bassBeadg.
  ///
  /// In en, this message translates to:
  /// **'5-string bass'**
  String get bassBeadg;

  /// No description provided for @ukuleleGcea.
  ///
  /// In en, this message translates to:
  /// **'Ukulele'**
  String get ukuleleGcea;

  /// No description provided for @cNoteName.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get cNoteName;

  /// No description provided for @dNoteName.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get dNoteName;

  /// No description provided for @eNoteName.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get eNoteName;

  /// No description provided for @fNoteName.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fNoteName;

  /// No description provided for @gNoteName.
  ///
  /// In en, this message translates to:
  /// **'G'**
  String get gNoteName;

  /// No description provided for @aNoteName.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get aNoteName;

  /// No description provided for @bNoteName.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get bNoteName;

  /// No description provided for @bflatNoteName.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get bflatNoteName;

  /// No description provided for @cSolfege.
  ///
  /// In en, this message translates to:
  /// **'Do'**
  String get cSolfege;

  /// No description provided for @dSolfege.
  ///
  /// In en, this message translates to:
  /// **'Re'**
  String get dSolfege;

  /// No description provided for @eSolfege.
  ///
  /// In en, this message translates to:
  /// **'Mi'**
  String get eSolfege;

  /// No description provided for @fSolfege.
  ///
  /// In en, this message translates to:
  /// **'Fa'**
  String get fSolfege;

  /// No description provided for @gSolfege.
  ///
  /// In en, this message translates to:
  /// **'Sol'**
  String get gSolfege;

  /// No description provided for @aSolfege.
  ///
  /// In en, this message translates to:
  /// **'La'**
  String get aSolfege;

  /// No description provided for @bSolfege.
  ///
  /// In en, this message translates to:
  /// **'Si'**
  String get bSolfege;

  /// No description provided for @cNoteInternational.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get cNoteInternational;

  /// No description provided for @dNoteInternational.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get dNoteInternational;

  /// No description provided for @eNoteInternational.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get eNoteInternational;

  /// No description provided for @fNoteInternational.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fNoteInternational;

  /// No description provided for @gNoteInternational.
  ///
  /// In en, this message translates to:
  /// **'G'**
  String get gNoteInternational;

  /// No description provided for @aNoteInternational.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get aNoteInternational;

  /// No description provided for @bNoteInternational.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get bNoteInternational;

  /// No description provided for @notation.
  ///
  /// In en, this message translates to:
  /// **'Notation'**
  String get notation;

  /// No description provided for @notationRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional'**
  String get notationRegional;

  /// No description provided for @notationRegionalDescription.
  ///
  /// In en, this message translates to:
  /// **'C-D-E-…-B'**
  String get notationRegionalDescription;

  /// No description provided for @notationSolfege.
  ///
  /// In en, this message translates to:
  /// **'Solfège'**
  String get notationSolfege;

  /// No description provided for @notationSolfegeDescription.
  ///
  /// In en, this message translates to:
  /// **'Do-Re-Mi-…-Si'**
  String get notationSolfegeDescription;

  /// No description provided for @notationInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get notationInternational;

  /// No description provided for @notationInternationalDescription.
  ///
  /// In en, this message translates to:
  /// **'C-D-E-…-B'**
  String get notationInternationalDescription;

  /// No description provided for @violinGdae.
  ///
  /// In en, this message translates to:
  /// **'Violin'**
  String get violinGdae;

  /// No description provided for @abort.
  ///
  /// In en, this message translates to:
  /// **'Abort'**
  String get abort;

  /// No description provided for @instrumentName.
  ///
  /// In en, this message translates to:
  /// **'Instrument name'**
  String get instrumentName;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNote;

  /// No description provided for @latelyDetectedNotes.
  ///
  /// In en, this message translates to:
  /// **'Lately detected tones'**
  String get latelyDetectedNotes;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @editInstrument.
  ///
  /// In en, this message translates to:
  /// **'Edit instrument'**
  String get editInstrument;

  /// No description provided for @predefinedItems.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get predefinedItems;

  /// No description provided for @customItem.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customItem;

  /// No description provided for @fileEmpty.
  ///
  /// In en, this message translates to:
  /// **'File is empty: {value}'**
  String fileEmpty(Object value);

  /// No description provided for @fileInvalid.
  ///
  /// In en, this message translates to:
  /// **'File is invalid: {value}'**
  String fileInvalid(Object value);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @pickIcon.
  ///
  /// In en, this message translates to:
  /// **'Pick icon'**
  String get pickIcon;

  /// No description provided for @copyExtension.
  ///
  /// In en, this message translates to:
  /// **'{value} (copy)'**
  String copyExtension(Object value);

  /// No description provided for @failedToArchiveItems.
  ///
  /// In en, this message translates to:
  /// **'Failed to write items to file'**
  String get failedToArchiveItems;

  /// No description provided for @databaseEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no items which can be saved.'**
  String get databaseEmpty;

  /// No description provided for @replaceCurrentList.
  ///
  /// In en, this message translates to:
  /// **'Replace current list'**
  String get replaceCurrentList;

  /// No description provided for @prependCurrentList.
  ///
  /// In en, this message translates to:
  /// **'Prepend to current list'**
  String get prependCurrentList;

  /// No description provided for @appendCurrentList.
  ///
  /// In en, this message translates to:
  /// **'Append to current list'**
  String get appendCurrentList;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share items'**
  String get share;

  /// No description provided for @loadFromDisk.
  ///
  /// In en, this message translates to:
  /// **'Load items from file'**
  String get loadFromDisk;

  /// No description provided for @saveToDisk.
  ///
  /// In en, this message translates to:
  /// **'Save items to file'**
  String get saveToDisk;

  /// No description provided for @preferFlat.
  ///
  /// In en, this message translates to:
  /// **'Prefer \\u266D over \\u266F'**
  String get preferFlat;

  /// No description provided for @violaCgda.
  ///
  /// In en, this message translates to:
  /// **'Viola'**
  String get violaCgda;

  /// No description provided for @celloCgda.
  ///
  /// In en, this message translates to:
  /// **'Cello'**
  String get celloCgda;

  /// No description provided for @doubleBassEadg.
  ///
  /// In en, this message translates to:
  /// **'Double bass'**
  String get doubleBassEadg;

  /// No description provided for @equalTemperament12.
  ///
  /// In en, this message translates to:
  /// **'Equal temperament'**
  String get equalTemperament12;

  /// No description provided for @equalTemperamentX.
  ///
  /// In en, this message translates to:
  /// **'Equal temperament {value}'**
  String equalTemperamentX(Object value);

  /// No description provided for @equalTemperamentXAbbr.
  ///
  /// In en, this message translates to:
  /// **'EDO {value}'**
  String equalTemperamentXAbbr(Object value);

  /// No description provided for @pythagoreanTuning.
  ///
  /// In en, this message translates to:
  /// **'Pythagorean tuning'**
  String get pythagoreanTuning;

  /// No description provided for @pythagoreanTuningAbbr.
  ///
  /// In en, this message translates to:
  /// **'Pythagorean'**
  String get pythagoreanTuningAbbr;

  /// No description provided for @pureTuning.
  ///
  /// In en, this message translates to:
  /// **'Just tuning'**
  String get pureTuning;

  /// No description provided for @pureTuningDesc.
  ///
  /// In en, this message translates to:
  /// **'5-limit, asymmetric scale'**
  String get pureTuningDesc;

  /// No description provided for @pureTuningAbbr.
  ///
  /// In en, this message translates to:
  /// **'Just'**
  String get pureTuningAbbr;

  /// No description provided for @quarterCommaMeanTone.
  ///
  /// In en, this message translates to:
  /// **'¼ comma meantone'**
  String get quarterCommaMeanTone;

  /// No description provided for @quarterCommaMeanToneDesc.
  ///
  /// In en, this message translates to:
  /// **'Pure major 3rds'**
  String get quarterCommaMeanToneDesc;

  /// No description provided for @quarterCommaMeanToneAbbr.
  ///
  /// In en, this message translates to:
  /// **'¼ comma meantone'**
  String get quarterCommaMeanToneAbbr;

  /// No description provided for @thirdCommaMeanTone.
  ///
  /// In en, this message translates to:
  /// **'⅓ comma meantone'**
  String get thirdCommaMeanTone;

  /// No description provided for @thirdCommaMeanToneDesc.
  ///
  /// In en, this message translates to:
  /// **'Pure minor 3rds'**
  String get thirdCommaMeanToneDesc;

  /// No description provided for @thirdCommaMeanToneAbbr.
  ///
  /// In en, this message translates to:
  /// **'⅓ comma meantone'**
  String get thirdCommaMeanToneAbbr;

  /// No description provided for @fifthCommaMeanTone.
  ///
  /// In en, this message translates to:
  /// **'⅕ comma meantone'**
  String get fifthCommaMeanTone;

  /// No description provided for @fifthCommaMeanToneDesc.
  ///
  /// In en, this message translates to:
  /// **'Pure diatonic semitones'**
  String get fifthCommaMeanToneDesc;

  /// No description provided for @fifthCommaMeanToneAbbr.
  ///
  /// In en, this message translates to:
  /// **'⅕ comma meantone'**
  String get fifthCommaMeanToneAbbr;

  /// No description provided for @werckmeisterIii.
  ///
  /// In en, this message translates to:
  /// **'Werckmeister III'**
  String get werckmeisterIii;

  /// No description provided for @werckmeisterIiiDesc.
  ///
  /// In en, this message translates to:
  /// **'¼ comma divisions'**
  String get werckmeisterIiiDesc;

  /// No description provided for @werckmeisterIiiAbbr.
  ///
  /// In en, this message translates to:
  /// **'Werckmeister III'**
  String get werckmeisterIiiAbbr;

  /// No description provided for @werckmeisterIv.
  ///
  /// In en, this message translates to:
  /// **'Werckmeister IV'**
  String get werckmeisterIv;

  /// No description provided for @werckmeisterIvDesc.
  ///
  /// In en, this message translates to:
  /// **'⅓ comma divisions'**
  String get werckmeisterIvDesc;

  /// No description provided for @werckmeisterIvAbbr.
  ///
  /// In en, this message translates to:
  /// **'Werckmeister IV'**
  String get werckmeisterIvAbbr;

  /// No description provided for @werckmeisterV.
  ///
  /// In en, this message translates to:
  /// **'Werckmeister V'**
  String get werckmeisterV;

  /// No description provided for @werckmeisterVDesc.
  ///
  /// In en, this message translates to:
  /// **'Other ¼ comma divisions'**
  String get werckmeisterVDesc;

  /// No description provided for @werckmeisterVAbbr.
  ///
  /// In en, this message translates to:
  /// **'Werckmeister V'**
  String get werckmeisterVAbbr;

  /// No description provided for @werckmeisterVi.
  ///
  /// In en, this message translates to:
  /// **'Werckmeister VI'**
  String get werckmeisterVi;

  /// No description provided for @werckmeisterViDesc.
  ///
  /// In en, this message translates to:
  /// **'Septenarius'**
  String get werckmeisterViDesc;

  /// No description provided for @werckmeisterViAbbr.
  ///
  /// In en, this message translates to:
  /// **'Werckmeister VI'**
  String get werckmeisterViAbbr;

  /// No description provided for @kirnberger1.
  ///
  /// In en, this message translates to:
  /// **'Kirnberger I'**
  String get kirnberger1;

  /// No description provided for @kirnberger1Desc.
  ///
  /// In en, this message translates to:
  /// **'One syntonic comma'**
  String get kirnberger1Desc;

  /// No description provided for @kirnberger1Abbr.
  ///
  /// In en, this message translates to:
  /// **'Kirnberger I'**
  String get kirnberger1Abbr;

  /// No description provided for @kirnberger2.
  ///
  /// In en, this message translates to:
  /// **'Kirnberger II'**
  String get kirnberger2;

  /// No description provided for @kirnberger2Desc.
  ///
  /// In en, this message translates to:
  /// **'½ syntonic comma divisions'**
  String get kirnberger2Desc;

  /// No description provided for @kirnberger2Abbr.
  ///
  /// In en, this message translates to:
  /// **'Kirnberger II'**
  String get kirnberger2Abbr;

  /// No description provided for @kirnberger3.
  ///
  /// In en, this message translates to:
  /// **'Kirnberger III'**
  String get kirnberger3;

  /// No description provided for @kirnberger3Desc.
  ///
  /// In en, this message translates to:
  /// **'¼ syntonic comma divisions'**
  String get kirnberger3Desc;

  /// No description provided for @kirnberger3Abbr.
  ///
  /// In en, this message translates to:
  /// **'Kirnberger III'**
  String get kirnberger3Abbr;

  /// No description provided for @neidhardt1.
  ///
  /// In en, this message translates to:
  /// **'Neidhardt 1'**
  String get neidhardt1;

  /// No description provided for @neidhardt1Desc.
  ///
  /// In en, this message translates to:
  /// **'For a village, 1732'**
  String get neidhardt1Desc;

  /// No description provided for @neidhardt1Abbr.
  ///
  /// In en, this message translates to:
  /// **'Neidhardt 1'**
  String get neidhardt1Abbr;

  /// No description provided for @neidhardt2.
  ///
  /// In en, this message translates to:
  /// **'Neidhardt 2'**
  String get neidhardt2;

  /// No description provided for @neidhardt2Desc.
  ///
  /// In en, this message translates to:
  /// **'For a small town, 1732'**
  String get neidhardt2Desc;

  /// No description provided for @neidhardt2Abbr.
  ///
  /// In en, this message translates to:
  /// **'Neidhardt 2'**
  String get neidhardt2Abbr;

  /// No description provided for @neidhardt3.
  ///
  /// In en, this message translates to:
  /// **'Neidhardt 3'**
  String get neidhardt3;

  /// No description provided for @neidhardt3Desc.
  ///
  /// In en, this message translates to:
  /// **'For a big city, 1732'**
  String get neidhardt3Desc;

  /// No description provided for @neidhardt3Abbr.
  ///
  /// In en, this message translates to:
  /// **'Neidhardt 3'**
  String get neidhardt3Abbr;

  /// No description provided for @valotti.
  ///
  /// In en, this message translates to:
  /// **'Vallotti'**
  String get valotti;

  /// No description provided for @valottiAbbr.
  ///
  /// In en, this message translates to:
  /// **'Vallotti'**
  String get valottiAbbr;

  /// No description provided for @young2.
  ///
  /// In en, this message translates to:
  /// **'Young 2'**
  String get young2;

  /// No description provided for @young2Abbr.
  ///
  /// In en, this message translates to:
  /// **'Young 2'**
  String get young2Abbr;

  /// No description provided for @referenceFrequency.
  ///
  /// In en, this message translates to:
  /// **'Reference frequency'**
  String get referenceFrequency;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @temperament.
  ///
  /// In en, this message translates to:
  /// **'Temperament'**
  String get temperament;

  /// No description provided for @rootNote.
  ///
  /// In en, this message translates to:
  /// **'Key note'**
  String get rootNote;

  /// No description provided for @testTuning.
  ///
  /// In en, this message translates to:
  /// **'Test tuning'**
  String get testTuning;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @pythagoreanComma.
  ///
  /// In en, this message translates to:
  /// **'{val1}\\u2044{val2} pC'**
  String pythagoreanComma(Object val1, Object val2);

  /// No description provided for @syntonicComma.
  ///
  /// In en, this message translates to:
  /// **'{val1}\\u2044{val2} sC'**
  String syntonicComma(Object val1, Object val2);

  /// No description provided for @schisma.
  ///
  /// In en, this message translates to:
  /// **'{val1}\\u2044{val2} sch'**
  String schisma(Object val1, Object val2);

  /// No description provided for @plusCorrection.
  ///
  /// In en, this message translates to:
  /// **' + '**
  String get plusCorrection;

  /// No description provided for @minusCorrection.
  ///
  /// In en, this message translates to:
  /// **' - '**
  String get minusCorrection;

  /// No description provided for @pythagoreanCommaDesc.
  ///
  /// In en, this message translates to:
  /// **'pC: Pythagorean Comma, 531441\\u2044524288\nsC: Syntonic Comma, 81\\u204480\nsch: Schisma, 32805\\u204432768'**
  String get pythagoreanCommaDesc;

  /// No description provided for @circleOfFifths.
  ///
  /// In en, this message translates to:
  /// **'Circle of fifths'**
  String get circleOfFifths;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get setDefault;

  /// No description provided for @acknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get acknowledged;

  /// No description provided for @blackNightMode.
  ///
  /// In en, this message translates to:
  /// **'Black background in dark mode'**
  String get blackNightMode;

  /// No description provided for @systemColorAccents.
  ///
  /// In en, this message translates to:
  /// **'Color accents from system'**
  String get systemColorAccents;

  /// No description provided for @incorrectTemperament.
  ///
  /// In en, this message translates to:
  /// **'Incompatible temperament!'**
  String get incorrectTemperament;

  /// No description provided for @keySignatureSharp.
  ///
  /// In en, this message translates to:
  /// **'Key signature: one more sharp or one less flat'**
  String get keySignatureSharp;

  /// No description provided for @keySignatureFlat.
  ///
  /// In en, this message translates to:
  /// **'Key signature: one more flat or one less sharp'**
  String get keySignatureFlat;

  /// No description provided for @staffClef.
  ///
  /// In en, this message translates to:
  /// **'Clef'**
  String get staffClef;

  /// No description provided for @staffClefGrand.
  ///
  /// In en, this message translates to:
  /// **'Piano (treble and bass)'**
  String get staffClefGrand;

  /// No description provided for @staffClefTreble.
  ///
  /// In en, this message translates to:
  /// **'Treble'**
  String get staffClefTreble;

  /// No description provided for @staffClefTenor.
  ///
  /// In en, this message translates to:
  /// **'Tenor (octave treble)'**
  String get staffClefTenor;

  /// No description provided for @staffClefBass.
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get staffClefBass;

  /// No description provided for @chromaticAsStaff.
  ///
  /// In en, this message translates to:
  /// **'Chromatic tuner as note staff'**
  String get chromaticAsStaff;

  /// No description provided for @chromaticAsStaffSummary.
  ///
  /// In en, this message translates to:
  /// **'Show the target note on a staff instead of the list of all notes'**
  String get chromaticAsStaffSummary;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @newTemperamentRequiresAdaptingReferenceNote.
  ///
  /// In en, this message translates to:
  /// **'New temperament requires adapting the reference note!'**
  String get newTemperamentRequiresAdaptingReferenceNote;

  /// No description provided for @commaSeparator.
  ///
  /// In en, this message translates to:
  /// **',\\ '**
  String get commaSeparator;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @captureDuration.
  ///
  /// In en, this message translates to:
  /// **'Capture duration: {value} s'**
  String captureDuration(Object value);

  /// No description provided for @noCaptureDuration.
  ///
  /// In en, this message translates to:
  /// **'Disable capturing'**
  String get noCaptureDuration;

  /// No description provided for @saCarnatic.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get saCarnatic;

  /// No description provided for @ri1Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Ri₁'**
  String get ri1Carnatic;

  /// No description provided for @ri2Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Ri₂'**
  String get ri2Carnatic;

  /// No description provided for @ga1Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Ga₁'**
  String get ga1Carnatic;

  /// No description provided for @ga2Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Ga₂'**
  String get ga2Carnatic;

  /// No description provided for @ma1Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Ma₁'**
  String get ma1Carnatic;

  /// No description provided for @ma2Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Ma₂'**
  String get ma2Carnatic;

  /// No description provided for @paCarnatic.
  ///
  /// In en, this message translates to:
  /// **'Pa'**
  String get paCarnatic;

  /// No description provided for @dha1Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Dha₁'**
  String get dha1Carnatic;

  /// No description provided for @dha2Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Dha₂'**
  String get dha2Carnatic;

  /// No description provided for @ni1Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Ni₁'**
  String get ni1Carnatic;

  /// No description provided for @ni2Carnatic.
  ///
  /// In en, this message translates to:
  /// **'Ni₂'**
  String get ni2Carnatic;

  /// No description provided for @notationCarnatic.
  ///
  /// In en, this message translates to:
  /// **'Carnatic'**
  String get notationCarnatic;

  /// No description provided for @notationCarnaticDescription.
  ///
  /// In en, this message translates to:
  /// **'Sa-Ri₁-Ri₂-…-Ni₂'**
  String get notationCarnaticDescription;

  /// No description provided for @saHindustani.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get saHindustani;

  /// No description provided for @re1Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Re₁'**
  String get re1Hindustani;

  /// No description provided for @re2Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Re₂'**
  String get re2Hindustani;

  /// No description provided for @ga1Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Ga₁'**
  String get ga1Hindustani;

  /// No description provided for @ga2Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Ga₂'**
  String get ga2Hindustani;

  /// No description provided for @ma1Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Ma₁'**
  String get ma1Hindustani;

  /// No description provided for @ma2Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Ma₂'**
  String get ma2Hindustani;

  /// No description provided for @paHindustani.
  ///
  /// In en, this message translates to:
  /// **'Pa'**
  String get paHindustani;

  /// No description provided for @dha1Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Dha₁'**
  String get dha1Hindustani;

  /// No description provided for @dha2Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Dha₂'**
  String get dha2Hindustani;

  /// No description provided for @ni1Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Ni₁'**
  String get ni1Hindustani;

  /// No description provided for @ni2Hindustani.
  ///
  /// In en, this message translates to:
  /// **'Ni₂'**
  String get ni2Hindustani;

  /// No description provided for @notationHindustani.
  ///
  /// In en, this message translates to:
  /// **'Hindustani'**
  String get notationHindustani;

  /// No description provided for @notationHindustaniDescription.
  ///
  /// In en, this message translates to:
  /// **'Sa-Re₁-Re₂-…-Ni₂'**
  String get notationHindustaniDescription;

  /// No description provided for @niByzantine.
  ///
  /// In en, this message translates to:
  /// **'Νη'**
  String get niByzantine;

  /// No description provided for @paByzantine.
  ///
  /// In en, this message translates to:
  /// **'Πα'**
  String get paByzantine;

  /// No description provided for @vouByzantine.
  ///
  /// In en, this message translates to:
  /// **'Βου'**
  String get vouByzantine;

  /// No description provided for @ghaByzantine.
  ///
  /// In en, this message translates to:
  /// **'Γα'**
  String get ghaByzantine;

  /// No description provided for @dhiByzantine.
  ///
  /// In en, this message translates to:
  /// **'Δι'**
  String get dhiByzantine;

  /// No description provided for @keByzantine.
  ///
  /// In en, this message translates to:
  /// **'Κε'**
  String get keByzantine;

  /// No description provided for @zoByzantine.
  ///
  /// In en, this message translates to:
  /// **'Ζω'**
  String get zoByzantine;

  /// No description provided for @notationByzantine.
  ///
  /// In en, this message translates to:
  /// **'Byzantine'**
  String get notationByzantine;

  /// No description provided for @notationByzantineDescription.
  ///
  /// In en, this message translates to:
  /// **'Νη-Πα-Βου-…-Ζω'**
  String get notationByzantineDescription;

  /// No description provided for @extendedQuarterCommaMeanTone.
  ///
  /// In en, this message translates to:
  /// **'Extended ¼ comma meantone'**
  String get extendedQuarterCommaMeanTone;

  /// No description provided for @extendedQuarterCommaMeanToneDesc.
  ///
  /// In en, this message translates to:
  /// **'Pure major 3rds, 15 notes'**
  String get extendedQuarterCommaMeanToneDesc;

  /// No description provided for @extendedQuarterCommaMeanToneAbbr.
  ///
  /// In en, this message translates to:
  /// **'Extended ¼ comma meantone'**
  String get extendedQuarterCommaMeanToneAbbr;

  /// No description provided for @sensitivity.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get sensitivity;

  /// No description provided for @deleteItems.
  ///
  /// In en, this message translates to:
  /// **'Delete items'**
  String get deleteItems;

  /// No description provided for @databaseEmptyShare.
  ///
  /// In en, this message translates to:
  /// **'There are no items to share.'**
  String get databaseEmptyShare;

  /// No description provided for @audioRecordPermissionRationale.
  ///
  /// In en, this message translates to:
  /// **'Grant microphone access to start tuning.'**
  String get audioRecordPermissionRationale;

  /// No description provided for @soundSourceInvalidBufferSize.
  ///
  /// In en, this message translates to:
  /// **'Recording audio is not supported with the current settings (error {value}).'**
  String soundSourceInvalidBufferSize(Object value);

  /// No description provided for @soundSourceMicrophoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot access the microphone. Another app might be using it.'**
  String get soundSourceMicrophoneUnavailable;

  /// No description provided for @soundSourceReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Recording from the microphone failed (error {value}). Another app might be using it.'**
  String soundSourceReadFailed(Object value);

  /// No description provided for @writingWaveFile.
  ///
  /// In en, this message translates to:
  /// **'Writing wave file: {value}'**
  String writingWaveFile(Object value);

  /// No description provided for @failedWritingWaveFile.
  ///
  /// In en, this message translates to:
  /// **'Did not write wave file.'**
  String get failedWritingWaveFile;

  /// No description provided for @instruments.
  ///
  /// In en, this message translates to:
  /// **'Instruments'**
  String get instruments;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @temperaments.
  ///
  /// In en, this message translates to:
  /// **'Temperaments'**
  String get temperaments;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @temperamentEditor.
  ///
  /// In en, this message translates to:
  /// **'Edit temperament'**
  String get temperamentEditor;

  /// No description provided for @noteNumber.
  ///
  /// In en, this message translates to:
  /// **'Number of notes'**
  String get noteNumber;

  /// No description provided for @centStr.
  ///
  /// In en, this message translates to:
  /// **'cent'**
  String get centStr;

  /// No description provided for @octaveOffset.
  ///
  /// In en, this message translates to:
  /// **'Octave offset'**
  String get octaveOffset;

  /// No description provided for @ratio.
  ///
  /// In en, this message translates to:
  /// **'ratio'**
  String get ratio;

  /// No description provided for @temperamentName.
  ///
  /// In en, this message translates to:
  /// **'Temperament name'**
  String get temperamentName;

  /// No description provided for @temperamentAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'Abbreviation'**
  String get temperamentAbbreviation;

  /// No description provided for @temperamentDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get temperamentDescription;

  /// No description provided for @decreasingValueError.
  ///
  /// In en, this message translates to:
  /// **'Value must be greater than the previous one.'**
  String get decreasingValueError;

  /// No description provided for @missingNoteName.
  ///
  /// In en, this message translates to:
  /// **'Missing note name.'**
  String get missingNoteName;

  /// No description provided for @missingValue.
  ///
  /// In en, this message translates to:
  /// **'Missing cent or ratio value.'**
  String get missingValue;

  /// No description provided for @duplicateNoteName.
  ///
  /// In en, this message translates to:
  /// **'Duplicate note name.'**
  String get duplicateNoteName;

  /// No description provided for @invalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value.'**
  String get invalidValue;

  /// No description provided for @maximumValueExceeded.
  ///
  /// In en, this message translates to:
  /// **'Maximum value of {value} exceeded.'**
  String maximumValueExceeded(Object value);

  /// No description provided for @edoTemperaments.
  ///
  /// In en, this message translates to:
  /// **'Equal temperaments'**
  String get edoTemperaments;

  /// No description provided for @otherTemperaments.
  ///
  /// In en, this message translates to:
  /// **'Other temperaments'**
  String get otherTemperaments;

  /// No description provided for @customTemperaments.
  ///
  /// In en, this message translates to:
  /// **'Custom temperaments'**
  String get customTemperaments;

  /// No description provided for @notationVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get notationVietnamese;

  /// No description provided for @notationVietnameseDescription.
  ///
  /// In en, this message translates to:
  /// **'Hò-Xư-Y-…-Phan'**
  String get notationVietnameseDescription;

  /// No description provided for @cNoteVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Hò'**
  String get cNoteVietnamese;

  /// No description provided for @dNoteVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Xư'**
  String get dNoteVietnamese;

  /// No description provided for @eNoteVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Y'**
  String get eNoteVietnamese;

  /// No description provided for @fNoteVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Xang'**
  String get fNoteVietnamese;

  /// No description provided for @gNoteVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Xê'**
  String get gNoteVietnamese;

  /// No description provided for @aNoteVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Công'**
  String get aNoteVietnamese;

  /// No description provided for @bNoteVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Phan'**
  String get bNoteVietnamese;

  /// No description provided for @useDefault.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get useDefault;

  /// No description provided for @detectFrequency.
  ///
  /// In en, this message translates to:
  /// **'Detect frequency'**
  String get detectFrequency;

  /// No description provided for @stretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get stretch;

  /// No description provided for @stretchTuning.
  ///
  /// In en, this message translates to:
  /// **'Stretch tuning'**
  String get stretchTuning;

  /// No description provided for @noStretchTuning.
  ///
  /// In en, this message translates to:
  /// **'No stretch tuning'**
  String get noStretchTuning;

  /// No description provided for @stretchTuningOff.
  ///
  /// In en, this message translates to:
  /// **'Stretch tuning is turned off.'**
  String get stretchTuningOff;

  /// No description provided for @railsback.
  ///
  /// In en, this message translates to:
  /// **'Railsback'**
  String get railsback;

  /// No description provided for @railsbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Railsback data (average)'**
  String get railsbackDescription;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @stretchTuningEditor.
  ///
  /// In en, this message translates to:
  /// **'Edit stretch tuning'**
  String get stretchTuningEditor;

  /// No description provided for @stretchTuningInfo.
  ///
  /// In en, this message translates to:
  /// **'Stretch tuning info'**
  String get stretchTuningInfo;

  /// No description provided for @stretchedFrequency.
  ///
  /// In en, this message translates to:
  /// **'Stretched frequency'**
  String get stretchedFrequency;

  /// No description provided for @inputIsNoNumber.
  ///
  /// In en, this message translates to:
  /// **'Input is no valid number.'**
  String get inputIsNoNumber;

  /// No description provided for @valueMustBeLargerZero.
  ///
  /// In en, this message translates to:
  /// **'Value must be larger than zero.'**
  String get valueMustBeLargerZero;

  /// No description provided for @centSymbol.
  ///
  /// In en, this message translates to:
  /// **'¢'**
  String get centSymbol;

  /// No description provided for @cent2f.
  ///
  /// In en, this message translates to:
  /// **'{value} ¢'**
  String cent2f(Object value);

  /// No description provided for @hertz2f.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String hertz2f(Object value);

  /// No description provided for @stretchedFrequenciesMustBeStrictlyIncreasing.
  ///
  /// In en, this message translates to:
  /// **'Stretched frequencies must be strictly increasing (previous value: {val1} Hz, this value: {val2} Hz).'**
  String stretchedFrequenciesMustBeStrictlyIncreasing(Object val1, Object val2);

  /// No description provided for @octaveNotationScientific.
  ///
  /// In en, this message translates to:
  /// **'Scientific'**
  String get octaveNotationScientific;

  /// No description provided for @octaveNotationScientificDescription.
  ///
  /// In en, this message translates to:
  /// **'… C¹ C² C³ C⁴ …'**
  String get octaveNotationScientificDescription;

  /// No description provided for @octaveNotationHelmholtz.
  ///
  /// In en, this message translates to:
  /// **'Helmholtz'**
  String get octaveNotationHelmholtz;

  /// No description provided for @octaveNotationHelmholtzDescription.
  ///
  /// In en, this message translates to:
  /// **'… C, C c c\' …'**
  String get octaveNotationHelmholtzDescription;

  /// No description provided for @octaveNotationHelmholtzNumbered.
  ///
  /// In en, this message translates to:
  /// **'Helmholtz numbered'**
  String get octaveNotationHelmholtzNumbered;

  /// No description provided for @octaveNotationHelmholtzNumberedDescription.
  ///
  /// In en, this message translates to:
  /// **'… C₁ C c c¹ …'**
  String get octaveNotationHelmholtzNumberedDescription;

  /// No description provided for @octaveRepresentation.
  ///
  /// In en, this message translates to:
  /// **'Octave representation'**
  String get octaveRepresentation;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @hungarian.
  ///
  /// In en, this message translates to:
  /// **'Magyar'**
  String get hungarian;

  /// No description provided for @polish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get polish;

  /// No description provided for @ukrainian.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get ukrainian;

  /// No description provided for @simplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get simplifiedChinese;

  /// No description provided for @romanian.
  ///
  /// In en, this message translates to:
  /// **'Română'**
  String get romanian;

  /// No description provided for @advancedAcousticDsp.
  ///
  /// In en, this message translates to:
  /// **'Advanced Acoustic DSP'**
  String get advancedAcousticDsp;

  /// No description provided for @pitchAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Pitch Detection Engine'**
  String get pitchAlgorithm;

  /// No description provided for @pitchAlgorithmSummary.
  ///
  /// In en, this message translates to:
  /// **'Select core frequency tracking algorithm (Classic, MPM, TWM, pYIN, Hybrid Jacobsen).'**
  String get pitchAlgorithmSummary;

  /// No description provided for @pitchAlgoClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic (Autocorrelation + Vocoder)'**
  String get pitchAlgoClassic;

  /// No description provided for @pitchAlgoClassicDescription.
  ///
  /// In en, this message translates to:
  /// **'Baseline algorithm. Combines time-domain autocorrelation and FFT phase vocoder.'**
  String get pitchAlgoClassicDescription;

  /// No description provided for @pitchAlgoHybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid Jacobsen (Phase Vocoder + Jacobsen)'**
  String get pitchAlgoHybrid;

  /// No description provided for @pitchAlgoHybridDescription.
  ///
  /// In en, this message translates to:
  /// **'Uses 3-bin complex FFT interpolation to prevent integer bin phase jumps on high notes.'**
  String get pitchAlgoHybridDescription;

  /// No description provided for @pitchAlgoMpm.
  ///
  /// In en, this message translates to:
  /// **'MPM (McLeod Pitch Method)'**
  String get pitchAlgoMpm;

  /// No description provided for @pitchAlgoMpmDescription.
  ///
  /// In en, this message translates to:
  /// **'Normalized Square Difference Function (NSDF) with first-peak selection to eliminate octave errors.'**
  String get pitchAlgoMpmDescription;

  /// No description provided for @pitchAlgoTwm.
  ///
  /// In en, this message translates to:
  /// **'TWM (Two-Way Mismatch)'**
  String get pitchAlgoTwm;

  /// No description provided for @pitchAlgoTwmDescription.
  ///
  /// In en, this message translates to:
  /// **'Bidirectional harmonic matching with inharmonicity compensation. Excels at missing fundamentals.'**
  String get pitchAlgoTwmDescription;

  /// No description provided for @pitchAlgoPyin.
  ///
  /// In en, this message translates to:
  /// **'pYIN (Probabilistic Continuity Tracking)'**
  String get pitchAlgoPyin;

  /// No description provided for @pitchAlgoPyinDescription.
  ///
  /// In en, this message translates to:
  /// **'Probabilistic multi-candidate pitch tracking with temporal continuity smoothing.'**
  String get pitchAlgoPyinDescription;

  /// No description provided for @octaveJumpGate.
  ///
  /// In en, this message translates to:
  /// **'Attack Octave Jump Gate'**
  String get octaveJumpGate;

  /// No description provided for @octaveJumpGateSummary.
  ///
  /// In en, this message translates to:
  /// **'Suppresses transient octave jumping (such as violin bow-scratch overtones causing pitch indicators to fly off-screen on attack).'**
  String get octaveJumpGateSummary;

  /// No description provided for @medianFilter.
  ///
  /// In en, this message translates to:
  /// **'Anti-Jitter Median Filter'**
  String get medianFilter;

  /// No description provided for @medianFilterSummary.
  ///
  /// In en, this message translates to:
  /// **'Applies a 3-tap weighted median filter before moving average to eliminate erratic single-sample jumps on high violin notes without adding latency.'**
  String get medianFilterSummary;

  /// No description provided for @acousticWeighting.
  ///
  /// In en, this message translates to:
  /// **'Acoustic Weighting'**
  String get acousticWeighting;

  /// No description provided for @acousticWeightingSummary.
  ///
  /// In en, this message translates to:
  /// **'Applies A-weighting matching the human ear to heavily attenuate 50Hz/60Hz mains hum and HVAC room noise.'**
  String get acousticWeightingSummary;

  /// No description provided for @acousticWeightingNone.
  ///
  /// In en, this message translates to:
  /// **'Flat (No weighting)'**
  String get acousticWeightingNone;

  /// No description provided for @acousticWeightingNoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Linear frequency response with no filtering.'**
  String get acousticWeightingNoneDescription;

  /// No description provided for @acousticWeightingA.
  ///
  /// In en, this message translates to:
  /// **'A-Weighting (Human hearing, eliminates hum)'**
  String get acousticWeightingA;

  /// No description provided for @acousticWeightingADescription.
  ///
  /// In en, this message translates to:
  /// **'IEC 61672 A-weighting curve; heavily attenuates low-frequency hum and HVAC noise (Recommended).'**
  String get acousticWeightingADescription;

  /// No description provided for @acousticWeightingC.
  ///
  /// In en, this message translates to:
  /// **'C-Weighting (High volume)'**
  String get acousticWeightingC;

  /// No description provided for @acousticWeightingCDescription.
  ///
  /// In en, this message translates to:
  /// **'Standard C-weighting curve for high sound pressure levels.'**
  String get acousticWeightingCDescription;

  /// No description provided for @pitchHistoryNumFaultyValuesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Directly jump to new pitch result} other{After {count} similar pitch results}}'**
  String pitchHistoryNumFaultyValuesSummary(num count);

  /// No description provided for @numMovingAverageSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{No averaging} other{Average over {count} pitch results}}'**
  String numMovingAverageSummary(num count);

  /// No description provided for @itemsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} item deleted} other{{count} items deleted}}'**
  String itemsDeleted(num count);

  /// No description provided for @databaseNumSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Writing {count} item to \"%s\".} other{Writing {count} items to \"%s\".}}'**
  String databaseNumSaved(num count);

  /// No description provided for @loadInstruments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Loading {count} instrument} other{Loading {count} instruments}}'**
  String loadInstruments(num count);

  /// No description provided for @loadTemperaments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Loading {count} temperament} other{Loading {count} temperaments}}'**
  String loadTemperaments(num count);

  /// No description provided for @loadStretchTunings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Loading {count} stretch tuning} other{Loading {count} stretch tunings}}'**
  String loadStretchTunings(num count);

  /// No description provided for @sharingNumItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sharing {count} items} other{Sharing {count} items}}'**
  String sharingNumItems(num count);

  /// No description provided for @equalTemperamentXDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} note per octave} other{{count} notes per octave}}'**
  String equalTemperamentXDesc(num count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'br',
    'ca',
    'cs',
    'de',
    'en',
    'es',
    'fr',
    'hu',
    'pl',
    'pt',
    'ro',
    'sv',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'br':
      return AppLocalizationsBr();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hu':
      return AppLocalizationsHu();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'sv':
      return AppLocalizationsSv();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
