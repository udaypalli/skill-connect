<%@ page import="java.sql.*" %>
<%@ page import="java.util.Base64" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    String categoryName = request.getParameter("category");
    String sortBy = request.getParameter("sortBy");
    String categoryId = null;
    String userEmail = (String) session.getAttribute("userEmail");
    Double userLat = null, userLng = null;
    DecimalFormat df = new DecimalFormat("#.##");

    try {
        conn = DBConnection.getConnection();
        
        // Get user location from database
        if (userEmail != null) {
            String userLocationQuery = "SELECT latitude, longitude FROM Locations WHERE user_id = (SELECT user_id FROM Users WHERE email = ?)";
            pst = conn.prepareStatement(userLocationQuery);
            pst.setString(1, userEmail);
            ResultSet userRs = pst.executeQuery();
            if (userRs.next()) {
                userLat = userRs.getDouble("latitude");
                userLng = userRs.getDouble("longitude");
            }
            userRs.close();
            pst.close();
        }

        // Get category_id from category_name
        String categoryQuery = "SELECT category_id FROM Categories WHERE category_name = ?";
        pst = conn.prepareStatement(categoryQuery);
        pst.setString(1, categoryName);
        ResultSet categoryRs = pst.executeQuery();
        if (categoryRs.next()) {
            categoryId = categoryRs.getString("category_id");
        }
        categoryRs.close();
        pst.close();

        if (categoryId == null) {
            out.println("<h3 class='text-center text-danger'>Invalid Category</h3>");
            return;
        }

        // Fetch providers query (only those with location entries)
        String query = "SELECT sp.provider_id, sp.name, sp.expertise, sp.location, sp.pricing, sp.availability, sp.profile_image, COALESCE(AVG(r.rating), 0) AS rating, l.latitude, l.longitude " +
                       "FROM ServiceProviders sp " +
                       "INNER JOIN Locations l ON sp.provider_id = l.provider_id " + // Changed to INNER JOIN
                       "LEFT JOIN Reviews r ON sp.provider_id = r.provider_id " +
                       "WHERE sp.expertise = ? AND sp.verification_status = 'verified' " +
                       "GROUP BY sp.provider_id, sp.name, sp.expertise, sp.location, sp.pricing, sp.availability, sp.profile_image, l.latitude, l.longitude";
        
        if ("price".equals(sortBy)) {
            query += " ORDER BY sp.pricing ASC";
        } else if ("rating".equals(sortBy)) {
            query += " ORDER BY rating DESC";
        } else if ("distance".equals(sortBy) && userLat != null && userLng != null) {
            query = "SELECT sp.provider_id, sp.name, sp.expertise, sp.location, sp.pricing, sp.availability, sp.profile_image, COALESCE(AVG(r.rating), 0) AS rating, l.latitude, l.longitude, " +
                    "(6371 * acos(cos(radians(?)) * cos(radians(l.latitude)) * cos(radians(l.longitude) - radians(?)) + sin(radians(?)) * sin(radians(l.latitude)))) AS distance " +
                    "FROM ServiceProviders sp " +
                    "INNER JOIN Locations l ON sp.provider_id = l.provider_id " +
                    "LEFT JOIN Reviews r ON sp.provider_id = r.provider_id " +
                    "WHERE sp.expertise = ? AND sp.verification_status = 'verified' " +
                    "GROUP BY sp.provider_id, sp.name, sp.expertise, sp.location, sp.pricing, sp.availability, sp.profile_image, l.latitude, l.longitude " +
                    "ORDER BY distance ASC";
        }
        
        pst = conn.prepareStatement(query);
        if ("distance".equals(sortBy) && userLat != null && userLng != null) {
            pst.setDouble(1, userLat);
            pst.setDouble(2, userLng);
            pst.setDouble(3, userLat);
            pst.setString(4, categoryName);
        } else {
            pst.setString(1, categoryName);
        }
        rs = pst.executeQuery();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Providers</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <!-- Bootstrap Icons CDN -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css">
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <script>
        function sortProviders(sortBy) {
            window.location.href = "service_list.jsp?category=<%= categoryName %>&sortBy=" + sortBy;
        }
    </script>
</head>
<body>
<jsp:include page="user_header.jsp" />
    <div class="container">
        <h2 class="text-center mb-4">Service Providers for <%= categoryName %></h2>
        <div class="mb-3 text-center">
            <button class="btn btn-primary" onclick="sortProviders('rating')">Top Rated</button>
            <button class="btn btn-primary" onclick="sortProviders('price')">Lowest Price</button>
            <button class="btn btn-primary" onclick="sortProviders('distance')">Nearest</button>
        </div>
        
        <% while (rs.next()) { 
            double distance = -1;
            if (userLat != null && userLng != null && rs.getObject("latitude") != null && rs.getObject("longitude") != null) {
                if ("distance".equals(sortBy)) {
                    distance = rs.getDouble("distance"); // Use pre-calculated distance from query
                } else {
                    // Haversine formula for other cases
                    double providerLat = rs.getDouble("latitude");
                    double providerLng = rs.getDouble("longitude");
                    double latDiff = Math.toRadians(providerLat - userLat);
                    double lngDiff = Math.toRadians(providerLng - userLng);
                    double a = Math.sin(latDiff / 2) * Math.sin(latDiff / 2) +
                               Math.cos(Math.toRadians(userLat)) * Math.cos(Math.toRadians(providerLat)) *
                               Math.sin(lngDiff / 2) * Math.sin(lngDiff / 2);
                    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                    distance = 6371 * c; // Earth's radius in kilometers
                }
            }
        %>
        <div class="container mt-4 p-4 border rounded" style="background-color: #f8f9fa;">
    <div class="card shadow-sm border-0 p-4 mb-3" style="background-color: #e6f0ff; border-radius: 12px;">
        <div class="row align-items-center">
            <!-- Left Side: Profile & Name -->
            <div class="col-md-3 text-center">
                <div class="mb-2">
                    <i class="bi bi-person-circle text-primary fs-3"></i>  <!-- Changed Icon -->
                </div>
                <h4 class="fw-bold text-primary" style="font-family: Arial, sans-serif;">
                    <%= rs.getString("name") %>
                </h4>
            </div>
            
            <!-- Middle: Details in Two Columns -->
            <div class="col-md-6">
                <div class="row">
                    <div class="col-6">
                        <p class="fw-semibold"><i class="bi bi-tools text-warning me-2"></i> Expertise: <span class="text-dark"><%= rs.getString("expertise") %></span></p>
                        <p class="fw-semibold"><i class="bi bi-geo-alt text-danger me-2"></i> Location: <span class="text-dark"><%= rs.getString("location") %></span></p>
                        <p class="fw-semibold"><i class="bi bi-cash-stack text-success me-2"></i> Pricing: <span class="text-dark"><%= rs.getDouble("pricing") %></span></p>
                    </div>
                    <div class="col-6">
                        <p class="fw-semibold"><i class="bi bi-clock text-info me-2"></i> Availability:
                            <span class="<%= rs.getBoolean("availability") ? "text-success" : "text-danger" %> fw-bold">
                                <%= rs.getBoolean("availability") ? "Available" : "Not Available" %>
                            </span>
                        </p>
                        <p class="fw-semibold"><i class="bi bi-star-fill text-warning me-2"></i> Rating: 
                            <span class="text-dark"><%= String.format("%.1f", rs.getDouble("rating")) %> / 5</span>
                        </p>
                        <% if (distance != -1) { %>
                            <p class="fw-semibold"><i class="bi bi-map text-secondary me-2"></i> Distance: 
                                <span class="text-dark"><%= df.format(distance) %> km</span>
                            </p>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Right Side: Button -->
            <div class="col-md-3 text-center">
                <a href="provider_profile.jsp?id=<%= rs.getInt("provider_id") %>"
                    class="btn btn-lg fw-bold text-white w-100" 
                    style="background-color: #ff7f00; border-radius: 8px;">
                    <i class="bi bi-eye"></i> View Profile
                </a>
            </div>
        </div>
    </div>
</div>
        <% } %>
    </div>
<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pst != null) pst.close();
        if (conn != null) conn.close();
    }
%>
<jsp:include page="footer.jsp" />
</body>
</html>