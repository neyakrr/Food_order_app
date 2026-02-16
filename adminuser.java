package h1;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.sql.*;

/**
 * Servlet implementation class adminuser
 */
@WebServlet("/adminuser")
public class adminuser extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public adminuser() {
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
		int id=Integer.parseInt(request.getParameter("id"));//change according admin html page
		String name=request.getParameter("name");//change according admin html page
		String pass=request.getParameter("pass");//change according admin html page
		PrintWriter o=response.getWriter();
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			Connection con=DriverManager.getConnection("jdbc:mysql://localhost:3306/food_order_project","root","root");//change the portal and localhost
			Statement stmt=con.createStatement();
			ResultSet rs=stmt.executeQuery("Select * from admin");
			int f=0;
			while(rs.next()) {
				if(id==rs.getInt("id") && name.equals(rs.getString("name")) && pass.equals(rs.getString("password"))) {
					f=1;
					response.sendRedirect("Admin2.html");//change it
				}
			}
			if(f==0) {
			o.println("Your credentials are invalid");
			o.println("Please give correct data");
			o.println("<a href='admin.html'>Back To Login</a>");
			}
			
		}
		catch(Exception e) {
			o.println("Error:"+e.getMessage());
		}
	}

}
