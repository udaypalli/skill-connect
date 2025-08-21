<%@ page import="java.sql.*, java.util.Base64" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%@ page import="java.io.InputStream, java.io.IOException, jakarta.servlet.http.Part" %>
<%

%>
<%

    if (request.getMethod().equalsIgnoreCase("post")) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String manualAddress = request.getParameter("manualAddress");
        String pincode = request.getParameter("pincode");
        String location = request.getParameter("location");
        String latitude = request.getParameter("latitude");
        String longitude = request.getParameter("longitude");

        try {
            conn = DBConnection.getConnection();

            // Get user_id from email stored in session
            String userEmail = (String) session.getAttribute("userEmail");
            int userId = -1;

            String getUserIdSQL = "SELECT user_id FROM Users WHERE email=?";
            pstmt = conn.prepareStatement(getUserIdSQL);
            pstmt.setString(1, userEmail);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                userId = rs.getInt("user_id");
            } else {
                request.setAttribute("errorMessage", "Error: No user found for this email!");
            }

            if (userId != -1) {
                // Step 1: Update Users table
                String sqlUser = "UPDATE Users SET name=?, phone=?, location=? WHERE user_id=?";
                pstmt.close(); // Close previous statement before reusing pstmt
                pstmt = conn.prepareStatement(sqlUser);
                pstmt.setString(1, name);
                pstmt.setString(2, phone);
                pstmt.setString(3, manualAddress); // User-typed address
                pstmt.setInt(4, userId);
                pstmt.executeUpdate();

                // Step 2: Check if user_id exists in Locations table and update or insert accordingly
                String checkLocationSQL = "SELECT COUNT(*) FROM Locations WHERE user_id = ?";
                pstmt.close();
                pstmt = conn.prepareStatement(checkLocationSQL);
                pstmt.setInt(1, userId);
                rs = pstmt.executeQuery();
                boolean userExistsInLocations = false;
                if (rs.next()) {
                    userExistsInLocations = rs.getInt(1) > 0;
                }

                String addressWithPincode = location + ", Pincode: " + pincode;
                if (userExistsInLocations) {
                    // Update existing location record
                    String sqlUpdateLocation = "UPDATE Locations SET latitude=?, longitude=?, address=? WHERE user_id=?";
                    pstmt.close();
                    pstmt = conn.prepareStatement(sqlUpdateLocation);
                    pstmt.setString(1, latitude);
                    pstmt.setString(2, longitude);
                    pstmt.setString(3, addressWithPincode);
                    pstmt.setInt(4, userId);
                    pstmt.executeUpdate();
                } else {
                    // Insert new location record
                    String sqlInsertLocation = "INSERT INTO Locations (user_id, latitude, longitude, address) VALUES (?, ?, ?, ?)";
                    pstmt.close();
                    pstmt = conn.prepareStatement(sqlInsertLocation);
                    pstmt.setInt(1, userId);
                    pstmt.setString(2, latitude);
                    pstmt.setString(3, longitude);
                    pstmt.setString(4, addressWithPincode);
                    pstmt.executeUpdate();
                }

                request.setAttribute("errorMessage", "Profile updated successfully!");
            } else {
                request.setAttribute("errorMessage", "Error: User not found!");
            }
        } catch (Exception e) {
            // Handle all exceptions in a unified way
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile - SkillConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
    <style>
        body { background-color: #f8f9fa; }
        .container { max-width: 900px; }
        .card { border-radius: 12px; box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1); }
        .map-container { height: 300px; border-radius: 8px; overflow: hidden; }
        .btn-primary { background-color: #ff7700; border: none; } /* Orange Buttons */
        .btn-primary:hover { background-color: #e66000; }
        #map { height: 300px; border-radius: 8px; }
        .profile-imgg {  width: 300px !important; 
    height: 300px !important;  border-radius: 50%; object-fit: cover; cursor: pointer; }
        .error-alert { margin-top: 20px; }
    </style>
</head>
<body>
<%@ include file="user_header.jsp" %>
    <div class="container mt-5">
        <div class="card p-4">
            <h3 class="text-center text-primary">Edit Profile</h3>

            <!-- Error Display Area -->
            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert <%= request.getAttribute("errorMessage").toString().startsWith("Error:") ? "alert-danger" : "alert-success" %> error-alert" role="alert">
                    <%= request.getAttribute("errorMessage") %>
                </div>
            <% } %>

            <form action="user_edit_profile.jsp" method="post" onsubmit="return validateForm()">
                <div class="row">
                    <!-- Profile Image Section -->
                    <div class="col-md-4 text-center">
                        <label>
                            <img id="previewImage" class="profile-imgg" src="default-profile (2).png" alt="Profile">
                        </label>
                    </div>

                    <!-- User Details Section -->
                    <div class="col-md-8">
                        <div class="mb-3">
                            <label class="form-label">Name</label>
                            <input type="text" class="form-control" name="name" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Phone</label>
                            <input type="text" class="form-control" name="phone" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Manual Address</label>
                            <input type="text" class="form-control" name="manualAddress" placeholder="Enter your address manually" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Pincode</label>
                            <input type="text" class="form-control" name="pincode" placeholder="Enter your pincode" required>
                        </div>
                    </div>
                </div>

                <!-- Map Section -->
                <label class="form-label">Location (Fetched from Map)</label>
                <div class="d-flex">
                    <input type="text" class="form-control" id="location" name="location" placeholder="Choose location from map..." readonly>
                    <button type="button" class="btn btn-primary ms-2" onclick="getCurrentLocation()">Use My Location</button>
                </div>
                <div id="map" class="map-container mt-3"></div>
                <input type="hidden" id="latitude" name="latitude">
                <input type="hidden" id="longitude" name="longitude">

                <div class="text-center mt-4">
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
    <script>
        var map = L.map('map').setView([20.5937, 78.9629], 5); // Default India
        L.tileLayer('https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', {
            subdomains: ['mt0', 'mt1', 'mt2', 'mt3'], // Satellite View
            attribution: '© Google Maps'
        }).addTo(map);

        var marker;
        function getCurrentLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;
                    updateMap(lat, lng);
                }, function(error) {
                    // Display error in the error area
                    document.querySelector(".error-alert").innerHTML = "Failed to get location: " + error.message;
                    document.querySelector(".error-alert").classList.remove("alert-success");
                    document.querySelector(".error-alert").classList.add("alert-danger");
                    document.querySelector(".error-alert").style.display = "block";
                }, {
                    enableHighAccuracy: true,
                    timeout: 10000,
                    maximumAge: 0
                });
            } else {
                // Display error in the error area
                document.querySelector(".error-alert").innerHTML = "Geolocation is not supported by this browser.";
                document.querySelector(".error-alert").classList.remove("alert-success");
                document.querySelector(".error-alert").classList.add("alert-danger");
                document.querySelector(".error-alert").style.display = "block";
            }
        }

        function updateMap(lat, lng) {
            if (marker) {
                map.removeLayer(marker);
            }
            marker = L.marker([lat, lng]).addTo(map);
            map.setView([lat, lng], 16);
            document.getElementById("latitude").value = lat;
            document.getElementById("longitude").value = lng;

            fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`)
                .then(response => response.json())
                .then(data => {
                    document.getElementById("location").value = data.display_name;
                })
                .catch(error => {
                    // Display error in the error area
                    document.querySelector(".error-alert").innerHTML = "Error fetching address: " + error.message;
                    document.querySelector(".error-alert").classList.remove("alert-success");
                    document.querySelector(".error-alert").classList.add("alert-danger");
                    document.querySelector(".error-alert").style.display = "block";
                });
        }

        map.on('click', function(e) {
            updateMap(e.latlng.lat, e.latlng.lng);
        });

        // Validate required fields before form submission
        function validateForm() {
            const requiredFields = document.querySelectorAll("input[required]");
            let isValid = true;

            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    isValid = false;
                    field.classList.add("is-invalid");
                } else {
                    field.classList.remove("is-invalid");
                }
            });

            if (!isValid) {
                // Display error in the error area
                document.querySelector(".error-alert").innerHTML = "Please fill out all required fields before submitting.";
                document.querySelector(".error-alert").classList.remove("alert-success");
                document.querySelector(".error-alert").classList.add("alert-danger");
                document.querySelector(".error-alert").style.display = "block";
            }

            return isValid;
        }
    </script>
    <%@ include file="footer.jsp" %>
</body>
</html>