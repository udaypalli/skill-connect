<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.skillconnect.util.DBConnection" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Provider Support - Raise a Dispute</title>
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
        .orange-btnnn {
            background-color: #ff6f00; /* Orange */
            border-color: #ff6f00;
            color: #fff;
        }
        .orange-btnnn:hover {
            background-color: #e65a00; /* Darker Orange */
            border-color: #e65a00;
        }
        .form-label {
            font-weight: bold;
            color: #003366; /* Updated label color */
        }
        .bi {
            margin-right: 5px;
            color: #ff6f00; /* Updated icon color to orange */
        }
        .main-header {
            color: rgb(13 110 253); /* Updated main header color */
        }
    </style>
</head>
<body>
<jsp:include page="service_provider_header.jsp" />
    <!-- Main Content -->
    <div class="container mt-5">
        <h2 class="mb-4 text-center main-header"><i class="bi bi-headset"></i>Raise a Dispute</h2>

        <!-- Dispute Form -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0"><i class="bi bi-info-circle"></i>Provide Dispute Details</h5>
            </div>
            <div class="card-body">
                <form action="service_provider_customer_support.jsp" method="POST">
                    <!-- Booking ID Dropdown -->
                    <div class="mb-3">
                        <label for="bookingId" class="form-label"><i class="bi bi-person"></i>Select Booking</label>
                        <select class="form-select" id="bookingId" name="bookingId" required>
                            <option value="">Choose a booking...</option>
                            <%
                                // Fetch provider email from session
                                String providerEmail = (String) session.getAttribute("userEmail");
                                if (providerEmail != null) {
                                    Connection conn = null;
                                    PreparedStatement pstmt = null;
                                    ResultSet rs = null;
                                    try {
                                        conn = DBConnection.getConnection();
                                        String query = "SELECT b.booking_id, u.name  " +
                                                "FROM Users u " +
                                                "JOIN Bookings b ON u.user_id = b.user_id " +
                                                "JOIN ServiceProviders sp ON b.provider_id = sp.provider_id " +
                                                "WHERE sp.email = ? AND b.status IN ('Pending', 'Accepted', 'Completed', 'Cancelled')";

                                        pstmt = conn.prepareStatement(query);
                                        pstmt.setString(1, providerEmail);
                                        rs = pstmt.executeQuery();
                                        while (rs.next()) {
                                            int bookingId = rs.getInt("booking_id");
                                            String userName = rs.getString("name");
                                            out.println("<option value='" + bookingId + "'>Booking ID: " + bookingId + " - " + userName + "</option>");
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
                    <button type="submit" class="btn orange-btnnn" style="background-color: #ff6f00; border-color: #ff6f00; color:white;"><i class="bi bi-send"></i>Submit Dispute</button>
                </form>
            </div>
        </div>

        <!-- Handle Form Submission -->
        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String bookingIdStr = request.getParameter("bookingId");
                String issueDescription = request.getParameter("issueDescription");
                int bookingIdd = Integer.parseInt(bookingIdStr);
                
                Connection connn = DBConnection.getConnection();
                PreparedStatement pstmtt = null;
                
                String userQuery = "SELECT user_id FROM Bookings WHERE booking_id = ?";
                pstmtt = connn.prepareStatement(userQuery);
                pstmtt.setInt(1, bookingIdd);
                ResultSet rss = pstmtt.executeQuery();

                int userId = -1;
                if (rss.next()) {
                    userId = rss.getInt("user_id");
                }
                rss.close();
                pstmtt.close();


                if (bookingIdStr != null && !bookingIdStr.isEmpty() && issueDescription != null && !issueDescription.isEmpty()) {
                    int bookingId = Integer.parseInt(bookingIdStr);
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    try {
                        conn = DBConnection.getConnection();

                        // Fetch provider_id from the session email
                        String query = "SELECT provider_id FROM ServiceProviders WHERE email = ?";
                        pstmt = conn.prepareStatement(query);
                        pstmt.setString(1, providerEmail);
                        ResultSet rs = pstmt.executeQuery();
                        if (rs.next()) {
                            int providerId = rs.getInt("provider_id");

                            // Insert dispute into the Disputes table
                            String insertQuery = "INSERT INTO Disputes (booking_id, provider_id, issue_description,user_id, status) VALUES (?, ?, ?,?, 'Open')";
                            pstmt = conn.prepareStatement(insertQuery);
                            pstmt.setInt(1, bookingId);
                            pstmt.setInt(2, providerId);
                            pstmt.setString(3, issueDescription);
                            pstmt.setInt(4, userId);
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