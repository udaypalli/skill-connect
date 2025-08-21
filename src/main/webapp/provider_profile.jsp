<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // Initialize variables
    String providerName = "";
    String expertise = "";
    String location = "";
    String workingHours = "";
    String reviewsCount = "0";
    String averageRating = "0.0";
    String memberSince = "";
    String profileImage = ""; // Placeholder for profile image URL
    String services = ""; // To store comma-separated services from ServiceProviders

    // Get provider ID from request (assuming it's passed as a parameter)
    int providerId = Integer.parseInt(request.getParameter("id"));

    // Database connection
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection(); // Get connection from DBConnection

        // Fetch provider details
        String providerQuery = "SELECT name, expertise, location, working_hours, created_at, profile_image, services FROM ServiceProviders WHERE provider_id = ?";
        pstmt = conn.prepareStatement(providerQuery);
        pstmt.setInt(1, providerId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            providerName = rs.getString("name");
            expertise = rs.getString("expertise");
            location = rs.getString("location");
            workingHours = rs.getString("working_hours");
            memberSince = rs.getString("created_at").split(" ")[0]; // Extract date only
            profileImage = rs.getString("profile_image"); // Assuming profile_image stores the URL
            services = rs.getString("services"); // Fetch comma-separated service IDs
        }

        // Fetch reviews and ratings
        String reviewQuery = "SELECT COUNT(*) AS review_count, AVG(rating) AS avg_rating FROM Reviews WHERE provider_id = ?";
        pstmt = conn.prepareStatement(reviewQuery);
        pstmt.setInt(1, providerId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            reviewsCount = rs.getString("review_count");
            averageRating = String.format("%.1f", rs.getDouble("avg_rating"));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        // Close resources
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= providerName %> - Provider Profile</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Arial', sans-serif;
        }
        .profile-container {
            max-width: 1200px;
            margin: 20px auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.1);
        }
        .profile-header {
            display: flex;
            align-items: center;
            border-bottom: 1px solid #ddd;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .profile-image {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 20px;
        }
        .profile-info {
            flex-grow: 1;
        }
        .profile-info h1 {
            margin: 0;
            font-size: 28px;
            color: #333;
        }
        .profile-info p {
            margin: 5px 0;
            color: #666;
        }
        .rating-stars {
            color: #ffc107;
        }
        .review-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            background: #fff;
        }
        .review-card h5 {
            margin: 0;
            font-size: 16px;
            color: #333;
        }
        .review-card p {
            margin: 5px 0;
            color: #555;
        }
        .review-card small {
            color: #888;
        }
        .btn-primary {
            background-color: #007bff;
            border: none;
            padding: 10px 20px;
            font-size: 16px;
            border-radius: 5px;
        }
        .btn-primary:hover {
            background-color: #0056b3;
        }
        .section-title {
            font-size: 22px;
            color: #333;
            margin-bottom: 15px;
            border-bottom: 2px solid #007bff;
            display: inline-block;
            padding-bottom: 5px;
        }
        .services-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .service-item {
            background: #f1f1f1;
            padding: 10px 15px;
            border-radius: 5px;
            font-size: 14px;
            color: #333;
        }
        .two-column-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .icon {
            margin-right: 8px;
            color: #007bff;
        }
    </style>
</head>
<body>
<jsp:include page="user_header.jsp" />
    <div class="container profile-container">
        <!-- Profile Header -->
        <div class="profile-header">
            <img src="default-profile (2).png" alt="Profile Image" class="profile-image">
            <div class="profile-info">
                <h1><%= providerName %></h1>
                <p><%= expertise %></p>
                <p>📍 <%= location %></p>
                <div class="d-flex align-items-center">
                    <span class="rating-stars">
                        <% for (int i = 0; i < 5; i++) { %>
                            <% if (i < Double.parseDouble(averageRating)) { %>
                                <i class="fas fa-star"></i>
                            <% } else { %>
                                <i class="far fa-star"></i>
                            <% } %>
                        <% } %>
                    </span>
                    <span class="ms-2">(<%= reviewsCount %> Reviews)</span>
                </div>
            </div>
            <a href="booking.jsp?providerId=<%= providerId %>&providerName=<%= URLEncoder.encode(providerName, "UTF-8") %>" class="btn btn-primary">Book Now</a>
        </div>

        <!-- Two-Column Layout -->
        <div class="two-column-layout">
            <!-- Left Column -->
            <div>
                <!-- Quick Info -->
                <div class="mt-4">
                    <h3 class="section-title"><i class="fas fa-info-circle icon"></i>Quick Info</h3>
                    <p><strong><i class="fas fa-tools icon"></i>Expertise:</strong> <%= expertise %></p>
                    <p><strong><i class="fas fa-calendar-alt icon"></i>Member Since:</strong> <%= memberSince %></p>
                    <p><strong><i class="fas fa-map-marker-alt icon"></i>Address:</strong> <%= location %></p>
                </div>

                <!-- Services & Pricing -->
                <div class="mt-4">
                    <h3 class="section-title"><i class="fas fa-list-alt icon"></i>Services</h3>
                    <div class="services-list">
                        <%
                            try {
                                conn = DBConnection.getConnection();
                                if (services != null && !services.isEmpty()) {
                                    String[] serviceIds = services.split(",");
                                    String serviceQuery = "SELECT service_name FROM Services WHERE service_id = ?";
                                    pstmt = conn.prepareStatement(serviceQuery);

                                    for (String serviceId : serviceIds) {
                                        try {
                                            pstmt.setInt(1, Integer.parseInt(serviceId.trim()));
                                            rs = pstmt.executeQuery();
                                            if (rs.next()) {
                                                String serviceName = rs.getString("service_name");
                        %>
                                                <div class="service-item"><%= serviceName %></div>
                        <%
                                            }
                                        } catch (NumberFormatException e) {
                                            // Skip invalid service IDs
                                            continue;
                                        }
                                    }
                                } else {
                        %>
                                    <div class="service-item">No services listed</div>
                        <%
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                        %>
                                <div class="service-item">Error fetching services</div>
                        <%
                            } finally {
                                if (rs != null) rs.close();
                                if (pstmt != null) pstmt.close();
                                if (conn != null) conn.close();
                            }
                        %>
                    </div>
                    <p class="mt-3"><strong><i class="fas fa-clock icon"></i>Available Timings:</strong> 
                        <div class="service-item"><%= workingHours %></div>
                    </p>
                </div>
            </div>

            <!-- Right Column -->
            <div>
                <!-- Reviews Section -->
                <div class="mt-4">
                    <h3 class="section-title"><i class="fas fa-star icon"></i>Reviews & Ratings</h3>
                    <p>⭐ <%= averageRating %> | <%= reviewsCount %> Reviews</p>
                    <%
                        try {
                            conn = DBConnection.getConnection();
                            String reviewsQuery = "SELECT u.name, r.rating, r.review_text, r.created_at FROM Reviews r JOIN Users u ON r.user_id = u.user_id WHERE r.provider_id = ? ORDER BY r.created_at DESC";
                            pstmt = conn.prepareStatement(reviewsQuery);
                            pstmt.setInt(1, providerId);
                            rs = pstmt.executeQuery();

                            while (rs.next()) {
                                String reviewerName = rs.getString("name");
                                int rating = rs.getInt("rating");
                                String reviewText = rs.getString("review_text");
                                String reviewDate = rs.getString("created_at").split(" ")[0];
                    %>
                                <div class="review-card">
                                    <h5><%= reviewerName %></h5>
                                    <div class="rating-stars">
                                        <% for (int i = 0; i < 5; i++) { %>
                                            <% if (i < rating) { %>
                                                <i class="fas fa-star"></i>
                                            <% } else { %>
                                                <i class="far fa-star"></i>
                                            <% } %>
                                        <% } %>
                                    </div>
                                    <p><%= reviewText %></p>
                                    <small><%= reviewDate %></small>
                                </div>
                    <%
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        } finally {
                            if (rs != null) rs.close();
                            if (pstmt != null) pstmt.close();
                            if (conn != null) conn.close();
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="footer.jsp" />
</body>
</html>