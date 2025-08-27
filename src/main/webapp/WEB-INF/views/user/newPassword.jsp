<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>회원님의 비밀번호 재설정</title>

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
            <p class="font-jockey text-white text-lg">Reset your password</p>
        </div>

        <!-- 카드 -->
        <div class="bg-black/50 backdrop-blur-sm rounded-2xl p-8 border border-gray-700">
            <h2 class="font-jockey text-2xl text-white mb-6 text-center">비밀번호 재설정</h2>

            <!-- 메시지 박스 -->
            <div id="errorBox" class="hidden bg-red-900/50 border border-red-500 rounded-lg p-3 mb-4">
                <p id="errorMsg" class="text-red-300 text-sm"></p>
            </div>
            <div id="okBox" class="hidden bg-emerald-900/50 border border-emerald-500 rounded-lg p-3 mb-4">
                <p id="okMsg" class="text-emerald-300 text-sm"></p>
            </div>

            <!-- 폼 -->
            <form id="f" class="space-y-6" autocomplete="off">
                <!-- 새 비밀번호 -->
                <div class="space-y-2">
                    <label for="password" class="text-white">새로운 비밀번호</label>
                    <div class="relative">
                        <i data-lucide="lock" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"></i>
                        <input id="password" name="password" type="password" placeholder="••••••••"
                               class="bg-gray-800 border border-gray-600 text-white pl-10 pr-10 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                        <button type="button" id="togglePw"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white">
                            <span id="eyeIcon"></span>
                        </button>
                    </div>
                    <!-- 강도 표시 -->
                    <div id="pwBarWrap" class="hidden items-center gap-2 text-sm mt-1">
                        <div class="flex gap-1">
                            <div id="bar1" class="w-6 h-1 rounded bg-gray-600"></div>
                            <div id="bar2" class="w-6 h-1 rounded bg-gray-600"></div>
                            <div id="bar3" class="w-6 h-1 rounded bg-gray-600"></div>
                        </div>
                        <span id="pwText" class="text-gray-400">보통</span>
                    </div>
                </div>

                <!-- 비밀번호 확인 -->
                <div class="space-y-2">
                    <label for="password2" class="text-white">비밀번호 확인</label>
                    <div class="relative">
                        <i data-lucide="lock" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"></i>
                        <input id="password2" name="password2" type="password" placeholder="••••••••"
                               class="bg-gray-800 border border-gray-600 text-white pl-10 pr-10 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                        <button type="button" id="togglePw2"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white">
                            <span id="eyeIcon2"></span>
                        </button>
                    </div>
                    <!-- 일치 여부 -->
                    <div id="matchRow" class="hidden flex items-center gap-2 text-sm mt-1">
                        <span id="matchIcon"></span>
                        <span id="matchText"></span>
                    </div>
                </div>

                <!-- 제출 버튼 -->
                <button id="btnReset" type="button"
                        class="w-full bg-[#1ccc94] hover:bg-[#16a085] text-black font-jockey text-lg py-3 h-auto rounded-md flex items-center justify-center gap-2">
            <span id="btnText" class="flex items-center gap-2">
              비밀번호 재설정
              <i data-lucide="arrow-right" class="w-4 h-4"></i>
            </span>
                    <span id="spinner" class="hidden w-4 h-4 border-2 border-black border-t-transparent rounded-full animate-spin"></span>
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
        setEyeIcon(eyeIcon, false);
        setEyeIcon(eyeIcon2, false);
    });

    // ===== 상태 & 엘리먼트 =====
    let showPw=false, showPw2=false;

    const form=document.getElementById('f');
    const pw=document.getElementById('password');
    const pw2=document.getElementById('password2');

    const errorBox=document.getElementById('errorBox'), errorMsg=document.getElementById('errorMsg');
    const okBox=document.getElementById('okBox'), okMsg=document.getElementById('okMsg');

    const btnReset=document.getElementById('btnReset'), btnText=document.getElementById('btnText'), spinner=document.getElementById('spinner');

    const togglePw=document.getElementById('togglePw'), togglePw2=document.getElementById('togglePw2');
    const eyeIcon=document.getElementById('eyeIcon'), eyeIcon2=document.getElementById('eyeIcon2');

    const pwBarWrap=document.getElementById('pwBarWrap'), bar1=document.getElementById('bar1'), bar2=document.getElementById('bar2'), bar3=document.getElementById('bar3'), pwText=document.getElementById('pwText');
    const matchRow=document.getElementById('matchRow'), matchIcon=document.getElementById('matchIcon'), matchText=document.getElementById('matchText');

    // ===== 유틸 =====
    function setError(msg){ if(!msg){errorBox.classList.add('hidden'); errorMsg.textContent='';} else{errorMsg.textContent=msg; errorBox.classList.remove('hidden');}}
    function setOk(msg){ if(!msg){okBox.classList.add('hidden'); okMsg.textContent='';} else{okMsg.textContent=msg; okBox.classList.remove('hidden');}}
    function setLoading(b){ if(b){btnText.classList.add('hidden'); spinner.classList.remove('hidden'); btnReset.setAttribute('disabled','true');}
    else{spinner.classList.add('hidden'); btnText.classList.remove('hidden'); btnReset.removeAttribute('disabled');}}
    function setEyeIcon(target, shown){ target.innerHTML = shown? lucide.icons['eye-off'].toSvg({width:16,height:16}) : lucide.icons['eye'].toSvg({width:16,height:16}); }
    function getPasswordStrength(pw){ if(!pw) return {lvl:0,text:''}; if(pw.length<6) return {lvl:1,text:'너무 짧습니다 (최소 6자)'}; if(pw.length<8) return {lvl:2,text:'보통'}; if(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])/.test(pw)) return {lvl:3,text:'강함'}; return {lvl:2,text:'보통'}; }
    function renderPwStrength(){ const {lvl,text}=getPasswordStrength(pw.value); if(!pw.value){pwBarWrap.classList.add('hidden'); return;}
        pwBarWrap.classList.remove('hidden'); bar1.className='w-6 h-1 rounded '+(lvl>=1?'bg-red-500':'bg-gray-600'); bar2.className='w-6 h-1 rounded '+(lvl>=2?'bg-yellow-500':'bg-gray-600'); bar3.className='w-6 h-1 rounded '+(lvl>=3?'bg-green-500':'bg-gray-600');
        pwText.textContent=text; pwText.className=(lvl===1?'text-red-400':lvl===2?'text-yellow-400':'text-green-400'); }
    function renderMatch(){ if(!pw2.value){matchRow.classList.add('hidden'); return;} matchRow.classList.remove('hidden'); const ok=pw.value===pw2.value;
        matchIcon.innerHTML = ok? lucide.icons['check-circle'].toSvg({width:16,height:16,class:'text-green-400'}) : lucide.icons['x-circle'].toSvg({width:16,height:16,class:'text-red-400'});
        matchText.textContent = ok? '비밀번호가 일치합니다' : '비밀번호가 일치하지 않습니다'; matchText.className = ok? 'text-green-400' : 'text-red-400'; }

    // 입력 변화
    pw.addEventListener('input', ()=>{ renderPwStrength(); renderMatch(); });
    pw2.addEventListener('input', renderMatch);

    // 토글
    togglePw.addEventListener('click', ()=>{ showPw=!showPw; pw.type=showPw?'text':'password'; setEyeIcon(eyeIcon, showPw); });
    togglePw2.addEventListener('click', ()=>{ showPw2=!showPw2; pw2.type=showPw2?'text':'password'; setEyeIcon(eyeIcon2, showPw2); });

    // 제출
    btnReset.addEventListener('click', async ()=>{
        setError(''); setOk('');
        const p=pw.value, p2=pw2.value;
        if(!p)  return setError('새로운 비밀번호를 입력하세요.');
        if(!p2) return setError('비밀번호 확인을 입력하세요.');
        if(p!==p2) return setError('입력한 비밀번호가 일치하지 않습니다.');

        setLoading(true);
        try{
            const headers={'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'};
            const t=document.querySelector('meta[name="_csrf"]')?.getAttribute('content');
            const h=document.querySelector('meta[name="_csrf_header"]')?.getAttribute('content');
            if(t&&h) headers[h]=t;

            const body=new URLSearchParams(); body.append('password', p);

            // /user/newPasswordProc : String(메시지) 반환
            const res=await fetch('<c:url value="/user/newPasswordProc"/>',{method:'POST',headers,body:body.toString()});
            if(!res.ok) throw new Error('net');
            const msg=await res.text();
            setOk(msg || '비밀번호가 재설정되었습니다.');
            // 잠시 후 로그인 화면으로 이동
            setTimeout(()=>{ window.location.href='<c:url value="/user/login"/>'; }, 600);
        }catch(err){
            setError('시스템 오류가 발생했습니다.');
        }finally{
            setLoading(false);
        }
    });
</script>
</body>
</html>
