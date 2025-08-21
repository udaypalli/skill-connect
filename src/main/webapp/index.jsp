<%@ page import="java.sql.*, java.util.*" %>

<%@ page import="com.skillconnect.util.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Check for cookies
    String userEmailFromCookie = null;
    String userRoleFromCookie = null;
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("userEmail".equals(cookie.getName())) {
                userEmailFromCookie = cookie.getValue();
            } else if ("userRole".equals(cookie.getName())) {
                userRoleFromCookie = cookie.getValue();
            }
        }
    }

    // If cookies exist, set session and redirect
    if (userEmailFromCookie != null && userRoleFromCookie != null) {
        session.setAttribute("userEmail", userEmailFromCookie);
        session.setAttribute("userRole", userRoleFromCookie);
        if ("user".equals(userRoleFromCookie)) {
            response.sendRedirect("userDashboard.jsp");
        } else if ("service_provider".equals(userRoleFromCookie)) {
            response.sendRedirect("service_provider_dashboard.jsp");
        }
        return;
    }
%>
<%-- Rest of your index.jsp content goes here --%>

<%
    List<String[]> reviews = new ArrayList<>();

    String[][] topCategories = {
        {"Automobile Repair", "bi-car-front-fill", "#007bff"},
        {"Beauty & Wellness", "bi-heart-fill", "#e83e8c"},
        {"Carpentry", "bi-hammer", "#fd7e14"},
        {"Cleaning", "bi-bucket-fill", "#20c997"},
        {"Electrician", "bi-lightning-fill", "#ffc107"},
        {"Gardening", "bi-flower1", "#28a745"},
        {"Home Security", "bi-shield-lock-fill", "#6f42c1"},
        {"IT Support", "bi-laptop", "#17a2b8"},
        {"Painting", "bi-brush", "#dc3545"},
        {"Plumbing", "bi-wrench", "#343a40"}
    };

    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String reviewQuery = "SELECT u.name, r.review_text FROM Reviews r JOIN Users u ON r.user_id = u.user_id ORDER BY r.created_at DESC LIMIT 3";
            try (PreparedStatement ps = conn.prepareStatement(reviewQuery);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reviews.add(new String[]{rs.getString("name"), rs.getString("review_text")});
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SkillConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css">
    <style>
        .hero-section, .promo-section { background-color: #f8f9fa; padding: 50px; border-radius: 10px; }
        .category-card, .feature-card, .review-card { transition: 0.3s; cursor: pointer; border-radius: 10px; height: 100%; display: flex; align-items: center; justify-content: center; flex-direction: column; }
        .category-card:hover, .feature-card:hover, .review-card:hover { background-color: #f1f1f1; transform: scale(1.05); box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); }
        .search-box { border: 2px solid #0d6efd; border-radius: 5px; padding: 10px; }
        .search-box:hover { border-color: #6610f2; }
        .icon-hover:hover { transform: scale(1.2); transition: 0.3s; }
    </style>
</head>
<body>
<%@ include file="header.jsp" %>
    <div class="container mt-5">
        <div class="hero-section p-4 shadow-lg">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="text-primary"><i class="bi bi-search icon-hover"></i> Find the Best Service Providers</h1>
                    <input type="text" class="form-control search-box mt-3" placeholder="Search for services...">
                    <div class="mt-4">
                        <p><i class="bi bi-people-fill text-primary icon-hover"></i> <strong>212+</strong> Providers</p>
                        <p><i class="bi bi-star-fill text-warning icon-hover"></i> <strong>15M+</strong> Reviews</p>
                        <p><i class="bi bi-check-circle-fill text-success icon-hover"></i> <strong>30K+</strong> Services Completed</p>
                    </div>
                </div>
                <div class="col-md-6 text-center">
                    <img src="service-logo.png" class="img-fluid w-75" alt="Service Providers">
                </div>
            </div>
        </div>

        <div class="container mt-5 text-center">
            <h2 class="text-primary"><i class="bi bi-grid-fill icon-hover"></i> Top Categories</h2>
            <div class="row row-cols-2 row-cols-md-5 g-3 mt-4">
                <% for (String[] category : topCategories) { %>
                    <div class="col">
                        <div class="card category-card text-center border p-3 shadow-sm">
                            <i class="bi <%= category[1] %> fs-1" style="color: <%= category[2] %>"></i>
                            <p class="mt-2 fw-bold"><%= category[0] %></p>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>

        <div class="container mt-5 text-center">
            <h2 class="text-primary"><i class="bi bi-lightbulb-fill icon-hover"></i> How It Works</h2>
            <div class="row mt-4">
                <div class="col-md-4">
                    <div class="card p-4 shadow-sm">
                        <i class="bi bi-search fs-1 icon-hover" style="color: #007bff;"></i>
                        <p class="mt-2">Use our powerful search tool to explore a wide range of service providers near you. Browse profiles, check ratings, and read customer reviews to find the best fit for your needs</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card p-4 shadow-sm">
                        <i class="bi bi-calendar-check-fill fs-1 icon-hover" style="color: #28a745;"></i>
                        <p class="mt-2">Once youve found the right provider, book their services instantly or schedule an appointment at your convenience. Our seamless booking system ensures a hassle-free experience.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card p-4 shadow-sm">
                        <i class="bi bi-hand-thumbs-up-fill fs-1 icon-hover" style="color: #ffc107;"></i>
                        <p class="mt-2">Sit back and relax as a skilled professional takes care of the task. Whether it’s home repairs, beauty services, or IT support, we connect you with top-tier experts for quality service every time</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
     <!-- User Reviews Section -->
        <div class="container mt-5 text-center">
            <h2 class="text-primary"><i class="bi bi-chat-dots-fill icon-hover"></i> User Reviews</h2>
            <div class="row mt-4">
                <% for (String[] review : reviews) { %>
                    <div class="col-md-4">
                        <div class="card review-card p-3 shadow-sm">
                            <div class="d-flex align-items-center">
                                <i class="bi bi-star-fill text-warning me-1"></i>
                                <i class="bi bi-star-fill text-warning me-1"></i>
                                <i class="bi bi-star-fill text-warning me-1"></i>
                                <i class="bi bi-star-fill text-warning me-1"></i>
                                <i class="bi bi-star-fill text-warning"></i>
                            </div>
                            <p class="mt-2"><%= review[1] %></p>
                            <small class="text-muted"><%= review[0] %></small>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
        <!-- Promotion Section -->
        <div class="container mt-5 promo-section text-center">
            <div class="row align-items-center">
                <div class="col-md-6 text-start"> <!-- Added text-start class for left alignment -->
    <h2 class="text-primary">Advertise Your Services</h2>
    <p>Are you a skilled professional looking to grow your business? <strong>SkillConnect</strong> helps you reach more customers and expand your services.</p>

    <ul class="list-unstyled mt-3">
        <li><i class="bi bi-eye-fill text-primary me-2"></i> <strong>Increase Visibility</strong>-  Showcase your skills and expertise to a larger audience.</li>
        <li><i class="bi bi-calendar-check-fill text-success me-2"></i> <strong>Get More Bookings</strong>-  Attract potential clients and receive more service requests.</li>
        <li><i class="bi bi-star-fill text-warning me-2"></i> <strong>Build a Strong Reputation</strong>-  Gain trust with customer reviews and ratings.</li>
    </ul>

    <p class="mt-3">Join <strong>SkillConnect</strong> today and take your business to the next level!</p>
</div>


                <div class="col-md-6">
                     <img src="advertise.png" class="img-fluid w-50" alt="Service Providers">
                </div>
            </div>
        </div>
    </div>
    <!-- Features Section -->
        <div class="container mt-5 text-center">
            <h2 class="text-primary"><i class="bi bi-star-fill icon-hover"></i> Features</h2>
            <div class="row mt-4">
                <div class="col-md-4">
                    <div class="card feature-card p-4 shadow-sm text-center">
                        <i class="bi bi-tools fs-1 text-danger icon-hover"></i>
                       <p class="mt-2 fw-bold">Instant Booking</p>
                        
                        <p>No more waiting! With just a few clicks, you can book a professional service instantly. Whether its a last-minute repair or a planned appointment, our platform ensures quick and convenient scheduling.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card feature-card p-4 shadow-sm text-center">
                        <i class="bi bi-shield-lock fs-1 text-primary icon-hover"></i>
                         <p class="mt-2 fw-bold">Secure Payments</p>
                        <p>Your transactions are safe with our secure payment gateway. Choose from multiple payment options, enjoy hassle-free billing, and have peace of mind knowing your payments are protected.s</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card feature-card p-4 shadow-sm text-center">
                        <i class="bi bi-chat-dots fs-1 text-success icon-hover"></i>
                         <p class="mt-2 fw-bold">24/7 Customer Support</p>
                        <p>Need help? Our dedicated support team is available round the clock to assist you with any questions or concerns. Whether its booking assistance or issue resolution, we’re here for you anytime, anywhere.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="footer.jsp" %>
</body>
</html>
