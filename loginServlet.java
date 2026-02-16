package h1;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.sql.*;

/**
 * Servlet implementation class loginservlet
 */
@WebServlet("/loginServlet")
public class loginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public loginServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
		response.setContentType("text/html");
		PrintWriter out = response.getWriter();
		
		String x = request.getParameter("tableNumber");
		int table_no = Integer.parseInt(x);
		String Username = request.getParameter("Username");
		String PhoneNo = request.getParameter("phoneNumber");
		String emailId = request.getParameter("emailnumber");
		HttpSession session = request.getSession();
		session.setAttribute("t_no", table_no);
		
		try {
			
			Class.forName("com.mysql.cj.jdbc.Driver");
			
			Connection con = DriverManager.getConnection(
					"jdbc:mysql://localhost:3306/food_order_project",
					"root",
					"root"
					);
			Statement stmt = con.createStatement();
			
			ResultSet table = stmt.executeQuery("select * from table_details where table_id="+table_no);
			
			if(!table.next()) {
				
				response.sendRedirect("user.html");
			}else {
				
				String sql = "update table_details set name=?,phone_number=?,email_id=? where table_id=?";
				
				PreparedStatement ps = con.prepareStatement(sql);
				ps.setString(1, Username);
				ps.setString(2, PhoneNo);
				ps.setString(3, emailId);
				ps.setInt(4, table_no);
				
			
			 int i = ps.executeUpdate();
			   if(i > 0) {
				   response.sendRedirect("menu.jsp");
				   
			   }else {
				   out.println("<h3>Insert failed!</h3>");
			   }
			}
			
		}catch(Exception e) {
			out.println("Error: "+e.getMessage());
		}
	}

}
