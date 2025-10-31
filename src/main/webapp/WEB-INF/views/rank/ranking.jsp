<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>RIDING GOAT • Dangerous Map</title>

  <!-- Tailwind -->
  <script src="https://cdn.tailwindcss.com"></script>

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Jockey+One&family=Paytone+One&display=swap" rel="stylesheet"/>

  <!-- Icons -->
  <script src="https://unpkg.com/lucide@latest"></script>

  <!-- 배경 블러 -->
  <!-- Swiper (community와 동일) -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css"/>
  <script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>

  <style>
    /* 슬라이드 네비게이션 버튼 색상 */
    .swiper .swiper-button-prev,
    .swiper .swiper-button-next {
      color: #12d2a0; /* var(--brand)와 동일 톤 */
    }
    /* 페이지네이션(동그라미) 색상 */
    .swiper .swiper-pagination-bullet {
      background: #12d2a0;
      opacity: .35;
    }
    .swiper .swiper-pagination-bullet-active {
      background: #12d2a0;
      opacity: 1;
    }
  </style>
  <style>
    *{ scrollbar-width: thin; scrollbar-color: #2c3a37 transparent; }
    *::-webkit-scrollbar{ height:10px; width:10px; }
    *::-webkit-scrollbar-thumb{ background:#2c3a37; border-radius:10px; }
    *::-webkit-scrollbar-track{ background:transparent; }
  </style>

</head>

<body class="page-ranking"> <!-- ranking.jsp -->

<!-- ✅ 공통 헤더 include -->
<%@ include file="../common/header.jsp" %>

<!-- 본문 -->
<main class="pt-6">
  <div class="absolute inset-0 top-14 text-white">
    <div class="absolute inset-0 flex">
      <!-- 왼쪽 랭킹 영역 -->
      <div class="flex-1 p-6 overflow-y-auto">
        <div class="font-jockey text-3xl mb-6" style="color:var(--brand)">Leaderboard</div>

        <!-- 기간 선택 -->
        <div id="periodTabs" class="flex gap-4 mb-6"></div>

        <!-- 탑 3 포디움 -->
        <div id="podium" class="flex items-end justify-center gap-8 mb-8 h-64"></div>

        <!-- 전체 랭킹 리스트 -->
        <div id="rankList" class="space-y-3"></div>
      </div>

      <!-- 오른쪽 정보 패널 -->
      <aside class="w-80 bg-black bg-opacity-70 p-6 overflow-y-auto">
        <!-- 내 정보 -->
        <div id="yourStats" class="mb-6 bg-gray-800 rounded-lg p-4 hidden"></div>

        <!-- ✅ 주간 도전 과제 -->
        <div class="mb-6 bg-gray-800 rounded-lg p-4">
          <div class="font-jockey text-xl mb-4" style="color:var(--brand)">Weekly Challenge</div>
          <div class="weekly-challenges space-y-3"></div>
        </div>

        <!-- 업적 시스템 -->
        <div class="bg-gray-800 rounded-lg p-4">
          <div class="font-jockey text-xl mb-4" style="color:var(--brand)">Achievements</div>
          <div id="achievements" class="space-y-3"></div>
        </div>
      </aside>
    </div>
  </div>
</main>

<!-- 순수 JS 렌더링 -->
<script>
  // ===== 서버 데이터 =====
  let selectedPeriod = 'weekly';

  const rankingUsers = [
    <c:forEach var="u" items="${rankingUsers}" varStatus="st">
    {
      id: ${u.id},
      name: '${u.userName}',
      avatar: '<c:out value="${u.avatar}" default="🚴" />',
      points: ${u.points},
      distance: ${u.distance},
      achievements: ${u.achievements},
      level: ${u.level},
      isCurrentUser: ${u.currentUser}
    }${!st.last ? ',' : ''}
    </c:forEach>
  ];

  const achievements = [
    <c:forEach var="a" items="${achievements}" varStatus="st">
    {
      id: '<c:out value="${a.id}"/>',
      title: '<c:out value="${a.title}"/>',
      description: '<c:out value="${a.description}"/>',
      icon: '<c:out value="${a.icon}" default="✅" />',
      rarity: '<c:out value="${a.rarity}" default="common" />',
      unlocked: ${a.unlocked},
      progress: ${a.progress != null ? a.progress : 0},
      target: ${a.target != null ? a.target : 0},
      unit: '<c:out value="${a.unit}" default="km" />'
  }${!st.last ? ',' : ''}
    </c:forEach>
  ];

  const challenges = [
    <c:forEach var="c" items="${challenges}" varStatus="st">
    {
      id: <c:out value="${c.challengeId}" default="0"/>,
      type: '<c:out value="${c.challengeType}" default="Weekly Challenge"/>',
      target: <c:out value="${c.targetValue}" default="0"/>,
      // ⬇⬇⬇ 여기만 바꿈
      progress: <c:out value="${c.progressKm}" default="0"/>,
      completed: <c:out value="${c.completed}" default="0"/>
    }${!st.last ? ',' : ''}
    </c:forEach>
  ];

  // ===== 유틸 =====
  const esc = function(s){
    return String(s ?? '').replace(/[&<>"']/g, function(m){
      return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]);
    });
  };
  const rarityBorder = function(r){
    return ({common:'border-gray-400', rare:'border-blue-400', epic:'border-purple-400', legendary:'border-yellow-400'})[r] || 'border-gray-400';
  };
  function rankIcon(position){
    if (position === 1) return '<i data-lucide="trophy" class="w-8 h-8 text-yellow-400"></i>';
    if (position === 2) return '<i data-lucide="medal" class="w-8 h-8 text-gray-400"></i>';
    if (position === 3) return '<i data-lucide="award" class="w-8 h-8 text-orange-400"></i>';
    return '<div class="w-8 h-8 bg-gray-600 rounded-full flex items-center justify-center text-white">'+position+'</div>';
  }

  // ===== 렌더 =====
  function renderTabs(){
    var periods = ['daily','weekly','monthly'];
    document.getElementById('periodTabs').innerHTML = periods.map(function(p){
      return '<button data-period="'+p+'" class="px-4 py-2 rounded-lg font-jockey transition-all '+(selectedPeriod==p ? 'bg-[var(--brand)] text-black' : 'bg-gray-800 text-white hover:bg-gray-700')+'">'
              + p[0].toUpperCase()+p.slice(1)
              + '</button>';
    }).join('');
    document.querySelectorAll('[data-period]').forEach(function(btn){
      btn.addEventListener('click', function(){
        selectedPeriod = btn.getAttribute('data-period');
        renderAll();
      });
    });
  }

  function renderPodium(){
    if (!Array.isArray(rankingUsers) || rankingUsers.length < 3) {
      document.getElementById('podium').innerHTML = '';
      return;
    }
    var u = rankingUsers;
    var html = ''
            // 2nd
            + '<div class="flex flex-col items-center">'
            +   '<div class="text-6xl mb-2">'+esc(u[1].avatar)+'</div>'
            +   '<div class="text-center mb-4">'
            +     '<div class="text-xl text-white">'+esc(u[1].name)+'</div>'
            +     '<div class="text-sm text-gray-300">'+u[1].points.toLocaleString()+' PTS</div>'
            +   '</div>'
            +   '<div class="w-24 h-32 bg-gray-700 rounded-t-lg flex flex-col items-center justify-end pb-4">'
            +     '<i data-lucide="medal" class="w-12 h-12 text-gray-400 mb-2"></i>'
            +     '<div class="text-2xl text-white">2</div>'
            +   '</div>'
            + '</div>'
            // 1st
            + '<div class="flex flex-col items-center">'
            +   '<div class="text-6xl mb-2">'+esc(u[0].avatar)+'</div>'
            +   '<div class="text-center mb-4">'
            +     '<div class="text-xl text-white">'+esc(u[0].name)+'</div>'
            +     '<div class="text-sm text-gray-300">'+u[0].points.toLocaleString()+' PTS</div>'
            +   '</div>'
            +   '<div class="w-24 h-40 bg-yellow-600 rounded-t-lg flex flex-col items-center justify-end pb-4">'
            +     '<i data-lucide="trophy" class="w-12 h-12 text-yellow-400 mb-2"></i>'
            +     '<div class="text-2xl text-white">1</div>'
            +   '</div>'
            + '</div>'
            // 3rd
            + '<div class="flex flex-col items-center">'
            +   '<div class="text-6xl mb-2">'+esc(u[2].avatar)+'</div>'
            +   '<div class="text-center mb-4">'
            +     '<div class="text-xl text-white">'+esc(u[2].name)+'</div>'
            +     '<div class="text-sm text-gray-300">'+u[2].points.toLocaleString()+' PTS</div>'
            +   '</div>'
            +   '<div class="w-24 h-28 bg-orange-600 rounded-t-lg flex flex-col items-center justify-end pb-4">'
            +     '<i data-lucide="award" class="w-12 h-12 text-orange-400 mb-2"></i>'
            +     '<div class="text-2xl text-white">3</div>'
            +   '</div>'
            + '</div>';
    document.getElementById('podium').innerHTML = html;
  }

  function renderList(){
    // 상위 5명만 자르기
    var topUsers = rankingUsers.slice(0, 5);

    var html = topUsers.map(function(user, idx){
      return '<div class="p-4 rounded-lg transition-all '+(user.isCurrentUser ? 'bg-[var(--brand)]/20 border-2 border-[var(--brand)]' : 'bg-gray-800 hover:bg-gray-700')+'">'
              +   '<div class="flex items-center gap-4">'
              +     '<div class="flex-shrink-0">'+rankIcon(idx+1)+'</div>'
              +     '<div class="text-3xl">'+esc(user.avatar)+'</div>'
              +     '<div class="flex-1">'
              +       '<div class="flex items-center gap-2">'
              +         '<span class="font-jockey text-lg">'+esc(user.name)+'</span>'
              +         (user.isCurrentUser ? '<span class="text-xs bg-[var(--brand)] text-black px-2 py-1 rounded">YOU</span>' : '')
              +       '</div>'
              +       '<div class="text-sm text-gray-300">Level '+user.level+' • '+user.achievements+' achievements</div>'
              +     '</div>'
              +     '<div class="text-right">'
              +       '<div class="text-lg text-white">'+user.points.toLocaleString()+'</div>'
              +       '<div class="text-sm text-gray-300">'+user.distance+'km</div>'
              +     '</div>'
              +   '</div>'
              + '</div>';
    }).join('');
    document.getElementById('rankList').innerHTML = html;
  }


  function renderYourStats(){
    var currentUser = rankingUsers.find(function(u){ return u.isCurrentUser; });
    var box = document.getElementById('yourStats');
    if (!currentUser){
      box.classList.add('hidden');
      return;
    }
    var rank = rankingUsers.findIndex(function(u){ return u.id===currentUser.id; }) + 1;
    box.classList.remove('hidden');
    box.innerHTML =
            '<div class="font-jockey text-xl mb-4" style="color:var(--brand)">Your Stats</div>'
            + '<div class="space-y-3">'
            +   '<div class="flex items-center gap-3">'
            +     '<i data-lucide="trophy" class="w-5 h-5 text-yellow-400"></i>'
            +     '<div>'
            +       '<div class="text-sm text-gray-300">Rank</div>'
            +       '<div class="text-white">#'+rank+'</div>'
            +     '</div>'
            +   '</div>'
            +   '<div class="flex items-center gap-3">'
            +     '<i data-lucide="star" class="w-5 h-5 text-purple-400"></i>'
            +     '<div>'
            +       '<div class="text-sm text-gray-300">Points</div>'
            +       '<div class="text-white">'+currentUser.points.toLocaleString()+'</div>'
            +     '</div>'
            +   '</div>'
            +   '<div class="flex items-center gap-3">'
            +     '<i data-lucide="route" class="w-5 h-5 text-blue-400"></i>'
            +     '<div>'
            +       '<div class="text-sm text-gray-300">Distance</div>'
            +       '<div class="text-white">'+currentUser.distance+'km</div>'
            +     '</div>'
            +   '</div>'
            +   '<div class="flex items-center gap-3">'
            +     '<i data-lucide="trending-up" class="w-5 h-5 text-green-400"></i>'
            +     '<div>'
            +       '<div class="text-sm text-gray-300">Level</div>'
            +       '<div class="text-white">'+currentUser.level+'</div>'
            +     '</div>'
            +   '</div>'
            + '</div>';
  }

  function renderAchievements(){
    const fmt = function(v){ return (v % 1 === 0 ? v : Number(v).toFixed(1)); };
    var html = achievements.map(function(a){
      var pct = a.target > 0 ? Math.min(100, Math.round((a.progress / a.target) * 100)) : 0;
      var badge = (a.unlocked == 1)
              ? '<div class="text-xs bg-green-600 text-white px-2 py-1 rounded">✓</div>'
              : '<div class="text-xs bg-gray-600 text-white px-2 py-1 rounded">' + pct + '%</div>';

      return ''
              + '<div class="p-3 rounded-lg border-2 '
              +   (a.unlocked == 1 ? (rarityBorder(a.rarity)+' bg-white/5') : 'border-gray-600 bg-gray-700')
              + '">'
              +   '<div class="flex items-center gap-3">'
              +     '<div class="flex-1">'
              +       '<div class="text-sm text-white">' + esc(a.title) + '</div>'
              +       '<div class="text-xs text-gray-300">' + esc(a.description) + '</div>'
              +       '<div class="mt-2">'
              +         '<div class="w-full bg-gray-600/60 rounded-full h-2">'
              +           '<div class="h-2 rounded-full bg-[var(--brand)]" style="width:' + pct + '%;"></div>'
              +         '</div>'
              +         '<div class="mt-1 text-[11px] text-gray-300">'
              +           fmt(a.progress) + ' / ' + fmt(a.target) + ' ' + esc(a.unit || 'km')
              +         '</div>'
              +       '</div>'
              +     '</div>'
              +     badge
              +   '</div>'
              + '</div>';
    }).join('');
    document.getElementById('achievements').innerHTML = html;
  }


  function renderChallenges(){
    var html = challenges.map(function(c){
      var p   = Number(c.progress || 0);   // ← progressKm가 여기로 들어옴
      var t   = Number(c.target   || 0);
      var pct = t > 0 ? Math.min(100, Math.round((p / t) * 100)) : 0;
      var fmt = function(v){ return Number.isFinite(v) ? (v % 1 === 0 ? v : v.toFixed(1)) : '0'; };

      var badge = Number(c.completed) === 1
              ? '<div class="text-xs bg-green-600 text-white px-2 py-1 rounded">✓</div>'
              : '';

      return ''
              + '<div class="flex items-center gap-3">'
              +   '<i data-lucide="target" class="w-5 h-5 text-orange-400"></i>'
              +   '<div class="flex-1">'
              +     '<div class="text-sm text-white">' + String(c.type || '') + '</div>'
              +     '<div class="text-xs text-gray-300">Progress: ' + fmt(p) + ' / ' + fmt(t) + '</div>'
              +     '<div class="w-full bg-gray-700 rounded-full h-2 mt-1">'
              +       '<div class="bg-orange-400 h-2 rounded-full" style="width:' + pct + '%"></div>'
              +     '</div>'
              +   '</div>'
              +   badge
              + '</div>';
    }).join('');

    var box = document.querySelector('.weekly-challenges');
    if (box){
      box.innerHTML = html;
      if (window.lucide && lucide.createIcons) lucide.createIcons();
    }
  }



  function renderAll(){
    renderTabs();
    renderPodium();
    renderList();
    renderYourStats();
    renderAchievements();
    renderChallenges();
    lucide.createIcons();
  }

  // 초기 렌더
  renderAll();

  console.log("DEBUG challenges:", challenges);
</script>
</body>
</html>
