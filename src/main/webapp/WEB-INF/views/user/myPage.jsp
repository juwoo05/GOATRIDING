<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- ✅ 컨텍스트 경로 변수 (EL로 통일) --%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- ✅ 공통 헤더 include (헤더에서 ${ctx} 사용 가능) --%>
<%@ include file="../common/header.jsp" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>RIDING GOAT • My Page</title>

    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Jockey+One&family=Paytone+One&display=swap" rel="stylesheet"/>

    <!-- 배경 블러 -->
    <style>
        body::before{
            content:"";
            position:fixed; inset:0;
            background:url('${ctx}/images/ranking-thumbnail.png') no-repeat center/cover;
            filter:blur(8px) brightness(.6);
            z-index:-1;
        }
    </style>

    <!-- 헤더 스타일 (디자인 유지) -->
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

    <!-- (선택) jQuery 필요 시 사용 -->
    <script src="${ctx}/js/jquery-3.6.0.min.js"></script>

    <!-- Spring Security CSRF 메타 (있으면 자동 주입) -->
    <c:if test="${not empty _csrf}">
        <meta name="_csrf_header" content="${_csrf.headerName}" />
        <meta name="_csrf"        content="${_csrf.token}" />
    </c:if>
</head>

<body class="min-h-screen bg-neutral-900/80">

<div class="flex flex-col items-center p-6">

    <!-- 프로필 카드 -->
    <div class="bg-gray-800 bg-opacity-80 rounded-2xl p-6 w-full max-w-3xl shadow-lg">
        <div class="flex items-center space-x-4">
            <c:choose>
                <c:when test="${not empty user.profileImage}">
                    <img src="${user.profileImage}" class="w-20 h-20 rounded-full border-2 border-green-400" alt="profile"/>
                </c:when>
                <c:otherwise>
                    <img src="${ctx}/images/default.png" class="w-20 h-20 rounded-full border-2 border-green-400" alt="profile"/>
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

    <!-- 🔹 닉네임 변경 (방법 A: 폼 전송) -->
    <form action="${ctx}/user/updateName" method="post" class="mt-6 flex space-x-2 w-full max-w-3xl">
        <input type="text" name="userName" placeholder="새 닉네임 입력"
               class="flex-1 px-4 py-2 rounded-lg text-black" required/>
        <c:if test="${not empty _csrf}">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        </c:if>
        <button type="submit" class="bg-green-500 px-4 py-2 rounded-lg font-semibold">닉네임 변경</button>
    </form>

    <!-- 🔹 프로필 이미지 변경 -->
    <div class="mt-4 flex space-x-2 w-full max-w-3xl">
        <input type="file" id="profileFile" accept="image/*"
               class="flex-1 px-4 py-2 rounded-lg bg-gray-800 text-white"/>
        <button type="button" id="btnProfileUpload"
                class="bg-blue-500 px-4 py-2 rounded-lg font-semibold">프로필 변경</button>
    </div>

</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const fileInput = document.getElementById('profileFile');
    const btn = document.getElementById('btnProfileUpload');

    const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.getAttribute('content');
    const csrfToken  = document.querySelector('meta[name="_csrf"]')?.getAttribute('content');

    btn.addEventListener('click', async function () {
        const file = fileInput.files && fileInput.files[0];
        if (!file) { alert('파일을 선택해 주세요.'); return; }

        try {
            // 1) Presign URL 발급
            const preForm = new FormData();
            preForm.append('contentType', file.type || 'application/octet-stream');

            const preRes = await fetch('${ctx}/user/profile/uploadUrl', {
                method: 'POST',
                headers: (csrfHeader && csrfToken) ? { [csrfHeader]: csrfToken } : {},
                body: preForm
            });
            const pre = await preRes.json();
            if (!(pre && pre.success && pre.uploadUrl && pre.publicUrl)) {
                throw new Error(pre?.message || '업로드 URL 발급 실패');
            }

            // 2) PUT 업로드
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
            const dbRes = await fetch('${ctx}/user/updateProfileImageByUrl', {
                method: 'POST',
                headers: Object.assign(
                    { 'Content-Type': 'application/json' },
                    (csrfHeader && csrfToken) ? { [csrfHeader]: csrfToken } : {}
                ),
                body: JSON.stringify({ imageUrl: pre.publicUrl })
            });
            const db = await dbRes.json();
            if (!(db && db.success)) {
                throw new Error(db?.message || 'DB 저장 실패');
            }

            // 4) 썸네일 즉시 갱신
            const img = document.querySelector('.bg-gray-800 img');
            if (img) img.src = pre.publicUrl + '?v=' + Date.now();

            alert('프로필 이미지가 변경되었습니다 ✅');
        } catch (err) {
            console.error('[profile-upload]', err);
            alert('업로드에 실패했습니다.');
        }
    });
});
</script>

</body>
</html>
