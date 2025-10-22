# CLAUDE_ko.md

이 파일은 이 저장소에서 작업할 때 Claude Code(claude.ai/code)에게 가이드를 제공합니다.

## 프로젝트 개요

Wake Coffee는 일반 직장인과 교대근무자를 위해 설계된 iOS 알람 앱입니다. 일반근무(9 to 6 스케줄)와 교대근무(2/3/4교대 패턴) 두 가지 모드로 직관적인 알람 관리를 제공합니다.

## 빌드 & 실행

```bash
# 프로젝트 빌드
xcodebuild -scheme wakecoffee -destination 'platform=iOS Simulator,name=iPhone 16' build

# 테스트 실행
xcodebuild -scheme wakecoffee -destination 'platform=iOS Simulator,name=iPhone 16' test

# 클린 빌드
xcodebuild -scheme wakecoffee clean
```

또는 Xcode에서 `wakecoffee.xcodeproj`를 열고 Cmd+R로 실행하면 됩니다.

## 아키텍처

이 프로젝트는 **MVVM (Model-View-ViewModel)** 아키텍처를 따릅니다:

### 데이터 흐름
1. **Views**는 `@StateObject`와 `@Published` 속성을 사용하여 **ViewModels**를 관찰
2. **ViewModels**는 비즈니스 로직을 관리하고 **Services**와 **Models** 간 조정
3. **Services** (NotificationManager, DataManager)는 시스템 상호작용과 영속성 처리
4. **Models**는 데이터 구조 정의 (Alarm, WorkSchedule, AlarmStatistics)

### 주요 아키텍처 패턴

**두 가지 근무 모드**:
- `RegularWorkViewModel`은 출근 전/중/후 구간이 있는 9 to 6 스타일 스케줄 관리
- `ShiftWorkViewModel`은 자동 스케줄 계산이 있는 2/3/4교대 패턴 관리

**알림 스케줄링**:
- 일반 알람: 요일별로 `UNCalendarNotificationTrigger`를 사용하여 반복 트리거로 스케줄
- 교대 알람: 계산된 근무일을 기반으로 다음 30일간 반복되지 않는 트리거로 생성

**데이터 영속성**:
- `DataManager.shared`는 JSON 인코딩과 함께 UserDefaults 사용
- 일반 알람, 교대 알람, 스케줄, 통계를 별도로 저장
- ViewModel 상태 변경 시마다 자동 저장

### 중요한 구현 세부사항

**교대 패턴 계산** (`ShiftWorkSchedule.getShiftTime(for:)`):
- `daysSinceStart % cycleDays`를 사용하여 특정 날짜의 근무 타입 결정
- 2교대: 2일 주간 근무 → 2일 휴무
- 3교대: 2일 주간 → 2일 야간 → 2일 휴무
- 4교대: 2일 주간 → 2일 야간 → 2일 저녁 → 2일 휴무

**알람 목적 시스템**:
- `AlarmPurpose` enum은 6가지 알람 타입 정의 (물, 스트레칭, 영양제, 커피, 눈 운동, 산책)
- 각 목적은 UI 전체에서 사용되는 이모지 아이콘 보유
- 목적은 알람 알림 콘텐츠와 통계 그룹핑 결정

**근무 구간 색상 코딩**:
- 출근 전: 파란색 (`.blue.opacity(0.6)`)
- 근무 중: 초록색 (`.green.opacity(0.6)`)
- 퇴근 후: 주황색 (`.orange.opacity(0.6)`)
- 타임라인, 구분선, 카드에 일관되게 적용

## 프로젝트 구조

```
wakecoffee/
├── Models/              # 데이터 구조 (Codable, Equatable)
├── ViewModels/          # 비즈니스 로직 (@MainActor, ObservableObject)
├── Views/               # 기능별로 구성된 SwiftUI 뷰
│   ├── RegularWork/     # 타임라인 기반 알람 관리
│   ├── ShiftWork/       # 패턴 기반 알람 관리
│   ├── Settings/        # 앱 설정
│   └── Statistics/      # 차트와 준수율 추적
├── Components/          # 재사용 가능한 UI 컴포넌트
└── Services/            # 시스템 상호작용 (싱글톤 패턴)
```

## 새로운 기능 추가하기

**새로운 알람 목적**:
1. `Models/Alarm.swift`의 `AlarmPurpose` enum에 case 추가
2. `icon` computed property에 이모지 아이콘 제공
3. 목적이 모든 알람 생성 시트에 자동으로 표시됨

**새로운 교대 패턴**:
1. `Models/WorkSchedule.swift`의 `ShiftType` enum에 case 추가
2. 패턴의 `cycleDays` 정의
3. `ShiftWorkSchedule.getShiftTime(for:)`에 패턴 로직 구현

**새로운 통계**:
1. `StatisticsViewModel`에 계산 메서드 추가
2. `Views/Statistics/`에 뷰 컴포넌트 생성
3. `StatisticsView` 메인 스크롤 뷰에 추가

## 테스팅

현재 테스트는 기본 구조만 있고 구현되지 않았습니다. 테스트 추가 시:
- 단위 테스트는 `wakecoffeeTests` 타겟 사용
- UI 테스트는 `wakecoffeeUITests` 타겟 사용
- ViewModel 테스트를 위해 `NotificationManager`와 `DataManager` Mock 사용

## 일반적인 문제

**알림 권한**: 앱은 `AppDelegate`를 통해 첫 실행 시 권한을 요청합니다. 알림이 작동하지 않으면 iOS 설정 → wakecoffee → 알림을 확인하세요.

**날짜 처리**: 모든 알람 시간은 시/분 컴포넌트만 추출된 `Date`를 사용합니다. 시간대 변환에 주의하세요.

**ViewModel 업데이트**: ViewModel published 속성 변경은 자동으로 뷰 업데이트와 데이터 영속성을 트리거합니다. ViewModel을 우회하지 않는 한 저장 메서드를 수동으로 호출하지 마세요.

## 디자인 철학

- **단순성**: UI는 최소한의 설정으로 직관적이어야 함
- **시각적 계층**: 색상, 간격, 아이콘을 사용하여 사용자 안내
- **일관성**: 기능 전반에 걸쳐 컴포넌트(AlarmCard, HeaderBar) 재사용
- **접근성**: 모든 상호작용 요소는 명확한 터치 영역과 레이블 보유
