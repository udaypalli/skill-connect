<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .header {
            background: #1976D2; /* Blue background */
            padding: 10px 20px; /* Reduced padding for less vertical space */
            box-shadow: 0 2px 15px rgba(0, 0, 0, 0.2); /* Deeper shadow */
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1000;
        }
        .logo {
            font-size: 24px;
            font-weight: 700;
            font-family: 'Poppins', sans-serif;
            display: flex; /* Flex to control spacing */
            align-items: center;
            margin: 0; /* Remove default margin */
        }
        .logo .skill {
            color: #fff; /* White text */
            background: transparent; /* Remove background for cleaner look */
            padding: 0; /* Remove padding for no extra space */
            margin-right: 4px; /* Tight spacing between Skill and Connect */
        }
        .logo .connect {
            color: #FF6200; /* Bright orange for contrast */
        }
        .btn.btn-logout { /* Increased specificity */
            background: #FF6200; /* Bright orange */
            border: none;
            border-radius: 5px;
            padding: 8px 20px;
            font-size: 14px;
            font-weight: 600;
            color: #fff !important; /* White text */
            text-decoration: none;
            transition: all 0.3s ease;
            display: inline-block; /* Ensure visibility */
        }
        .btn.btn-logout:hover {
            background: #E65100; /* Deeper orange on hover */
            transform: translateY(-2px);
            color: #fff !important;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <%
        // Check if logout parameter is present in the URL
        if ("true".equals(request.getParameter("logout"))) {
            session.invalidate(); // Invalidate the entire session
            response.sendRedirect("admin_login.jsp");
            return; // Stop further processing of the page
        }
    %>
    <div class="header">
        <div class="logo">
            <span class="skill">Skill</span><span class="connect">Connect</span>
        </div>
        <a href="admin_header.jsp?logout=true" class="btn btn-logout">Logout</a>
    </div>
</body>
</html>