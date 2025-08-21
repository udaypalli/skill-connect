<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException, com.skillconnect.util.DBConnection, java.util.ArrayList, java.util.List, java.util.HashMap, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Business Insights - SkillConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .service-card {
            cursor: pointer;
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 10px;
            margin: 5px;
            text-align: center;
            width: 150px;
            height: 100px;
            display: inline-block;
        }
        .service-card.selected {
            background-color: #ff6600;
            color: white;
        }
        .chart-container {
            width: 100%;
            max-width: 800px;
            margin: 20px auto;
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <div class="row">
            <div class="col-md-12">
                <h2 class="text-center mb-4">
                    <i class="bi bi-bar-chart-line"></i> Business Insights
                </h2>

                <%
                    String userEmail = (String) session.getAttribute("userEmail");
                    int providerId = 0;
                    List<String> services = new ArrayList<>();
                    List<Integer> serviceIds = new ArrayList<>();
                    String selectedServices = "";

                    // Data for graphs
                    Map<String, Double> dailyEarnings = new HashMap<>();
                    Map<String, int[]> bookingStatusCounts = new HashMap<>();

                    if (userEmail != null) {
                        try (Connection conn = DBConnection.getConnection()) {
                            // Fetch provider ID and expertise
                            String providerSql = "SELECT provider_id, expertise FROM ServiceProviders WHERE email = ?";
                            try (PreparedStatement providerStmt = conn.prepareStatement(providerSql)) {
                                providerStmt.setString(1, userEmail);
                                ResultSet providerRs = providerStmt.executeQuery();
                                if (providerRs.next()) {
                                    providerId = providerRs.getInt("provider_id");
                                    String expertise = providerRs.getString("expertise");

                                    // Fetch category ID using expertise
                                    String categorySql = "SELECT category_id FROM Categories WHERE category_name = ?";
                                    try (PreparedStatement categoryStmt = conn.prepareStatement(categorySql)) {
                                        categoryStmt.setString(1, expertise);
                                        ResultSet categoryRs = categoryStmt.executeQuery();
                                        if (categoryRs.next()) {
                                            int categoryId = categoryRs.getInt("category_id");

                                            // Fetch services under the category
                                            String serviceSql = "SELECT service_id, service_name FROM Services WHERE category_id = ?";
                                            try (PreparedStatement serviceStmt = conn.prepareStatement(serviceSql)) {
                                                serviceStmt.setInt(1, categoryId);
                                                ResultSet serviceRs = serviceStmt.executeQuery();
                                                while (serviceRs.next()) {
                                                    services.add(serviceRs.getString("service_name"));
                                                    serviceIds.add(serviceRs.getInt("service_id"));
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Fetch daily earnings for the current month
                            String earningsSql = "SELECT DATE(booking_time) AS booking_date, SUM(total_cost) AS daily_earnings " +
                                                "FROM Bookings WHERE provider_id = ? AND MONTH(booking_time) = MONTH(CURRENT_DATE()) " +
                                                "GROUP BY DATE(booking_time)";
                            try (PreparedStatement earningsStmt = conn.prepareStatement(earningsSql)) {
                                earningsStmt.setInt(1, providerId);
                                ResultSet earningsRs = earningsStmt.executeQuery();
                                while (earningsRs.next()) {
                                    dailyEarnings.put(earningsRs.getString("booking_date"), earningsRs.getDouble("daily_earnings"));
                                }
                            }

                            // Fetch booking status counts (completed, pending, canceled)
                            String statusSql = "SELECT status, COUNT(*) AS count FROM Bookings WHERE provider_id = ? GROUP BY status";
                            try (PreparedStatement statusStmt = conn.prepareStatement(statusSql)) {
                                statusStmt.setInt(1, providerId);
                                ResultSet statusRs = statusStmt.executeQuery();
                                while (statusRs.next()) {
                                    String status = statusRs.getString("status");
                                    int count = statusRs.getInt("count");
                                    bookingStatusCounts.put(status, new int[]{count});
                                }
                            }

                            // Handle form submission to update selected services
                            if ("POST".equalsIgnoreCase(request.getMethod())) {
                                String[] selectedServiceIds = request.getParameterValues("services");
                                if (selectedServiceIds != null && selectedServiceIds.length > 0) {
                                    selectedServices = String.join(",", selectedServiceIds);

                                    // Update the services in the database
                                    String updateSql = "UPDATE ServiceProviders SET services = ? WHERE provider_id = ?";
                                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                                        updateStmt.setString(1, selectedServices);
                                        updateStmt.setInt(2, providerId);
                                        updateStmt.executeUpdate();
                                        out.println("<div class='alert alert-success'>Services updated successfully!</div>");
                                    }
                                } else {
                                    out.println("<div class='alert alert-warning'>No services selected.</div>");
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                            out.println("<div class='alert alert-danger'>Error updating services.</div>");
                        }
                    }
                %>

                <!-- Services Section -->
                <div class="mb-4">
                    <h4><i class="bi bi-list-task"></i> Your Services</h4>
                    <form method="POST" action="">
                        <div class="d-flex flex-wrap">
                            <% for (int i = 0; i < services.size(); i++) { %>
                                <div class="service-card">
                                    <input type="checkbox" name="services" value="<%= serviceIds.get(i) %>" id="service<%= serviceIds.get(i) %>"
                                           <%= selectedServices.contains(serviceIds.get(i).toString()) ? "checked" : "" %>>
                                    <label for="service<%= serviceIds.get(i) %>" class="card-title"><%= services.get(i) %></label>
                                </div>
                            <% } %>
                        </div>
                        <button type="submit" class="btn btn-primary mt-3">Update Selected Services</button>
                    </form>
                </div>

                <!-- Graphs Section -->
                <div class="insights-section">
                    <h4><i class="bi bi-graph-up"></i> Business Insights</h4>
                    <div class="chart-container">
                        <h5>Daily Earnings for Current Month</h5>
                        <canvas id="dailyEarningsChart"></canvas>
                    </div>
                    <div class="chart-container">
                        <h5>Booking Status</h5>
                        <canvas id="bookingStatusChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Pass server-side data to JavaScript
       const dailyEarnings = {
    labels: <%= dailyEarnings.keySet().toString().replace("[", "['").replace("]", "']").replace(", ", "', '") %>,
    data: <%= dailyEarnings.values().toString().replace("[", "[").replace("]", "]") %>
};

const bookingStatus = {
    labels: <%= bookingStatusCounts.keySet().toString().replace("[", "['").replace("]", "']").replace(", ", "', '") %>,
    data: <%= bookingStatusCounts.values().stream().map(arr -> arr[0]).toList().toString() %>
};


        // Daily Earnings Chart
        const dailyEarningsCtx = document.getElementById('dailyEarningsChart').getContext('2d');
        new Chart(dailyEarningsCtx, {
            type: 'bar',
            data: {
                labels: dailyEarnings.labels,
                datasets: [{
                    label: 'Daily Earnings',
                    data: dailyEarnings.data,
                    backgroundColor: '#ff6600',
                }]
            },
            options: {
                scales: {
                    y: { beginAtZero: true }
                }
            }
        });

        // Booking Status Chart
        const bookingStatusCtx = document.getElementById('bookingStatusChart').getContext('2d');
        new Chart(bookingStatusCtx, {
            type: 'bar',
            data: {
                labels: bookingStatus.labels,
                datasets: [{
                    label: 'Bookings',
                    data: bookingStatus.data,
                    backgroundColor: ['#28a745', '#ffc107', '#dc3545'], // Green, Yellow, Red
                }]
            },
            options: {
                scales: {
                    y: { beginAtZero: true }
                }
            }
        });
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>