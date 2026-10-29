// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

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
  String get windowingFunction => 'Fönsterfunktion';

  @override
  String get windowHamming => 'Hammingfönster';

  @override
  String get windowHann => 'Hannfönster';

  @override
  String get noWindow => 'Ingen fönsterfunktion';

  @override
  String get appearance => 'Utseende';

  @override
  String get darkAppearance => 'Mörkt utseende';

  @override
  String get lightAppearance => 'Ljust utseende';

  @override
  String get systemAppearance => 'Utseendet följer systeminställningarna';

  @override
  String get darkAppearanceShort => 'Mörkt';

  @override
  String get lightAppearanceShort => 'Ljust';

  @override
  String get systemAppearanceShort => 'Automatiskt';

  @override
  String get settings => 'Inställningar';

  @override
  String get overlap => 'Fönsteröverlappning';

  @override
  String get windowSize => 'Fönsterstorlek';

  @override
  String get minimumFrequency => 'Minsta frekvens: ';

  @override
  String get pitchHistoryDuration => 'Längd på tonhöjdshistorik';

  @override
  String get pitchHistoryNumFaultyValues => 'Hoppa till ny tonhöjd';

  @override
  String get numMovingAverage => 'Glidande medelvärde';

  @override
  String get about => 'Om';

  @override
  String aboutMessage(Object value) {
    return 'Tuner-app\nVersion: $value\nLicens: GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => 'Återställ alla inställningar';

  @override
  String get resetSettingsPrompt =>
      'Vill du verkligen återställa alla inställningar?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nej';

  @override
  String get autocorrelation => 'autokorrelation';

  @override
  String get pitchHistory => 'tonhöjdshistorik';

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
  String get keepScreenOn => 'Håll skärmen på';

  @override
  String get displayOnLockScreen => 'Visa på låsskärmen';

  @override
  String get samples => 'sampler';

  @override
  String get scientificMode => 'Vetenskapligt läge';

  @override
  String get toleranceInCents => 'Tolerans';

  @override
  String toleranceSummary(Object value) {
    return '±$value ¢';
  }

  @override
  String get expert => 'Expert';

  @override
  String get basic => 'Grundläggande';

  @override
  String get others => 'Övriga';

  @override
  String get chromatic => 'Kromatisk';

  @override
  String get guitarEadgbe => '6-strängad gitarr';

  @override
  String get bassEadg => '4-strängad bas';

  @override
  String get bassBeadg => '5-strängad bas';

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
  String get bNoteName => 'B';

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
  String get notation => 'Notering';

  @override
  String get notationRegional => 'Regional';

  @override
  String get notationRegionalDescription => 'C-D-E-…-B';

  @override
  String get notationSolfege => 'Solfège';

  @override
  String get notationSolfegeDescription => 'Do-Re-Mi-…-Si';

  @override
  String get notationInternational => 'Internationell';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => 'Violin';

  @override
  String get abort => 'Avbryt';

  @override
  String get instrumentName => 'Instrumentnamn';

  @override
  String get addNote => 'Lägg till ton';

  @override
  String get deleteNote => 'Ta bort ton';

  @override
  String get latelyDetectedNotes => 'Senast identifierade toner';

  @override
  String get done => 'Klar';

  @override
  String get editInstrument => 'Redigera instrument';

  @override
  String get predefinedItems => 'Standard';

  @override
  String get customItem => 'Anpassat';

  @override
  String fileEmpty(Object value) {
    return 'Filen är tom: $value';
  }

  @override
  String fileInvalid(Object value) {
    return 'Filen är ogiltig: $value';
  }

  @override
  String get undo => 'Ångra';

  @override
  String get pickIcon => 'Välj ikon';

  @override
  String copyExtension(Object value) {
    return '$value (kopia)';
  }

  @override
  String get failedToArchiveItems => 'Kunde inte skriva objekt till fil';

  @override
  String get databaseEmpty => 'Det finns inga objekt som kan sparas.';

  @override
  String get replaceCurrentList => 'Ersätt aktuell lista';

  @override
  String get prependCurrentList => 'Lägg före aktuell lista';

  @override
  String get appendCurrentList => 'Lägg till efter aktuell lista';

  @override
  String get share => 'Dela objekt';

  @override
  String get loadFromDisk => 'Läs in objekt från fil';

  @override
  String get saveToDisk => 'Spara objekt till fil';

  @override
  String get preferFlat => 'Föredra ♭ framför ♯';

  @override
  String get violaCgda => 'Viola';

  @override
  String get celloCgda => 'Cello';

  @override
  String get doubleBassEadg => 'Kontrabas';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(Object value) {
    return 'Liksvävande temperatur $value';
  }

  @override
  String equalTemperamentXAbbr(Object value) {
    return 'EDO $value';
  }

  @override
  String get pythagoreanTuning => 'Pythagoreisk stämning';

  @override
  String get pythagoreanTuningAbbr => 'Pythagoreisk';

  @override
  String get pureTuning => 'Ren stämning';

  @override
  String get pureTuningDesc => '5-gräns, asymmetrisk skala';

  @override
  String get pureTuningAbbr => 'Ren';

  @override
  String get quarterCommaMeanTone => '¼-komma medelton';

  @override
  String get quarterCommaMeanToneDesc => 'Rena stora terser';

  @override
  String get quarterCommaMeanToneAbbr => '¼-komma medelton';

  @override
  String get thirdCommaMeanTone => '⅓-komma medelton';

  @override
  String get thirdCommaMeanToneDesc => 'Rena små terser';

  @override
  String get thirdCommaMeanToneAbbr => '⅓-komma medelton';

  @override
  String get fifthCommaMeanTone => '⅕-komma medelton';

  @override
  String get fifthCommaMeanToneDesc => 'Rena diatoniska halvtoner';

  @override
  String get fifthCommaMeanToneAbbr => '⅕-komma medelton';

  @override
  String get werckmeisterIii => 'Werckmeister III';

  @override
  String get werckmeisterIiiDesc => '¼-kommadelningssystem';

  @override
  String get werckmeisterIiiAbbr => 'Werckmeister III';

  @override
  String get werckmeisterIv => 'Werckmeister IV';

  @override
  String get werckmeisterIvDesc => '⅓-kommadelningssystem';

  @override
  String get werckmeisterIvAbbr => 'Werckmeister IV';

  @override
  String get werckmeisterV => 'Werckmeister V';

  @override
  String get werckmeisterVDesc => 'Andra ¼-kommadelningssystem';

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
  String get kirnberger1Desc => 'En syntonisk komma';

  @override
  String get kirnberger1Abbr => 'Kirnberger I';

  @override
  String get kirnberger2 => 'Kirnberger II';

  @override
  String get kirnberger2Desc => '½ syntoniska kommadelningar';

  @override
  String get kirnberger2Abbr => 'Kirnberger II';

  @override
  String get kirnberger3 => 'Kirnberger III';

  @override
  String get kirnberger3Desc => '¼ syntoniska kommadelningar';

  @override
  String get kirnberger3Abbr => 'Kirnberger III';

  @override
  String get neidhardt1 => 'Neidhardt 1';

  @override
  String get neidhardt1Desc => 'För en by, 1732';

  @override
  String get neidhardt1Abbr => 'Neidhardt 1';

  @override
  String get neidhardt2 => 'Neidhardt 2';

  @override
  String get neidhardt2Desc => 'För en liten stad, 1732';

  @override
  String get neidhardt2Abbr => 'Neidhardt 2';

  @override
  String get neidhardt3 => 'Neidhardt 3';

  @override
  String get neidhardt3Desc => 'För en stor stad, 1732';

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
  String get referenceFrequency => 'Referensfrekvens';

  @override
  String get frequency => 'Frekvens';

  @override
  String get temperament => 'Temperering';

  @override
  String get rootNote => 'Grundton';

  @override
  String get testTuning => 'Testa stämning';

  @override
  String get details => 'Detaljer';

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
      'pC: Pythagoreisk komma, 531441⁄524288\nsC: Syntonisk komma, 81⁄80\nsch: Schisma, 32805⁄32768';

  @override
  String get circleOfFifths => 'Kvintcirkeln';

  @override
  String get setDefault => 'Återställ till standard';

  @override
  String get acknowledged => 'Bekräftat';

  @override
  String get blackNightMode => 'Svart bakgrund i mörkt läge';

  @override
  String get systemColorAccents => 'Färgaccenter från systemet';

  @override
  String get incorrectTemperament => 'Inkompatibel temperering!';

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
      'Ny temperering kräver anpassning av referenstonen!';

  @override
  String get commaSeparator => ',';

  @override
  String get capture => 'Spela in';

  @override
  String captureDuration(Object value) {
    return 'Inspelningstid: $value s';
  }

  @override
  String get noCaptureDuration => 'Inaktivera inspelning';

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
  String get notationCarnatic => 'Karnatisk';

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
  String get notationHindustani => 'Hindustansk';

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
  String get notationByzantine => 'Bysantinsk';

  @override
  String get notationByzantineDescription => 'Νη-Πα-Βου-…-Ζω';

  @override
  String get extendedQuarterCommaMeanTone => 'Utökad ¼-komma medelton';

  @override
  String get extendedQuarterCommaMeanToneDesc => 'Rena stora terser, 15 toner';

  @override
  String get extendedQuarterCommaMeanToneAbbr => 'Utökad ¼-komma medelton';

  @override
  String get sensitivity => 'Känslighet';

  @override
  String get deleteItems => 'Ta bort objekt';

  @override
  String get databaseEmptyShare => 'Det finns inga objekt att dela.';

  @override
  String get audioRecordPermissionRationale =>
      'Ge mikrofonåtkomst för att börja stämma.';

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
    return 'Skriver vågfil: $value';
  }

  @override
  String get failedWritingWaveFile => 'Skrev inte vågfil.';

  @override
  String get instruments => 'Instrument';

  @override
  String get edit => 'Redigera';

  @override
  String get copy => 'Kopiera';

  @override
  String get delete => 'Ta bort';

  @override
  String get temperaments => 'Tempereringar';

  @override
  String get save => 'Spara';

  @override
  String get temperamentEditor => 'Redigera temperering';

  @override
  String get noteNumber => 'Antal toner';

  @override
  String get centStr => 'cent';

  @override
  String get octaveOffset => 'Oktavförskjutning';

  @override
  String get ratio => 'förhållande';

  @override
  String get temperamentName => 'Tempereringsnamn';

  @override
  String get temperamentAbbreviation => 'Förkortning';

  @override
  String get temperamentDescription => 'Beskrivning';

  @override
  String get decreasingValueError => 'Värdet måste vara större än föregående.';

  @override
  String get missingNoteName => 'Tonens namn saknas.';

  @override
  String get missingValue => 'Cent- eller förhållandevärde saknas.';

  @override
  String get duplicateNoteName => 'Dubblett av tonnamn.';

  @override
  String get invalidValue => 'Ogiltigt värde.';

  @override
  String maximumValueExceeded(Object value) {
    return 'Maximivärdet $value överskreds.';
  }

  @override
  String get edoTemperaments => 'Liksvävande tempereringar';

  @override
  String get otherTemperaments => 'Andra tempereringar';

  @override
  String get customTemperaments => 'Anpassade tempereringar';

  @override
  String get notationVietnamese => 'Vietnamesisk';

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
  String get useDefault => 'Använd standard';

  @override
  String get detectFrequency => 'Identifiera frekvens';

  @override
  String get stretch => 'Sträckning';

  @override
  String get stretchTuning => 'Sträckt stämning';

  @override
  String get noStretchTuning => 'Ingen sträckt stämning';

  @override
  String get stretchTuningOff => 'Sträckt stämning är avstängd.';

  @override
  String get railsback => 'Railsback';

  @override
  String get railsbackDescription => 'Railsback-data (medelvärde)';

  @override
  String get name => 'Namn';

  @override
  String get description => 'Beskrivning';

  @override
  String get stretchTuningEditor => 'Redigera sträckt stämning';

  @override
  String get stretchTuningInfo => 'Information om sträckt stämning';

  @override
  String get stretchedFrequency => 'Sträckt frekvens';

  @override
  String get inputIsNoNumber => 'Indata är inte ett giltigt tal.';

  @override
  String get valueMustBeLargerZero => 'Värdet måste vara större än noll.';

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
    return 'Sträckta frekvenser måste vara strikt ökande (föregående värde: $val1 Hz, detta värde: $val2 Hz).';
  }

  @override
  String get octaveNotationScientific => 'Vetenskaplig';

  @override
  String get octaveNotationScientificDescription => '… C¹ C² C³ C⁴ …';

  @override
  String get octaveNotationHelmholtz => 'Helmholtz';

  @override
  String get octaveNotationHelmholtzDescription => '… C, C c c\' …';

  @override
  String get octaveNotationHelmholtzNumbered => 'Helmholtz numrerad';

  @override
  String get octaveNotationHelmholtzNumberedDescription => '… C₁ C c c¹ …';

  @override
  String get octaveRepresentation => 'Oktavrepresentation';

  @override
  String get language => 'Språk';

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
      other: 'Efter $countString liknande tonhöjdsresultat',
      one: 'Hoppa direkt till nytt tonhöjdsresultat',
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
      other: 'Medelvärde över $countString tonhöjdsresultat',
      one: 'Ingen medelvärdesbildning',
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
      other: '$countString objekt togs bort',
      one: '$countString objekt togs bort',
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
      other: 'Skriver $countString objekt till \"%s\".',
      one: 'Skriver $countString objekt till \"%s\".',
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
      other: 'Läser in $countString instrument',
      one: 'Läser in $countString instrument',
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
      other: 'Läser in $countString tempereringar',
      one: 'Läser in $countString temperering',
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
      other: 'Läser in $countString sträckta stämningar',
      one: 'Läser in $countString sträckt stämning',
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
      other: 'Delar $countString objekt',
      one: 'Delar $countString objekt',
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
      other: '$countString toner per oktav',
      one: '$countString ton per oktav',
    );
    return '$_temp0';
  }
}
