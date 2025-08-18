<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>자전거 내비게이션 (Kakao)</title>

    <link rel="icon" href="data:,">
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Kakao SDK: services + autoload=false (우리 JS에서 kakao.maps.load(...) 호출해야 함) -->
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoJsKey}&libraries=services&autoload=false"></script>

    <!-- 서버 JSON 안전 주입 (비어도 죽지 않게) -->
    <script>
        (function () {
            try { window.dangerousAreas = JSON.parse('<c:out value="${dangerousAreasJson}" escapeXml="false"/>' ); }
            catch (e) { window.dangerousAreas = []; }

            try { window.recommendedRoutes = JSON.parse('<c:out value="${recommendedRoutesJson}" escapeXml="false"/>' ); }
            catch (e) { window.recommendedRoutes = []; }

            // (개발용) 브라우저에서 REST를 직접 호출할 때만 사용 — 운영은 서버 프록시 권장
            window.KAKAO_REST_KEY = '${kakaoMobilityRestKey}';
        })();
    </script>

    <!-- 우리 JS (정적 리소스: resources/static/js/dangerousMap.js) -->
    <script src="${pageContext.request.contextPath}/js/dangerousMap.js" defer></script>
</head>
<body class="bg-black text-white m-0 p-0">

<div class="absolute inset-0 flex">

    <!-- 지도 영역 -->
    <div class="flex-1 relative">
        <div id="map" class="absolute inset-0 m-4 w-full h-full rounded-lg shadow-lg z-10"></div>

        <!-- 경로 이탈 경고 -->
        <div id="offRouteWarning"
             class="hidden absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2
                bg-red-600 rounded-lg p-6 max-w-sm z-50 text-center">
            <div class="w-12 h-12 mx-auto mb-4">⚠️</div>
            <h3 class="text-xl mb-2">경로 이탈</h3>
            <p class="text-sm mb-4">설정된 경로에서 벗어났습니다.</p>
            <div class="flex gap-2">
                <button onclick="handleReroute()"
                        class="flex-1 bg-white text-red-600 px-4 py-2 rounded-lg hover:bg-gray-100">
                    재경로
                </button>
                <button onclick="stopNavigation()"
                        class="px-4 py-2 border border-white rounded-lg hover:bg-white hover:text-red-600">
                    중지
                </button>
            </div>
        </div>

        <!-- 음성 안내 텍스트 -->
        <!-- ⓘ 경로 안내: 하단 작은 도크 -->
        <div id="voiceDock"
             class="fixed bottom-3 left-1/2 -translate-x-1/2 z-40 flex flex-col items-center space-y-2">

            <!-- 다음 안내 한 줄만 보여주는 칩(클릭하면 패널 토글) -->
            <button id="voiceChip"
                    onclick="toggleVoicePanel()"
                    class="hidden fixed bottom-4 right-4 z-50 px-3 py-2 rounded-full bg-emerald-500 hover:bg-emerald-400 text-sm">
                다음: 안내 없음
            </button>

            <!-- 펼침 패널: 높이 낮게, 스크롤 가능 -->
            <div id="voiceList"
                 class="hidden fixed bottom-16 right-4 z-50 w-72 max-h-60 overflow-auto bg-gray-900/90 text-white rounded-lg p-3 shadow">
                <div class="text-sm font-semibold mb-2">안내 목록</div>
                <div id="voiceItems" class="space-y-1 text-xs"></div>
            </div>
        </div>
    </div>

    <!-- 사이드바 -->
    <aside class="w-80 h-screen p-4 bg-black space-y-6 overflow-y-auto z-50">

        <!-- 경로 검색 -->
        <section class="space-y-2">
            <h2 class="text-xl font-bold text-emerald-400">Smart Navigation (Kakao)</h2>
            <input id="startInput" type="text" placeholder="출발지 검색 (예: 강남역)" class="w-full p-2 rounded text-black"/>
            <input id="endInput"   type="text" placeholder="도착지 검색 (예: 서울역)" class="w-full p-2 rounded text-black"/>
            <div class="flex gap-2">
                <button id="searchStart" class="flex-1 p-2 bg-slate-600 rounded hover:bg-slate-500">출발지 찾기</button>
                <button id="searchEnd"   class="flex-1 p-2 bg-slate-600 rounded hover:bg-slate-500">도착지 찾기</button>
            </div>
            <button onclick="searchRoute()" class="w-full p-2 bg-emerald-500 hover:bg-emerald-400 rounded">경로 탐색</button>
        </section>

        <!-- 현재 위치 -->
        <section class="space-y-2">
            <h3 class="text-lg font-semibold">Current Location</h3>
            <p class="text-sm">위도: <span id="lat">-</span></p>
            <p class="text-sm">경도: <span id="lng">-</span></p>
            <p class="text-sm">시간: <span id="time">-</span></p>

            <!-- ✅ 토글 버튼: toggleGPSTrack(this) -->
            <button id="gpsToggleBtn"
                    onclick="toggleGPSTrack(this)"
                    class="w-full p-2 bg-teal-500 hover:bg-teal-400 rounded">
                위치 추적 시작
            </button>

            <!-- 옵션: 한 번만 내 위치로 화면 이동 -->
            <button onclick="recenterToMe()" class="w-full p-2 bg-slate-600 hover:bg-slate-500 rounded">
                내 위치로 이동
            </button>
        </section>

        <!-- 추천 경로 -->
        <section class="space-y-2">
            <h3 class="text-lg font-semibold">추천 경로</h3>
            <button onclick="toggleRoutes()" class="w-full p-2 bg-green-600 hover:bg-green-500 rounded">추천 경로 보기</button>
            <div id="routeList" class="hidden mt-2 space-y-2"></div>
        </section>

        <!-- 위험지역 -->
        <section class="space-y-2">
            <h3 class="text-lg font-semibold">주변 위험지역</h3>
            <div id="dangerousAreaList" class="space-y-1 text-sm text-gray-300"></div>
        </section>

    </aside>
</div>

</body>
</html>
