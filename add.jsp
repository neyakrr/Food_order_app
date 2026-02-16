<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import= "java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Insert title here</title>
</head>
<body>
<form action= Update.jsp>
Enter Food Name: 
<input type="text" name="fname">
Enter Food Price: 
<input type="text" name="fprice">
Enter Food Quantity: 
<input type="text" name="fquantity">
<button type="submit" value="add" name="action">Add to menu</button></form>
</body>
</html>