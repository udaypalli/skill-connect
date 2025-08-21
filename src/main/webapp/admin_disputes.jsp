<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.skillconnect.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Manage Disputes - SkillConnect</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS (Naukri.com Theme) -->
    <style>
        body {
            background: #f8f9fa;
            font-family: 'Arial', sans-serif;
            min-height: 100vh;
            margin: 0;
            padding-top: 70px; /* Space for header */
            padding-bottom: 80px; /* Space for footer */
        }
        .containerr {
            max-width: calc(100% - 250px); /* Adjust container width based on sidebar width */
            margin-left: 250px; /* Align content after the sidebar */
            padding: 20px;
        }
        .main-header {
            color: rgb(13 110 253); /* Naukri Blue */
            font-weight: 600;
            margin-bottom: 30px;
        }
        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s ease;
            margin-bottom: 20px;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 25px rgba(0, 0, 0, 0.1);
        }
        .card-header {
            background: rgb(13 110 253); /* Naukri Blue */
            color: #fff;
            border-radius: 12px 12px 0 0;
            padding: 15px 20px;
            font-weight: 600;
        }
        .card-body {
            padding: 20px;
        }
        .dispute-info {
            font-size: 14px;
            color: #555;
            margin-bottom: 8px;
        }
        .dispute-info strong {
            color: #333;
            font-weight: 600;
        }
        .btn-primary {
            background-color: rgb(13 110 253);
            border-color: rgb(13 110 253);
            text-transform: uppercase;
            font-weight: 600;
            padding: 8px 16px;
        }
        .btn-primary:hover {
            background-color: #0b5ed7;
            border-color: #0b5ed7;
        }
        .btn-success {
            background-color: #28a745;
            border-color: #28a745;
            text-transform: uppercase;
            font-weight: 600;
            padding: 8px 16px;
        }
        .btn-success:hover {
            background-color: #218838;
            border-color: #218838;
        }
        .btn-danger {
            background-color: #dc3545;
            border-color: #dc3545;
            text-transform: uppercase;
            font-weight: 600;
            padding: 8px 16px;
        }
        .btn-danger:hover {
            background-color: #c82333;
            border-color: #c82333;
        }
        .btn-group {
            gap: 10px;
        }
        .form-label {
            font-weight: bold;
            color: #003366;
        }
        .bi {
            margin-right: 5px;
            color: #ff6f00; /* Orange accent */
        }
        .alert {
            border-radius: 8px;
        }
        .no-data {
            text-align: center;
            font-size: 16px;
            color: #666;
            padding: 20px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        }
        .filter-btns {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
        }
        .filter-btn {
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            color: #fff;
            border: none;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .filter-btn-open {
            background: rgb(13 110 253);
        }
        .filter-btn-open:hover, .filter-btn-open.active {
            background: #0b5ed7;
        }
        .filter-btn-resolved {
            background: #28a745;
        }
        .filter-btn-resolved:hover, .filter-btn-resolved.active {
            background: #218838;
        }
        .filter-btn-rejected {
            background: #dc3545;
        }
        .filter-btn-rejected:hover, .filter-btn-rejected.active {
            background: #c82333;
        }
    </style>
</head>
<body>
    <%@ include file="admin_header.jsp" %>
    <%@ include file="admin_sidebar.jsp" %>

    <div class="containerr mt-5">
        <h2 class="text-center main-header"><i class="bi bi-shield-check"></i>Manage Disputes</h2>

        <!-- Filter Buttons -->
        <%
            String selectedFilter = request.getParameter("filter") != null ? request.getParameter("filter") : "Open";
        %>
        <div class="filter-btns">
            <button class="filter-btn filter-btn-open <%= selectedFilter.equals("Open") ? "active" : "" %>" onclick="filterDisputes('Open')"><i class="bi bi-folder"></i>Open</button>
            <button class="filter-btn filter-btn-resolved <%= selectedFilter.equals("Resolved") ? "active" : "" %>" onclick="filterDisputes('Resolved')"><i class="bi bi-check2"></i>Resolved</button>
            <button class="filter-btn filter-btn-rejected <%= selectedFilter.equals("Rejected") ? "active" : "" %>" onclick="filterDisputes('Rejected')"><i class="bi bi-x"></i>Rejected</button>
        </div>

        <!-- Handle Dispute Resolution -->
        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String disputeIdStr = request.getParameter("disputeId");
                String newStatus = request.getParameter("status");
                String resolutionNote = request.getParameter("resolutionNote");

                if (disputeIdStr != null && !disputeIdStr.isEmpty() && newStatus != null && !newStatus.isEmpty()) {
                    int disputeId = Integer.parseInt(disputeIdStr);
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    try {
                        conn = DBConnection.getConnection();

                        // Update dispute status
                        String updateQuery = "UPDATE Disputes SET status = ?, resolution_note = ? WHERE dispute_id = ?";
                        pstmt = conn.prepareStatement(updateQuery);
                        pstmt.setString(1, newStatus);
                        pstmt.setString(2, resolutionNote != null && !resolutionNote.isEmpty() ? resolutionNote : null);
                        pstmt.setInt(3, disputeId);
                        int rowsAffected = pstmt.executeUpdate();

                        if (rowsAffected > 0) {
                            out.println("<div class='alert alert-success' role='alert'><i class='bi bi-check-circle'></i> Dispute " + (newStatus.equals("Resolved") ? "resolved" : "rejected") + " successfully!</div>");

                            // Fetch dispute details for notification
                            String disputeQuery = "SELECT d.booking_id, d.user_id, d.provider_id, d.issue_description, u.name AS user_name, sp.name AS provider_name " +
                                                 "FROM Disputes d " +
                                                 "LEFT JOIN Users u ON d.user_id = u.user_id " +
                                                 "LEFT JOIN ServiceProviders sp ON d.provider_id = sp.provider_id " +
                                                 "WHERE d.dispute_id = ?";
                            pstmt = conn.prepareStatement(disputeQuery);
                            pstmt.setInt(1, disputeId);
                            rs = pstmt.executeQuery();

                            if (rs.next()) {
                                int bookingId = rs.getInt("booking_id");
                                int userId = rs.getInt("user_id");
                                int providerId = rs.getInt("provider_id");
                                String issueDescription = rs.getString("issue_description");
                                String userName = rs.getString("user_name");
                                String providerName = rs.getString("provider_name");

                                // Construct notification message
                                String statusMessage = newStatus.equals("Resolved") ? "resolved" : "rejected";
                                String notificationMessage = "Dispute ID: " + disputeId + " regarding Booking ID: " + bookingId + " between " +
                                                             (userName != null ? userName : "User") + " and " + 
                                                             (providerName != null ? providerName : "Provider") + 
                                                             " with issue: '" + issueDescription + "' has been " + statusMessage + 
                                                             (resolutionNote != null && !resolutionNote.isEmpty() ? ". Resolution: " + resolutionNote : ".");

                                // Insert notification into Notifications table
                                String notifyQuery = "INSERT INTO Notifications (user_id, provider_id, message) VALUES (?, ?, ?)";
                                pstmt = conn.prepareStatement(notifyQuery);
                                pstmt.setInt(1, userId);
                                pstmt.setInt(2, providerId);
                                pstmt.setString(3, notificationMessage);
                                pstmt.executeUpdate();
                            }
                        } else {
                            out.println("<div class='alert alert-warning' role='alert'><i class='bi bi-exclamation-triangle'></i> No dispute found with ID: " + disputeId + "</div>");
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error updating dispute: " + e.getMessage() + "</div>");
                    } finally {
                        if (rs != null) rs.close();
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                } else {
                    out.println("<div class='alert alert-warning' role='alert'><i class='bi bi-exclamation-triangle'></i> Please provide all required fields.</div>");
                }
            }
        %>

        <!-- Disputes List -->
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            boolean hasData = false;
            try {
                conn = DBConnection.getConnection();
                String query = "SELECT d.dispute_id, d.booking_id, u.name AS user_name, sp.name AS provider_name, d.issue_description, d.status " +
                              "FROM Disputes d " +
                              "LEFT JOIN Users u ON d.user_id = u.user_id " +
                              "LEFT JOIN ServiceProviders sp ON d.provider_id = sp.provider_id " +
                              "WHERE d.status = ? " +
                              "ORDER BY d.created_at DESC";
                pstmt = conn.prepareStatement(query);
                pstmt.setString(1, selectedFilter);
                rs = pstmt.executeQuery();

                while (rs.next()) {
                    hasData = true;
                    int disputeId = rs.getInt("dispute_id");
                    int bookingId = rs.getInt("booking_id");
                    String userName = rs.getString("user_name");
                    String providerName = rs.getString("provider_name");
                    String issueDescription = rs.getString("issue_description");
                    String status = rs.getString("status");
        %>
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="bi bi-info-circle"></i>Dispute ID: <%= disputeId %> - Status: <%= status %></h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-8">
                                    <p class="dispute-info"><strong>Booking ID:</strong> <%= bookingId %></p>
                                    <p class="dispute-info"><strong>User:</strong> <%= userName != null ? userName : "N/A" %></p>
                                    <p class="dispute-info"><strong>Provider:</strong> <%= providerName != null ? providerName : "N/A" %></p>
                                    <p class="dispute-info"><strong>Issue Description:</strong> <%= issueDescription %></p>
                                </div>
                                <div class="col-md-4">
                                    <% if (status.equals("Open")) { %>
                                        <form action="admin_disputes.jsp" method="POST">
                                            <input type="hidden" name="disputeId" value="<%= disputeId %>">
                                            <input type="hidden" name="filter" value="<%= selectedFilter %>">
                                            <div class="mb-3">
                                                <label for="resolutionNote_<%= disputeId %>" class="form-label"><i class="bi bi-pencil"></i>Resolution Note</label>
                                                <textarea class="form-control" id="resolutionNote_<%= disputeId %>" name="resolutionNote" rows="2" placeholder="Optional note..."></textarea>
                                            </div>
                                            <div class="btn-group d-flex">
                                                <button type="submit" name="status" value="Resolved" class="btn btn-success"><i class="bi bi-check2"></i>Resolve</button>
                                                <button type="submit" name="status" value="Rejected" class="btn btn-danger"><i class="bi bi-x"></i>Reject</button>
                                            </div>
                                        </form>
                                    <% } else { %>
                                        <p class="dispute-info text-muted"><i class="bi bi-lock"></i>Dispute is already <%= status.toLowerCase() %>.</p>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
        <%
                }
                if (!hasData) {
        %>
                    <div class="no-data">
                        <i class="bi bi-info-circle"></i> No <%= selectedFilter.toLowerCase() %> disputes found.
                    </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error fetching disputes: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            }
        %>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterDisputes(status) {
            window.location.href = "admin_disputes.jsp?filter=" + status;
        }
    </script>
   
</body>
</html>