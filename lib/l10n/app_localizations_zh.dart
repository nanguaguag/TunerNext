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
  String pitchHistoryNumFaultyValuesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '连续检测到 $count 次相似音高后跳转',
      one: '直接跳转到新音高结果',
    );
    return '$_temp0';
  }

  @override
  String get numMovingAverage => '移动平均';

  @override
  String numMovingAverageSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '对连续 $count 次音高结果取移动平均',
      one: '不进行平滑平均',
    );
    return '$_temp0';
  }

  @override
  String get about => '关于';

  @override
  String aboutMessage(String version) {
    return 'Tuner app\n版本：$version\n许可证：GPLv3\nhttps://codeberg.org/thetwom/Tuner';
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
  String toleranceSummary(int cents) {
    return '±$cents ¢';
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
  String fileEmpty(String filename) {
    return '文件为空：$filename';
  }

  @override
  String fileInvalid(String filename) {
    return '文件无效：$filename';
  }

  @override
  String itemsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已删除 $count 个项目',
      one: '已删除 $count 个项目',
    );
    return '$_temp0';
  }

  @override
  String get undo => '撤销';

  @override
  String get pickIcon => '选取图标';

  @override
  String copyExtension(String name) {
    return '$name（副本）';
  }

  @override
  String get failedToArchiveItems => '无法将乐器写入文件';

  @override
  String databaseNumSaved(int count, String filename) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在将 $count 个项目保存至 \"$filename\"',
      one: '正在将 $count 个项目保存至 \"$filename\"',
    );
    return '$_temp0';
  }

  @override
  String get databaseEmpty => '没有可以保存的乐器。';

  @override
  String loadInstruments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在加载 $count 种乐器',
      one: '正在加载 $count 种乐器',
    );
    return '$_temp0';
  }

  @override
  String loadTemperaments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在加载 $count 个律制',
      one: '',
    );
    return '$_temp0';
  }

  @override
  String loadStretchTunings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在加载 $count 个延展调音预设',
      one: '正在加载 $count 个延展调音预设',
    );
    return '$_temp0';
  }

  @override
  String get replaceCurrentList => '替换当前列表';

  @override
  String get prependCurrentList => '在当前列表之前添加';

  @override
  String get appendCurrentList => '在当前列表之后添加';

  @override
  String get share => '分享乐器';

  @override
  String sharingNumItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在分享 $count 个项目',
      one: '',
    );
    return '$_temp0';
  }

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
  String get equalTemperament12 => '十二平均律';

  @override
  String equalTemperamentX(int divisions) {
    return '$divisions 平均律';
  }

  @override
  String equalTemperamentXDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每个八度包含 $count 个音符',
      one: '每个八度包含 $count 个音符',
    );
    return '$_temp0';
  }

  @override
  String equalTemperamentXAbbr(int divisions) {
    return '$divisions-EDO';
  }

  @override
  String get pythagoreanTuning => '毕达哥拉斯音律 (五度相生律)';

  @override
  String get pythagoreanTuningAbbr => '毕达哥拉斯律';

  @override
  String get pureTuning => '纯律 (五极限自然纯律)';

  @override
  String get pureTuningDesc => '五极限非对称纯律，纯正纯三度与纯五度';

  @override
  String get pureTuningAbbr => '纯律';

  @override
  String get quarterCommaMeanTone => '¼ 常见中庸全音律';

  @override
  String get quarterCommaMeanToneDesc => '纯大三度音程调律';

  @override
  String get quarterCommaMeanToneAbbr => '¼ 中庸全音律';

  @override
  String get thirdCommaMeanTone => '⅓ 常见中庸全音律';

  @override
  String get thirdCommaMeanToneDesc => '纯小三度音程调律';

  @override
  String get thirdCommaMeanToneAbbr => '⅓ 中庸全音律';

  @override
  String get fifthCommaMeanTone => '⅕ 常见中庸全音律';

  @override
  String get fifthCommaMeanToneDesc => '纯自然半音调律';

  @override
  String get fifthCommaMeanToneAbbr => '⅕ 中庸全音律';

  @override
  String get werckmeisterIii => '韦克迈斯特第 III 律制';

  @override
  String get werckmeisterIiiDesc => '¼ 音差分割良律';

  @override
  String get werckmeisterIiiAbbr => '韦克迈斯特 III';

  @override
  String get werckmeisterIv => '韦克迈斯特第 IV 律制';

  @override
  String get werckmeisterIvDesc => '⅓ 音差分割良律';

  @override
  String get werckmeisterIvAbbr => '韦克迈斯特 IV';

  @override
  String get werckmeisterV => '韦克迈斯特第 V 律制';

  @override
  String get werckmeisterVDesc => '其他 ¼ 音差分割良律';

  @override
  String get werckmeisterVAbbr => '韦克迈斯特 V';

  @override
  String get werckmeisterVi => '韦克迈斯特第 VI 律制 (七分律)';

  @override
  String get werckmeisterViDesc => '七分等分分割律';

  @override
  String get werckmeisterViAbbr => '韦克迈斯特 VI';

  @override
  String get kirnberger1 => '柯恩伯格第 I 律制';

  @override
  String get kirnberger1Desc => '含一个单音差调律';

  @override
  String get kirnberger1Abbr => '柯恩伯格 I';

  @override
  String get kirnberger2 => '柯恩伯格第 II 律制';

  @override
  String get kirnberger2Desc => '½ 双音差分割调律';

  @override
  String get kirnberger2Abbr => '柯恩伯格 II';

  @override
  String get kirnberger3 => '柯恩伯格第 III 律制';

  @override
  String get kirnberger3Desc => '¼ 常见音差分割调律';

  @override
  String get kirnberger3Abbr => '柯恩伯格 III';

  @override
  String get neidhardt1 => '诺伊哈特第 1 律制';

  @override
  String get neidhardt1Desc => '乡村环境调律，1732';

  @override
  String get neidhardt1Abbr => '诺伊哈特 1';

  @override
  String get neidhardt2 => '诺伊哈特第 2 律制';

  @override
  String get neidhardt2Desc => '城镇环境调律，1732';

  @override
  String get neidhardt2Abbr => '诺伊哈特 2';

  @override
  String get neidhardt3 => '诺伊哈特第 3 律制';

  @override
  String get neidhardt3Desc => '大都市环境调律，1732';

  @override
  String get neidhardt3Abbr => '诺伊哈特 3';

  @override
  String get valotti => '瓦洛蒂律制';

  @override
  String get valottiAbbr => '瓦洛蒂';

  @override
  String get young2 => '杨氏第 2 律制';

  @override
  String get young2Abbr => '杨氏 2';

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
      'pC: 毕氏音差 (Pythagorean Comma), 531441⁄524288\nsC: 联音音差 (Syntonic Comma), 81⁄80\nsch: 缓音差 (Schisma), 32805⁄32768';

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
  String get keySignatureSharp => '调号：增加一个升号或减少一个降号';

  @override
  String get keySignatureFlat => '调号：增加一个降号或减少一个升号';

  @override
  String get staffClef => '谱号';

  @override
  String get staffClefGrand => '大谱表 (高低音谱表)';

  @override
  String get staffClefTreble => '高音谱号 (G 谱号)';

  @override
  String get staffClefTenor => '次中音谱号 (C 谱号)';

  @override
  String get staffClefBass => '低音谱号 (F 谱号)';

  @override
  String get chromaticAsStaff => '半音阶调音器五线谱显示';

  @override
  String get chromaticAsStaffSummary => '在五线谱上显示目标音符，而非展示所有音符列表';

  @override
  String get ok => '确定';

  @override
  String get newTemperamentRequiresAdaptingReferenceNote => '新的音调需要调整基准音符！';

  @override
  String get commaSeparator => ', ';

  @override
  String get capture => '捕捉';

  @override
  String captureDuration(int seconds) {
    return '捕捉时长：$seconds 秒';
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
  String get notationCarnatic => '卡纳提克记谱法';

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
  String get notationHindustani => '印度斯坦记谱法';

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
  String get notationByzantine => '拜占庭记谱法';

  @override
  String get notationByzantineDescription => 'Νη-Πα-Βου-…-Ζω';

  @override
  String get extendedQuarterCommaMeanTone => '扩展 ¼ 常见中庸全音律';

  @override
  String get extendedQuarterCommaMeanToneDesc => '纯大三度音程，包含 15 个音级';

  @override
  String get extendedQuarterCommaMeanToneAbbr => '¼ 半音音程';

  @override
  String get sensitivity => '灵敏度';

  @override
  String get deleteItems => '删除项目';

  @override
  String get databaseEmptyShare => '暂无可以分享的乐器项目。';

  @override
  String get audioRecordPermissionRationale => '请授予麦克风录音权限以启动调音分析。';

  @override
  String soundSourceInvalidBufferSize(int error) {
    return '当前设置不支持当前音频缓冲区大小 (错误代码 $error)。';
  }

  @override
  String get soundSourceMicrophoneUnavailable => '无法访问麦克风设备，可能正被其他应用程序独占占用。';

  @override
  String soundSourceReadFailed(int error) {
    return '从麦克风读取音频数据失败 (错误代码 $error)，可能已被系统中断或被其他应用占用。';
  }

  @override
  String writingWaveFile(String filename) {
    return '正在保存音频文件：$filename';
  }

  @override
  String get failedWritingWaveFile => '音频文件保存失败。';

  @override
  String get instruments => '乐器管理';

  @override
  String get edit => '编辑';

  @override
  String get copy => '复制';

  @override
  String get delete => '删除';

  @override
  String get temperaments => '历史与现代律制';

  @override
  String get save => '保存';

  @override
  String get temperamentEditor => '编辑音律';

  @override
  String get noteNumber => '音符数量';

  @override
  String get centStr => '音分';

  @override
  String get octaveOffset => '八度偏移';

  @override
  String get ratio => '音程比率';

  @override
  String get temperamentName => '律制名称';

  @override
  String get temperamentAbbreviation => '律制缩写';

  @override
  String get temperamentDescription => '律制描述';

  @override
  String get decreasingValueError => '数值必须严格大于前一个音级值。';

  @override
  String get missingNoteName => '缺少音符名称。';

  @override
  String get missingValue => '缺少音分或比率数值。';

  @override
  String get duplicateNoteName => '音符名称重复。';

  @override
  String get invalidValue => '无效的数值格式。';

  @override
  String maximumValueExceeded(int max) {
    return '超出最大允许值 $max。';
  }

  @override
  String get edoTemperaments => '平均律体系 (EDO)';

  @override
  String get otherTemperaments => '历史名律与其他律制';

  @override
  String get customTemperaments => '自定义律制';

  @override
  String get notationVietnamese => '越南记谱法';

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
  String get useDefault => '恢复默认';

  @override
  String get detectFrequency => '检测基频';

  @override
  String get stretch => '延展调音';

  @override
  String get stretchTuning => '拉伸调音';

  @override
  String get noStretchTuning => '不使用拉伸调音';

  @override
  String get stretchTuningOff => '拉伸调音已关闭。';

  @override
  String get railsback => '雷尔斯贝克曲线 (Railsback)';

  @override
  String get railsbackDescription => '雷尔斯贝克钢琴声学校准曲线 (平均统计值)';

  @override
  String get name => '名称';

  @override
  String get description => '说明描述';

  @override
  String get stretchTuningEditor => '编辑拉伸调音';

  @override
  String get stretchTuningInfo => '拉伸调音信息';

  @override
  String get stretchedFrequency => '拉伸的频率';

  @override
  String get inputIsNoNumber => '输入内容非有效数字格式。';

  @override
  String get valueMustBeLargerZero => '数值必须大于零。';

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
    return '拉伸频率必须严格递增（上一个值：$prev Hz，当前值：$current Hz）。';
  }

  @override
  String get octaveNotationScientific => '科学记谱法 (C4, A4)';

  @override
  String get octaveNotationScientificDescription => '… C¹ C² C³ C⁴ …';

  @override
  String get octaveNotationHelmholtz => '亥姆霍兹记谱法 (c\'\'\', a\'\')';

  @override
  String get octaveNotationHelmholtzDescription => '… C, C c c\' …';

  @override
  String get octaveNotationHelmholtzNumbered => '亥姆霍兹数字记谱法 (c1, a1)';

  @override
  String get octaveNotationHelmholtzNumberedDescription => '… C₁ C c c¹ …';

  @override
  String get octaveRepresentation => '八度记谱符号体系';

  @override
  String get language => '语言';

  @override
  String get english => 'English (英文)';

  @override
  String get german => 'Deutsch (德文)';

  @override
  String get systemDefault => '跟随系统默认';

  @override
  String get french => 'Français (法文)';

  @override
  String get hungarian => 'Magyar (匈牙利文)';

  @override
  String get polish => 'Polski (波兰文)';

  @override
  String get ukrainian => 'Українська';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get romanian => 'Română (罗马尼亚文)';

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
  String get instrumentTuner => '乐器调音';

  @override
  String get scientificTuner => '科学调音';

  @override
  String get selectInstrument => '选择乐器定弦';

  @override
  String get referencePitchDialogTitle => 'A4 基准参考音高 (Hz)';

  @override
  String get unlock => '解锁';

  @override
  String get retry => '重试';

  @override
  String get dismiss => '忽略';

  @override
  String get resetTo440hz => '重置 440 Hz';

  @override
  String get exportWav => '导出 WAV';

  @override
  String recordingExported(String filename) {
    return '录音已导出: $filename';
  }

  @override
  String get noRecordingData => '暂无可导出的录音数据';

  @override
  String exportFailed(String error) {
    return '导出失败: $error';
  }

  @override
  String get restoreAutoDetection => '恢复自动识别';

  @override
  String lockedString(String note) {
    return '已锁定琴弦: $note';
  }

  @override
  String get italian => '意大利语';

  @override
  String get russian => '俄语';

  @override
  String get japanese => '日语';

  @override
  String get portuguese => '葡萄牙语';

  @override
  String get czech => '捷克语';

  @override
  String get swedish => '瑞典语';

  @override
  String get spanish => '西班牙语';

  @override
  String get vietnamese => '越南语';
}
