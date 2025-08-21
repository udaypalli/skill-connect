<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.skillconnect.util.DBConnection, java.time.LocalDate" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Manage Promotions - SkillConnect</title>
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
        .promo-info {
            font-size: 14px;
            color: #555;
            margin-bottom: 8px;
        }
        .promo-info strong {
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
        .btn-warning {
            background-color: #ffc107;
            border-color: #ffc107;
            text-transform: uppercase;
            font-weight: 600;
            padding: 8px 16px;
        }
        .btn-warning:hover {
            background-color: #e0a800;
            border-color: #e0a800;
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
        .filter-btn-pending {
            background: rgb(13 110 253);
        }
        .filter-btn-pending:hover, .filter-btn-pending.active {
            background: #0b5ed7;
        }
        .filter-btn-approved {
            background: #28a745;
        }
        .filter-btn-approved:hover, .filter-btn-approved.active {
            background: #218838;
        }
        .filter-btn-published {
            background: #ffc107;
        }
        .filter-btn-published:hover, .filter-btn-published.active {
            background: #e0a800;
        }
        .filter-btn-rejected {
            background: #dc3545;
        }
        .filter-btn-rejected:hover, .filter-btn-rejected.active {
            background: #c82333;
        }
        .search-bar {
            max-width: 400px;
            margin-bottom: 20px;
        }
        .payment-status-box {
            display: inline-block;
            width: 15px;
            height: 15px;
            border-radius: 3px;
            margin-left: 10px;
            vertical-align: middle;
        }
        .payment-paid {
            background-color: #28a745; /* Green */
        }
        .payment-not-paid {
            background-color: #dc3545; /* Red */
        }
    </style>
</head>
<body>
    <%@ include file="admin_header.jsp" %>
    <%@ include file="admin_sidebar.jsp" %>

    <div class="containerr mt-5">
        <h2 class="text-center main-header"><i class="bi bi-megaphone"></i>Manage Promotions</h2>

        <!-- Pincode Search -->
        <form class="search-bar mx-auto" method="GET" action="admin_promotions.jsp">
            <div class="input-group">
                <input type="text" class="form-control" name="pincode" placeholder="Enter Pincode" value="<%= request.getParameter("pincode") != null ? request.getParameter("pincode") : "" %>">
                <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Search</button>
            </div>
        </form>

        <!-- Filter Buttons -->
        <%
            String pincode = request.getParameter("pincode");
            String selectedFilter = request.getParameter("filter") != null ? request.getParameter("filter") : "Pending";
            LocalDate currentDate = LocalDate.now();
        %>
        <div class="filter-btns">
            <button class="filter-btn filter-btn-pending <%= selectedFilter.equals("Pending") ? "active" : "" %>" onclick="filterPromotions('Pending')"><i class="bi bi-hourglass"></i>Pending</button>
            <button class="filter-btn filter-btn-approved <%= selectedFilter.equals("Approved") ? "active" : "" %>" onclick="filterPromotions('Approved')"><i class="bi bi-check2"></i>Approved</button>
            <button class="filter-btn filter-btn-published <%= selectedFilter.equals("Published") ? "active" : "" %>" onclick="filterPromotions('Published')"><i class="bi bi-megaphone"></i>Published</button>
            <button class="filter-btn filter-btn-rejected <%= selectedFilter.equals("Rejected") ? "active" : "" %>" onclick="filterPromotions('Rejected')"><i class="bi bi-x"></i>Rejected</button>
        </div>

        <!-- Handle Promotion Actions -->
        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String promotionIdStr = request.getParameter("promotionId");
                String action = request.getParameter("action");
                int adminId = session.getAttribute("admin_id") != null ? (Integer) session.getAttribute("admin_id") : 1; // Assuming admin_id from session

                if (promotionIdStr != null && !promotionIdStr.isEmpty() && action != null && !action.isEmpty()) {
                    int promotionId = Integer.parseInt(promotionIdStr);
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    try {
                        conn = DBConnection.getConnection();

                        if (action.equals("Approve")) {
                            String updateQuery = "UPDATE Promotions SET status = 'Approved', approved_by = ?, approved_at = NOW() WHERE promotion_id = ?";
                            pstmt = conn.prepareStatement(updateQuery);
                            pstmt.setInt(1, adminId);
                            pstmt.setInt(2, promotionId);
                            pstmt.executeUpdate();
                            out.println("<div class='alert alert-success' role='alert'><i class='bi bi-check-circle'></i> Promotion approved successfully!</div>");
                        } else if (action.equals("Publish")) {
                            String countQuery = "SELECT COUNT(*) FROM Promotions WHERE status = 'Published' AND provider_id IN (SELECT provider_id FROM Locations WHERE SUBSTRING(address, -6) = ?)";
                            pstmt = conn.prepareStatement(countQuery);
                            pstmt.setString(1, pincode);
                            ResultSet rsCount = pstmt.executeQuery();
                            rsCount.next();
                            int publishedCount = rsCount.getInt(1);
                            if (publishedCount < 5) {
                                String updateQuery = "UPDATE Promotions SET status = 'Published', approved_by = ?, approved_at = NOW() WHERE promotion_id = ?";
                                pstmt = conn.prepareStatement(updateQuery);
                                pstmt.setInt(1, adminId);
                                pstmt.setInt(2, promotionId);
                                pstmt.executeUpdate();
                                out.println("<div class='alert alert-success' role='alert'><i class='bi bi-check-circle'></i> Promotion published successfully!</div>");
                            } else {
                                out.println("<div class='alert alert-warning' role='alert'><i class='bi bi-exclamation-triangle'></i> Limit of 5 published promotions reached for this pincode!</div>");
                            }
                            rsCount.close();
                        } else if (action.equals("Reject") || action.equals("Dispose")) {
                            String updateQuery = "UPDATE Promotions SET status = 'Rejected' WHERE promotion_id = ?";
                            pstmt = conn.prepareStatement(updateQuery);
                            pstmt.setInt(1, promotionId);
                            pstmt.executeUpdate();
                            out.println("<div class='alert alert-success' role='alert'><i class='bi bi-check-circle'></i> Promotion " + (action.equals("Dispose") ? "disposed" : "rejected") + " successfully!</div>");
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error processing promotion: " + e.getMessage() + "</div>");
                    } finally {
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                }
            }
        %>

        <!-- Promotions List -->
        <%
            if (pincode != null && !pincode.isEmpty()) {
                out.println("<p class='text-center promo-info'><strong>You are viewing promotions for Pincode:</strong> " + pincode + "</p>");

                if (selectedFilter.equals("Approved")) {
                    out.println("<div class='alert alert-info' role='alert'><i class='bi bi-info-circle'></i> Only 5 promotions are allowed per pincode. Carefully publish them!</div>");
                } else if (selectedFilter.equals("Published")) {
                    Connection connCount = DBConnection.getConnection();
                    PreparedStatement pstmtCount = connCount.prepareStatement("SELECT COUNT(*) FROM Promotions WHERE status = 'Published' AND pincode = ?");
                    pstmtCount.setString(1, pincode);
                    ResultSet rsCount = pstmtCount.executeQuery();
                    rsCount.next();
                    int publishedCount = rsCount.getInt(1);
                    out.println("<p class='text-center promo-info'><strong>Published Promotions for this Pincode:</strong> " + publishedCount + "/5</p>");
                    rsCount.close();
                    pstmtCount.close();
                    connCount.close();
                }

                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                boolean hasData = false;
                try {
                    conn = DBConnection.getConnection();
                    String query = "SELECT p.promotion_id, p.provider_id, p.title, p.description, p.discount_percentage, p.start_date, p.end_date, p.status, p.created_at, sp.name AS provider_name " +
                                  "FROM Promotions p " +
                                  "JOIN ServiceProviders sp ON p.provider_id = sp.provider_id " +
                                  "WHERE p.pincode = ? " +
                                  "AND p.status = ? " +
                                  "ORDER BY p.end_date ASC"; // Closest end_date first
                    pstmt = conn.prepareStatement(query);
                    pstmt.setString(1, pincode);
                    pstmt.setString(2, selectedFilter);
                    rs = pstmt.executeQuery();

                    while (rs.next()) {
                        hasData = true;
                        int promotionId = rs.getInt("promotion_id");
                        int providerId = rs.getInt("provider_id");
                        String title = rs.getString("title");
                        String description = rs.getString("description");
                        double discountPercentage = rs.getDouble("discount_percentage");
                        String startDate = rs.getString("start_date");
                        String endDate = rs.getString("end_date");
                        String createdAt = rs.getString("created_at");
                        String providerName = rs.getString("provider_name");
                        String status = rs.getString("status");

                        // Check payment status for Pending promotions using PlatformFees
                        boolean isPaid = false;
                        if (status.equals("Pending")) {
                            PreparedStatement pstmtPayment = conn.prepareStatement(
                                "SELECT COUNT(*) " +
                                "FROM PlatformFees pf " +
                                "WHERE pf.provider_id = ? " +
                                "AND pf.type = 'Promotion' " +
                                "AND pf.payment_status = 'Paid' " +
                                "AND pf.transaction_date > ? " +
                                "AND pf.transaction_date < pf.due_date"
                            );
                            pstmtPayment.setInt(1, providerId);
                            pstmtPayment.setString(2, createdAt);
                            ResultSet rsPayment = pstmtPayment.executeQuery();
                            rsPayment.next();
                            isPaid = rsPayment.getInt(1) > 0;
                            rsPayment.close();
                            pstmtPayment.close();
                        }
        %>
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="bi bi-megaphone"></i><%= title %> - <%= status %>
                                    <% if (status.equals("Pending")) { %>
                                        <span class="payment-status-box <%= isPaid ? "payment-paid" : "payment-not-paid" %>"></span>
                                    <% } %>
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <p class="promo-info"><strong>Provider:</strong> <%= providerName %></p>
                                        <p class="promo-info"><strong>Description:</strong> <%= description %></p>
                                    </div>
                                    <div class="col-md-6">
                                        <p class="promo-info"><strong>Discount:</strong> <%= discountPercentage %>%</p>
                                        <p class="promo-info"><strong>Start Date:</strong> <%= startDate %></p>
                                        <p class="promo-info"><strong>End Date:</strong> <%= endDate %></p>
                                        <% if (status.equals("Published")) { %>
                                            <p class="promo-info"><strong>Current Date:</strong> <%= currentDate %></p>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="btn-group d-flex mt-3">
                                    <% if (status.equals("Pending")) { %>
                                        <form action="admin_promotions.jsp" method="POST">
                                            <input type="hidden" name="promotionId" value="<%= promotionId %>">
                                            <input type="hidden" name="action" value="Approve">
                                            <input type="hidden" name="pincode" value="<%= pincode %>">
                                            <input type="hidden" name="filter" value="<%= selectedFilter %>">
                                            <button type="submit" class="btn btn-success"><i class="bi bi-check2"></i>Approve</button>
                                        </form>
                                        <form action="admin_promotions.jsp" method="POST">
                                            <input type="hidden" name="promotionId" value="<%= promotionId %>">
                                            <input type="hidden" name="action" value="Reject">
                                            <input type="hidden" name="pincode" value="<%= pincode %>">
                                            <input type="hidden" name="filter" value="<%= selectedFilter %>">
                                            <button type="submit" class="btn btn-danger"><i class="bi bi-x"></i>Reject</button>
                                        </form>
                                    <% } else if (status.equals("Approved")) { %>
                                        <form action="admin_promotions.jsp" method="POST">
                                            <input type="hidden" name="promotionId" value="<%= promotionId %>">
                                            <input type="hidden" name="action" value="Publish">
                                            <input type="hidden" name="pincode" value="<%= pincode %>">
                                            <input type="hidden" name="filter" value="<%= selectedFilter %>">
                                            <button type="submit" class="btn btn-warning"><i class="bi bi-megaphone"></i>Publish</button>
                                        </form>
                                    <% } else if (status.equals("Published")) { %>
                                        <form action="admin_promotions.jsp" method="POST">
                                            <input type="hidden" name="promotionId" value="<%= promotionId %>">
                                            <input type="hidden" name="action" value="Dispose">
                                            <input type="hidden" name="pincode" value="<%= pincode %>">
                                            <input type="hidden" name="filter" value="<%= selectedFilter %>">
                                            <button type="submit" class="btn btn-danger"><i class="bi bi-trash"></i>Dispose</button>
                                        </form>
                                    <% } %>
                                </div>
                            </div>
                        </div>
        <%
                    }
                    if (!hasData) {
        %>
                        <div class="no-data">
                            <i class="bi bi-info-circle"></i> No <%= selectedFilter.toLowerCase() %> promotions found for Pincode: <%= pincode %>
                        </div>
        <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error fetching promotions: " + e.getMessage() + "</div>");
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            } else {
                out.println("<div class='alert alert-warning' role='alert'><i class='bi bi-exclamation-triangle'></i> Please enter a pincode to view promotions.</div>");
            }
        %>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterPromotions(status) {
            const pincode = "<%= pincode != null ? pincode : 0 %>";
            window.location.href = "admin_promotions.jsp?filter=" + status + "&pincode=" + pincode;
        }
    </script>
  
</body>
</html>