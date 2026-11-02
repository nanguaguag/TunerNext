// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Tuner';

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
  String get windowingFunction => 'Funkcja okienkowania';

  @override
  String get windowHamming => 'Okno Hamminga';

  @override
  String get windowHann => 'Okno Hanna';

  @override
  String get noWindow => 'Brak funkcji okienkowania';

  @override
  String get appearance => 'Wygląd';

  @override
  String get darkAppearance => 'Ciemny wygląd';

  @override
  String get lightAppearance => 'Jasny wygląd';

  @override
  String get systemAppearance => 'Zgodnie z ustawieniami systemu';

  @override
  String get darkAppearanceShort => 'Ciemny';

  @override
  String get lightAppearanceShort => 'Jasny';

  @override
  String get systemAppearanceShort => 'Auto';

  @override
  String get settings => 'Ustawienia';

  @override
  String get overlap => 'Nakładanie się okien';

  @override
  String get windowSize => 'Rozmiar okna';

  @override
  String get minimumFrequency => 'Minimalna częstotliwość: ';

  @override
  String get pitchHistoryDuration => 'Czas trwania historii dźwięku';

  @override
  String get pitchHistoryNumFaultyValues => 'Przeskocz do nowego dźwięku';

  @override
  String pitchHistoryNumFaultyValuesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Po $count podobnych wynikach dźwięku',
      one: 'Przeskocz bezpośrednio do nowego wyniku',
    );
    return '$_temp0';
  }

  @override
  String get numMovingAverage => 'Średnia krocząca';

  @override
  String numMovingAverageSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Średnia z $count wyników dźwięku',
      one: 'Bez uśredniania',
    );
    return '$_temp0';
  }

  @override
  String get about => 'O aplikacji';

  @override
  String aboutMessage(String version) {
    return 'Aplikacja Tuner\nWersja: $version\nLicencja: GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => 'Przywróć wszystkie ustawienia';

  @override
  String get resetSettingsPrompt =>
      'Czy na pewno chcesz przywrócić wszystkie ustawienia?';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get autocorrelation => 'autokorelacja';

  @override
  String get pitchHistory => 'historia dźwięku';

  @override
  String get spectrum => 'widmo';

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
  String get keepScreenOn => 'Nie wygaszaj ekranu';

  @override
  String get displayOnLockScreen => 'Wyświetlaj na zablokowanym ekranie';

  @override
  String get samples => 'próbki';

  @override
  String get scientificMode => 'Tryb naukowy';

  @override
  String get toleranceInCents => 'Tolerancja';

  @override
  String toleranceSummary(int cents) {
    return '±$cents ¢';
  }

  @override
  String get expert => 'Zaawansowane';

  @override
  String get basic => 'Podstawowe';

  @override
  String get others => 'Inne';

  @override
  String get chromatic => 'Chromatyczny';

  @override
  String get guitarEadgbe => 'Gitara 6-strunowa';

  @override
  String get bassEadg => 'Bas 4-strunowy';

  @override
  String get bassBeadg => 'Bas 5-strunowy';

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
  String get notation => 'Notacja';

  @override
  String get notationRegional => 'Domyślna';

  @override
  String get notationRegionalDescription => 'C-D-E-…-B';

  @override
  String get notationSolfege => 'Solfeż';

  @override
  String get notationSolfegeDescription => 'Do-Re-Mi-…-Si';

  @override
  String get notationInternational => 'Międzynarodowa';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => 'Skrzypce';

  @override
  String get abort => 'Anuluj';

  @override
  String get instrumentName => 'Nazwa instrumentu';

  @override
  String get addNote => 'Dodaj dźwięk';

  @override
  String get deleteNote => 'Usuń dźwięk';

  @override
  String get latelyDetectedNotes => 'Ostatnio wykryte dźwięki';

  @override
  String get done => 'Gotowe';

  @override
  String get editInstrument => 'Edytuj instrument';

  @override
  String get predefinedItems => 'Domyślne';

  @override
  String get customItem => 'Własny';

  @override
  String fileEmpty(String filename) {
    return 'Plik jest pusty: $filename';
  }

  @override
  String fileInvalid(String filename) {
    return 'Plik jest nieprawidłowy: $filename';
  }

  @override
  String itemsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunięto $count elementu',
      one: 'Usunięto $count element',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Cofnij';

  @override
  String get pickIcon => 'Wybierz ikonę';

  @override
  String copyExtension(String name) {
    return '$name (kopia)';
  }

  @override
  String get failedToArchiveItems => 'Nie udało się zapisać elementów do pliku';

  @override
  String databaseNumSaved(int count, String filename) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zapisywanie $count elementów do \\\"$filename\\\".',
      one: 'Zapisywanie $count elementu do \\\"$filename\\\".',
    );
    return '$_temp0';
  }

  @override
  String get databaseEmpty => 'Brak elementów do zapisania.';

  @override
  String loadInstruments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wczytywanie $count instrumentów',
      one: 'Wczytywanie $count instrumentu',
    );
    return '$_temp0';
  }

  @override
  String loadTemperaments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wczytywanie $count strojeń',
      one: 'Wczytywanie $count strojenia',
    );
    return '$_temp0';
  }

  @override
  String loadStretchTunings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Loading $count stretch tunings',
      one: 'Loading $count stretch tuning',
    );
    return '$_temp0';
  }

  @override
  String get replaceCurrentList => 'Zastąp bieżącą listę';

  @override
  String get prependCurrentList => 'Dodaj na początek listy';

  @override
  String get appendCurrentList => 'Dodaj na koniec listy';

  @override
  String get share => 'Udostępnij elementy';

  @override
  String sharingNumItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Udostępnianie $count elementów',
      one: 'Udostępnianie $count elementu',
    );
    return '$_temp0';
  }

  @override
  String get loadFromDisk => 'Wczytaj elementy z pliku';

  @override
  String get saveToDisk => 'Zapisz elementy do pliku';

  @override
  String get preferFlat => 'Preferuj \\u266D zamiast \\u266F';

  @override
  String get violaCgda => 'Altówka';

  @override
  String get celloCgda => 'Wiolonczela';

  @override
  String get doubleBassEadg => 'Kontrabas';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(int divisions) {
    return '$divisions-tonowy strój równomiernie temperowany';
  }

  @override
  String equalTemperamentXDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dźwięku na oktawę',
      one: '$count dźwięk na oktawę',
    );
    return '$_temp0';
  }

  @override
  String equalTemperamentXAbbr(int divisions) {
    return 'EDO $divisions';
  }

  @override
  String get pythagoreanTuning => 'Strój pitagorejski';

  @override
  String get pythagoreanTuningAbbr => 'Pitagorejski';

  @override
  String get pureTuning => 'Strój naturalny (czysto intonowany)';

  @override
  String get pureTuningDesc => 'Skala 5-limit, asymetryczna';

  @override
  String get pureTuningAbbr => 'Naturalny';

  @override
  String get quarterCommaMeanTone => 'Temperacja średniotonowa ¼-komowa';

  @override
  String get quarterCommaMeanToneDesc => 'Czyste tercje wielkie';

  @override
  String get quarterCommaMeanToneAbbr => '¼-komowa średniotonowa';

  @override
  String get thirdCommaMeanTone => 'Temperacja średniotonowa ⅓-komowa';

  @override
  String get thirdCommaMeanToneDesc => 'Czyste tercje małe';

  @override
  String get thirdCommaMeanToneAbbr => '⅓-komowa średniotonowa';

  @override
  String get fifthCommaMeanTone => 'Temperacja średniotonowa ⅕-komowa';

  @override
  String get fifthCommaMeanToneDesc => 'Czyste diatoniczne półtony';

  @override
  String get fifthCommaMeanToneAbbr => '⅕-komowa średniotonowa';

  @override
  String get werckmeisterIii => 'Werckmeister III';

  @override
  String get werckmeisterIiiDesc => 'Podział na ¼ komy';

  @override
  String get werckmeisterIiiAbbr => 'Werckmeister III';

  @override
  String get werckmeisterIv => 'Werckmeister IV';

  @override
  String get werckmeisterIvDesc => 'Podział na ⅓ komy';

  @override
  String get werckmeisterIvAbbr => 'Werckmeister IV';

  @override
  String get werckmeisterV => 'Werckmeister V';

  @override
  String get werckmeisterVDesc => 'Inny podział na ¼ komy';

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
  String get kirnberger1Desc => 'Jedna koma syntoniczna';

  @override
  String get kirnberger1Abbr => 'Kirnberger I';

  @override
  String get kirnberger2 => 'Kirnberger II';

  @override
  String get kirnberger2Desc => 'Podział na ½ komy syntonicznej';

  @override
  String get kirnberger2Abbr => 'Kirnberger II';

  @override
  String get kirnberger3 => 'Kirnberger III';

  @override
  String get kirnberger3Desc => 'Podział na ¼ komy syntonicznej';

  @override
  String get kirnberger3Abbr => 'Kirnberger III';

  @override
  String get neidhardt1 => 'Neidhardt 1';

  @override
  String get neidhardt1Desc => 'Dla wsi, 1732';

  @override
  String get neidhardt1Abbr => 'Neidhardt 1';

  @override
  String get neidhardt2 => 'Neidhardt 2';

  @override
  String get neidhardt2Desc => 'Dla małego miasta, 1732';

  @override
  String get neidhardt2Abbr => 'Neidhardt 2';

  @override
  String get neidhardt3 => 'Neidhardt 3';

  @override
  String get neidhardt3Desc => 'Dla dużego miasta, 1732';

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
  String get referenceFrequency => 'Częstotliwość odniesienia';

  @override
  String get frequency => 'Częstotliwość';

  @override
  String get temperament => 'Strojenie';

  @override
  String get rootNote => 'Dźwięk podstawowy';

  @override
  String get testTuning => 'Test strojenia';

  @override
  String get details => 'Szczegóły';

  @override
  String pythagoreanComma(int num, int den) {
    return '$num/$den';
  }

  @override
  String syntonicComma(int num, int den) {
    return '$num/$den';
  }

  @override
  String schisma(int num, int den) {
    return '$num/$den';
  }

  @override
  String get plusCorrection => ' + ';

  @override
  String get minusCorrection => ' - ';

  @override
  String get pythagoreanCommaDesc =>
      'pC: Koma pitagorejska, 531441\\u2044524288\nsC: Koma syntoniczna, 81\\u204480\nsch: Schizma, 32805\\u204432768';

  @override
  String get circleOfFifths => 'Koło kwintowe';

  @override
  String get setDefault => 'Przywróć domyślne';

  @override
  String get acknowledged => 'Potwierdzono';

  @override
  String get blackNightMode => 'Czarne tło w trybie ciemnym';

  @override
  String get systemColorAccents => 'Akcenty kolorystyczne z systemu';

  @override
  String get incorrectTemperament => 'Niekompatybilne strojenie!';

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
      'Nowe strojenie wymaga dostosowania dźwięku odniesienia!';

  @override
  String get commaSeparator => ', ';

  @override
  String get capture => 'Nagrywaj';

  @override
  String captureDuration(int seconds) {
    return 'Czas nagrania: $seconds s';
  }

  @override
  String get noCaptureDuration => 'Wyłącz nagrywanie';

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
  String get notationCarnatic => 'Karnatycka';

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
  String get notationHindustani => 'Hindustańska';

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
  String get notationByzantine => 'Bizantyjska';

  @override
  String get notationByzantineDescription => 'Νη-Πα-Βου-…-Ζω';

  @override
  String get extendedQuarterCommaMeanTone =>
      'Rozszerzona temperacja średniotonowa ¼-komowa';

  @override
  String get extendedQuarterCommaMeanToneDesc =>
      'Czyste tercje wielkie, 15 dźwięków';

  @override
  String get extendedQuarterCommaMeanToneAbbr =>
      'Rozszerzona ¼-komowa średniotonowa';

  @override
  String get sensitivity => 'Czułość';

  @override
  String get deleteItems => 'Usuń elementy';

  @override
  String get databaseEmptyShare => 'Brak elementów do udostępnienia.';

  @override
  String get audioRecordPermissionRationale =>
      'Zezwól na dostęp do mikrofonu, aby rozpocząć strojenie.';

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
    return 'Zapisywanie pliku WAV: $filename';
  }

  @override
  String get failedWritingWaveFile => 'Nie zapisano pliku WAV.';

  @override
  String get instruments => 'Instrumenty';

  @override
  String get edit => 'Edytuj';

  @override
  String get copy => 'Kopiuj';

  @override
  String get delete => 'Usuń';

  @override
  String get temperaments => 'Temperacje';

  @override
  String get save => 'Zapisz';

  @override
  String get temperamentEditor => 'Edytuj temperację';

  @override
  String get noteNumber => 'Liczba dźwięków';

  @override
  String get centStr => 'cent';

  @override
  String get octaveOffset => 'Przesunięcie oktawy';

  @override
  String get ratio => 'Iloraz';

  @override
  String get temperamentName => 'Nazwa temperacji';

  @override
  String get temperamentAbbreviation => 'Skrót';

  @override
  String get temperamentDescription => 'Opis';

  @override
  String get decreasingValueError => 'Wartość musi być większa od poprzedniej.';

  @override
  String get missingNoteName => 'Brak nazwy dźwięku.';

  @override
  String get missingValue => 'Brak wartości centów lub ilorazu.';

  @override
  String get duplicateNoteName => 'Powielona nazwa dźwięku.';

  @override
  String get invalidValue => 'Nieprawidłowa wartość.';

  @override
  String maximumValueExceeded(int max) {
    return 'Przekroczono maksymalną wartość $max.';
  }

  @override
  String get edoTemperaments => 'Temperacje równomiernie temperowane';

  @override
  String get otherTemperaments => 'Inne temperacje';

  @override
  String get customTemperaments => 'Własne temperacje';

  @override
  String get notationVietnamese => 'Wietnamski';

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
  String get useDefault => 'Użyj domyślnych';

  @override
  String get detectFrequency => 'Wykryj częstotliwość';

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
    return 'Stretched frequencies must be strictly increasing (previous value: $prev Hz, this value: $current Hz).';
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
  String get instrumentTuner => 'Stroik instrumentów';

  @override
  String get scientificTuner => 'Stroik naukowy';

  @override
  String get selectInstrument => 'Wybierz instrument';

  @override
  String get referencePitchDialogTitle => 'Wysokość odniesienia A4 (Hz)';

  @override
  String get unlock => 'Odblokuj';

  @override
  String get retry => 'Ponów';

  @override
  String get dismiss => 'Odrzuć';

  @override
  String get resetTo440hz => 'Zresetuj do 440 Hz';

  @override
  String get exportWav => 'Eksportuj WAV';

  @override
  String recordingExported(String filename) {
    return 'Nagranie wyeksportowane: $filename';
  }

  @override
  String get noRecordingData => 'Brak danych nagrania do wyeksportowania';

  @override
  String exportFailed(String error) {
    return 'Eksport nie powiódł się: $error';
  }

  @override
  String get restoreAutoDetection => 'Przywróć automatyczne wykrywanie';

  @override
  String lockedString(String note) {
    return 'Zablokowana struna: $note';
  }

  @override
  String get italian => 'Włoski';

  @override
  String get russian => 'Rosyjski';

  @override
  String get japanese => 'Japoński';

  @override
  String get portuguese => 'Portugalski';

  @override
  String get czech => 'Czeski';

  @override
  String get swedish => 'Szwedzki';

  @override
  String get spanish => 'Hiszpański';

  @override
  String get vietnamese => 'Wietnamski';
}
