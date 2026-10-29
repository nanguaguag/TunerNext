// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'Acordor';

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
  String get windowingFunction => 'Funcție pentru fereastră';

  @override
  String get windowHamming => 'Fereastră Hamming';

  @override
  String get windowHann => 'Fereastră Hann';

  @override
  String get noWindow => 'Fără funcție de fereastră';

  @override
  String get appearance => 'Aspect';

  @override
  String get darkAppearance => 'Aspect întunecat';

  @override
  String get lightAppearance => 'Aspect luminos';

  @override
  String get systemAppearance => 'Aspectul urmează setările de sistem';

  @override
  String get darkAppearanceShort => 'Întunecat';

  @override
  String get lightAppearanceShort => 'Luminos';

  @override
  String get systemAppearanceShort => 'Automat';

  @override
  String get settings => 'Setări';

  @override
  String get overlap => 'Suprapunere fereastră';

  @override
  String get windowSize => 'Mărime fereastră';

  @override
  String get minimumFrequency => 'Frecvența minimă: ';

  @override
  String get pitchHistoryDuration => 'Durata istoricului de înălțime';

  @override
  String get pitchHistoryNumFaultyValues => 'Sari la o nouă înălțime';

  @override
  String get numMovingAverage => 'Medie mobilă';

  @override
  String get about => 'Despre';

  @override
  String aboutMessage(Object value) {
    return 'Aplicație acordare\nVersiune: $value\nLicență: GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => 'Resetează toate setările';

  @override
  String get resetSettingsPrompt => 'Dorești să resetezi toate setările?';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Nu';

  @override
  String get autocorrelation => 'autocorelare';

  @override
  String get pitchHistory => 'istoric înălțimi';

  @override
  String get spectrum => 'spectru';

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
  String get keepScreenOn => 'Ține ecranul aprins';

  @override
  String get displayOnLockScreen => 'Afișează pe ecranul de blocare';

  @override
  String get samples => 'eșantioane';

  @override
  String get scientificMode => 'Mod științific';

  @override
  String get toleranceInCents => 'Toleranță';

  @override
  String toleranceSummary(Object value) {
    return '±$value ¢';
  }

  @override
  String get expert => 'Expert';

  @override
  String get basic => 'De bază';

  @override
  String get others => 'Altele';

  @override
  String get chromatic => 'Cromatic';

  @override
  String get guitarEadgbe => 'Chitară cu 6 coarde';

  @override
  String get bassEadg => 'Chitară bas cu 4 coarde';

  @override
  String get bassBeadg => 'Chitară bas cu 5 coarde';

  @override
  String get ukuleleGcea => 'Ukulele';

  @override
  String get cNoteName => 'do';

  @override
  String get dNoteName => 're';

  @override
  String get eNoteName => 'mi';

  @override
  String get fNoteName => 'fa';

  @override
  String get gNoteName => 'sol';

  @override
  String get aNoteName => 'la';

  @override
  String get bNoteName => 'si';

  @override
  String get bflatNoteName => '-';

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
  String get notation => 'Notație';

  @override
  String get notationRegional => 'Regională';

  @override
  String get notationRegionalDescription => 'do-re-mi-…-si';

  @override
  String get notationSolfege => 'Solfège';

  @override
  String get notationSolfegeDescription => 'Do-Re-Mi-…-Si';

  @override
  String get notationInternational => 'Internațională';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => 'Vioară';

  @override
  String get abort => 'Anulează';

  @override
  String get instrumentName => 'Nume instrument';

  @override
  String get addNote => 'Adaugă nota';

  @override
  String get deleteNote => 'Șterge nota';

  @override
  String get latelyDetectedNotes => 'Ultimele tonuri detectate';

  @override
  String get done => 'Realizat';

  @override
  String get editInstrument => 'Editează instrument';

  @override
  String get predefinedItems => 'Implicit';

  @override
  String get customItem => 'Personalizat';

  @override
  String fileEmpty(Object value) {
    return 'Fișierul este gol: $value';
  }

  @override
  String fileInvalid(Object value) {
    return 'Fișierul este invalid: $value';
  }

  @override
  String get undo => 'Anulează';

  @override
  String get pickIcon => 'Alege pictogramă';

  @override
  String copyExtension(Object value) {
    return '$value (copie)';
  }

  @override
  String get failedToArchiveItems => 'A eșuat scrierea elementelor în fișier';

  @override
  String get databaseEmpty => 'Nu exsită elemente ce pot fi salvate.';

  @override
  String get replaceCurrentList => 'Înlocuiește lista curentă';

  @override
  String get prependCurrentList => 'Adaugă la începutul listei curente';

  @override
  String get appendCurrentList => 'Adaugă la sfârșitul listei curente';

  @override
  String get share => 'Partajează elementele';

  @override
  String get loadFromDisk => 'Încarcă elemente din fișier';

  @override
  String get saveToDisk => 'Salvează elementele în fișier';

  @override
  String get preferFlat => 'Preferă ♭ în loc de ♯';

  @override
  String get violaCgda => 'Violă';

  @override
  String get celloCgda => 'Violoncel';

  @override
  String get doubleBassEadg => 'Contrabas';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(Object value) {
    return 'Temperament egal $value';
  }

  @override
  String equalTemperamentXAbbr(Object value) {
    return 'EDO $value';
  }

  @override
  String get pythagoreanTuning => 'Acordaj pitagorean';

  @override
  String get pythagoreanTuningAbbr => 'Pitagorean';

  @override
  String get pureTuning => 'Acordaj just';

  @override
  String get pureTuningDesc => 'Limită de 5, gamă asimetrică';

  @override
  String get pureTuningAbbr => 'Just';

  @override
  String get quarterCommaMeanTone => 'Ton mediu de ¼ comă';

  @override
  String get quarterCommaMeanToneDesc => 'Terțe majore pure';

  @override
  String get quarterCommaMeanToneAbbr => 'Ton mediu de ¼ comă';

  @override
  String get thirdCommaMeanTone => 'Ton mediu de ⅓ comă';

  @override
  String get thirdCommaMeanToneDesc => 'Terțe minore pure';

  @override
  String get thirdCommaMeanToneAbbr => 'Ton mediu de ⅓ comă';

  @override
  String get fifthCommaMeanTone => 'Ton mediu de ⅕ comă';

  @override
  String get fifthCommaMeanToneDesc => 'Semitonuri diatonice pure';

  @override
  String get fifthCommaMeanToneAbbr => 'Ton mediu de ⅕ comă';

  @override
  String get werckmeisterIii => 'Werckmeister III';

  @override
  String get werckmeisterIiiDesc => 'Diviziuni de ¼ comă';

  @override
  String get werckmeisterIiiAbbr => 'Werckmeister III';

  @override
  String get werckmeisterIv => 'Werckmeister IV';

  @override
  String get werckmeisterIvDesc => 'Diviziuni de ⅓ comă';

  @override
  String get werckmeisterIvAbbr => 'Werckmeister IV';

  @override
  String get werckmeisterV => 'Werckmeister V';

  @override
  String get werckmeisterVDesc => 'Alte diviziuni de ¼ comă';

  @override
  String get werckmeisterVAbbr => 'Werckmeister V';

  @override
  String get werckmeisterVi => 'Werckmeister VI';

  @override
  String get werckmeisterViDesc => 'Septenariu';

  @override
  String get werckmeisterViAbbr => 'Werckmeister VI';

  @override
  String get kirnberger1 => 'Kirnberger I';

  @override
  String get kirnberger1Desc => 'O comă sintonică';

  @override
  String get kirnberger1Abbr => 'Kirnberger I';

  @override
  String get kirnberger2 => 'Kirnberger II';

  @override
  String get kirnberger2Desc => 'diviziuni de ½ comă sintonică';

  @override
  String get kirnberger2Abbr => 'Kirnberger II';

  @override
  String get kirnberger3 => 'Kirnberger III';

  @override
  String get kirnberger3Desc => 'diviziuni de ¼ comă sintonică';

  @override
  String get kirnberger3Abbr => 'Kirnberger III';

  @override
  String get neidhardt1 => 'Neidhardt 1';

  @override
  String get neidhardt1Desc => 'Pentru un sat, 1732';

  @override
  String get neidhardt1Abbr => 'Neidhardt 1';

  @override
  String get neidhardt2 => 'Neidhardt 2';

  @override
  String get neidhardt2Desc => 'Pentru un oraș mic, 1732';

  @override
  String get neidhardt2Abbr => 'Neidhardt 2';

  @override
  String get neidhardt3 => 'Neidhardt 3';

  @override
  String get neidhardt3Desc => 'Pentru un oraș mare, 1732';

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
  String get referenceFrequency => 'Frecvență de referință';

  @override
  String get frequency => 'Frecvență';

  @override
  String get temperament => 'Temperament';

  @override
  String get rootNote => 'Notă de bază';

  @override
  String get testTuning => 'Acordaj de test';

  @override
  String get details => 'Detalii';

  @override
  String pythagoreanComma(Object val1, Object val2) {
    return '$val1⁄$val2 pC';
  }

  @override
  String syntonicComma(Object val1, Object val2) {
    return '$val1⁄$val2 sC';
  }

  @override
  String schisma(Object val1, Object val2) {
    return '$val1⁄$val2 sch';
  }

  @override
  String get plusCorrection => ' + ';

  @override
  String get minusCorrection => ' - ';

  @override
  String get pythagoreanCommaDesc =>
      'pC: comă pitagoreană, 531441⁄524288\nsC: comă sintonică 81⁄80\nsch: schismă, 32805⁄32768';

  @override
  String get circleOfFifths => 'Cadran tonal';

  @override
  String get setDefault => 'Resetează la implicit';

  @override
  String get acknowledged => 'Am înțeles';

  @override
  String get blackNightMode => 'Fundal negru în modul întunecat';

  @override
  String get systemColorAccents => 'Accente de culoare din sistem';

  @override
  String get incorrectTemperament => 'Temperament incompatibil!';

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
      'Noul temperament necesită adaptarea notei de referință!';

  @override
  String get commaSeparator => ',';

  @override
  String get capture => 'Capturare';

  @override
  String captureDuration(Object value) {
    return 'Durată capturare: $value s';
  }

  @override
  String get noCaptureDuration => 'Capturare dezactivată';

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
  String get notationCarnatic => 'Carnatică';

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
  String get notationHindustani => 'Hindustană';

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
  String get notationByzantine => 'Bizantină';

  @override
  String get notationByzantineDescription => 'Νη-Πα-Βου-…-Ζω';

  @override
  String get extendedQuarterCommaMeanTone => 'Ton mediu extins de ¼ comă';

  @override
  String get extendedQuarterCommaMeanToneDesc => 'Terțe majore pure, 15 note';

  @override
  String get extendedQuarterCommaMeanToneAbbr => 'Ton mediu extins de ¼ comă';

  @override
  String get sensitivity => 'Sensibilitate';

  @override
  String get deleteItems => 'Șterge elementele';

  @override
  String get databaseEmptyShare => 'Nu există elemente de partajat.';

  @override
  String get audioRecordPermissionRationale =>
      'Permite accesul la microfon pentru a începe acordarea.';

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
    return 'Se scrie fișierul wave: $value';
  }

  @override
  String get failedWritingWaveFile => 'Nu s-a scris fișierul wave.';

  @override
  String get instruments => 'Instrumente';

  @override
  String get edit => 'Editează';

  @override
  String get copy => 'Copiază';

  @override
  String get delete => 'Șterge';

  @override
  String get temperaments => 'Temperamente';

  @override
  String get save => 'Salvează';

  @override
  String get temperamentEditor => 'Editează temperament';

  @override
  String get noteNumber => 'Numărul de note';

  @override
  String get centStr => 'cent';

  @override
  String get octaveOffset => 'Decalaj octavă';

  @override
  String get ratio => 'raport';

  @override
  String get temperamentName => 'Nume temperament';

  @override
  String get temperamentAbbreviation => 'Abreviere';

  @override
  String get temperamentDescription => 'Descriere';

  @override
  String get decreasingValueError =>
      'Valoarea trebuie să fie mai mare decât anterioara.';

  @override
  String get missingNoteName => 'Nume notă lipsă.';

  @override
  String get missingValue => 'Valoare cenți sau raport lipsă.';

  @override
  String get duplicateNoteName => 'Nume notă duplicat.';

  @override
  String get invalidValue => 'Valoare invalidă.';

  @override
  String maximumValueExceeded(Object value) {
    return 'S-a depășit valoarea maximă de $value.';
  }

  @override
  String get edoTemperaments => 'Temperamente egale';

  @override
  String get otherTemperaments => 'Alte temperamente';

  @override
  String get customTemperaments => 'Temperamente personalizate';

  @override
  String get notationVietnamese => 'Vietnameză';

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
  String get useDefault => 'Folosește implicitul';

  @override
  String get detectFrequency => 'Detectează frecvența';

  @override
  String get stretch => 'Întinde';

  @override
  String get stretchTuning => 'Acordaj întins';

  @override
  String get noStretchTuning => 'Fără acordaj întins';

  @override
  String get stretchTuningOff => 'Acordajul întins este oprit.';

  @override
  String get railsback => 'Railsback';

  @override
  String get railsbackDescription => 'Date Railsback (medie)';

  @override
  String get name => 'Nume';

  @override
  String get description => 'Descriere';

  @override
  String get stretchTuningEditor => 'Editează acordaj întins';

  @override
  String get stretchTuningInfo => 'Informații acordaj întins';

  @override
  String get stretchedFrequency => 'Frecvență întinsă';

  @override
  String get inputIsNoNumber => 'Numărul introdus nu este valid.';

  @override
  String get valueMustBeLargerZero =>
      'Valoarea trebuie să fie mai mare ca zero.';

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
    return 'Frecvențele întinse trebuie să fie strict crescătoare (valoarea anterioară: $val1 Hz, această valoare: $val2 Hz).';
  }

  @override
  String get octaveNotationScientific => 'Științifică';

  @override
  String get octaveNotationScientificDescription => '… do¹ do² do³ do⁴ …';

  @override
  String get octaveNotationHelmholtz => 'Helmholtz';

  @override
  String get octaveNotationHelmholtzDescription => '… Do, Do do do\' …';

  @override
  String get octaveNotationHelmholtzNumbered => 'Helmholtz numeric';

  @override
  String get octaveNotationHelmholtzNumberedDescription => '… Do₁ Do do do¹ …';

  @override
  String get octaveRepresentation => 'Reprezentarea octavei';

  @override
  String get language => 'Limbă';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get systemDefault => 'Implicit sistem';

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
      other: 'După $countString de rezultate similare',
      one: 'Sari direct la noua înălțime',
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
      other: 'Media ultimelor $countString de rezultate',
      one: 'Fără calcularea mediei',
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
      other: '$countString de elemente șterse',
      one: '$countString element șters',
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
      other: 'Se scriu $countString de elemente în „%s”.',
      one: 'Se scrie $countString element în „%s”.',
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
      other: 'Se încarcă $countString de instrumente',
      one: 'Se încarcă $countString instrument',
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
      other: 'Se încarcă $countString de temperamente',
      one: 'Se încarcă $countString temperament',
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
      other: 'Se încarcă $countString de acordaje întinse',
      one: 'Se încarcă $countString acordaj întins',
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
      other: 'Se partajează $countString de elemente',
      one: 'Se partajează $countString element',
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
      other: '$countString de note per octavă',
      one: '$countString notă per octavă',
    );
    return '$_temp0';
  }
}
