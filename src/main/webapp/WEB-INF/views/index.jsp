<%@ page import="kopo.poly.util.CmmUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	String ssUserName = CmmUtil.nvl((String) session.getAttribute("SS_USER_NAME")); // 로그인된 회원 이름
	String ssUserId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));     // 로그인된 회원 아이디
	String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8" />
	<title>RIDING GOAT - Safe Riding Community</title>
	<link href="https://fonts.googleapis.com/css2?family=Creepster&display=swap" rel="stylesheet">

	<style>
		:root{
			--brand:#12d2a0;
			--brand-600:#10b38a;
			--brand-700:#0f9a78;
			--ink:#0b1715;
		}

		*{ box-sizing:border-box; }
		html, body{ margin:0; padding:0; }
		body{
			font-family: 'Segoe UI', sans-serif;
			overflow:hidden;
			position:relative;
			color:#fff;
			background:#000;
		}

		/* ==== 새 네비바 CSS ==== */
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

		/* ==== 배경/본문 ==== */
		.blur-bg {
			position: fixed;
			top: 0; left: 0;
			width: 100%; height: 100%;
			background-image: url('<%= ctx %>/images/화면 캡처 2025-07-10 205810.png.png');
			background-repeat: no-repeat;
			background-position: center center;
			background-attachment: fixed;
			background-size: cover;
			filter: blur(4px);
			z-index: -2;
			transition: background-image 0.4s ease;
		}
		.content { position: relative; z-index: 10; text-align: center; }

		.hero { margin-top: 60px; display: inline-block; }
		.hero h1 {
			font-size: 100px;
			font-family: 'Creepster', cursive;
			letter-spacing: 2px;
		}
		.hero p {
			font-size: 20px;
			font-weight: 300;
			font-family: 'Creepster', cursive;
		}

		.section {
			display:flex; justify-content:center; gap:60px; margin-top:60px;
		}
		.circle-link {
			width:300px; height:300px; border-radius:50%; overflow:hidden;
			border:4px solid #fff; cursor:pointer; transition:transform .4s ease;
		}
		.circle-link:hover { transform: scale(1.05); }
		.circle-link img { width:210%; height:150%; object-fit:cover; }

		.label { margin-top:15px; font-weight:bold; font-size:30px; }
	</style>

	<script>
		window.onload = () => {
			const blurBg = document.querySelector(".blur-bg");
			const content = document.querySelector(".content");

			document.querySelector(".link-map").addEventListener("mouseenter", () => {
				blurBg.style.backgroundImage = `url('<%= ctx %>/images/map-thumbnail.png')`
				content.style.color = "#00ff99"
			});
			document.querySelector(".link-ranking").addEventListener("mouseenter", () => {
				blurBg.style.backgroundImage = `url('<%= ctx %>/images/ranking-thumbnail.png')`
				content.style.color = "#00ff99"
			});
			document.querySelector(".link-community").addEventListener("mouseenter", () => {
				blurBg.style.backgroundImage = `url('<%= ctx %>/images/community-thumbnail.png')`
				content.style.color = "#00ff99"
			});
			document.querySelector(".hero h1").addEventListener("mouseenter", () => {
				blurBg.style.backgroundImage = `url('<%= ctx %>/images/화면 캡처 2025-07-10 205810.png.png')`
				content.style.color = "#FFFFFF"
			});

			// 현재 메뉴 활성화
			(function(){
				var path = location.pathname;
				document.querySelectorAll('.menu a').forEach(function(a){
					var href = a.getAttribute('href');
					if (path === href || (href !== '<%= ctx %>/' && path.startsWith(href))) {
						a.classList.add('active');
					}
				});
			})();
		};
	</script>
</head>
<body>

<!-- 흐릿한 배경 -->
<div class="blur-bg"></div>

<!-- ✅ 새 네비바 -->
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

<!-- 실제 콘텐츠 -->
<div class="content">
	<div class="hero">
		<h1>RIDING GOAT</h1>
		<p>This company makes safe riding custom and community behind <strong>RIDING GOAT</strong>.</p>
	</div>

	<div class="section">
		<div>
			<div class="circle-link link-map" onclick="location.href='<%= ctx %>/map/map'">
				<img src="<%= ctx %>/images/map-thumbnail.png" alt="Dangerous Map" />
			</div>
			<div class="label">Dangerous Map</div>
		</div>
		<div>
			<div class="circle-link link-ranking" onclick="location.href='<%= ctx %>/rank/ranking'">
				<img src="<%= ctx %>/images/ranking-thumbnail.png" alt="Ranking" />
			</div>
			<div class="label">Ranking</div>
		</div>
		<div>
			<div class="circle-link link-community" onclick="location.href='<%= ctx %>/community/community'">
				<img src="<%= ctx %>/images/community-thumbnail.png" alt="Community" />
			</div>
			<div class="label">Community</div>
		</div>
	</div>
</div>

</body>
</html>
