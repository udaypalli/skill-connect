<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, com.skillconnect.util.DBConnection" %>
<jsp:include page="user_header.jsp" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Reviews</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS for Naukri Theme -->
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Arial', sans-serif;
        }
        .btn-primary {
            background-color: rgb(13 110 253); /* Naukri Blue */
            border-color: rgb(13 110 253);
        }
        .btn-primary:hover {
            background-color: rgb(13 110 253); /* Darker Blue */
            border-color: rgb(13 110 253);
        }
        .card {
            border: none;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s;
        }
        .card:hover {
            transform: translateY(-5px);
        }
        .card-header {
            background-color: rgb(13 110 253);
            color: #fff;
        }
        .star-rating {
            color: #ffc107; /* Yellow for stars */
            cursor: pointer;
        }
        .star-rating .bi-star {
            color: #ddd; /* Gray for unselected stars */
        }
        .star-rating .bi-star-fill {
            color: #ffc107; /* Yellow for selected stars */
        }
        .star-rating .bi-star:hover,
        .star-rating .bi-star-fill:hover {
            color: #ffc107; /* Yellow on hover */
        }
        .orange-btn {
            background-color: #F37321; /* Orange */
            border-color: #F37321;
            color: #fff;
        }
        .orange-btn:hover {
            background-color: #e65a00; /* Darker Orange */
            border-color: #e65a00;
        }
        .review-card {
            background-color: #fff;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15); /* Soft shadow */
    border: 1px solid #ddd; /* Light border */
    transition: box-shadow 0.3s ease-in-out;
        }
        .review-card h5 {
            color: rgb(13 110 253);;
        }
        .review-card .bi {
            font-size: 1.5rem;
            margin-right: 5px;
        }
        .review-card .bi-star-fill {
            color: #ffc107;
        }
        .review-card .bi-star {
            color: #ddd;
        }
        .review-card .text-muted {
            font-size: 0.9rem;
        }
        .review-card:hover {
    box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2); /* Stronger shadow on hover */
}
    </style>
</head>
<body>

    <!-- Main Content -->
    <div class="container mt-5">
        <h2 class="mb-4 text-center">Your Reviews</h2>

        <!-- Add Review Form -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0">Add a Review</h5>
            </div>
            <div class="card-body">
                <form action="addReview.jsp" method="POST">
                    <div class="mb-3">
                        <label for="providerId" class="form-label">Select Service Provider</label>
                        <select class="form-select" id="providerId" name="providerId" required>
                            <option value="">Choose a provider...</option>
                            <%
                                // Fetch user email from session
                                String userEmail = (String) session.getAttribute("userEmail");
                                if (userEmail != null) {
                                    Connection conn = null;
                                    PreparedStatement pstmt = null;
                                    ResultSet rs = null;
                                    try {
                                        conn = DBConnection.getConnection();
                                        String query = "SELECT DISTINCT sp.provider_id, sp.name FROM Bookings b " +
                                                       "JOIN ServiceProviders sp ON b.provider_id = sp.provider_id " +
                                                       "JOIN Users u ON b.user_id = u.user_id " +
                                                       "WHERE u.email = ?";
                                        pstmt = conn.prepareStatement(query);
                                        pstmt.setString(1, userEmail);
                                        rs = pstmt.executeQuery();
                                        while (rs.next()) {
                                            int providerId = rs.getInt("provider_id");
                                            String providerName = rs.getString("name");
                                            out.println("<option value='" + providerId + "'>" + providerName + "</option>");
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
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="rating" class="form-label">Rating</label>
                        <div class="star-rating" id="starRating">
                            <i class="bi bi-star" data-rating="1"></i>
                            <i class="bi bi-star" data-rating="2"></i>
                            <i class="bi bi-star" data-rating="3"></i>
                            <i class="bi bi-star" data-rating="4"></i>
                            <i class="bi bi-star" data-rating="5"></i>
                        </div>
                        <input type="hidden" id="rating" name="rating" required>
                    </div>
                    <div class="mb-3">
                        <label for="reviewText" class="form-label">Review</label>
                        <textarea class="form-control" id="reviewText" name="reviewText" rows="3" required></textarea>
                    </div>
                    <button type="submit" class="btn orange-btn">Submit Review</button>
                </form>
            </div>
        </div>

        <!-- Display User Reviews -->
        <h3 class="mb-3 text-center">Your Past Reviews</h3>
        <div class="row">
            <%
                if (userEmail != null) {
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    try {
                        conn = DBConnection.getConnection();
                        String query = "SELECT r.review_id, r.rating, r.review_text, r.created_at, sp.name AS provider_name " +
                                        "FROM Reviews r " +
                                        "JOIN ServiceProviders sp ON r.provider_id = sp.provider_id " +
                                        "JOIN Users u ON r.user_id = u.user_id " +
                                        "WHERE u.email = ? " +
                                        "ORDER BY r.created_at DESC";
                        pstmt = conn.prepareStatement(query);
                        pstmt.setString(1, userEmail);
                        rs = pstmt.executeQuery();
                        while (rs.next()) {
                            int reviewId = rs.getInt("review_id");
                            int rating = rs.getInt("rating");
                            String reviewText = rs.getString("review_text");
                            String providerName = rs.getString("provider_name");
                            String createdAt = rs.getString("created_at");
            %>
                            <div class="col-md-6">
                                <div class="review-card">
                                    <h5><i class="bi bi-person-circle"></i><%= providerName %></h5>
                                    <div class="star-rating">
                                        <% for (int i = 1; i <= 5; i++) { %>
                                            <i class="bi bi-star<%= i <= rating ? "-fill" : "" %>"></i>
                                        <% } %>
                                    </div>
                                    <p><%= reviewText %></p>
                                    <p class="text-muted"><small><i class="bi bi-calendar"></i> Reviewed on <%= createdAt %></small></p>
                                </div>
                            </div>
            <%
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
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Star Rating Script -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const stars = document.querySelectorAll('#starRating .bi-star');
            const ratingInput = document.getElementById('rating');

            stars.forEach(star => {
                star.addEventListener('click', function () {
                    const rating = this.getAttribute('data-rating');
                    ratingInput.value = rating;
                    stars.forEach((s, index) => {
                        if (index < rating) {
                            s.classList.remove('bi-star');
                            s.classList.add('bi-star-fill');
                        } else {
                            s.classList.remove('bi-star-fill');
                            s.classList.add('bi-star');
                        }
                    });
                });

                star.addEventListener('mouseover', function () {
                    const rating = this.getAttribute('data-rating');
                    stars.forEach((s, index) => {
                        if (index < rating) {
                            s.classList.remove('bi-star');
                            s.classList.add('bi-star-fill');
                        }
                    });
                });

                star.addEventListener('mouseout', function () {
                    const selectedRating = ratingInput.value;
                    stars.forEach((s, index) => {
                        if (index >= selectedRating) {
                            s.classList.remove('bi-star-fill');
                            s.classList.add('bi-star');
                        }
                    });
                });
            });
        });
    </script>
    <jsp:include page="footer.jsp" />
</body>
</html>