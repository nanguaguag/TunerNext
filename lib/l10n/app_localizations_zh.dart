// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '调音器';

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
  String get windowingFunction => '窗函数';

  @override
  String get windowHamming => '汉明窗';

  @override
  String get windowHann => '汉恩窗';

  @override
  String get noWindow => '不使用窗函数';

  @override
  String get appearance => '外观';

  @override
  String get darkAppearance => '暗色外观';

  @override
  String get lightAppearance => '亮色外观';

  @override
  String get systemAppearance => '跟随系统设置';

  @override
  String get darkAppearanceShort => '暗色';

  @override
  String get lightAppearanceShort => '亮色';

  @override
  String get systemAppearanceShort => '自动';

  @override
  String get settings => '设置';

  @override
  String get overlap => '窗重叠';

  @override
  String get windowSize => '窗大小';

  @override
  String get minimumFrequency => '最低频率：';

  @override
  String get pitchHistoryDuration => '音高历史持续时间';

  @override
  String get pitchHistoryNumFaultyValues => '跳转到新的音高';

  @override
  String get numMovingAverage => '移动平均';

  @override
  String get about => '关于';

  @override
  String aboutMessage(Object value) {
    return 'Tuner app\n版本：$value\n许可证：GPLv3\nhttps://codeberg.org/thetwom/Tuner';
  }

  @override
  String get resetAllSettings => '重置所有设置';

  @override
  String get resetSettingsPrompt => '你确定要重置所有设置吗？';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get autocorrelation => '自相关';

  @override
  String get pitchHistory => '音高历史记录';

  @override
  String get spectrum => '频谱';

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
  String get keepScreenOn => '保持屏幕打开';

  @override
  String get displayOnLockScreen => '锁屏上显示';

  @override
  String get samples => '采样';

  @override
  String get scientificMode => '科学模式';

  @override
  String get toleranceInCents => '容限';

  @override
  String toleranceSummary(Object value) {
    return '±$value ¢';
  }

  @override
  String get expert => '专家';

  @override
  String get basic => '基础';

  @override
  String get others => '其它';

  @override
  String get chromatic => '半音阶';

  @override
  String get guitarEadgbe => '六弦吉他';

  @override
  String get bassEadg => '四弦贝斯';

  @override
  String get bassBeadg => '五弦贝斯';

  @override
  String get ukuleleGcea => '尤克里里';

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
  String get notation => '记谱法';

  @override
  String get notationRegional => '默认';

  @override
  String get notationRegionalDescription => 'C-D-E-…-B';

  @override
  String get notationSolfege => '唱名法';

  @override
  String get notationSolfegeDescription => 'Do-Re-Mi-…-Si';

  @override
  String get notationInternational => '国际标准';

  @override
  String get notationInternationalDescription => 'C-D-E-…-B';

  @override
  String get violinGdae => '小提琴';

  @override
  String get abort => '中止';

  @override
  String get instrumentName => '乐器名称';

  @override
  String get addNote => '添加音符';

  @override
  String get deleteNote => '删除音符';

  @override
  String get latelyDetectedNotes => '最近检测的音调';

  @override
  String get done => '完成';

  @override
  String get editInstrument => '编辑乐器';

  @override
  String get predefinedItems => '默认';

  @override
  String get customItem => '自定义';

  @override
  String fileEmpty(Object value) {
    return '文件为空：$value';
  }

  @override
  String fileInvalid(Object value) {
    return '文件无效：$value';
  }

  @override
  String get undo => '撤销';

  @override
  String get pickIcon => '选取图标';

  @override
  String copyExtension(Object value) {
    return '$value（副本）';
  }

  @override
  String get failedToArchiveItems => '无法将乐器写入文件';

  @override
  String get databaseEmpty => '没有可以保存的乐器。';

  @override
  String get replaceCurrentList => '替换当前列表';

  @override
  String get prependCurrentList => '在当前列表之前添加';

  @override
  String get appendCurrentList => '在当前列表之后添加';

  @override
  String get share => '分享乐器';

  @override
  String get loadFromDisk => '从文件加载乐器';

  @override
  String get saveToDisk => '保存乐器到文件';

  @override
  String get preferFlat => '倾向使用 \\u266D 而非 \\u266F';

  @override
  String get violaCgda => '中提琴';

  @override
  String get celloCgda => '大提琴';

  @override
  String get doubleBassEadg => '低音提琴';

  @override
  String get equalTemperament12 => 'Equal temperament';

  @override
  String equalTemperamentX(Object value) {
    return 'Equal temperament $value';
  }

  @override
  String equalTemperamentXAbbr(Object value) {
    return 'EDO $value';
  }

  @override
  String get pythagoreanTuning => 'Pythagorean tuning';

  @override
  String get pythagoreanTuningAbbr => 'Pythagorean';

  @override
  String get pureTuning => 'Just tuning';

  @override
  String get pureTuningDesc => '5-limit, asymmetric scale';

  @override
  String get pureTuningAbbr => 'Just';

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
  String get werckmeisterIii => 'Werckmeister III';

  @override
  String get werckmeisterIiiDesc => '¼ comma divisions';

  @override
  String get werckmeisterIiiAbbr => 'Werckmeister III';

  @override
  String get werckmeisterIv => 'Werckmeister IV';

  @override
  String get werckmeisterIvDesc => '⅓ comma divisions';

  @override
  String get werckmeisterIvAbbr => 'Werckmeister IV';

  @override
  String get werckmeisterV => 'Werckmeister V';

  @override
  String get werckmeisterVDesc => 'Other ¼ comma divisions';

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
  String get kirnberger1Desc => 'One syntonic comma';

  @override
  String get kirnberger1Abbr => 'Kirnberger I';

  @override
  String get kirnberger2 => 'Kirnberger II';

  @override
  String get kirnberger2Desc => '½ syntonic comma divisions';

  @override
  String get kirnberger2Abbr => 'Kirnberger II';

  @override
  String get kirnberger3 => 'Kirnberger III';

  @override
  String get kirnberger3Desc => '¼ syntonic comma divisions';

  @override
  String get kirnberger3Abbr => 'Kirnberger III';

  @override
  String get neidhardt1 => 'Neidhardt 1';

  @override
  String get neidhardt1Desc => 'For a village, 1732';

  @override
  String get neidhardt1Abbr => 'Neidhardt 1';

  @override
  String get neidhardt2 => 'Neidhardt 2';

  @override
  String get neidhardt2Desc => 'For a small town, 1732';

  @override
  String get neidhardt2Abbr => 'Neidhardt 2';

  @override
  String get neidhardt3 => 'Neidhardt 3';

  @override
  String get neidhardt3Desc => 'For a big city, 1732';

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
  String get referenceFrequency => '基准频率';

  @override
  String get frequency => '频率';

  @override
  String get temperament => '调律';

  @override
  String get rootNote => '主音';

  @override
  String get testTuning => '测试调音';

  @override
  String get details => '详细信息';

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
      'pC: Pythagorean Comma, 531441\\u2044524288\nsC: Syntonic Comma, 81\\u204480\nsch: Schisma, 32805\\u204432768';

  @override
  String get circleOfFifths => '五度圈';

  @override
  String get setDefault => '重置为默认';

  @override
  String get acknowledged => '知道了';

  @override
  String get blackNightMode => '深色模式下启用纯黑背景';

  @override
  String get systemColorAccents => '来自系统的强调色';

  @override
  String get incorrectTemperament => '不兼容的音律！';

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
  String get ok => '确定';

  @override
  String get newTemperamentRequiresAdaptingReferenceNote => '新的音调需要调整基准音符！';

  @override
  String get commaSeparator => ',\\ ';

  @override
  String get capture => '捕捉';

  @override
  String captureDuration(Object value) {
    return '捕捉时长：$value 秒';
  }

  @override
  String get noCaptureDuration => '禁用捕捉';

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
  String get extendedQuarterCommaMeanToneAbbr => '¼ 半音音程';

  @override
  String get sensitivity => '灵敏度';

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
  String get stretchTuning => '拉伸调音';

  @override
  String get noStretchTuning => '不使用拉伸调音';

  @override
  String get stretchTuningOff => '拉伸调音已关闭。';

  @override
  String get railsback => 'Railsback';

  @override
  String get railsbackDescription => 'Railsback data (average)';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get stretchTuningEditor => '编辑拉伸调音';

  @override
  String get stretchTuningInfo => '拉伸调音信息';

  @override
  String get stretchedFrequency => '拉伸的频率';

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
    return '拉伸频率必须严格递增（上一个值：$val1 Hz，当前值：$val2 Hz）。';
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
  String get advancedAcousticDsp => '进阶声学实验室 (DSP)';

  @override
  String get pitchAlgorithm => '音高检测核心算法';

  @override
  String get pitchAlgorithmSummary =>
      '选择底层基频检测与追踪引擎（经典算法、MPM、TWM、pYIN、Jacobsen 混合）';

  @override
  String get pitchAlgoClassic => '经典算法 (自相关 + 相位声码器)';

  @override
  String get pitchAlgoClassicDescription =>
      '原版基线算法。结合时域自相关与频域 FFT 相位插值，适合平稳周期信号。';

  @override
  String get pitchAlgoHybrid => 'Jacobsen 混合算法 (复数谱插值)';

  @override
  String get pitchAlgoHybridDescription =>
      '基于 Jacobsen 3 点复数谱插值优化频域峰值，彻底消除高频整数谱峰切换时的相位震荡。';

  @override
  String get pitchAlgoMpm => 'MPM 算法 (McLeod Pitch Method)';

  @override
  String get pitchAlgoMpmDescription =>
      '归一化差分函数 (NSDF) 配合首峰门限裁决。专克小提琴与笛管的八度倍频翻转，清晰度极高。';

  @override
  String get pitchAlgoTwm => 'TWM 算法 (双向失配谐波匹配)';

  @override
  String get pitchAlgoTwmDescription =>
      '频域谐波双向误差评估并内置弦刚度非谐波性补偿。擅长基频缺失、低音厚弦及共鸣箱丰富乐器。';

  @override
  String get pitchAlgoPyin => 'pYIN 算法 (概率时序连续性追踪)';

  @override
  String get pitchAlgoPyinDescription =>
      '多候选概率采样与 HMM 状态平滑。小提琴快速运弓与弱信号下轨迹极为平顺稳定。';

  @override
  String get octaveJumpGate => '起音八度防飞门限';

  @override
  String get octaveJumpGateSummary => '抑制小提琴等运弓接触瞬间摩擦杂音导致的音高倍频跳跃，杜绝指示圆点飞出屏幕';

  @override
  String get medianFilter => '高把位加权中值防抖';

  @override
  String get medianFilterSummary => '拉奏高音时滤除因采样点离散误差引起的上下剧烈抖动，零时延保持跟手度';

  @override
  String get acousticWeighting => '人耳声学计权滤波';

  @override
  String get acousticWeightingSummary =>
      '启用 A 计权模拟人耳听觉特性，大幅衰减 50Hz 市电工频与环境低频底噪，静音更稳定';

  @override
  String get acousticWeightingNone => '平直（无计权）';

  @override
  String get acousticWeightingNoneDescription => '平直频响，不对各频段做声学校准。';

  @override
  String get acousticWeightingA => 'A 计权（推荐：模拟人耳，滤除底噪）';

  @override
  String get acousticWeightingADescription =>
      '遵循 IEC 61672 标准模拟人耳听觉特性，大幅衰减 50/60Hz 工频底噪与风噪（推荐）。';

  @override
  String get acousticWeightingC => 'C 计权';

  @override
  String get acousticWeightingCDescription => '标准 C 计权曲线，适用于较高声压级的大音量声学环境。';

  @override
  String pitchHistoryNumFaultyValuesSummary(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'After $countString similar pitch results',
      one: 'Directly jump to new pitch result',
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
      other: 'Average over $countString pitch results',
      one: 'No averaging',
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
      other: 'Loading $countString instruments',
      one: 'Loading $countString instrument',
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
      other: '正在加载 $countString 个律制',
      one: '',
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
      other: '正在分享 $countString 个项目',
      one: '',
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
      other: '$countString notes per octave',
      one: '$countString note per octave',
    );
    return '$_temp0';
  }
}
