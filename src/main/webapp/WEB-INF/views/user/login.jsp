<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>로그인</title>

  <!-- Tailwind (CDN) -->
  <script src="https://cdn.tailwindcss.com"></script>

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Creepster&family=Jockey+One&display=swap" rel="stylesheet">

  <!-- Lucide (웹용 아이콘) -->
  <script src="https://unpkg.com/lucide@latest"></script>

  <!-- 정적 리소스: 배경/이미지 경로 예시 -->
  <!-- 배경이미지 파일을 /static/images/login-bg.jpg 로 두었다고 가정 -->
  <style>
    .font-creepster { font-family: 'Creepster', system-ui, sans-serif; }
    .font-jockey   { font-family: 'Jockey One', system-ui, sans-serif; }
  </style>

  <!-- (선택) Spring Security CSRF 메타태그가 있을 경우 자동 포함되어 있음 -->
  <meta name="_csrf" content="${_csrf.token}"/>
  <meta name="_csrf_header" content="${_csrf.headerName}"/>
</head>
<body class="min-h-screen relative overflow-hidden">

<!-- 배경 -->
<div
        class="absolute inset-0 bg-center bg-cover bg-no-repeat"
        style="background-image:url('<c:url value="/images/map-thumbnail.png"/>')"
></div>
<div class="absolute inset-0 backdrop-blur-[15px] backdrop-filter bg-[rgba(0,0,0,0.7)]"></div>

<!-- 메인 콘텐츠 -->
<div class="relative z-10 min-h-screen flex items-center justify-center px-4">
  <div class="w-full max-w-md">

    <!-- 로고 -->
    <div class="text-center mb-8">
      <div class="flex items-center justify-center gap-3 mb-4">
        <div class="w-12 h-12 bg-[#1ccc94] rounded-lg flex items-center justify-center">
          <i data-lucide="bike" class="w-8 h-8 text-black"></i>
        </div>
        <div class="font-creepster text-4xl text-[#1ccc94]">
          RIDING GOAT
        </div>
      </div>
      <p class="font-jockey text-white text-lg">
        Safe riding starts here
      </p>
    </div>

    <!-- 로그인 카드 -->
    <div class="bg-black bg-opacity-50 backdrop-blur-sm rounded-2xl p-8 border border-gray-700">

      <h2 class="font-jockey text-2xl text-white mb-6 text-center">로그인</h2>

      <!-- 에러 메시지 -->
      <div id="errorBox" class="hidden bg-red-900 bg-opacity-50 border border-red-500 rounded-lg p-3 mb-4">
        <p id="errorMsg" class="text-red-300 text-sm"></p>
      </div>

      <!-- 로그인 폼 -->
      <form id="loginForm" class="space-y-6" autocomplete="on">
        <!-- 이메일(실제 전송명은 userId로 맞춤) -->
        <div class="space-y-2">
          <label for="userId" class="text-white">아이디</label>
          <div class="relative">
            <i data-lucide="mail" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"></i>
            <input
                    id="userId" name="userId" type="text"
                    placeholder="아이디를 입력해주세요"
                    class="bg-gray-800 border border-gray-600 text-white pl-10 pr-3 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"
            />
          </div>
        </div>

        <!-- 비밀번호 -->
        <div class="space-y-2">
          <label for="password" class="text-white">비밀번호</label>
          <div class="relative">
            <i data-lucide="lock" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"></i>
            <input
                    id="password" name="password" type="password"
                    placeholder="••••••••"
                    class="bg-gray-800 border border-gray-600 text-white pl-10 pr-10 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"
            />
            <button
                    type="button" id="togglePw"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white"
                    aria-label="비밀번호 표시/숨기기"
            >
              <span id="eyeIcon"></span>
            </button>
          </div>
        </div>

        <!-- 로그인 버튼 -->
        <button
                id="loginBtn" type="submit"
                class="w-full bg-[#1ccc94] hover:bg-[#16a085] text-black font-jockey text-lg py-3 h-auto rounded-md flex items-center justify-center gap-2"
        >
            <span id="loginBtnText" class="flex items-center gap-2">
              로그인
              <i data-lucide="arrow-right" class="w-4 h-4"></i>
            </span>
          <span id="spinner" class="hidden w-4 h-4 border-2 border-black border-t-transparent rounded-full animate-spin"></span>
        </button>
      </form>

      <!-- 아이디/비밀번호 찾기 -->
      <hr class="my-4 border-t border-dashed border-gray-600" />

      <div class="flex items-center justify-between gap-3">
        <a href="<c:url value='/user/searchUserId'/>"
           class="flex-1 inline-flex items-center justify-center gap-2 py-2 rounded-md border border-gray-600
            text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94] transition">
          <i data-lucide="search" class="w-4 h-4"></i>
          아이디 찾기
        </a>

        <a href="<c:url value='/user/searchPassword'/>"
           class="flex-1 inline-flex items-center justify-center gap-2 py-2 rounded-md border border-gray-600
            text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94] transition">
          <i data-lucide="key" class="w-4 h-4"></i>
          비밀번호 찾기
        </a>
      </div>


      <!-- 회원가입 링크 -->
      <div class="mt-6 text-center">
        <p class="text-gray-400">
          계정이 없으신가요?
          <a href="<c:url value='/user/userRegForm'/>"
             class="text-[#1ccc94] hover:text-[#16a085] font-jockey underline">
            회원가입
          </a>
        </p>
      </div>

      <!-- 데모 계정 -->
      <div class="mt-6 bg-gray-800 bg-opacity-50 rounded-lg p-4">
        <h3 class="font-jockey text-[#1ccc94] text-sm mb-2">RIDING GOAT</h3>
        <p class="text-gray-300 text-sm">
          E-MAIL: RIDING@GOAT.COM<br />
          ADDRESS: 강서폴리텍
        </p>
      </div>
    </div>
  </div>
</div>

<script>
  // Lucide 아이콘 초기 렌더
  document.addEventListener('DOMContentLoaded', () => {
    lucide.createIcons();
    setEyeIcon(false);
  });

  const form       = document.getElementById('loginForm');
  const loginBtn   = document.getElementById('loginBtn');
  const btnText    = document.getElementById('loginBtnText');
  const spinner    = document.getElementById('spinner');
  const errorBox   = document.getElementById('errorBox');
  const errorMsg   = document.getElementById('errorMsg');
  const userIdEl   = document.getElementById('userId');
  const pwEl       = document.getElementById('password');
  const togglePw   = document.getElementById('togglePw');
  const eyeIcon    = document.getElementById('eyeIcon');

  let showPw = false;
  let isLoading = false;

  function setError(msg) {
    if (!msg) {
      errorBox.classList.add('hidden');
      errorMsg.textContent = '';
    } else {
      errorMsg.textContent = msg;
      errorBox.classList.remove('hidden');
    }
  }

  function setLoading(loading) {
    isLoading = loading;
    if (loading) {
      btnText.classList.add('hidden');
      spinner.classList.remove('hidden');
      loginBtn.setAttribute('disabled', 'true');
    } else {
      spinner.classList.add('hidden');
      btnText.classList.remove('hidden');
      loginBtn.removeAttribute('disabled');
    }
  }

  function setEyeIcon(isShown) {
    // lucide 아이콘 SVG를 직접 주입
    eyeIcon.innerHTML = isShown
            ? lucide.icons['eye-off'].toSvg({ width: 16, height: 16 })
            : lucide.icons['eye'].toSvg({ width: 16, height: 16 });
  }

  togglePw.addEventListener('click', () => {
    showPw = !showPw;
    pwEl.type = showPw ? 'text' : 'password';
    setEyeIcon(showPw);
  });

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    setError('');

    const userId   = userIdEl.value.trim();
    const password = pwEl.value;

    if (!userId || !password) {
      setError('이메일(아이디)과 비밀번호를 입력해주세요.');
      return;
    }

    setLoading(true);

    try {
      // CSRF(있을 경우) 헤더 자동 포함
      const csrfToken  = document.querySelector('meta[name="_csrf"]')?.getAttribute('content');
      const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.getAttribute('content');

      const params = new URLSearchParams();
      params.append('userId', userId);      // 컨트롤러 시그니처에 맞춤
      params.append('password', password);

      const headers = { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' };
      if (csrfToken && csrfHeader) headers[csrfHeader] = csrfToken;

      const res = await fetch('<c:url value="/user/loginProc"/>', {
        method: 'POST',
        headers,
        body: params.toString()
      });

      if (!res.ok) throw new Error('네트워크 오류');
      const json = await res.json();

      if (json.result === 1) {
        // 로그인 성공 → 결과 페이지로
        window.location.href = '<c:url value="/"/>';
      } else {
        setError(json.msg || '이메일 또는 비밀번호가 올바르지 않습니다.');
      }
    } catch (err) {
      setError('서버 통신 중 오류가 발생했습니다.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  });
</script>
</body>
</html>
