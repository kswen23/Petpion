# Petpion
새로운 내 반려동물 자랑 커뮤니티 **Petpion**
## 개발기간
2022.11.02 ~ 2023.03.15
## 서비스 소개
<img width="1789" alt="PetpionPreview" src="https://user-images.githubusercontent.com/89299245/224591843-377965e4-7e8c-4c7c-8649-b7fc805368e2.png">

## 사용한 기술
### 모듈화
> **Tuist** 
[![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)](https://tuist.io)
*  Tuist를 사용하여 Xcode 프로젝트의 구성 및 관리를 자동화 하였습니다. 
* 각 프레임워크 간 의존성을 단번에 파악할 수 있고 의존성 버전관리 또한 간편해졌습다.
> **Swinject**
* 모든 레이어에 대한 의존성을 가지는 독립적인 의존성 주입 컴포넌트를 Swinject로 구성했습니다.
* 모듈 간의 조립을 한 컴포넌트(컨테이너)에서 모두 처리하게 되고, 각 레이어에서는 단순히 주입된 의존성을 가진 인스턴스를 사용하기만 하면 됩니다.
* Swinject의 컨테이너는 객체의 생명주기를 관리하고 의존성을 교체하는 데에 매우 유연하게 사용할 수 있습니다.

[Swift] Petpion - 모듈화를 위한 도구 (Tuist, Swinject)
https://kswift.tistory.com/15

### 백엔드 서비스

> **Firestore**

  NoSQL 데이터베이스로, 실시간 데이터 동기화를 지원하며 빠른 읽기/쓰기 속도를 보장합니다.
1.  피드 데이터 업로드
-   유저가 올리는 피드의 데이터를 Firestore에 업로드합니다.
-   업로드된 데이터는 유저가 올린 피드의 정보, 유저 정보, 좋아요 개수, 댓글 정보 등이 포함됩니다.
-   Firestore의 `collection`과 `document`를 사용하여 데이터를 구조화하고, `add()` 메서드를 사용하여 데이터를 업로드합니다.

2.  피드 특정 규칙순으로 불러오기
-   Firestore의 `collection`과 `document`를 사용하여 구조화된 데이터를 특정 규칙에 따라 불러옵니다.
-   예를 들어, 유저가 올린 최신순의 피드 10개를 불러오거나, 좋아요 개수가 많은 순으로 상위 10개의 피드를 불러오는 등의 규칙을 설정하여 데이터를 불러올 수 있습니다.
-   `orderBy()`, `limit()` 등의 메서드를 사용하여 규칙에 따라 데이터를 불러옵니다.

3.  데이터 동기화
-   Petpion 앱에서는 실시간으로 데이터를 동기화하여 사용자 경험을 향상시킵니다.
-   Firebase의 `onSnapshot()` 메서드를 사용하여 데이터 변경 사항을 실시간으로 감지하고, 변경 사항이 있을 때마다 UI를 업데이트합니다.

4.  Petpion 투표 기능
-   Petpion 앱에서는 사용자들이 업로드한 피드에 대해 투표할 수 있는 기능을 제공합니다.
-   사용자들은 1시간마다 1개의 투표 기회를 얻으며, 투표한 피드는 좋아요 개수가 증가합니다.
-   투표한 내용은 Firestore에 업로드되며, 업로드된 데이터를 기반으로 인기 순위를 제공합니다
> **Firebase Storage**

클라우드 스토리지로, 사용자가 업로드한 파일을 안전하게 저장하고 다운로드할 수 있습니다.
1.  이미지 업로드
-   유저가 Petpion 앱에서 이미지를 올리면, 클라이언트 측에서 해당 이미지을 Firestorage에 업로드합니다.
-   업로드 시에는 Firebase SDK에서 제공하는 `putData()` 함수를 사용합니다. 이 함수는 파일을 바이트 배열로 변환한 후 업로드합니다.
-   반환된 URL을 Firestore에 저장되어 있는 해당 피드 문서의 `imageReference` 필드에 업데이트합니다.

2.  이미지 불러오기
-   피드 리스트에서 특정 피드를 클릭하면, 해당 피드에 대한 상세 페이지로 이동합니다.
-   이때, 해당 피드의 `imageReference` 필드에 저장되어 있는 URL을 가져와 Firestorage에서 사진을 다운로드합니다.
-   다운로드 시에는 Firebase SDK에서 제공하는 `downloadURL()` 함수를 사용합니다. 이 함수는 참조하는 파일의 다운로드 URL을 가져옵니다.
-   다운로드한 사진을 클라이언트 측에서 적절한 방법으로 렌더링하여 사용자에게 보여줍니다.
> **Firebase Auth**

사용자 인증 기능을 제공합니다. 
-  AppleLogin 또는 KakaoLogin을 사용하여 유저가 입력한 인증 정보를 검증하고, 인증된 유저에 대한 정보를 Firebase 서버에서 관리합니다.

> **Kakao Auth**

카카오 로그인 기능을 구현하기 위한 SDK입니다.

[Swift] Petpion - Apple, Kakao Login with OAuth
https://kswift.tistory.com/16


앱에 대해서 질문또는 문의사항이 있으시다면 
kswen0203@gmail.com 으로 자유롭게 연락주세요!
