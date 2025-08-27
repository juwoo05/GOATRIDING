<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>비밀번호 찾기</title>

    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Creepster&family=Jockey+One&display=swap" rel="stylesheet">
    <style>
        .font-creepster { font-family: 'Creepster', system-ui, sans-serif; }
        .font-jockey   { font-family: 'Jockey One', system-ui, sans-serif; }
    </style>
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>

    <!-- CSRF (Spring Security 사용 시) -->
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
</head>
<body class="min-h-screen relative overflow-y-auto">
<!-- 배경 (고정) -->
<div class="fixed inset-0 bg-center bg-cover bg-no-repeat"
     style="background-image:url('<c:url value="/images/map-thumbnail.png"/>')"></div>
<div class="fixed inset-0 backdrop-blur-[15px] backdrop-filter bg-[rgba(0,0,0,0.7)]"></div>

<!-- 메인 -->
<div class="relative z-10 min-h-screen flex items-start md:items-center justify-center px-4 py-8">
    <div class="w-full max-w-md">
        <!-- 로고 -->
        <div class="text-center mb-8">
            <div class="flex items-center justify-center gap-3 mb-4">
                <div class="w-12 h-12 bg-[#1ccc94] rounded-lg flex items-center justify-center">
                    <i data-lucide="bike" class="w-8 h-8 text-black"></i>
                </div>
                <div class="font-creepster text-4xl text-[#1ccc94]">RIDING GOAT</div>
            </div>
            <p class="font-jockey text-white text-lg">Recover your password</p>
        </div>

        <!-- 카드 -->
        <div class="bg-black/50 backdrop-blur-sm rounded-2xl p-8 border border-gray-700">
            <h2 class="font-jockey text-2xl text-white mb-6 text-center">비밀번호 찾기</h2>

            <!-- 메시지 박스 -->
            <div id="errorBox" class="hidden bg-red-900/50 border border-red-500 rounded-lg p-3 mb-4">
                <p id="errorMsg" class="text-red-300 text-sm"></p>
            </div>
            <div id="okBox" class="hidden bg-emerald-900/50 border border-emerald-500 rounded-lg p-3 mb-4">
                <p id="okMsg" class="text-emerald-300 text-sm"></p>
            </div>

            <!-- 폼 (POST로 newPassword 화면으로 이동) -->
            <form id="f" class="space-y-6" method="post" action="<c:url value='/user/searchPasswordProc'/>" autocomplete="off">
                <!-- 이메일 -->
                <div class="space-y-2">
                    <label for="email" class="text-white">이메일</label>
                    <div class="flex gap-2">
                        <div class="relative flex-1">
                            <i data-lucide="mail" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"></i>
                            <input id="email" name="email" type="email" placeholder="가입한 이메일 주소"
                                   class="bg-gray-800 border border-gray-600 text-white pl-10 pr-3 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                        </div>
                        <button type="button" id="btnConfirmEmail"
                                class="px-3 min-w-[150px] rounded-md border border-gray-600 text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94]">
                            인증번호 보내기
                        </button>
                    </div>
                    <p id="emailHint" class="text-xs text-gray-400"></p>
                </div>

                <!-- 인증번호 입력/확인 -->
                <div id="verifyRow" class="hidden space-y-2">
                    <label for="authNumber" class="text-white">이메일 인증번호</label>
                    <div class="flex gap-2">
                        <div class="relative flex-1">
                            <i data-lucide="key-round" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"></i>
                            <input id="authNumber" name="authNumber" type="text" placeholder="메일로 받은 인증번호"
                                   class="bg-gray-800 border border-gray-600 text-white pl-10 pr-3 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                        </div>
                        <button type="button" id="btnVerify"
                                class="px-3 min-w-[110px] rounded-md border border-gray-600 text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94]">
                            확인
                        </button>
                    </div>
                    <p id="verifyHint" class="text-xs"></p>
                </div>

                <!-- 비밀번호 재설정 이동 버튼 -->
                <button id="btnGoReset" type="button"
                        class="w-full bg-[#1ccc94] hover:bg-[#16a085] text-black font-jockey text-lg py-3 h-auto rounded-md flex items-center justify-center gap-2">
            <span id="goText" class="flex items-center gap-2">
              비밀번호 재설정으로 이동
              <i data-lucide="arrow-right" class="w-4 h-4"></i>
            </span>
                    <span id="spinnerGo" class="hidden w-4 h-4 border-2 border-black border-t-transparent rounded-full animate-spin"></span>
                </button>

                <!-- 링크 모음 -->
                <hr class="my-4 border-t border-dashed border-gray-600" />
                <div class="flex items-center justify-between gap-3">
                    <a href="<c:url value='/user/login'/>"
                       class="flex-1 inline-flex items-center justify-center gap-2 py-2 rounded-md border border-gray-600 text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94] transition">
                        <i data-lucide="log-in" class="w-4 h-4"></i>
                        로그인
                    </a>
                    <a href="<c:url value='/user/searchUserId'/>"
                       class="flex-1 inline-flex items-center justify-center gap-2 py-2 rounded-md border border-gray-600 text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94] transition">
                        <i data-lucide="search" class="w-4 h-4"></i>
                        아이디 찾기
                    </a>
                </div>
                <div class="text-center">
                    <p class="text-gray-400">
                        아직 회원이 아니신가요?
                        <a href="<c:url value='/user/userRegForm'/>" class="text-[#1ccc94] hover:text-[#16a085] font-jockey underline">회원가입</a>
                    </p>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // ===== 아이콘 렌더 =====
    document.addEventListener('DOMContentLoaded', () => {
        lucide.createIcons();
    });

    // ===== 상태 =====
    let emailAuthNumber = "";   // 서버가 내려주면 프론트에서 비교
    let emailVerified   = false;

    // ===== 엘리먼트 =====
    const form        = document.getElementById('f');
    const emailEl     = document.getElementById('email');
    const emailHint   = document.getElementById('emailHint');
    const btnConfirm  = document.getElementById('btnConfirmEmail');

    const verifyRow   = document.getElementById('verifyRow');
    const authEl      = document.getElementById('authNumber');
    const btnVerify   = document.getElementById('btnVerify');
    const verifyHint  = document.getElementById('verifyHint');

    const btnGoReset  = document.getElementById('btnGoReset');
    const goText      = document.getElementById('goText');
    const spinnerGo   = document.getElementById('spinnerGo');

    const errorBox    = document.getElementById('errorBox');
    const errorMsg    = document.getElementById('errorMsg');
    const okBox       = document.getElementById('okBox');
    const okMsg       = document.getElementById('okMsg');

    // ===== 유틸 =====
    function setError(msg){ if(!msg){errorBox.classList.add('hidden'); errorMsg.textContent='';} else{errorMsg.textContent=msg; errorBox.classList.remove('hidden');}}
    function setOk(msg){ if(!msg){okBox.classList.add('hidden'); okMsg.textContent='';} else{okMsg.textContent=msg; okBox.classList.remove('hidden');}}
    function setBtnLoading(b){ if(b){goText.classList.add('hidden'); spinnerGo.classList.remove('hidden'); btnGoReset.setAttribute('disabled','true');}
    else{spinnerGo.classList.add('hidden'); goText.classList.remove('hidden'); btnGoReset.removeAttribute('disabled');}}
    function csrfHeaders() {
        const headers = { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' };
        const t = document.querySelector('meta[name="_csrf"]')?.getAttribute('content');
        const h = document.querySelector('meta[name="_csrf_header"]')?.getAttribute('content');
        if (t && h) headers[h] = t;
        return headers;
    }

    // ===== 인증번호 보내기 =====
    btnConfirm.addEventListener('click', async () => {
        setError(''); setOk('');
        emailVerified = false; emailAuthNumber = '';
        const email = emailEl.value.trim();
        if (!email) return setError('이메일을 입력하세요.');

        try {
            const body = new URLSearchParams(); body.append('email', email);
            const res = await fetch('<c:url value="/user/getUserIdByEmail"/>', {
                method: 'POST', headers: csrfHeaders(), body
            });
            if (!res.ok) throw new Error('net');
            const json = await res.json();

            if (json.existsYn === 'Y') {
                verifyRow.classList.remove('hidden');
                emailHint.textContent = '이메일로 인증번호가 발송되었습니다.';
                emailHint.className = 'text-xs text-emerald-400';
                emailAuthNumber = (json.authNumber ?? '').toString(); // 기존 로직 호환: 프론트 비교
            } else {
                emailHint.textContent = '가입된 이메일 주소가 없습니다.';
                emailHint.className = 'text-xs text-red-400';
                verifyRow.classList.add('hidden');
            }
        } catch (e) {
            setError('서버 통신 중 오류가 발생했습니다.');
        }
    });

    // ===== 인증번호 확인 =====
    btnVerify.addEventListener('click', () => {
        setError(''); setOk('');
        const v = (authEl.value || '').trim();
        if (!v) return setError('인증번호를 입력하세요.');
        if (emailAuthNumber) {
            if (v === emailAuthNumber) {
                emailVerified = true;
                verifyHint.textContent = '이메일 인증이 완료되었습니다.';
                verifyHint.className = 'text-xs text-emerald-400';
                setOk('이메일 인증이 완료되었습니다.');
            } else {
                emailVerified = false;
                verifyHint.textContent = '인증번호가 일치하지 않습니다.';
                verifyHint.className = 'text-xs text-red-400';
                setError('인증번호가 일치하지 않습니다.');
            }
        } else {
            setError('서버에서 인증번호를 받지 못했습니다. 관리자에게 문의하세요.');
        }
    });

    // ===== 비밀번호 재설정 화면으로 이동(POST 제출) =====
    btnGoReset.addEventListener('click', async () => {
        setError(''); setOk('');
        const email = emailEl.value.trim();
        const code  = (authEl.value || '').trim();

        if (!email) return setError('이메일을 입력하세요.');
        if (!code)  return setError('이메일 인증번호를 입력하세요.');
        if (!emailVerified) return setError('이메일 인증을 먼저 완료해주세요.');

        // 실제 이동은 서버 렌더링 화면이므로 form POST 제출을 사용
        setBtnLoading(true);
        try {
            form.submit(); // /user/searchPasswordProc -> 컨트롤러에서 user/newPassword 뷰 렌더
        } finally {
            // submit 후 네비게이션으로 넘어가므로 굳이 로딩 되돌릴 필요는 없음
        }
    });
</script>
</body>
</html>
