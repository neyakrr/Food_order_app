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
<%Class.forName("com.mysql.cj.jdbc.Driver");

Connection con = DriverManager.getConnection(
		"jdbc:mysql://localhost:3306/food_order_project",
		"root",
		"root"
		);
Statement stmt=con.createStatement();
ResultSet rs=stmt.executeQuery("Select * from menu");
%>
<h2>Menu List</h2>
<table border='1'>
<tr><th>ID</th><th>Food Name</th><th>Price</th><th>Quantity</th></tr>
<% 
while(rs.next())
{
	%>
	<tr>
	<td> <%= rs.getInt("fid") %></td>
	<td> <%= rs.getString("f_item_name") %></td>
	<td> <%= rs.getDouble("price") %></td>
	<td> <%= rs.getInt("quantity") %></td>
	</tr>
	<% 
}
 %>
 <br><br>
 </table>
 <form action="Update.jsp">
 <input type="submit" value="Update"></form>

</body>
</html>