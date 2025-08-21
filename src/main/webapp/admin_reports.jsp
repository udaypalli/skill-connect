<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.skillconnect.util.DBConnection, java.time.LocalDate, java.time.temporal.ChronoUnit, java.util.*" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Reports - SkillConnect</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        .date-range-form {
            max-width: 500px;
            margin: 0 auto 20px;
        }
        canvas {
            max-width: 100%;
        }
    </style>
</head>
<body>
    <%@ include file="admin_header.jsp" %>
    <%@ include file="admin_sidebar.jsp" %>

    <div class="containerr mt-5">
        <h2 class="text-center main-header"><i class="bi bi-bar-chart"></i>Admin Reports</h2>

        <!-- Date Range Selector -->
        <form class="date-range-form" method="GET" action="admin_reports.jsp">
            <div class="row g-3 align-items-center">
                <div class="col-md-5">
                    <label for="startDate" class="form-label promo-info"><strong>Start Date:</strong></label>
                    <input type="date" class="form-control" id="startDate" name="startDate" value="<%= request.getParameter("startDate") != null ? request.getParameter("startDate") : "" %>" required onchange="restrictEndDate()">
                </div>
                <div class="col-md-5">
                    <label for="endDate" class="form-label promo-info"><strong>End Date:</strong></label>
                    <input type="date" class="form-control" id="endDate" name="endDate" value="<%= request.getParameter("endDate") != null ? request.getParameter("endDate") : "" %>" required>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100 mt-4"><i class="bi bi-search"></i>Generate</button>
                </div>
            </div>
        </form>

        <!-- Graphs -->
        <%
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");

            if (startDateStr != null && endDateStr != null && !startDateStr.isEmpty() && !endDateStr.isEmpty()) {
                LocalDate startDate = LocalDate.parse(startDateStr);
                LocalDate endDate = LocalDate.parse(endDateStr);
                long daysBetween = ChronoUnit.DAYS.between(startDate, endDate);

                if (daysBetween > 30) {
                    out.println("<div class='alert alert-warning' role='alert'><i class='bi bi-exclamation-triangle'></i> Date range cannot exceed 30 days!</div>");
                } else if (endDate.isBefore(startDate)) {
                    out.println("<div class='alert alert-warning' role='alert'><i class='bi bi-exclamation-triangle'></i> End date cannot be before start date!</div>");
                } else {
                    Connection conn = null;
                    PreparedStatement pstmtRevenue = null;
                    PreparedStatement pstmtBookings = null;
                    ResultSet rsRevenue = null;
                    ResultSet rsBookings = null;

                    try {
                        conn = DBConnection.getConnection();

                        // Revenue Data (Graph 1)
                        String revenueQuery = "SELECT DATE(transaction_date) AS payment_day, SUM(amount) AS total_revenue " +
                                             "FROM PlatformFees " +
                                             "WHERE payment_status = 'Paid' " +
                                             "AND transaction_date BETWEEN ? AND ? " +
                                             "GROUP BY payment_day " +
                                             "ORDER BY payment_day ASC";
                        pstmtRevenue = conn.prepareStatement(revenueQuery);
                        pstmtRevenue.setString(1, startDateStr);
                        pstmtRevenue.setString(2, endDateStr);
                        rsRevenue = pstmtRevenue.executeQuery();

                        List<String> revenueDates = new ArrayList<>();
                        List<Double> revenueAmounts = new ArrayList<>();
                        while (rsRevenue.next()) {
                            revenueDates.add(rsRevenue.getString("payment_day"));
                            revenueAmounts.add(rsRevenue.getDouble("total_revenue"));
                        }

                        // Bookings Data (Graph 2)
                        String bookingsQuery = "SELECT DATE(created_at) AS booking_day, COUNT(*) AS booking_count " +
                                              "FROM Bookings " +
                                              "WHERE created_at BETWEEN ? AND ? " +
                                              "GROUP BY booking_day " +
                                              "ORDER BY booking_day ASC";
                        pstmtBookings = conn.prepareStatement(bookingsQuery);
                        pstmtBookings.setString(1, startDateStr + " 00:00:00");
                        pstmtBookings.setString(2, endDateStr + " 23:59:59");
                        rsBookings = pstmtBookings.executeQuery();

                        List<String> bookingDates = new ArrayList<>();
                        List<Integer> bookingCounts = new ArrayList<>();
                        while (rsBookings.next()) {
                            bookingDates.add(rsBookings.getString("booking_day"));
                            bookingCounts.add(rsBookings.getInt("booking_count"));
                        }

                        // Check if data exists
                        if (revenueDates.isEmpty() && bookingDates.isEmpty()) {
                            out.println("<div class='no-data'><i class='bi bi-info-circle'></i> No data available for the selected date range.</div>");
                        } else {
        %>
                            <!-- Graph 1: Total Revenue -->
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0"><i class="bi bi-currency-rupee"></i>Total Revenue Collected Per Day</h5>
                                </div>
                                <div class="card-body">
                                    <canvas id="revenueChart"></canvas>
                                </div>
                            </div>

                            <!-- Graph 2: Number of Bookings -->
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0"><i class="bi bi-calendar-check"></i>Number of Bookings Per Day</h5>
                                </div>
                                <div class="card-body">
                                    <canvas id="bookingsChart"></canvas>
                                </div>
                            </div>

                            <!-- Chart.js Script -->
                            <script>
                                // Revenue Chart
                                const revenueCtx = document.getElementById('revenueChart').getContext('2d');
                                new Chart(revenueCtx, {
                                    type: 'line',
                                    data: {
                                        labels: <%= "[" + revenueDates.stream().map(date -> "\"" + date + "\"").collect(Collectors.joining(",")) + "]" %>,
                                        datasets: [{
                                            label: 'Total Revenue (₹)',
                                            data: <%= "[" + revenueAmounts.stream().map(String::valueOf).collect(Collectors.joining(",")) + "]" %>,
                                            borderColor: 'rgb(13, 110, 253)',
                                            backgroundColor: 'rgba(13, 110, 253, 0.2)',
                                            fill: true,
                                            tension: 0.1
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        scales: {
                                            y: { beginAtZero: true }
                                        }
                                    }
                                });

                                // Bookings Chart
                                const bookingsCtx = document.getElementById('bookingsChart').getContext('2d');
                                new Chart(bookingsCtx, {
                                    type: 'bar',
                                    data: {
                                        labels: <%= "[" + bookingDates.stream().map(date -> "\"" + date + "\"").collect(Collectors.joining(",")) + "]" %>,
                                        datasets: [{
                                            label: 'Number of Bookings',
                                            data: <%= "[" + bookingCounts.stream().map(String::valueOf).collect(Collectors.joining(",")) + "]" %>,
                                            backgroundColor: 'rgb(13, 110, 253)',
                                            borderColor: 'rgb(13, 110, 253)',
                                            borderWidth: 1
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        scales: {
                                            y: { beginAtZero: true }
                                        }
                                    }
                                });

                                // Restrict end date to 30 days from start date
                                function restrictEndDate() {
                                    const startDate = new Date(document.getElementById('startDate').value);
                                    const maxEndDate = new Date(startDate);
                                    maxEndDate.setDate(startDate.getDate() + 30);
                                    document.getElementById('endDate').setAttribute('min', startDate.toISOString().split('T')[0]);
                                    document.getElementById('endDate').setAttribute('max', maxEndDate.toISOString().split('T')[0]);
                                }
                            </script>
        <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<div class='alert alert-danger' role='alert'><i class='bi bi-exclamation-circle'></i> Error generating reports: " + e.getMessage() + "</div>");
                    } finally {
                        if (rsRevenue != null) rsRevenue.close();
                        if (rsBookings != null) rsBookings.close();
                        if (pstmtRevenue != null) pstmtRevenue.close();
                        if (pstmtBookings != null) pstmtBookings.close();
                        if (conn != null) conn.close();
                    }
                }
            } else {
                out.println("<div class='alert alert-warning' role='alert'><i class='bi bi-exclamation-triangle'></i> Please select a date range to generate reports.</div>");
            }
        %>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
   
</body>
</html>