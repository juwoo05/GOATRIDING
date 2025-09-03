<%@ page import="kopo.poly.util.CmmUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
	String ssUserName = CmmUtil.nvl((String) session.getAttribute("SS_USER_NAME")); // 로그인된 회원 이름
	String ssUserId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID")); // 로그인된 회원 아이디
%>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8" />
	<title>RIDING GOAT - Safe Riding Community</title>
	<link href="https://fonts.googleapis.com/css2?family=Creepster&display=swap" rel="stylesheet">
	<style>
		body {
			margin: 0;
			padding: 0;
			font-family: 'Segoe UI', sans-serif;
			overflow: hidden;
			position: relative;
		}

		/* 흐릿한 배경 */
		.blur-bg {
			position: fixed;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			background-image: url('/images/화면 캡처 2025-07-10 205810.png.png');
			background-repeat: no-repeat;
			background-position: center center;
			background-attachment: fixed;
			background-size: cover;
			filter: blur(4px);
			z-index: -2;
			transition: background-image 0.4s ease;
		}

		.content {
			position: relative;
			z-index: 10;
			color: white;
			text-align: center;
		}

		.nav {
			position: fixed;
			top: 0;
			width: 100%;
			padding: 15px 30px;
			background: rgba(0, 0, 0, 0.9);
			display: flex;
			justify-content: space-between;
			align-items: center;
			z-index: 999;
		}

		.nav .logo a {
			color: #00ff99;
			font-weight: bold;
			font-size: 20px;
			text-decoration: none;
		}

		.nav .menu a {
			margin: 0 15px;
			color: white;
			text-decoration: none;
			font-weight: bold;
		}

		.menu {
			margin-right: 40px;
		}

		.auth-buttons {
			margin-left: 20px;
			display: flex;
			gap: 15px;
		}

		.auth-link {
			color: #ffffff;
			text-decoration: none;
			font-weight: bold;
			transition: color 0.3s ease;
		}

		.auth-link:hover {
			color: #00ff99;
		}

		.hero {
			margin-top: 100px;
			display: inline-block;
		}

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
			display: flex;
			justify-content: center;
			gap: 60px;
			margin-top: 60px;
		}

		.circle-link {
			width: 300px;
			height: 300px;
			border-radius: 50%;
			overflow: hidden;
			border: 4px solid white;
			cursor: pointer;
			transition: transform 0.4s ease;
		}

		.circle-link:hover {
			transform: scale(1.05);
		}

		.circle-link img {
			width: 210%;
			height: 150%;
			object-fit: cover;
		}

		.label {
			margin-top: 15px;
			font-weight: bold;
			font-size: 30px;
		}
	</style>

	<script>
		window.onload = () => {
			const blurBg = document.querySelector(".blur-bg");
			const content = document.querySelector(".content");

			// 각 버튼에 이벤트 추가
			document.querySelector(".link-map").addEventListener("mouseenter", () => {
				blurBg.style.backgroundImage = `url('/images/map-thumbnail.png')`
				content.style.color = "#00ff99"
			});

			document.querySelector(".link-ranking").addEventListener("mouseenter", () => {
				blurBg.style.backgroundImage = `url('/images/ranking-thumbnail.png')`
				content.style.color = "#00ff99"
			});

			document.querySelector(".link-community").addEventListener("mouseenter", () => {
				blurBg.style.backgroundImage = `url('/images/community-thumbnail.png')`
				content.style.color = "#00ff99"
			});

			document.querySelector(".hero h1").addEventListener("mouseenter", () => {
				blurBg.style.backgroundImage = `url('/images/화면 캡처 2025-07-10 205810.png.png')`
				content.style.color = "#FFFFFF"
			});

		};
	</script>
</head>
<body>

<!-- 흐릿한 배경 -->
<div class="blur-bg"></div>

<!-- 실제 콘텐츠 -->
<div class="content">
	<div class="nav">
		<div class="logo">
			<a href="/">RIDING GOAT</a>
		</div>
		<div class="menu">
			<a href="/map/map">Dangerous Map</a>
			<a href="/rank/ranking">Ranking</a>
			<a href="/community/community">Community</a>
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

	<div class="hero">
		<h1>RIDING GOAT</h1>
		<p>This company makes safe riding custom and community behind <strong>RIDING GOAT</strong>.</p>
	</div>

	<div class="section">
		<div>
			<div class="circle-link link-map" onclick="location.href='/map/map'">
				<img src="/images/map-thumbnail.png" alt="Dangerous Map" />
			</div>
			<div class="label">Dangerous Map</div>
		</div>
		<div>
			<div class="circle-link link-ranking" onclick="location.href='/rank/ranking'">
				<img src="/images/ranking-thumbnail.png" alt="Ranking" />
			</div>
			<div class="label">Ranking</div>
		</div>
		<div>
			<div class="circle-link link-community" onclick="location.href='/community/community'">
				<img src="/images/community-thumbnail.png" alt="Community" />
			</div>
			<div class="label">Community</div>
		</div>
	</div>
</div>

</body>
</html>