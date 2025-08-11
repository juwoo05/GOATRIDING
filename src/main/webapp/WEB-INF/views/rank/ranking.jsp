<%--
  Created by IntelliJ IDEA.
  User: data8320-25
  Date: 2025-07-23
  Time: 오후 4:46
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
  <title>랭킹 TOP 5</title>
</head>
<body>
<h2>🏆 TOP 5 랭킹 🏆</h2>
<table border="1" cellpadding="10">
  <thead>
  <tr>
    <th>순위</th>
    <th>이름</th>
    <th>점수</th>
    <th>거리</th>
    <th>탄소</th>
    <th>등록일</th>
  </tr>
  </thead>
  <tbody>
  <c:forEach var="user" items="${top5List}" varStatus="status">
    <tr>
      <td>${status.index + 1}</td>
      <td>${user.name}</td>
      <td>${user.points}</td>
      <td>${user.distance}</td>
      <td>${user.carbonSaved}</td>
      <td>${user.createdAt}</td>
    </tr>
  </c:forEach>
  </tbody>
</table>
</body>
</html>