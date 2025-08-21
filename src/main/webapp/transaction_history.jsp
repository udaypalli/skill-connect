<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.skillconnect.util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction History - SkillConnect</title>
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
            padding-top: 0; /* Space for header */
            padding-bottom: 0; /* Space for footer */
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
        }
        .table thead th {
            background: rgb(13 110 253);
            color: #fff;
            border: none;
        }
        .table tbody tr:hover {
            background-color: #f1f3f5;
        }
    </style>
</head>
<body>
<jsp:include page="service_provider_header.jsp" />
    <div class="containerr mt-5">
        <h2 class="text-center main-header"><i class="bi bi-clock-history"></i>Transaction History</h2>

        <!-- Transaction History Table -->
        <%
            String userEmail = (String) session.getAttribute("userEmail");
            if (userEmail == null) {
                out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Please log in to view transaction history.</div>");
            } else {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                try {
                    conn = DBConnection.getConnection();

                    // Get Provider ID
                    String providerQuery = "SELECT provider_id FROM ServiceProviders WHERE email = ?";
                    pstmt = conn.prepareStatement(providerQuery);
                    pstmt.setString(1, userEmail);
                    rs = pstmt.executeQuery();
                    int providerId = 0;
                    if (rs.next()) {
                        providerId = rs.getInt("provider_id");
                    }
                    rs.close();
                    pstmt.close();

                    if (providerId == 0) {
                        out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Provider not found.</div>");
                    } else {
                        // Fetch all transactions for the provider, newest first
                        String transactionQuery = "SELECT * FROM PlatformFees WHERE provider_id = ? ORDER BY transaction_date DESC";
                        pstmt = conn.prepareStatement(transactionQuery);
                        pstmt.setInt(1, providerId);
                        rs = pstmt.executeQuery();
        %>

        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-receipt"></i>Your Transactions</h5>
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
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                boolean hasTransactions = false;
                                while (rs.next()) {
                                    hasTransactions = true;
                            %>
                            <tr>
                                <td><%= rs.getInt("fee_id") %></td>
                                <td><%= rs.getInt("provider_id") %></td>
                                <td>₹<%= String.format("%.2f", rs.getDouble("amount")) %></td>
                                <td><%= rs.getString("payment_status") %></td>
                                <td><%= rs.getDate("due_date") %></td>
                                <td><%= rs.getString("type") != null ? rs.getString("type") : "N/A" %></td>
                                <td><%= rs.getDate("transaction_date") != null ? rs.getDate("transaction_date") : "N/A" %></td>
                                <td><%= rs.getString("upi_transaction_id") != null ? rs.getString("upi_transaction_id") : "N/A" %></td>
                                <td><%= rs.getString("verification") != null ? rs.getString("verification") : "N/A" %></td>
                                <td><%= rs.getString("remark") != null ? rs.getString("remark") : "N/A" %></td>
                            </tr>
                            <%
                                }
                                if (!hasTransactions) {
                            %>
                            <tr>
                                <td colspan="10" class="text-center">No transactions found.</td>
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
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error fetching transaction history: " + e.getMessage() + "</div>");
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            }
        %>

        <!-- Back to Payments Button -->
        <div class="text-center mt-4">
            <a href="service_provider_payment.jsp" class="btn btn-primary"><i class="bi bi-arrow-left"></i>Back to Payments</a>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
      <%@ include file="footer.jsp" %>
</body>
</html>