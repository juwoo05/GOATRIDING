<%@ page contentType="text/html; charset=UTF-8" language="java" %>
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

    <!-- 공통 헤더 스타일 -->
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
            min-height:68px;
            display:flex; align-items:center; justify-content:space-between;
        }
        .logo a{
            color:var(--brand);
            text-decoration:none; font-weight:800; letter-spacing:.3px;
            font-size:28px;
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

        .header-spacer{ height:68px; }

        @media (max-width: 640px){
            .site-header .nav{ min-height:60px; padding:0 16px; }
            .header-spacer{ height:60px; }
            .logo a{ font-size:24px; }
            .menu{ gap:16px; font-size:16px; }
            .auth-link{ font-size:16px; }
        }
    </style>

    <!-- 페이지 JS -->
    <script src="${ctx}/js/dangerousMap.js" defer></script>
</head>
<body class="bg-black text-white m-0 p-0">
<!-- ✅ 상단 헤더 -->
<header class="site-header">
    <div class="nav">
        <div class="logo">
            <a href="${ctx}/">RIDING GOAT</a>
        </div>
        <div class="menu">
            <a href="${ctx}/map/map">Dangerous Map</a>
            <a href="${ctx}/ranking">Ranking</a>
            <a href="${ctx}/community/community">Community</a>
        </div>
        <div class="auth-buttons">
            <a href="${ctx}/user/login" class="auth-link">Login</a>
            <a href="${ctx}/user/userRegForm" class="auth-link">Sign Up</a>
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
<div class="relative h-[calc(100vh-56px)] w-screen flex">
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
        <div id="voiceDock"
             class="fixed bottom-3 left-1/2 -translate-x-1/2 z-40 flex flex-col items-center space-y-2">
            <button id="voiceChip"
                    onclick="toggleVoicePanel()"
                    class="hidden fixed bottom-4 right-4 z-50 px-3 py-2 rounded-full bg-emerald-500 hover:bg-emerald-400 text-sm">
                다음: 안내 없음
            </button>
            <div id="voiceList"
                 class="hidden fixed bottom-16 right-4 z-50 w-72 max-h-60 overflow-auto bg-gray-900/90 text-white rounded-lg p-3 shadow">
                <div class="text-sm font-semibold mb-2">안내 목록</div>
                <div id="voiceItems" class="space-y-1 text-xs"></div>
            </div>
        </div>
    </div>

    <!-- 사이드바 -->
    <aside class="relative z-50 w-80 h-[calc(100vh-56px)] p-4 bg-black space-y-6 overflow-y-auto">
        <!-- 경로 검색 -->
        <section class="space-y-2">
            <h2 class="text-xl font-bold text-emerald-400">🚴Navigation (Kakao)</h2>
            <input id="startInput" type="text" placeholder="출발지 검색 (예: 강남역)" class="w-full p-2 rounded text-black"/>
            <input id="endInput"   type="text" placeholder="도착지 검색 (예: 서울역)" class="w-full p-2 rounded text-black"/>
            <div class="flex gap-2">
                <button id="searchStart" class="flex-1 p-2 bg-slate-600 rounded hover:bg-slate-500">출발지 찾기</button>
                <button id="searchEnd"   class="flex-1 p-2 bg-slate-600 rounded hover:bg-slate-500">도착지 찾기</button>
            </div>
            <button onclick="searchRoute()" class="w-full p-2 bg-emerald-500 hover:bg-emerald-400 rounded">경로 탐색</button>
            <p class="text-xs text-gray-400 mt-1">※ 경로를 탐색하면 위험구간이 라인 색상(빨강/주황/초록)으로 표시됩니다.</p>
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

        <!-- 추천 경로 -->
        <section class="space-y-2">
            <h3 class="text-lg font-semibold">추천 경로</h3>
            <button onclick="toggleRoutes()" class="w-full p-2 bg-green-600 hover:bg-green-500 rounded">추천 경로 보기</button>
            <div id="routeList" class="hidden mt-2 space-y-2"></div>
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

<button id="toggleTTSBtn" type="button">음성안내: 켜짐</button>
<script>
    // 간단 토글 스텁 (버튼 동작만 처리)
    window.toggleTTS = function(btn){
        try{
            const on = btn.textContent.includes('켜짐');
            btn.textContent = on ? '음성안내: 꺼짐' : '음성안내: 켜짐';
        }catch(_){}
    };
    document.getElementById('toggleTTSBtn')?.addEventListener('click', e => toggleTTS(e.currentTarget));
</script>
</body>
</html>
