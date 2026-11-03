// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get windowingFunction => 'Función de ventana';

  @override
  String get windowHamming => 'Ventana de Hamming';

  @override
  String get windowHann => 'Ventana de Hanna';

  @override
  String get noWindow => 'Sin función de ventana';

  @override
  String get appearance => 'Aspecto';

  @override
  String get darkAppearance => 'Oscuro';

  @override
  String get lightAppearance => 'Claro';

  @override
  String get systemAppearance => 'Predeterminado del sistema';

  @override
  String get darkAppearanceShort => 'Oscuro';

  @override
  String get lightAppearanceShort => 'Claro';

  @override
  String get systemAppearanceShort => 'Automática';

  @override
  String get settings => 'Ajustes';

  @override
  String get overlap => 'Solapamiento de ventanas';

  @override
  String get windowSize => 'Tamaño de la ventana';

  @override
  String get minimumFrequency => 'Frecuencia mínima: ';

  @override
  String get pitchHistoryDuration => 'Duración del historial de tono';

  @override
  String get pitchHistoryNumFaultyValues => 'Salto a un nuevo tono';

  @override
  String pitchHistoryNumFaultyValuesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Al acumular $count tonos similares',
      one: 'Respuesta directa al cambio de tono',
    );
    return '$_temp0';
  }

  @override
  String get numMovingAverage => 'Media móvil';

  @override
  String numMovingAverageSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Media de los últimos $count tonos',
      one: 'Sin media',
    );
    return '$_temp0';
  }

  @override
  String get about => 'Acerca de';

  @override
  String aboutMessage(String version) {
    return 'Tuner app\nVersión: $version\nLicencia: GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => 'Restablecer todos los ajustes';

  @override
  String get resetSettingsPrompt =>
      '¿De verdad quieres restablecer todos los ajustes?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get autocorrelation => 'Autocorrelación';

  @override
  String get pitchHistory => 'Historial de tono';

  @override
  String get spectrum => 'espectro';

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
  String get keepScreenOn => 'Pantalla siempre encendida';

  @override
  String get displayOnLockScreen => 'Ver en pantalla de bloqueo';

  @override
  String get samples => 'ejemplos';

  @override
  String get scientificMode => 'Modo científico';

  @override
  String get toleranceInCents => 'Tolerancia';

  @override
  String toleranceSummary(int cents) {
    return '±$cents ¢';
  }

  @override
  String get expert => 'Experto';

  @override
  String get basic => 'Básico';

  @override
  String get others => 'Otros';

  @override
  String get chromatic => 'Cromático';

  @override
  String get guitarEadgbe => 'Guitarra de 6 cuerdas';

  @override
  String get bassEadg => 'Bajo de 4 cuerdas';

  @override
  String get bassBeadg => 'Bajo de 5 cuerdas';

  @override
  String get ukuleleGcea => 'Ukelele';

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
  String get notation => 'Notación';

  @override
  String get notationRegional => 'Regional';

  @override
  String get notationRegionalDescription => 'Latina (Do-Re-Mi-…-Si) o Solfeo';

  @override
  String get notationSolfege => 'Solfeo';

  @override
  String get notationSolfegeDescription => 'Do-Re-Mi-…-Si';

  @override
  String get notationInternational => 'International';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => 'Violín';

  @override
  String get abort => 'Abortar';

  @override
  String get instrumentName => 'Nombre del instrumento';

  @override
  String get addNote => 'Agregar nota';

  @override
  String get deleteNote => 'Borrar nota';

  @override
  String get latelyDetectedNotes => 'Tonos detectados recientemente';

  @override
  String get done => 'Hecho';

  @override
  String get editInstrument => 'Editar el instrumento';

  @override
  String get predefinedItems => 'Por defecto';

  @override
  String get customItem => 'Personalizado';

  @override
  String fileEmpty(String filename) {
    return 'El archivo está vacío: $filename';
  }

  @override
  String fileInvalid(String filename) {
    return 'Archivo erroneo: $filename';
  }

  @override
  String itemsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos eliminados',
      one: '$count elemento eliminado',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get pickIcon => 'Elegir icono';

  @override
  String copyExtension(String name) {
    return '$name (copiar)';
  }

  @override
  String get failedToArchiveItems => 'Error al guardar los datos en el archivo';

  @override
  String databaseNumSaved(int count, String filename) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardando $count elementos en \\\"$filename\\\".',
      one: 'Guardando $count elemento en \\\"$filename\\\".',
    );
    return '$_temp0';
  }

  @override
  String get databaseEmpty => 'No hay nada para guardar.';

  @override
  String loadInstruments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cargando $count instrumentos',
      one: 'Cargando $count instrumento',
    );
    return '$_temp0';
  }

  @override
  String loadTemperaments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cargando $count temperamentos',
      one: 'Cargando $count temperamento',
    );
    return '$_temp0';
  }

  @override
  String loadStretchTunings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cargando $count afinaciónes con estiramiento',
      one: 'Cargando $count afinación con estiramiento',
    );
    return '$_temp0';
  }

  @override
  String get replaceCurrentList => 'Reemplazar la lista actual';

  @override
  String get prependCurrentList => 'Anteponer a la lista actual';

  @override
  String get appendCurrentList => 'Agregar a la lista actual';

  @override
  String get share => 'Compartir elementos';

  @override
  String sharingNumItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Compartiendo $count elementos',
      one: 'Compartiendo $count elemento',
    );
    return '$_temp0';
  }

  @override
  String get loadFromDisk => 'Cargar elementos desde un archivo';

  @override
  String get saveToDisk => 'Guardar elementos en un archivo';

  @override
  String get preferFlat => 'Prefiero ♭ a ♯';

  @override
  String get violaCgda => 'Viola';

  @override
  String get celloCgda => 'Violonchelo';

  @override
  String get doubleBassEadg => 'Contrabajo';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(int divisions) {
    return 'Temperamento igual $divisions';
  }

  @override
  String equalTemperamentXDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas por octava',
      one: '$count nota por octava',
    );
    return '$_temp0';
  }

  @override
  String equalTemperamentXAbbr(int divisions) {
    return 'EDO $divisions';
  }

  @override
  String get pythagoreanTuning => 'Afinación pitagórica';

  @override
  String get pythagoreanTuningAbbr => 'Pitagórico';

  @override
  String get pureTuning => 'Entonación correcta';

  @override
  String get pureTuningDesc => 'Escala asimétrica de 5 límites';

  @override
  String get pureTuningAbbr => 'Equilibrado';

  @override
  String get quarterCommaMeanTone => '¼ de coma nota media';

  @override
  String get quarterCommaMeanToneDesc => 'Tercera mayor pura';

  @override
  String get quarterCommaMeanToneAbbr => '¼ de coma nota media';

  @override
  String get thirdCommaMeanTone => '⅓ de coma nota media';

  @override
  String get thirdCommaMeanToneDesc => 'Terceras menores puras';

  @override
  String get thirdCommaMeanToneAbbr => '⅓ coma medio';

  @override
  String get fifthCommaMeanTone => '⅕ coma media';

  @override
  String get fifthCommaMeanToneDesc => 'Semitonos diatónicos puros';

  @override
  String get fifthCommaMeanToneAbbr => '⅕ coma media';

  @override
  String get werckmeisterIii => 'Werckmeister III';

  @override
  String get werckmeisterIiiDesc => 'Divisiones ¼ coma';

  @override
  String get werckmeisterIiiAbbr => 'Werckmeister III';

  @override
  String get werckmeisterIv => 'Werckmeister IV';

  @override
  String get werckmeisterIvDesc => 'División ⅓ punto';

  @override
  String get werckmeisterIvAbbr => 'Werckmeister IV';

  @override
  String get werckmeisterV => 'Werckmeister V';

  @override
  String get werckmeisterVDesc => 'Otras divisiones ¼ coma';

  @override
  String get werckmeisterVAbbr => 'Werckmeister V';

  @override
  String get werckmeisterVi => 'Werckmeister VI';

  @override
  String get werckmeisterViDesc => 'Septenario';

  @override
  String get werckmeisterViAbbr => 'Werckmeister VI';

  @override
  String get kirnberger1 => 'Kirnberger I';

  @override
  String get kirnberger1Desc => 'Una coma sintónica';

  @override
  String get kirnberger1Abbr => 'Kirnberger I';

  @override
  String get kirnberger2 => 'Kirnberger II';

  @override
  String get kirnberger2Desc =>
      'Fraccionamiento de la coma sintónica en dos partes iguales';

  @override
  String get kirnberger2Abbr => 'Kirnberger II';

  @override
  String get kirnberger3 => 'Kirnberger III';

  @override
  String get kirnberger3Desc => 'divisiones de ¼ de coma sintónica';

  @override
  String get kirnberger3Abbr => 'Kirnberger III';

  @override
  String get neidhardt1 => 'Neidhardt 1';

  @override
  String get neidhardt1Desc => 'Para un pueblo, 1732';

  @override
  String get neidhardt1Abbr => 'Neidhardt 1';

  @override
  String get neidhardt2 => 'Neidhardt 2';

  @override
  String get neidhardt2Desc => 'Para un pueblo pequeño, 1732';

  @override
  String get neidhardt2Abbr => 'Neidhardt 2';

  @override
  String get neidhardt3 => 'Neidhardt 3';

  @override
  String get neidhardt3Desc => 'Para una gran ciudad, 1732';

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
  String get referenceFrequency => 'Frecuencia de referencia';

  @override
  String get referenceNote => 'Nota de referencia';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get temperament => 'Temperamento';

  @override
  String get rootNote => 'nota tónica';

  @override
  String get testTuning => 'Ajuste de prueba';

  @override
  String get details => 'Detalles';

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
      'pC: Coma Pitagórica, 531441⁄524288\nsC: Coma Sintónica, 81⁄80\nsch: Schisma, 32805⁄32768';

  @override
  String get circleOfFifths => 'Círculo de quintas';

  @override
  String get setDefault => 'Restablecer a valores predeterminados';

  @override
  String get acknowledged => 'Admitido';

  @override
  String get blackNightMode => 'Fondo negro en modo oscuro';

  @override
  String get systemColorAccents => 'Color del sistema';

  @override
  String get incorrectTemperament => '¡Temperamento incompatible!';

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
  String get ok => 'Entiendo';

  @override
  String get newTemperamentRequiresAdaptingReferenceNote =>
      '¡El nuevo temperamento requiere adaptar la nota de referencia!';

  @override
  String get commaSeparator => ',';

  @override
  String get capture => 'Captura';

  @override
  String captureDuration(int seconds) {
    return 'Duración de la captura: $seconds s';
  }

  @override
  String get noCaptureDuration => 'Deshabilitar la captura';

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
  String get notationCarnatic => 'Carnática';

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
  String get notationHindustani => 'Hindustaní';

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
  String get notationByzantine => 'Bizantina';

  @override
  String get notationByzantineDescription => 'Νη-Πα-Βου-…-Ζω';

  @override
  String get extendedQuarterCommaMeanTone => 'Mesotónico extendido ¼ coma';

  @override
  String get extendedQuarterCommaMeanToneDesc =>
      'Terceras mayores puras, 15 notas';

  @override
  String get extendedQuarterCommaMeanToneAbbr =>
      'Mesotónico extendido de ¼ de coma';

  @override
  String get sensitivity => 'Sensibilidad';

  @override
  String get deleteItems => 'Borrar elementos';

  @override
  String get databaseEmptyShare => 'Sin elementos para compartir.';

  @override
  String get audioRecordPermissionRationale =>
      'Permitir acceso al micrófono para afinar.';

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
    return 'Escribiendo archivo de audio: $filename';
  }

  @override
  String get failedWritingWaveFile => 'No se escribió el archivo WAV.';

  @override
  String get instruments => 'Instrumentos';

  @override
  String get edit => 'Editar';

  @override
  String get copy => 'Copiar';

  @override
  String get delete => 'Borrar';

  @override
  String get temperaments => 'Temperamentos';

  @override
  String get save => 'Guardar';

  @override
  String get temperamentEditor => 'Editar los temperamentos';

  @override
  String get noteNumber => 'Número de notas';

  @override
  String get centStr => 'cent';

  @override
  String get octaveOffset => 'Desplazamiento de octava';

  @override
  String get ratio => 'Proporción';

  @override
  String get temperamentName => 'Nombre del temperamento';

  @override
  String get temperamentAbbreviation => 'Abreviatura';

  @override
  String get temperamentDescription => 'Descripción';

  @override
  String get decreasingValueError => 'El valor debe ser mayor que el anterior.';

  @override
  String get missingNoteName => 'Falta el nombre de la nota.';

  @override
  String get missingValue => 'Falta el valor en cents o la proporción.';

  @override
  String get duplicateNoteName => 'Nombre de nota duplicada.';

  @override
  String get invalidValue => 'Valor no válido.';

  @override
  String maximumValueExceeded(int max) {
    return 'Se superó el valor máximo de $max.';
  }

  @override
  String get edoTemperaments => 'Temperamentos iguales';

  @override
  String get otherTemperaments => 'Otros temperamentos';

  @override
  String get customTemperaments => 'Temperamentos personalizados';

  @override
  String get searchTemperamentsHint =>
      'Buscar temperamentos (ej. 19-EDO, Puro)...';

  @override
  String get notationVietnamese => 'Vietnamita';

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
  String get useDefault => 'Usar predeterminado';

  @override
  String get detectFrequency => 'Detectar frecuencia';

  @override
  String get stretch => 'Estiramiento de octava';

  @override
  String get stretchTuning => 'Afinación con estiramiento de octavas';

  @override
  String get noStretchTuning => 'Sin afinación estirada';

  @override
  String get stretchTuningOff => 'Afinación estirada: desactivada.';

  @override
  String get railsback => 'Curva de Railsback';

  @override
  String get railsbackDescription => 'Datos de Railsback (media)';

  @override
  String get name => 'Nombre';

  @override
  String get description => 'Descripción';

  @override
  String get stretchTuningEditor => 'Editar afinación estirada';

  @override
  String get stretchTuningInfo => 'Información sobre afinación estirada';

  @override
  String get stretchedFrequency => 'Frecuencia estirada';

  @override
  String get inputIsNoNumber => 'Entrada no válida: no es un número.';

  @override
  String get valueMustBeLargerZero => 'El valor debe ser > 0.';

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
    return 'Las frecuencias estiradas deben aumentar (anterior: $prev Hz,actual: $current Hz).';
  }

  @override
  String get octaveNotationScientific => 'Científica';

  @override
  String get octaveNotationScientificDescription => '… C¹ C² C³ C⁴ …';

  @override
  String get octaveNotationHelmholtz => 'Notación de Helmholtz';

  @override
  String get octaveNotationHelmholtzDescription => '… C, C c c\' …';

  @override
  String get octaveNotationHelmholtzNumbered => 'Helmholtz numerada';

  @override
  String get octaveNotationHelmholtzNumberedDescription => '… C₁ C c c¹ …';

  @override
  String get octaveRepresentation => 'Representación de octavas';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get systemDefault => 'Del sistema';

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
  String get instrumentTuner => 'Afinador de instrumentos';

  @override
  String get scientificTuner => 'Afinador científico';

  @override
  String get selectInstrument => 'Seleccionar instrumento';

  @override
  String get referencePitchDialogTitle => 'Tono de referencia A4 (Hz)';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get retry => 'Reintentar';

  @override
  String get dismiss => 'Descartar';

  @override
  String get resetTo440hz => 'Restablecer a 440 Hz';

  @override
  String get exportWav => 'Exportar WAV';

  @override
  String recordingExported(String filename) {
    return 'Grabación exportada: $filename';
  }

  @override
  String get noRecordingData => 'No hay datos de grabación para exportar';

  @override
  String exportFailed(String error) {
    return 'Error de exportación: $error';
  }

  @override
  String get restoreAutoDetection => 'Restaurar detección automática';

  @override
  String lockedString(String note) {
    return 'Cuerda bloqueada: $note';
  }

  @override
  String get italian => 'Italiano';

  @override
  String get russian => 'Ruso';

  @override
  String get japanese => 'Japonés';

  @override
  String get portuguese => 'Portugués';

  @override
  String get czech => 'Checo';

  @override
  String get swedish => 'Sueco';

  @override
  String get spanish => 'Español';

  @override
  String get vietnamese => 'Vietnamita';

  @override
  String get keepScreenOnDesc =>
      'Evita que la pantalla se apague mientras afina';

  @override
  String get toleranceDesc =>
      'Umbral para el indicador verde de precisión de tono';

  @override
  String get preferFlatDesc =>
      'Mostrar alteraciones como bemoles en vez de sostenidos (♭)';

  @override
  String get chromaticAsStaffDesc =>
      'Mostrar pentagrama en modo de instrumento cromático';

  @override
  String get sensitivityDesc =>
      'Umbral de ganancia de entrada para la detección de tono';

  @override
  String get octaveJumpGateDesc =>
      'Elimina ataques de duplicación armónica transitoria';

  @override
  String get medianFilterDesc =>
      'Filtra picos anómalos de tono de un solo fotograma';

  @override
  String get scientificModeDesc =>
      'Habilitar vistas de espectro FFT y análisis de correlación';

  @override
  String get numMovingAverageDesc =>
      'Muestras del búfer de suavizado para eliminar valores atípicos';

  @override
  String get windowSizeDesc => 'Longitud de muestra del búfer de análisis';

  @override
  String get overlapDesc =>
      'Superposición entre ventanas consecutivas de análisis';

  @override
  String get pitchHistoryDurationDesc =>
      'Ventana de tiempo mostrada en el historial de tono';

  @override
  String get jumpToNewPitchDirect =>
      'Saltar directamente al nuevo tono detectado';

  @override
  String jumpToNewPitchMultiple(int count) {
    return 'Después de $count tonos similares';
  }

  @override
  String get audioCaptureDesc =>
      'Capacidad de búfer de exportación WAV (0s desactiva el botón de exportación)';

  @override
  String get audioCaptureDisabled => 'Desactivado';

  @override
  String get displayOnLockScreenDesc =>
      'Permite que el afinador esté activo sobre la pantalla de bloqueo';

  @override
  String get resetAllSettingsDesc =>
      'Restablecer parámetros predeterminados de fábrica';

  @override
  String get aboutTunerDesc => 'Especificaciones de versión y arquitectura';

  @override
  String get resetSettingsConfirmTitle => 'Restablecer ajustes';

  @override
  String get resetSettingsConfirmMessage =>
      '¿Seguro que desea restablecer todos los ajustes a los valores de fábrica? Esta acción no se puede deshacer.';

  @override
  String get algorithmMpmDesc =>
      'Alta precisión y supresión robusta de saltos de octava para cuerdas.';

  @override
  String get algorithmTwmDesc =>
      'Coincidencia espectral armónica para sobretonos ricos/inarmónicos.';

  @override
  String get algorithmClassicDesc =>
      'Autocorrelación basada en FFT con ajuste de picos parabólicos.';

  @override
  String get algorithmJacobsenDesc =>
      'Interpolación de vocoder de fase de 3 bins complejos mejorada.';

  @override
  String get algorithmPyinDesc =>
      'Seguimiento de candidatos por camino de Viterbi en el tiempo.';

  @override
  String get weightingNone => 'Ninguna (Plana)';

  @override
  String get weightingNoneDesc =>
      'Espectro de frecuencia de audio lineal sin ponderación.';

  @override
  String get windowingTophatDesc =>
      'Sin atenuación de ventana (máxima resolución de frecuencia).';

  @override
  String get windowingHammingDesc =>
      'Supresión moderada de lóbulos laterales (-42 dB de atenuación).';

  @override
  String get windowingHanningDesc =>
      'Ventana cos² suave con fuerte caída de lóbulos laterales.';

  @override
  String get pureBlackOled => 'Negro puro (OLED)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get actions => 'Acciones';

  @override
  String get searchStretchTuningsHint =>
      'Buscar afinaciones con estiramiento...';

  @override
  String get deleteStretchTuning => 'Eliminar afinación estirada';

  @override
  String deleteStretchTuningConfirm(String name) {
    return '¿Seguro que desea eliminar \"$name\"?';
  }

  @override
  String get newStretchTuning => 'Nueva afinación estirada';

  @override
  String get noStretchPointsDefined =>
      'No hay puntos de estiramiento definidos.\nToca + para añadir uno.';

  @override
  String get editStretchPoint => 'Editar punto de estiramiento';

  @override
  String get addStretchPoint => 'Añadir punto de estiramiento';

  @override
  String get frequencyHz => 'Frecuencia (Hz)';

  @override
  String get stretchCents => 'Estiramiento (Cents)';

  @override
  String get frequencyMustBeIncreasing => 'Debe ser > que la anterior';

  @override
  String get createNewStretchTuning => 'Crear nueva afinación estirada';

  @override
  String get predefinedSection => 'PREDEFINIDO';

  @override
  String get customSection => 'PERSONALIZADO';
}
