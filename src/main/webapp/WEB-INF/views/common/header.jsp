<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="kopo.poly.util.CmmUtil" %>

<%
    String ctx = request.getContextPath();
    String ssUserId   = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));
    String ssUserName = CmmUtil.nvl((String) session.getAttribute("SS_USER_NAME"));
%>

<!-- ✅ 공통 상단 헤더 -->
<header class="site-header">
    <div class="nav">
        <!-- 로고 -->
        <div class="logo">
            <a href="<%=ctx%>/" class="font-jockey">RIDING GOAT</a>
        </div>

        <!-- 메뉴 -->
        <div class="menu">
            <a href="<%=ctx%>/map/map"
               class="${pageContext.request.requestURI.contains('/map') ? 'active' : ''}">
               Dangerous Map</a>
            <a href="<%=ctx%>/rank/ranking"
               class="${pageContext.request.requestURI.contains('/rank') ? 'active' : ''}">
               Ranking</a>
            <a href="<%=ctx%>/community/community"
               class="${pageContext.request.requestURI.contains('/community') ? 'active' : ''}">
               Community</a>
        </div>

        <!-- 로그인 / 로그아웃 -->
        <div class="auth-buttons">
            <% if (ssUserId.equals("")) { %>
            <!-- 로그인 안됨 -->
            <a href="<%=ctx%>/user/login" class="auth-link">Login</a>
            <a href="<%=ctx%>/user/userRegForm" class="auth-link">Sign Up</a>
            <% } else { %>
            <!-- 로그인 됨 -->
            <a href="<%=ctx%>/user/myPage" class="auth-link flex items-center gap-2">
                <c:choose>
                    <c:when test="${not empty user and not empty user.profileImage}">
                        <img src="${user.profileImage}"
                             class="w-8 h-8 rounded-full border border-gray-400 object-cover"/>
                    </c:when>
                    <c:otherwise>
                        <img src="${ctx}/images/default.png"
                             class="w-8 h-8 rounded-full border border-gray-400 object-cover"/>
                    </c:otherwise>
                </c:choose>
                <span><%= ssUserName %></span>
            </a>
            <a href="<%=ctx%>/user/logout" class="auth-link">Logout</a>
            <% } %>
        </div>
    </div>
</header>

<div class="header-spacer"></div>

<!-- ✅ 헤더 & 페이지별 스타일 -->
<style>
    :root{ --brand:#12d2a0; }

    .font-jockey{ font-family:'Jockey One', sans-serif; }

    /* 헤더 스타일 */
    .site-header{
        position:fixed; top:0; left:0; right:0;
        background:#0b1715;
        border-bottom:1px solid rgba(255,255,255,.12);
        color:#fff; z-index:1000;
        backdrop-filter:blur(6px);
    }
    .site-header .nav{
        max-width:1280px; margin:0 auto; padding:0 16px; height:68px;
        display:flex; align-items:center; justify-content:space-between;
    }
    .logo a{
        font-family:'Jockey One', sans-serif;
        color:var(--brand); font-weight:800;
        text-decoration:none; font-size:26px;
        letter-spacing:.5px;
    }
    .menu{
        display:flex; gap:32px;
        font-weight:700; font-size:18px;
    }
    .menu a{
        color:#fff; text-decoration:none; opacity:.85; transition:.2s ease;
    }
    .menu a:hover{ opacity:1; }
    .menu a.active{ color:var(--brand); }
    .auth-buttons{
        display:flex; gap:18px; align-items:center;
    }
    .auth-link{
        color:#fff; text-decoration:none; font-weight:700; opacity:.9;
        display:flex; align-items:center; gap:6px;
    }
    .auth-link:hover{ opacity:1; }
    .auth-buttons img {
        width: 32px; height: 32px;
        border-radius: 50%; object-fit: cover;
    }
    .header-spacer{ height:68px; }

    /* ✅ 페이지별 배경 (body class로 제어) */
    body.page-index::before,
    body.page-ranking::before,
    body.page-map::before,
    body.page-mypage::before {
        content:"";
        position:fixed; inset:0;
        background-repeat:no-repeat;
        background-position:center;
        background-attachment:fixed;
        background-size:cover;
        filter:blur(8px) brightness(.6);
        z-index:-1;
    }
    body.page-index::before {
        background-image:url('<%= ctx %>/images/home-thumbnail.png');
    }
    body.page-ranking::before {
        background-image:url('<%= ctx %>/images/ranking-thumbnail.png');
    }
    body.page-map::before {
        background-image:url('<%= ctx %>/images/map-thumbnail.png');
    }
    body.page-mypage::before {
        background-image:url('<%= ctx %>/images/mypage-thumbnail.png');
    }
</style>
<style>
    /* Ranking 페이지만 헤더 레이아웃 오버라이드 */
    .page-ranking .site-header{
        background:#0b1715;          /* 기존 톤 유지 */
        border-bottom:1px solid rgba(255,255,255,.12);
        backdrop-filter:blur(6px);
    }
    .page-ranking .site-header .nav{
        /* 폭 제한 해제 + 좌우 패딩 확보 */
        max-width: none !important;
        width: 100%;
        padding-left: clamp(16px, 3vw, 32px);
        padding-right: clamp(16px, 3vw, 32px);

        /* 좌-중-우 넓게 벌어지도록 */
        display:flex;
        align-items:center;
        justify-content: space-between !important;
        gap: clamp(12px, 3vw, 40px);
    }

    /* 가운데 메뉴는 가변폭으로 중앙 정렬 */
    .page-ranking .menu{
        flex: 1 1 auto !important;
        display:flex;
        justify-content: center !important;
        gap: clamp(16px, 3vw, 40px);
        font-weight:700;
        font-size:18px;
        flex-wrap:wrap;
    }

    /* 우측 버튼은 맨 오른쪽으로 밀착 */
    .page-ranking .auth-buttons{
        margin-left: auto !important;
        display:flex;
        gap:18px;
    }

    /* 작은 화면에서도 답답하지 않게 */
    @media (max-width: 640px){
        .page-ranking .site-header .nav{
            min-height:60px;
            padding-left:16px; padding-right:16px;
        }
        .page-ranking .menu{ gap:16px; font-size:16px; }
    }
</style>

