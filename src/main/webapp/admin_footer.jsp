<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .modern-footer {
            background: linear-gradient(135deg, #001f3f 0%, #001329 100%);
            padding: 20px 0;
            position: fixed;
            bottom: 0;
            width: 100%; /* Full-width footer */
            text-align: center;
            box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
            z-index: 1000;
        }
        .footer-content {
            color: #ffffff;
            font-family: 'Poppins', sans-serif;
            font-size: 14px;
        }
        .footer-content a {
            color: #ff851b;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        .footer-content a:hover {
            color: #ff6600;
            text-decoration: underline;
        }
        .footer-icon {
            color: #ff851b;
            margin-left: 5px;
        }
    </style>
</head>
<body>
    <footer class="modern-footer">
        <div class="footer-content">
            <p>© 2025 SkillConnect Admin Panel - All Rights Reserved</p>
            <p>Manage with precision | <a href="admin_support.jsp">Support</a></p>
            <p>Powered by <a href="#">SkillConnect Team</a> <i class="fas fa-cogs footer-icon"></i></p>
        </div>
    </footer>
</body>
</html>