​
<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%@ page import= "java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%Class.forName("com.mysql.cj.jdbc.Driver");

Connection con = DriverManager.getConnection(
"jdbc:mysql://localhost:3306/food_order_project",
"root",
"root"
);
%>
<%
String action = request.getParameter("action");
if("edit".equals(action))
{
int fid = Integer.parseInt(request.getParameter("fid"));
String f_item_name = request.getParameter("f_item_name");
Double price = Double.parseDouble(request.getParameter("price"));
int quantity = Integer.parseInt(request.getParameter("quantity"));
String sql = "update menu set f_item_name=?,price=?,quantity=? where fid=?";
PreparedStatement ps = con.prepareStatement(sql);
ps.setString(1, f_item_name);
ps.setDouble(2, price);
ps.setInt(3, quantity);
ps.setInt(4, fid);

ps.executeUpdate();

}else if("delete".equals(action)){
int fid = Integer.parseInt(request.getParameter("fid"));
String sql = "delete from menu where fid=?";
PreparedStatement ps = con.prepareStatement(sql);
ps.setInt(1,fid);
ps.executeUpdate();
}
else if("add".equals(action)){
	String name = request.getParameter("fname");
	double price = Double.parseDouble(request.getParameter("fprice"));
	int quantity = Integer.parseInt(request.getParameter("fquantity"));
	String sql = "insert into menu(f_item_name, price, quantity) values(?,?,?)";
	PreparedStatement ps = con.prepareStatement(sql);
	ps.setString(1, name);
	ps.setDouble(2, price);
	ps.setInt(3, quantity);

	ps.executeUpdate();
}
%>
<h2>Menu List</h2>

<table border='1'>
<tr><th>ID</th><th>Food Name</th><th>Price</th><th>Quantity</th><th>Action</th></tr>
<%
Statement stmt=con.createStatement();
ResultSet rs=stmt.executeQuery("Select * from menu");
while(rs.next())
{
%>
<tr>
<td> <%= rs.getInt("fid") %></td>
<td> <%= rs.getString("f_item_name") %></td>
<td> <%= rs.getDouble("price") %></td>
<td>
<form action = Update.jsp method=post>
<input type="hidden" name="fid" value="<%= rs.getInt("fid") %>">
<input type="hidden" name="f_item_name" value="<%= rs.getString("f_item_name") %>">
<input type="hidden" name="price" value="<%= rs.getDouble("price") %>">
<input type="number" name="quantity" value= <%= rs.getInt("quantity") %>>
<button type="submit" name = "action" value = "edit">Update</button>
</form>
</td>
<td>
<form action="Update.jsp" method="post" style="display:inline;">
<input type="hidden" name="fid" value="<%= rs.getInt("fid") %>">
<button type="submit" onclick="return confirm('Delete this item?');" name = "action" value = "delete">Delete</button>
</form>
</td>
</tr>
<%
}

%>
<form action="add.jsp">
<button type="submit" name="action" value="add">Add Item</button>
</form>



</body>
</html>