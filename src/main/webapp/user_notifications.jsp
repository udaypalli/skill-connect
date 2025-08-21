<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%
  // Database connection
  Connection conn = DBConnection.getConnection(); // Assuming DBConnection is a class with a static getConnection() method

  // Get user email from session
  String userEmail = (String) session.getAttribute("userEmail");

  // Convert email to user ID
  int userId = -1;
  if (userEmail != null) {
    String query = "SELECT user_id FROM Users WHERE email = ?";
    try (PreparedStatement pstmt = conn.prepareStatement(query)) {
      pstmt.setString(1, userEmail);
      ResultSet rs = pstmt.executeQuery();
      if (rs.next()) {
        userId = rs.getInt("user_id");
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }

  // Handle delete actions
  if (request.getMethod().equalsIgnoreCase("POST")) {
    String action = request.getParameter("action");

    if (action != null) {
      if (action.equals("deleteAll")) {
        // Delete all notifications for the user
        String deleteAllQuery = "DELETE FROM Notifications WHERE user_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(deleteAllQuery)) {
          pstmt.setInt(1, userId);
          pstmt.executeUpdate();
          request.setAttribute("successMessage", "All notifications deleted successfully!");
        } catch (SQLException e) {
          e.printStackTrace();
          request.setAttribute("errorMessage", "Error deleting notifications: " + e.getMessage());
        }
      } else if (action.equals("deleteRange")) {
        // Delete notifications within a custom date range
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        if (startDate != null && endDate != null) {
          String deleteRangeQuery = "DELETE FROM Notifications WHERE user_id = ? AND created_at BETWEEN ? AND ?";
          try (PreparedStatement pstmt = conn.prepareStatement(deleteRangeQuery)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, startDate);
            pstmt.setString(3, endDate);
            pstmt.executeUpdate();
            request.setAttribute("successMessage", "Notifications deleted for the selected range!");
          } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error deleting notifications: " + e.getMessage());
          }
        } else {
          request.setAttribute("errorMessage", "Please select a valid date range.");
        }
      }
    }
  }

  // Fetch notifications for the user (excluding booking-related messages)
  List<Map<String, String>> notifications = new ArrayList<>();
  if (userId != -1) {
    String notificationQuery = "SELECT notification_id, message, created_at FROM Notifications WHERE user_id = ? AND message NOT LIKE ? AND message NOT LIKE ? ORDER BY created_at DESC";
    try (PreparedStatement pstmt = conn.prepareStatement(notificationQuery)) {
      pstmt.setInt(1, userId);
      pstmt.setString(2, "%You have a new booking request. Please check your bookings.%");
      pstmt.setString(3, "%Your booking has been cancelled. Please check your bookings.%");
      ResultSet rs = pstmt.executeQuery();
      while (rs.next()) {
        Map<String, String> notification = new HashMap<>();
        notification.put("notification_id", rs.getString("notification_id"));
        notification.put("message", rs.getString("message"));
        notification.put("created_at", rs.getString("created_at"));
        notifications.add(notification);
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Notifications - SkillConnect</title>
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Font Awesome for Icons -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <!-- Flatpickr for Date Picker -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
  <style>
    body { background-color: #f8f9fa; }
    .card { border: none; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); }
    .btn-primary { background-color: #ff7700; border: none; } /* Orange Buttons */
    .btn-primary:hover { background-color: #e66000; }
    .btn-danger { background-color: #ff7700; border: none; } /* Orange Buttons */
    .btn-danger:hover { background-color: #e66000; }
    .btn-warning { background-color: #ff7700; border: none; } /* Orange Buttons */
    .btn-warning:hover { background-color: #e66000; }
    .notification-card { border: 1px solid #ddd; border-radius: 8px; padding: 16px; margin-bottom: 16px; }
    .notification-card:hover { box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); }
    .notification-time { font-size: 0.9rem; color: #666; }
    .delete-options { margin-bottom: 20px; }
    .date-range-picker { display: flex; gap: 10px; align-items: center; }
    .date-range-picker input { flex: 1; }
    .icon { color: #ff7700; margin-right: 5px; } /* Orange Icons */
  </style>
</head>
<body>
  <jsp:include page="user_header.jsp" />
  <div class="container mt-5">
    <div class="card p-4">
      <h3 class="text-center text-primary"><i class="fas fa-bell icon"></i>Notifications</h3>

      <!-- Error/Success Messages -->
      <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="alert alert-danger error-alert" role="alert">
          <i class="fas fa-exclamation-circle icon"></i><%= request.getAttribute("errorMessage") %>
        </div>
      <% } %>
      <% if (request.getAttribute("successMessage") != null) { %>
        <div class="alert alert-success error-alert" role="alert">
          <i class="fas fa-check-circle icon"></i><%= request.getAttribute("successMessage") %>
        </div>
      <% } %>

      <!-- Delete Options -->
      <div class="delete-options">
        <form method="POST" class="mb-3">
          <button type="submit" name="action" value="deleteAll" class="btn btn-danger">
            <i class="fas fa-trash icon"></i>Delete All Notifications
          </button>
        </form>
        <form method="POST" class="date-range-picker">
          <input type="text" id="startDate" name="startDate" placeholder="Start Date" class="form-control" required>
          <input type="text" id="endDate" name="endDate" placeholder="End Date" class="form-control" required>
          <button type="submit" name="action" value="deleteRange" class="btn btn-warning">
            <i class="fas fa-calendar-times icon"></i>Delete Custom Range
          </button>
        </form>
      </div>

      <!-- Notifications List -->
      <div class="notifications-list">
        <% if (notifications.isEmpty()) { %>
          <div class="alert alert-info" role="alert">
            <i class="fas fa-info-circle icon"></i>No notifications found.
          </div>
        <% } else { %>
          <% for (Map<String, String> notification : notifications) { %>
            <div class="notification-card">
              <p><i class="fas fa-envelope icon"></i><%= notification.get("message") %></p>
              <p class="notification-time">
                <i class="fas fa-clock icon"></i><%= notification.get("created_at") %>
              </p>
            </div>
          <% } %>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Bootstrap JS and dependencies -->
  <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.min.js"></script>
  <!-- Flatpickr for Date Picker -->
  <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
  <script>
    // Initialize Flatpickr for date range picker
    flatpickr("#startDate", {
      dateFormat: "Y-m-d",
      placeholder: "Start Date",
    });

    flatpickr("#endDate", {
      dateFormat: "Y-m-d",
      placeholder: "End Date",
    });
  </script>
  <%@ include file="footer.jsp" %>
</body>
</html>