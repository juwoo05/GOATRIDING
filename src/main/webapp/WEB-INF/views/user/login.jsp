<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>로그인하기</title>
  <link rel="stylesheet" href="/css/table.css"/>
  <link rel="stylesheet" href="/css/modal.css"/>
  <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
  <script type="text/javascript">

    // HTML로딩이 완료되고, 실행됨
    $(document).ready(function () {
      const modal = document.querySelector('.modal');
      const btnOpenModal=document.querySelector('.btn-open-modal');

      btnOpenModal.addEventListener("click", ()=>{
        modal.style.display="flex";
      });

      // 회원가입
      $("#btnGoJoin").on("click", function () { // 버튼 클릭했을때, 발생되는 이벤트 생성함(onclick 이벤트와 동일함)
        location.href = "/user/userRegForm";
      })

      // 아이디 찾기
      $("#btnGoFindId").on("click", function () { // 버튼 클릭했을때, 발생되는 이벤트 생성함(onclick 이벤트와 동일함)
        location.href = "/user/searchUserId";
      })

      // 비밀번호 찾기
      $("#btnGoFindPw").on("click", function () { // 버튼 클릭했을때, 발생되는 이벤트 생성함(onclick 이벤트와 동일함)
        location.href = "/user/searchPassword";
      })

      // 로그인
      $("#btnLogin").on("click", function () {
        let f = document.getElementById("f"); // form 태그

        if (f.userId.value === "") {
          alert("아이디를 입력하세요.");
          f.userId.focus();
          return;
        }

        if (f.password.value === "") {
          alert("비밀번호를 입력하세요.");
          f.password.focus();
          return;
        }

        // Ajax 호출해서 로그인하기
        $.ajax({
                  url: "/user/loginProc",
                  type: "post", // 전송방식은 Post
                  dataType: "JSON", // 전송 결과는 JSON으로 받기
                  data: $("#f").serialize(), // form 태그 내 input 등 객체를 자동으로 전송할 형태로 변경하기
                  success: function (json) { // /notice/noticeUpdate 호출이 성공했다면..

                    if (json.result === 1) { // 로그인 성공
                      alert(json.msg); // 메시지 띄우기
                      location.href = "/user/loginResult"; // 로그인 성공 페이지 이동

                    } else { // 로그인 실패
                      alert(json.msg); // 메시지 띄우기
                      $("#userId").focus(); // 아이디 입력 항목에 마우스 커서 이동
                    }

                  }
                }
        )

      })
    })
  </script>
</head>
<body>
<main>
  <section class="login-section">
    <form id="f" class="login-box" th:action="@{/user/loginProc}" method="post">
      <img th:src="@{/images/person.png}" alt="로그인 아이콘" class="login-icon">
      <h2>로그인</h2>

      <div class="input-group1" style="position:relative">
        <label for="userId">아이디</label>
        <img th:src="@{/images/person.png}" alt="아이디 아이콘" class="input-icon">
        <input type="text" id="userId" name="userId" placeholder="아이디를 입력하세요" required>
      </div>

      <div class="input-group1" style="position:relative">
        <label for="password">비밀번호</label>
        <img th:src="@{/images/secure.png}" alt="비밀번호 아이콘" class="input-icon">
        <input type="password" id="password" name="password" placeholder="비밀번호를 입력하세요" required>
      </div>

      <div class="login-buttons">
        <button type="button" id="btnLogin" class="btn login-btn">로그인</button>
        <hr class="divider">
        <div class="sub-buttons">
          <button type="button" id="btnGoFindId" class="btn small-btn">아이디 찾기</button>
          <button type="button" id="btnGoFindPw" class="btn small-btn">비밀번호 찾기</button>
        </div>
        <button type="button" id="btnGoJoin" class="btn outline-btn">회원가입</button>
      </div>
    </form>
  </section>
  <button class="btn-open-modal">Modal열기</button>

</main>
<div class="modal">
  <div class="modal_body">
    <h2>모달창 제목</h2>
    <p>모달창 내용 </p>
  </div>
</div>
</body>
</html>