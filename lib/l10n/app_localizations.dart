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

  String get homeMenuExamOrderSub => _t({
        'ko': '응시 절차를 한 번에 정리',
        'en': 'Steps to take the exam',
        'zh': '考试流程一览',
        'vi': 'Quy trình dự thi',
      });

  String get homeMenuPrepSub => _t({
        'ko': '시험 당일 챙길 준비물',
        'en': 'What to bring on test day',
        'zh': '考试当天必带物品',
        'vi': 'Đồ cần mang ngày thi',
      });

  String get homeMenuEduScheduleSub => _t({
        'ko': '도로교통공단 외부 페이지',
        'en': 'Opens external KoROAD page',
        'zh': '跳转至韩国道路交通公团',
        'vi': 'Mở trang KoROAD',
      });

  String get homeMenuTestScheduleSub => _t({
        'ko': '도로교통공단 외부 페이지',
        'en': 'Opens external KoROAD page',
        'zh': '跳转至韩国道路交通公团',
        'vi': 'Mở trang KoROAD',
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

  // 수집·이용 / 제3자 제공 표 (현재 ko 만 작성, 다른 언어는 ko 폴백).

  String get consentCollectionTitle => _t({
        'ko': '개인정보 수집·이용 안내',
      });

  List<({String label, String value})> get consentCollectionRows => [
        (
          label: _t({'ko': '수집 항목'}),
          value: _t({
            'ko': '이름(사용자 입력), 동의 일자, 플랫폼',
          }),
        ),
        (
          label: _t({'ko': '수집 목적'}),
          value: _t({
            'ko': '앱 이용자 실적 집계',
          }),
        ),
        (
          label: _t({'ko': '수집·이용 근거'}),
          value: _t({'ko': '정보주체의 동의'}),
        ),
        (
          label: _t({'ko': '보유기간'}),
          value: _t({'ko': '앱 삭제 또는 동의 철회 시까지'}),
        ),
      ];

  String get consentThirdPartyTitle => _t({
        'ko': '개인정보 제3자 제공 내역',
      });

  List<({String label, String value})> get consentThirdPartyRows => [
        (
          label: _t({'ko': '제공받는 기관'}),
          value: _t({'ko': 'Google LLC (Google Forms / Google Sheets 호스팅)'}),
        ),
        (
          label: _t({'ko': '제공 목적'}),
          value: _t({'ko': '동의 기록 보관'}),
        ),
        (
          label: _t({'ko': '제공 항목'}),
          value: _t({'ko': '이름, 동의 일자, 플랫폼'}),
        ),
        (
          label: _t({'ko': '제공 근거'}),
          value: _t({'ko': '정보주체의 동의'}),
        ),
        (
          label: _t({'ko': '보유·이용기간'}),
          value: _t({'ko': '앱 운영자가 시트에서 삭제하기 전까지'}),
        ),
      ];

  String get consentRightToRefuse => _t({
        'ko':
            '동의를 거부할 권리가 있으며, 거부 시 앱을 사용할 수 없습니다.',
        'en': 'You may refuse; refusing means the app cannot be used.',
        'zh': '您有权拒绝同意,拒绝后无法使用本应用。',
        'vi': 'Bạn có thể từ chối; nếu từ chối, ứng dụng không khả dụng.',
      });

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

  String get consentCollectionAgreeCheckbox => _t({
        'ko': '[필수] 개인정보 수집·이용에 동의합니다.',
      });

  String get consentThirdPartyAgreeCheckbox => _t({
        'ko': '[필수] 개인정보 제3자 제공(한국도로교통공단)에 동의합니다.',
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

  String get menuRevokeConsent => _t({
        'ko': '개인정보 동의 철회',
        'en': 'Revoke privacy consent',
        'zh': '撤回个人信息同意',
        'vi': 'Rút lại đồng ý quyền riêng tư',
      });

  String get revokeConsentDialogTitle => _t({
        'ko': '동의를 철회하시겠습니까?',
        'en': 'Revoke consent?',
        'zh': '撤回同意?',
        'vi': 'Rút lại đồng ý?',
      });

  String get revokeConsentDialogBody => _t({
        'ko': '저장된 동의 기록이 삭제됩니다. 다시 사용하려면 동의 절차를 다시 거쳐야 합니다.',
        'en':
            'Saved consent will be removed. You will need to consent again to use the app.',
        'zh': '将删除已保存的同意记录,再次使用前需要重新同意。',
        'vi': 'Sẽ xoá đồng ý đã lưu. Bạn sẽ phải đồng ý lại để dùng tiếp.',
      });

  String get revokeConsentConfirm => _t({
        'ko': '철회',
        'en': 'Revoke',
        'zh': '撤回',
        'vi': 'Rút lại',
      });

  String get revokeConsentCancel => _t({
        'ko': '취소',
        'en': 'Cancel',
        'zh': '取消',
        'vi': 'Huỷ',
      });

  // ——— 친환경 운전 교육 인트로 (동의 직후 1회 노출) ———

  String get ecoIntroBtnPrev => _t({
        'ko': '이전',
        'en': 'Previous',
        'zh': '上一页',
        'vi': 'Trước',
      });

  String get ecoIntroBtnNext => _t({
        'ko': '다음',
        'en': 'Next',
        'zh': '下一页',
        'vi': 'Tiếp',
      });

  String get ecoIntroBtnStart => _t({
        'ko': '시작하기',
        'en': 'Get started',
        'zh': '开始',
        'vi': 'Bắt đầu',
      });

  // 슬라이드 1 — DEFINITION
  String get ecoIntroS1Badge => '01 · DEFINITION';

  String get ecoIntroS1TopLabel => _t({
        'ko': '친환경 운전',
        'en': 'Eco-driving',
        'zh': '环保驾驶',
        'vi': 'Lái xe xanh',
      });

  String get ecoIntroS1Title => _t({
        'ko': '친환경 운전이란?',
        'en': 'What is eco-driving?',
        'zh': '什么是环保驾驶？',
        'vi': 'Lái xe xanh là gì?',
      });

  String get ecoIntroS1Subtitle => _t({
        'ko': 'Eco-Driving · 친환경 경제 운전',
        'en': 'Eco-Driving · economical & green',
        'zh': 'Eco-Driving · 环保经济驾驶',
        'vi': 'Eco-Driving · Lái xe xanh & tiết kiệm',
      });

  String get ecoIntroS1Body => _t({
        'ko': '연료 소비와 온실가스 배출을 줄이기 위해 부드럽고 효율적으로 운전하는 습관으로, 환경과 경제를 동시에 살리는 운전법입니다.',
        'en':
            'A driving habit that smoothly and efficiently reduces fuel use and greenhouse gas emissions — saving both the environment and your wallet.',
        'zh': '通过平稳高效的驾驶习惯，减少燃料消耗与温室气体排放，让环境与经济同时受益。',
        'vi':
            'Thói quen lái xe êm và hiệu quả nhằm giảm tiêu thụ nhiên liệu và khí nhà kính, vừa bảo vệ môi trường vừa tiết kiệm chi phí.',
      });

  String get ecoIntroS1PrincipleSectionTitle => _t({
        'ko': '3대 핵심 원칙',
        'en': '3 Core Principles',
        'zh': '三大核心原则',
        'vi': '3 Nguyên tắc cốt lõi',
      });

  String get ecoIntroS1Principle1Label => _t({
        'ko': '친환경',
        'en': 'Eco',
        'zh': '环保',
        'vi': 'Xanh',
      });

  String get ecoIntroS1Principle1Body => _t({
        'ko': '온실가스·오염물질 배출 감소',
        'en': 'Reduces greenhouse gases and pollutants',
        'zh': '减少温室气体与污染物排放',
        'vi': 'Giảm khí nhà kính và chất ô nhiễm',
      });

  String get ecoIntroS1Principle2Label => _t({
        'ko': '경제성',
        'en': 'Economy',
        'zh': '经济',
        'vi': 'Tiết kiệm',
      });

  String get ecoIntroS1Principle2Body => _t({
        'ko': '연료비 절감, 차량 수명 연장',
        'en': 'Lower fuel cost, longer vehicle life',
        'zh': '节省燃油费，延长车辆寿命',
        'vi': 'Giảm chi phí nhiên liệu, kéo dài tuổi thọ xe',
      });

  String get ecoIntroS1Principle3Label => _t({
        'ko': '안전성',
        'en': 'Safety',
        'zh': '安全',
        'vi': 'An toàn',
      });

  String get ecoIntroS1Principle3Body => _t({
        'ko': '급조작 자제로 사고 위험 감소',
        'en': 'Fewer abrupt actions, lower accident risk',
        'zh': '避免急操作，降低事故风险',
        'vi': 'Tránh thao tác đột ngột, giảm rủi ro tai nạn',
      });

  String get ecoIntroS1WhyTitle => _t({
        'ko': '왜 필요할까요?',
        'en': 'Why does it matter?',
        'zh': '为什么重要？',
        'vi': 'Vì sao quan trọng?',
      });

  String get ecoIntroS1WhyBody => _t({
        'ko': '승용차 1대 연간 CO₂ 배출량 약 2톤. 운전 습관만 바꿔도 최대 30%까지 감축 가능합니다.',
        'en':
            'One passenger car emits ~2 tons of CO₂ per year. Changing habits alone can cut up to 30%.',
        'zh': '一辆乘用车年均排放约 2 吨 CO₂。仅改变驾驶习惯就可减排最高 30%。',
        'vi':
            'Một xe con thải ~2 tấn CO₂ mỗi năm. Chỉ thay đổi thói quen lái xe có thể giảm tới 30%.',
      });

  String get ecoIntroS1Tag1 => _t({
        'ko': '# 경제운전',
        'en': '# Economy',
        'zh': '# 经济驾驶',
        'vi': '# Tiết kiệm',
      });

  String get ecoIntroS1Tag2 => _t({
        'ko': '# 탄소절감',
        'en': '# CarbonCut',
        'zh': '# 减碳',
        'vi': '# GiảmCarbon',
      });

  String get ecoIntroS1Tag3 => _t({
        'ko': '# 안전운행',
        'en': '# SafeDrive',
        'zh': '# 安全驾驶',
        'vi': '# LáiAnToàn',
      });

  String get ecoIntroS1Tag4 => _t({
        'ko': '# 연비향상',
        'en': '# MPGUp',
        'zh': '# 节油',
        'vi': '# TiếtKiệmXăng',
      });

  // 슬라이드 2 — EFFECT
  String get ecoIntroS2Badge => '02 · EFFECT';

  String get ecoIntroS2TopLabel => _t({
        'ko': '실제 효과',
        'en': 'Real impact',
        'zh': '实际效果',
        'vi': 'Hiệu quả thực tế',
      });

  String get ecoIntroS2Title => _t({
        'ko': '숫자로 보는 변화',
        'en': 'Change in numbers',
        'zh': '用数字看变化',
        'vi': 'Thay đổi qua những con số',
      });

  String get ecoIntroS2Source => _t({
        'ko': '출처 : 환경부 친환경운전요령',
        'en': 'Source: ME Eco-Driving Guide',
        'zh': '来源：韩国环境部 环保驾驶要领',
        'vi': 'Nguồn: Hướng dẫn lái xe xanh, Bộ Môi trường HQ',
      });

  String get ecoIntroS2CoreLabel => 'CORE IMPACT';

  String get ecoIntroS2CoreValue => _t({
        'ko': '최대 30%',
        'en': 'Up to 30%',
        'zh': '最高 30%',
        'vi': 'Tối đa 30%',
      });

  String get ecoIntroS2CoreUnit => _t({
        'ko': '연료 절감',
        'en': 'fuel saved',
        'zh': '节省燃油',
        'vi': 'tiết kiệm xăng',
      });

  String get ecoIntroS2CoreBody => _t({
        'ko': '급가·감속만 피해도 연비 30~40% 개선, 오염물질 40% 감소',
        'en':
            'Avoiding hard accel/decel alone boosts MPG by 30–40% and cuts pollutants 40%.',
        'zh': '仅避免急加减速即可提升油耗 30~40%，污染物减少 40%。',
        'vi':
            'Chỉ cần tránh tăng/giảm tốc đột ngột giúp tiết kiệm 30–40% nhiên liệu và giảm 40% chất ô nhiễm.',
      });

  String get ecoIntroS2Kpi1Label => _t({
        'ko': '연료비 절감',
        'en': 'Fuel savings',
        'zh': '节省油费',
        'vi': 'Tiết kiệm xăng',
      });

  String get ecoIntroS2Kpi1Value => _t({
        'ko': '연 386L · 약 50만원',
        'en': '386 L/yr · ~500K KRW',
        'zh': '年省 386 L · 约 50 万韩元',
        'vi': '386 L/năm · ~500K KRW',
      });

  String get ecoIntroS2Kpi2Label => _t({
        'ko': 'CO₂ 배출 감소',
        'en': 'CO₂ reduction',
        'zh': 'CO₂ 减排',
        'vi': 'Giảm CO₂',
      });

  String get ecoIntroS2Kpi2Value => _t({
        'ko': '연 348kg 감축',
        'en': '348 kg/yr cut',
        'zh': '年减 348 kg',
        'vi': 'Giảm 348 kg/năm',
      });

  String get ecoIntroS2Kpi3Label => _t({
        'ko': '오염물질 감축',
        'en': 'Pollutant cut',
        'zh': '污染物减少',
        'vi': 'Giảm ô nhiễm',
      });

  String get ecoIntroS2Kpi3Value => _t({
        'ko': '질소산화물 50% 감소',
        'en': 'NOx down 50%',
        'zh': '氮氧化物 减少 50%',
        'vi': 'NOx giảm 50%',
      });

  String get ecoIntroS2Kpi4Label => _t({
        'ko': '교통사고 위험',
        'en': 'Accident risk',
        'zh': '交通事故风险',
        'vi': 'Rủi ro tai nạn',
      });

  String get ecoIntroS2Kpi4Value => _t({
        'ko': '급조작 감소 · 안전 향상',
        'en': 'Fewer abrupt acts · safer',
        'zh': '减少急操作 · 更安全',
        'vi': 'Ít thao tác đột ngột · an toàn hơn',
      });

  String get ecoIntroS2Kpi5Label => _t({
        'ko': '차량 수명·정비',
        'en': 'Life & service',
        'zh': '寿命与保养',
        'vi': 'Tuổi thọ & bảo dưỡng',
      });

  String get ecoIntroS2Kpi5Value => _t({
        'ko': '엔진·타이어 부담 감소',
        'en': 'Less stress on engine & tires',
        'zh': '减轻发动机与轮胎负担',
        'vi': 'Giảm tải động cơ & lốp',
      });

  String get ecoIntroS2TreeTitle => _t({
        'ko': '나무로 환산하면',
        'en': 'Translated to trees',
        'zh': '换算成树木',
        'vi': 'Quy đổi sang cây xanh',
      });

  String get ecoIntroS2TreeBody => _t({
        'ko': '연 348kg CO₂ 감축 = 소나무 53그루가 1년간 흡수하는 양',
        'en': 'Cutting 348 kg CO₂/yr ≈ what 53 pine trees absorb in a year',
        'zh': '年减 348 kg CO₂ ≈ 53 棵松树一年吸收量',
        'vi': 'Giảm 348 kg CO₂/năm ≈ lượng 53 cây thông hấp thụ trong một năm',
      });

  // 슬라이드 3 — ACTION
  String get ecoIntroS3Badge => '03 · ACTION';

  String get ecoIntroS3TopLabel => _t({
        'ko': '실천 10계명',
        'en': '10 Practices',
        'zh': '实践十法',
        'vi': '10 quy tắc',
      });

  String get ecoIntroS3Title => _t({
        'ko': '오늘부터 실천하기',
        'en': 'Start today',
        'zh': '从今天开始实践',
        'vi': 'Bắt đầu từ hôm nay',
      });

  String get ecoIntroS3Subtitle => _t({
        'ko': '환경부·서울시 친환경 운전 10계명',
        'en': '10 Eco-Driving Tips (ME · Seoul)',
        'zh': '环境部·首尔市 环保驾驶十法',
        'vi': '10 nguyên tắc lái xe xanh (Bộ MT · Seoul)',
      });

  String get ecoIntroS3Group1Title => _t({
        'ko': '▸ 운전 습관',
        'en': '▸ Driving habits',
        'zh': '▸ 驾驶习惯',
        'vi': '▸ Thói quen lái xe',
      });

  String get ecoIntroS3Group2Title => _t({
        'ko': '▸ 차량 관리',
        'en': '▸ Vehicle care',
        'zh': '▸ 车辆保养',
        'vi': '▸ Bảo dưỡng xe',
      });

  String get ecoIntroS3Group3Title => _t({
        'ko': '▸ 주행 계획',
        'en': '▸ Trip planning',
        'zh': '▸ 行程规划',
        'vi': '▸ Lập kế hoạch',
      });

  String get ecoIntroS3Item1Label => _t({
        'ko': '부드러운 출발',
        'en': 'Smooth start',
        'zh': '缓慢起步',
        'vi': 'Khởi hành êm',
      });

  String get ecoIntroS3Item1Body => _t({
        'ko': '5초간 시속 20km까지 천천히',
        'en': '5 sec to reach 20 km/h',
        'zh': '5 秒达到 20 km/h',
        'vi': '5 giây đạt 20 km/h',
      });

  String get ecoIntroS3Item2Label => _t({
        'ko': '경제속도 유지',
        'en': 'Economical speed',
        'zh': '保持经济车速',
        'vi': 'Giữ tốc độ kinh tế',
      });

  String get ecoIntroS3Item2Body => _t({
        'ko': '시속 60~80km 정속 주행',
        'en': 'Steady 60–80 km/h',
        'zh': '60~80 km/h 匀速',
        'vi': '60–80 km/h ổn định',
      });

  String get ecoIntroS3Item3Label => _t({
        'ko': '예측 운전',
        'en': 'Anticipatory driving',
        'zh': '预测驾驶',
        'vi': 'Lái xe dự đoán',
      });

  String get ecoIntroS3Item3Body => _t({
        'ko': '차간거리 확보, 미리 감속',
        'en': 'Keep distance, slow early',
        'zh': '保持车距，提前减速',
        'vi': 'Giữ khoảng cách, giảm tốc sớm',
      });

  String get ecoIntroS3Item4Label => _t({
        'ko': '내리막길 가속 금지',
        'en': 'No downhill accel',
        'zh': '下坡勿加速',
        'vi': 'Không tăng tốc xuống dốc',
      });

  String get ecoIntroS3Item4Body => _t({
        'ko': '관성 활용, 페달에서 발 떼기',
        'en': 'Use inertia, lift the pedal',
        'zh': '利用惯性，松开油门',
        'vi': 'Tận dụng quán tính, nhả chân ga',
      });

  String get ecoIntroS3Item5Label => _t({
        'ko': '공회전 자제',
        'en': 'Avoid idling',
        'zh': '减少怠速',
        'vi': 'Hạn chế nổ máy chờ',
      });

  String get ecoIntroS3Item5Body => _t({
        'ko': '3분 이상 정차 시 시동 끄기',
        'en': 'Turn off if idling >3 min',
        'zh': '停车超过 3 分钟熄火',
        'vi': 'Tắt máy khi đỗ trên 3 phút',
      });

  String get ecoIntroS3Item6Label => _t({
        'ko': '타이어 공기압 점검',
        'en': 'Tire pressure check',
        'zh': '检查胎压',
        'vi': 'Kiểm tra áp suất lốp',
      });

  String get ecoIntroS3Item6Body => _t({
        'ko': '월 1회, 권장 30~34 psi',
        'en': 'Monthly · 30–34 psi',
        'zh': '每月一次，建议 30~34 psi',
        'vi': '1 lần/tháng · 30–34 psi',
      });

  String get ecoIntroS3Item7Label => _t({
        'ko': '불필요한 짐 빼기',
        'en': 'Drop excess load',
        'zh': '卸下多余物品',
        'vi': 'Bỏ hành lý dư',
      });

  String get ecoIntroS3Item7Body => _t({
        'ko': '10kg 감소 = 연비 1% 향상',
        'en': '-10 kg = +1% MPG',
        'zh': '减 10 kg = 油耗提升 1%',
        'vi': '-10 kg = +1% tiết kiệm',
      });

  String get ecoIntroS3Item8Label => _t({
        'ko': '정품 연료 사용',
        'en': 'Use genuine fuel',
        'zh': '使用正规燃油',
        'vi': 'Dùng nhiên liệu chính hãng',
      });

  String get ecoIntroS3Item8Body => _t({
        'ko': '유사연료 시 연비 7.4% 감소',
        'en': 'Fake fuel cuts MPG 7.4%',
        'zh': '假冒燃油 燃耗下降 7.4%',
        'vi': 'Nhiên liệu giả giảm 7.4% tiết kiệm',
      });

  String get ecoIntroS3Item9Label => _t({
        'ko': '경로 미리 확인',
        'en': 'Plan the route',
        'zh': '提前规划路线',
        'vi': 'Lập sẵn lộ trình',
      });

  String get ecoIntroS3Item9Body => _t({
        'ko': '내비 활용, 정체 구간 회피',
        'en': 'Use navi, avoid jams',
        'zh': '使用导航避开拥堵',
        'vi': 'Dùng navi, tránh kẹt xe',
      });

  String get ecoIntroS3Item10Label => _t({
        'ko': '에어컨 적정 사용',
        'en': 'Use A/C wisely',
        'zh': '合理使用空调',
        'vi': 'Dùng điều hoà hợp lý',
      });

  String get ecoIntroS3Item10Body => _t({
        'ko': '고속주행 시 창문 닫기',
        'en': 'Close windows on highway',
        'zh': '高速行驶时关窗',
        'vi': 'Đóng cửa khi chạy cao tốc',
      });

  String get ecoIntroS3SloganTitle => _t({
        'ko': '작은 습관, 큰 변화',
        'en': 'Small habit, big change',
        'zh': '小习惯，大改变',
        'vi': 'Thói quen nhỏ, thay đổi lớn',
      });

  String get ecoIntroS3SloganBody => _t({
        'ko': '오늘부터 한 가지씩 시작하세요',
        'en': 'Start with one thing today',
        'zh': '从今天开始，一项一项实践',
        'vi': 'Bắt đầu mỗi ngày một điều',
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
