<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%@ page import="java.security.MessageDigest, java.security.NoSuchAlgorithmException, java.util.Base64" %>
<%
  

    String name = request.getParameter("fullname");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String repeatPassword = request.getParameter("repeatpassword");
    String role = request.getParameter("role");
    String phone = request.getParameter("phone"); // Get phone number from input
    // Store unique phone number


    if (name != null && email != null && password != null && role != null) {
        if (!password.equals(repeatPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match!");
        } else {
            Connection conn = null;
            PreparedStatement stmt = null;
            try {
                conn = DBConnection.getConnection();
                
                // Check if email already exists in either table
                String checkQuery = "SELECT email FROM Users WHERE email = ? UNION SELECT email FROM ServiceProviders WHERE email = ?";
                stmt = conn.prepareStatement(checkQuery);
                stmt.setString(1, email);
                stmt.setString(2, email);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    request.setAttribute("errorMessage", "Email already exists! Please use a different email.");
                } else {
                    // Hash the password using SHA-256
                    String hashedPassword = password;
                   
                    
                    String insertQuery;
                    if (role.equals("user")) {
                        insertQuery = "INSERT INTO Users (name, email, password_hash, phone, location, created_at) VALUES (?, ?, ?, ?, ?, NOW())";
                        stmt = conn.prepareStatement(insertQuery);
                        stmt.setString(1, name);
                        stmt.setString(2, email);
                        stmt.setString(3, hashedPassword);
                        stmt.setString(4, phone); // Dummy phone number
                        stmt.setString(5, "Not Provided"); // Default value for location
                    } else {
                        insertQuery = "INSERT INTO ServiceProviders (name, email, password_hash, phone, expertise, location, pricing, working_hours, availability, verification_status, earnings, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending', 0.00, NOW())";
                        stmt = conn.prepareStatement(insertQuery);
                        stmt.setString(1, name);
                        stmt.setString(2, email);
                        stmt.setString(3, hashedPassword);
                        stmt.setString(4, phone); // Dummy phone number
                        stmt.setString(5, "General"); // Default expertise
                        stmt.setString(6, "Not Provided"); // Default location
                        stmt.setDouble(7, 0.00); // Default pricing
                        stmt.setString(8, "9 AM - 5 PM"); // Default working hours
                        stmt.setBoolean(9, true); // Default availability
                    }
                    
                    int rowsInserted = stmt.executeUpdate();
                    if (rowsInserted > 0) {
                        response.sendRedirect("login.jsp?signup=success");
                    } else {
                        request.setAttribute("errorMessage", "Signup failed! Please try again.");
                    }
                }
            } catch (Exception e) {
                request.setAttribute("errorMessage", "Database Error: " + e.getMessage());
                e.printStackTrace();
            } finally {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Signup | SkillConnect</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        body { background-color: #f8f9fa; }
        .signup-container { max-width: 900px; margin: auto; background: white; border-radius: 10px; 
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); margin-top: 50px; overflow: hidden; }
        .signup-form { padding: 2rem; }
        .signup-header { color: #003366; font-weight: bold; text-align: center; }
        .input-group-text { background: #f0f0f0; border-radius: 5px 0 0 5px; color: #0073e6; }
        .form-control { border-left: none; }
        .btn-orange { background: #ff7300; border: none; padding: 10px; font-size: 1.2rem;
            font-weight: bold; transition: 0.3s; border-radius: 5px; color: white; width: 100%; }
        .btn-orange:hover { background: #e65c00; }
        .signup-right { background: url('signup.png') no-repeat center;
            background-size: cover; min-height: 100%; }
    </style>
</head>
<body>
<div class="container">
    <div class="row signup-container">
        <div class="col-md-6 signup-form">
            <h2 class="signup-header">Create Your Account</h2>
            <% String errorMessage = (String) request.getAttribute("errorMessage");
               if (errorMessage != null) { %>
                <div class="alert alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> <%= errorMessage %></div>
            <% } %>
            <form action="signup.jsp" method="post">
                <div class="form-group mt-3">
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-user"></i></span>
                        <input type="text" name="fullname" class="form-control" placeholder="Full Name" required>
                    </div>
                </div>
                <div class="form-group mt-3">
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-envelope"></i></span>
                        <input type="email" name="email" class="form-control" placeholder="Email" required>
                    </div>
                </div>
                <div class="form-group mt-3">
    <div class="input-group">
        <span class="input-group-text"><i class="fa-solid fa-phone"></i></span>
        <input type="text" name="phone" class="form-control" placeholder="Phone Number" required>
    </div>
</div>
                
                <div class="form-group mt-3">
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                        <input type="password" name="password" class="form-control" placeholder="Password" required>
                    </div>
                </div>
                <div class="form-group mt-3">
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-key"></i></span>
                        <input type="password" name="repeatpassword" class="form-control" placeholder="Confirm Password" required>
                    </div>
                </div>
                <div class="form-group mt-3">
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-user-tag"></i></span>
                        <select name="role" class="form-control" required>
                            <option value="">Select Role</option>
                            <option value="user">User</option>
                            <option value="service_provider">Service Provider</option>
                        </select>
                    </div>
                </div>
                 <!-- Terms & Conditions -->
                <div class="form-group form-check mt-3">
                    <input type="checkbox" class="form-check-input" required>
                    <label class="form-check-label terms">I agree to the <a href="#">Terms & Conditions</a></label>
                </div>
                <div class="form-group text-center mt-4">
                    <button type="submit" class="btn btn-orange">Sign Up</button>
                </div>
                 <!-- Already have an account -->
                <p class="text-center mt-3">Already have an account? <a href="login.jsp" class="text-primary">Login</a></p>
            </form>
        </div>
        <div class="col-md-6 signup-right"></div>
    </div>
</div>

</body>
</html>