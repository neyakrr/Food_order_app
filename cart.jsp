<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ page import="java.sql.*,java.math.*" %>


<%
String[] fids = (String[]) session.getAttribute("fid");
String[] qtys = (String[]) session.getAttribute("qty");

BigDecimal total = BigDecimal.ZERO;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Your Cart</title>

<style>

body {
    margin: 0;
    font-family: 'Segoe UI', sans-serif;
    background: #f8f8f8;
}

.header {
    background: linear-gradient(to right, #ff512f, #dd2476);
    color: white;
    padding: 18px;
    text-align: center;
    font-size: 22px;
    font-weight: bold;
}

.cart-container {
    padding: 15px;
    max-width: 800px;
    margin: auto;
}

.cart-card {
    background: white;
    border-radius: 12px;
    padding: 15px;
    margin-bottom: 15px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}

.food-name {
    font-size: 16px;
    font-weight: 600;
}

.price {
    color: #ff512f;
    font-weight: bold;
}

.total-box {
    background: white;
    padding: 15px;
    border-radius: 12px;
    font-weight: bold;
    font-size: 18px;
    text-align: right;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}

.btn {
    display: block;
    text-align: center;
    padding: 14px;
    margin-top: 15px;
    border-radius: 10px;
    text-decoration: none;
    font-weight: bold;
}

.btn-primary {
    background: linear-gradient(to right, #ff512f, #dd2476);
    color: white;
}

.btn-ghost {
    background: #f1f5f9;
    color: #111;
}

</style>
</head>
<body>

<div class="header">🛒 Your Cart</div>

<div class="cart-container">

<%
if (fids != null && qtys != null) {

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/food_order_project",
        "root", "root");

    PreparedStatement ps = con.prepareStatement(
        "SELECT f_item_name, price FROM menu WHERE fid=?");

    for (int i = 0; i < fids.length; i++) {

        int fid = Integer.parseInt(fids[i]);
        int qty = Integer.parseInt(qtys[i]);

        if (qty <= 0) continue;

        ps.setInt(1, fid);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {

            String name = rs.getString("f_item_name");
            BigDecimal price = rs.getBigDecimal("price");
            BigDecimal lineTotal = price.multiply(BigDecimal.valueOf(qty));

            total = total.add(lineTotal);
%>

<div class="cart-card">
    <div class="food-name"><%= name %></div>
    <div>Qty: <%= qty %></div>
    <div class="price">₹ <%= lineTotal %></div>
</div>

<%
        }
    }
    con.close();
}
%>

<div class="total-box">
    Total: ₹ <%= total %>
</div>

<a href="menu.jsp" class="btn btn-ghost">← Back to Menu</a>
<a href="placed" class="btn btn-primary">Place Order</a>

</div>

</body>
</html>


