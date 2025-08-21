<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%
  // Database connection
  Connection conn = DBConnection.getConnection(); // Assuming DBConnection is a class with a static getConnection() method

  // Get provider email from session
  String providerEmail = (String) session.getAttribute("userEmail");

  // Convert email to provider ID
  int providerId = -1;
  if (providerEmail != null) {
    String query = "SELECT provider_id FROM ServiceProviders WHERE email = ?";
    try (PreparedStatement pstmt = conn.prepareStatement(query)) {
      pstmt.setString(1, providerEmail);
      ResultSet rs = pstmt.executeQuery();
      if (rs.next()) {
        providerId = rs.getInt("provider_id");
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }

  // Handle booking actions (accept/reject/cancel/complete)
  if (request.getMethod().equalsIgnoreCase("POST") && request.getParameter("action") != null) {
    String action = request.getParameter("action");
    int bookingId = Integer.parseInt(request.getParameter("bookingId"));
    String updateQuery = "";

    if (action.equals("accept")) {
      updateQuery = "UPDATE Bookings SET status = 'Accepted' WHERE booking_id = ?";
    } else if (action.equals("reject")) {
      updateQuery = "UPDATE Bookings SET status = 'Rejected' WHERE booking_id = ?";
    } else if (action.equals("cancel")) {
      updateQuery = "UPDATE Bookings SET status = 'Cancelled' WHERE booking_id = ?";
    } else if (action.equals("complete")) {
     // updateQuery = "UPDATE Bookings SET status = 'Completed' WHERE booking_id = ?";
    	updateQuery = "UPDATE Bookings AS B " +
                "JOIN ServiceProviders AS S ON B.provider_id = S.provider_id " +
                "SET B.status = 'Completed', " +
                "S.earnings = S.earnings + 50 " +
                "WHERE B.booking_id = ?;";

    }

    try (PreparedStatement pstmt = conn.prepareStatement(updateQuery)) {
      pstmt.setInt(1, bookingId);
      pstmt.executeUpdate();

      // Insert notification into the Notifications table
      String notificationMessage = "";
      if (action.equals("accept")) {
        notificationMessage = "Your booking has been accepted by the service provider.";
      } else if (action.equals("reject")) {
        notificationMessage = "Your booking has been rejected by the service provider.";
      } else if (action.equals("cancel")) {
        notificationMessage = "Your booking has been cancelled by the service provider.";
      } else if (action.equals("complete")) {
        notificationMessage = "Your booking has been marked as completed by the service provider.";
      }

      String insertNotificationQuery = "INSERT INTO Notifications (user_id, provider_id, message) " +
                                      "SELECT user_id, provider_id, ? FROM Bookings WHERE booking_id = ?";
      try (PreparedStatement pstmtNotification = conn.prepareStatement(insertNotificationQuery)) {
        pstmtNotification.setString(1, notificationMessage);
        pstmtNotification.setInt(2, bookingId);
        pstmtNotification.executeUpdate();
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }

//Fetch bookings for the service provider
List<Map<String, String>> pendingBookings = new ArrayList<>();
List<Map<String, String>> completedBookings = new ArrayList<>();
Set<String> seenBookingIds = new HashSet<>(); // Set to track unique booking IDs

if (providerId != -1) {
   String bookingQuery = "SELECT b.booking_id, b.booking_time, b.status, b.total_cost, " +
                         "s.service_name, u.name AS user_name, l.address AS user_location " +
                         "FROM Bookings b " +
                         "JOIN Services s ON b.service_id = s.service_id " +
                         "JOIN Users u ON b.user_id = u.user_id " +
                         "LEFT JOIN Locations l ON u.user_id = l.user_id " +
                         "WHERE b.provider_id = ?";

   try (PreparedStatement pstmt = conn.prepareStatement(bookingQuery)) {
       pstmt.setInt(1, providerId);
       ResultSet rs = pstmt.executeQuery();

       while (rs.next()) {
           String bookingId = rs.getString("booking_id");

           // Check if the booking ID is already processed
           if (!seenBookingIds.contains(bookingId)) {
               seenBookingIds.add(bookingId); // Mark as processed
               
               Map<String, String> booking = new HashMap<>();
               booking.put("booking_id", bookingId);
               booking.put("booking_time", rs.getString("booking_time"));
               booking.put("status", rs.getString("status"));
               booking.put("service_name", rs.getString("service_name"));
               booking.put("user_name", rs.getString("user_name"));
               booking.put("user_location", rs.getString("user_location"));
               booking.put("total_cost", rs.getString("total_cost"));

               // Categorize bookings based on status
               if ("Pending".equalsIgnoreCase(rs.getString("status"))) {
                   pendingBookings.add(booking);
               } else {
                   completedBookings.add(booking);
               }
           }
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
  <title>Service Provider Bookings</title>
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Font Awesome for Icons -->
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <style>
    .booking-container {
      border: 2px solid #ddd;
      border-radius: 10px;
      padding: 20px;
      margin: 20px auto;
      max-width: 1000px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    .booking-card {
      border: 1px solid #ddd;
      border-radius: 10px;
      padding: 20px;
      margin: 10px 0;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    .badge {
      font-size: 14px;
      padding: 8px 12px;
    }
    .badge-pending {
      background-color: #ffc107;
    }
    .badge-accepted {
      background-color: #28a745;
    }
    .badge-rejected {
      background-color: #dc3545;
    }
    .badge-completed {
      background-color: #17a2b8;
    }
    .badge-cancelled {
      background-color: #6c757d;
    }
    .icon {
      font-size: 24px;
      margin-right: 10px;
      color: #1a73e8; /* Naukri blue */
    }
    .btn-success {
      background-color: #28a745; /* Green for accept */
      border: none;
    }
    .btn-danger {
      background-color: #dc3545; /* Red for reject */
      border: none;
    }
    .btn-warning {
      background-color: #ffc107; /* Yellow for cancel */
      border: none;
    }
    .btn-info {
      background-color: #17a2b8; /* Blue for complete */
      border: none;
    }
    .btn-success:hover, .btn-danger:hover, .btn-warning:hover, .btn-info:hover {
      opacity: 0.9;
    }
  </style>
</head>
<body>
<jsp:include page="service_provider_header.jsp" />
  <div class="container mt-5">
    <h1 class="text-center mb-4">Your Bookings</h1>

    <!-- Toggle Switch for Pending/Completed -->
    <div class="toggle-switch text-center mb-4">
      <button id="pendingBtn" class="btn btn-warning active">Pending</button>
      <button id="completedBtn" class="btn btn-success">Completed</button>
    </div>

    <!-- Big Container for Bookings -->
    <div class="booking-container">
      <!-- Pending Bookings Section -->
      <div id="pendingBookings">
        <h3 class="text-center mb-4"><i class="fas fa-hourglass-half icon"></i> Pending Bookings</h3>
        <% for (Map<String, String> booking : pendingBookings) { %>
          <div class="booking-card">
            <div class="row">
              <!-- Left Column -->
              <div class="col-md-6">
                <h5><i class="fas fa-calendar-alt icon"></i> Booking ID: <strong>#<%= booking.get("booking_id") %></strong></h5>
                <p><i class="fas fa-tools icon"></i> <strong>Service:</strong> <%= booking.get("service_name") %></p>
                <p><i class="fas fa-user icon"></i> <strong>User:</strong> <%= booking.get("user_name") %></p>
                <p><i class="fas fa-map-marker-alt icon"></i> <strong>Location:</strong> <%= booking.get("user_location") %></p>
              </div>
              <!-- Right Column -->
              <div class="col-md-6">
                <p><i class="fas fa-clock icon"></i> <strong>Booking Time:</strong> <%= booking.get("booking_time") %></p>
                <p><i class="fas fa-money-bill-wave icon"></i> <strong>Total Cost:</strong> $<%= booking.get("total_cost") %></p>
                <p><strong>Status:</strong> <span class="badge badge-pending"><%= booking.get("status") %></span></p>
              </div>
            </div>
            <!-- Buttons at the Bottom -->
            <div class="text-end mt-3">
              <form method="POST" style="display: inline;">
                <input type="hidden" name="action" value="accept">
                <input type="hidden" name="bookingId" value="<%= booking.get("booking_id") %>">
                <button type="submit" class="btn btn-success btn-sm">
                  <i class="fas fa-check-circle"></i> Accept
                </button>
              </form>
              <form method="POST" style="display: inline; margin-left: 10px;">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="bookingId" value="<%= booking.get("booking_id") %>">
                <button type="submit" class="btn btn-danger btn-sm">
                  <i class="fas fa-times-circle"></i> Reject
                </button>
              </form>
            </div>
          </div>
        <% } %>
      </div>

      <!-- Completed Bookings Section -->
      <div id="completedBookings" style="display: none;">
        <h3 class="text-center mb-4"><i class="fas fa-check-circle icon"></i> Completed Bookings</h3>
        <% for (Map<String, String> booking : completedBookings) { %>
          <div class="booking-card">
            <div class="row">
              <!-- Left Column -->
              <div class="col-md-6">
                <h5><i class="fas fa-calendar-alt icon"></i> Booking ID: <strong>#<%= booking.get("booking_id") %></strong></h5>
                <p><i class="fas fa-tools icon"></i> <strong>Service:</strong> <%= booking.get("service_name") %></p>
                <p><i class="fas fa-user icon"></i> <strong>User:</strong> <%= booking.get("user_name") %></p>
                <p><i class="fas fa-map-marker-alt icon"></i> <strong>Location:</strong> <%= booking.get("user_location") %></p>
              </div>
              <!-- Right Column -->
              <div class="col-md-6">
                <p><i class="fas fa-clock icon"></i> <strong>Booking Time:</strong> <%= booking.get("booking_time") %></p>
                <p><i class="fas fa-money-bill-wave icon"></i> <strong>Total Cost:</strong> $<%= booking.get("total_cost") %></p>
                <p><strong>Status:</strong> 
                  <span class="badge <%= booking.get("status").equalsIgnoreCase("Accepted") ? "badge-accepted" : 
                                        booking.get("status").equalsIgnoreCase("Completed") ? "badge-completed" : 
                                        booking.get("status").equalsIgnoreCase("Cancelled") ? "badge-cancelled" : "badge-rejected" %>">
                    <%= booking.get("status") %>
                  </span>
                </p>
              </div>
            </div>
            <!-- Buttons at the Bottom -->
            <div class="text-end mt-3">
              <% if (booking.get("status").equalsIgnoreCase("Accepted")) { %>
                <form method="POST" style="display: inline;">
                  <input type="hidden" name="action" value="complete">
                  <input type="hidden" name="bookingId" value="<%= booking.get("booking_id") %>">
                  <button type="submit" class="btn btn-info btn-sm">
                    <i class="fas fa-check-double"></i> Mark as Completed
                  </button>
                </form>
              <% } %>
              <form method="POST" style="display: inline; margin-left: 10px;">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" name="bookingId" value="<%= booking.get("booking_id") %>">
                <button type="submit" class="btn btn-warning btn-sm">
                  <i class="fas fa-ban"></i> Cancel
                </button>
              </form>
            </div>
          </div>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Bootstrap JS and dependencies -->
  <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.min.js"></script>
  <script>
    // Toggle between Pending and Completed Bookings
    document.getElementById('pendingBtn').addEventListener('click', function() {
      document.getElementById('pendingBookings').style.display = 'block';
      document.getElementById('completedBookings').style.display = 'none';
      this.classList.add('active');
      document.getElementById('completedBtn').classList.remove('active');
    });

    document.getElementById('completedBtn').addEventListener('click', function() {
      document.getElementById('pendingBookings').style.display = 'none';
      document.getElementById('completedBookings').style.display = 'block';
      this.classList.add('active');
      document.getElementById('pendingBtn').classList.remove('active');
    });
  </script>
  <jsp:include page="footer.jsp" />
</body>
</html>