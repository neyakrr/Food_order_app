package h1;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/addtocarts")
public class addtocarts extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter o = response.getWriter();

        String[] fids = request.getParameterValues("fid");
        String[] qtys = request.getParameterValues("qty");

        if (fids == null || qtys == null || fids.length == 0) {
            o.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Cart</title></head><body>");
            o.println("<h3>No items selected.</h3>");
            o.println("<a href='menu.jsp'>Back to Menu</a>");
            o.println("</body></html>");
            return;
        }

        int len = Math.min(fids.length, qtys.length);

        BigDecimal total = BigDecimal.ZERO;
        int[] quan = new int[len];
        String[] items = new String[len];

        o.println("<!DOCTYPE html>");
        o.println("<html lang='en'><head><meta charset='UTF-8'><title>Cart Summary</title>");
        o.println("<style>");
        o.println("body{font-family:Segoe UI,Arial,sans-serif;line-height:1.6;margin:20px;}");
        o.println("table{border-collapse:collapse;width:100%;max-width:800px;background:#fff;border:1px solid #e2e8f0;}");
        o.println("th,td{padding:10px 12px;border-bottom:1px solid #e2e8f0;text-align:left;}");
        o.println("th{background:#0ea5e9;color:#fff;}");
        o.println(".total{font-weight:800;font-size:1.1rem;}");
        o.println(".actions{margin-top:14px;display:flex;gap:10px;flex-wrap:wrap;}");
        o.println(".btn{display:inline-block;padding:10px 14px;border-radius:10px;text-decoration:none;font-weight:700;}");
        o.println(".btn.primary{background:#0ea5e9;color:#fff;}");
        o.println(".btn.ghost{background:#f8fafc;color:#0f172a;border:1px solid #e2e8f0;}");
        o.println("</style>");
        o.println("</head><body>");
        o.println("<h2>🛒 Order Summary</h2>");
        o.println("<table>");
        o.println("<tr><th>Food Name</th><th>Unit Price</th><th>Quantity</th><th>Line Total</th></tr>");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/food_order_project", "root", "root");
                 PreparedStatement ps = con.prepareStatement("SELECT f_item_name, price, quantity FROM menu WHERE fid = ?")) {

                for (int i = 0; i < len; i++) {
                    if (fids[i] == null || qtys[i] == null || fids[i].isEmpty() || qtys[i].isEmpty()) continue;

                    int fid = Integer.parseInt(fids[i].trim());
                    int qty = Integer.parseInt(qtys[i].trim());
                    if (qty <= 0) continue;

                    ps.setInt(1, fid);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) continue;

                        String name = rs.getString("f_item_name");
                        BigDecimal unitPrice = rs.getBigDecimal("price");
                        if (unitPrice == null) unitPrice = BigDecimal.valueOf(rs.getDouble("price"));

                        int stock = rs.getInt("quantity");
                        if (qty > stock) qty = stock;
                        if (qty <= 0) continue;

                        BigDecimal lineTotal = unitPrice.multiply(BigDecimal.valueOf(qty));
                        total = total.add(lineTotal);

                        quan[i] = qty;
                        items[i] = name;

                        o.println("<tr>");
                        o.println("<td>" + escapeHtml(name) + "</td>");
                        o.println("<td>₹ " + unitPrice.setScale(2, RoundingMode.HALF_UP) + "</td>");
                        o.println("<td>" + qty + "</td>");
                        o.println("<td>₹ " + lineTotal.setScale(2, RoundingMode.HALF_UP) + "</td>");
                        o.println("</tr>");
                    }
                }
            }
        } catch (Exception e) {
            o.println("<tr><td colspan='4' style='color:#b91c1c;'>Error: " + escapeHtml(e.getMessage()) + "</td></tr>");
        }

        // Total row
        o.println("<tr><td colspan='3' class='total' style='text-align:right'>TOTAL</td>");
        o.println("<td class='total'>₹ " + total.setScale(2, RoundingMode.HALF_UP) + "</td></tr>");
        o.println("</table>");

        HttpSession ss = request.getSession();
        ss.setAttribute("fid", fids);
        ss.setAttribute("qty", quan);
        ss.setAttribute("items", items);

        o.println("<div class='actions'>");
        o.println("<a class='btn ghost' href='menu.jsp'>Back to Menu</a>");
        o.println("<a class='btn primary' href='placed'>Place The Order</a>");
        o.println("</div>");
        o.println("</body></html>");
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}