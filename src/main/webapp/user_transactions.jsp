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

  // Handle cancellation request
  if (request.getMethod().equalsIgnoreCase("POST") && request.getParameter("action") != null) {
    String action = request.getParameter("action");
    if (action.equals("cancel")) {
      int bookingId = Integer.parseInt(request.getParameter("bookingId"));
      String updateQuery = "UPDATE Bookings SET status = 'Cancelled' WHERE booking_id = ?";
      try (PreparedStatement pstmt = conn.prepareStatement(updateQuery)) {
        pstmt.setInt(1, bookingId);
        pstmt.executeUpdate();
      } catch (SQLException e) {
        e.printStackTrace();
      }
    }
  }

  // Fetch transactions for the user
  List<Map<String, String>> pendingTransactions = new ArrayList<>();
  List<Map<String, String>> completedTransactions = new ArrayList<>();
  if (userId != -1) {
    String transactionQuery = "SELECT b.booking_id, b.booking_time, b.status, s.service_name, sp.name AS provider_name " +
                             "FROM Bookings b " +
                             "JOIN Services s ON b.service_id = s.service_id " +
                             "JOIN ServiceProviders sp ON b.provider_id = sp.provider_id " +
                             "WHERE b.user_id = ?";
    try (PreparedStatement pstmt = conn.prepareStatement(transactionQuery)) {
      pstmt.setInt(1, userId);
      ResultSet rs = pstmt.executeQuery();
      while (rs.next()) {
        Map<String, String> transaction = new HashMap<>();
        transaction.put("booking_id", rs.getString("booking_id"));
        transaction.put("booking_time", rs.getString("booking_time"));
        transaction.put("status", rs.getString("status"));
        transaction.put("service_name", rs.getString("service_name"));
        transaction.put("provider_name", rs.getString("provider_name"));

        if (rs.getString("status").equalsIgnoreCase("Pending")) {
          pendingTransactions.add(transaction);
        } else {
          completedTransactions.add(transaction);
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
  <title>User Transactions</title>
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Font Awesome for Icons -->
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <style>
    .transaction-container {
      border: 2px solid #ddd;
      border-radius: 10px;
      padding: 20px;
      margin: 20px auto;
      max-width: 1000px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    .transaction-card {
      border: 1px solid #ddd;
      border-radius: 10px;
      padding: 20px;
      margin: 10px 0;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .transaction-card .left-column {
      flex: 1;
      padding-right: 20px;
    }
    .transaction-card .right-column {
      flex: 1;
      text-align: right;
    }
    .toggle-switch {
      display: flex;
      justify-content: center;
      margin-bottom: 20px;
    }
    .toggle-switch .btn {
      margin: 0 10px;
      padding: 10px 20px;
      font-size: 16px;
      background-color: #ff6600; /* Bright orange */
      color: white;
      border: none;
    }
    .toggle-switch .btn.active {
      background-color: #cc5200; /* Darker orange for active state */
    }
    .badge {
      font-size: 14px;
      padding: 8px 12px;
    }
    .badge-pending {
      background-color: #ffc107;
    }
    .badge-completed {
      background-color: #28a745;
    }
    .badge-cancelled {
      background-color: #dc3545;
    }
    .icon {
      font-size: 24px;
      margin-right: 10px;
      color: #1a73e8; /* Naukri blue */
    }
    .btn-danger {
      background-color: #ff6600; /* Bright orange */
      border: none;
    }
    .btn-danger:hover {
      background-color: #cc5200; /* Darker orange on hover */
    }
  </style>
</head>
<body>
<jsp:include page="user_header.jsp" />
  <div class="container mt-5">
    <h1 class="text-center mb-4">Your Transactions</h1>

    <!-- Toggle Switch for Pending/Completed -->
    <div class="toggle-switch">
      <button id="pendingBtn" class="btn btn-warning active">Pending</button>
      <button id="completedBtn" class="btn btn-success">Completed</button>
    </div>

    <!-- Big Container for Transactions -->
    <div class="transaction-container">
      <!-- Pending Transactions Section -->
      <div id="pendingTransactions">
        <h3 class="text-center mb-4"><i class="fas fa-hourglass-half icon"></i> Pending Transactions</h3>
        <% for (Map<String, String> transaction : pendingTransactions) { %>
          <div class="transaction-card">
            <div class="left-column">
              <h5><i class="fas fa-calendar-alt icon"></i> Booking ID: <strong>#<%= transaction.get("booking_id") %></strong></h5>
              <p><i class="fas fa-tools icon"></i> <strong>Service:</strong> <%= transaction.get("service_name") %></p>
              <p><i class="fas fa-user-tie icon"></i> <strong>Provider:</strong> <%= transaction.get("provider_name") %></p>
            </div>
            <div class="right-column">
              <p><i class="fas fa-clock icon"></i> <strong>Booking Time:</strong> <%= transaction.get("booking_time") %></p>
              <p><strong>Status:</strong> <span class="badge badge-pending"><%= transaction.get("status") %></span></p>
              <form method="POST" style="display: inline;">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" name="bookingId" value="<%= transaction.get("booking_id") %>">
                <button type="submit" class="btn btn-danger btn-sm">
                  <i class="fas fa-times-circle"></i> Cancel Order
                </button>
              </form>
            </div>
          </div>
        <% } %>
      </div>

      <!-- Completed Transactions Section -->
      <div id="completedTransactions" style="display: none;">
        <h3 class="text-center mb-4"><i class="fas fa-check-circle icon"></i> Completed Transactions</h3>
        <% for (Map<String, String> transaction : completedTransactions) { %>
          <div class="transaction-card">
            <div class="left-column">
              <h5><i class="fas fa-calendar-alt icon"></i> Booking ID: <strong>#<%= transaction.get("booking_id") %></strong></h5>
              <p><i class="fas fa-tools icon"></i> <strong>Service:</strong> <%= transaction.get("service_name") %></p>
              <p><i class="fas fa-user-tie icon"></i> <strong>Provider:</strong> <%= transaction.get("provider_name") %></p>
            </div>
            <div class="right-column">
              <p><i class="fas fa-clock icon"></i> <strong>Booking Time:</strong> <%= transaction.get("booking_time") %></p>
              <p><strong>Status:</strong> 
                <span class="badge <%= transaction.get("status").equalsIgnoreCase("Completed") ? "badge-completed" : "badge-cancelled" %>">
                  <%= transaction.get("status") %>
                </span>
              </p>
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
    // Toggle between Pending and Completed Transactions
    document.getElementById('pendingBtn').addEventListener('click', function() {
      document.getElementById('pendingTransactions').style.display = 'block';
      document.getElementById('completedTransactions').style.display = 'none';
      this.classList.add('active');
      document.getElementById('completedBtn').classList.remove('active');
    });

    document.getElementById('completedBtn').addEventListener('click', function() {
      document.getElementById('pendingTransactions').style.display = 'none';
      document.getElementById('completedTransactions').style.display = 'block';
      this.classList.add('active');
      document.getElementById('pendingBtn').classList.remove('active');
    });
  </script>
  <jsp:include page="footer.jsp" />
</body>
</html>