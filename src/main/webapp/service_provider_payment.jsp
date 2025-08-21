<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.skillconnect.util.DBConnection, java.time.LocalDate" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Provider - Payments - SkillConnect</title>
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
        .bi {
            margin-right: 5px;
            color: #ff6f00; /* Orange accent */
        }
        .alert {
            border-radius: 8px;
        }
        .instructions {
            background: #fff;
            padding: 15px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
        }
        .modal-content {
            border-radius: 12px;
        }
        .modal-header {
            background: rgb(13 110 253);
            color: #fff;
            border-radius: 12px 12px 0 0;
        }
        .modal-body {
            text-align: center;
        }
        .upi-link {
            font-size: 16px;
            color: rgb(13 110 253);
            text-decoration: underline;
            word-wrap: break-word;
        }
        .upi-link:hover {
            color: #0b5ed7;
        }
    </style>
</head>
<body>
<jsp:include page="service_provider_header.jsp" />
    <div class="containerr mt-5">
        <h2 class="text-center main-header"><i class="bi bi-wallet"></i>Payment Management</h2>

        <!-- Instructions -->
        <div class="instructions">
            <h5><i class="bi bi-info-circle"></i>Important Instructions</h5>
            <ol class="promo-info">
                <li>Pay platform fees in the 1st week of every month to avoid suspension.</li>
                <li>Pay and enter UPI transaction ID, and we will verify it. Please wait and check transaction history periodically.</li>
                <li>Platform fees and promotions fees can be paid any time.</li>
            </ol>
        </div>

        <!-- Handle Form Submission -->
        <%
            String successMessage = null;
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String providerIdStr = request.getParameter("providerId");
                String upiTransactionId = request.getParameter("upiTransactionId");
                String paymentType = request.getParameter("paymentType");
                double amount = Double.parseDouble(request.getParameter("amount"));

                if (providerIdStr != null && upiTransactionId != null && paymentType != null) {
                    int providerId = Integer.parseInt(providerIdStr);
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    try {
                        conn = DBConnection.getConnection();

                        if ("Platform".equals(paymentType)) {
                            // Insert new entry for Platform Fees with verification 'Not'
                            String insertQuery = "INSERT INTO PlatformFees (provider_id, amount, payment_status, due_date, type, transaction_date, upi_transaction_id, verification) " +
                                                 "VALUES (?, ?, 'Paid', DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Platform', CURDATE(), ?, 'Not')";
                            pstmt = conn.prepareStatement(insertQuery);
                            pstmt.setInt(1, providerId);
                            pstmt.setDouble(2, amount);
                            pstmt.setString(3, upiTransactionId);
                            pstmt.executeUpdate();

                            // Reset earnings to 0 in ServiceProviders
                            String updateEarningsQuery = "UPDATE ServiceProviders SET earnings = 0 WHERE provider_id = ?";
                            pstmt = conn.prepareStatement(updateEarningsQuery);
                            pstmt.setInt(1, providerId);
                            pstmt.executeUpdate();
                        } else if ("Promotion".equals(paymentType)) {
                            // Update existing Promotion Fees to Paid with verification 'Not'
                            String updateQuery = "UPDATE PlatformFees SET payment_status = 'Paid', upi_transaction_id = ?, transaction_date = CURDATE(), verification = 'Not' " +
                                                 "WHERE provider_id = ? AND type = 'Promotion' AND payment_status = 'Pending'";
                            pstmt = conn.prepareStatement(updateQuery);
                            pstmt.setString(1, upiTransactionId);
                            pstmt.setInt(2, providerId);
                            pstmt.executeUpdate();
                        }

                        successMessage = "Your payment has been done successfully. Please wait until admins verify it. To check remarks, please visit Transaction History.";
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error processing payment: " + e.getMessage() + "</div>");
                    } finally {
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                }
            }
        %>

        <!-- Success Popup Modal -->
        <% if (successMessage != null) { %>
            <div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="successModalLabel"><i class="bi bi-check-circle"></i> Payment Submitted</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <p class="promo-info"><%= successMessage %></p>
                        </div>
                    </div>
                </div>
            </div>
            <script>
                document.addEventListener('DOMContentLoaded', function () {
                    var successModal = new bootstrap.Modal(document.getElementById('successModal'));
                    successModal.show();
                    document.querySelector('#successModal .btn-close').addEventListener('click', function () {
                    	window.location.href = window.location.pathname;
                    });
                });
            </script>
        <% } %>

        <!-- Payment Columns -->
        <div class="row">
            <%
                String userEmail = (String) session.getAttribute("userEmail");
                if (userEmail == null) {
                    out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Please log in to view payment details.</div>");
                } else {
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    try {
                        conn = DBConnection.getConnection();

                        // Get Provider ID and Earnings
                        String providerQuery = "SELECT provider_id, earnings FROM ServiceProviders WHERE email = ?";
                        pstmt = conn.prepareStatement(providerQuery);
                        pstmt.setString(1, userEmail);
                        rs = pstmt.executeQuery();
                        int providerId = 0;
                        double earnings = 0.0;
                        if (rs.next()) {
                            providerId = rs.getInt("provider_id");
                            earnings = rs.getDouble("earnings");
                        }
                        rs.close();
                        pstmt.close();

                        // Platform Fees Due (set as earnings directly)
                        double platformFeeDue = earnings;

                        // Promotion Fees Due
                        String promoFeeQuery = "SELECT SUM(amount) AS promo_fee_due " +
                                              "FROM PlatformFees " +
                                              "WHERE provider_id = ? " +
                                              "AND type = 'Promotion' " +
                                              "AND payment_status = 'Pending'";
                        pstmt = conn.prepareStatement(promoFeeQuery);
                        pstmt.setInt(1, providerId);
                        rs = pstmt.executeQuery();
                        double promoFeeDue = 0.0;
                        if (rs.next()) {
                            promoFeeDue = rs.getDouble("promo_fee_due");
                        }
                        rs.close();
                        pstmt.close();

                        // UPI ID
                        

                        // Generate UPI links in Java
                        String platformUpiLink = "upi://pay?pa=" + upiId + "&am=" + String.format("%.2f", platformFeeDue) + "&cu=INR";
                        String promoUpiLink = "upi://pay?pa=" + upiId + "&am=" + String.format("%.2f", promoFeeDue) + "&cu=INR";
            %>

            <!-- Column 1: Platform Fees -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-currency-rupee"></i>Platform Fees Due</h5>
                    </div>
                    <div class="card-body">
                        <p class="promo-info"><strong>Amount Due:</strong> ₹<%= String.format("%.2f", platformFeeDue) %></p>
                        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#paymentModalPlatform"><i class="bi bi-check2"></i>Pay Now</button>
                        <form method="POST" class="mt-3">
                            <input type="hidden" name="providerId" value="<%= providerId %>">
                            <input type="hidden" name="paymentType" value="Platform">
                            <input type="hidden" name="amount" value="<%= platformFeeDue %>">
                            <div class="input-group">
                                <input type="text" class="form-control" name="upiTransactionId" placeholder="Enter UPI Transaction ID" required>
                                <button type="submit" class="btn btn-primary" <%= platformFeeDue == 0 ? "disabled" : "" %>><i class="bi bi-upload"></i>Submit</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Column 2: Promotion Fees -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-megaphone"></i>Promotion Fees Due</h5>
                    </div>
                    <div class="card-body">
                        <p class="promo-info"><strong>Amount Due:</strong> ₹<%= String.format("%.2f", promoFeeDue) %></p>
                        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#paymentModalPromo"><i class="bi bi-check2"></i>Pay Now</button>
                        <form method="POST" class="mt-3">
                            <input type="hidden" name="providerId" value="<%= providerId %>">
                            <input type="hidden" name="paymentType" value="Promotion">
                            <input type="hidden" name="amount" value="<%= promoFeeDue %>">
                            <div class="input-group">
                                <input type="text" class="form-control" name="upiTransactionId" placeholder="Enter UPI Transaction ID" required>
                                <button type="submit" class="btn btn-primary" <%= promoFeeDue == 0 ? "disabled" : "" %>><i class="bi bi-upload"></i>Submit</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Platform Fees Payment Modal -->
            <div class="modal fade" id="paymentModalPlatform" tabindex="-1" aria-labelledby="paymentModalPlatformLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="paymentModalPlatformLabel"><i class="bi bi-wallet"></i>Make Payment</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <p class="promo-info"><strong>Payment For:</strong> Platform Fees</p>
                            <p class="promo-info"><strong>Amount:</strong> ₹<%= String.format("%.2f", platformFeeDue) %></p>
                             <p class="promo-info"><strong>UPI ID:</strong> </p>
                            <p class="promo-info"><strong>Click to Pay:</strong></p>
                            <a href="<%= platformUpiLink %>" class="upi-link" target="_blank">Pay ₹<%= String.format("%.2f", platformFeeDue) %> via UPI</a>
                            <p class="promo-info">Click the link above to open your UPI app and complete the payment.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Promotion Fees Payment Modal -->
            <div class="modal fade" id="paymentModalPromo" tabindex="-1" aria-labelledby="paymentModalPromoLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="paymentModalPromoLabel"><i class="bi bi-wallet"></i>Make Payment</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <p class="promo-info"><strong>Payment For:</strong> Promotion Fees</p>
                            <p class="promo-info"><strong>Amount:</strong> ₹<%= String.format("%.2f", promoFeeDue) %></p>
                            <p class="promo-info"><strong>Click to Pay:</strong></p>
                            <a href="<%= promoUpiLink %>" class="upi-link" target="_blank">Pay ₹<%= String.format("%.2f", promoFeeDue) %> via UPI</a>
                            <p class="promo-info">Click the link above to open your UPI app and complete the payment.</p>
                        </div>
                    </div>
                </div>
            </div>

            <%
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error fetching payment details: " + e.getMessage() + "</div>");
                    } finally {
                        if (rs != null) rs.close();
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                }
            %>
        </div>

        <!-- Transaction History Button -->
        <div class="text-center mt-4">
            <a href="transaction_history.jsp" class="btn btn-primary"><i class="bi bi-clock-history"></i>Transaction History</a>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
      <%@ include file="footer.jsp" %>
</body>
</html>