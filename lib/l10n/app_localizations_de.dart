// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

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
  String get windowingFunction => 'Fensterfunktion';

  @override
  String get windowHamming => 'Hamming Fenster';

  @override
  String get windowHann => 'Hann Fenster';

  @override
  String get noWindow => 'Keine Fensterfunktion';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get darkAppearance => 'Dunkles Erscheinungsbild';

  @override
  String get lightAppearance => 'Helles Erscheinungsbild';

  @override
  String get systemAppearance => 'Erscheinungsbild folgt Systemeinstellungen';

  @override
  String get darkAppearanceShort => 'Dunkel';

  @override
  String get lightAppearanceShort => 'Hell';

  @override
  String get systemAppearanceShort => 'Automatisch';

  @override
  String get settings => 'Einstellungen';

  @override
  String get overlap => 'Fensterüberlappung';

  @override
  String get windowSize => 'Fensterweite';

  @override
  String get minimumFrequency => 'Minimale Frequenz: ';

  @override
  String get pitchHistoryDuration => 'Dauer des Tonverlaufs';

  @override
  String get pitchHistoryNumFaultyValues => 'Zu neuem Ton springen';

  @override
  String get numMovingAverage => 'Gleitender Mittelwert';

  @override
  String get about => 'Über';

  @override
  String aboutMessage(Object value) {
    return 'Tuner app\nVersion: $value\nLizenz: GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => 'Alle Einstellungen zurücksetzen';

  @override
  String get resetSettingsPrompt =>
      'Sollen wirklich alle Einstellungen zurückgesetzt werden?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get autocorrelation => 'Autokorrelation';

  @override
  String get pitchHistory => 'Tonverlauf';

  @override
  String get spectrum => 'Spektrum';

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
  String get keepScreenOn => 'Bildschirm immer an';

  @override
  String get displayOnLockScreen => 'Anzeige auf dem Sperrbildschirm';

  @override
  String get samples => 'Samples';

  @override
  String get scientificMode => 'Wissenschaftlicher Modus';

  @override
  String get toleranceInCents => 'Toleranz';

  @override
  String toleranceSummary(Object value) {
    return '±$value ¢';
  }

  @override
  String get expert => 'Experten';

  @override
  String get basic => 'Allgemein';

  @override
  String get others => 'Andere';

  @override
  String get chromatic => 'Chromatisch';

  @override
  String get guitarEadgbe => '6-saitige Gitarre';

  @override
  String get bassEadg => '4-saitiger Bass';

  @override
  String get bassBeadg => '5-saitiger Bass';

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
  String get notation => 'Schreibweise';

  @override
  String get notationRegional => 'Regional';

  @override
  String get notationRegionalDescription => 'C-D-E-…-H';

  @override
  String get notationSolfege => 'Solfège';

  @override
  String get notationSolfegeDescription => 'Do-Re-Mi-…-Si';

  @override
  String get notationInternational => 'International';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => 'Geige';

  @override
  String get abort => 'Abbrechen';

  @override
  String get instrumentName => 'Instrumentname';

  @override
  String get addNote => 'Note hinzufügen';

  @override
  String get deleteNote => 'Note löschen';

  @override
  String get latelyDetectedNotes => 'Kürzlich erkannte Noten';

  @override
  String get done => 'Fertig';

  @override
  String get editInstrument => 'Instrument bearbeiten';

  @override
  String get predefinedItems => 'Voreingestellt';

  @override
  String get customItem => 'Benutzerdefiniert';

  @override
  String fileEmpty(Object value) {
    return 'Datei ist leer: $value';
  }

  @override
  String fileInvalid(Object value) {
    return 'Datei ist ungültig: $value';
  }

  @override
  String get undo => 'Rückgängig';

  @override
  String get pickIcon => 'Icon auswählen';

  @override
  String copyExtension(Object value) {
    return '$value (Kopie)';
  }

  @override
  String get failedToArchiveItems => 'Speichern der Einträge fehlgeschlagen';

  @override
  String get databaseEmpty => 'Keine zu speichernden Einträge.';

  @override
  String get replaceCurrentList => 'Aktuelle Liste ersetzen';

  @override
  String get prependCurrentList => 'Vor aktueller Liste einfügen';

  @override
  String get appendCurrentList => 'An aktuelle Liste anhängen';

  @override
  String get share => 'Einträge teilen';

  @override
  String get loadFromDisk => 'Lade Einträge aus Datei';

  @override
  String get saveToDisk => 'Einträge in Datei speichern';

  @override
  String get preferFlat => 'Bevorzuge \\u266D vor \\u266F';

  @override
  String get violaCgda => 'Bratsche';

  @override
  String get celloCgda => 'Cello';

  @override
  String get doubleBassEadg => 'Kontrabass';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(Object value) {
    return 'Gleichstufige Stimmung $value';
  }

  @override
  String equalTemperamentXAbbr(Object value) {
    return 'EDO $value';
  }

  @override
  String get pythagoreanTuning => 'Pythagoreische Stimmung';

  @override
  String get pythagoreanTuningAbbr => 'Pythagoreisch';

  @override
  String get pureTuning => 'Reine Stimmung';

  @override
  String get pureTuningDesc => '5-Limit, Asymmetrische Skala';

  @override
  String get pureTuningAbbr => 'rein';

  @override
  String get quarterCommaMeanTone => '¼-Komma mitteltönige Stimmung';

  @override
  String get quarterCommaMeanToneDesc => 'Reine große Terzen';

  @override
  String get quarterCommaMeanToneAbbr => '¼-Komma mitteltönig';

  @override
  String get thirdCommaMeanTone => '⅓ Komma mitteltönige Stimmung';

  @override
  String get thirdCommaMeanToneDesc => 'Reine kleine Terzen';

  @override
  String get thirdCommaMeanToneAbbr => '⅓-Komma mitteltönig';

  @override
  String get fifthCommaMeanTone => '⅕-Komma mitteltönig';

  @override
  String get fifthCommaMeanToneDesc => 'Reine diatonische Halbtöne';

  @override
  String get fifthCommaMeanToneAbbr => '⅕-Komma mitteltönig';

  @override
  String get werckmeisterIii => 'Werckmeister III';

  @override
  String get werckmeisterIiiDesc => '¼-Komma Teilung';

  @override
  String get werckmeisterIiiAbbr => 'Werckmeister III';

  @override
  String get werckmeisterIv => 'Werckmeister IV';

  @override
  String get werckmeisterIvDesc => '⅓-Komma Teilung';

  @override
  String get werckmeisterIvAbbr => 'Werckmeister IV';

  @override
  String get werckmeisterV => 'Werckmeister V';

  @override
  String get werckmeisterVDesc => 'Alternative ¼-Komma Teilung';

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
  String get kirnberger1Desc => 'Ein syntonisches Komma';

  @override
  String get kirnberger1Abbr => 'Kirnberger I';

  @override
  String get kirnberger2 => 'Kirnberger II';

  @override
  String get kirnberger2Desc => '½ syntonisches Komma Teilung';

  @override
  String get kirnberger2Abbr => 'Kirnberger II';

  @override
  String get kirnberger3 => 'Kirnberger III';

  @override
  String get kirnberger3Desc => '¼ syntonisches Komma Teilung';

  @override
  String get kirnberger3Abbr => 'Kirnberger III';

  @override
  String get neidhardt1 => 'Neidhardt 1';

  @override
  String get neidhardt1Desc => 'Für ein Dorf, 1732';

  @override
  String get neidhardt1Abbr => 'Neidhardt 1';

  @override
  String get neidhardt2 => 'Neidhardt 2';

  @override
  String get neidhardt2Desc => 'Für eine kleine Stadt, 1732';

  @override
  String get neidhardt2Abbr => 'Neidhardt 2';

  @override
  String get neidhardt3 => 'Neidhardt 3';

  @override
  String get neidhardt3Desc => 'Für eine große Stadt, 1732';

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
  String get referenceFrequency => 'Referenzfrequenz';

  @override
  String get frequency => 'Frequenz';

  @override
  String get temperament => 'Stimmung';

  @override
  String get rootNote => 'Grundton';

  @override
  String get testTuning => 'Teststimmung';

  @override
  String get details => 'Details';

  @override
  String pythagoreanComma(Object val1, Object val2) {
    return '$val1\\u2044$val2 pK';
  }

  @override
  String syntonicComma(Object val1, Object val2) {
    return '$val1\\u2044$val2 sK';
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
      'pK: Pythagoreisches Komma, 531441\\u2044524288\nsK: Syntonisches Komma, 81\\u204480\nsch: Schisma, 32805\\u204432768';

  @override
  String get circleOfFifths => 'Quintenzirkel';

  @override
  String get setDefault => 'Zurücksetzen';

  @override
  String get acknowledged => 'Verstanden';

  @override
  String get blackNightMode => 'Schwarzer Hintergrund im dunklen Modus';

  @override
  String get systemColorAccents => 'System-Akzentfarben verwenden';

  @override
  String get incorrectTemperament => 'Stimmung inkompatibel!';

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
      'Neue Stimmung verlangt Anpassung der Referenznote!';

  @override
  String get commaSeparator => ',\\ ';

  @override
  String get capture => 'Aufnehmen';

  @override
  String captureDuration(Object value) {
    return 'Aufnahmedauer: $value s';
  }

  @override
  String get noCaptureDuration => 'Keine Aufnahme';

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
  String get notationCarnatic => 'Karnatisch';

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
  String get notationHindustani => 'Hindustanisch';

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
  String get notationByzantine => 'Byzantinisch';

  @override
  String get notationByzantineDescription => 'Νη-Πα-Βου-…-Ζω';

  @override
  String get extendedQuarterCommaMeanTone =>
      'Erweiterte ¼-Komma mitteltönige Stimmung';

  @override
  String get extendedQuarterCommaMeanToneDesc => 'Reine große Terzen, 15 Noten';

  @override
  String get extendedQuarterCommaMeanToneAbbr =>
      '¼-Komma mitteltönig, erweitert';

  @override
  String get sensitivity => 'Empfindlichkeit';

  @override
  String get deleteItems => 'Einträge löschen';

  @override
  String get databaseEmptyShare => 'Keine Einträge zum Teilen.';

  @override
  String get audioRecordPermissionRationale =>
      'Erlaube Verwendung des Mikrofons um zu stimmen.';

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
    return 'Schreibe wav-Datei: $value';
  }

  @override
  String get failedWritingWaveFile => 'Keine wav-Datei geschrieben.';

  @override
  String get instruments => 'Instrumente';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get copy => 'Kopieren';

  @override
  String get delete => 'Löschen';

  @override
  String get temperaments => 'Stimmungen';

  @override
  String get save => 'Speichern';

  @override
  String get temperamentEditor => 'Stimmung bearbeiten';

  @override
  String get noteNumber => 'Anzahl Noten';

  @override
  String get centStr => 'cent';

  @override
  String get octaveOffset => 'Oktavenoffset';

  @override
  String get ratio => 'Verhältnis';

  @override
  String get temperamentName => 'Name der Stimmung';

  @override
  String get temperamentAbbreviation => 'Abkürzung';

  @override
  String get temperamentDescription => 'Beschreibung';

  @override
  String get decreasingValueError => 'Wert muss größer sein als der Vorherige.';

  @override
  String get missingNoteName => 'Fehlender Notenname.';

  @override
  String get missingValue => 'Fehlender Wert für Cent oder Verhältnis.';

  @override
  String get duplicateNoteName => 'Notenname wird bereits verwendet.';

  @override
  String get invalidValue => 'Ungültiger Wert.';

  @override
  String maximumValueExceeded(Object value) {
    return 'Maximaler Wert von $value überschritten.';
  }

  @override
  String get edoTemperaments => 'Gleichstufige Stimmungen';

  @override
  String get otherTemperaments => 'Weitere Stimmungen';

  @override
  String get customTemperaments => 'Benutzerdefinierte Stimmungen';

  @override
  String get notationVietnamese => 'Vietnamesisch';

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
  String get useDefault => 'Standard verwenden';

  @override
  String get detectFrequency => 'Frequenz erkennen';

  @override
  String get stretch => 'Spreizung';

  @override
  String get stretchTuning => 'Spreizung';

  @override
  String get noStretchTuning => 'Keine Spreizung';

  @override
  String get stretchTuningOff => 'Spreizung ist nicht aktiv.';

  @override
  String get railsback => 'Railsback';

  @override
  String get railsbackDescription => 'Railsback-Daten (gemittelt)';

  @override
  String get name => 'Name';

  @override
  String get description => 'Beschreibung';

  @override
  String get stretchTuningEditor => 'Spreizung bearbeiten';

  @override
  String get stretchTuningInfo => 'Spreizung Info';

  @override
  String get stretchedFrequency => 'Gespreizte Frequenz';

  @override
  String get inputIsNoNumber => 'Eingabe ist keine gültige Zahl.';

  @override
  String get valueMustBeLargerZero => 'Wert muss größer als null sein.';

  @override
  String get centSymbol => '¢';

  @override
  String cent2f(Object value) {
    return '$value ¢';
  }

  @override
  String hertz2f(Object value) {
    return '$value Hz';
  }

  @override
  String stretchedFrequenciesMustBeStrictlyIncreasing(
    Object val1,
    Object val2,
  ) {
    return 'Gespreizte Frequenzen müssen monoton anwachsen (voriger Wert: $val1 Hz, dieser Wert: $val2 Hz).';
  }

  @override
  String get octaveNotationScientific => 'Wissenschaftlich';

  @override
  String get octaveNotationScientificDescription => '… C¹ C² C³ C⁴ …';

  @override
  String get octaveNotationHelmholtz => 'Helmholtz';

  @override
  String get octaveNotationHelmholtzDescription => '… C, C c c\' …';

  @override
  String get octaveNotationHelmholtzNumbered => 'Helmholtz nummeriert';

  @override
  String get octaveNotationHelmholtzNumberedDescription => '… C₁ C c c¹ …';

  @override
  String get octaveRepresentation => 'Oktavdarstellung';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get systemDefault => 'Systemstandard';

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
      other: 'Nach $countString ähnlichen Ton-Ergebnissen',
      one: 'Immer direkt zu neuem Ton springen',
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
      other: 'Mittelung über $countString Ton-Ergebnisse',
      one: 'Keine Mittelung',
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
      other: '$countString Einträge gelöscht',
      one: '$countString Eintrag gelöscht',
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
      other: 'Schreibe $countString Einträge nach \"%s\".',
      one: 'Schreibe $countString Eintrag nach \"%s\".',
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
      other: 'Lade $countString Instrumente',
      one: 'Lade $countString Instrument',
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
      other: 'Lade $countString Stimmngen',
      one: 'Lade $countString Stimmung',
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
      other: 'Lade $countString Spreizungen',
      one: 'Lade $countString Spreizung',
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
      other: 'Teile $countString Einträge',
      one: 'Teile $countString Eintrag',
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
      other: '$countString Noten pro Oktave',
      one: '$countString Note pro Oktave',
    );
    return '$_temp0';
  }
}
