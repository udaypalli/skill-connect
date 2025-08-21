<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .sidebar {
            background: linear-gradient(180deg, #f5f5f5 0%, #e0e0e0 100%); /* Gradient for depth */
            width: 250px;
            height: 120vh; /* More than screen height */
            position: fixed;
            top: 70px; /* Below header */
            left: 0;
            padding: 20px;
            box-shadow: 4px 0 20px rgba(0, 0, 0, 0.2); /* Deeper shadow for depth */
            font-family: 'Poppins', sans-serif;
        }
        .admin-name {
            font-size: 24px;
            font-weight: 700;
            color: #333; /* Dark gray text */
            margin-bottom: 30px;
            text-align: center;
        }
        .nav-btn {
            display: block;
            width: 100%;
            background: #FF6200; /* Bright orange */
            border: none;
            border-radius: 8px;
            padding: 12px 20px;
            margin-bottom: 15px;
            text-align: center; /* Text centered */
            font-size: 16px;
            font-weight: 700; /* Bold text */
            color: #fff; /* White text on orange */
            transition: all 0.3s ease;
            text-decoration: none;
        }
        .nav-btn:hover {
            background: #E65100; /* Deeper orange on hover */
            transform: translateX(5px);
            color: #fff;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="admin-name">
            <%= session.getAttribute("username") != null ? session.getAttribute("username") : "Admin" %>
        </div>
        <a href="add_admin.jsp" class="nav-btn">Add Admin</a>
        <a href="admin_manage_sprovider.jsp" class="nav-btn">Manage Service Providers</a>
        <a href="admin_payments.jsp" class="nav-btn">Payments</a>
        <a href="admin_reports.jsp" class="nav-btn">Reports</a>
        <a href="admin_promotions.jsp" class="nav-btn">Promotions</a>
        <a href="admin_disputes.jsp" class="nav-btn">Disputes</a>
    </div>
</body>
</html>