<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Admin - SkillConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            margin: 0;
            padding: 0;
            font-family: 'Poppins', sans-serif;
            color: #333;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            padding-bottom: 80px; /* Space for footer height */
        }
        .content {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-left: 280px; /* Space for sidebar */
            margin-top: 70px; /* Space for header */
            padding: 20px;
        }
        .form-container {
            background: #fff;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            max-width: 500px;
            width: 100%;
        }
        .form-control {
            border-radius: 25px;
            padding: 12px 20px;
            border: 1px solid #ddd;
        }
        .form-control:focus {
            border-color: #FF6200;
            box-shadow: 0 0 5px rgba(255, 98, 0, 0.3);
        }
        .btn.btn-submit { /* Increased specificity */
            background: #FF6200; /* Bright orange */
            border: none;
            border-radius: 8px;
            padding: 12px;
            font-size: 16px;
            font-weight: 700;
            color: #fff !important;
            transition: all 0.3s ease;
            text-decoration: none;
            display: block; /* Ensure it’s visible */
            width: 100%; /* Matches w-100 class */
        }
        .btn.btn-submit:hover {
            background: #E65100; /* Deeper orange on hover */
            transform: translateY(-2px);
            color: #fff !important;
        }
        .message {
            text-align: center;
            margin-top: 20px;
            font-size: 16px;
        }
        .success {
            color: #28a745;
        }
        .error {
            color: #dc3545;
        }
        h2 {
            color: #333;
        }
    </style>
</head>
<body>
    <%@ include file="admin_header.jsp" %>
    <%@ include file="admin_sidebar.jsp" %>

    <div class="content">
        <%
            if (session.getAttribute("admin_id") == null || session.getAttribute("username") == null) {
                response.sendRedirect("admin_login.jsp");
            } else {
        %>
        <div class="form-container">
            <h2 class="text-center mb-4">Add New Admin</h2>
            <form action="add_admin.jsp" method="post">
                <div class="mb-3">
                    <input type="text" class="form-control" name="username" placeholder="Username" required>
                </div>
                <div class="mb-3">
                    <input type="email" class="form-control" name="email" placeholder="Email (e.g., name@skillconnect.com)" required>
                </div>
                <div class="mb-3">
                    <input type="password" class="form-control" name="password" placeholder="Password" required>
                </div>
                <button type="submit" class="btn btn-submit w-100">Add Admin</button>
            </form>

            <%
                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    String loggedInUsername = (String) session.getAttribute("username");
                    if (!"root".equals(loggedInUsername)) {
                        out.println("<p class='message error'>Only the root admin can add new admins!</p>");
                    } else {
                        String username = request.getParameter("username");
                        String email = request.getParameter("email");
                        String password = request.getParameter("password");

                        if (!email.endsWith("@skillconnect.com")) {
                            out.println("<p class='message error'>Email must end with @skillconnect.com!</p>");
                        } else {
                            try {
                                java.sql.Connection conn = DBConnection.getConnection();
                                String checkQuery = "SELECT * FROM Admins WHERE username = ? OR email = ?";
                                PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
                                checkStmt.setString(1, username);
                                checkStmt.setString(2, email);
                                ResultSet rs = checkStmt.executeQuery();

                                if (rs.next()) {
                                    out.println("<p class='message error'>Username or email already exists!</p>");
                                } else {
                                    String insertQuery = "INSERT INTO Admins (username, email, password_hash) VALUES (?, ?, ?)";
                                    PreparedStatement insertStmt = conn.prepareStatement(insertQuery);
                                    insertStmt.setString(1, username);
                                    insertStmt.setString(2, email);
                                    insertStmt.setString(3, password);

                                    int rowsAffected = insertStmt.executeUpdate();
                                    if (rowsAffected > 0) {
                                        out.println("<p class='message success'>Admin added successfully!</p>");
                                    } else {
                                        out.println("<p class='message error'>Failed to add admin. Please try again.</p>");
                                    }
                                    insertStmt.close();
                                }
                                rs.close();
                                checkStmt.close();
                                conn.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<p class='message error'>An error occurred: " + e.getMessage() + "</p>");
                            }
                        }
                    }
                }
            %>
        </div>
        <%
            }
        %>
    </div>

    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>