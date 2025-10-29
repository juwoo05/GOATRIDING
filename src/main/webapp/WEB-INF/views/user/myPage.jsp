<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="kopo.poly.util.CmmUtil" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%
    String ctx = request.getContextPath();

    // ✅ 세션 변수 선언 (널 방지)
    String ssUserId   = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID"));
    String ssUserName = CmmUtil.nvl((String) session.getAttribute("SS_USER_NAME"));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>RIDING GOAT • MyPage</title>

    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Jockey+One&family=Paytone+One&display=swap" rel="stylesheet"/>

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

    <!-- 헤더 스타일 -->
    <style>
        :root{ --brand:#12d2a0; --ink:#0b1715; }
        *{ box-sizing:border-box; }
        html, body{ margin:0; padding:0; }
        body{ overflow-x:hidden; color:#fff; font-family:'Jockey One', sans-serif; }
        .site-header{ position:fixed; top:0; left:0; right:0; color:#fff; z-index:1000; background:#0b1715;
            border-bottom:1px solid rgba(255,255,255,.12); backdrop-filter:blur(6px); }
        .site-header .nav{ width:100%; margin:0 auto; padding:0 clamp(16px,3vw,32px); min-height:68px;
            display:flex; align-items:center; justify-content:space-between; }
        .logo a{ color:var(--brand); text-decoration:none; font-weight:800; letter-spacing:.3px; font-size:28px; }
        .menu{ flex:1; display:flex; justify-content:center; gap:clamp(16px,3vw,40px); font-weight:700; font-size:18px; flex-wrap:wrap; }
        .menu a{ color:#fff; text-decoration:none; opacity:.95; transition:.15s; white-space:nowrap; }
        .menu a:hover{ opacity:1; }
        .menu a.active{ color:var(--brand); }
        .auth-buttons{ display:flex; gap:18px; }
        .auth-link{ color:#fff; text-decoration:none; font-weight:700; opacity:.95; font-size:18px; }
        .auth-link:hover{ opacity:1; }
        .header-spacer{ height:68px; }
    </style>

    <script src="${ctx}/js/jquery-3.6.0.min.js"></script>
    <script>
        (function(){
            const $file = $('#profileFile');
            const $btn  = $('#btnProfileUpload');

            function toast(msg){ alert(msg); } // 간단 토스트

            async function presignAndUpload(file){
                if(!file){ toast('파일을 선택해 주세요.'); return; }

                // 1) presign 요청: contentType을 그대로 전달
                const pre = await $.ajax({
                    url: '${ctx}/user/updateProfileImage',
                    method: 'POST',
                    dataType: 'json',
                    data: { contentType: file.type || 'application/octet-stream' }
                });

                if(!(pre && pre.success && pre.uploadUrl && pre.publicUrl)){
                    throw new Error(pre?.message || '업로드 URL 발급 실패');
                }

                // 2) PUT 업로드 (서명 조건과 동일한 헤더)
                await new Promise((resolve, reject) => {
                    $.ajax({
                        url: pre.uploadUrl,
                        type: 'PUT',
                        headers: {
                            'Content-Type': file.type || 'application/octet-stream',
                            'X-Amz-Acl': 'public-read'
                        },
                        processData: false,
                        data: file,
                        success: () => resolve(),
                        error: (xhr) => reject(xhr)
                    });
                });

                // 3) DB 반영 (publicUrl 저장)
                const res = await $.ajax({
                    url: '${ctx}/user/updateProfileImage',
                    method: 'POST',
                    contentType: 'application/json',
                    dataType: 'json',
                    data: JSON.stringify({ imageUrl: pre.publicUrl })
                });

                if(!(res && res.success)){
                    throw new Error(res?.message || 'DB 저장 실패');
                }

                // 성공: 즉시 프로필 썸네일 갱신 (페이지 새로고침 없이)
                const img = document.querySelector('.bg-gray-800 img');
                if(img) img.src = pre.publicUrl;

                toast('프로필 이미지가 변경되었습니다 ✅');
            }

            $btn.on('click', async function(){
                console.log("응애에여")
                try{
                    const file = $file[0].files && $file[0].files[0];
                    await presignAndUpload(file);
                }catch(err){
                    console.error('[profile-upload]', err);
                    toast('업로드에 실패했습니다.');
                }
            });
        })();
    </script>
</head>

<body class="min-h-screen bg-neutral-900/80">

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
            <a href="<%=ctx%>/user/login" class="auth-link">Login</a>
            <a href="<%=ctx%>/user/userRegForm" class="auth-link">Sign Up</a>
            <% } else { %>
            <!-- 로그인됨 -->
            <a href="<%=ctx%>/user/myPage" class="auth-link"><%= ssUserName %></a>
            <a href="<%=ctx%>/user/logout" class="auth-link">Logout</a>
            <% } %>
        </div>
    </div>
</header>
<div class="header-spacer"></div>


<!-- 🔹 본문 -->
<div class="flex flex-col items-center p-6">

    <!-- 프로필 카드 -->
    <div class="bg-gray-800 bg-opacity-80 rounded-2xl p-6 w-full max-w-3xl shadow-lg">
        <div class="flex items-center space-x-4">
            <c:choose>
                <c:when test="${not empty user.profileImage}">
                    <!-- 절대 URL 저장 기준 -->
                    <img src="${user.profileImage}" class="w-20 h-20 rounded-full border-2 border-green-400"/>
                </c:when>
                <c:otherwise>
                    <img src="${ctx}/images/default.png" class="w-20 h-20 rounded-full border-2 border-green-400"/>
                </c:otherwise>
            </c:choose>

            <div>
                <h2 class="text-xl font-bold">${user.userName}</h2>
                <p class="text-sm">가입일: ${user.regDt}</p>
            </div>
        </div>
    </div>

    <!-- 스탯 카드 -->
    <div class="grid grid-cols-2 md:grid-cols-3 gap-4 mt-6 w-full max-w-3xl">
        <div class="bg-gray-800 bg-opacity-80 p-4 rounded-xl text-center shadow">
            <p class="font-bold">Points</p>
            <p class="text-lg">${user.points}</p>
        </div>
        <div class="bg-gray-800 bg-opacity-80 p-4 rounded-xl text-center shadow">
            <p class="font-bold">Distance (km)</p>
            <p class="text-lg">${user.distance}</p>
        </div>
        <div class="bg-gray-800 bg-opacity-80 p-4 rounded-xl text-center shadow">
            <p class="font-bold">Carbon Saved (kg)</p>
            <p class="text-lg">${user.carbonSaved}</p>
        </div>
        <div class="bg-gray-800 bg-opacity-80 p-4 rounded-xl text-center shadow">
            <p class="font-bold">Level</p>
            <p class="text-lg">${user.level}</p>
        </div>
        <div class="bg-gray-800 bg-opacity-80 p-4 rounded-xl text-center shadow">
            <p class="font-bold">Achievements</p>
            <p class="text-lg">${user.achievements}</p>
        </div>
        <div class="bg-gray-800 bg-opacity-80 p-4 rounded-xl text-center shadow">
            <p class="font-bold">Challenges</p>
            <p class="text-lg">${user.challenges}</p>
        </div>
    </div>

    <!-- 닉네임 변경 -->
    <form action="${ctx}/user/updateName" method="post" class="mt-6 flex space-x-2 w-full max-w-3xl">
        <input type="text" name="userName" placeholder="새 닉네임 입력"
               class="flex-1 px-4 py-2 rounded-lg text-black"/>
        <button type="submit" class="bg-green-500 px-4 py-2 rounded-lg">닉네임 변경</button>
    </form>

    <!-- 프로필 이미지 변경 -->
    <div class="mt-4 flex space-x-2 w-full max-w-3xl">
        <input type="file" id="profileFile"
               accept="image/*"
               class="flex-1 px-4 py-2 rounded-lg bg-gray-800 text-white"/>
        <button type="button" id="btnProfileUpload"
                class="bg-blue-500 px-4 py-2 rounded-lg">프로필 변경</button>
    </div>

</div>
<script>
    // 페이지가 다 그려진 뒤에 버튼/파일 입력을 잡는다
    document.addEventListener('DOMContentLoaded', function () {
        const fileInput = document.getElementById('profileFile');
        const btn = document.getElementById('btnProfileUpload');

        // 클릭 이벤트 연결 (바로 확인 가능하도록 로그 남김)
        btn.addEventListener('click', function () {
            console.log('응애에여 - 버튼 클릭됨'); // ← 이 로그가 보이면 연결 OK

            const file = fileInput.files && fileInput.files[0];
            if (!file) {
                alert('파일을 선택해 주세요.');
                return;
            }
            presignAndUpload(file).catch(err => {
                console.error('[profile-upload]', err);
                alert('업로드에 실패했습니다.');
            });
        });

        // presign → PUT 업로드 → DB 저장
        async function presignAndUpload(file) {
            // 1) presign (파일 종류 전달)
            const form = new FormData();
            form.append('contentType', file.type || 'application/octet-stream');

            // ⚠️ 엔드포인트: presign 전용
            const preRes = await fetch('<%=ctx%>/user/profile/uploadUrl', {
                method: 'POST',
                body: form
            });
            const pre = await preRes.json();
            if (!(pre && pre.success && pre.uploadUrl && pre.publicUrl)) {
                throw new Error(pre?.message || '업로드 URL 발급 실패');
            }
            console.log('[presign]', pre);

            // 2) PUT 업로드 (presign과 Content-Type, x-amz-acl 일치)
            const putRes = await fetch(pre.uploadUrl, {
                method: 'PUT',
                headers: {
                    'Content-Type': file.type || 'application/octet-stream',
                    'X-Amz-Acl': 'public-read'
                },
                body: file
            });
            if (!putRes.ok) {
                const t = await putRes.text().catch(()=> '');
                throw new Error('PUT 업로드 실패: ' + putRes.status + ' ' + t);
            }

            // 3) DB 반영 (publicUrl 저장)
            const dbRes = await fetch('<%=ctx%>/user/updateProfileImageByUrl', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ imageUrl: pre.publicUrl })
            });
            const db = await dbRes.json();
            if (!(db && db.success)) {
                throw new Error(db?.message || 'DB 저장 실패');
            }

            // 4) 화면 즉시 반영
            const img = document.querySelector('.bg-gray-800 img');
            if (img) img.src = pre.publicUrl + '?v=' + Date.now();

            alert('프로필 이미지가 변경되었습니다 ✅');
        }
    });
</script>

</body>
</html>
