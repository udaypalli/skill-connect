<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.skillconnect.util.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Service Providers - SkillConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            font-family: 'Poppins', sans-serif;
            color: #333;
            min-height: 100vh;
            margin: 0;
            padding-top: 70px;
            padding-bottom: 80px;
        }
        .manage-container {
            margin-left: 250px;
            padding: 20px;
            width: calc(100% - 250px);
            max-width: 1200px;
            margin-right: auto;
        }
        .manage-pincode-select {
            max-width: 300px;
            margin-bottom: 30px;
        }
        .manage-filter-btns {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
        }
        .manage-btn-filter {
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            color: #fff;
            border: none;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .manage-btn-pending {
            background: #FF6200;
        }
        .manage-btn-pending:hover, .manage-btn-pending.active {
            background: #E65100;
        }
        .manage-btn-verified {
            background: #28a745;
        }
        .manage-btn-verified:hover, .manage-btn-verified.active {
            background: #218838;
        }
        .manage-btn-rejected {
            background: #dc3545;
        }
        .manage-btn-rejected:hover, .manage-btn-rejected.active {
            background: #c82333;
        }
        .manage-provider-card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            padding: 20px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.3s ease;
            border: 1px solid #e9ecef;
        }
        .manage-provider-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 25px rgba(0, 0, 0, 0.1);
        }
        .manage-column {
            flex: 1;
            padding: 0 15px;
        }
        .manage-provider-info {
            font-size: 14px;
            color: #555;
            margin-bottom: 8px;
            line-height: 1.4;
        }
        .manage-provider-info strong {
            color: #333;
            font-weight: 600;
        }
        .manage-btn-group {
            display: flex;
            gap: 10px;
        }
        .manage-btn-action {
            padding: 8px 16px;
            border-radius: 6px;
            font-weight: 600;
            color: #fff;
            border: none;
            transition: all 0.3s ease;
            font-size: 13px;
            text-transform: uppercase;
        }
        .manage-btn-orange {
            background: #FF6200;
        }
        .manage-btn-orange:hover {
            background: #E65100;
        }
        .manage-btn-green {
            background: #28a745;
        }
        .manage-btn-green:hover {
            background: #218838;
        }
        .manage-btn-red {
            background: #dc3545;
        }
        .manage-btn-red:hover {
            background: #c82333;
        }
        .manage-pincode-message {
            font-size: 16px;
            color: #333;
            margin-bottom: 20px;
        }
        .manage-no-data {
            font-size: 16px;
            color: #666;
            text-align: center;
            padding: 20px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <%@ include file="admin_header.jsp" %>
    <%@ include file="admin_sidebar.jsp" %>

    <div class="manage-container">
        <h2 class="text-center mb-4">Manage Service Providers</h2>

        <!-- Pincode Dropdown -->
        <div class="manage-pincode-select">
            <label for="pincode" class="form-label fw-bold">Select Pincode:</label>
            <select id="pincode" name="pincode" class="form-select" onchange="fetchProviders(this.value)">
                <option value="">-- Select Pincode --</option>
                <%
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    try {
                        conn = DBConnection.getConnection();
                        String sql = "SELECT DISTINCT pincode FROM ServiceProviders WHERE pincode IS NOT NULL ORDER BY pincode";
                        pstmt = conn.prepareStatement(sql);
                        rs = pstmt.executeQuery();
                        while (rs.next()) {
                            String pincode = rs.getString("pincode");
                            String selected = pincode.equals(request.getParameter("pincode")) ? "selected" : "";
                %>
                            <option value="<%= pincode %>" <%= selected %>><%= pincode %></option>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) rs.close();
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                %>
            </select>
        </div>

        <!-- Handle Status Update -->
        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String providerId = request.getParameter("providerId");
                String newStatus = request.getParameter("status");
                String selectedPincode = request.getParameter("pincode");
                String currentFilter = request.getParameter("currentFilter");
                conn = null;
                pstmt = null;
                try {
                    conn = DBConnection.getConnection();
                    String sql = "UPDATE ServiceProviders SET verification_status = ? WHERE provider_id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, newStatus);
                    pstmt.setInt(2, Integer.parseInt(providerId));
                    pstmt.executeUpdate();
                    response.sendRedirect("admin_manage_sprovider.jsp?pincode=" + selectedPincode + "&status=" + currentFilter);
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            }
        %>

        <!-- Filter Buttons and Providers Display -->
        <%
            String selectedPincode = request.getParameter("pincode");
            String selectedStatus = request.getParameter("status") != null ? request.getParameter("status") : "Pending";
            if (selectedPincode != null && !selectedPincode.isEmpty()) {
        %>
                <div class="manage-pincode-message">
                    Currently viewing providers for pincode: <strong><%= selectedPincode %></strong>
                </div>
                <div class="manage-filter-btns">
                    <button class="manage-btn-filter manage-btn-pending <%= selectedStatus.equals("Pending") ? "active" : "" %>" onclick="filterProviders('Pending')">Pending</button>
                    <button class="manage-btn-filter manage-btn-verified <%= selectedStatus.equals("Verified") ? "active" : "" %>" onclick="filterProviders('Verified')">Verified</button>
                    <button class="manage-btn-filter manage-btn-rejected <%= selectedStatus.equals("Rejected") ? "active" : "" %>" onclick="filterProviders('Rejected')">Rejected</button>
                </div>

                <div class="manage-category-section">
                    <%
                        conn = null;
                        pstmt = null;
                        rs = null;
                        boolean hasData = false;
                        try {
                            conn = DBConnection.getConnection();
                            String sql = "SELECT * FROM ServiceProviders WHERE pincode = ? AND verification_status = ?";
                            pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, selectedPincode);
                            pstmt.setString(2, selectedStatus);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                hasData = true;
                                int providerId = rs.getInt("provider_id");
                                String name = rs.getString("name");
                                String phone = rs.getString("phone");
                                String expertise = rs.getString("expertise");
                                String location = rs.getString("location");
                                String pricing = rs.getString("pricing");
                                String workingHours = rs.getString("working_hours");
                                String availability = rs.getString("availability");
                                String pincode = rs.getString("pincode");
                                String email = rs.getString("email");
                                String verificationStatus = rs.getString("verification_status");
                    %>
                                <div class="manage-provider-card">
                                    <div class="manage-column">
                                        <p class="manage-provider-info"><strong>Name:</strong> <%= name %></p>
                                        <p class="manage-provider-info"><strong>Email:</strong> <%= email != null ? email : "N/A" %></p>
                                        <p class="manage-provider-info"><strong>Phone:</strong> <%= phone != null ? phone : "N/A" %></p>
                                    </div>
                                    <div class="manage-column">
                                        <p class="manage-provider-info"><strong>Expertise:</strong> <%= expertise != null ? expertise : "N/A" %></p>
                                        <p class="manage-provider-info"><strong>Location:</strong> <%= location != null ? location : "N/A" %></p>
                                        <p class="manage-provider-info"><strong>Pincode:</strong> <%= pincode != null ? pincode : "N/A" %></p>
                                    </div>
                                    <div class="manage-column">
                                        <p class="manage-provider-info"><strong>Pricing:</strong> ₹<%= pricing != null ? pricing : "N/A" %></p>
                                        <p class="manage-provider-info"><strong>Hours:</strong> <%= workingHours != null ? workingHours : "N/A" %></p>
                                        <p class="manage-provider-info"><strong>Availability:</strong> <%= availability.equals("1") ? "Available" : "Not Available" %></p>
                                    </div>
                                    <div class="manage-btn-group">
                                        <% if (selectedStatus.equals("Pending")) { %>
                                            <form action="admin_manage_sprovider.jsp" method="post" style="display:inline;">
                                                <input type="hidden" name="providerId" value="<%= providerId %>">
                                                <input type="hidden" name="status" value="Verified">
                                                <input type="hidden" name="pincode" value="<%= selectedPincode %>">
                                                <input type="hidden" name="currentFilter" value="<%= selectedStatus %>">
                                                <button type="submit" class="manage-btn-action manage-btn-green">Accept</button>
                                            </form>
                                            <form action="admin_manage_sprovider.jsp" method="post" style="display:inline;">
                                                <input type="hidden" name="providerId" value="<%= providerId %>">
                                                <input type="hidden" name="status" value="Rejected">
                                                <input type="hidden" name="pincode" value="<%= selectedPincode %>">
                                                <input type="hidden" name="currentFilter" value="<%= selectedStatus %>">
                                                <button type="submit" class="manage-btn-action manage-btn-red">Reject</button>
                                            </form>
                                        <% } else if (selectedStatus.equals("Verified")) { %>
                                            <form action="admin_manage_sprovider.jsp" method="post" style="display:inline;">
                                                <input type="hidden" name="providerId" value="<%= providerId %>">
                                                <input type="hidden" name="status" value="Pending">
                                                <input type="hidden" name="pincode" value="<%= selectedPincode %>">
                                                <input type="hidden" name="currentFilter" value="<%= selectedStatus %>">
                                                <button type="submit" class="manage-btn-action manage-btn-orange">Pending</button>
                                            </form>
                                            <form action="admin_manage_sprovider.jsp" method="post" style="display:inline;">
                                                <input type="hidden" name="providerId" value="<%= providerId %>">
                                                <input type="hidden" name="status" value="Rejected">
                                                <input type="hidden" name="pincode" value="<%= selectedPincode %>">
                                                <input type="hidden" name="currentFilter" value="<%= selectedStatus %>">
                                                <button type="submit" class="manage-btn-action manage-btn-red">Reject</button>
                                            </form>
                                        <% } else if (selectedStatus.equals("Rejected")) { %>
                                            <form action="admin_manage_sprovider.jsp" method="post" style="display:inline;">
                                                <input type="hidden" name="providerId" value="<%= providerId %>">
                                                <input type="hidden" name="status" value="Verified">
                                                <input type="hidden" name="pincode" value="<%= selectedPincode %>">
                                                <input type="hidden" name="currentFilter" value="<%= selectedStatus %>">
                                                <button type="submit" class="manage-btn-action manage-btn-green">Accept</button>
                                            </form>
                                            <form action="admin_manage_sprovider.jsp" method="post" style="display:inline;">
                                                <input type="hidden" name="providerId" value="<%= providerId %>">
                                                <input type="hidden" name="status" value="Pending">
                                                <input type="hidden" name="pincode" value="<%= selectedPincode %>">
                                                <input type="hidden" name="currentFilter" value="<%= selectedStatus %>">
                                                <button type="submit" class="manage-btn-action manage-btn-orange">Pending</button>
                                            </form>
                                        <% } %>
                                    </div>
                                </div>
                    <%
                            }
                            if (!hasData) {
                    %>
                                <div class="manage-no-data">
                                    There are no <%= selectedStatus.toLowerCase() %> records for pincode <strong><%= selectedPincode %></strong>.
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
                    %>
                </div>
        <%
            }
        %>
    </div>

    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const selectedPincode = "<%= selectedPincode != null ? selectedPincode : "" %>";

        function fetchProviders(pincode) {
            if (pincode) {
                window.location.href = "admin_manage_sprovider.jsp?pincode=" + pincode + "&status=Pending";
            }
        }

        function filterProviders(status) {
            if (selectedPincode) {
                window.location.href = "admin_manage_sprovider.jsp?pincode=" + selectedPincode + "&status=" + status;
            } else {
                console.error("No pincode selected!");
            }
        }
    </script>
</body>
</html>