// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appName => 'Tuner';

  @override
  String percent(Object value) {
    return '$value %%';
  }

  @override
  String hertz(Object value) {
    return '$value Hz';
  }

  @override
  String hertz1f(Object value) {
    return '$value Hz';
  }

  @override
  String hertzStr(Object value) {
    return '$value Hz';
  }

  @override
  String seconds(Object value) {
    return '$value s';
  }

  @override
  String get windowingFunction => 'Funkce okna';

  @override
  String get windowHamming => 'Okno Hamming';

  @override
  String get windowHann => 'Okno Hann';

  @override
  String get noWindow => 'Bez funkce okna';

  @override
  String get appearance => 'Vzhled';

  @override
  String get darkAppearance => 'Tmavý vzhled';

  @override
  String get lightAppearance => 'Světlý vzhled';

  @override
  String get systemAppearance => 'Vzhled podle nastavení zařízení';

  @override
  String get darkAppearanceShort => 'Tmavý';

  @override
  String get lightAppearanceShort => 'Světlý';

  @override
  String get systemAppearanceShort => 'Auto';

  @override
  String get settings => 'Nastavení';

  @override
  String get overlap => 'Překryv okna';

  @override
  String get windowSize => 'Velikost okna';

  @override
  String get minimumFrequency => 'Minimální frekvence: ';

  @override
  String get pitchHistoryDuration => 'Doba historie výšky tónu';

  @override
  String get pitchHistoryNumFaultyValues => 'Přejít na novou výšku tónu';

  @override
  String get numMovingAverage => 'Klouzavý průměr';

  @override
  String get about => 'O aplikaci';

  @override
  String aboutMessage(Object value) {
    return 'Tuner app\nVerze: $value\nLicense: GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => 'Obnovit výchozí nastavení';

  @override
  String get resetSettingsPrompt => 'Opravdu chcete obnovit výchozí nastavení?';

  @override
  String get yes => 'Ano';

  @override
  String get no => 'Ne';

  @override
  String get autocorrelation => 'Autokorelace';

  @override
  String get pitchHistory => 'historie výšky tónu';

  @override
  String get spectrum => 'spektrum';

  @override
  String cent(Object value) {
    return '$value ¢';
  }

  @override
  String centNosign(Object value) {
    return '$value ¢';
  }

  @override
  String cent1f(Object value) {
    return '$value ¢';
  }

  @override
  String get keepScreenOn => 'Nevypínat displej';

  @override
  String get displayOnLockScreen => 'Zobrazení na zamykací obrazovce';

  @override
  String get samples => 'vzor';

  @override
  String get scientificMode => 'Vědecký režim';

  @override
  String get toleranceInCents => 'Tolerance';

  @override
  String toleranceSummary(Object value) {
    return '±$value ¢';
  }

  @override
  String get expert => 'Expert';

  @override
  String get basic => 'Základ';

  @override
  String get others => 'Další';

  @override
  String get chromatic => 'Chromatická';

  @override
  String get guitarEadgbe => '6strunná kytara';

  @override
  String get bassEadg => '4strunná baskytara';

  @override
  String get bassBeadg => '5strunná baskytara';

  @override
  String get ukuleleGcea => 'Ukulele';

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
  String get cSolfege => 'Do';

  @override
  String get dSolfege => 'Re';

  @override
  String get eSolfege => 'Mi';

  @override
  String get fSolfege => 'Fa';

  @override
  String get gSolfege => 'Sol';

  @override
  String get aSolfege => 'La';

  @override
  String get bSolfege => 'Si';

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
  String get notation => 'Zápis';

  @override
  String get notationRegional => 'Výchozí';

  @override
  String get notationRegionalDescription => 'C-D-E-…-B';

  @override
  String get notationSolfege => 'Solfège';

  @override
  String get notationSolfegeDescription => 'Do-Re-Mi-…-Si';

  @override
  String get notationInternational => 'Mezinárodní';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => 'Housle';

  @override
  String get abort => 'Zrušit';

  @override
  String get instrumentName => 'Název nástroje';

  @override
  String get addNote => 'Přidat notu';

  @override
  String get deleteNote => 'Smazat notu';

  @override
  String get latelyDetectedNotes => 'Nedávno smazané noty';

  @override
  String get done => 'Hotovo';

  @override
  String get editInstrument => 'Upravit nástroj';

  @override
  String get predefinedItems => 'Výchozí';

  @override
  String get customItem => 'Vlastní';

  @override
  String fileEmpty(Object value) {
    return 'Soubor je prázdný: $value';
  }

  @override
  String fileInvalid(Object value) {
    return 'Soubor je neplatný: $value';
  }

  @override
  String get undo => 'Zpět';

  @override
  String get pickIcon => 'Vybrat ikonu';

  @override
  String copyExtension(Object value) {
    return '$value (kopie)';
  }

  @override
  String get failedToArchiveItems => 'Nepodařilo se uložit nástroj do souboru';

  @override
  String get databaseEmpty =>
      'Neexistují žádné nástroje, které by bylo možné uložit.';

  @override
  String get replaceCurrentList => 'Nahradit aktuální seznam';

  @override
  String get prependCurrentList => 'Přidat na začátek stávajícího seznamu';

  @override
  String get appendCurrentList => 'Přidat na konec stávajícího seznamu';

  @override
  String get share => 'Sdílet nástroje';

  @override
  String get loadFromDisk => 'Načíst nástroje ze souboru';

  @override
  String get saveToDisk => 'Uložit nástroje do souboru';

  @override
  String get preferFlat => 'Dávat přednost \\u266D před \\u266F';

  @override
  String get violaCgda => 'Viola';

  @override
  String get celloCgda => 'Violoncello';

  @override
  String get doubleBassEadg => 'Kontrabas';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(Object value) {
    return 'Rovnoměrně temperované ladění $value';
  }

  @override
  String equalTemperamentXAbbr(Object value) {
    return 'EDO $value';
  }

  @override
  String get pythagoreanTuning => 'Pythagorejské ladění';

  @override
  String get pythagoreanTuningAbbr => 'Pythagorejské';

  @override
  String get pureTuning => 'Čisté ladění';

  @override
  String get pureTuningDesc => '5-limitní ladění';

  @override
  String get pureTuningAbbr => 'didymické';

  @override
  String get quarterCommaMeanTone => '¼-koma středotón';

  @override
  String get quarterCommaMeanToneDesc => 'Čistá velká tercie';

  @override
  String get quarterCommaMeanToneAbbr => '¼-koma středotón';

  @override
  String get thirdCommaMeanTone => '⅓-koma středotón';

  @override
  String get thirdCommaMeanToneDesc => 'Čistá malá tercie';

  @override
  String get thirdCommaMeanToneAbbr => '⅓-koma středotón';

  @override
  String get fifthCommaMeanTone => '⅕-koma středotón';

  @override
  String get fifthCommaMeanToneDesc => 'Pure diatonic semitones';

  @override
  String get fifthCommaMeanToneAbbr => '⅕-koma středotón';

  @override
  String get werckmeisterIii => 'Werckmeister III';

  @override
  String get werckmeisterIiiDesc => 'Divize ¼-komma';

  @override
  String get werckmeisterIiiAbbr => 'Werckmeister III';

  @override
  String get werckmeisterIv => 'Werckmeister IV';

  @override
  String get werckmeisterIvDesc => 'Divize ⅓-komma';

  @override
  String get werckmeisterIvAbbr => 'Werckmeister IV';

  @override
  String get werckmeisterV => 'Werckmeister V';

  @override
  String get werckmeisterVDesc => 'Další divize ¼-komma';

  @override
  String get werckmeisterVAbbr => 'Werckmeister V';

  @override
  String get werckmeisterVi => 'Werckmeister VI';

  @override
  String get werckmeisterViDesc => 'Septenarius';

  @override
  String get werckmeisterViAbbr => 'Werckmeister VI';

  @override
  String get kirnberger1 => 'Kirnberger I';

  @override
  String get kirnberger1Desc => 'Jedno syntonické koma';

  @override
  String get kirnberger1Abbr => 'Kirnberger I';

  @override
  String get kirnberger2 => 'Kirnberger II';

  @override
  String get kirnberger2Desc => '½ syntonické koma';

  @override
  String get kirnberger2Abbr => 'Kirnberger II';

  @override
  String get kirnberger3 => 'Kirnberger III';

  @override
  String get kirnberger3Desc => '¼ syntonické koma';

  @override
  String get kirnberger3Abbr => 'Kirnberger III';

  @override
  String get neidhardt1 => 'Neidhardt 1';

  @override
  String get neidhardt1Desc => 'Pro jednu vesnici, 1732';

  @override
  String get neidhardt1Abbr => 'Neidhardt 1';

  @override
  String get neidhardt2 => 'Neidhardt 2';

  @override
  String get neidhardt2Desc => 'Pro malé město, 1732';

  @override
  String get neidhardt2Abbr => 'Neidhardt 2';

  @override
  String get neidhardt3 => 'Neidhardt 3';

  @override
  String get neidhardt3Desc => 'Pro velké město, 1732';

  @override
  String get neidhardt3Abbr => 'Neidhardt 3';

  @override
  String get valotti => 'Vallotti';

  @override
  String get valottiAbbr => 'Vallotti';

  @override
  String get young2 => 'Young 2';

  @override
  String get young2Abbr => 'Young 2';

  @override
  String get referenceFrequency => 'Referenční frekvence';

  @override
  String get frequency => 'Frekvence';

  @override
  String get temperament => 'Temperament';

  @override
  String get rootNote => 'Keynote';

  @override
  String get testTuning => 'Testovací ladění';

  @override
  String get details => 'Detaily';

  @override
  String pythagoreanComma(Object val1, Object val2) {
    return '$val1\\u2044$val2 pC';
  }

  @override
  String syntonicComma(Object val1, Object val2) {
    return '$val1\\u2044$val2 sC';
  }

  @override
  String schisma(Object val1, Object val2) {
    return '$val1\\u2044$val2 sch';
  }

  @override
  String get plusCorrection => ' + ';

  @override
  String get minusCorrection => ' - ';

  @override
  String get pythagoreanCommaDesc =>
      'pC: Pythagorejské koma, 531441⁄524288\nsC: Syntonic Comma, 81⁄80\nsch: Schisma, 32805⁄32768';

  @override
  String get circleOfFifths => 'Kvintový kruh';

  @override
  String get setDefault => 'Obnovit výchozí hodnotu';

  @override
  String get acknowledged => 'Potrvzeno';

  @override
  String get blackNightMode => 'Černé pozadí v tmavém režimu';

  @override
  String get systemColorAccents => 'Akcentní barva podle systému';

  @override
  String get incorrectTemperament => 'Nekompatibilní temperament';

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
  String get ok => 'OK';

  @override
  String get newTemperamentRequiresAdaptingReferenceNote =>
      'Nový temperament vyžaduje nastavení referenční noty!';

  @override
  String get commaSeparator => ',\\ ';

  @override
  String get capture => 'Nahrát';

  @override
  String captureDuration(Object value) {
    return 'Doba nahrávání: $value s';
  }

  @override
  String get noCaptureDuration => 'Žádné nahrávání';

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
  String get notationCarnatic => 'Carnatic';

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
  String get notationHindustani => 'Hindustani';

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
  String get notationByzantine => 'Byzantine';

  @override
  String get notationByzantineDescription => 'Νη-Πα-Βου-…-Ζω';

  @override
  String get extendedQuarterCommaMeanTone => 'Extended ¼ comma meantone';

  @override
  String get extendedQuarterCommaMeanToneDesc => 'Pure major 3rds, 15 notes';

  @override
  String get extendedQuarterCommaMeanToneAbbr => 'Extended ¼ comma meantone';

  @override
  String get sensitivity => 'Sensitivity';

  @override
  String get deleteItems => 'Delete items';

  @override
  String get databaseEmptyShare => 'There are no items to share.';

  @override
  String get audioRecordPermissionRationale =>
      'Grant microphone access to start tuning.';

  @override
  String soundSourceInvalidBufferSize(Object value) {
    return 'Recording audio is not supported with the current settings (error $value).';
  }

  @override
  String get soundSourceMicrophoneUnavailable =>
      'Cannot access the microphone. Another app might be using it.';

  @override
  String soundSourceReadFailed(Object value) {
    return 'Recording from the microphone failed (error $value). Another app might be using it.';
  }

  @override
  String writingWaveFile(Object value) {
    return 'Writing wave file: $value';
  }

  @override
  String get failedWritingWaveFile => 'Did not write wave file.';

  @override
  String get instruments => 'Instruments';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get delete => 'Delete';

  @override
  String get temperaments => 'Temperaments';

  @override
  String get save => 'Save';

  @override
  String get temperamentEditor => 'Edit temperament';

  @override
  String get noteNumber => 'Number of notes';

  @override
  String get centStr => 'cent';

  @override
  String get octaveOffset => 'Octave offset';

  @override
  String get ratio => 'ratio';

  @override
  String get temperamentName => 'Temperament name';

  @override
  String get temperamentAbbreviation => 'Abbreviation';

  @override
  String get temperamentDescription => 'Description';

  @override
  String get decreasingValueError =>
      'Value must be greater than the previous one.';

  @override
  String get missingNoteName => 'Missing note name.';

  @override
  String get missingValue => 'Missing cent or ratio value.';

  @override
  String get duplicateNoteName => 'Duplicate note name.';

  @override
  String get invalidValue => 'Invalid value.';

  @override
  String maximumValueExceeded(Object value) {
    return 'Maximum value of $value exceeded.';
  }

  @override
  String get edoTemperaments => 'Equal temperaments';

  @override
  String get otherTemperaments => 'Other temperaments';

  @override
  String get customTemperaments => 'Custom temperaments';

  @override
  String get notationVietnamese => 'Vietnamese';

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
  String get useDefault => 'Use default';

  @override
  String get detectFrequency => 'Detect frequency';

  @override
  String get stretch => 'Stretch';

  @override
  String get stretchTuning => 'Stretch tuning';

  @override
  String get noStretchTuning => 'No stretch tuning';

  @override
  String get stretchTuningOff => 'Stretch tuning is turned off.';

  @override
  String get railsback => 'Railsback';

  @override
  String get railsbackDescription => 'Railsback data (average)';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get stretchTuningEditor => 'Edit stretch tuning';

  @override
  String get stretchTuningInfo => 'Stretch tuning info';

  @override
  String get stretchedFrequency => 'Stretched frequency';

  @override
  String get inputIsNoNumber => 'Input is no valid number.';

  @override
  String get valueMustBeLargerZero => 'Value must be larger than zero.';

  @override
  String get centSymbol => '¢';

  @override
  String cent2f(Object value) {
    return '$value ¢';
  }

  @override
  String hertz2f(Object value) {
    return '$value Hz';
  }

  @override
  String stretchedFrequenciesMustBeStrictlyIncreasing(
    Object val1,
    Object val2,
  ) {
    return 'Stretched frequencies must be strictly increasing (previous value: $val1 Hz, this value: $val2 Hz).';
  }

  @override
  String get octaveNotationScientific => 'Scientific';

  @override
  String get octaveNotationScientificDescription => '… C¹ C² C³ C⁴ …';

  @override
  String get octaveNotationHelmholtz => 'Helmholtz';

  @override
  String get octaveNotationHelmholtzDescription => '… C, C c c\' …';

  @override
  String get octaveNotationHelmholtzNumbered => 'Helmholtz numbered';

  @override
  String get octaveNotationHelmholtzNumberedDescription => '… C₁ C c c¹ …';

  @override
  String get octaveRepresentation => 'Octave representation';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get systemDefault => 'System default';

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
  String pitchHistoryNumFaultyValuesSummary(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Za $countString podobných hodnot',
      one: 'Okamžitě pokračovat na novou hodnotu',
    );
    return '$_temp0';
  }

  @override
  String numMovingAverageSummary(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Průměr za posledních $countString hodnot',
      one: 'Bez zprůměrování',
    );
    return '$_temp0';
  }

  @override
  String itemsDeleted(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items deleted',
      one: '$countString item deleted',
    );
    return '$_temp0';
  }

  @override
  String databaseNumSaved(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Writing $countString items to \"%s\".',
      one: 'Writing $countString item to \"%s\".',
    );
    return '$_temp0';
  }

  @override
  String loadInstruments(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Načítá se $countString nástrojů',
      one: 'Načítá se nástroj',
    );
    return '$_temp0';
  }

  @override
  String loadTemperaments(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Loading $countString temperaments',
      one: 'Loading $countString temperament',
    );
    return '$_temp0';
  }

  @override
  String loadStretchTunings(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Loading $countString stretch tunings',
      one: 'Loading $countString stretch tuning',
    );
    return '$_temp0';
  }

  @override
  String sharingNumItems(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sdílí se $countString nástrojů',
      one: 'Sdíení nástroje',
    );
    return '$_temp0';
  }

  @override
  String equalTemperamentXDesc(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString not na oktávu',
      one: '$countString nota na oktávu',
    );
    return '$_temp0';
  }
}
