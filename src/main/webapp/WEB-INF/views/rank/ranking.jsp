<%@ page import="kopo.poly.util.CmmUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%
  String ctx = request.getContextPath();
%>
<%
  String ssUserName = CmmUtil.nvl((String) session.getAttribute("SS_USER_NAME")); // 로그인된 회원 이름
  String ssUserId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID")); // 로그인된 회원 아이디
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>RIDING GOAT • Ranking</title>

  <!-- Tailwind -->
  <script src="https://cdn.tailwindcss.com"></script>

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Jockey+One&family=Paytone+One&display=swap" rel="stylesheet"/>

  <!-- Icons -->
  <script src="https://unpkg.com/lucide@latest"></script>

  <!-- 배경 블러 -->
  <style>
    body::before{
      content:"";
      position:fixed; inset:0;
      background:url('<%=ctx%>/images/ranking-thumbnail.png') no-repeat center/cover;
      filter:blur(8px) brightness(.6);
      z-index:-1;
    }
  </style>

  <!-- 공통 헤더 스타일 -->
  <!-- 공통 헤더 스타일 (community.jsp와 동일) -->
  <style>
    :root{
      --brand:#12d2a0;
      --brand-600:#10b38a;
      --brand-700:#0f9a78;
      --ink:#0b1715;
    }
    *{ box-sizing:border-box; }
    html, body{ margin:0; padding:0; }
    body{ overflow-x:hidden; }

    .site-header{
      position:fixed; top:0; left:0; right:0;
      color:#fff; z-index:1000;
      background:#0b1715;
      border-bottom:1px solid rgba(255,255,255,.12);
      backdrop-filter:blur(6px);
      padding-left:max(0px, env(safe-area-inset-left));
      padding-right:max(0px, env(safe-area-inset-right));
    }
    .site-header .nav{
      width:100%;
      max-width:none;
      margin:0 auto;
      padding:0 clamp(16px,3vw,32px);
      min-height:68px;                /* ← 높이 통일 */
      display:flex; align-items:center; justify-content:space-between;  /* ← flex 레이아웃 */
    }
    .logo a{
      color:var(--brand);
      text-decoration:none; font-weight:800; letter-spacing:.3px;
      font-size:28px;                 /* ← 글자 크기 통일 */
    }
    .menu{
      flex:1; display:flex; justify-content:center;
      gap:clamp(16px,3vw,40px);
      font-weight:700; font-size:18px; flex-wrap:wrap;
    }
    .menu a{ color:#fff; text-decoration:none; opacity:.95; transition:.15s; white-space:nowrap; }
    .menu a:hover{ opacity:1; }
    .menu a.active{ color:var(--brand); }

    .auth-buttons{ display:flex; gap:18px; }
    .auth-link{ color:#fff; text-decoration:none; font-weight:700; opacity:.95; font-size:18px; }
    .auth-link:hover{ opacity:1; }

    .header-spacer{ height:68px; }    /* ← spacer도 통일 */

    @media (max-width: 640px){
      .site-header .nav{ min-height:60px; padding:0 16px; }
      .header-spacer{ height:60px; }
      .logo a{ font-size:24px; }
      .menu{ gap:16px; font-size:16px; }
      .auth-link{ font-size:16px; }
    }
  </style>


  <!-- Scrollbars: community.jsp와 동일 스킨 -->
  <style>
    /* Firefox */
    * { scrollbar-width: thin; scrollbar-color: #2c3a37 transparent; }

    /* WebKit (Chrome/Edge/Safari) */
    *::-webkit-scrollbar { width: 10px; height: 10px; }
    *::-webkit-scrollbar-thumb { background: #2c3a37; border-radius: 10px; }
    *::-webkit-scrollbar-track { background: transparent; }
  </style>

</head>

<body class="min-h-screen bg-neutral-900/80 text-white">
<!-- ✅ 공통 상단 헤더 -->
<header class="site-header">
  <div class="nav">
    <div class="logo"><a href="<%=ctx%>/">RIDING GOAT</a></div>
    <div class="menu">
      <a href="<%=ctx%>/map/map">Dangerous Map</a>
      <a href="<%=ctx%>/rank/ranking">Ranking</a>
      <a href="<%=ctx%>/community/community">Community</a>
    </div>
    <div class="auth-buttons">
      <% if (ssUserId.equals("")) { %>
      <!-- 로그인 안됨 -->
      <a href="/user/login" class="auth-link">Login</a>
      <a href="/user/userRegForm" class="auth-link">Sign Up</a>
      <% } else { %>
      <!-- 로그인됨 -->
      <a href="/user/myPage" class="auth-link"><%= ssUserName %></a>
      <a href="/user/logout" class="auth-link">Logout</a>
      <% } %>
    </div>
  </div>
</header>
<div class="header-spacer"></div>

<!-- 현재 메뉴 활성화 -->
<script>
  (function(){
    var path = location.pathname;
    document.querySelectorAll('.menu a').forEach(function(a){
      var href = a.getAttribute('href');
      if (path === href || (href !== '<%=ctx%>/' && path.startsWith(href))) {
        a.classList.add('active');
      }
    });
  })();
</script>

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
      target: ${a.target != null ? a.target : 0}
    }${!st.last ? ',' : ''}
    </c:forEach>
  ];

  const challenges = [
    <c:forEach var="c" items="${challenges}" varStatus="st">
    {
      id: '${c.challengeId}',    // 문자열
      type: '${c.challengeType}', // 문자열
      target: ${c.targetValue != null ? c.targetValue : 0},     // 숫자
      progress: ${c.progressValue != null ? c.progressValue : 0}, // 숫자
      completed: ${c.completed != null ? c.completed : 0}       // 숫자(0/1)
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
    var html = rankingUsers.map(function(user, idx){
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
    var html = achievements.map(function(a){
      return '<div class="p-3 rounded-lg border-2 '
              + (a.unlocked == 1 ? (rarityBorder(a.rarity)+' bg-white/5') : 'border-gray-600 bg-gray-700 opacity-70')
              + '">'
              +   '<div class="flex items-center gap-3">'
              +     '<div class="text-2xl">'+esc(a.icon)+'</div>'
              +     '<div class="flex-1">'
              +       '<div class="text-sm text-white">'+esc(a.title)+'</div>'
              +       '<div class="text-xs text-gray-300">'+esc(a.description)+'</div>'
              +     '</div>'
              +     (a.unlocked == 1 ? '<div class="text-xs bg-green-600 text-white px-2 py-1 rounded">✓</div>' : '')
              +   '</div>'
              + '</div>';
    }).join('');
    document.getElementById('achievements').innerHTML = html;
  }


  function renderChallenges(){
    const html = challenges.map(c => `
    <div class="flex items-center gap-3">
      <i data-lucide="target" class="w-5 h-5 text-orange-400"></i>
      <div class="flex-1">
        <div class="text-sm text-white">\${c.type}</div>
        <div class="text-xs text-gray-300">Progress: \${c.progress}/\${c.target}</div>
        <div class="w-full bg-gray-700 rounded-full h-2 mt-1">
          <div class="bg-orange-400 h-2 rounded-full"
               style="width:\${c.target > 0 ? ((c.progress/c.target)*100).toFixed(0) : 0}%"></div>
        </div>
      </div>
      \${c.completed == 1
          ? '<div class="text-xs bg-green-600 text-white px-2 py-1 rounded">✓</div>'
          : ''}
    </div>
  `).join('');
    document.querySelector('.weekly-challenges').innerHTML = html;
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
