<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="true" %>
<%
  String ctx = request.getContextPath();
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
  <style>
    :root{
      --brand:#12d2a0;
      --brand-600:#10b38a;
      --brand-700:#0f9a78;
      --ink:#0b1715;
    }

    /* 기본 리셋: 좌우 잘림 방지 */
    *{ box-sizing:border-box; }
    html, body{ margin:0; padding:0; }
    body{ overflow-x:hidden; } /* safe-area/스크롤바로 가로 스크롤 생기는 것 방지 */

    /* ✅ 고정 상단 헤더: 화면 가득 */
    .site-header{
      position:fixed; top:0; left:0; right:0;
      color:#fff; z-index:1000;
      background:#0b1715;                     /* 단색 배경 */
      border-bottom:1px solid rgba(255,255,255,.12);
      backdrop-filter:blur(6px);
      /* iOS 노치 대응 */
      padding-left:max(0px, env(safe-area-inset-left));
      padding-right:max(0px, env(safe-area-inset-right));
    }

    /* ✅ 내부 컨테이너를 100% 폭으로 (max-width 제거) */
    .site-header .nav{
      width:100%;
      max-width:none;                /* ✨ 이전의 1280px 제한 해제 */
      margin:0 auto;
      padding:0 clamp(16px,3vw,32px);
      min-height:68px;               /* 높이 업 */
      display:flex; align-items:center; justify-content:space-between;
    }

    /* 좌/중앙/우 배치 */
    .logo a{
      color:var(--brand);
      text-decoration:none; font-weight:800; letter-spacing:.3px;
      font-size:28px;               /* 글자 키움 */
    }
    .menu{
      flex:1; display:flex; justify-content:center;
      gap:clamp(16px,3vw,40px);
      font-weight:700; font-size:18px;  /* 글자 키움 */
      flex-wrap:wrap;
    }
    .menu a{ color:#fff; text-decoration:none; opacity:.95; transition:.15s; white-space:nowrap; }
    .menu a:hover{ opacity:1; }
    .menu a.active{ color:var(--brand); }

    .auth-buttons{ display:flex; gap:18px; }
    .auth-link{ color:#fff; text-decoration:none; font-weight:700; opacity:.95; font-size:18px; }
    .auth-link:hover{ opacity:1; }

    /* 본문이 헤더 밑으로 들어가지 않게 간격 확보 */
    .header-spacer{ height:68px; }

    /* 반응형(좁은 화면에서 조금 컴팩트하게) */
    @media (max-width: 640px){
      .site-header .nav{ min-height:60px; padding:0 16px; }
      .header-spacer{ height:60px; }
      .logo a{ font-size:24px; }
      .menu{ gap:16px; font-size:16px; }
      .auth-link{ font-size:16px; }
    }

  </style>
</head>

<body class="min-h-screen bg-neutral-900/80 text-white">
<!-- ✅ 공통 상단 헤더 -->
<header class="site-header">
  <div class="nav">
    <div class="logo">
      <a href="<%=ctx%>/">RIDING GOAT</a>
    </div>
    <div class="menu">
      <a href="<%=ctx%>/map/map">Dangerous Map</a>
      <a href="<%=ctx%>/ranking">Ranking</a>
      <a href="<%=ctx%>/community">Community</a>
    </div>
    <div class="auth-buttons">
      <a href="<%=ctx%>/user/login" class="auth-link">Login</a>
      <a href="<%=ctx%>/user/userRegForm" class="auth-link">Sign Up</a>
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

        <!-- 이번 주 도전 과제 -->
        <div class="mb-6 bg-gray-800 rounded-lg p-4">
          <div class="font-jockey text-xl mb-4" style="color:var(--brand)">Weekly Challenge</div>
          <div class="space-y-3">
            <div class="flex items-center gap-3">
              <i data-lucide="target" class="w-5 h-5 text-orange-400"></i>
              <div class="flex-1">
                <div class="text-sm text-white">Ride 50km</div>
                <div class="text-xs text-gray-300">Progress: 32/50km</div>
                <div class="w-full bg-gray-700 rounded-full h-2 mt-1">
                  <div class="bg-orange-400 h-2 rounded-full" style="width:64%"></div>
                </div>
              </div>
            </div>
            <div class="flex items-center gap-3">
              <i data-lucide="users" class="w-5 h-5 text-blue-400"></i>
              <div class="flex-1">
                <div class="text-sm text-white">Join 3 group rides</div>
                <div class="text-xs text-gray-300">Progress: 1/3</div>
                <div class="w-full bg-gray-700 rounded-full h-2 mt-1">
                  <div class="bg-blue-400 h-2 rounded-full" style="width:33%"></div>
                </div>
              </div>
            </div>
          </div>
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
  // ===== 데이터 (React state 대체) =====
  let selectedPeriod = 'weekly';

  const rankingUsers = [
    { id:'1', name:'Alex Kim',  avatar:'🚴‍♂️', points:15420, distance:340.5, achievements:28, level:12 },
    { id:'2', name:'Sarah Lee', avatar:'🚴‍♀️', points:14880, distance:325.2, achievements:25, level:11 },
    { id:'3', name:'Mike Chen', avatar:'🚴‍♂️', points:13650, distance:298.7, achievements:22, level:10 },
    { id:'4', name:'You',       avatar:'🚴‍♂️', points:12340, distance:267.3, achievements:19, level:9,  isCurrentUser:true },
    { id:'5', name:'Emma Park', avatar:'🚴‍♀️', points:11980, distance:255.8, achievements:18, level:9 }
  ];
  const achievements = [
    { id:'1', title:'First Ride',       description:'Complete your first ride',     icon:'🚴‍♂️', rarity:'common',    unlocked:true  },
    { id:'2', title:'Speed Demon',      description:'Reach 30km/h speed',           icon:'⚡',   rarity:'rare',      unlocked:true  },
    { id:'3', title:'Distance King',    description:'Ride 100km in a week',         icon:'👑',   rarity:'epic',      unlocked:true  },
    { id:'4', title:'Night Rider',      description:'Complete 10 night rides',      icon:'🌙',   rarity:'rare',      unlocked:false },
    { id:'5', title:'Mountain Master',  description:'Climb 1000m elevation',        icon:'🏔️',  rarity:'legendary', unlocked:false },
  ];

  // ===== 유틸 =====
  const esc = s => String(s ?? '').replace(/[&<>"']/g, m=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[m]));
  const rarityBorder = r => ({common:'border-gray-400', rare:'border-blue-400', epic:'border-purple-400', legendary:'border-yellow-400'})[r] || 'border-gray-400';

  function rankIcon(position){
    if (position === 1) return `<i data-lucide="trophy" class="w-8 h-8 text-yellow-400"></i>`;
    if (position === 2) return `<i data-lucide="medal"  class="w-8 h-8 text-gray-400"></i>`;
    if (position === 3) return `<i data-lucide="award"  class="w-8 h-8 text-orange-400"></i>`;
    return `<div class="w-8 h-8 bg-gray-600 rounded-full flex items-center justify-center text-white">${position}</div>`;
  }

  // ===== 렌더 함수 =====
  function renderTabs(){
    const periods = ['daily','weekly','monthly'];
    document.getElementById('periodTabs').innerHTML = periods.map(p => `
        <button data-period="${p}"
          class="px-4 py-2 rounded-lg font-jockey transition-all ${selectedPeriod===p ? 'bg-[var(--brand)] text-black' : 'bg-gray-800 text-white hover:bg-gray-700'}">
          ${p[0].toUpperCase()+p.slice(1)}
        </button>
      `).join('');

    document.querySelectorAll('[data-period]').forEach(btn=>{
      btn.addEventListener('click', ()=>{
        selectedPeriod = btn.getAttribute('data-period');
        renderAll();
      });
    });
  }

  function renderPodium(){
    const u = rankingUsers;
    const html = `
        <!-- 2nd -->
        <div class="flex flex-col items-center">
          <div class="text-6xl mb-2">${esc(u[1].avatar)}</div>
          <div class="text-center mb-4">
            <div class="text-xl text-white">${esc(u[1].name)}</div>
            <div class="text-sm text-gray-300">${u[1].points.toLocaleString()} PTS</div>
          </div>
          <div class="w-24 h-32 bg-gray-700 rounded-t-lg flex flex-col items-center justify-end pb-4">
            <i data-lucide="medal" class="w-12 h-12 text-gray-400 mb-2"></i>
            <div class="text-2xl text-white">2</div>
          </div>
        </div>

        <!-- 1st -->
        <div class="flex flex-col items-center">
          <div class="text-6xl mb-2">${esc(u[0].avatar)}</div>
          <div class="text-center mb-4">
            <div class="text-xl text-white">${esc(u[0].name)}</div>
            <div class="text-sm text-gray-300">${u[0].points.toLocaleString()} PTS</div>
          </div>
          <div class="w-24 h-40 bg-yellow-600 rounded-t-lg flex flex-col items-center justify-end pb-4">
            <i data-lucide="trophy" class="w-12 h-12 text-yellow-400 mb-2"></i>
            <div class="text-2xl text-white">1</div>
          </div>
        </div>

        <!-- 3rd -->
        <div class="flex flex-col items-center">
          <div class="text-6xl mb-2">${esc(u[2].avatar)}</div>
          <div class="text-center mb-4">
            <div class="text-xl text-white">${esc(u[2].name)}</div>
            <div class="text-sm text-gray-300">${u[2].points.toLocaleString()} PTS</div>
          </div>
          <div class="w-24 h-28 bg-orange-600 rounded-t-lg flex flex-col items-center justify-end pb-4">
            <i data-lucide="award" class="w-12 h-12 text-orange-400 mb-2"></i>
            <div class="text-2xl text-white">3</div>
          </div>
        </div>
      `;
    document.getElementById('podium').innerHTML = html;
  }

  function renderList(){
    const html = rankingUsers.map((user, idx)=>`
        <div class="p-4 rounded-lg transition-all ${user.isCurrentUser ? 'bg-[var(--brand)]/20 border-2 border-[var(--brand)]' : 'bg-gray-800 hover:bg-gray-700'}">
          <div class="flex items-center gap-4">
            <div class="flex-shrink-0">${rankIcon(idx+1)}</div>
            <div class="text-3xl">${esc(user.avatar)}</div>
            <div class="flex-1">
              <div class="flex items-center gap-2">
                <span class="font-jockey text-lg">${esc(user.name)}</span>
                ${user.isCurrentUser ? '<span class="text-xs bg-[var(--brand)] text-black px-2 py-1 rounded">YOU</span>' : ''}
              </div>
              <div class="text-sm text-gray-300">Level ${user.level} • ${user.achievements} achievements</div>
            </div>
            <div class="text-right">
              <div class="text-lg text-white">${user.points.toLocaleString()}</div>
              <div class="text-sm text-gray-300">${user.distance}km</div>
            </div>
          </div>
        </div>
      `).join('');
    document.getElementById('rankList').innerHTML = html;
  }

  function renderYourStats(){
    const currentUser = rankingUsers.find(u=>u.isCurrentUser);
    const box = document.getElementById('yourStats');
    if (!currentUser){ box.classList.add('hidden'); return; }

    const rank = rankingUsers.findIndex(u=>u.id===currentUser.id) + 1;
    box.classList.remove('hidden');
    box.innerHTML = `
        <div class="font-jockey text-xl mb-4" style="color:var(--brand)">Your Stats</div>
        <div class="space-y-3">
          <div class="flex items-center gap-3">
            <i data-lucide="trophy" class="w-5 h-5 text-yellow-400"></i>
            <div>
              <div class="text-sm text-gray-300">Rank</div>
              <div class="text-white">#${rank}</div>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <i data-lucide="star" class="w-5 h-5 text-purple-400"></i>
            <div>
              <div class="text-sm text-gray-300">Points</div>
              <div class="text-white">${currentUser.points.toLocaleString()}</div>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <i data-lucide="route" class="w-5 h-5 text-blue-400"></i>
            <div>
              <div class="text-sm text-gray-300">Distance</div>
              <div class="text-white">${currentUser.distance}km</div>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <i data-lucide="trending-up" class="w-5 h-5 text-green-400"></i>
            <div>
              <div class="text-sm text-gray-300">Level</div>
              <div class="text-white">${currentUser.level}</div>
            </div>
          </div>
        </div>
      `;
  }

  function renderAchievements(){
    const html = achievements.map(a=>`
        <div class="p-3 rounded-lg border-2 ${a.unlocked ? rarityBorder(a.rarity)+' bg-white/5' : 'border-gray-600 bg-gray-700 opacity-70'}">
          <div class="flex items-center gap-3">
            <div class="text-2xl">${esc(a.icon)}</div>
            <div class="flex-1">
              <div class="text-sm text-white">${esc(a.title)}</div>
              <div class="text-xs text-gray-300">${esc(a.description)}</div>
            </div>
            ${a.unlocked ? '<div class="text-xs bg-green-600 text-white px-2 py-1 rounded">✓</div>' : ''}
          </div>
        </div>
      `).join('');
    document.getElementById('achievements').innerHTML = html;
  }

  function renderAll(){
    renderTabs();
    renderPodium();
    renderList();
    renderYourStats();
    renderAchievements();
    // 아이콘 초기화
    lucide.createIcons();
  }

  // 초기 렌더
  renderAll();
</script>
</body>
</html>
