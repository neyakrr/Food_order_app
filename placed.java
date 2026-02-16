package h1;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/placed")
public class placed extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public placed() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        HttpSession ss = request.getSession(false);
        PrintWriter out = response.getWriter();

        int table_no = (int) ss.getAttribute("t_no");
        String[] fid = (String[]) ss.getAttribute("fid");
        int[] qty = (int[]) ss.getAttribute("qty");
        String[] items = (String[]) ss.getAttribute("items");

        // Start HTML
        out.println("<html><head><title>Order Placed</title>");

        // Embedded CSS
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; background: linear-gradient(to right,#4facfe,#00f2fe); padding:50px; }");
        out.println(".container { background:white; max-width:800px; margin:auto; padding:30px; border-radius:10px; box-shadow:0 10px 25px rgba(0,0,0,0.3); text-align:center; }");
        out.println("h2 { color:#333; margin-bottom:20px; }");
        out.println("table { width:100%; border-collapse:collapse; margin-top:20px; }");
        out.println("th { background:#00c6ff; color:white; padding:12px; }");
        out.println("td { padding:10px; text-align:center; }");
        out.println("tr:nth-child(even) { background:#f2f2f2; }");
        out.println(".total { text-align:right; font-size:18px; font-weight:bold; margin-top:15px; }");
        out.println("a { display:inline-block; margin:15px 10px 0 0; padding:10px 20px; background:#00c6ff; color:white; text-decoration:none; border-radius:5px; font-weight:bold; transition:0.3s; }");
        out.println("a:hover { background:#009fe3; }");
        out.println("</style>");

        out.println("</head><body><div class='container'>");
        out.println("<h2> Your Order Summary</h2>");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/food_order_project",
                    "root",
                    "root"
            );

            // Insert order details
            String sqlInsert = "INSERT INTO order_details(table_id, order_id, item_name, quantity, price) "
                    + "VALUES(?, ?, ?, ?, (SELECT price FROM menu WHERE fid = ?)*?)";

            PreparedStatement psInsert = con.prepareStatement(sqlInsert);
            for (int i = 0; i < fid.length; i++) {
                psInsert.setInt(1, table_no);
                psInsert.setInt(2, table_no);
                psInsert.setString(3, items[i]);
                psInsert.setInt(4, qty[i]);
                psInsert.setInt(5, Integer.parseInt(fid[i]));
                psInsert.setInt(6, qty[i]);
                psInsert.executeUpdate();
            }

            // Check stock availability
            Statement stmt = con.createStatement();
            for (int i = 0; i < fid.length; i++) {
                ResultSet table = stmt.executeQuery("SELECT * FROM menu WHERE fid=" + fid[i]);
                if (table.next() && (table.getInt("quantity") - qty[i]) < 0) {
                    response.sendRedirect("menu.jsp?itemId=" + qty[i]);
                    return;
                }
            }

            // Update stock
            String sqlUpdate = "UPDATE menu SET quantity=(quantity - ?) WHERE fid=?";
            for (int i = 0; i < fid.length; i++) {
                PreparedStatement psUpdate = con.prepareStatement(sqlUpdate);
                psUpdate.setInt(1, qty[i]);
                psUpdate.setString(2, fid[i]);
                psUpdate.executeUpdate();
            }

            // Display order summary
            out.println("<table border='1'>");
            out.println("<tr><th>Food Name</th><th>Quantity</th><th>Price</th></tr>");
            int total = 0;
            PreparedStatement psSelect = con.prepareStatement("SELECT price FROM menu WHERE fid=?");

            for (int i = 0; i < fid.length; i++) {
                psSelect.setInt(1, Integer.parseInt(fid[i]));
                ResultSet rs = psSelect.executeQuery();
                if (rs.next()) {
                    int price = rs.getInt("price") * qty[i];
                    total += price;

                    out.println("<tr>");
                   
                    out.println("<td>" + items[i] + "</td>");
                    out.println("<td>" + qty[i] + "</td>");
                    out.println("<td> " + price + "</td>");
                    out.println("</tr>");
                }
                rs.close();
            }
            out.println("</table>");
            out.println("<div class='total'>TOTAL PRICE:  " + total + "</div>");
            out.println("<h3> YOUR ORDER HAS BEEN PLACED SUCCESSFULLY!</h3>");
            out.println("<a href='menu.jsp'>Back to Menu</a>");

            con.close();

        } catch (Exception e) {
            out.println("<h3 style='color:red;'>Error: " + e.getMessage() + "</h3>");
            out.println("<a href='menu.jsp'>Back to Menu</a>");
        }

        out.println("</div></body></html>");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}