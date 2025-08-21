<%@ page import="java.sql.*" %>
<%
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int providerId = Integer.parseInt(request.getParameter("providerId"));
    int rating = Integer.parseInt(request.getParameter("rating"));
    String reviewText = request.getParameter("reviewText");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/SkillConnect", "root", "uday");

        // Get user_id from email
        String userQuery = "SELECT user_id FROM Users WHERE email = ?";
        PreparedStatement userStmt = conn.prepareStatement(userQuery);
        userStmt.setString(1, userEmail);
        ResultSet userRs = userStmt.executeQuery();
        int userId = 0;
        if (userRs.next()) {
            userId = userRs.getInt("user_id");
        }
        userRs.close();
        userStmt.close();

        // Insert review
        String insertQuery = "INSERT INTO Reviews (user_id, provider_id, rating, review_text) VALUES (?, ?, ?, ?)";
        PreparedStatement insertStmt = conn.prepareStatement(insertQuery);
        insertStmt.setInt(1, userId);
        insertStmt.setInt(2, providerId);
        insertStmt.setInt(3, rating);
        insertStmt.setString(4, reviewText);
        insertStmt.executeUpdate();
        insertStmt.close();

        conn.close();
        response.sendRedirect("user_reviews.jsp");
    } catch (Exception e) {
        e.printStackTrace();
    }
%>