<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>회원가입</title>

    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Creepster&family=Jockey+One&display=swap" rel="stylesheet">
    <style>
        .font-creepster { font-family: 'Creepster', system-ui, sans-serif; }
        .font-jockey   { font-family: 'Jockey One', system-ui, sans-serif; }
    </style>
    <!-- Lucide -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <!-- Kakao Postcode -->
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

    <!-- CSRF (선택) -->
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
</head>
<body class="min-h-screen relative overflow-y-auto">

<!-- 배경 (fixed) -->
<div class="fixed inset-0 bg-center bg-cover bg-no-repeat"
     style="background-image:url('<c:url value="/images/map-thumbnail.png"/>')"></div>
<div class="fixed inset-0 backdrop-blur-[15px] backdrop-filter bg-[rgba(0,0,0,0.7)]"></div>

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
            <p class="font-jockey text-white text-lg">Join the cycling community</p>
        </div>

        <!-- 카드 -->
        <div class="bg-black/50 backdrop-blur-sm rounded-2xl p-8 border border-gray-700">
            <h2 class="font-jockey text-2xl text-white mb-6 text-center">회원가입</h2>

            <!-- 메시지 -->
            <div id="errorBox" class="hidden bg-red-900/50 border border-red-500 rounded-lg p-3 mb-4">
                <p id="errorMsg" class="text-red-300 text-sm"></p>
            </div>
            <div id="okBox" class="hidden bg-emerald-900/50 border border-emerald-500 rounded-lg p-3 mb-4">
                <p id="okMsg" class="text-emerald-300 text-sm"></p>
            </div>

            <!-- 폼 -->
            <form id="regForm" class="space-y-6" autocomplete="off">
                <!-- 이름 -->
                <div class="space-y-2">
                    <label for="userName" class="text-white">이름</label>
                    <div class="relative">
                        <i data-lucide="user" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"></i>
                        <input id="userName" name="userName" type="text" placeholder="홍길동"
                               class="bg-gray-800 border border-gray-600 text-white pl-10 pr-3 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                    </div>
                </div>

                <!-- 아이디 -->
                <div class="space-y-2">
                    <label for="userId" class="text-white">아이디</label>
                    <div class="flex gap-2">
                        <div class="relative flex-1">
                            <i data-lucide="user" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"></i>
                            <input id="userId" name="userId" type="text" placeholder="아이디"
                                   class="bg-gray-800 border border-gray-600 text-white pl-10 pr-3 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                        </div>
                        <button type="button" id="btnUserId"
                                class="px-3 min-w-[110px] rounded-md border border-gray-600 text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94]">
                            중복체크
                        </button>
                    </div>
                    <p id="userIdHint" class="text-xs text-gray-400"></p>
                </div>

                <!-- 이메일 + 인증 -->
                <div class="space-y-2">
                    <label for="email" class="text-white">이메일</label>
                    <div class="flex gap-2">
                        <div class="relative flex-1">
                            <i data-lucide="mail" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"></i>
                            <input id="email" name="email" type="email" placeholder="your@email.com"
                                   class="bg-gray-800 border border-gray-600 text-white pl-10 pr-3 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                        </div>
                        <button type="button" id="btnEmailSend"
                                class="px-3 min-w-[140px] rounded-md border border-gray-600 text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94]">
                            인증번호 발송
                        </button>
                    </div>
                    <div id="emailVerifyRow" class="hidden flex gap-2">
                        <input id="authNumber" name="authNumber" type="text" placeholder="인증번호"
                               class="bg-gray-800 border border-gray-600 text-white px-3 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                        <button type="button" id="btnEmailVerify"
                                class="px-3 min-w-[110px] rounded-md border border-gray-600 text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94]">
                            인증확인
                        </button>
                    </div>
                    <p id="emailHint" class="text-xs"></p>
                </div>

                <!-- 비밀번호 -->
                <div class="space-y-2">
                    <label for="password" class="text-white">비밀번호</label>
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
                    <div id="pwBarWrap" class="hidden items-center gap-2 text-sm">
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
                    <div id="matchRow" class="hidden flex items-center gap-2 text-sm mt-1">
                        <span id="matchIcon"></span>
                        <span id="matchText"></span>
                    </div>
                </div>

                <!-- 주소 -->
                <div class="space-y-2">
                    <label for="addr1" class="text-white">주소</label>
                    <div class="flex gap-2">
                        <input id="addr1" name="addr1" type="text" placeholder="(우편번호) 주소"
                               class="bg-gray-800 border border-gray-600 text-white px-3 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                        <button type="button" id="btnAddr"
                                class="px-3 min-w-[110px] rounded-md border border-gray-600 text-gray-200 hover:border-[#1ccc94] hover:text-[#1ccc94]">
                            우편번호
                        </button>
                    </div>
                    <input id="addr2" name="addr2" type="text" placeholder="상세주소"
                           class="bg-gray-800 border border-gray-600 text-white px-3 py-2 rounded-md w-full focus:border-[#1ccc94] focus:ring-[#1ccc94] outline-none"/>
                </div>

                <!-- 제출 -->
                <button id="btnSubmit" type="submit"
                        class="w-full bg-[#1ccc94] hover:bg-[#16a085] text-black font-jockey text-lg py-3 h-auto rounded-md flex items-center justify-center gap-2">
            <span id="btnText" class="flex items-center gap-2">
              계정 만들기
              <i data-lucide="arrow-right" class="w-4 h-4"></i>
            </span>
                    <span id="spinner" class="hidden w-4 h-4 border-2 border-black border-t-transparent rounded-full animate-spin"></span>
                </button>

                <!-- 로그인 링크 -->
                <div class="text-center">
                    <p class="text-gray-400">
                        이미 계정이 있으신가요?
                        <a href="<c:url value='/user/login'/>"
                           class="text-[#1ccc94] hover:text-[#16a085] font-jockey underline">로그인</a>
                    </p>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // 초기 아이콘
    document.addEventListener('DOMContentLoaded', () => {
        lucide.createIcons();
        setEyeIcon(eyeIcon, false); setEyeIcon(eyeIcon2, false);
    });

    // 상태
    let userIdChecked=false, emailAuthNumber="", emailVerified=false, showPw=false, showPw2=false;

    // 엘리먼트
    const form=document.getElementById('regForm');
    const errorBox=document.getElementById('errorBox'), errorMsg=document.getElementById('errorMsg');
    const okBox=document.getElementById('okBox'), okMsg=document.getElementById('okMsg');

    const userIdEl=document.getElementById('userId'), userNameEl=document.getElementById('userName');
    const userIdHint=document.getElementById('userIdHint'), btnUserId=document.getElementById('btnUserId');

    const emailEl=document.getElementById('email'), emailHint=document.getElementById('emailHint');
    const btnEmailSend=document.getElementById('btnEmailSend');
    const emailVerifyRow=document.getElementById('emailVerifyRow'), authNumberEl=document.getElementById('authNumber');
    const btnEmailVerify=document.getElementById('btnEmailVerify');

    const pwEl=document.getElementById('password'), pw2El=document.getElementById('password2');
    const pwBarWrap=document.getElementById('pwBarWrap'), bar1=document.getElementById('bar1'), bar2=document.getElementById('bar2'), bar3=document.getElementById('bar3'), pwText=document.getElementById('pwText');
    const matchRow=document.getElementById('matchRow'), matchIcon=document.getElementById('matchIcon'), matchText=document.getElementById('matchText');

    const togglePw=document.getElementById('togglePw'), togglePw2=document.getElementById('togglePw2');
    const eyeIcon=document.getElementById('eyeIcon'), eyeIcon2=document.getElementById('eyeIcon2');

    const addr1El=document.getElementById('addr1'), addr2El=document.getElementById('addr2'), btnAddr=document.getElementById('btnAddr');

    const btnSubmit=document.getElementById('btnSubmit'), btnText=document.getElementById('btnText'), spinner=document.getElementById('spinner');

    // 공용
    function setError(msg){ if(!msg){errorBox.classList.add('hidden'); errorMsg.textContent='';} else{errorMsg.textContent=msg; errorBox.classList.remove('hidden');}}
    function setOk(msg){ if(!msg){okBox.classList.add('hidden'); okMsg.textContent='';} else{okMsg.textContent=msg; okBox.classList.remove('hidden');}}
    function setLoading(b){ if(b){btnText.classList.add('hidden'); spinner.classList.remove('hidden'); btnSubmit.setAttribute('disabled','true');}
    else{spinner.classList.add('hidden'); btnText.classList.remove('hidden'); btnSubmit.removeAttribute('disabled');}}
    function setEyeIcon(target, shown){ target.innerHTML = shown? lucide.icons['eye-off'].toSvg({width:16,height:16}) : lucide.icons['eye'].toSvg({width:16,height:16}); }
    function getPasswordStrength(pw){ if(!pw) return {lvl:0,text:''}; if(pw.length<6) return {lvl:1,text:'너무 짧습니다 (최소 6자)'}; if(pw.length<8) return {lvl:2,text:'보통'}; if(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/.test(pw)) return {lvl:3,text:'강함'}; return {lvl:2,text:'보통'}; }
    function renderPwStrength(){ const {lvl,text}=getPasswordStrength(pwEl.value); if(!pwEl.value){pwBarWrap.classList.add('hidden'); return;}
        pwBarWrap.classList.remove('hidden'); bar1.className='w-6 h-1 rounded '+(lvl>=1?'bg-red-500':'bg-gray-600'); bar2.className='w-6 h-1 rounded '+(lvl>=2?'bg-yellow-500':'bg-gray-600'); bar3.className='w-6 h-1 rounded '+(lvl>=3?'bg-green-500':'bg-gray-600');
        pwText.textContent=text; pwText.className=(lvl===1?'text-red-400':lvl===2?'text-yellow-400':'text-green-400'); }
    function renderMatch(){ if(!pw2El.value){matchRow.classList.add('hidden'); return;} matchRow.classList.remove('hidden'); const ok=pwEl.value===pw2El.value;
        matchIcon.innerHTML = ok? lucide.icons['check-circle'].toSvg({width:16,height:16,class:'text-green-400'}) : lucide.icons['x-circle'].toSvg({width:16,height:16,class:'text-red-400'});
        matchText.textContent = ok? '비밀번호가 일치합니다' : '비밀번호가 일치하지 않습니다'; matchText.className = ok? 'text-green-400' : 'text-red-400'; }

    // 입력 변경
    userIdEl.addEventListener('input', ()=>{ userIdChecked=false; userIdHint.textContent=''; });
    pwEl.addEventListener('input', ()=>{ renderPwStrength(); renderMatch(); });
    pw2El.addEventListener('input', renderMatch);

    // 토글
    togglePw.addEventListener('click', ()=>{ showPw=!showPw; pwEl.type=showPw?'text':'password'; setEyeIcon(eyeIcon, showPw); });
    togglePw2.addEventListener('click', ()=>{ showPw2=!showPw2; pw2El.type=showPw2?'text':'password'; setEyeIcon(eyeIcon2, showPw2); });

    // 아이디 중복
    btnUserId.addEventListener('click', async ()=>{
        setError(''); setOk('');
        const userId=userIdEl.value.trim(); if(!userId) return setError('아이디를 입력하세요.');
        const headers={'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'};
        const t=document.querySelector('meta[name="_csrf"]')?.getAttribute('content'); const h=document.querySelector('meta[name="_csrf_header"]')?.getAttribute('content'); if(t&&h) headers[h]=t;
        const body=new URLSearchParams(); body.append('userId',userId);
        const res=await fetch('<c:url value="/user/getUserIdExists"/>',{method:'POST',headers,body});
        if(!res.ok) return setError('네트워크 오류');
        const json=await res.json();
        if(json.existsYn==='Y'){ userIdChecked=false; userIdHint.textContent='이미 가입된 아이디입니다.'; userIdHint.className='text-xs text-red-400'; }
        else{ userIdChecked=true; userIdHint.textContent='사용 가능한 아이디입니다.'; userIdHint.className='text-xs text-emerald-400'; }
    });

    // 이메일 인증
    btnEmailSend.addEventListener('click', async ()=>{
        setError(''); setOk('');
        const email=emailEl.value.trim(); if(!email) return setError('이메일을 입력하세요.');
        const headers={'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'};
        const t=document.querySelector('meta[name="_csrf"]')?.getAttribute('content'); const h=document.querySelector('meta[name="_csrf_header"]')?.getAttribute('content'); if(t&&h) headers[h]=t;
        const body=new URLSearchParams(); body.append('email',email);
        const res=await fetch('<c:url value="/user/getEmailExists"/>',{method:'POST',headers,body});
        if(!res.ok) return setError('네트워크 오류');
        const json=await res.json();
        if(json.existsYn==='Y'){ emailHint.textContent='이미 가입된 이메일입니다.'; emailHint.className='text-xs text-red-400'; emailAuthNumber=''; emailVerified=false; }
        else{ emailVerifyRow.classList.remove('hidden'); emailHint.textContent='이메일로 인증번호가 발송되었습니다.'; emailHint.className='text-xs text-emerald-400'; emailAuthNumber=(json.authNumber??'').toString(); }
    });
    btnEmailVerify.addEventListener('click', ()=>{
        setError(''); setOk('');
        const v=(authNumberEl.value||'').trim(); if(!v) return setError('인증번호를 입력하세요.');
        if(emailAuthNumber){ if(v===emailAuthNumber){ emailVerified=true; setOk('이메일 인증이 완료되었습니다.'); } else { emailVerified=false; setError('인증번호가 일치하지 않습니다.'); } }
        else { setError('서버에서 인증번호를 받지 못했습니다. 관리자에게 문의하세요.'); }
    });

    // 주소
    btnAddr.addEventListener('click', ()=>{
        new daum.Postcode({
            oncomplete: function(data){ const addr=data.address; const zonecode=data.zonecode; addr1El.value='('+zonecode+') '+addr; addr2El.focus(); }
        }).open();
    });

    // 제출
    form.addEventListener('submit', async (e)=>{
        e.preventDefault(); setError(''); setOk('');
        const userId=userIdEl.value.trim(), userName=userNameEl.value.trim(), email=emailEl.value.trim();
        const pw=pwEl.value, pw2=pw2El.value, addr1=addr1El.value.trim(), addr2=addr2El.value.trim();

        if(!userName) return setError('이름을 입력하세요.');
        if(!userId) return setError('아이디를 입력하세요.');
        if(!userIdChecked) return setError('아이디 중복체크를 해주세요.');
        if(!email) return setError('이메일을 입력하세요.');
        if(!pw) return setError('비밀번호를 입력하세요.');
        if(!pw2) return setError('비밀번호 확인을 입력하세요.');
        if(pw!==pw2) return setError('비밀번호가 일치하지 않습니다.');
        if(!addr1) return setError('주소를 입력하세요.');
        if(!addr2) return setError('상세주소를 입력하세요.');
        if(!emailVerified) return setError('이메일 인증을 완료해주세요.');

        setLoading(true);
        try{
            const headers={'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'};
            const t=document.querySelector('meta[name="_csrf"]')?.getAttribute('content'); const h=document.querySelector('meta[name="_csrf_header"]')?.getAttribute('content'); if(t&&h) headers[h]=t;
            const body=new URLSearchParams();
            body.append('userId',userId); body.append('userName',userName); body.append('password',pw); body.append('email',email); body.append('addr1',addr1); body.append('addr2',addr2);

            const res=await fetch('<c:url value="/user/insertUserInfo"/>',{method:'POST',headers,body:body.toString()});
            if(!res.ok) throw new Error('net');
            const json=await res.json();
            if(json.result===1){ setOk(json.msg || '회원가입되었습니다.'); setTimeout(()=>{ window.location.href='<c:url value="/user/login"/>'; },600); }
            else { setError(json.msg || '오류로 인해 회원가입이 실패하였습니다.'); }
        }catch(err){ setError('서버 통신 중 오류가 발생했습니다.'); }
        finally{ setLoading(false); }
    });
</script>
</body>
</html>
