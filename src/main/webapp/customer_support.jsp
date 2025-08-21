<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.skillconnect.util.DBConnection" %>
<jsp:include page="user_header.jsp" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Support - Raise a Dispute</title>
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
        .orange-btn {
            background-color: #ff6f00; /* Orange */
            border-color: #ff6f00;
            color: #fff;
        }
        .orange-btn:hover {
            background-color: #e65a00; /* Darker Orange */
            border-color: #e65a00;
        }
        .form-label {
            font-weight: bold;
        }
        .bi {
            margin-right: 5px;
        }
    </style>
</head>
<body>

    <!-- Main Content -->
    <div class="container mt-5">
        <h2 class="mb-4 text-center"><i class="bi bi-headset"></i>Raise a Dispute</h2>

        <!-- Dispute Form -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0"><i class="bi bi-info-circle"></i>Provide Dispute Details</h5>
            </div>
            <div class="card-body">
                <form action="customer_support.jsp" method="POST">
                    <!-- Booking ID Dropdown -->
                    <div class="mb-3">
                        <label for="bookingId" class="form-label"><i class="bi bi-calendar-check"></i>Select Booking</label>
                        <select class="form-select" id="bookingId" name="bookingId" required>
                            <option value="">Choose a booking...</option>
                            <%
                                // Fetch user email from session
                                String userEmail = (String) session.getAttribute("userEmail");
                                if (userEmail != null) {
                                    Connection conn = null;
                                    PreparedStatement pstmt = null;
                                    ResultSet rs = null;
                                    try {
                                        conn = DBConnection.getConnection();
                                        String query = "SELECT b.booking_id, sp.name AS provider_name " +
                                                "FROM Bookings b " +
                                                "JOIN ServiceProviders sp ON b.provider_id = sp.provider_id " +
                                                "JOIN Users u ON b.user_id = u.user_id " +
                                                "WHERE u.email = ? AND b.status IN ('Pending', 'Accepted', 'Completed', 'Cancelled')";

                                        pstmt = conn.prepareStatement(query);
                                        pstmt.setString(1, userEmail);
                                        rs = pstmt.executeQuery();
                                        while (rs.next()) {
                                            int bookingId = rs.getInt("booking_id");
                                            String providerName = rs.getString("provider_name");
                                            out.println("<option value='" + bookingId + "'>Booking ID: " + bookingId + " - " + providerName + "</option>");
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

                    <!-- Issue Description -->
                    <div class="mb-3">
                        <label for="issueDescription" class="form-label"><i class="bi bi-chat-left-text"></i>Issue Description</label>
                        <textarea class="form-control" id="issueDescription" name="issueDescription" rows="5" required></textarea>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" class="btn orange-btn"><i class="bi bi-send"></i>Submit Dispute</button>
                </form>
            </div>
        </div>

        <!-- Handle Form Submission -->
        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String bookingIdStr = request.getParameter("bookingId");
                String issueDescription = request.getParameter("issueDescription");

                if (bookingIdStr != null && !bookingIdStr.isEmpty() && issueDescription != null && !issueDescription.isEmpty()) {
                    int bookingId = Integer.parseInt(bookingIdStr);
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    try {
                        conn = DBConnection.getConnection();

                        // Fetch user_id and provider_id from the selected booking
                        String query = "SELECT user_id, provider_id FROM Bookings WHERE booking_id = ?";
                        pstmt = conn.prepareStatement(query);
                        pstmt.setInt(1, bookingId);
                        ResultSet rs = pstmt.executeQuery();
                        if (rs.next()) {
                            int userId = rs.getInt("user_id");
                            int providerId = rs.getInt("provider_id");

                            // Insert dispute into the Disputes table
                            String insertQuery = "INSERT INTO Disputes (booking_id, user_id, provider_id, issue_description, status) VALUES (?, ?, ?, ?, 'Open')";
                            pstmt = conn.prepareStatement(insertQuery);
                            pstmt.setInt(1, bookingId);
                            pstmt.setInt(2, userId);
                            pstmt.setInt(3, providerId);
                            pstmt.setString(4, issueDescription);
                            pstmt.executeUpdate();

                            out.println("<div class='alert alert-success' role='alert'><i class='bi bi-check-circle'></i>Dispute submitted successfully!</div>");
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i>Error submitting dispute. Please try again.</div>");
                    } finally {
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                } else {
                    out.println("<div class='alert alert-warning' role='alert'><i class='bi bi-exclamation-triangle'></i>Please fill all the fields.</div>");
                }
            }
        %>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <jsp:include page="footer.jsp" />
</body>
</html>