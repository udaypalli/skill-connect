<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css">
    <style>
        .navbar-custom {
            background-color: #1976D2;
            padding: 10px 20px;
        }
        .brand-text {
            font-size: 1.8rem;
            font-weight: bold;
            color: white;
        }
        .brand-text .connect {
            color: #F37321;
        }
        .profile-img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            cursor: pointer;
            border: 2px solid white;
        }
        .sidebar {
    position: fixed;
    top: 80px;  /* Adjust this to match navbar height */
    right: -250px;
    width: 250px;
    height: calc(100% - 80px); /* Adjust height to avoid covering the navbar */
    background: #fff;
    box-shadow: -2px 0 10px rgba(0, 0, 0, 0.2);
    transition: 0.3s;
    padding-top: 20px;
    z-index: 1000; /* Add this line to ensure it appears above other content */
}

        .sidebar.active {
            right: 0;
        }
        .sidebar a {
            display: block;
            padding: 12px 20px;
            color: #1976D2;
            font-weight: bold;
            text-decoration: none;
            transition: 0.3s;
        }
        .sidebar a:hover {
            background: #F37321;
            color: white;
        }
        .close-btn {
            position: absolute;
            top: 10px;
            right: 15px;
            font-size: 20px;
            cursor: pointer;
            color: #1976D2;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-custom shadow">
        <div class="container">
            <a class="navbar-brand brand-text" href="index.jsp">
                <span class="skill">Skill</span><span class="connect">Connect</span>
            </a>
            <div class="ms-auto">
                <%@ page import="java.sql.*, java.util.Base64" %>
<%@ page import="com.skillconnect.util.DBConnection" %> <!-- Import your DBConnection class -->
<%
String profileImage = request.getContextPath() + "/images/default-profile.png";
 // Default image
    String userEmail = (String) session.getAttribute("userEmail"); // Assuming session stores email

    if (userEmail != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection(); // Use your DBConnection class
            pstmt = conn.prepareStatement("SELECT profile_image FROM Users WHERE email = ?");
            pstmt.setString(1, userEmail);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Blob imageBlob = rs.getBlob("profile_image");
                if (imageBlob != null && imageBlob.length() > 0) {
                    byte[] imgData = imageBlob.getBytes(1, (int) imageBlob.length());
                    String base64Image = Base64.getEncoder().encodeToString(imgData);
                    profileImage = "data:image/jpeg;base64," + base64Image;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
%>
<img src="<%= profileImage %>" class="profile-img" id="profileIcon">


            </div>
        </div>
    </nav>

    <div class="sidebar" id="sidebarMenu">
        <span class="close-btn" id="closeSidebar">&times;</span>
        <a href="user_edit_profile.jsp">Edit Profile</a>
        <a href="userDashboard.jsp">Dashboard</a>
        <a href="user_transactions.jsp">My Transactions</a>
        <a href="user_notifications.jsp">Notifications</a>
        <a href="user_reviews.jsp">My Reviews</a>
        <a href="customer_support.jsp">Customer Support</a>
        <a href="logout.jsp">Logout</a>
    </div>

    <script>
    document.addEventListener("DOMContentLoaded", function () {
        document.getElementById("profileIcon").addEventListener("click", function() {
            document.getElementById("sidebarMenu").classList.toggle("active");
        });

        document.getElementById("closeSidebar").addEventListener("click", function() {
            document.getElementById("sidebarMenu").classList.remove("active");
        });
    });

    </script>
</body>
</html>
