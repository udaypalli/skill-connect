<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%
    // Check if the form has been submitted
    String errorMessage = null;
    String successMessage = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Process the form submission
        int providerId = Integer.parseInt(request.getParameter("providerId"));
        int serviceId = Integer.parseInt(request.getParameter("serviceId"));
        String bookingTime = request.getParameter("bookingTime");
        double totalCost = Double.parseDouble(request.getParameter("payment"));
        String userEmail = (String) session.getAttribute("userEmail"); // Assuming user email is stored in session

        // Initialize variables
        int userId = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // Get database connection
            conn = DBConnection.getConnection();

            // Step 1: Fetch user_id from Users table using userEmail
            String userQuery = "SELECT user_id FROM Users WHERE email = ?";
            pstmt = conn.prepareStatement(userQuery);
            pstmt.setString(1, userEmail);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                userId = rs.getInt("user_id");
            }
            rs.close();
            pstmt.close();

            // Step 2: Insert booking details into Bookings table
            String bookingQuery = "INSERT INTO Bookings (user_id, provider_id, service_id, booking_time, total_cost, status) VALUES (?, ?, ?, ?, ?, 'Pending')";
            pstmt = conn.prepareStatement(bookingQuery);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, providerId);
            pstmt.setInt(3, serviceId);
            pstmt.setString(4, bookingTime);
            pstmt.setDouble(5, totalCost);
            pstmt.executeUpdate();
            pstmt.close();

            // Step 3: Insert notification into Notifications table
            String notificationQuery = "INSERT INTO Notifications (user_id, provider_id, message) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(notificationQuery);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, providerId);
            pstmt.setString(3, "You have a new booking request. Please check your bookings.");
            pstmt.executeUpdate();
            pstmt.close();

            // Set success message for modal
            successMessage = "Booking Successful!";
        } catch (Exception e) {
            e.printStackTrace();
            // Set error message for modal
            errorMessage = "Error Occurred: " + e.getMessage();
        } finally {
            // Close database resources
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }

    // If the form has not been submitted or after processing, display the booking form
    int providerId = Integer.parseInt(request.getParameter("providerId"));
    String providerName = "";
    double providerFees = 0.0;
    String expertise = "";
    int categoryId = 0;

    try {
        Connection conn = DBConnection.getConnection(); // Use your DBConnection class

        // Fetch provider details
        String providerQuery = "SELECT name, expertise, pricing FROM ServiceProviders WHERE provider_id = ?";
        PreparedStatement providerStmt = conn.prepareStatement(providerQuery);
        providerStmt.setInt(1, providerId);
        ResultSet providerRs = providerStmt.executeQuery();
        if (providerRs.next()) {
            providerName = providerRs.getString("name");
            expertise = providerRs.getString("expertise");
            providerFees = providerRs.getDouble("pricing");
        }
        providerRs.close();
        providerStmt.close();

        // Fetch category_id based on expertise
        String categoryQuery = "SELECT category_id FROM Categories WHERE category_name = ?";
        PreparedStatement categoryStmt = conn.prepareStatement(categoryQuery);
        categoryStmt.setString(1, expertise);
        ResultSet categoryRs = categoryStmt.executeQuery();
        if (categoryRs.next()) {
            categoryId = categoryRs.getInt("category_id");
        }
        categoryRs.close();
        categoryStmt.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Service Provider</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Arial', sans-serif;
        }
        .booking-container {
            background: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            margin-top: 50px;
        }
        .service-box {
            padding: 8px 16px;
            border-radius: 20px; /* Curved edges */
            background-color: #e9ecef; /* Gray background before selection */
            color: #495057; /* Dark text color */
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid #dee2e6; /* Light border */
            font-size: 14px; /* Smaller font size */
            text-align: center;
            white-space: nowrap; /* Prevent text from wrapping */
        }
        .service-box:hover {
            background-color: #ced4da; /* Slightly darker gray on hover */
        }
        .service-box.selected {
            background-color: #ffa500; /* Orange background after selection */
            color: #fff; /* White text after selection */
            border-color: #ffa500; /* Orange border after selection */
        }
        .form-label {
            font-weight: bold;
            color: #495057;
        }
        .btn-primary {
            background-color: #007bff;
            border-color: #007bff;
            padding: 10px 20px;
            font-size: 16px;
            border-radius: 8px;
        }
        .btn-primary:hover {
            background-color: #0056b3;
            border-color: #004085;
        }
        .icon {
            margin-right: 10px;
        }
    </style>
</head>
<body>
<jsp:include page="user_header.jsp" />
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 booking-container">
                <h2 class="text-center mb-4"><i class="fas fa-calendar-check icon"></i>Book Service Provider</h2>
                <form action="booking.jsp" method="post">
                    <!-- Hidden input for providerId -->
                    <input type="hidden" name="providerId" value="<%= providerId %>">

                    <!-- Provider Information -->
                    <div class="mb-3">
                        <label for="providerName" class="form-label"><i class="fas fa-user-tie icon"></i>Provider Name</label>
                        <input type="text" class="form-control" id="providerName" name="providerName" value="<%= providerName %>" readonly>
                    </div>

                    <!-- Service Selection -->
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-briefcase icon"></i>Select Service</label>
                        <div id="expertiseContainer" class="d-flex flex-wrap gap-2">
                            <%
                                try {
                                    Connection conn = DBConnection.getConnection(); // Use your DBConnection class

                                    // Fetch services based on category_id
                                    String serviceQuery = "SELECT service_id, service_name FROM Services WHERE category_id = ?";
                                    PreparedStatement serviceStmt = conn.prepareStatement(serviceQuery);
                                    serviceStmt.setInt(1, categoryId);
                                    ResultSet serviceRs = serviceStmt.executeQuery();
                                    while (serviceRs.next()) {
                            %>
                            <div class="service-box" onclick="selectService(<%= serviceRs.getInt("service_id") %>, '<%= serviceRs.getString("service_name") %>')">
                                <span><%= serviceRs.getString("service_name") %></span>
                            </div>
                            <%
                                    }
                                    serviceRs.close();
                                    serviceStmt.close();
                                    conn.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </div>
                        <input type="hidden" name="serviceId" id="serviceId">
                    </div>

                    <!-- Hours Selection -->
                    <div class="mb-3">
                        <label for="hours" class="form-label"><i class="fas fa-clock icon"></i>Duration (in hours)</label>
                        <select class="form-control" id="hours" name="hours" onchange="calculateFees(<%= providerFees %>)">
                            <option value="1">1 hour</option>
                            <option value="2">2 hours</option>
                            <option value="3">3 hours</option>
                        </select>
                    </div>

                    <!-- Payment Information -->
                    <div class="mb-3">
                        <label for="payment" class="form-label"><i class="fas fa-money-bill-wave icon"></i>Payment Amount</label>
                        <input type="number" class="form-control" id="payment" name="payment" value="<%= providerFees %>" readonly>
                    </div>

                    <!-- Date and Time Picker -->
                    <div class="mb-3">
                        <label for="bookingTime" class="form-label"><i class="fas fa-calendar-alt icon"></i>Booking Date and Time</label>
                        <input type="datetime-local" class="form-control" id="bookingTime" name="bookingTime" required>
                    </div>

                    <!-- Submit Button -->
                    <div class="text-center">
                        <button type="submit" class="btn btn-primary"><i class="fas fa-check-circle icon"></i>Confirm Booking</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Success Modal -->
    <% if (successMessage != null) { %>
        <div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="successModalLabel"><i class="fas fa-check-circle"></i> Success</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <%= successMessage %>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" onclick="window.location.href='user_transactions.jsp'">OK</button>
                    </div>
                </div>
            </div>
        </div>
        <script>
            // Automatically show success modal
            document.addEventListener('DOMContentLoaded', function () {
                var successModal = new bootstrap.Modal(document.getElementById('successModal'));
                successModal.show();
            });
        </script>
    <% } %>

    <!-- Error Modal -->
    <% if (errorMessage != null) { %>
        <div class="modal fade" id="errorModal" tabindex="-1" aria-labelledby="errorModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title" id="errorModalLabel"><i class="fas fa-exclamation-triangle"></i> Error</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <%= errorMessage %>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" onclick="window.location.href='user_transactions.jsp'">OK</button>
                    </div>
                </div>
            </div>
        </div>
        <script>
            // Automatically show error modal
            document.addEventListener('DOMContentLoaded', function () {
                var errorModal = new bootstrap.Modal(document.getElementById('errorModal'));
                errorModal.show();
            });
        </script>
    <% } %>

    <!-- Bootstrap JS and dependencies -->
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.min.js"></script>
    <!-- Custom JS -->
    <script>
        function selectService(serviceId, serviceName) {
            // Set the selected service ID in the hidden input
            document.getElementById("serviceId").value = serviceId;

            // Highlight the selected service box
            let serviceBoxes = document.querySelectorAll(".service-box");
            serviceBoxes.forEach(box => box.classList.remove("selected"));
            event.currentTarget.classList.add("selected");
        }

        function calculateFees(baseFees) {
            let hours = document.getElementById("hours").value;
            let totalFees = baseFees * hours;
            document.getElementById("payment").value = totalFees.toFixed(2);
        }
    </script>
    <jsp:include page="footer.jsp" />
</body>
</html>