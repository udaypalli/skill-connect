<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.*, java.time.format.DateTimeFormatter" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%@ page import="java.time.LocalDate, java.time.temporal.ChronoUnit" %>

<%
    // Get provider email from session
    String providerEmail = (String) session.getAttribute("userEmail");
    if (providerEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int providerId = 0;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // Today's schedule data
    int todayOrders = 0;
    java.util.List<String[]> todayBookings = new java.util.ArrayList<>();

    // Next 15 days calendar data
    int[] tasksPerDay = new int[15]; // Array to store task counts for each day

    try {
        conn = DBConnection.getConnection();

        // Fetch provider_id from ServiceProviders
        String providerQuery = "SELECT provider_id FROM ServiceProviders WHERE email = ?";
        pstmt = conn.prepareStatement(providerQuery);
        pstmt.setString(1, providerEmail);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            providerId = rs.getInt("provider_id");
        }
        rs.close();
        pstmt.close();

        if (providerId == 0) {
            out.println("<p class='text-danger'>Provider not found.</p>");
            return;
        }

        // Fetch today's bookings
        LocalDate today = LocalDate.now();
        String todayDate = today.format(DateTimeFormatter.ISO_LOCAL_DATE);
        String todayQuery = "SELECT b.booking_id, u.name, s.service_name, b.booking_time " +
                            "FROM Bookings b " +
                            "JOIN Users u ON b.user_id = u.user_id " +
                            "JOIN Services s ON b.service_id = s.service_id " +
                            "WHERE b.provider_id = ? AND DATE(b.booking_time) = ?";
        pstmt = conn.prepareStatement(todayQuery);
        pstmt.setInt(1, providerId);
        pstmt.setString(2, todayDate);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            todayOrders++;
            todayBookings.add(new String[]{
                rs.getString("booking_id"),
                rs.getString("name"),
                rs.getString("service_name"),
                rs.getString("booking_time")
            });
        }
        rs.close();
        pstmt.close();

        // Fetch bookings for the next 15 days
        LocalDate startDate = today;
        String calendarQuery = "SELECT DATE(booking_time) AS booking_date, COUNT(*) AS task_count " +
                              "FROM Bookings " +
                              "WHERE provider_id = ? AND DATE(booking_time) BETWEEN ? AND ? " +
                              "GROUP BY DATE(booking_time)";
        pstmt = conn.prepareStatement(calendarQuery);
        pstmt.setInt(1, providerId);
        pstmt.setString(2, startDate.format(DateTimeFormatter.ISO_LOCAL_DATE));
        pstmt.setString(3, startDate.plusDays(14).format(DateTimeFormatter.ISO_LOCAL_DATE));
        rs = pstmt.executeQuery();

        while (rs.next()) {
            LocalDate bookingDate = LocalDate.parse(rs.getString("booking_date"));
            int daysDifference = (int) ChronoUnit.DAYS.between(startDate, bookingDate);
            if (daysDifference >= 0 && daysDifference < 15) {
                tasksPerDay[daysDifference] = rs.getInt("task_count");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p class='text-danger'>Error fetching dashboard data: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Provider Dashboard | SkillConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Arial', sans-serif;
        }
        .uday-dashboard-container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 20px;
        }
        .uday-card {
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        .uday-card-header {
            background-color: #007bff;
            color: white;
            font-weight: bold;
            border-radius: 12px 12px 0 0;
            padding: 15px;
        }
        .uday-card-body {
            padding: 20px;
        }
        .uday-schedule-table th, .uday-schedule-table td {
            vertical-align: middle;
            padding: 10px;
        }
        .uday-calendar-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr); /* 5 days per row */
            gap: 10px;
        }
        .uday-calendar-day {
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 15px;
            text-align: center;
            transition: all 0.3s ease;
        }
        .uday-calendar-day:hover {
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            transform: scale(1.05);
        }
        .uday-calendar-day .uday-date {
            font-weight: bold;
            color: #333;
        }
        .uday-calendar-day .uday-tasks {
            color: #007bff;
            font-size: 14px;
        }
        .uday-calendar-day.uday-today {
            border: 2px solid #007bff;
            background-color: #e9f5ff;
        }
    </style>
</head>
<body>
<jsp:include page="service_provider_header.jsp" /> <!-- Assuming a header for service providers -->

<div class="uday-dashboard-container">
    <!-- Today's Schedule -->
    <div class="uday-card">
        <div class="uday-card-header">
            <i class="fas fa-calendar-day me-2"></i>Today's Schedule (<%= todayOrders %> Orders)
        </div>
        <div class="uday-card-body">
            <% if (todayOrders == 0) { %>
                <p class="text-muted">No bookings scheduled for today.</p>
            <% } else { %>
                <table class="table uday-schedule-table">
                    <thead>
                        <tr>
                            <th>Booking ID</th>
                            <th>User Name</th>
                            <th>Service</th>
                            <th>Time</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (String[] booking : todayBookings) { %>
                            <tr>
                                <td><%= booking[0] %></td>
                                <td><%= booking[1] %></td>
                                <td><%= booking[2] %></td>
                                <td><%= booking[3] %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>

    <!-- Next 15 Days Calendar -->
    <div class="uday-card">
        <div class="uday-card-header">
            <i class="fas fa-calendar-alt me-2"></i>Next 15 Days Schedule
        </div>
        <div class="uday-card-body">
            <div class="uday-calendar-grid">
                <%
                    LocalDate today = LocalDate.now();
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd");
                    for (int i = 0; i < 15; i++) {
                        LocalDate date = today.plusDays(i);
                        String dayClass = (i == 0) ? "uday-calendar-day uday-today" : "uday-calendar-day";
                %>
                    <div class="<%= dayClass %>">
                        <div class="uday-date"><%= date.format(formatter) %></div>
                        <div class="uday-tasks"><%= tasksPerDay[i] %> Task<%= (tasksPerDay[i] != 1) ? "s" : "" %></div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.min.js"></script>
</body>
</html>