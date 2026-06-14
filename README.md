# BestWorldCupTeam
### 나만의 월드컵 드림팀을 구성하는 iOS 애플리케이션

2171467 최지환

<br>

### 1. 프로젝트 수행 목적

#### 1.1 프로젝트 정의

* 전 세계 스타 선수를 모아 나만의 월드컵 드림팀(베스트 11)을 구성하는 iOS 애플리케이션

#### 1.2 프로젝트 배경

* 월드컵 시즌이 되면 팬들은 "내가 감독이라면 누구를 뽑을까"를 상상하며 즐긴다. 그러나 기존의 라인업 도구들은 데이터가 복잡하거나 웹 기반이라 모바일에서 직관적으로 즐기기 어렵다.
* 누구나 손쉽게 선수를 탐색하고, 포메이션 위에 직접 배치하며, 자신만의 드림팀을 완성하는 경험을 모바일 네이티브 앱으로 제공하고자 한다.

#### 1.3 프로젝트 목표

* 선수 탐색
  * 국가·대륙·포지션별 필터와 검색, 정렬로 원하는 선수를 빠르게 탐색
* 드림팀 구성
  * 12종의 포메이션을 선택하고, 선수를 자리에 배치해 베스트 11 완성
* 직관적 인터랙션
  * 피치 위에서 선수를 드래그해 자리를 교체하는 모바일 친화적 조작
* 실제 대회 연동
  * 진행 중인 월드컵 경기 결과를 홈 화면에서 함께 확인

### 2. 프로젝트 개요

#### 2.1 프로젝트 설명

* 16개국 약 200명의 선수 데이터를 바탕으로, 포지션·국가·대륙 필터와 검색·정렬을 통해 선수를 탐색한다.
* 선수를 선택하면 능력치 6종(페이스·슈팅·패스·드리블·수비·피지컬)을 바 그래프로 확인하고 드림팀에 추가할 수 있다.
* 12종의 포메이션 중 하나를 골라 피치 위에 선수를 배치하며, 선수 칩을 드래그해 자리를 교체한다.
* OVR을 10단위로 끊은 S/A/B/C/D 등급을 골드·실버·브론즈·그레이 색상으로 시각화한다.
* 드림팀 상태는 `UserDefaults`로 저장되어 앱을 재실행해도 유지된다. (향후 Firebase 클라우드 동기화로 확장 가능)
* 홈 화면에서 완성도 링, 최고 평점 선수 카드, 진행 중인 월드컵 경기 결과를 한눈에 확인한다.
* 도움말(ⓘ) 화면에서 팀 구성 팁과 추천 포메이션 조합을 안내한다.

#### 2.2 프로젝트 구조

```
BestWorldCupTeam/
├── AppDelegate.swift / SceneDelegate.swift   앱 진입점
├── Theme.swift                               색상·폰트 토큰
├── Models.swift                              국가·선수·포메이션·경기결과 데이터
├── AppState.swift                            드림팀 상태 + UserDefaults 영속
├── Helpers.swift                             토스트·칩·배지·능력치 바
├── PortraitView.swift                        선수 아바타(사진/실루엣)
├── WrapStack.swift                           자동 줄바꿈 레이아웃
├── MainTabBarController.swift                하단 탭바
├── SplashViewController.swift                시작 화면
├── HomeViewController.swift                  홈 대시보드
├── PlayersViewController.swift               선수 탐색 (테이블·필터·검색)
├── PlayerCell.swift                          선수 목록 셀
├── PlayerDetailViewController.swift          선수 상세 (능력치·픽)
├── DreamTeamViewController.swift             드림팀 포메이션 뷰
├── PitchView.swift                           축구장 + 드래그 교체
├── PlayerChipView.swift                      피치 위 선수 칩
├── FormationPickerViewController.swift       포메이션 선택
├── HelpViewController.swift                  팀 구성 도움말
└── CompleteViewController.swift              완성 화면
```

#### 2.3 결과물

* 시작 화면
  
  <img width="340" height="652" alt="초기화면" src="https://github.com/user-attachments/assets/9c2d5265-f0f5-4fd8-840c-16c8d321862e" />

* 홈 대시보드

  <img width="340" height="652" alt="1번화면" src="https://github.com/user-attachments/assets/58ff7a96-0953-4c17-a5ed-d0ee22e4a0d8" />

* 선수 탐색 화면

  <img width="340" height="652" alt="선수선택화면" src="https://github.com/user-attachments/assets/bac165e8-8aa6-48f9-8783-7863d01282b9" />

* 드림팀 포메이션 화면

  <img width="340" height="652" alt="포메이션화면" src="https://github.com/user-attachments/assets/383624c4-0859-47c0-a947-8dc7af0ee846" />

* 선수 상세 화면

  <img width="340" height="652" alt="선수개인화면" src="https://github.com/user-attachments/assets/5243c258-63db-4088-8738-77ee3ebf502f" />

* 팀 완성 화면

  <img width="340" height="652" alt="포메이션화면" src="https://github.com/user-attachments/assets/75e919ee-8c32-4f37-8077-83bc2ef76460" />


#### 2.4 기대효과

* 복잡한 데이터 없이도 누구나 직관적으로 자신만의 드림팀을 구성하며 월드컵을 즐길 수 있다.
* 드래그 기반의 모바일 친화적 인터랙션으로 라인업 구성의 재미를 높인다.
* 진행 중인 실제 경기 결과와 연동되어 대회 기간 동안 반복적으로 사용하게 된다.

#### 2.5 관련 기술

| **구분** | **설명** |
| --- | --- |
| UIKit | 애플이 제공하는 iOS UI 프레임워크. 본 프로젝트는 스토리보드 없이 코드로 화면을 구성하는 프로그래밍 방식으로 작성하였다. |
| Auto Layout | 다양한 화면 크기에 대응하기 위해 제약(constraint) 기반으로 뷰의 위치와 크기를 정의하는 레이아웃 시스템이다. |
| Core Animation | CAShapeLayer·CAGradientLayer를 이용해 축구장 라인, 그라데이션 배경, 완성도 링 등 커스텀 그래픽을 그린다. |
| UIGestureRecognizer | UIPanGestureRecognizer로 피치 위 선수 칩을 드래그해 자리를 교체하는 인터랙션을 구현한다. |
| UserDefaults | 드림팀 라인업과 포메이션 상태를 로컬에 영속 저장하여 앱 재실행 시에도 유지한다. |

#### 2.6 개발 도구

| **구분** | **설명** |
| --- | --- |
| Xcode | 애플의 공식 통합 개발 환경(IDE)으로, Swift 언어로 iOS 애플리케이션을 작성·빌드·디버깅한다. 본 프로젝트는 VMware 가상 macOS 환경의 Xcode에서 개발하였다. |
| Swift | 애플이 개발한 현대적 프로그래밍 언어로, 안전성과 간결한 문법을 특징으로 한다. |
| iOS Simulator | 실제 기기 없이 다양한 iPhone 환경에서 앱을 실행·테스트할 수 있는 시뮬레이터이다. (최소 타깃 iOS 14.0+) |

#### 2.7 발표영상

[![발표영상](https://img.youtube.com/vi/DblJDVpPgXM/0.jpg)](https://youtu.be/DblJDVpPgXM)
