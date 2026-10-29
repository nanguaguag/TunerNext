// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

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
  String get windowingFunction => 'Ablakozási függvény';

  @override
  String get windowHamming => 'Hamming ablak';

  @override
  String get windowHann => 'Hann ablak';

  @override
  String get noWindow => 'Nincs ablakozási függvény';

  @override
  String get appearance => 'Megjelenés';

  @override
  String get darkAppearance => 'Sötét megjelenés';

  @override
  String get lightAppearance => 'Világos megjelenés';

  @override
  String get systemAppearance => 'Rendszert követő megjelenés';

  @override
  String get darkAppearanceShort => 'Sötét';

  @override
  String get lightAppearanceShort => 'Világos';

  @override
  String get systemAppearanceShort => 'Automatikus';

  @override
  String get settings => 'Beállítások';

  @override
  String get overlap => 'Ablakok átlapolása';

  @override
  String get windowSize => 'Ablakok mérete';

  @override
  String get minimumFrequency => 'Legkisebb frekvencia: ';

  @override
  String get pitchHistoryDuration => 'Hangmagasság-előzmények hossza';

  @override
  String get pitchHistoryNumFaultyValues => 'Új hangmagasságra ugrás';

  @override
  String get numMovingAverage => 'Mozgóátlag';

  @override
  String get about => 'Névjegy';

  @override
  String aboutMessage(Object value) {
    return 'Hangoló alkalmazás\nVerzió: $value\nLicenc: GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => 'Összes beállítás alaphelyzetbe állítása';

  @override
  String get resetSettingsPrompt =>
      'Biztos, hogy alaphelyzetbe állítja az összes beállítást?';

  @override
  String get yes => 'Igen';

  @override
  String get no => 'Nem';

  @override
  String get autocorrelation => 'autokorreláció';

  @override
  String get pitchHistory => 'hangmagasság-előzmények';

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
  String get keepScreenOn => 'Képernyő bekapcsolva tartása';

  @override
  String get displayOnLockScreen => 'Display on lock screen';

  @override
  String get samples => 'minták';

  @override
  String get scientificMode => 'Tudományos mód';

  @override
  String get toleranceInCents => 'Tűrés';

  @override
  String toleranceSummary(Object value) {
    return '±$value ¢';
  }

  @override
  String get expert => 'Szakértő';

  @override
  String get basic => 'Alapvetők';

  @override
  String get others => 'Egyebek';

  @override
  String get chromatic => 'Kromatikus';

  @override
  String get guitarEadgbe => '6 húros gitár';

  @override
  String get bassEadg => '4 húros basszusgitár';

  @override
  String get bassBeadg => '5 húros basszusgitár';

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
  String get cSolfege => 'dó';

  @override
  String get dSolfege => 'ré';

  @override
  String get eSolfege => 'mi';

  @override
  String get fSolfege => 'fá';

  @override
  String get gSolfege => 'szó';

  @override
  String get aSolfege => 'lá';

  @override
  String get bSolfege => 'ti';

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
  String get notation => 'Jelölés';

  @override
  String get notationRegional => 'Alapértelmezett';

  @override
  String get notationRegionalDescription => 'C-D-E-…-B';

  @override
  String get notationSolfege => 'Szolfézs';

  @override
  String get notationSolfegeDescription => 'Do-Re-Mi-…-Si';

  @override
  String get notationInternational => 'Nemzetközi';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => 'Hegedű';

  @override
  String get abort => 'Megszakítás';

  @override
  String get instrumentName => 'Hangszer neve';

  @override
  String get addNote => 'Hangjegy hozzáadása';

  @override
  String get deleteNote => 'Hangjegy törlése';

  @override
  String get latelyDetectedNotes => 'Nemrég észlelt hangjegyek';

  @override
  String get done => 'Kész';

  @override
  String get editInstrument => 'Hangszer szerkesztése';

  @override
  String get predefinedItems => 'Alapértelmezett';

  @override
  String get customItem => 'Egyéni';

  @override
  String fileEmpty(Object value) {
    return 'A fájl üres: $value';
  }

  @override
  String fileInvalid(Object value) {
    return 'A fájl érvénytelen: $value';
  }

  @override
  String get undo => 'Visszavonás';

  @override
  String get pickIcon => 'Válasszon ikont';

  @override
  String copyExtension(Object value) {
    return '$value (másolat)';
  }

  @override
  String get failedToArchiveItems => 'Az elemek fájlba írása sikertelen';

  @override
  String get databaseEmpty => 'Nincsenek mentendő elemek.';

  @override
  String get replaceCurrentList => 'Jelenlegi lista lecserélése';

  @override
  String get prependCurrentList => 'Jelenlegi lista elé fűzés';

  @override
  String get appendCurrentList => 'Jelenlegi lista mögé fűzés';

  @override
  String get share => 'Elemek megosztása';

  @override
  String get loadFromDisk => 'Elemek betöltése fájlból';

  @override
  String get saveToDisk => 'Elemek fájlba mentése';

  @override
  String get preferFlat => '\\u266D előnyben részesítése a \\u266F-tel szemben';

  @override
  String get violaCgda => 'Brácsa';

  @override
  String get celloCgda => 'Cselló';

  @override
  String get doubleBassEadg => 'Nagybőgő';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(Object value) {
    return '$value hangjegyes kiegyenlített hangolás';
  }

  @override
  String equalTemperamentXAbbr(Object value) {
    return 'EDO $value';
  }

  @override
  String get pythagoreanTuning => 'Püthagoraszi hangolás';

  @override
  String get pythagoreanTuningAbbr => 'Püthagoraszi';

  @override
  String get pureTuning => 'Tiszta hangolás';

  @override
  String get pureTuningDesc => 'Ötfokú, aszimmetrikus skála';

  @override
  String get pureTuningAbbr => 'Kiegyenlített';

  @override
  String get quarterCommaMeanTone => '¼ kommás középhang';

  @override
  String get quarterCommaMeanToneDesc => 'Tiszta nagytercek';

  @override
  String get quarterCommaMeanToneAbbr => '¼ kommás középhang';

  @override
  String get thirdCommaMeanTone => '⅓ kommás középhang';

  @override
  String get thirdCommaMeanToneDesc => 'Tiszta kistercek';

  @override
  String get thirdCommaMeanToneAbbr => '⅓ kommás középhang';

  @override
  String get fifthCommaMeanTone => '⅕ kommás középhang';

  @override
  String get fifthCommaMeanToneDesc => 'Tiszta diatónikus félhangok';

  @override
  String get fifthCommaMeanToneAbbr => '⅕ kommás középhang';

  @override
  String get werckmeisterIii => 'Werckmeister III';

  @override
  String get werckmeisterIiiDesc => '¼ kommás osztások';

  @override
  String get werckmeisterIiiAbbr => 'Werckmeister III';

  @override
  String get werckmeisterIv => 'Werckmeister IV';

  @override
  String get werckmeisterIvDesc => '⅓ kommás felosztások';

  @override
  String get werckmeisterIvAbbr => 'Werckmeister IV';

  @override
  String get werckmeisterV => 'Werckmeister V';

  @override
  String get werckmeisterVDesc => 'Egyéb ¼ kommás felosztások';

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
  String get kirnberger1Desc => 'Egy szintonikus komma';

  @override
  String get kirnberger1Abbr => 'Kirnberger I';

  @override
  String get kirnberger2 => 'Kirnberger II';

  @override
  String get kirnberger2Desc => '½ szintonikus kommás felosztások';

  @override
  String get kirnberger2Abbr => 'Kirnberger II';

  @override
  String get kirnberger3 => 'Kirnberger III';

  @override
  String get kirnberger3Desc => '¼ szintonikus kommás felosztások';

  @override
  String get kirnberger3Abbr => 'Kirnberger III';

  @override
  String get neidhardt1 => 'Neidhardt 1';

  @override
  String get neidhardt1Desc => 'Faluhoz, 1732';

  @override
  String get neidhardt1Abbr => 'Neidhardt 1';

  @override
  String get neidhardt2 => 'Neidhardt 2';

  @override
  String get neidhardt2Desc => 'Kisvároshoz, 1732';

  @override
  String get neidhardt2Abbr => 'Neidhardt 2';

  @override
  String get neidhardt3 => 'Neidhardt 3';

  @override
  String get neidhardt3Desc => 'Nagyvároshoz, 1732';

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
  String get referenceFrequency => 'Referenciafrekvencia';

  @override
  String get frequency => 'Frekvencia';

  @override
  String get temperament => 'Hangolás';

  @override
  String get rootNote => 'Kulcshangjegy';

  @override
  String get testTuning => 'Teszthangolás';

  @override
  String get details => 'Részletek';

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
      'pC: püthagoraszi komma, 531441\\u2044524288\nsC: szintonikus komma, 81\\u204480\nsch: szkizma, 32805\\u204432768';

  @override
  String get circleOfFifths => 'Kvintkör';

  @override
  String get setDefault => 'Alaphelyzetbe állítás';

  @override
  String get acknowledged => 'Értettem';

  @override
  String get blackNightMode => 'Fekete háttér sötét módban';

  @override
  String get systemColorAccents => 'Rendszer kiemelőszínei';

  @override
  String get incorrectTemperament => 'Nem kompatibilis hangolás!';

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
  String get ok => 'Rendben';

  @override
  String get newTemperamentRequiresAdaptingReferenceNote =>
      'Az új hangoláshoz a referenciahang módosítása szükséges!';

  @override
  String get commaSeparator => ',\\ ';

  @override
  String get capture => 'Felvétel';

  @override
  String captureDuration(Object value) {
    return 'Felvétel hossza: $value s';
  }

  @override
  String get noCaptureDuration => 'Felvétel letiltása';

  @override
  String get saCarnatic => 'Sza';

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
  String get notationCarnatic => 'Karnátikus';

  @override
  String get notationCarnaticDescription => 'Sa-Ri₁-Ri₂-…-Ni₂';

  @override
  String get saHindustani => 'Sza';

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
  String get notationHindustani => 'Hindusztáni';

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
  String get notationByzantine => 'Bizánci';

  @override
  String get notationByzantineDescription => 'Νη-Πα-Βου-…-Ζω';

  @override
  String get extendedQuarterCommaMeanTone => 'Bővített ¼ kommás középhang';

  @override
  String get extendedQuarterCommaMeanToneDesc =>
      'Tiszta nagytercek, 15 hangjegy';

  @override
  String get extendedQuarterCommaMeanToneAbbr => 'Bővített ¼ kommás középhang';

  @override
  String get sensitivity => 'Érzékenység';

  @override
  String get deleteItems => 'Elemek törlése';

  @override
  String get databaseEmptyShare => 'Nincsenek megosztandó elemek.';

  @override
  String get audioRecordPermissionRationale =>
      'Adjon mikrofon-hozzáférést a hangolás megkezdéséhez.';

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
    return 'Hangfájl írása: $value';
  }

  @override
  String get failedWritingWaveFile => 'Nem lett hangfájl írva.';

  @override
  String get instruments => 'Hangszerek';

  @override
  String get edit => 'Szerkestés';

  @override
  String get copy => 'Másolás';

  @override
  String get delete => 'Törlés';

  @override
  String get temperaments => 'Hangolások';

  @override
  String get save => 'Mentés';

  @override
  String get temperamentEditor => 'Hangolás szerkesztése';

  @override
  String get noteNumber => 'Hangjegyek száma';

  @override
  String get centStr => 'cent';

  @override
  String get octaveOffset => 'Oktáveltolás';

  @override
  String get ratio => 'arány';

  @override
  String get temperamentName => 'hangolás neve';

  @override
  String get temperamentAbbreviation => 'Rövidítés';

  @override
  String get temperamentDescription => 'Leírás';

  @override
  String get decreasingValueError =>
      'Az értéknek nagyobbnak kell lennie az előzőnél.';

  @override
  String get missingNoteName => 'Hiányzó hangjegynév.';

  @override
  String get missingValue => 'Hiányzó cent- vagy arányérték.';

  @override
  String get duplicateNoteName => 'Ismétlődő hangjegynév.';

  @override
  String get invalidValue => 'Érvénytelen érték.';

  @override
  String maximumValueExceeded(Object value) {
    return 'Legnagyobb érték túllépve: $value.';
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
      other: '$countString hasonló hangmagasság-eredmény után',
      one: 'Ugrás közvetlenül az új hangmagasság-eredményre',
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
      other: '$countString hangmagasság-eredmény átlagolása',
      one: 'Nincs átlagolás',
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
      other: '$countString elem észlelve',
      one: '$countString elem észlelve',
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
      other: '$countString elem írása ide: „%s”.',
      one: '$countString elem írása ide: „%s”.',
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
      other: '$countString hangszer betöltése',
      one: '$countString hangszer betöltése',
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
      other: '$countString hangolás betöltése',
      one: '$countString hangolás betöltése',
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
      other: '$countString elem megosztása',
      one: '$countString elem megosztása',
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
      other: '$countString hangjegy oktávonként',
      one: '$countString hangjegy oktávonként',
    );
    return '$_temp0';
  }
}
