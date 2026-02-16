<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Food Menu</title>

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
    font-size: 24px;
    font-weight: bold;
}

.search-container {
    text-align: center;
    margin: 20px;
}

.search-container input {
    width: 80%;
    max-width: 400px;
    padding: 12px;
    border-radius: 25px;
    border: 1px solid #ccc;
    font-size: 14px;
}

.menu-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: 20px;
    padding: 20px;
    max-width: 1200px;
    margin: auto;
}

.card {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    transition: 0.3s ease;
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 18px rgba(0,0,0,0.15);
}

.card img {
    width: 100%;
    height: 180px;
    object-fit: cover;
}

.card-body {
    padding: 15px;
}

.food-name {
    font-size: 18px;
    font-weight: 600;
}

.price {
    color: #ff512f;
    font-weight: bold;
    margin: 8px 0;
}

.stock {
    font-size: 13px;
    margin-bottom: 8px;
}

.qty-section {
    display: flex;
    align-items: center;
    margin-top: 10px;
}

.qty-btn {
    background: #ff512f;
    border: none;
    color: white;
    font-size: 18px;
    width: 35px;
    height: 35px;
    border-radius: 50%;
    cursor: pointer;
}

.qty-btn:hover {
    background: #dd2476;
}

.qty-section input {
    width: 40px;
    text-align: center;
    border: none;
    font-size: 16px;
    margin: 0 10px;
}

.submit-btn {
    display: block;
    width: 90%;
    max-width: 400px;
    margin: 20px auto;
    padding: 14px;
    background: linear-gradient(to right, #ff512f, #dd2476);
    border: none;
    color: white;
    font-size: 16px;
    border-radius: 8px;
    cursor: pointer;
}

.submit-btn:hover {
    opacity: 0.9;
}

@media (max-width: 600px) {
    .header {
        font-size: 20px;
    }
}

</style>

<script>

// Quantity controls
function increaseQty(id, maxStock) {
    var qty = document.getElementById(id);
    var value = parseInt(qty.value);

    if (value < maxStock) {
        qty.value = value + 1;
    }
}

function decreaseQty(id) {
    var qty = document.getElementById(id);
    var value = parseInt(qty.value);

    if (value > 0) {
        qty.value = value - 1;
    }
}

// Live search
function searchFood() {
    var input = document.getElementById("searchInput").value.toLowerCase();
    var cards = document.getElementsByClassName("card");

    for (var i = 0; i < cards.length; i++) {
        var name = cards[i].getElementsByClassName("food-name")[0]
                           .innerText.toLowerCase();

        if (name.includes(input)) {
            cards[i].style.display = "block";
        } else {
            cards[i].style.display = "none";
        }
    }
}

</script>

</head>
<body>
<!-- CART BUTTON (Top Right Floating) -->
<div style="position:fixed; top:15px; right:15px; z-index:999;">
    <a href="cart.jsp"
       style="background:#ff512f;
              color:white;
              padding:10px 18px;
              border-radius:25px;
              text-decoration:none;
              font-weight:bold;
              box-shadow:0 4px 10px rgba(0,0,0,0.2);">
        🛒 Cart
    </a>
</div>


<div class="header">🍽️ Our Delicious Menu</div>

<div class="search-container">
    <input type="text" id="searchInput"
           placeholder="Search food..."
           onkeyup="searchFood()">
</div>

<form action="addtocarts" method="post">

<div class="menu-container">

<%
Class.forName("com.mysql.cj.jdbc.Driver");
Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/food_order_project",
    "root",
    "root"
);

Statement stmt = con.createStatement();
ResultSet rs = stmt.executeQuery("SELECT * FROM menu");

int i = 0;

while (rs.next()) {

    int fid = rs.getInt("fid");
    int stockQty = rs.getInt("quantity");
%>

<div class="card">

    <img src="<%= request.getContextPath() + "/" + rs.getString("image_url") %>"
         alt="Food Image">

    <div class="card-body">

        <div class="food-name">
            <%= rs.getString("f_item_name") %>
        </div>

        <div class="price">
            ₹ <%= rs.getDouble("price") %>
        </div>

        <div class="stock"
             style="color:<%= stockQty > 0 ? "green" : "red" %>;">
            <%= stockQty > 0 ? "Available (" + stockQty + ")" : "Out of Stock" %>
        </div>

        <div class="qty-section">

            <button type="button"
                    class="qty-btn"
                    onclick="decreaseQty('qty<%=i%>')">−</button>

            <input type="text"
                   id="qty<%=i%>"
                   name="qty"
                   value="0"
                   readonly>

            <button type="button"
                    class="qty-btn"
                    onclick="increaseQty('qty<%=i%>', <%= stockQty %>)"
                    <%= stockQty == 0 ? "disabled" : "" %>>+</button>

        </div>

        <input type="hidden" name="fid" value="<%= fid %>">

    </div>

</div>

<%
    i++;
}
con.close();
%>

</div>

<input type="submit" value="Add to Cart" class="submit-btn">

</form>

</body>
</html>
