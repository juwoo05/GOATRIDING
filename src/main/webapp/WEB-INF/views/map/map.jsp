<%@ page import="kopo.poly.util.CmmUtil" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String ssUserName = CmmUtil.nvl((String) session.getAttribute("SS_USER_NAME")); // 로그인된 회원 이름
    String ssUserId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));     // 로그인된 회원 아이디
    String ctx = request.getContextPath();
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko" data-context-path="${ctx}">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>RIDING GOAT • Dangerous Map</title>

    <link rel="icon" href="data:,">
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Kakao SDK (services, autoload=false) -->
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoJsKey}&libraries=services&autoload=false"></script>

    <!-- 서버 JSON 주입 안전 처리 -->
    <script>
        (function () {
            try { window.dangerousAreas = JSON.parse('<c:out value="${dangerousAreasJson}" escapeXml="false"/>' ); }
            catch (e) { window.dangerousAreas = []; }

            try { window.recommendedRoutes = JSON.parse('<c:out value="${recommendedRoutesJson}" escapeXml="false"/>' ); }
            catch (e) { window.recommendedRoutes = []; }

            window.KAKAO_REST_KEY = '<c:out value="${kakaoMobilityRestKey}"/>';
        })();
    </script>

    <!-- ✅ GraphHopper Cloud API 키 (복붙) -->
    <script>
        window.GH_API_KEY = 'fa1e749c-b3a6-44b9-b4b6-ff180acfc769';
    </script>

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


    <!-- 페이지 JS (메인 지도 로직) -->
    <script src="${ctx}/js/dangerousMap.js" defer></script>

    <style>
        /* 추천 목록 컨테이너 */
        .place-suggest {
            position: absolute;
            left: 0; right: 0; top: 100%;
            margin-top: 6px;
            background: rgba(17,24,39,.98); /* slate-900 비슷 */
            border: 1px solid rgba(255,255,255,.08);
            border-radius: 10px;
            box-shadow: 0 10px 24px rgba(0,0,0,.35);
            z-index: 2000;
            max-height: 300px;
            overflow-y: auto;
        }
        .place-suggest.hidden { display: none; }
        .place-suggest-item {
            padding: 10px 12px;
            display: grid;
            grid-template-columns: 20px 1fr;
            gap: 8px;
            color: #e5e7eb; /* text-gray-200 */
            cursor: pointer;
        }
        .place-suggest-item:hover, .place-suggest-item.active {
            background: rgba(255,255,255,.06);
        }
        .place-suggest-title { font-weight: 700; font-size: 13px; line-height: 1.2; }
        .place-suggest-addr  { font-size: 12px; color: #cbd5e1; } /* text-slate-300 */
        .place-suggest-icon  { align-self: center; opacity: .85; }
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

<body class="bg-black text-white m-0 p-0">
<!-- ✅ 상단 헤더 -->
<header class="site-header">
    <div class="nav">
        <div class="logo">
            <a href="<%= ctx %>/">RIDING GOAT</a>
        </div>

        <nav class="menu">
            <a href="<%= ctx %>/map/map">Dangerous Map</a>
            <a href="<%= ctx %>/rank/ranking">Ranking</a>
            <a href="<%= ctx %>/community/community">Community</a>
        </nav>

        <div class="auth-buttons">
            <% if (ssUserId.equals("")) { %>
            <a href="<%= ctx %>/user/login" class="auth-link">Login</a>
            <a href="<%= ctx %>/user/userRegForm" class="auth-link">Sign Up</a>
            <% } else { %>
            <a href="<%= ctx %>/user/myPage" class="auth-link"><%= ssUserName %></a>
            <a href="<%= ctx %>/user/logout" class="auth-link">Logout</a>
            <% } %>
        </div>
    </div>
</header>
<div class="header-spacer"></div>

<!-- 현재 메뉴 활성화 표시 -->
<script>
    (function(){
        var path = location.pathname;
        document.querySelectorAll('.menu a').forEach(function(a){
            var href = a.getAttribute('href');
            if (path === href || (href !== '${ctx}/' && path.startsWith(href))) {
                a.classList.add('active');
            }
        });
    })();
</script>

<!-- 전체 레이아웃 -->
<div class="relative h-[calc(100vh-68px)] w-screen flex">
    <!-- 지도 -->
    <div class="relative flex-1">
        <div id="map" class="absolute inset-0 m-4 w-full h-full rounded-lg shadow-lg z-0"></div>

        <!-- 경로 이탈 경고 (JS가 상단 pill로 스타일 적용) -->
        <div id="offRouteWarning" class="hidden z-50 text-center font-bold px-4 py-2 rounded-full">
            경로에서 벗어났습니다.
            <button onclick="handleReroute()" class="ml-2 underline">재경로</button>
            <button onclick="stopNavigation()" class="ml-2 underline">중지</button>
        </div>

        <!-- 하단 도크(음성 안내) -->
        <!-- 하단 도크(음성 안내) -->
        <div id="voiceDock"
             class="fixed bottom-3 left-1/2 -translate-x-1/2 z-40 flex flex-col items-center space-y-2">

            <!-- 가로형 칩 -->
            <button id="voiceChip"
                    onclick="toggleVoicePanel()"
                    class="hidden fixed bottom-4 right-4 z-50 px-4 py-2 rounded-full bg-emerald-500 hover:bg-emerald-400 text-sm shadow-lg">
                다음: 안내 없음
            </button>

            <!-- 목록 -->
            <div id="voiceList"
                 class="hidden fixed bottom-16 right-4 z-50 w-72 max-h-60 overflow-auto bg-gray-900/90 text-white rounded-lg p-3 shadow">
                <div class="text-sm font-semibold mb-2">안내 목록</div>
                <div id="voiceItems" class="space-y-1 text-xs"></div>
            </div>
        </div>

        <!-- 가로 고정 CSS(세로쓰기/회전 방지) -->
        <style>
            #voiceChip{
                writing-mode: horizontal-tb !important;
                transform: none !important;
                rotate: 0deg !important;
                white-space: nowrap;
            }
        </style>

    </div>

    <!-- 사이드바 -->
    <aside class="relative z-50 w-80 h-[calc(100vh-68px)] p-4 bg-black space-y-6 overflow-y-auto">

        <!-- 경로 검색 -->
        <section class="space-y-2">
            <h2 class="text-xl font-bold text-emerald-400">🚴 Navigation (Kakao)</h2>
            <input id="startInput" type="text" placeholder="출발지 검색 (예: 강남역)" class="w-full p-2 rounded text-black"/>
            <input id="endInput"   type="text" placeholder="도착지 검색 (예: 서울역)" class="w-full p-2 rounded text-black"/>
            <div class="flex gap-2">
                <button id="searchStart" class="flex-1 p-2 bg-slate-600 rounded hover:bg-slate-500">출발지 찾기</button>
                <button id="searchEnd"   class="flex-1 p-2 bg-slate-600 rounded hover:bg-slate-500">도착지 찾기</button>
            </div>

            <!-- 기존: 카카오 길찾기 -->
            <button onclick="searchRoute()" class="w-full p-2 bg-emerald-500 hover:bg-emerald-400 rounded">
                경로 탐색
            </button>

            <!-- ✅ 추가: GraphHopper Cloud (자전거) -->
            <button onclick="searchBikeRouteGHCloud()" class="w-full mt-2 p-2 bg-blue-600 hover:bg-blue-500 rounded">
                자전거길로 탐색
            </button>
            <p class="text-xs text-gray-400 mt-1">
                GraphHopper(bike)로 자전거 우선 경로를 계산합니다. 탐색 후 위험구간 색상(빨강/주황/초록) 자동 표시.
            </p>
        </section>

        <!-- 현재 위치 -->
        <section class="space-y-2">
            <h3 class="text-lg font-semibold">Current Location</h3>
            <p class="text-sm">시간: <span id="time">-</span></p>
            <button id="gpsToggleBtn"
                    onclick="toggleGPSTrack(this)"
                    class="w-full p-2 bg-teal-500 hover:bg-teal-400 rounded">
                위치 추적 시작
            </button>
            <button onclick="recenterToMe()" class="w-full p-2 bg-slate-600 hover:bg-slate-500 rounded">
                내 위치로 이동
            </button>
        </section>

        <!-- ✅ 가상 주행 -->
        <section class="space-y-2">
            <h3 class="text-lg font-semibold">가상 주행 (시뮬레이터)</h3>
            <div class="flex items-center gap-2">
                <label class="text-sm text-gray-300">속도</label>
                <select id="simSpeed" class="flex-1 p-2 rounded text-black">
                    <option value="10">10 km/h</option>
                    <option value="15" selected>15 km/h</option>
                    <option value="20">20 km/h</option>
                    <option value="25">25 km/h</option>
                    <option value="30">30 km/h</option>
                </select>
            </div>
            <div class="flex gap-2">
                <button id="simStartBtn" class="flex-1 p-2 bg-indigo-600 hover:bg-indigo-500 rounded" onclick="startVirtualRide()">시작</button>
                <button id="simPauseBtn" class="p-2 bg-slate-600 hover:bg-slate-500 rounded" onclick="pauseVirtualRide()" disabled>일시정지</button>
                <button id="simStopBtn" class="p-2 bg-rose-600 hover:bg-rose-500 rounded" onclick="stopVirtualRide()" disabled>정지</button>
            </div>
            <p class="text-xs text-gray-400">경로가 없으면 출발·도착으로 먼저 탐색해 주세요. 아이콘은 진행방향으로 회전합니다.</p>
        </section>

        <!-- Popular Routes (큰 카드) -->
        <section class="space-y-3">
            <div class="font-bold text-emerald-400 text-xl">Popular Routes</div>
            <div id="popularRoutes" class="space-y-3"></div>
        </section>

        <!-- GPX 업로드 -->
        <section class="space-y-2">
            <h3 class="text-lg font-semibold">GPX 업로드</h3>

            <!-- ❗한 줄 고정 + 간격 -->
            <form id="uploadForm" class="flex flex-nowrap items-center gap-2">
                <!-- ❗줄어들 수 있게: min-w-0 flex-1 -->
                <input
                        type="file"
                        id="gpxInput"
                        accept=".gpx"
                        class="min-w-0 flex-1 text-sm
             file:mr-3 file:px-3 file:py-2 file:rounded
             file:bg-slate-700 file:text-white" />

                <!-- ❗버튼은 줄어들지 않게: shrink-0 -->
                <button
                        id="uploadBtn"
                        type="button"
                        class="shrink-0 px-3 py-2 bg-slate-600 hover:bg-slate-500 rounded">
                    업로드
                </button>
            </form>

            <p class="text-xs text-gray-400">업로드 후 목록이 자동 갱신됩니다.</p>
        </section>


        <!-- 위험지역 -->
        <section class="space-y-2">
            <h3 class="text-lg font-semibold">주변 위험지역</h3>
            <div class="flex gap-2">
                <button onclick="loadDangerousAreasFromDb()"
                        class="flex-1 p-2 bg-rose-600 hover:bg-rose-500 rounded">
                    DB에서 불러오기
                </button>
            </div>
            <div id="dangerousAreaList" class="space-y-1 text-sm text-gray-300"></div>

            <!-- 범례: 라인 스와치 (경로 색과 동일) -->
            <div class="flex gap-3 text-xs text-gray-400 mt-1 items-center">
                <div class="flex items-center gap-1">
                    <span style="display:inline-block;width:22px;height:3px;border-radius:2px;background:#ef4444;border:1px solid #111"></span> high
                </div>
                <div class="flex items-center gap-1">
                    <span style="display:inline-block;width:22px;height:3px;border-radius:2px;background:#f59e0b;border:1px solid #111"></span> medium
                </div>
                <div class="flex items-center gap-1">
                    <span style="display:inline-block;width:22px;height:3px;border-radius:2px;background:#22c55e;border:1px solid #111"></span> low
                </div>
            </div>
        </section>
    </aside>
</div>

<style>
    /* (구) 흰색 오버레이 텍스트 보정 스타일 - 필요 시 유지 */
    .rg-map-iw {
        background:#fff; color:#111 !important;
        border:1px solid rgba(0,0,0,.15);
        border-radius:8px;
        padding:8px 10px;
        max-width:280px;
        box-shadow:0 6px 16px rgba(0,0,0,.18);
        font: 12px/1.45 "Noto Sans KR", system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
        word-break:keep-all; white-space:normal;
    }
    .rg-map-iw *{ color:#111 !important; }
    .rg-map-iw .title{ font-weight:700; font-size:13px; margin:2px 0 6px; }
    .rg-map-iw .meta{ margin:0; padding:0; list-style:none; }
    .rg-map-iw .meta li{ display:flex; align-items:center; gap:6px; margin:2px 0; font-size:12px; color:#555 !important; }
    .rg-map-iw .badge{
        display:inline-block; padding:1px 6px; border-radius:9999px;
        font-size:11px; font-weight:700; color:#fff !important;
    }
    .rg-map-iw.risk-high   .badge{ background:#ef4444; }
    .rg-map-iw.risk-medium .badge{ background:#f59e0b; }
    .rg-map-iw.risk-low    .badge{ background:#22c55e; }
    .rg-map-iw .incidents{ font-weight:800; color:#111 !important; }

    /* 응급 패치(파란 헤더 케이스 보정) */
    #map .wrap .info, #map .wrap .info * { color:#111 !important; }
    #map .wrap .title{ background:#fff !important; color:#111 !important; border-bottom:1px solid #e5e7eb !important; }
</style>

<!-- 음성 안내 간단 토글 -->
<button id="toggleTTSBtn" type="button" class="hidden">음성안내: 켜짐</button>
<script>
    window.toggleTTS = function(btn){
        try{
            const on = btn.textContent.includes('켜짐');
            btn.textContent = on ? '음성안내: 꺼짐' : '음성안내: 켜짐';
        }catch(_){}
    };
    document.getElementById('toggleTTSBtn')?.addEventListener('click', function(e){ toggleTTS(e.currentTarget); });
</script>

<!-- 업로드 (EL-safe) -->
<script>
    (function(){
        const ctx = document.documentElement.getAttribute('data-context-path') || '';
        const $ = function(id){ return document.getElementById(id); };

        $('uploadBtn')?.addEventListener('click', async function () {
            const fileInput = $('gpxInput');
            const file = (fileInput && fileInput.files && fileInput.files[0]) ? fileInput.files[0] : null;
            if (!file) { alert('GPX 파일을 선택하세요.'); return; }

            const fd = new FormData();
            fd.append('gpxFile', file);

            try {
                const res = await fetch(ctx + '/routes/upload', { method:'POST', body: fd });
                if (!res.ok) {
                    const text = await res.text().catch(function(){ return ''; });
                    throw new Error('업로드 실패 (' + res.status + ') ' + text);
                }
                const json = await res.json().catch(function(){ return {}; });
                alert('업로드 완료 (routeId=' + (json.routeId ?? '?') + ')');
                if (typeof window.refreshPopularRoutes === 'function') window.refreshPopularRoutes();
            } catch (e) {
                console.error(e);
                alert('업로드 실패: ' + e.message);
            }
        });
    })();
</script>

<!-- Popular Routes 큰 카드 렌더링 (EL-safe) -->
<script>
    (function(){
        const ctx = document.documentElement.getAttribute('data-context-path') || '';

        function _basename(name, fileName){
            const raw = (fileName && String(fileName)) || (name && String(name)) || '';
            try { return decodeURIComponent(raw); } catch { return raw; }
        }
        function _ratingById(id){
            const x = ((Number(id)||1) * 9301 + 49297) % 233280;
            return (4.2 + (x/233280)*0.7).toFixed(1);
        }
        function formatKm(v){
            if (v == null) return '— km';
            const n = Number(v);
            return (Number.isFinite(n) ? n.toFixed(1) : '—') + ' km';
        }
        function formatDur(min){
            const n = Number(min);
            if (!Number.isFinite(n)) return '—';
            const h = Math.floor(n/60), m = n%60;
            return (h? (h+'시간 ') : '') + m + '분';
        }
        function starSvg(size){
            size = size || 20;
            return '<svg width="' + size + '" height="' + size + '" viewBox="0 0 24 24" fill="#facc15" stroke="#facc15" stroke-width="1.5"><path d="M12 17.27 18.18 21l-1.64-7.03L22 9.24l-7.19-.62L12 2 9.19 8.62 2 9.24l5.46 4.73L5.82 21z"/></svg>';
        }

        async function renderPopularRoutesBig(limit){
            limit = limit || 10;
            const box = document.getElementById('popularRoutes');
            if (!box) return;
            box.innerHTML = '<div class="text-sm text-gray-400">불러오는 중…</div>';

            try{
                const res = await fetch(ctx + '/routes/list');
                const data = await res.json();

                if (!Array.isArray(data) || !data.length){
                    box.innerHTML = '<div class="text-sm text-gray-400">등록된 경로가 없습니다.</div>';
                    return;
                }

                box.innerHTML = '';
                data.slice(0, limit).forEach(function(r){
                    const title   = _basename(r.name, r.fileName);
                    const distTxt = formatKm(r.distKm);
                    const durTxt  = formatDur(r.durationMin);
                    const rating  = _ratingById(r.routeId);

                    const el = document.createElement('button');
                    el.type = 'button';
                    el.className = 'w-full text-left bg-slate-800/90 hover:bg-slate-700/90 border border-slate-600 rounded-xl px-4 py-3 flex items-center justify-between gap-3 shadow';
                    el.innerHTML =
                        '<div class="min-w-0">' +
                        '<div class="text-[15px] md:text-base font-bold truncate">' + title + '</div>' +
                        '<div class="text-[12px] md:text-sm text-slate-300">' + distTxt + ' · ' + durTxt + '</div>' +
                        '</div>' +
                        '<div class="flex items-center gap-1 shrink-0">' +
                        starSvg(18) + '<span class="text-sm">' + rating + '</span>' +
                        '</div>';

                    el.addEventListener('click', function(){
                        if (window.drawServerRoute) window.drawServerRoute(r.routeId);
                    });
                    box.appendChild(el);
                });
            }catch(e){
                console.error(e);
                box.innerHTML = '<div class="text-sm text-rose-400">로드 실패: ' + (e.message||'') + '</div>';
            }
        }

        // 외부에서 호출 가능 (업로드 후 갱신)
        window.refreshPopularRoutes = function(){ renderPopularRoutesBig(10); };

        // 초기 렌더
        window.addEventListener('DOMContentLoaded', function(){ renderPopularRoutesBig(10); });
        window.addEventListener('load', function(){ setTimeout(function(){ renderPopularRoutesBig(10); }, 500); });
    })();
</script>
<script>
    // ── 작은 유틸
    function debounce(fn, ms){ let t; return (...a)=>{ clearTimeout(t); t=setTimeout(()=>fn(...a), ms); }; }

    // DOM 유틸: 엘 바로 아래 절대 위치 컨테이너 보장
    function ensureSuggestHost(input){
        // 래퍼를 relative로 바꾸고, 목록용 div를 넣는다.
        let wrap = input.parentElement;
        if (!wrap) wrap = input;
        if (getComputedStyle(wrap).position === 'static') wrap.style.position = 'relative';

        let list = wrap.querySelector('.place-suggest');
        if (!list){
            list = document.createElement('div');
            list.className = 'place-suggest hidden';
            wrap.appendChild(list);
        }
        return list;
    }

    // 카카오 place → 리스트 렌더
    function renderSuggest(listEl, places){
        if (!Array.isArray(places) || !places.length){
            listEl.innerHTML = '<div class="place-suggest-item" style="cursor:default;opacity:.7">결과 없음</div>';
            return [];
        }
        listEl.innerHTML = places.map((p,i)=>`
      <div class="place-suggest-item" data-idx="${i}">
        <div class="place-suggest-icon">📍</div>
        <div>
          <div class="place-suggest-title">${p.place_name || ''}</div>
          <div class="place-suggest-addr">${p.road_address_name || p.address_name || ''}</div>
        </div>
      </div>
    `).join('');
        return Array.from(listEl.querySelectorAll('.place-suggest-item'));
    }

    // 메인: 입력창에 자동완성 붙이기
    function setupPlaceAutocomplete(selector){
        const input = document.querySelector(selector);
        if (!input) return console.warn('setupPlaceAutocomplete: not found', selector);
        const listEl = ensureSuggestHost(input);

        let items = [];     // 현재 렌더된 항목 DOM 배열
        let data  = [];     // kakao 원본 데이터
        let active = -1;    // 키보드 선택 인덱스

        const open  = ()=> listEl.classList.remove('hidden');
        const close = ()=> { listEl.classList.add('hidden'); active=-1; };

        // 결과 선택 처리
        function choose(idx){
            if (idx < 0 || idx >= data.length) return;
            const p = data[idx];
            // 입력창 채우고 dataset에 좌표 저장
            input.value = p.place_name || input.value;
            input.dataset.lat = p.y;
            input.dataset.lng = p.x;
            close();
            // 포커스 유지 시 엔터 탐색 가능
            input.dispatchEvent(new CustomEvent('place:chosen', { detail: { lat:+p.y, lng:+p.x, name:p.place_name } }));
        }

        // 검색 (디바운스)
        const doSearch = debounce((q)=>{
            if (!q || q.trim().length < 1){ close(); return; }
            if (!window.kakao || !window.kakao.maps || !window.kakao.maps.services || !window.kakao.maps.services.Status){
                console.warn('Kakao Places not ready'); return;
            }
            // kakaoPlaces는 기존 코드에서 전역으로 만든 객체 재사용
            (window.kakaoPlaces || new kakao.maps.services.Places()).keywordSearch(q, (res, status)=>{
                if (status !== kakao.maps.services.Status.OK){ data=[]; items=[]; renderSuggest(listEl,[]); open(); return; }
                data = res.slice(0,7); // 상위 7개만
                items = renderSuggest(listEl, data);
                open();
            }, { size: 10 });
        }, 220);

        // 입력 이벤트
        input.addEventListener('input', (e)=>{
            const q = e.target.value;
            input.removeAttribute('data-lat');
            input.removeAttribute('data-lng');
            doSearch(q);
        });

        // 포커스 시 최근 결과 노출
        input.addEventListener('focus', ()=>{
            if (listEl.innerHTML.trim()) open();
        });


        // 항목 클릭
        listEl.addEventListener('click', (e)=>{
            const el = e.target.closest('.place-suggest-item');
            if (!el) return;
            const idx = +el.getAttribute('data-idx');
            choose(idx);
        });

        // 바깥 클릭 닫기
        document.addEventListener('click', (e)=>{
            if (e.target === input || listEl.contains(e.target)) return;
            close();
        });
    }

    // ── 사용: kakao 초기화 이후 한 번만 호출 ──
    // 예) initKakao() 맨 끝에 아래 두 줄 추가
    // setupPlaceAutocomplete('#startInput');
    // setupPlaceAutocomplete('#endInput');
</script>

<script>
    kakao.maps.load(function () {
        // 전역 재사용 객체
        window.kakaoPlaces = new kakao.maps.services.Places();

        // 자동완성 바인딩
        setupPlaceAutocomplete('#startInput');
        setupPlaceAutocomplete('#endInput');
    });
</script>

</body>
</html>
