<%@ page contentType="text/html; charset=UTF-8" %>
<html>
<head>
  <title>메일 발송</title>
  <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 40px;
    }

    label {
      display: block;
      margin-top: 20px;
    }

    input, textarea {
      width: 400px;
      padding: 8px;
      box-sizing: border-box;
    }

    button {
      margin-top: 20px;
      padding: 10px 20px;
      background-color: #1976d2;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }

    button:hover {
      background-color: #125ea3;
    }

    #result {
      margin-top: 30px;
      font-weight: bold;
    }
  </style>
  <script>
    $(document).ready(function () {
      $("#sendBtn").click(function () {
        const toMail = $("#toMail").val();
        const title = $("#title").val();
        const contents = $("#contents").val();

        if (!toMail || !title || !contents) {
          alert("모든 항목을 입력해주세요.");
          return;
        }

        $.ajax({
          type: "POST",
          url: "/mail/sendMail",
          data: {
            toMail: toMail,
            title: title,
            contents: contents
          }
        }).then(
                function(json) {
                  alert(json.msg);
                }
        )
      });
    });
  </script>
</head>
<body>

<h2>메일 발송</h2>

<label for="toMail">받는 사람 이메일</label>
<input type="email" id="toMail" name="toMail" placeholder="example@domain.com" />

<label for="title">메일 제목</label>
<input type="text" id="title" name="title" placeholder="메일 제목 입력" />

<label for="contents">메일 내용</label>
<textarea id="contents" name="contents" rows="8" placeholder="내용 입력"></textarea>

<button id="sendBtn">메일 발송</button>

<div id="result"></div>

</body>
</html>