import 'package:flutter/material.dart';

import '../models/mock_exam_license_kind.dart';
import '../services/subcategory_classifier.dart';

/// 홈·하단 탭 등 주요 UI 문자열 (ko / en / zh / vi)
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String _t(Map<String, String> m) =>
      m[locale.languageCode] ?? m['ko']!;

  // ——— 일반 ———
  String get appTitle => _t({
        'ko': '운전면허 학과시험 1000제',
        'en': 'Driver\'s License Written Exam 1000',
        'zh': '驾照学科考试 1000 题',
        'vi': 'Thi lý thuyết lái xe 1000 câu',
      });

  String get greetHello => _t({
        'ko': '안녕하세요.',
        'en': 'Hello.',
        'zh': '您好。',
        'vi': 'Xin chào.',
      });

  String get titleMain => _t({
        'ko': '운전면허 학과시험',
        'en': 'Driver\'s License Knowledge Test',
        'zh': '驾照学科考试',
        'vi': 'Thi lý thuyết lái xe',
      });

  String get learningProgress => _t({
        'ko': '학습 진도',
        'en': 'Study progress',
        'zh': '学习进度',
        'vi': 'Tiến độ học',
      });

  String get mockExamScoreToday => _t({
        'ko': '오늘 모의고사 점수',
        'en': 'Today\'s exam score',
        'zh': '今日模拟考分数',
        'vi': 'Điểm thi thử hôm nay',
      });

  String get scoreZero => _t({
        'ko': '0점',
        'en': '0 pts',
        'zh': '0 分',
        'vi': '0 điểm',
      });

  String progressQuestions(int attempted, int total) {
    switch (locale.languageCode) {
      case 'en':
        return '$attempted / $total questions';
      case 'zh':
        return '$attempted / $total 题';
      case 'vi':
        return '$attempted / $total câu';
      case 'ko':
      default:
        return '$attempted / $total문제';
    }
  }

  String get problemTypes => _t({
        'ko': '문제 유형',
        'en': 'Question types',
        'zh': '题目类型',
        'vi': 'Loại câu hỏi',
      });

  String get menuPracticeTitle => _t({
        'ko': '문제 풀기',
        'en': 'Practice',
        'zh': '做题练习',
        'vi': 'Luyện đề',
      });

  String get menuPracticeSubtitle => _t({
        'ko': '유형을 골라 랜덤 40문제 연습',
        'en': 'Pick a type — random 40 questions',
        'zh': '选类型，随机 40 题',
        'vi': 'Chọn dạng — 40 câu ngẫu nhiên',
      });

  String menuFavoritesSubtitle(int count) => _t({
        'ko': '저장한 문제 $count개',
        'en': '$count saved questions',
        'zh': '已收藏 $count 题',
        'vi': '$count câu đã lưu',
      });

  String menuWrongSubtitle(int count) => _t({
        'ko': '틀린 문제 $count개',
        'en': '$count wrong questions',
        'zh': '错题 $count 道',
        'vi': '$count câu sai',
      });

  String get menuFavoritesTitle => _t({
        'ko': '즐겨찾기 문제',
        'en': 'Favorites',
        'zh': '收藏题目',
        'vi': 'Câu yêu thích',
      });

  String get menuWrongTitle => _t({
        'ko': '오답 다시 풀기',
        'en': 'Review wrong answers',
        'zh': '错题重做',
        'vi': 'Ôn câu sai',
      });

  String get menuMockTitle => _t({
        'ko': '모의고사 응시',
        'en': 'Exam',
        'zh': '模拟考试',
        'vi': 'Thi thử',
      });

  String get menuMockSubtitle => _t({
        'ko': '실제 시험과 동일한 40문제',
        'en': '40 questions like the real test',
        'zh': '与正式考试相同的 40 题',
        'vi': '40 câu giống thi thật',
      });

  String get mockLicenseSheetTitle => _t({
        'ko': '모의고사 면허 종류',
        'en': 'License type (exam)',
        'zh': '模拟考试 驾照类型',
        'vi': 'Loại bằng (thi thử)',
      });

  String get mockLicenseSheetHint => _t({
        'ko': '응시할 면허를 선택하면 합격 기준이 적용됩니다.',
        'en': 'Passing rules depend on the type you choose.',
        'zh': '所选类型将决定及格分数。',
        'vi': 'Tiêu chí đậu phụ thuộc loại bằng bạn chọn.',
      });

  String mockLicenseLabel(MockExamLicenseKind kind) {
    switch (kind) {
      case MockExamLicenseKind.type1Large:
        return _t({
          'ko': '1종 대형',
          'en': 'Class 1 large',
          'zh': '1类 大型',
          'vi': 'Hạng 1 xe lớn',
        });
      case MockExamLicenseKind.type1Special:
        return _t({
          'ko': '1종 특수',
          'en': 'Class 1 special',
          'zh': '1类 特殊',
          'vi': 'Hạng 1 đặc thù',
        });
      case MockExamLicenseKind.type1Normal:
        return _t({
          'ko': '1종 보통',
          'en': 'Class 1 regular',
          'zh': '1类 普通',
          'vi': 'Hạng 1 thường',
        });
      case MockExamLicenseKind.type2Normal:
        return _t({
          'ko': '2종 보통',
          'en': 'Class 2 regular',
          'zh': '2类 普通',
          'vi': 'Hạng 2 thường',
        });
    }
  }

  String get mockResultPass => _t({
        'ko': '합격',
        'en': 'Pass',
        'zh': '合格',
        'vi': 'Đạt',
      });

  String get mockResultFail => _t({
        'ko': '불합격',
        'en': 'Fail',
        'zh': '不合格',
        'vi': 'Không đạt',
      });

  String mockResultScaledScore(int points) {
    return _t({
      'ko': '환산 점수 {p}점 (만점 100점)',
      'en': 'Converted score: {p} / 100',
      'zh': '换算得分 {p} 分（满分 100）',
      'vi': 'Điểm quy đổi: {p}/100',
    }).replaceAll('{p}', '$points');
  }

  String mockResultPassBar(int minPoints) {
    return _t({
      'ko': '합격 기준: {p}점 이상',
      'en': 'Passing: {p} or above (out of 100)',
      'zh': '及格线：{p} 分及以上',
      'vi': 'Đậu: từ {p} điểm trở lên (thang 100)',
    }).replaceAll('{p}', '$minPoints');
  }

  String get mockResultLicenseKindLine => _t({
        'ko': '면허 구분',
        'en': 'License type',
        'zh': '驾照类别',
        'vi': 'Loại bằng',
      });

  String get mockExamHistoryTitle => _t({
        'ko': '모의고사 기록',
        'en': 'Exam history',
        'zh': '模拟考试记录',
        'vi': 'Lịch sử thi thử',
      });

  String get mockExamHistoryEmpty => _t({
        'ko': '아직 모의고사 응시 기록이 없어요.',
        'en': 'No exam attempts yet.',
        'zh': '暂无模拟考试记录。',
        'vi': 'Chưa có lần thi thử nào.',
      });

  String get mockExamNoRecordYet => _t({
        'ko': '—',
        'en': '—',
        'zh': '—',
        'vi': '—',
      });

  String mockExamCardPoints(int points) {
    return _t({
      'ko': '{p}점',
      'en': '{p} pts',
      'zh': '{p} 分',
      'vi': '{p} điểm',
    }).replaceAll('{p}', '$points');
  }

  String get mockExamHistoryWhen => _t({
        'ko': '응시 일시',
        'en': 'Date & time',
        'zh': '日期时间',
        'vi': 'Thời gian',
      });

  String get mockExamHistoryScoreLine => _t({
        'ko': '정답',
        'en': 'Score',
        'zh': '得分',
        'vi': 'Điểm',
      });

  String get tipTitle => _t({
        'ko': '기능 및 도로주행 실격사항',
        'en': 'Road test disqualification',
        'zh': '技能与路考不合格事项',
        'vi': 'Thi kỹ năng & sa hình: điểm loại',
      });

  String get disqualificationLoading => _t({
        'ko': '실격 기준을 불러오는 중…',
        'en': 'Loading disqualification rules…',
        'zh': '正在加载不合格标准…',
        'vi': 'Đang tải tiêu chí loại…',
      });

  String get disqualificationLoadError => _t({
        'ko': '실격 기준을 불러오지 못했습니다.',
        'en': 'Could not load disqualification rules.',
        'zh': '无法加载不合格标准。',
        'vi': 'Không tải được tiêu chí loại.',
      });

  String get disqualificationViewAll => _t({
        'ko': '전체보기',
        'en': 'View all',
        'zh': '查看全部',
        'vi': 'Xem tất cả',
      });

  String get disqualificationScreenTitle => _t({
        'ko': '실격사항',
        'en': 'Disqualifications',
        'zh': '不合格事项',
        'vi': 'Tiêu chí loại',
      });

  String get disqualificationTabFunction => _t({
        'ko': '기능시험',
        'en': 'Skills test',
        'zh': '技能考试',
        'vi': 'Thi sa hình',
      });

  String get disqualificationTabRoad => _t({
        'ko': '도로주행',
        'en': 'Road test',
        'zh': '路考',
        'vi': 'Thi đường trường',
      });

  String get disqualificationSourceLink => _t({
        'ko': '공식 안내 원문 보기',
        'en': 'Official source',
        'zh': '官方原文',
        'vi': 'Nguồn chính thức',
      });

  String get linkOpenFailed => _t({
        'ko': '링크를 열지 못했습니다.',
        'en': 'Could not open the link.',
        'zh': '无法打开链接。',
        'vi': 'Không mở được liên kết.',
      });

  String get navExamOrder => _t({
        'ko': '면허시험 순서',
        'en': 'Exam steps',
        'zh': '考试顺序',
        'vi': 'Trình tự thi',
      });

  String get navPrep => _t({
        'ko': '준비물 가이드',
        'en': 'What to bring',
        'zh': '准备物品',
        'vi': 'Đồ cần mang',
      });

  String get navEduSchedule => _t({
        'ko': '특별교육 일정',
        'en': 'Special training',
        'zh': '特别教育日程',
        'vi': 'Lịch học đặc biệt',
      });

  String get navTestSchedule => _t({
        'ko': '면허시험 일정',
        'en': 'Test schedule',
        'zh': '考试日程',
        'vi': 'Lịch thi',
      });

  String get languageSheetTitle => _t({
        'ko': '언어',
        'en': 'Language',
        'zh': '语言',
        'vi': 'Ngôn ngữ',
      });

  String get languageSheetTranslationNote => _t({
        'ko': '번역이 다소 어색할 수 있습니다.',
        'en': 'The translation may be somewhat awkward.',
        'zh': '翻译可能略显生硬。',
        'vi': 'Bản dịch có thể hơi gượng.',
      });

  String get languageKo => _t({
        'ko': '한국어',
        'en': 'Korean',
        'zh': '韩语',
        'vi': 'Tiếng Hàn',
      });

  String get languageEn => _t({
        'ko': 'English',
        'en': 'English',
        'zh': '英语',
        'vi': 'English',
      });

  String get languageZh => _t({
        'ko': '中文',
        'en': 'Chinese',
        'zh': '中文',
        'vi': 'Tiếng Trung',
      });

  String get languageVi => _t({
        'ko': 'Tiếng Việt',
        'en': 'Vietnamese',
        'zh': '越南语',
        'vi': 'Tiếng Việt',
      });

  String get languageButtonTooltip => _t({
        'ko': '언어 선택',
        'en': 'Choose language',
        'zh': '选择语言',
        'vi': 'Chọn ngôn ngữ',
      });

  String get themeModeSheetTitle => _t({
        'ko': '화면 테마',
        'en': 'Appearance',
        'zh': '外观主题',
        'vi': 'Giao diện',
      });

  String get themeModeSystem => _t({
        'ko': '시스템 설정과 같이',
        'en': 'Same as device',
        'zh': '跟随系统',
        'vi': 'Theo thiết bị',
      });

  String get themeModeLight => _t({
        'ko': '라이트',
        'en': 'Light',
        'zh': '浅色',
        'vi': 'Sáng',
      });

  String get themeModeDark => _t({
        'ko': '다크',
        'en': 'Dark',
        'zh': '深色',
        'vi': 'Tối',
      });

  String get practiceSheetTitle => _t({
        'ko': '어떤 문제를 풀까요?',
        'en': 'Which type to practice?',
        'zh': '要练习哪种题目？',
        'vi': 'Bạn muốn luyện dạng nào?',
      });

  String get practiceVerbalTitle => _t({
        'ko': '말문제',
        'en': 'Text questions',
        'zh': '文字题',
        'vi': 'Câu lý thuyết',
      });

  String get practiceVerbalSub => _t({
        'ko': '말로 된 이론 문제 위주로 연습',
        'en': 'Theory questions in text',
        'zh': '以文字理论题为主',
        'vi': 'Luyện câu lý thuyết dạng chữ',
      });

  String get practiceSignTitle => _t({
        'ko': '표지 및 상황문제',
        'en': 'Signs & situations',
        'zh': '标志与情景题',
        'vi': 'Biển báo & tình huống',
      });

  String get practiceSignSub => _t({
        'ko': '표지, 표지판, 상황 그림 문제 위주로 연습',
        'en': 'Signs, road signs, situation images',
        'zh': '标志、路牌、情景图为主',
        'vi': 'Biển báo, biển đường, hình tình huống',
      });

  String get practiceVideoTitle => _t({
        'ko': '동영상 문제',
        'en': 'Video questions',
        'zh': '视频题',
        'vi': 'Câu có video',
      });

  String get practiceVideoSub => _t({
        'ko': '영상 기반 상황 판단 문제 위주로 연습',
        'en': 'Video-based situation judgment',
        'zh': '基于视频的情景判断',
        'vi': 'Phán đoán tình huống qua video',
      });

  String get practiceRandomTitle => _t({
        'ko': '랜덤 문제',
        'en': 'Random',
        'zh': '随机题',
        'vi': 'Ngẫu nhiên',
      });

  String get practiceRandomSub => _t({
        'ko': '전체 문항 중 무작위 40문제',
        'en': 'Random 40 from all questions',
        'zh': '从全部题目随机 40 题',
        'vi': '40 câu ngẫu nhiên từ toàn bộ',
      });

  String get snackNoFavorites => _t({
        'ko': '즐겨찾기한 문제가 없어요. 풀이 화면에서 별을 눌러 추가하세요.',
        'en': 'No favorites yet. Tap the star while solving to add.',
        'zh': '暂无收藏。答题时点击星标添加。',
        'vi': 'Chưa có câu yêu thích. Nhấn sao khi làm bài để thêm.',
      });

  String get snackNoWrong => _t({
        'ko': '저장된 오답이 없어요.',
        'en': 'No saved wrong answers.',
        'zh': '没有已保存的错题。',
        'vi': 'Chưa có câu sai đã lưu.',
      });

  String get snackNoQuestionsForType => _t({
        'ko': '선택한 유형의 문제를 찾지 못했어요.',
        'en': 'No questions found for that type.',
        'zh': '未找到该类型的题目。',
        'vi': 'Không tìm thấy câu cho loại đã chọn.',
      });

  String get quizTitleFavorites => _t({
        'ko': '즐겨찾기',
        'en': 'Favorites',
        'zh': '收藏',
        'vi': 'Yêu thích',
      });

  String get quizTitleWrong => _t({
        'ko': '오답 다시 풀기',
        'en': 'Wrong answers',
        'zh': '错题重做',
        'vi': 'Ôn câu sai',
      });

  String get quizTitleVerbal => _t({
        'ko': '말문제 풀기',
        'en': 'Text questions',
        'zh': '文字题练习',
        'vi': 'Luyện lý thuyết',
      });

  String get quizTitleSign => _t({
        'ko': '표지 및 상황문제 풀기',
        'en': 'Signs & situations',
        'zh': '标志与情景练习',
        'vi': 'Biển báo & tình huống',
      });

  String get quizTitleVideo => _t({
        'ko': '동영상 문제 풀기',
        'en': 'Video questions',
        'zh': '视频题练习',
        'vi': 'Câu video',
      });

  String get quizTitleRandom => _t({
        'ko': '랜덤 문제 풀기',
        'en': 'Random practice',
        'zh': '随机练习',
        'vi': 'Luyện ngẫu nhiên',
      });

  // ——— 말문제 소카테고리 ———
  String get subcategorySheetTitle => _t({
        'ko': '어떤 주제로 풀까요?',
        'en': 'Which topic?',
        'zh': '练习哪个主题？',
        'vi': 'Chủ đề nào?',
      });

  String get subcategoryAllVerbalTitle => _t({
        'ko': '말문제 전체',
        'en': 'All text questions',
        'zh': '全部文字题',
        'vi': 'Toàn bộ câu lý thuyết',
      });

  String get subcategoryAllVerbalSub => _t({
        'ko': '주제 무관 말문제 랜덤 40문제',
        'en': 'Random 40 from all text questions',
        'zh': '全部文字题中随机 40 题',
        'vi': '40 câu ngẫu nhiên từ toàn bộ câu lý thuyết',
      });

  String subcategoryLabel(String id) {
    switch (id) {
      case SubcategoryIds.alcohol:
        return _t({
          'ko': '음주·약물 운전',
          'en': 'Alcohol & drugs',
          'zh': '酒驾·药驾',
          'vi': 'Rượu bia & ma túy',
        });
      case SubcategoryIds.childZone:
        return _t({
          'ko': '어린이·노인·장애인 보호',
          'en': 'Child & elderly zones',
          'zh': '儿童·老人·残障人保护',
          'vi': 'Khu bảo vệ trẻ em & người già',
        });
      case SubcategoryIds.emergency:
        return _t({
          'ko': '응급처치·사고대응',
          'en': 'First aid & accidents',
          'zh': '应急处理·事故应对',
          'vi': 'Sơ cứu & xử lý tai nạn',
        });
      case SubcategoryIds.license:
        return _t({
          'ko': '면허·행정처분',
          'en': 'License & penalties',
          'zh': '驾照·行政处罚',
          'vi': 'Bằng lái & xử phạt',
        });
      case SubcategoryIds.signSignal:
        return _t({
          'ko': '신호·표지·노면표시',
          'en': 'Signals, signs, road marks',
          'zh': '信号·标志·路面标识',
          'vi': 'Tín hiệu, biển báo, vạch đường',
        });
      case SubcategoryIds.speedLane:
        return _t({
          'ko': '속도·차로·앞지르기',
          'en': 'Speed, lanes, overtaking',
          'zh': '速度·车道·超车',
          'vi': 'Tốc độ, làn, vượt xe',
        });
      case SubcategoryIds.parking:
        return _t({
          'ko': '주차·정차',
          'en': 'Parking & stopping',
          'zh': '停车·驻车',
          'vi': 'Đỗ & dừng xe',
        });
      case SubcategoryIds.highway:
        return _t({
          'ko': '고속도로·긴급차량',
          'en': 'Highways & emergency vehicles',
          'zh': '高速公路·紧急车辆',
          'vi': 'Cao tốc & xe ưu tiên',
        });
      case SubcategoryIds.vehicleEco:
        return _t({
          'ko': '친환경·차량장치',
          'en': 'Eco driving & vehicle parts',
          'zh': '环保·车辆装置',
          'vi': 'Lái xanh & thiết bị xe',
        });
      case SubcategoryIds.general:
      default:
        return _t({
          'ko': '일반 법규',
          'en': 'General rules',
          'zh': '一般法规',
          'vi': 'Quy định chung',
        });
    }
  }

  String subcategorySubtitle(String id, int count) {
    final unit = _t({
      'ko': '$count문제',
      'en': '$count questions',
      'zh': '$count 题',
      'vi': '$count câu',
    });
    final hint = () {
      switch (id) {
        case SubcategoryIds.alcohol:
          return _t({
            'ko': '음주·약물 운전 관련',
            'en': 'About drunk/drug driving',
            'zh': '酒驾·药驾相关',
            'vi': 'Liên quan lái xe khi uống rượu/ma túy',
          });
        case SubcategoryIds.childZone:
          return _t({
            'ko': '어린이·노인·장애인 보호구역',
            'en': 'Protected zones',
            'zh': '保护区相关',
            'vi': 'Khu vực bảo vệ',
          });
        case SubcategoryIds.emergency:
          return _t({
            'ko': '사고 현장 대응, 응급처치',
            'en': 'Accident scene, first aid',
            'zh': '事故现场处置、应急',
            'vi': 'Hiện trường tai nạn, sơ cứu',
          });
        case SubcategoryIds.license:
          return _t({
            'ko': '면허·벌점·과태료·범칙금',
            'en': 'License, points, fines',
            'zh': '驾照·扣分·罚款',
            'vi': 'Bằng, điểm trừ, tiền phạt',
          });
        case SubcategoryIds.signSignal:
          return _t({
            'ko': '신호등, 안전표지, 노면표시',
            'en': 'Signals, traffic signs, road marks',
            'zh': '信号灯、安全标志、路面标识',
            'vi': 'Đèn tín hiệu, biển báo, vạch',
          });
        case SubcategoryIds.speedLane:
          return _t({
            'ko': '제한속도, 차로, 앞지르기',
            'en': 'Speed limits, lane, overtaking',
            'zh': '限速、车道、超车',
            'vi': 'Giới hạn tốc độ, làn, vượt',
          });
        case SubcategoryIds.parking:
          return _t({
            'ko': '주차·정차, 견인',
            'en': 'Parking, stopping, towing',
            'zh': '停车、驻车、拖车',
            'vi': 'Đỗ xe, dừng xe, kéo xe',
          });
        case SubcategoryIds.highway:
          return _t({
            'ko': '고속도로, 긴급자동차',
            'en': 'Highways, emergency vehicles',
            'zh': '高速公路、紧急车辆',
            'vi': 'Đường cao tốc, xe ưu tiên',
          });
        case SubcategoryIds.vehicleEco:
          return _t({
            'ko': '친환경 운전·차량 점검',
            'en': 'Eco driving, vehicle check',
            'zh': '环保驾驶、车辆检查',
            'vi': 'Lái xe xanh, kiểm tra xe',
          });
        case SubcategoryIds.general:
        default:
          return _t({
            'ko': '기타 도로교통법 일반',
            'en': 'Other traffic rules',
            'zh': '其他交通法规',
            'vi': 'Luật giao thông khác',
          });
      }
    }();
    return '$hint · $unit';
  }

  String quizTitleSubcategory(String id) {
    return subcategoryLabel(id);
  }

  // ——— 학습 카드 ———
  String get studyActionLabel => _t({
        'ko': '공부하기',
        'en': 'Study',
        'zh': '学习',
        'vi': 'Học',
      });

  String get studyScreenSectionKeyPoints => _t({
        'ko': '핵심 포인트',
        'en': 'Key points',
        'zh': '核心要点',
        'vi': 'Điểm chính',
      });

  String get studyScreenSectionNumbers => _t({
        'ko': '핵심 수치',
        'en': 'Key numbers',
        'zh': '核心数值',
        'vi': 'Số liệu chính',
      });

  String get studyScreenSectionExamples => _t({
        'ko': '대표 기출',
        'en': 'Representative questions',
        'zh': '代表题目',
        'vi': 'Câu hỏi tiêu biểu',
      });

  String get studyScreenQuizRelated => _t({
        'ko': '관련 문제 풀기',
        'en': 'Practice these questions',
        'zh': '练习相关题目',
        'vi': 'Luyện câu liên quan',
      });

  // ——— 나의 통계 ———
  String get statsTitle => _t({
        'ko': '나의 통계',
        'en': 'My statistics',
        'zh': '我的统计',
        'vi': 'Thống kê của tôi',
      });

  String get statsMenuSubtitle => _t({
        'ko': '정답률, 모의고사 추이, 자주 틀리는 문제',
        'en': 'Accuracy, exam trend, challenging questions',
        'zh': '正确率、模拟考趋势、易错题',
        'vi': 'Tỷ lệ đúng, xu hướng thi thử, câu hay sai',
      });

  String get statsSectionOverall => _t({
        'ko': '전체 현황',
        'en': 'Overview',
        'zh': '总体情况',
        'vi': 'Tổng quan',
      });

  String get statsLabelAttempted => _t({
        'ko': '풀어본 문제',
        'en': 'Attempted',
        'zh': '已做题',
        'vi': 'Đã làm',
      });

  String get statsLabelAccuracy => _t({
        'ko': '전체 정답률',
        'en': 'Accuracy',
        'zh': '总正确率',
        'vi': 'Tỷ lệ đúng',
      });

  String get statsLabelWrongNow => _t({
        'ko': '현재 오답',
        'en': 'Wrong now',
        'zh': '当前错题',
        'vi': 'Câu sai hiện tại',
      });

  String statsQuestionsUnit(int n) {
    switch (locale.languageCode) {
      case 'en':
        return '$n questions';
      case 'zh':
        return '$n 题';
      case 'vi':
        return '$n câu';
      case 'ko':
      default:
        return '$n문제';
    }
  }

  String get statsMockExamTrend => _t({
        'ko': '모의고사 점수 추이',
        'en': 'Exam score trend',
        'zh': '模拟考分数趋势',
        'vi': 'Xu hướng điểm thi thử',
      });

  String get statsMockExamChartEmpty => _t({
        'ko': '모의고사 기록이 없습니다.\n모의고사를 완료하면 여기에 추이가 표시됩니다.',
        'en': 'No exam records yet.\nFinish an exam to see the trend here.',
        'zh': '暂无模拟考试记录。\n完成一次模拟考试后，将在此显示趋势。',
        'vi': 'Chưa có lịch sử thi thử.\nHoàn thành một bài thi thử để xem xu hướng tại đây.',
      });

  String get statsChartOldestFirst => _t({
        'ko': '오래된 순',
        'en': 'Oldest →',
        'zh': '从旧到新',
        'vi': 'Cũ → mới',
      });

  String statsChartRecentAttempts(int n) {
    return _t({
      'ko': '최근 {n}회',
      'en': 'Last {n} attempts',
      'zh': '最近 {n} 次',
      'vi': '{n} lần gần nhất',
    }).replaceAll('{n}', '$n');
  }

  String statsHardestTopN(int n) {
    return _t({
      'ko': '자주 틀리는 문제 Top {n}',
      'en': 'Top {n} challenging questions',
      'zh': '易错题 Top {n}',
      'vi': 'Top {n} câu hay sai',
    }).replaceAll('{n}', '$n');
  }

  String statsQuestionIdLine(int id) {
    return _t({
      'ko': '문제 ID: {id}',
      'en': 'Question ID: {id}',
      'zh': '题目 ID：{id}',
      'vi': 'ID câu: {id}',
    }).replaceAll('{id}', '$id');
  }

  String statsAttemptsWrongLine(int attempts, int wrong) {
    return _t({
      'ko': '{a}번 시도 · {w}번 틀림',
      'en': '{a} tries · {w} wrong',
      'zh': '尝试 {a} 次 · 错 {w} 次',
      'vi': '{a} lần làm · sai {w} lần',
    })
        .replaceAll('{a}', '$attempts')
        .replaceAll('{w}', '$wrong');
  }

  String statsWrongRatePercent(String rate) {
    return _t({
      'ko': '오답률 {r}%',
      'en': 'Wrong {r}%',
      'zh': '错误率 {r}%',
      'vi': 'Sai {r}%',
    }).replaceAll('{r}', rate);
  }

  // ——— 개인정보 수집 동의 (Google Sign-In 게이트) ———

  String get consentTitle => _t({
        'ko': '개인정보 수집 동의',
        'en': 'Privacy Consent',
        'zh': '个人信息收集同意',
        'vi': 'Đồng ý thu thập thông tin',
      });

  String get consentPurpose => _t({
        'ko': '수집 목적: 앱 사용자 통계',
        'en': 'Purpose: App usage statistics',
        'zh': '收集目的:应用使用统计',
        'vi': 'Mục đích: Thống kê người dùng',
      });

  String get consentItems => _t({
        'ko': '수집 항목: 이름(직접 입력), 이메일(Google 계정), Google 식별자(sub), 접속 일시, 플랫폼',
        'en': 'Items: name (entered), email (Google), Google ID (sub), access time, platform',
        'zh': '收集项目:姓名(自行输入)、邮箱(Google)、Google 标识(sub)、访问时间、平台',
        'vi': 'Mục: tên (nhập tay), email (Google), Google ID (sub), thời gian truy cập, nền tảng',
      });

  String get consentRetention => _t({
        'ko': '보유 기간: 앱 삭제 또는 본인 요청 시까지',
        'en': 'Retention: until app deletion or your request',
        'zh': '保留期限:卸载应用或本人请求时止',
        'vi': 'Lưu trữ: đến khi gỡ ứng dụng hoặc theo yêu cầu',
      });

  String get consentRightToRefuse => _t({
        'ko': '동의를 거부할 수 있으며, 거부 시 앱을 사용할 수 없습니다.',
        'en': 'You may refuse; refusing means the app cannot be used.',
        'zh': '您有权拒绝同意,拒绝后无法使用本应用。',
        'vi': 'Bạn có thể từ chối; nếu từ chối, ứng dụng không khả dụng.',
      });

  String get consentGoogleSignInButton => _t({
        'ko': 'Google 계정으로 로그인',
        'en': 'Sign in with Google',
        'zh': '使用 Google 账号登录',
        'vi': 'Đăng nhập bằng Google',
      });

  String get consentGoogleSignInRequired => _t({
        'ko': '먼저 Google 계정으로 로그인해 주세요.',
        'en': 'Please sign in with Google first.',
        'zh': '请先使用 Google 账号登录。',
        'vi': 'Vui lòng đăng nhập Google trước.',
      });

  String consentSignedInAs(String email) => _t({
        'ko': '로그인됨: {e}',
        'en': 'Signed in as {e}',
        'zh': '已登录:{e}',
        'vi': 'Đã đăng nhập: {e}',
      }).replaceAll('{e}', email);

  String get consentNameLabel => _t({
        'ko': '이름',
        'en': 'Name',
        'zh': '姓名',
        'vi': 'Tên',
      });

  String get consentNameHint => _t({
        'ko': '시트에 기록될 이름을 입력하세요',
        'en': 'Enter the name to record',
        'zh': '请输入要记录的姓名',
        'vi': 'Nhập tên sẽ được ghi lại',
      });

  String get consentNameRequired => _t({
        'ko': '이름을 입력해 주세요.',
        'en': 'Please enter your name.',
        'zh': '请输入姓名。',
        'vi': 'Vui lòng nhập tên.',
      });

  String get consentNameTooLong => _t({
        'ko': '이름은 30자 이내로 입력해 주세요.',
        'en': 'Name must be 30 characters or less.',
        'zh': '姓名不超过 30 个字符。',
        'vi': 'Tên không quá 30 ký tự.',
      });

  String get consentAgreeCheckbox => _t({
        'ko': '위 사항에 모두 동의합니다.',
        'en': 'I agree to all of the above.',
        'zh': '我同意以上所有事项。',
        'vi': 'Tôi đồng ý với toàn bộ nội dung trên.',
      });

  String get consentAgreeButton => _t({
        'ko': '동의하고 시작',
        'en': 'Agree and start',
        'zh': '同意并开始',
        'vi': 'Đồng ý và bắt đầu',
      });

  String get consentDeclineButton => _t({
        'ko': '동의하지 않음',
        'en': 'Decline',
        'zh': '不同意',
        'vi': 'Không đồng ý',
      });

  String get consentExitDialogTitle => _t({
        'ko': '동의가 필요합니다',
        'en': 'Consent required',
        'zh': '需要同意',
        'vi': 'Cần sự đồng ý',
      });

  String get consentExitDialogBody => _t({
        'ko': '동의하지 않으시면 앱을 사용할 수 없어 종료됩니다.',
        'en': 'Without consent the app cannot be used and will close.',
        'zh': '未同意将无法使用本应用,即将退出。',
        'vi': 'Không đồng ý thì không thể dùng ứng dụng và sẽ đóng.',
      });

  String get consentExitConfirm => _t({
        'ko': '종료',
        'en': 'Exit',
        'zh': '退出',
        'vi': 'Thoát',
      });

  String get consentExitCancel => _t({
        'ko': '돌아가기',
        'en': 'Back',
        'zh': '返回',
        'vi': 'Quay lại',
      });

  String get consentSilentSignInFailed => _t({
        'ko': '자동 로그인이 만료되어 다시 동의가 필요합니다.',
        'en': 'Sign-in expired. Please consent again.',
        'zh': '自动登录已过期,请重新同意。',
        'vi': 'Phiên đăng nhập đã hết hạn. Vui lòng đồng ý lại.',
      });

  String get consentSignInFailed => _t({
        'ko': 'Google 로그인에 실패했습니다. 다시 시도해 주세요.',
        'en': 'Google sign-in failed. Please try again.',
        'zh': 'Google 登录失败,请重试。',
        'vi': 'Đăng nhập Google thất bại. Vui lòng thử lại.',
      });
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ko', 'en', 'zh', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
