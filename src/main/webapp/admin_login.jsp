<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.skillconnect.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - SkillConnect</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <style>
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: 'Poppins', sans-serif;
        }
        .login-container {
            background: #fff;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header h2 {
            color: #4a00e0;
            font-weight: 700;
        }
        .form-control {
            border-radius: 25px;
            padding: 12px 20px;
            border: 1px solid #ddd;
        }
        .form-control:focus {
            border-color: #4a00e0;
            box-shadow: 0 0 5px rgba(74, 0, 224, 0.3);
        }
        .btn-login {
            background: linear-gradient(90deg, #4a00e0, #8e2de2);
            border: none;
            border-radius: 25px;
            padding: 12px;
            font-size: 16px;
            font-weight: 600;
            color: #fff;
            transition: all 0.3s ease;
        }
        .btn-login:hover {
            background: linear-gradient(90deg, #8e2de2, #4a00e0);
            transform: translateY(-2px);
        }
        .error-message {
            color: #dc3545;
            text-align: center;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h2>Admin Login</h2>
            <p class="text-muted">Welcome to SkillConnect Admin Portal</p>
        </div>
        <form action="admin_login.jsp" method="post">
            <div class="mb-3">
                <input type="text" class="form-control" name="username" placeholder="Username" required>
            </div>
            <div class="mb-3">
                <input type="password" class="form-control" name="password" placeholder="Password" required>
            </div>
            <button type="submit" class="btn btn-login w-100">Login</button>
        </form>

        <%-- JSP Logic for Login --%>
        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String username = request.getParameter("username");
                String password = request.getParameter("password");

                try {
                    java.sql.Connection conn = DBConnection.getConnection(); // Assuming DBConnection class exists
                    String query = "SELECT * FROM Admins WHERE username = ? AND password_hash = ?";
                    java.sql.PreparedStatement pstmt = conn.prepareStatement(query);
                    pstmt.setString(1, username);
                    pstmt.setString(2, password); // In production, use hashed password comparison

                    java.sql.ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        // Create session for admin
                        session.setAttribute("admin_id", rs.getInt("admin_id"));
                        session.setAttribute("username", rs.getString("username"));
                        response.sendRedirect("add_admin.jsp");
                    } else {
                        out.println("<p class='error-message'>Invalid username or password!</p>");
                    }
                    rs.close();
                    pstmt.close();
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<p class='error-message'>Something went wrong. Please try again.</p>");
                }
            }
        %>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>