<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="kopo.poly.dto.MailDTO" %>
<%@ page import="kopo.poly.util.CmmUtil" %>
<%
    // NoticeController 함수에서 model 객체에 저장된 값 불러오기
    List<MailDTO> rList = (List<MailDTO>) request.getAttribute("rList");
%>
<%
    String ssUserId = CmmUtil.nvl((String) session.getAttribute("SS_USER_ID")); // 로그인된 회원 아이디
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>공지 리스트</title>
    <link rel="stylesheet" href="/css/notice.css"/>
    <script type="text/javascript">

        //상세보기 이동
        function doDetail(nseq) {
            location.href = "/mail/mailInfo?mailSeq=" + nseq;
        }

    </script>
</head>
<body>
<h2>공지사항</h2>
<hr/>
<br/>
<div class="divTable minimalistBlack">
    <div class="divTableHeading">
        <div class="divTableRow">
            <div class="divTableHead">순번</div>
            <div class="divTableHead">제목</div>
            <div class="divTableHead">받는사람</div>
            <div class="divTableHead">내용</div>
            <div class="divTableHead">발송시간</div>
        </div>
    </div>
    <div class="divTableBody">
        <%
            for (MailDTO dto : rList) {
        %>
        <div class="divTableRow">
            <div class="divTableCell"><%=dto.getMailSeq()%></div>
            <div class="divTableCell"
                 onclick="doDetail('<%=dto.getMailSeq()%>')"><%=CmmUtil.nvl(dto.getTitle())%>
            </div>

            <div class="divTableCell"><%=CmmUtil.nvl(dto.getToMail())%>
            </div>
            <div class="divTableCell"><%=CmmUtil.nvl(dto.getContents())%>
            </div>
            <div class="divTableCell"><%=CmmUtil.nvl(dto.getChgDt())%></div>
        </div>
        <%
            }
        %>
    </div>
</div>
<div class="auth-buttons">
    <% if (ssUserId.equals("")) { %>
    <a href="/user/login?redirect=/mail/mailForm">메일쓰기</a>
    <% } else { %>
    <a href="/mail/mailForm">메일쓰기</a>
    <% } %>
</div>
</body>
</html>
