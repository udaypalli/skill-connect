<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%@ page import="com.skillconnect.util.DBConnection" %>  
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String role = request.getParameter("role");
    String rememberMe = request.getParameter("rememberMe"); // Get checkbox value
    String errorMessage = null;

    if (email != null && password != null && role != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Establish database connection
            conn = DBConnection.getConnection();
            
            // Determine table based on role
            String table = (role.equals("service_provider")) ? "ServiceProviders" : "Users";
            
            // Query to check login credentials
            String query = "SELECT * FROM " + table + " WHERE email = ? AND password_hash = ?";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // Set session attributes
                session.setAttribute("userEmail", email);
                session.setAttribute("userRole", role);

                // Handle "Keep me logged in" with cookies
                if ("on".equals(rememberMe)) {
                    Cookie emailCookie = new Cookie("userEmail", email);
                    Cookie roleCookie = new Cookie("userRole", role);
                    
                    // Set cookie expiry to 30 days (30 * 24 * 60 * 60 seconds)
                    int thirtyDays = 30 * 24 * 60 * 60;
                    emailCookie.setMaxAge(thirtyDays);
                    roleCookie.setMaxAge(thirtyDays);
                    
                    // Add cookies to response
                    response.addCookie(emailCookie);
                    response.addCookie(roleCookie);
                }

                // Redirect based on role
                if (role.equals("user")) {
                    response.sendRedirect("user_edit_profile.jsp"); // Redirect to User Dashboard
                } else {
                    response.sendRedirect("service_provider_dashboard.jsp"); // Redirect to Provider Dashboard
                }
                return; 
            } else {
                errorMessage = "Invalid email or password. Please try again.";
            }
        } catch (Exception e) {
            errorMessage = "Database connection error: " + e.getMessage();
            e.printStackTrace();
        } finally {
            // Close resources
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | SkillConnect</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        body { background-color: #f8f9fa; }
        .login-container {
            max-width: 800px;
            margin: auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            margin-top: 50px;
            overflow: hidden;
        }
        .login-form { padding: 2rem; }
        .login-header { color: #003366; font-weight: bold; text-align: center; }
        .input-group-text { background: #f0f0f0; color: #0073e6; min-width: 45px; text-align: center; }
        .form-control { border-left: none; }
        .btn-orange {
            background: #ff7300; border: none; padding: 10px;
            font-size: 1.2rem; font-weight: bold; transition: 0.3s;
            border-radius: 5px; color: white; width: 100%;
        }
        .btn-orange:hover { background: #e65c00; }
        .login-right { background: url('login.png') no-repeat center;
            background-size: cover; min-height: 100%; }
        .error-alert { margin-top: 10px; display: <%= (errorMessage != null) ? "block" : "none" %>; }
    </style>
</head>
<body>

<div class="container">
    <div class="row login-container">
        <!-- Left Side - Form -->
        <div class="col-md-6 login-form">
            <h2 class="login-header">Welcome Back</h2>
            
            <%-- Show error message dynamically --%>
            <% if (errorMessage != null) { %>
                <div class="alert alert-danger error-alert">
                    <i class="fa-solid fa-triangle-exclamation"></i> <%= errorMessage %>
                </div>
            <% } %>

            <form action="login.jsp" method="post">
                <!-- Email -->
                <div class="form-group mt-3">
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-envelope"></i></span>
                        <input type="email" name="email" class="form-control" placeholder="Email" required>
                    </div>
                </div>
                
                <!-- Password -->
                <div class="form-group mt-3">
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                        <input type="password" name="password" class="form-control" placeholder="Password" required>
                    </div>
                </div>

                <!-- User Role Dropdown -->
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

                <!-- Keep me logged in -->
                <div class="form-group form-check mt-3">
                    <input type="checkbox" name="rememberMe" class="form-check-input">
                    <label class="form-check-label">Keep me logged in</label>
                </div>

                <!-- Login Button -->
                <div class="form-group text-center mt-4">
                    <button type="submit" class="btn btn-orange">Login</button>
                </div>

                <!-- Forgot Password & Signup -->
                <p class="text-center mt-3">
                    <a href="#" class="text-danger">Forgot Password?</a>
                    <br>
                    Don't have an account? <a href="signup.jsp" class="text-primary">Sign Up</a>
                </p>
            </form>
        </div>
        
        <!-- Right Side - Image -->
        <div class="col-md-6 login-right"></div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="assets/js/bootstrap.bundle.min.js"></script>

</body>
</html>