<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.sql.*,java.math.BigDecimal,java.io.*,
com.itextpdf.text.*,com.itextpdf.text.pdf.*,
javax.mail.*,javax.mail.internet.*,java.util.*" %>

<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">


<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Orders by Table</title>

<style>
body { font-family: Arial; background:#f4f6f8; padding:20px; }
h2 { text-align:center; }
h3 { color:#0ea5e9; margin-top:30px; }
table { width:100%; border-collapse:collapse; margin-bottom:20px; background:#fff; }
th,td { border:1px solid #ccc; padding:10px; }
thead { background:#0ea5e9; color:white; }
button { padding:8px 12px; background:#0ea5e9; color:white; border:none; border-radius:5px; cursor:pointer; }
button:hover { background:#0284c7; }
.msg { padding:10px; margin-bottom:15px; border-radius:5px; }
.ok { background:#d4edda; color:#155724; }
.err { background:#f8d7da; color:#721c24; }
</style>
</head>
<body>

<h2>Orders Grouped by Table</h2>

<%
String url  = "jdbc:mysql://localhost:3306/food_order_project";
String dbUser = "root";
String dbPass = "root";

String message = null;
String error = null;

try {
    request.setCharacterEncoding("UTF-8");

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        String action = request.getParameter("action");

        if ("generateBill".equals(action)) {

            int tableId = Integer.parseInt(request.getParameter("table_id"));

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, dbUser, dbPass);

            // 1️⃣ Calculate total
            PreparedStatement totalStmt = con.prepareStatement(
                "SELECT SUM(quantity * price) AS total FROM order_details WHERE table_id=?");
            totalStmt.setInt(1, tableId);
            ResultSet totalRs = totalStmt.executeQuery();

            double totalAmount = 0;
            if (totalRs.next()) {
                totalAmount = totalRs.getDouble("total");
            }

            // 2️⃣ Get email
            PreparedStatement emailStmt = con.prepareStatement(
                "SELECT email_id FROM table_details WHERE table_id=?");
            emailStmt.setInt(1, tableId);
            ResultSet emailRs = emailStmt.executeQuery();

            String customerEmail = null;
            if (emailRs.next()) {
                customerEmail = emailRs.getString("email_id");
            }

            // 3️⃣ Generate PDF
            String filePath = application.getRealPath("/") + "bill_" + tableId + ".pdf";

            Document document = new Document();
            PdfWriter.getInstance(document, new FileOutputStream(filePath));
            document.open();

            document.add(new Paragraph("Restaurant Bill"));
            document.add(new Paragraph("Table Number: " + tableId));
            document.add(new Paragraph(" "));
            document.add(new Paragraph("Total Amount: ₹ " + totalAmount));

            document.close();

            // 4️⃣ Send Email
            if (customerEmail != null) {

                final String from = "neyakrr@gmail.com";
                final String password = "sxsgrmwyfxwfevjc";

                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");

                Session mailSession = Session.getInstance(props,
                    new Authenticator() {
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(from, password);
                        }
                    });

                Message msg = new MimeMessage(mailSession);
                msg.setFrom(new InternetAddress(from));
                msg.setRecipients(Message.RecipientType.TO,
                        InternetAddress.parse(customerEmail));
                msg.setSubject("Your Restaurant Bill - Table " + tableId);

                MimeBodyPart bodyPart = new MimeBodyPart();
                bodyPart.setText("Please find attached your restaurant bill.");

                MimeBodyPart attachment = new MimeBodyPart();
                attachment.attachFile(new File(filePath));

                Multipart multipart = new MimeMultipart();
                multipart.addBodyPart(bodyPart);
                multipart.addBodyPart(attachment);

                msg.setContent(multipart);

                Transport.send(msg);
            }

            // 5️⃣ Delete orders
            PreparedStatement delStmt = con.prepareStatement(
                "DELETE FROM order_details WHERE table_id=?");
            delStmt.setInt(1, tableId);
            int deleted = delStmt.executeUpdate();

            message = "Bill sent successfully to email. Table " + tableId +
                      " cleared. Items removed: " + deleted;

            con.close();
        }
    }
} catch (Exception e) {
    error = "Error: " + e.getMessage();
}

if (message != null) {
%>
<div class="msg ok"><%= message %></div>
<% }
if (error != null) { %>
<div class="msg err"><%= error %></div>
<% } %>

<%
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(url, dbUser, dbPass);

    ps = con.prepareStatement(
        "SELECT table_id, order_id, item_name, quantity, price FROM order_details ORDER BY table_id");

    rs = ps.executeQuery();

    Integer currentTable = null;
    boolean openTable = false;

    while (rs.next()) {

        int tableId = rs.getInt("table_id");

        if (currentTable == null || tableId != currentTable) {

            if (openTable) {
%>
</tbody></table>
<%
            }

            currentTable = tableId;
            openTable = true;
%>

<h3>Table <%= currentTable %></h3>

<form method="post">
<input type="hidden" name="action" value="generateBill">
<input type="hidden" name="table_id" value="<%= currentTable %>">
<button type="submit">Generate Bill</button>
</form>

<table>
<thead>
<tr>
<th>Order ID</th>
<th>Item</th>
<th>Quantity</th>
<th>Price</th>
</tr>
</thead>
<tbody>

<%
        }
%>
<tr>
<td><%= rs.getInt("order_id") %></td>
<td><%= rs.getString("item_name") %></td>
<td><%= rs.getInt("quantity") %></td>
<td>₹ <%= rs.getBigDecimal("price") %></td>
</tr>
<%
    }

    if (openTable) {
%>
</tbody></table>
<%
    }

} catch (Exception e) {
%>
<div class="msg err">Error loading orders: <%= e.getMessage() %></div>
<%
} finally {
    if (rs != null) rs.close();
    if (ps != null) ps.close();
    if (con != null) con.close();
}
%>

<br>
<a href="admin2.html">Back</a>

</body>
</html>
