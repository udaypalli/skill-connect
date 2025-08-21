<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.skillconnect.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Payments - SkillConnect</title>
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
            max-width: 100%; /* Full width without sidebar */
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
            padding: 10px; /* Reduced padding for compactness */
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
            padding: 6px 12px; /* Smaller padding for compactness */
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
            padding: 6px 12px; /* Smaller padding for compactness */
        }
        .btn-danger:hover {
            background-color: #c82333;
            border-color: #c82333;
        }
        .bi {
            margin-right: 5px;
            color: #ff6f00; /* Orange accent */
        }
        .alert {
            border-radius: 8px;
        }
        .table {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            font-size: 14px; /* Slightly smaller font for compactness */
        }
        .table thead th {
            background: rgb(13 110 253);
            color: #fff;
            border: none;
            padding: 8px; /* Reduced padding */
        }
        .table tbody td {
            padding: 6px; /* Reduced padding for tighter rows */
        }
        .table tbody tr:hover {
            background-color: #f1f3f5;
        }
        .input-group-sm .form-control {
            padding: 4px 8px; /* Smaller input padding */
        }
        .btn-group .btn {
            margin: 0; /* No margin between buttons */
        }
    </style>
</head>
<body>
 <%@ include file="admin_header.jsp" %>
    <div class="containerr mt-5">
        <h2 class="text-center main-header"><i class="bi bi-wallet"></i>Admin Payment Management</h2>

        <!-- Pincode Filter Form -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-geo-alt"></i>Filter Payments by Pincode</h5>
            </div>
            <div class="card-body">
                <form method="GET" action="admin_payments.jsp">
                    <div class="input-group">
                        <input type="number" class="form-control" name="pincode" placeholder="Enter Pincode" required>
                        <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i>View Payments</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Handle Payment Verification Actions -->
        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String feeIdStr = request.getParameter("feeId");
                String action = request.getParameter("action");
                String remark = request.getParameter("remark");

                if (feeIdStr != null && action != null && remark != null) {
                    int feeId = Integer.parseInt(feeIdStr);
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    try {
                        conn = DBConnection.getConnection();

                        // Get payment details to determine type and provider_id
                        String getPaymentQuery = "SELECT provider_id, amount, type FROM PlatformFees WHERE fee_id = ?";
                        pstmt = conn.prepareStatement(getPaymentQuery);
                        pstmt.setInt(1, feeId);
                        rs = pstmt.executeQuery();
                        int providerId = 0;
                        double amount = 0.0;
                        String paymentType = "";
                        if (rs.next()) {
                            providerId = rs.getInt("provider_id");
                            amount = rs.getDouble("amount");
                            paymentType = rs.getString("type");
                        }
                        rs.close();
                        pstmt.close();

                        if ("valid".equals(action)) {
                            // Mark as Verified
                            String updateQuery = "UPDATE PlatformFees SET verification = 'Verified', remark = ? WHERE fee_id = ?";
                            pstmt = conn.prepareStatement(updateQuery);
                            pstmt.setString(1, remark.isEmpty() ? "Successful Transaction" : remark);
                            pstmt.setInt(2, feeId);
                            pstmt.executeUpdate();
                        } else if ("not_valid".equals(action)) {
                            if ("Promotion".equals(paymentType)) {
                                // For Promotion: Revert to Pending
                                String updateQuery = "UPDATE PlatformFees SET payment_status = 'Pending', verification = 'Verified', remark = ? WHERE fee_id = ?";
                                pstmt = conn.prepareStatement(updateQuery);
                                pstmt.setString(1, remark.isEmpty() ? "Invalid Transaction" : remark);
                                pstmt.setInt(2, feeId);
                                pstmt.executeUpdate();
                            } else if ("Platform".equals(paymentType)) {
                                // For Platform: Add amount back to earnings
                                String updateQuery = "UPDATE PlatformFees SET verification = 'Verified', remark = ? WHERE fee_id = ?";
                                pstmt = conn.prepareStatement(updateQuery);
                                pstmt.setString(1, remark.isEmpty() ? "Invalid Transaction" : remark);
                                pstmt.setInt(2, feeId);
                                pstmt.executeUpdate();

                                String updateEarningsQuery = "UPDATE ServiceProviders SET earnings = earnings + ? WHERE provider_id = ?";
                                pstmt = conn.prepareStatement(updateEarningsQuery);
                                pstmt.setDouble(1, amount);
                                pstmt.setInt(2, providerId);
                                pstmt.executeUpdate();
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error processing action: " + e.getMessage() + "</div>");
                    } finally {
                        if (rs != null) rs.close();
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                }
            }
        %>

        <!-- Payment List -->
        <%
            String pincodeStr = request.getParameter("pincode");
            if (pincodeStr != null) {
                int pincode = Integer.parseInt(pincodeStr);
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                try {
                    conn = DBConnection.getConnection();

                    // Fetch payments for providers in the given pincode
                    String paymentQuery = "SELECT pf.* FROM PlatformFees pf " +
                                         "JOIN ServiceProviders sp ON pf.provider_id = sp.provider_id " +
                                         "WHERE sp.pincode = ? ORDER BY pf.transaction_date DESC";
                    pstmt = conn.prepareStatement(paymentQuery);
                    pstmt.setInt(1, pincode);
                    rs = pstmt.executeQuery();
        %>

        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-receipt"></i>Payments for Pincode: <%= pincode %></h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Fee ID</th>
                                <th>Provider ID</th>
                                <th>Amount</th>
                                <th>Payment Status</th>
                                <th>Due Date</th>
                                <th>Type</th>
                                <th>Transaction Date</th>
                                <th>UPI Transaction ID</th>
                                <th>Verification</th>
                                <th>Remark</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                boolean hasPayments = false;
                                while (rs.next()) {
                                    hasPayments = true;
                                    int feeId = rs.getInt("fee_id");
                            %>
                            <tr>
                                <td><%= feeId %></td>
                                <td><%= rs.getInt("provider_id") %></td>
                                <td>₹<%= String.format("%.2f", rs.getDouble("amount")) %></td>
                                <td><%= rs.getString("payment_status") %></td>
                                <td><%= rs.getDate("due_date") %></td>
                                <td><%= rs.getString("type") != null ? rs.getString("type") : "N/A" %></td>
                                <td><%= rs.getDate("transaction_date") != null ? rs.getDate("transaction_date") : "N/A" %></td>
                                <td><%= rs.getString("upi_transaction_id") != null ? rs.getString("upi_transaction_id") : "N/A" %></td>
                                <td><%= rs.getString("verification") != null ? rs.getString("verification") : "N/A" %></td>
                                <td><%= rs.getString("remark") != null ? rs.getString("remark") : "N/A" %></td>
                                <td>
                                    <form method="POST" class="d-inline">
                                        <input type="hidden" name="feeId" value="<%= feeId %>">
                                        <div class="input-group input-group-sm">
                                            <input type="text" class="form-control" name="remark" placeholder="Remark">
                                            <div class="btn-group">
                                                <button type="submit" name="action" value="valid" class="btn btn-success"><i class="bi bi-check"></i>Valid</button>
                                                <button type="submit" name="action" value="not_valid" class="btn btn-danger"><i class="bi bi-x"></i>Not Valid</button>
                                            </div>
                                        </div>
                                    </form>
                                </td>
                            </tr>
                            <%
                                }
                                if (!hasPayments) {
                            %>
                            <tr>
                                <td colspan="11" class="text-center">No payments found for this pincode.</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <%
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error fetching payments: " + e.getMessage() + "</div>");
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            }
        %>

    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>