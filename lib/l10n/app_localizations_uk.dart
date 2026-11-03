// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'Тюнер';

  @override
  String percent(int count) {
    return '$count%';
  }

  @override
  String hertz(num value) {
    return '$value Hz';
  }

  @override
  String hertz1f(num value) {
    return '$value Hz';
  }

  @override
  String hertzStr(String value) {
    return '$value Hz';
  }

  @override
  String seconds(num value) {
    return '$value s';
  }

  @override
  String get windowingFunction => 'Віконна функція';

  @override
  String get windowHamming => 'Вікно Геммінга';

  @override
  String get windowHann => 'Вікно Ганна';

  @override
  String get noWindow => 'Без віконної функції';

  @override
  String get appearance => 'Вигляд';

  @override
  String get darkAppearance => 'Темна тема';

  @override
  String get lightAppearance => 'Світла тема';

  @override
  String get systemAppearance => 'Дотримуватися налаштувань системи';

  @override
  String get darkAppearanceShort => 'Темна тема';

  @override
  String get lightAppearanceShort => 'Світла тема';

  @override
  String get systemAppearanceShort => 'Автоматично';

  @override
  String get settings => 'Налаштування';

  @override
  String get overlap => 'Перекривання вікон';

  @override
  String get windowSize => 'Розмір вікон';

  @override
  String get minimumFrequency => 'Мінімальна частота: ';

  @override
  String get pitchHistoryDuration => 'Тривалість звучання';

  @override
  String get pitchHistoryNumFaultyValues => 'Перехід до нового тону';

  @override
  String pitchHistoryNumFaultyValuesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Переходити після $count подібних результатів',
      one: 'Одразу переходити до нового тону',
    );
    return '$_temp0';
  }

  @override
  String get numMovingAverage => 'Рухоме середнє';

  @override
  String numMovingAverageSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Визначати за $count результатами тону',
      one: 'Не визначати середнє',
    );
    return '$_temp0';
  }

  @override
  String get about => 'Про додаток';

  @override
  String aboutMessage(String version) {
    return 'Тюнер\nВерсія: $version\nЛіцензія: GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => 'Скинути всі налаштування';

  @override
  String get resetSettingsPrompt =>
      'Ви справді хочете скинути всі налаштування?';

  @override
  String get yes => 'Так';

  @override
  String get no => 'Ні';

  @override
  String get autocorrelation => 'автокореляція';

  @override
  String get pitchHistory => 'звучання';

  @override
  String get spectrum => 'спектр';

  @override
  String cent(String cents) {
    return '$cents ¢';
  }

  @override
  String centNosign(String cents) {
    return '$cents ¢';
  }

  @override
  String cent1f(String cents) {
    return '$cents ¢';
  }

  @override
  String get keepScreenOn => 'Не вимикати екран';

  @override
  String get displayOnLockScreen => 'Показувати на заблокованому екрані';

  @override
  String get samples => 'семплів';

  @override
  String get scientificMode => 'Науковий режим';

  @override
  String get toleranceInCents => 'Допустиме відхилення';

  @override
  String toleranceSummary(int cents) {
    return '±$cents ¢';
  }

  @override
  String get expert => 'Експертні налаштування';

  @override
  String get basic => 'Основні';

  @override
  String get others => 'Інше';

  @override
  String get chromatic => 'Хроматичні';

  @override
  String get guitarEadgbe => '6-струнна гітара';

  @override
  String get bassEadg => '4-струнний бас';

  @override
  String get bassBeadg => '5-струнний бас';

  @override
  String get ukuleleGcea => 'Укулеле';

  @override
  String get cNoteName => 'C';

  @override
  String get dNoteName => 'D';

  @override
  String get eNoteName => 'E';

  @override
  String get fNoteName => 'F';

  @override
  String get gNoteName => 'G';

  @override
  String get aNoteName => 'A';

  @override
  String get bNoteName => 'H';

  @override
  String get bflatNoteName => 'B';

  @override
  String get cSolfege => 'до';

  @override
  String get dSolfege => 'ре';

  @override
  String get eSolfege => 'мі';

  @override
  String get fSolfege => 'фа';

  @override
  String get gSolfege => 'соль';

  @override
  String get aSolfege => 'ля';

  @override
  String get bSolfege => 'сі';

  @override
  String get cNoteInternational => 'C';

  @override
  String get dNoteInternational => 'D';

  @override
  String get eNoteInternational => 'E';

  @override
  String get fNoteInternational => 'F';

  @override
  String get gNoteInternational => 'G';

  @override
  String get aNoteInternational => 'A';

  @override
  String get bNoteInternational => 'B';

  @override
  String get notation => 'Нотація';

  @override
  String get notationRegional => 'Регіональна';

  @override
  String get notationRegionalDescription => 'C-D-E-…-H';

  @override
  String get notationSolfege => 'Сольфеджіо';

  @override
  String get notationSolfegeDescription => 'до-ре-мі-…-сі';

  @override
  String get notationInternational => 'Міжнародна';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => 'Скрипка';

  @override
  String get abort => 'Скасувати';

  @override
  String get instrumentName => 'Назва інструмента';

  @override
  String get addNote => 'Додати ноту';

  @override
  String get deleteNote => 'Видалити ноту';

  @override
  String get latelyDetectedNotes => 'Нещодавно розпізнані ноти';

  @override
  String get done => 'Готово';

  @override
  String get editInstrument => 'Редагувати інструмент';

  @override
  String get predefinedItems => 'Попередньо налаштовані';

  @override
  String get customItem => 'Користувацькі';

  @override
  String fileEmpty(String filename) {
    return 'Файл порожній: $filename';
  }

  @override
  String fileInvalid(String filename) {
    return 'Неправильний файл: $filename';
  }

  @override
  String itemsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count елементів видалено',
      one: '$count елемент видалено',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Скасувати';

  @override
  String get pickIcon => 'Вибрати значок';

  @override
  String copyExtension(String name) {
    return '$name (копія)';
  }

  @override
  String get failedToArchiveItems => 'Не вдалося записати елементи у файл';

  @override
  String databaseNumSaved(int count, String filename) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Запис $count елементів у «$filename».',
      one: 'Запис $count елемента в «$filename».',
    );
    return '$_temp0';
  }

  @override
  String get databaseEmpty => 'Немає елементів, які можна зберегти.';

  @override
  String loadInstruments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Завантаження $count інструментів',
      one: 'Завантаження $count інструмента',
    );
    return '$_temp0';
  }

  @override
  String loadTemperaments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Завантаження $count строїв',
      one: 'Завантаження $count строю',
    );
    return '$_temp0';
  }

  @override
  String loadStretchTunings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Завантаження $count розтягнених строїв',
      one: 'Завантаження $count розтягненого строю',
    );
    return '$_temp0';
  }

  @override
  String get replaceCurrentList => 'Замінити поточний список';

  @override
  String get prependCurrentList => 'Додати на початок списку';

  @override
  String get appendCurrentList => 'Додати в кінець списку';

  @override
  String get share => 'Поділитися';

  @override
  String sharingNumItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Надсилання $count елементів',
      one: 'Надсилання $count елемента',
    );
    return '$_temp0';
  }

  @override
  String get loadFromDisk => 'Завантажити елементи з файлу';

  @override
  String get saveToDisk => 'Зберегти елементи у файл';

  @override
  String get preferFlat => 'Використовувати ♭ замість ♯';

  @override
  String get violaCgda => 'Альт';

  @override
  String get celloCgda => 'Віолончель';

  @override
  String get doubleBassEadg => 'Контрабас';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(int divisions) {
    return '$divisions-ступеневий рівномірно темперований';
  }

  @override
  String equalTemperamentXDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ноти на октаву',
      one: '$count нота на октаву',
    );
    return '$_temp0';
  }

  @override
  String equalTemperamentXAbbr(int divisions) {
    return 'EDO $divisions';
  }

  @override
  String get pythagoreanTuning => 'Піфагорійський стрій';

  @override
  String get pythagoreanTuningAbbr => 'Піфагорійський';

  @override
  String get pureTuning => 'Чистий стрій';

  @override
  String get pureTuningDesc => 'Чистий стрій границі 5, асиметрична гама';

  @override
  String get pureTuningAbbr => 'Чистий';

  @override
  String get quarterCommaMeanTone => '¼ comma meantone';

  @override
  String get quarterCommaMeanToneDesc => 'Pure major 3rds';

  @override
  String get quarterCommaMeanToneAbbr => '¼ comma meantone';

  @override
  String get thirdCommaMeanTone => '⅓ comma meantone';

  @override
  String get thirdCommaMeanToneDesc => 'Pure minor 3rds';

  @override
  String get thirdCommaMeanToneAbbr => '⅓ comma meantone';

  @override
  String get fifthCommaMeanTone => '⅕ comma meantone';

  @override
  String get fifthCommaMeanToneDesc => 'Pure diatonic semitones';

  @override
  String get fifthCommaMeanToneAbbr => '⅕ comma meantone';

  @override
  String get werckmeisterIii => 'Веркмейстер III';

  @override
  String get werckmeisterIiiDesc => '¼ comma divisions';

  @override
  String get werckmeisterIiiAbbr => 'Веркмейстер III';

  @override
  String get werckmeisterIv => 'Веркмейстер IV';

  @override
  String get werckmeisterIvDesc => '⅓ comma divisions';

  @override
  String get werckmeisterIvAbbr => 'Веркмейстер IV';

  @override
  String get werckmeisterV => 'Веркмейстер V';

  @override
  String get werckmeisterVDesc => 'Other ¼ comma divisions';

  @override
  String get werckmeisterVAbbr => 'Веркмейстер V';

  @override
  String get werckmeisterVi => 'Веркмейстер VI';

  @override
  String get werckmeisterViDesc => 'Septenarius';

  @override
  String get werckmeisterViAbbr => 'Веркмейстер VI';

  @override
  String get kirnberger1 => 'Кірнбергер I';

  @override
  String get kirnberger1Desc => 'One syntonic comma';

  @override
  String get kirnberger1Abbr => 'Кірнбергер I';

  @override
  String get kirnberger2 => 'Кірнбергер II';

  @override
  String get kirnberger2Desc => '½ syntonic comma divisions';

  @override
  String get kirnberger2Abbr => 'Кірнбергер II';

  @override
  String get kirnberger3 => 'Кірнбергер III';

  @override
  String get kirnberger3Desc => '¼ syntonic comma divisions';

  @override
  String get kirnberger3Abbr => 'Кірнбергер III';

  @override
  String get neidhardt1 => 'Нейдхардт 1';

  @override
  String get neidhardt1Desc => 'For a village, 1732';

  @override
  String get neidhardt1Abbr => 'Нейдхардт 1';

  @override
  String get neidhardt2 => 'Нейдхардт 2';

  @override
  String get neidhardt2Desc => 'For a small town, 1732';

  @override
  String get neidhardt2Abbr => 'Нейдхардт 2';

  @override
  String get neidhardt3 => 'Нейдхардт 3';

  @override
  String get neidhardt3Desc => 'For a big city, 1732';

  @override
  String get neidhardt3Abbr => 'Нейдхардт 3';

  @override
  String get valotti => 'Валлотті';

  @override
  String get valottiAbbr => 'Валлотті';

  @override
  String get young2 => 'Юнг 2';

  @override
  String get young2Abbr => 'Юнг 2';

  @override
  String get referenceFrequency => 'Еталонна частота';

  @override
  String get referenceNote => 'Опорна нота';

  @override
  String get frequency => 'Частота';

  @override
  String get temperament => 'Стрій';

  @override
  String get rootNote => 'Основний тон';

  @override
  String get testTuning => 'Тестовий стрій';

  @override
  String get details => 'Деталі';

  @override
  String pythagoreanComma(int num, int den) {
    return '$num/$den d';
  }

  @override
  String syntonicComma(int num, int den) {
    return '$num/$den d';
  }

  @override
  String schisma(int num, int den) {
    return '$num/$den d';
  }

  @override
  String get plusCorrection => ' + ';

  @override
  String get minusCorrection => ' - ';

  @override
  String get pythagoreanCommaDesc =>
      'pC — піфагорійська кома, 531441⁄524288\nsC — синтонічна кома, 81⁄80\nsch — схизма, 32805⁄32768';

  @override
  String get circleOfFifths => 'Квінтове коло';

  @override
  String get setDefault => 'Скинути';

  @override
  String get acknowledged => 'Зрозуміло';

  @override
  String get blackNightMode => 'Чорний фон у темній темі';

  @override
  String get systemColorAccents => 'Акцентні кольори з налаштувань системи';

  @override
  String get incorrectTemperament => 'Несумісний стрій!';

  @override
  String get keySignatureSharp =>
      'Key signature: one more sharp or one less flat';

  @override
  String get keySignatureFlat =>
      'Key signature: one more flat or one less sharp';

  @override
  String get staffClef => 'Clef';

  @override
  String get staffClefGrand => 'Piano (treble and bass)';

  @override
  String get staffClefTreble => 'Treble';

  @override
  String get staffClefTenor => 'Tenor (octave treble)';

  @override
  String get staffClefBass => 'Bass';

  @override
  String get chromaticAsStaff => 'Chromatic tuner as note staff';

  @override
  String get chromaticAsStaffSummary =>
      'Show the target note on a staff instead of the list of all notes';

  @override
  String get ok => 'ОК';

  @override
  String get newTemperamentRequiresAdaptingReferenceNote =>
      'Новий стрій вимагає регулювання еталонної ноти!';

  @override
  String get commaSeparator => ',';

  @override
  String get capture => 'Запис';

  @override
  String captureDuration(int seconds) {
    return 'Тривалість запису: $seconds c';
  }

  @override
  String get noCaptureDuration => 'Вимкнути запис';

  @override
  String get saCarnatic => 'Sa';

  @override
  String get ri1Carnatic => 'Ri₁';

  @override
  String get ri2Carnatic => 'Ri₂';

  @override
  String get ga1Carnatic => 'Ga₁';

  @override
  String get ga2Carnatic => 'Ga₂';

  @override
  String get ma1Carnatic => 'Ma₁';

  @override
  String get ma2Carnatic => 'Ma₂';

  @override
  String get paCarnatic => 'Pa';

  @override
  String get dha1Carnatic => 'Dha₁';

  @override
  String get dha2Carnatic => 'Dha₂';

  @override
  String get ni1Carnatic => 'Ni₁';

  @override
  String get ni2Carnatic => 'Ni₂';

  @override
  String get notationCarnatic => 'Карнатична';

  @override
  String get notationCarnaticDescription => 'Sa-Ri₁-Ri₂-…-Ni₂';

  @override
  String get saHindustani => 'Sa';

  @override
  String get re1Hindustani => 'Re₁';

  @override
  String get re2Hindustani => 'Re₂';

  @override
  String get ga1Hindustani => 'Ga₁';

  @override
  String get ga2Hindustani => 'Ga₂';

  @override
  String get ma1Hindustani => 'Ma₁';

  @override
  String get ma2Hindustani => 'Ma₂';

  @override
  String get paHindustani => 'Pa';

  @override
  String get dha1Hindustani => 'Dha₁';

  @override
  String get dha2Hindustani => 'Dha₂';

  @override
  String get ni1Hindustani => 'Ni₁';

  @override
  String get ni2Hindustani => 'Ni₂';

  @override
  String get notationHindustani => 'Гіндустані';

  @override
  String get notationHindustaniDescription => 'Sa-Re₁-Re₂-…-Ni₂';

  @override
  String get niByzantine => 'Νη';

  @override
  String get paByzantine => 'Πα';

  @override
  String get vouByzantine => 'Βου';

  @override
  String get ghaByzantine => 'Γα';

  @override
  String get dhiByzantine => 'Δι';

  @override
  String get keByzantine => 'Κε';

  @override
  String get zoByzantine => 'Ζω';

  @override
  String get notationByzantine => 'Візантійська';

  @override
  String get notationByzantineDescription => 'Νη-Πα-Βου-…-Ζω';

  @override
  String get extendedQuarterCommaMeanTone => 'Extended ¼ comma meantone';

  @override
  String get extendedQuarterCommaMeanToneDesc => 'Pure major 3rds, 15 notes';

  @override
  String get extendedQuarterCommaMeanToneAbbr => 'Extended ¼ comma meantone';

  @override
  String get sensitivity => 'Чутливість';

  @override
  String get deleteItems => 'Видалити елементи';

  @override
  String get databaseEmptyShare => 'Немає елементів, якими можна поділитися.';

  @override
  String get audioRecordPermissionRationale =>
      'Щоб розпочати настроювання, надайте доступ до мікрофона.';

  @override
  String soundSourceInvalidBufferSize(int error) {
    return 'Recording audio is not supported with the current settings (error $error).';
  }

  @override
  String get soundSourceMicrophoneUnavailable =>
      'Cannot access the microphone. Another app might be using it.';

  @override
  String soundSourceReadFailed(int error) {
    return 'Recording from the microphone failed (error $error). Another app might be using it.';
  }

  @override
  String writingWaveFile(String filename) {
    return 'Запис файлу WAV: $filename';
  }

  @override
  String get failedWritingWaveFile => 'Не записано файл WAV.';

  @override
  String get instruments => 'Інструменти';

  @override
  String get edit => 'Редагувати';

  @override
  String get copy => 'Копіювати';

  @override
  String get delete => 'Видалити';

  @override
  String get temperaments => 'Строї';

  @override
  String get save => 'Зберегти';

  @override
  String get temperamentEditor => 'Редагувати стрій';

  @override
  String get noteNumber => 'Кількість нот';

  @override
  String get centStr => 'цент';

  @override
  String get octaveOffset => 'Зміщення октави';

  @override
  String get ratio => 'відношення';

  @override
  String get temperamentName => 'Назва строю';

  @override
  String get temperamentAbbreviation => 'Скорочення';

  @override
  String get temperamentDescription => 'Опис';

  @override
  String get decreasingValueError =>
      'Значення повинно бути більшим за попереднє.';

  @override
  String get missingNoteName => 'Відсутня назва ноти.';

  @override
  String get missingValue => 'Відсутнє значення цента або відношення.';

  @override
  String get duplicateNoteName => 'Така нота вже використовується.';

  @override
  String get invalidValue => 'Неправильне значення.';

  @override
  String maximumValueExceeded(int max) {
    return 'Перевищено максимальне значення $max.';
  }

  @override
  String get edoTemperaments => 'Рівномірно темперовані';

  @override
  String get otherTemperaments => 'Інші строї';

  @override
  String get customTemperaments => 'Користувацькі строї';

  @override
  String get searchTemperamentsHint =>
      'Пошук строю (наприклад, 19-EDO, Чистий стрій)...';

  @override
  String get notationVietnamese => 'В’єтнамcька';

  @override
  String get notationVietnameseDescription => 'Hò-Xư-Y-…-Phan';

  @override
  String get cNoteVietnamese => 'Hò';

  @override
  String get dNoteVietnamese => 'Xư';

  @override
  String get eNoteVietnamese => 'Y';

  @override
  String get fNoteVietnamese => 'Xang';

  @override
  String get gNoteVietnamese => 'Xê';

  @override
  String get aNoteVietnamese => 'Công';

  @override
  String get bNoteVietnamese => 'Phan';

  @override
  String get useDefault => 'Викор. стандартний';

  @override
  String get detectFrequency => 'Визначити частоту';

  @override
  String get stretch => 'Розтягування';

  @override
  String get stretchTuning => 'Розтягнений стрій';

  @override
  String get noStretchTuning => 'Без розтягування';

  @override
  String get stretchTuningOff => 'Розтягування вимкнено.';

  @override
  String get railsback => 'Рейлсбек';

  @override
  String get railsbackDescription => 'Дані Рейлсбека (середні)';

  @override
  String get name => 'Назва';

  @override
  String get description => 'Опис';

  @override
  String get stretchTuningEditor => 'Редагувати розтягнений стрій';

  @override
  String get stretchTuningInfo => 'Про розтягнений стрій';

  @override
  String get stretchedFrequency => 'Розтягнута частота';

  @override
  String get inputIsNoNumber => 'Уведене число не є дійсним.';

  @override
  String get valueMustBeLargerZero => 'Значення повинно бути більше нуля.';

  @override
  String get centSymbol => '¢';

  @override
  String cent2f(String cents) {
    return '$cents ¢';
  }

  @override
  String hertz2f(num value) {
    return '$value Hz';
  }

  @override
  String stretchedFrequenciesMustBeStrictlyIncreasing(
    String prev,
    String current,
  ) {
    return 'Розтягнуті частоти повинні строго зростати (попереднє значення: $prev Гц, поточне: $current Гц).';
  }

  @override
  String get octaveNotationScientific => 'Наукове';

  @override
  String get octaveNotationScientificDescription => '… C¹ C² C³ C⁴ …';

  @override
  String get octaveNotationHelmholtz => 'Гельмгольц';

  @override
  String get octaveNotationHelmholtzDescription => '… C, C c c\' …';

  @override
  String get octaveNotationHelmholtzNumbered => 'Гельмгольц із цифрами';

  @override
  String get octaveNotationHelmholtzNumberedDescription => '… C₁ C c c¹ …';

  @override
  String get octaveRepresentation => 'Позначення октав';

  @override
  String get language => 'Мова';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get systemDefault => 'Як у системі';

  @override
  String get french => 'Français';

  @override
  String get hungarian => 'Magyar';

  @override
  String get polish => 'Polski';

  @override
  String get ukrainian => 'Українська';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get romanian => 'Română';

  @override
  String get advancedAcousticDsp => 'Advanced Acoustic DSP';

  @override
  String get pitchAlgorithm => 'Pitch Detection Engine';

  @override
  String get pitchAlgorithmSummary =>
      'Select core frequency tracking algorithm (Classic, MPM, TWM, pYIN, Hybrid Jacobsen).';

  @override
  String get pitchAlgoClassic => 'Classic (Autocorrelation + Vocoder)';

  @override
  String get pitchAlgoClassicDescription =>
      'Baseline algorithm. Combines time-domain autocorrelation and FFT phase vocoder.';

  @override
  String get pitchAlgoHybrid => 'Hybrid Jacobsen (Phase Vocoder + Jacobsen)';

  @override
  String get pitchAlgoHybridDescription =>
      'Uses 3-bin complex FFT interpolation to prevent integer bin phase jumps on high notes.';

  @override
  String get pitchAlgoMpm => 'MPM (McLeod Pitch Method)';

  @override
  String get pitchAlgoMpmDescription =>
      'Normalized Square Difference Function (NSDF) with first-peak selection to eliminate octave errors.';

  @override
  String get pitchAlgoTwm => 'TWM (Two-Way Mismatch)';

  @override
  String get pitchAlgoTwmDescription =>
      'Bidirectional harmonic matching with inharmonicity compensation. Excels at missing fundamentals.';

  @override
  String get pitchAlgoPyin => 'pYIN (Probabilistic Continuity Tracking)';

  @override
  String get pitchAlgoPyinDescription =>
      'Probabilistic multi-candidate pitch tracking with temporal continuity smoothing.';

  @override
  String get octaveJumpGate => 'Attack Octave Jump Gate';

  @override
  String get octaveJumpGateSummary =>
      'Suppresses transient octave jumping (such as violin bow-scratch overtones causing pitch indicators to fly off-screen on attack).';

  @override
  String get medianFilter => 'Anti-Jitter Median Filter';

  @override
  String get medianFilterSummary =>
      'Applies a 3-tap weighted median filter before moving average to eliminate erratic single-sample jumps on high violin notes without adding latency.';

  @override
  String get acousticWeighting => 'Acoustic Weighting';

  @override
  String get acousticWeightingSummary =>
      'Applies A-weighting matching the human ear to heavily attenuate 50Hz/60Hz mains hum and HVAC room noise.';

  @override
  String get acousticWeightingNone => 'Flat (No weighting)';

  @override
  String get acousticWeightingNoneDescription =>
      'Linear frequency response with no filtering.';

  @override
  String get acousticWeightingA =>
      'A-Weighting (Human hearing, eliminates hum)';

  @override
  String get acousticWeightingADescription =>
      'IEC 61672 A-weighting curve; heavily attenuates low-frequency hum and HVAC noise (Recommended).';

  @override
  String get acousticWeightingC => 'C-Weighting (High volume)';

  @override
  String get acousticWeightingCDescription =>
      'Standard C-weighting curve for high sound pressure levels.';

  @override
  String get instrumentTuner => 'Тюнер інструментів';

  @override
  String get scientificTuner => 'Науковий тюнер';

  @override
  String get selectInstrument => 'Виберіть інструмент';

  @override
  String get referencePitchDialogTitle => 'Еталонна висота A4 (Гц)';

  @override
  String get unlock => 'Розблокувати';

  @override
  String get retry => 'Повторити';

  @override
  String get dismiss => 'Відхилити';

  @override
  String get resetTo440hz => 'Скинути до 440 Гц';

  @override
  String get exportWav => 'Експорт WAV';

  @override
  String recordingExported(String filename) {
    return 'Запис експортовано: $filename';
  }

  @override
  String get noRecordingData => 'Немає даних запису для експорту';

  @override
  String exportFailed(String error) {
    return 'Помилка експорту: $error';
  }

  @override
  String get restoreAutoDetection => 'Відновити автовизначення';

  @override
  String lockedString(String note) {
    return 'Заблокована струна: $note';
  }

  @override
  String get italian => 'Італійська';

  @override
  String get russian => 'Російська';

  @override
  String get japanese => 'Японська';

  @override
  String get portuguese => 'Португальська';

  @override
  String get czech => 'Чеська';

  @override
  String get swedish => 'Шведська';

  @override
  String get spanish => 'Іспанська';

  @override
  String get vietnamese => 'В\'єтнамська';

  @override
  String get keepScreenOnDesc =>
      'Запобігає вимкненню екрана під час налаштування';

  @override
  String get toleranceDesc => 'Поріг допуску для зеленого індикатора точності';

  @override
  String get preferFlatDesc => 'Показувати бемолі замість дієзів (♭)';

  @override
  String get chromaticAsStaffDesc =>
      'Показувати нотоносець у хроматичному режимі';

  @override
  String get sensitivityDesc =>
      'Поріг вхідної чутливості для розпізнавання висоти тону';

  @override
  String get octaveJumpGateDesc =>
      'Усуває перехідні сплески гармонічного подвоєння';

  @override
  String get medianFilterDesc =>
      'Фільтрує аномальні поодинокі стрибки висоти тону';

  @override
  String get scientificModeDesc =>
      'Увімкнути спектр БПФ та перегляд аналізу кореляції';

  @override
  String get numMovingAverageDesc =>
      'Кількість вибірок ковзного середнього для згладжування викидів';

  @override
  String get windowSizeDesc => 'Розмір буфера аналізу у вибірках';

  @override
  String get overlapDesc => 'Перекриття послідовних вікон аналізу';

  @override
  String get pitchHistoryDurationDesc =>
      'Часове вікно, що відображається на графіку історії тону';

  @override
  String get jumpToNewPitchDirect =>
      'Одразу переходити до нової виявленої висоти тону';

  @override
  String jumpToNewPitchMultiple(int count) {
    return 'Після $count подібних результатів висоти';
  }

  @override
  String get audioCaptureDesc =>
      'Місткість буфера експорту WAV (0с вимикає кнопку експорту)';

  @override
  String get audioCaptureDisabled => 'Вимкнено';

  @override
  String get displayOnLockScreenDesc =>
      'Дозволяє тюнеру працювати поверх екрана блокування';

  @override
  String get resetAllSettingsDesc =>
      'Відновити заводські параметри за замовчуванням';

  @override
  String get aboutTunerDesc => 'Версія та архітектурні характеристики';

  @override
  String get resetSettingsConfirmTitle => 'Скинути налаштування';

  @override
  String get resetSettingsConfirmMessage =>
      'Ви впевнені, що хочете скинути всі налаштування до заводських? Цю дію не можна скасувати.';

  @override
  String get algorithmMpmDesc =>
      'Висока точність та надійне придушення октавних стрибків для струн.';

  @override
  String get algorithmTwmDesc =>
      'Гармонічне узгодження спектра для багатих обертонів.';

  @override
  String get algorithmClassicDesc =>
      'Автокореляція на основі БПФ з параболічною апроксимацією піків.';

  @override
  String get algorithmJacobsenDesc =>
      'Покращена інтерполяція фазового вокодера на 3 комплексних бінах.';

  @override
  String get algorithmPyinDesc =>
      'Відстеження кандидатів шляху Вітербі за часовими кадрами.';

  @override
  String get weightingNone => 'Немає (Лінійна)';

  @override
  String get weightingNoneDesc =>
      'Необроблений лінійний спектр звукових частот.';

  @override
  String get windowingTophatDesc =>
      'Без віконного згасання (максимальна роздільна здатність за частотою).';

  @override
  String get windowingHammingDesc =>
      'Помірне придушення бічних пелюсток (-42 дБ згасання).';

  @override
  String get windowingHanningDesc =>
      'Гладке вікно cos² із сильним спадом бічних пелюсток.';

  @override
  String get pureBlackOled => 'Чистий чорний (OLED)';

  @override
  String get cancel => 'Скасувати';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get actions => 'Дії';

  @override
  String get searchStretchTuningsHint => 'Пошук розтягненого строю...';

  @override
  String get deleteStretchTuning => 'Видалити розтягнений стрій';

  @override
  String deleteStretchTuningConfirm(String name) {
    return 'Ви впевнені, що хочете видалити \"$name\"?';
  }

  @override
  String get newStretchTuning => 'Новий розтягнений стрій';

  @override
  String get noStretchPointsDefined =>
      'Точки розтягування не визначені.\nНатисніть +, щоб додати.';

  @override
  String get editStretchPoint => 'Редагувати точку розтягування';

  @override
  String get addStretchPoint => 'Додати точку розтягування';

  @override
  String get frequencyHz => 'Частота (Гц)';

  @override
  String get stretchCents => 'Розтягування (Центи)';

  @override
  String get frequencyMustBeIncreasing => 'Має бути > попередньої';

  @override
  String get createNewStretchTuning => 'Створити розтягнений стрій';

  @override
  String get predefinedSection => 'СТАНДАРТНІ';

  @override
  String get customSection => 'ВЛАСНІ';
}
