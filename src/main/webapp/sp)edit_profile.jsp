<%@ page import="java.sql.*, java.util.Base64, org.json.JSONArray, org.json.JSONObject" %>
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
        String expertise = request.getParameter("expertise");
        String location = request.getParameter("location");
        String pricing = request.getParameter("pricing");
        String workingHours = request.getParameter("workingHours");
        String availability = request.getParameter("availability");
        String latitude = request.getParameter("latitude");
        String longitude = request.getParameter("longitude");

        try {
            conn = DBConnection.getConnection();

            // Get provider_id from email stored in session
            String providerEmail = (String) session.getAttribute("providerEmail");
            int providerId = -1;

            String getProviderIdSQL = "SELECT provider_id FROM ServiceProviders WHERE email=?";
            pstmt = conn.prepareStatement(getProviderIdSQL);
            pstmt.setString(1, providerEmail);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                providerId = rs.getInt("provider_id");
            } else {
                request.setAttribute("errorMessage", "Error: No service provider found for this email!");
            }

            if (providerId != -1) {
                // Step 1: Update ServiceProviders table
                String sqlProvider = "UPDATE ServiceProviders SET name=?, phone=?, expertise=?, location=?, pricing=?, working_hours=?, availability=? WHERE provider_id=?";
                pstmt.close(); // Close previous statement before reusing pstmt
                pstmt = conn.prepareStatement(sqlProvider);
                pstmt.setString(1, name);
                pstmt.setString(2, phone);
                pstmt.setString(3, expertise);
                pstmt.setString(4, location);
                pstmt.setString(5, pricing);
                pstmt.setString(6, workingHours);
                pstmt.setString(7, availability);
                pstmt.setInt(8, providerId);
                pstmt.executeUpdate();

                // Step 2: Update Locations table
                String sqlLocation = "INSERT INTO Locations (provider_id, latitude, longitude, address) " +
                                     "VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE latitude=?, longitude=?, address=?";
                pstmt.close(); // Close previous statement before reusing pstmt
                pstmt = conn.prepareStatement(sqlLocation);
                pstmt.setInt(1, providerId);
                pstmt.setString(2, latitude);
                pstmt.setString(3, longitude);
                pstmt.setString(4, location);
                pstmt.setString(5, latitude);
                pstmt.setString(6, longitude);
                pstmt.setString(7, location);
                pstmt.executeUpdate();

                request.setAttribute("errorMessage", "Profile updated successfully!");
            } else {
                request.setAttribute("errorMessage", "Error: Service provider not found!");
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
        
        .card { border: none; }
        .map-container { height: 300px; border-radius: 8px; overflow: hidden; }
        .btn-primary { background-color: #ff7700; border: none; } /* Orange Buttons */
        .btn-primary:hover { background-color: #e66000; }
        #map { height: 300px; border-radius: 8px; }
        .error-alert { margin-top: 20px; }
        .form-label { font-weight: bold; color: #003366; }
        .form-control { border-radius: 8px; }
        .icon { color: #ff7700; margin-right: 10px; }
        .category-card, .service-card { 
            display: inline-block; 
            padding: 8px 16px; 
            margin: 4px; 
            border-radius: 20px; 
            background-color: #e9ecef; 
            cursor: pointer; 
        }
        .selected { background-color: #ff7700; color: white; }
        .time-slot { 
            display: inline-block; 
            padding: 8px 16px; 
            margin: 4px; 
            border-radius: 20px; 
            background-color: #e9ecef; 
            cursor: pointer; 
        }
        .time-slot.selected { background-color: #ff7700; color: white; }
        .availability-toggle { 
            display: flex; 
            align-items: center; 
            gap: 10px; 
        }
        .availability-toggle label { margin: 0; }
        .pricing-input { position: relative; }
        .pricing-input span { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #666; }
    </style>
</head>
<body>
    <%@ include file="service_provider_header.jsp" %>
    <div class="container">
        <div class="card p-4">
            <h3 class="text-center text-primary">Edit Profile</h3>

            <!-- Error Display Area -->
            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert <%= request.getAttribute("errorMessage").toString().startsWith("Error:") ? "alert-danger" : "alert-success" %> error-alert" role="alert">
                    <%= request.getAttribute("errorMessage") %>
                </div>
            <% } %>

            <form action="service_provider_edit_profile.jsp" method="post" onsubmit="return validateForm()">
                <div class="row">
                    <!-- Left Column -->
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-user icon"></i> Name</label>
                            <input type="text" class="form-control" name="name" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-phone icon"></i> Phone</label>
                            <input type="text" class="form-control" name="phone" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-map-marker-alt icon"></i> Location</label>
                            <input type="text" class="form-control" name="location" placeholder="Enter your location" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-money-bill-wave icon"></i> Pricing (₹)</label>
                            <div class="pricing-input">
                                <span>₹</span>
                                <input type="number" class="form-control" name="pricing" placeholder="Enter your pricing" required style="padding-left: 30px;">
                            </div>
                        </div>
                    </div>

                    <!-- Right Column -->
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-briefcase icon"></i> Expertise</label>
                            <div id="expertiseContainer"></div>
                            <input type="hidden" name="expertise" id="expertise">
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-clock icon"></i> Working Hours</label>
                            <div id="timeSlots">
                                <div class="time-slot" data-time="9:00 AM - 12:00 PM">9:00 AM - 12:00 PM</div>
                                <div class="time-slot" data-time="12:00 PM - 3:00 PM">12:00 PM - 3:00 PM</div>
                                <div class="time-slot" data-time="3:00 PM - 6:00 PM">3:00 PM - 6:00 PM</div>
                                <div class="time-slot" data-time="6:00 PM - 9:00 PM">6:00 PM - 9:00 PM</div>
                            </div>
                            <input type="hidden" name="workingHours" id="workingHours">
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-calendar-check icon"></i> Availability</label>
                            <div class="availability-toggle">
                                <label><input type="radio" name="availability" value="true" checked> Available</label>
                                <label><input type="radio" name="availability" value="false"> Not Available</label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Map Section -->
                <label class="form-label"><i class="fas fa-map icon"></i> Location (Fetched from Map)</label>
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
        // Fetch categories and services from the database
        function fetchCategoriesAndServices() {
            fetch("service_provider_edit_profile.jsp?action=fetchCategories")
                .then(response => response.json())
                .then(data => {
                    const expertiseContainer = document.getElementById("expertiseContainer");
                    expertiseContainer.innerHTML = "";

                    data.categories.forEach(category => {
                        const categoryCard = document.createElement("div");
                        categoryCard.className = "category-card";
                        categoryCard.textContent = category.category_name;
                        categoryCard.onclick = () => selectCategory(category);
                        expertiseContainer.appendChild(categoryCard);
                    });
                });
        }

        // Select a category and fetch its services
        function selectCategory(category) {
            fetch(`service_provider_edit_profile.jsp?action=fetchServices&categoryId=${category.category_id}`)
                .then(response => response.json())
                .then(data => {
                    const expertiseContainer = document.getElementById("expertiseContainer");
                    expertiseContainer.innerHTML = "";

                    // Add selected category
                    const selectedCategory = document.createElement("div");
                    selectedCategory.className = "category-card selected";
                    selectedCategory.textContent = `c->${category.category_name}`;
                    selectedCategory.onclick = () => deselectCategory(category);
                    expertiseContainer.appendChild(selectedCategory);

                    // Add services
                    data.services.forEach(service => {
                        const serviceCard = document.createElement("div");
                        serviceCard.className = "service-card";
                        serviceCard.textContent = `s->${service.service_name}`;
                        serviceCard.onclick = () => selectService(service);
                        expertiseContainer.appendChild(serviceCard);
                    });
                });
        }

        // Deselect a category
        function deselectCategory(category) {
            fetchCategoriesAndServices();
        }

        // Select a service
        function selectService(service) {
            const expertiseContainer = document.getElementById("expertiseContainer");
            const selectedService = document.createElement("div");
            selectedService.className = "service-card selected";
            selectedService.textContent = `s->${service.service_name}`;
            selectedService.onclick = () => deselectService(service);
            expertiseContainer.appendChild(selectedService);
        }

        // Deselect a service
        function deselectService(service) {
            const expertiseContainer = document.getElementById("expertiseContainer");
            const serviceCards = expertiseContainer.querySelectorAll(".service-card");
            serviceCards.forEach(card => {
                if (card.textContent === `s->${service.service_name}`) {
                    card.remove();
                }
            });
        }

        // Time slot selection
        const timeSlots = document.querySelectorAll(".time-slot");
        timeSlots.forEach(slot => {
            slot.onclick = () => {
                slot.classList.toggle("selected");
                updateWorkingHours();
            };
        });

        // Update working hours
        function updateWorkingHours() {
            const selectedSlots = document.querySelectorAll(".time-slot.selected");
            const workingHours = Array.from(selectedSlots).map(slot => slot.textContent).join(", ");
            document.getElementById("workingHours").value = workingHours;
        }

        // Fetch categories and services on page load
        fetchCategoriesAndServices();
    </script>
    <%@ include file="footer.jsp" %>
</body>
</html>