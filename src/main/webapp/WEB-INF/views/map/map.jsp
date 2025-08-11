<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>Dangerous Map Page</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
<%--  <link rel="stylesheet" type="text/css" href="/css/style.css" />--%>
  <script src="/js/dangerousMap.js"></script>

  <!-- Tailwind CSS 포함 (로컬로 설정 권장) -->
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    #bodyContent p {
      color: black;
    }
    #firstHeading {
      color: black;
      font-size: 50px;
      font-weight: bolder;
    }

  <%--  div img {--%>
  <%--    display: none;--%>
  <%--  }--%>
  </style>



  <!-- Google Maps API -->
  <script async
          defer
          src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDFRdAXJPQKDQYz8KhumTBqDRPDWEa-tjs&callback=initMap"></script>

  <!-- 필요 시 Lucide 아이콘 SVG 직접 포함 또는 아이콘 라이브러리 대체 -->
<%--  <link rel="stylesheet" href="https://unpkg.com/lucide-static/icons.css" />--%>
</head>
<body class="bg-black text-white">
<div id="map-container" class="absolute inset-0 top-11 text-white">
  <div class="absolute inset-0 flex">

    <!-- 지도 영역 -->
    <div class="flex-1 relative">
      <div id="map" class="absolute inset-0 m-4 w-full h-full rounded-lg shadow-lg z-10"></div>

      <!-- 경로 이탈 경고 -->
      <div id="offRouteWarning" class="hidden absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-red-600 rounded-lg p-6 max-w-sm z-50">
        <div class="text-center">
          <div class="w-12 h-12 mx-auto mb-4">⚠️</div>
          <h3 class="text-xl mb-2">경로 이탈</h3>
          <p class="text-sm mb-4">설정된 경로에서 벗어났습니다.</p>
          <div class="flex gap-2">
            <button onclick="handleReroute()" id="rerouteBtn" class="flex-1 bg-white text-red-600 px-4 py-2 rounded-lg hover:bg-gray-100 transition-colors">재경로</button>
            <button onclick="stopNavigation()" class="px-4 py-2 border border-white text-white rounded-lg hover:bg-white hover:text-red-600 transition-colors">중지</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 오른쪽 정보 패널 -->
    <div class="w-96 bg-black bg-opacity-70 p-6 overflow-y-auto">
      <div class="text-2xl mb-6 text-[#1ccc94]">Smart Navigation</div>

      <!-- 현재 위치 정보 -->
      <div class="mb-6 bg-gray-800 rounded-lg p-4" id="locationInfo">
        <div class="text-lg mb-3 text-[#1ccc94]">Current Location</div>
        <div class="space-y-2 text-sm">
          <div>위도: <span id="lat">-</span></div>
          <div>경도: <span id="lng">-</span></div>
          <div>시간: <span id="time">-</span></div>
        </div>
      </div>

      <!-- 추천 경로 보기 버튼 -->
      <div class="mb-6">
        <button onclick="toggleRoutes()" class="w-full p-4 rounded-lg mb-4 bg-[#1ccc94] hover:bg-[#16a085] text-black">추천경로 보기</button>
      </div>

      <!-- 추천 경로 리스트 -->
      <div id="routeList" class="space-y-4 mb-6 hidden">
        <!-- 여기에 자바스크립트로 동적으로 경로 목록 렌더링 -->
      </div>

      <!-- 음성 안내 영역 -->
      <div id="voiceList" class="hidden mb-6 bg-gray-800 rounded-lg p-4">
        <div class="text-lg text-white mb-2">음성 안내</div>
        <div id="voiceItems" class="space-y-2 max-h-32 overflow-y-auto">
          <!-- 음성 안내 내역 동적 표시 -->
        </div>
      </div>

      <!-- 위험 지역 리스트 -->
      <div class="space-y-4" id="dangerList">
        <h3 class="text-lg text-white">주변 위험지역</h3>
        <!-- 자바스크립트로 동적으로 위험지역 리스트 렌더링 -->
      </div>

      <!-- 구글맵 통합 설명 -->
      <div class="mt-6 bg-gray-800 rounded-lg p-4">
        <h3 class="text-lg mb-3 text-[#1ccc94]">Google Maps Integration</h3>
        <ul class="space-y-2 text-sm text-gray-300">
          <li>• 실시간 Google Maps API 사용</li>
          <li>• GPS 위치 추적 기능</li>
          <li>• 서울 시청 기본 위치 설정</li>
          <li>• 위험지역 마커 표시</li>
          <li>• 인터랙티브 지도 컨트롤</li>
        </ul>
      </div>
    </div>
  </div>
</div>

<button onclick="toggleRoutes()" style="position:absolute; top:10px; right:10px; z-index:999; background:#fff; border:1px solid #ccc; padding:8px;">
  경로 보기
</button>

<!-- JavaScript 파일 연결 -->
</body>
</html>
