<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html>
<head>
  <title>🏆 TOP 5 랭킹 🏆</title>
  <!-- Tailwind CSS 불러오기 -->
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    /* ✅ 배경 흐림 효과 */
    body::before {
      content: "";
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: url('<%=request.getContextPath()%>/images/ranking-thumbnail.png') no-repeat center center/cover;
      filter: blur(8px) brightness(0.6);
      z-index: -1;
    }
  </style>
</head>
<body class="bg-gray-900/80 text-white min-h-screen relative">

<!-- ===================== 상단 네비게이션 바 ===================== -->
<nav class="bg-black/80 flex items-center justify-between px-6 py-3 shadow-md relative z-10">

  <!-- 좌측 로고 -->
  <div class="text-2xl font-extrabold text-[#1ccc94]">
    <a href="http://localhost:11000">RIDING GOAT</a>
  </div>

  <!-- 가운데 메뉴 -->
  <div class="flex space-x-8 text-lg font-semibold">
    <a href="http://localhost:11000/map/map" class="hover:text-[#1ccc94] flex items-center gap-1">
      ⚠️ Dangerous Map <span class="text-red-500 text-sm">●</span>
    </a>
    <a href="/ranking" class="text-[#1ccc94] border-b-2 border-[#1ccc94]">
      Ranking
    </a>
    <a href="/community" class="hover:text-[#1ccc94]">Community</a>
    <a href="/events" class="hover:text-[#1ccc94]">Events</a>
  </div>

  <!-- 우측 사용자 정보 (임시 하드코딩) -->
  <div class="flex items-center bg-gray-800/80 px-3 py-1 rounded-lg">
    <span class="mr-2 text-xl">🚴</span>
    <div class="text-right">
      <div class="text-sm font-bold">Test User</div>
      <div class="text-xs text-gray-300">Level 9</div>
    </div>
  </div>
</nav>

<!-- ===================== 메인 콘텐츠 ===================== -->
<div class="p-8 relative z-10">

  <!-- 상단 제목 + Tabs -->
  <div class="flex justify-between items-center mb-10">
    <h1 class="text-2xl font-bold text-[#1ccc94]">Leaderboard</h1>
    <div class="flex gap-2">
      <button class="px-4 py-2 rounded-lg bg-black/60 hover:bg-black/80">Daily</button>
      <button class="px-4 py-2 rounded-lg bg-[#1ccc94] text-black font-bold">Weekly</button>
      <button class="px-4 py-2 rounded-lg bg-black/60 hover:bg-black/80">Monthly</button>
    </div>
  </div>

  <!-- Podium (1~3위) -->
  <div class="flex items-end justify-center gap-8 mb-12 h-64">

    <!-- 2등 -->
    <c:if test="${fn:length(top5List) >= 2}">
      <c:set var="user" value="${top5List[1]}" />
      <div class="flex flex-col items-center">
        <div class="text-5xl mb-2">🚴</div>
        <div class="text-lg">${user.name}</div>
        <div class="text-sm text-gray-300">${user.points} PTS</div>
        <div class="bg-gray-600 w-24 h-32 flex flex-col justify-end items-center rounded-t-lg mt-2">
          <span class="text-2xl">2</span>
        </div>
      </div>
    </c:if>

    <!-- 1등 -->
    <c:if test="${fn:length(top5List) >= 1}">
      <c:set var="user" value="${top5List[0]}" />
      <div class="flex flex-col items-center">
        <div class="text-5xl mb-2">🚴</div>
        <div class="text-yellow-300 text-lg">${user.name}</div>
        <div class="text-sm text-gray-300">${user.points} PTS</div>
        <div class="bg-yellow-600 w-24 h-40 flex flex-col justify-end items-center rounded-t-lg mt-2">
          <span class="text-2xl">1</span>
        </div>
      </div>
    </c:if>

    <!-- 3등 -->
    <c:if test="${fn:length(top5List) >= 3}">
      <c:set var="user" value="${top5List[2]}" />
      <div class="flex flex-col items-center">
        <div class="text-5xl mb-2">🚴</div>
        <div class="text-orange-300 text-lg">${user.name}</div>
        <div class="text-sm text-gray-300">${user.points} PTS</div>
        <div class="bg-orange-600 w-24 h-28 flex flex-col justify-end items-center rounded-t-lg mt-2">
          <span class="text-2xl">3</span>
        </div>
      </div>
    </c:if>
  </div>

  <!-- Ranking List (Top 5) -->
  <div class="w-full max-w-2xl mx-auto space-y-3">
    <c:forEach var="user" items="${top5List}" varStatus="status">
      <div class="flex justify-between items-center p-4 rounded-lg
          <c:choose>
            <c:when test='${status.index == 0}'>bg-yellow-600 text-black</c:when>
            <c:when test='${status.index == 1}'>bg-gray-700</c:when>
            <c:when test='${status.index == 2}'>bg-orange-600</c:when>
            <c:otherwise>bg-gray-800</c:otherwise>
          </c:choose>">

        <!-- Left: 이름 + 거리 + 탄소 절감 -->
        <div>
          <div class="flex items-center gap-2">
            <span class="font-bold">${status.index+1}. ${user.name}</span>
          </div>
          <div class="text-sm opacity-70">
            거리 ${user.distance}km • 탄소절감 ${user.carbonSaved}
          </div>
        </div>

        <!-- Right: 점수 + 등록일 -->
        <div class="text-right">
          <div class="font-bold">${user.points}</div>
          <div class="text-sm opacity-70">${user.createdAt}</div>
        </div>
      </div>
    </c:forEach>
  </div>
</div>
</body>
</html>
