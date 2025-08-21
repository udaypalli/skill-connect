<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.SQLException, com.skillconnect.util.DBConnection" %>
<%@ page import="java.sql.ResultSet" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Promotion - SkillConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .promotion-form {
            background: #fff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .form-icon {
            color: #ff6600;
            margin-right: 10px;
        }
        .btn-orange {
            background-color: #ff6600;
            color: #fff;
        }
        .btn-orange:hover {
            background-color: #e65c00;
        }
        .info-box {
            background-color: #fff3e6;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .alert {
            margin-top: 20px;
        }
    </style>
</head>
<body>
 <jsp:include page="service_provider_header.jsp" />
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="promotion-form">
                    <h2 class="text-center mb-4">
                        <i class="fas fa-bullhorn form-icon"></i>Create a New Promotion
                    </h2>

                    <!-- Information Box -->
                    <div class="info-box">
                        <h5><i class="fas fa-info-circle form-icon"></i>Platform Fees & Promotion Details</h5>
                        <p>
                            SkillConnect charges a nominal fee of <strong>₹500 per month</strong> for promoting your services. 
                            This fee is due within <strong>7 days</strong> of creating the promotion. 
                            Promotions help you reach more customers, increase visibility, and boost your earnings. 
                            Make sure your promotion is attractive and clear to get the best results!
                        </p>
                    </div>

                    <!-- Handle Form Submission -->
                    <%
                        String message = "";
                        String alertType = "";
                            		 

                        if ("POST".equalsIgnoreCase(request.getMethod())) {
                            // Retrieve form data
                            String title = request.getParameter("title");
                            String description = request.getParameter("description");
                            double discountPercentage = Double.parseDouble(request.getParameter("discount_percentage"));
                            String startDate = request.getParameter("start_date");
                            String endDate = request.getParameter("end_date");
                            int providerId = 1; // Replace with actual provider ID from session or authentication
                            int pincode = 0;
                         // Retrieve provider_id and pincode from the database
                            String email = (String) session.getAttribute("userEmail");  // Get user email from session
                            String providerIdSql = "SELECT provider_id, pincode FROM ServiceProviders WHERE email = ?";

                            try (Connection conn = DBConnection.getConnection();
                                 PreparedStatement stmt = conn.prepareStatement(providerIdSql)) {
                                 stmt.setString(1, email);
                                 try (ResultSet rs = stmt.executeQuery()) {
                                     if (rs.next()) {
                                         providerId = rs.getInt("provider_id");
                                         pincode = rs.getInt("pincode");  // Assuming you have a 'pincode' column in ServiceProviders
                                         // Continue with promotion insertion
                                     } else {
                                         // Handle case when provider is not found
                                     }
                                 }
                            } catch (SQLException e) {
                                e.printStackTrace();
                                // Handle error
                            }

                            
                            
                            
                            // Insert into Promotions table
                            String sql = "INSERT INTO Promotions (provider_id, title, description, discount_percentage, start_date, end_date, pincode, status) VALUES (?, ?, ?, ?, ?, ?,?, 'Pending')";

                            try (Connection conn = DBConnection.getConnection();
                                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                                stmt.setInt(1, providerId);
                                stmt.setString(2, title);
                                stmt.setString(3, description);
                                stmt.setDouble(4, discountPercentage);
                                stmt.setString(5, startDate);
                                stmt.setString(6, endDate);
                                stmt.setInt(7, pincode);
                                stmt.executeUpdate();

                                // Insert platform fee
                                String feeSql = "INSERT INTO PlatformFees (provider_id, amount, due_date, payment_status ,type) VALUES (?, 500.00, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Pending','Promotion')";
                                try (PreparedStatement feeStmt = conn.prepareStatement(feeSql)) {
                                    feeStmt.setInt(1, providerId);
                                    feeStmt.executeUpdate();
                                }

                                message = "Promotion created successfully!";
                                alertType = "success";
                            } catch (SQLException e) {
                                e.printStackTrace();
                                message = "Error creating promotion. Please try again.";
                                alertType = "danger";
                            }
                        }
                    %>

                    <!-- Display Success/Error Message -->
                    <% if (!message.isEmpty()) { %>
                        <div class="alert alert-<%= alertType %>">
                            <%= message %>
                        </div>
                    <% } %>

                    <!-- Promotion Form -->
                    <form method="POST">
                        <!-- Title -->
                        <div class="mb-3">
                            <label for="title" class="form-label"><i class="fas fa-heading form-icon"></i>Promotion Title</label>
                            <input type="text" class="form-control" id="title" name="title" placeholder="Enter promotion title" required>
                        </div>

                        <!-- Description -->
                        <div class="mb-3">
                            <label for="description" class="form-label"><i class="fas fa-align-left form-icon"></i>Description</label>
                            <textarea class="form-control" id="description" name="description" rows="4" placeholder="Enter promotion description" required></textarea>
                        </div>

                        <!-- Discount Percentage -->
                        <div class="mb-3">
                            <label for="discount_percentage" class="form-label"><i class="fas fa-percent form-icon"></i>Discount Percentage</label>
                            <input type="number" class="form-control" id="discount_percentage" name="discount_percentage" min="0" max="100" step="0.01" placeholder="Enter discount percentage (0-100)" required>
                        </div>

                        <!-- Start Date -->
                        <div class="mb-3">
                            <label for="start_date" class="form-label"><i class="fas fa-calendar-alt form-icon"></i>Start Date</label>
                            <input type="date" class="form-control" id="start_date" name="start_date" required>
                        </div>

                        <!-- End Date -->
                        <div class="mb-3">
                            <label for="end_date" class="form-label"><i class="fas fa-calendar-alt form-icon"></i>End Date</label>
                            <input type="date" class="form-control" id="end_date" name="end_date" required>
                        </div>

                        <!-- Submit Button -->
                        <div class="text-center">
                            <button type="submit" class="btn btn-orange btn-lg">
                                <i class="fas fa-check-circle"></i> Create Promotion
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <%@ include file="footer.jsp" %>
</body>
</html>