// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

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
  String get windowingFunction => 'Fenêtrage';

  @override
  String get windowHamming => 'Fenêtre de Hamming';

  @override
  String get windowHann => 'Fenêtre de Hann';

  @override
  String get noWindow => 'Pas de fenêtrage';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkAppearance => 'Apparence sombre';

  @override
  String get lightAppearance => 'Apparence claire';

  @override
  String get systemAppearance => 'Selon les paramètres du système';

  @override
  String get darkAppearanceShort => 'Sombre';

  @override
  String get lightAppearanceShort => 'Clair';

  @override
  String get systemAppearanceShort => 'Auto';

  @override
  String get settings => 'Paramètres';

  @override
  String get overlap => 'Chevauchement de la fenêtre';

  @override
  String get windowSize => 'Taille de la fenêtre';

  @override
  String get minimumFrequency => 'Fréquence minimale\\u00A0:';

  @override
  String get pitchHistoryDuration => 'Durée de l’historique de la hauteur';

  @override
  String get pitchHistoryNumFaultyValues => 'Allez à la nouvelle hauteur';

  @override
  String get numMovingAverage => 'Moyenne glissante';

  @override
  String get about => 'À propos';

  @override
  String aboutMessage(Object value) {
    return 'Tuner app\nVersion: $value\nLicence: GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => 'Réinitialiser tous les paramètres';

  @override
  String get resetSettingsPrompt =>
      'Êtes-vous sûr de vouloir réinitialiser tous les paramètres\\u00A0?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get autocorrelation => 'autocorrélation';

  @override
  String get pitchHistory => 'historique des hauteurs';

  @override
  String get spectrum => 'spectre';

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
  String get keepScreenOn => 'Maintenir l’écran allumé';

  @override
  String get displayOnLockScreen => 'Afficher sur l\'écran de verrouillage';

  @override
  String get samples => 'échantillons';

  @override
  String get scientificMode => 'Mode scientifique';

  @override
  String get toleranceInCents => 'Tolérance';

  @override
  String toleranceSummary(Object value) {
    return '±$value ¢';
  }

  @override
  String get expert => 'Expert';

  @override
  String get basic => 'Basique';

  @override
  String get others => 'Autres';

  @override
  String get chromatic => 'Chromatique';

  @override
  String get guitarEadgbe => 'Guitare à 6 cordes';

  @override
  String get bassEadg => 'Basse à 4 cordes';

  @override
  String get bassBeadg => 'Basse à 5 cordes';

  @override
  String get ukuleleGcea => 'Ukulélé';

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
  String get dSolfege => 'Ré';

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
  String get notation => 'Notation';

  @override
  String get notationRegional => 'Défaut';

  @override
  String get notationRegionalDescription => 'C-D-E-…-B';

  @override
  String get notationSolfege => 'Solfège';

  @override
  String get notationSolfegeDescription => 'Do-Re-Mi-…-Si';

  @override
  String get notationInternational => 'International';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => 'Violon';

  @override
  String get abort => 'Annuler';

  @override
  String get instrumentName => 'Nom d’instrument';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String get deleteNote => 'Supprimer une note';

  @override
  String get latelyDetectedNotes => 'Dernière notes détectées';

  @override
  String get done => 'Fait';

  @override
  String get editInstrument => 'Éditer l’instrument';

  @override
  String get predefinedItems => 'Défaut';

  @override
  String get customItem => 'Personnalisé';

  @override
  String fileEmpty(Object value) {
    return 'Le fichier est vide\\u00A0: $value';
  }

  @override
  String fileInvalid(Object value) {
    return 'Le fichier est invalide\\u00A0: $value';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get pickIcon => 'Choisir une icône';

  @override
  String copyExtension(Object value) {
    return '$value (copie)';
  }

  @override
  String get failedToArchiveItems =>
      'Impossible d’enregistrer les  dans le fichier';

  @override
  String get databaseEmpty => 'Il n’y a pas d’élément à enregistrer.';

  @override
  String get replaceCurrentList => 'Remplacer la liste actuelle';

  @override
  String get prependCurrentList => 'Ajouter en haut de la liste actuelle';

  @override
  String get appendCurrentList => 'Ajouter en bas de la liste actuelle';

  @override
  String get share => 'Partager les instruments';

  @override
  String get loadFromDisk => 'Charger les éléments depuis un fichier';

  @override
  String get saveToDisk => 'Enregistrer les éléments dans un fichier';

  @override
  String get preferFlat => 'Préférer \\u266D à \\u266F';

  @override
  String get violaCgda => 'Alto';

  @override
  String get celloCgda => 'Violoncelle';

  @override
  String get doubleBassEadg => 'Contrebasse';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(Object value) {
    return 'Tempérament $value intervalles égaux';
  }

  @override
  String equalTemperamentXAbbr(Object value) {
    return 'EDO $value';
  }

  @override
  String get pythagoreanTuning => 'Accord pythagoricien';

  @override
  String get pythagoreanTuningAbbr => 'pythagoricien';

  @override
  String get pureTuning => 'Intonation juste';

  @override
  String get pureTuningDesc => 'à quintes et tierces justes';

  @override
  String get pureTuningAbbr => 'juste';

  @override
  String get quarterCommaMeanTone => 'Mésotonique ¼ comma';

  @override
  String get quarterCommaMeanToneDesc => 'Tierce majeure pure';

  @override
  String get quarterCommaMeanToneAbbr => 'Mésotonique ¼ comma';

  @override
  String get thirdCommaMeanTone => 'Mésotonique ⅓ comma';

  @override
  String get thirdCommaMeanToneDesc => 'Tierce mineure pure';

  @override
  String get thirdCommaMeanToneAbbr => 'Mésotonique ⅓ comma';

  @override
  String get fifthCommaMeanTone => 'Mésotonique ⅕ comma';

  @override
  String get fifthCommaMeanToneDesc => 'Pure diatonic semitones';

  @override
  String get fifthCommaMeanToneAbbr => 'Mésotonique ⅕ comma';

  @override
  String get werckmeisterIii => 'Werckmeister III';

  @override
  String get werckmeisterIiiDesc => 'Divisions ¼ comma';

  @override
  String get werckmeisterIiiAbbr => 'Werckmeister III';

  @override
  String get werckmeisterIv => 'Werckmeister IV';

  @override
  String get werckmeisterIvDesc => 'Divisions ⅓ comma';

  @override
  String get werckmeisterIvAbbr => 'Werckmeister IV';

  @override
  String get werckmeisterV => 'Werckmeister V';

  @override
  String get werckmeisterVDesc => 'Autres divisions ¼ comma';

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
  String get kirnberger1Desc => 'Un comma syntonique';

  @override
  String get kirnberger1Abbr => 'Kirnberger I';

  @override
  String get kirnberger2 => 'Kirnberger II';

  @override
  String get kirnberger2Desc => 'Divisions ½ comma syntonique';

  @override
  String get kirnberger2Abbr => 'Kirnberger II';

  @override
  String get kirnberger3 => 'Kirnberger III';

  @override
  String get kirnberger3Desc => 'Divisions ¼ comma syntonique';

  @override
  String get kirnberger3Abbr => 'Kirnberger III';

  @override
  String get neidhardt1 => 'Neidhardt 1';

  @override
  String get neidhardt1Desc => 'Pour un village, 1732';

  @override
  String get neidhardt1Abbr => 'Neidhardt 1';

  @override
  String get neidhardt2 => 'Neidhardt 2';

  @override
  String get neidhardt2Desc => 'Pour une petite ville, 1732';

  @override
  String get neidhardt2Abbr => 'Neidhardt 2';

  @override
  String get neidhardt3 => 'Neidhardt 3';

  @override
  String get neidhardt3Desc => 'Pour une grande ville, 1732';

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
  String get referenceFrequency => 'Fréquence de référence';

  @override
  String get frequency => 'Fréquence';

  @override
  String get temperament => 'Tempérament';

  @override
  String get rootNote => 'Note de base';

  @override
  String get testTuning => 'Accordage de test';

  @override
  String get details => 'Détails';

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
      'pC: Comma pythagoricien, 531441\\u2044524288\nsC: Comma syntonique, 81\\u204480\nsch: Schisma, 32805\\u204432768';

  @override
  String get circleOfFifths => 'Cycle des quintes';

  @override
  String get setDefault => 'Réinitialiser à la valeur par défaut';

  @override
  String get acknowledged => 'Vu';

  @override
  String get blackNightMode => 'Arrière-plan noir en mode sombre';

  @override
  String get systemColorAccents => 'Couleur d’accentuation du système';

  @override
  String get incorrectTemperament => 'Tempérament incompatible\\u00A0!';

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
      'L’ajustement de la note de référence est requis pour un nouveau tempérament\\u00A0!';

  @override
  String get commaSeparator => ',\\ ';

  @override
  String get capture => 'Enregistrer';

  @override
  String captureDuration(Object value) {
    return 'Durée d’enregistrement\\u00A0: $value s';
  }

  @override
  String get noCaptureDuration => 'Pas d’enregistrement';

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
  String get notationHindustani => 'hindoustanie';

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
  String get extendedQuarterCommaMeanTone => 'Mésotonique ¼ comma étendu';

  @override
  String get extendedQuarterCommaMeanToneDesc =>
      'Tierce majeure pure, 15 notes';

  @override
  String get extendedQuarterCommaMeanToneAbbr => 'Mésotonique ¼ comma étendu';

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
      other: 'Après $countString valeurs similaires de hauteur',
      one: 'Aller directement à la nouvelle valeur de la hauteur',
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
      other: 'Moyenne sur $countString valeurs de hauteur',
      one: 'Pas de moyenne',
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
      other: 'Chargement de $countString instruments',
      one: 'Chargement d’$countString instrument',
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
      other: 'Partager $countString éléments',
      one: 'Partager $countString élément',
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
      other: '$countString notes par octave',
      one: '$countString note par octave',
    );
    return '$_temp0';
  }
}
