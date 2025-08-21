<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // Get user email from session
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        out.println("<p class='text-danger'>Please log in to see promotions and top providers.</p>");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    List<String[]> nearbyPromotions = new ArrayList<>();
    List<String[]> topProviders = new ArrayList<>();

    try {
        conn = DBConnection.getConnection();

        // Step 1: Get user’s address based on email and extract pincode
        String userAddressQuery = "SELECT address FROM Locations WHERE user_id = (SELECT user_id FROM Users WHERE email = ?)";
        stmt = conn.prepareStatement(userAddressQuery);
        stmt.setString(1, userEmail);
        rs = stmt.executeQuery();

        String pincode = null;
        if (rs.next()) {
            String address = rs.getString("address");
            if (address != null && address.length() >= 6) {
                pincode = address.substring(address.length() - 6); // Extract last 6 digits as pincode
            }
        }
        rs.close();
        stmt.close();

        if (pincode == null) {
            out.println("<p class='text-danger'>Pincode not found in your address. Please update your profile location.</p>");
            return;
        }

        // Step 2: Fetch Nearby Promotions based on pincode
        String promotionQuery = "SELECT DISTINCT p.promotion_id, p.title, p.description, p.discount_percentage, p.start_date, p.end_date " +
                               "FROM Promotions p " +
                               "WHERE p.pincode = ? " +
                               "AND p.status = 'Published' " +
                               "ORDER BY p.start_date ASC";

        stmt = conn.prepareStatement(promotionQuery);
        stmt.setString(1, pincode);
        rs = stmt.executeQuery();

        while (rs.next()) {
            nearbyPromotions.add(new String[]{
                rs.getString("title"),
                rs.getString("description"),
                "#007bff", // Default color for styling
                rs.getString("discount_percentage"),
                rs.getString("start_date"),
                rs.getString("end_date")
            });
        }
        rs.close();
        stmt.close();

        // Step 3: Fetch Top Providers Near User (unchanged)
        String topProvidersQuery = "SELECT sp.name, sp.expertise, COALESCE(AVG(r.rating), 0) AS avg_rating, COUNT(r.review_id) AS review_count, sp.profile_image " +
                                  "FROM ServiceProviders sp " +
                                  "JOIN Locations l ON sp.provider_id = l.provider_id " +
                                  "LEFT JOIN Reviews r ON sp.provider_id = r.provider_id " +
                                  "WHERE (6371 * ACOS(COS(RADIANS(?)) * COS(RADIANS(l.latitude)) * " +
                                  "COS(RADIANS(l.longitude) - RADIANS(?)) + SIN(RADIANS(?)) * SIN(RADIANS(l.latitude)))) <= 10 " +
                                  "AND sp.verification_status = 'Verified' " +
                                  "GROUP BY sp.provider_id " +
                                  "ORDER BY avg_rating DESC, review_count DESC " +
                                  "LIMIT 6";

        String userLocationQuery = "SELECT latitude, longitude FROM Locations WHERE user_id = (SELECT user_id FROM Users WHERE email = ?)";
        stmt = conn.prepareStatement(userLocationQuery);
        stmt.setString(1, userEmail);
        rs = stmt.executeQuery();

        double userLat = 0, userLng = 0;
        if (rs.next()) {
            userLat = rs.getDouble("latitude");
            userLng = rs.getDouble("longitude");
        }
        rs.close();
        stmt.close();

        stmt = conn.prepareStatement(topProvidersQuery);
        stmt.setDouble(1, userLat);
        stmt.setDouble(2, userLng);
        stmt.setDouble(3, userLat);
        rs = stmt.executeQuery();

        while (rs.next()) {
            String imagePath = "default-avatar.jpg"; // Default image
            Blob blob = rs.getBlob("profile_image");
            if (blob != null && blob.length() > 0) {
                byte[] imageBytes = blob.getBytes(1, (int) blob.length());
                String base64Image = "data:image/png;base64," + Base64.getEncoder().encodeToString(imageBytes);
                imagePath = base64Image;
            }

            topProviders.add(new String[]{
                rs.getString("name"),
                rs.getString("expertise"),
                String.format("%.1f", rs.getDouble("avg_rating")),
                rs.getString("review_count"),
                imagePath
            });
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p class='text-danger'>Error fetching data.</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>

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
        .provider-card { background-color: #fff; border-radius: 10px; padding: 20px; margin: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); }
        
        /* Updated Promo Section Styling */
        .promo-section { position: relative; overflow: hidden; }
        .promo-slider .carousel-inner { display: flex; align-items: stretch; }
        .promo-slider .carousel-item { display: flex; transition: transform 0.5s ease-in-out; }
        .promo-card { 
            background: linear-gradient(135deg, #007bff, #00d4ff); 
            border-radius: 15px; 
            padding: 15px; 
            margin: 5px; 
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.2); 
            color: white; 
            flex: 1 0 18%; /* 5 items per row (100% / 5 ≈ 18%) */
            max-width: 18%; 
            transition: transform 0.3s ease, box-shadow 0.3s ease; 
            height: 200px; /* Fixed height for uniformity */
            display: flex; 
            flex-direction: column; 
            justify-content: space-between; 
        }
        .promo-card:hover { 
            transform: scale(1.05); 
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3); 
        }
        .promo-card h4 { font-size: 1.2rem; margin-bottom: 5px; }
        .promo-card p { font-size: 0.9rem; margin: 2px 0; }
        .carousel-control-prev, .carousel-control-next { 
            width: 5%; 
            background: rgba(0, 0, 0, 0.3); 
            border-radius: 50%; 
            top: 50%; 
            transform: translateY(-50%); 
        }
        .carousel-control-prev-icon, .carousel-control-next-icon { 
            background-size: 50%, 50%; 
        }
    </style>
</head>
<body>
<jsp:include page="user_header.jsp" />

    <div class="container mt-5">
        <div class="hero-section p-4 shadow-lg">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="text-primary"><i class="bi bi-search icon-hover"></i> Find the Best Service Providers</h1>
                    <div class="input-group mt-3">
                        <input type="text" class="form-control search-box" placeholder="Search for services..." id="searchInput">
                        <button class="btn btn-primary" type="button" onclick="searchCategory()">Search</button>
                    </div>
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

        <!-- Display Nearby Promotions as Slider -->
        <div class="promo-section mt-5">
            <h2 class="text-primary"><i class="bi bi-megaphone-fill icon-hover"></i> Nearby Promotions</h2>
            <% if (nearbyPromotions.isEmpty()) { %>
                <p class="text-muted">No promotions available near you.</p>
            <% } else { %>
                <div id="promoSlider" class="carousel slide promo-slider" data-bs-ride="carousel" data-bs-interval="3000">
                    <div class="carousel-inner">
                        <%
                            int promoCount = nearbyPromotions.size();
                            int slides = (int) Math.ceil((double) promoCount / 5); // Number of slides (5 promos per slide)
                            for (int i = 0; i < slides; i++) {
                                int startIdx = i * 5;
                                int endIdx = Math.min(startIdx + 5, promoCount);
                        %>
                            <div class="carousel-item <%= i == 0 ? "active" : "" %>">
                                <div class="d-flex">
                                    <% for (int j = startIdx; j < endIdx; j++) { 
                                        String[] promo = nearbyPromotions.get(j); 
                                    %>
                                        <div class="promo-card">
                                            <div>
                                                <h4 class="card-title"><%= promo[0] %></h4>
                                                <p class="card-text"><%= promo[1] %></p>
                                            </div>
                                            <div>
                                                <p><strong>Discount:</strong> <%= promo[3] %>%</p>
                                                <p><strong>Duration:</strong> <%= promo[4] %> to <%= promo[5] %></p>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    </div>
                    <% if (slides > 1) { %>
                        <button class="carousel-control-prev" type="button" data-bs-target="#promoSlider" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Previous</span>
                        </button>
                        <button class="carousel-control-next" type="button" data-bs-target="#promoSlider" data-bs-slide="next">
                            <span class="carousel-control-next-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Next</span>
                        </button>
                    <% } %>
                </div>
            <% } %>
        </div>

        <!-- Top Categories Section -->
        <div class="container mt-5 text-center">
            <h2 class="text-primary"><i class="bi bi-grid-fill icon-hover"></i> Top Categories</h2>
            <div class="row row-cols-2 row-cols-md-5 g-3 mt-4">
                <% for (String[] category : topCategories) { %>
                    <div class="col">
                        <a href="service_list.jsp?category=<%= URLEncoder.encode(category[0], "UTF-8") %>" class="text-decoration-none text-dark">
                            <div class="card category-card text-center border p-3 shadow-sm">
                                <i class="bi <%= category[1] %> fs-1" style="color: <%= category[2] %>"></i>
                                <p class="mt-2 fw-bold"><%= category[0] %></p>
                            </div>  
                        </a>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Top Providers Near You Section -->
        <div class="container mt-5">
            <h2 class="text-primary"><i class="bi bi-geo-alt-fill icon-hover"></i> Top Providers Near You</h2>
            <% if (topProviders.isEmpty()) { %>
                <p class="text-muted">No top providers found near your location.</p>
            <% } else { %>
                <div class="row mt-4">
                    <% for (String[] provider : topProviders) { %>
                        <div class="col-md-4">
                            <div class="card provider-card shadow-sm text-center p-3">
                                <h4 class="mt-3"><%= provider[0] %></h4>
                                <p class="text-muted"><%= provider[1] %></p>
                                <p><i class="bi bi-star-fill text-warning"></i> <%= provider[2] %> | <%= provider[3] %> Reviews</p>
                                <button class="btn btn-primary">View Profile</button>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>

    <%@ include file="footer.jsp" %>
    
    <script>
        function searchCategory() {
            var searchInput = document.getElementById("searchInput").value.trim();
            if (searchInput) {
                window.location.href = "service_list.jsp?category=" + encodeURIComponent(searchInput);
            }
        }
    </script>
</body>
</html>