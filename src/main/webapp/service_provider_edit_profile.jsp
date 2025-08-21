<%@ page import="java.sql.*, java.util.Base64, org.json.JSONArray, org.json.JSONObject" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%@ page import="java.io.InputStream, java.io.IOException, jakarta.servlet.http.Part" %>
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
        int pincode = Integer.parseInt(request.getParameter("pincode"));

        try {
            conn = DBConnection.getConnection();

            // Get provider_id from email stored in session
            String providerEmail = (String) session.getAttribute("userEmail");
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
                String sqlProvider = "UPDATE ServiceProviders SET name=?, phone=?, expertise=?, location=?, pricing=?, working_hours=?, availability=?, pincode=? WHERE provider_id=?";
                pstmt.close(); // Close previous statement before reusing pstmt
                pstmt = conn.prepareStatement(sqlProvider);
                pstmt.setString(1, name);
                pstmt.setString(2, phone);
                pstmt.setString(3, expertise);
                pstmt.setString(4, location);
                pstmt.setString(5, pricing);
                pstmt.setString(6, workingHours);
                pstmt.setString(7, availability);
                pstmt.setInt(8, pincode);
                pstmt.setInt(9, providerId);
                pstmt.executeUpdate();

                // Step 2: Check if provider_id exists in Locations table and update or insert accordingly
                String checkLocationSQL = "SELECT COUNT(*) FROM Locations WHERE provider_id = ?";
                pstmt.close();
                pstmt = conn.prepareStatement(checkLocationSQL);
                pstmt.setInt(1, providerId);
                rs = pstmt.executeQuery();
                boolean providerExistsInLocations = false;
                if (rs.next()) {
                    providerExistsInLocations = rs.getInt(1) > 0;
                }

                if (providerExistsInLocations) {
                    // Update existing location record
                    String sqlUpdateLocation = "UPDATE Locations SET latitude=?, longitude=?, address=? WHERE provider_id=?";
                    pstmt.close();
                    pstmt = conn.prepareStatement(sqlUpdateLocation);
                    pstmt.setString(1, latitude);
                    pstmt.setString(2, longitude);
                    pstmt.setString(3, location);
                    pstmt.setInt(4, providerId);
                    pstmt.executeUpdate();
                } else {
                    // Insert new location record
                    String sqlInsertLocation = "INSERT INTO Locations (provider_id, latitude, longitude, address) VALUES (?, ?, ?, ?)";
                    pstmt.close();
                    pstmt = conn.prepareStatement(sqlInsertLocation);
                    pstmt.setInt(1, providerId);
                    pstmt.setString(2, latitude);
                    pstmt.setString(3, longitude);
                    pstmt.setString(4, location);
                    pstmt.executeUpdate();
                }

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
                            <label class="form-label"><i class="fas fa-money-bill-wave icon"></i> Pricing (RS)</label>
                            <div class="pricing-input">
                                <span>RS</span>
                                <input type="number" class="form-control" name="pricing" placeholder="Enter your pricing" required style="padding-left: 30px;">
                            </div>
                        </div>
                      <div class="mb-3">
    <label class="form-label"><i class="fas fa-mail-bulk icon"></i> Pincode</label>
    <input type="text" class="form-control" name="pincode" placeholder="Enter your pincode" required>
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
                                <label><input type="radio" name="availability" value="1" checked> Available</label>
                                <label><input type="radio" name="availability" value="0"> Not Available</label>
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
   <%@ include file="fetchCategoriesAndServices.jsp" %>
<script>
    // Categories and services data from JSP
    let categories = <%= new org.json.JSONArray((ArrayList<String>) request.getAttribute("categories")) %>;
    let services = <%= new org.json.JSONArray((ArrayList<String[]>) request.getAttribute("services")) %>;

    function loadCategoriesAndServices() {
        const expertiseContainer = document.getElementById("expertiseContainer");
        expertiseContainer.innerHTML = ""; // Clear previous data

        // Display categories
        categories.forEach(category => {
            let categoryCard = document.createElement("div");
            categoryCard.className = "category-card";
            categoryCard.innerText = category;
            categoryCard.onclick = function() {
                categoryCard.classList.toggle("selected");
                loadServices(category, expertiseContainer);
            };
            expertiseContainer.appendChild(categoryCard);
        });
    }

    function loadServices(selectedCategory, container) {
        // Remove existing service cards before adding new ones
        let existingServiceContainer = container.querySelector(".services-container");
        if (existingServiceContainer) {
            existingServiceContainer.remove();
        }

        let servicesContainer = document.createElement("div");
        servicesContainer.className = "services-container";

        services.forEach(service => {
            if (service[0] === selectedCategory) { // Match category name
                let serviceCard = document.createElement("div");
                serviceCard.className = "service-card";
                serviceCard.innerText = service[1];
                serviceCard.onclick = function() {
                    serviceCard.classList.toggle("selected");
                };
                servicesContainer.appendChild(serviceCard);
            }
        });

        container.appendChild(servicesContainer);
    }
    function updateExpertiseField() {
        let selectedItems = [];

        // Get selected categories
        document.querySelectorAll(".category-card.selected").forEach(categoryCard => {
            let category = categoryCard.innerText;
            let selectedServices = [];

            // Get selected services under this category
            let servicesContainer = categoryCard.nextElementSibling;
            if (servicesContainer && servicesContainer.classList.contains("services-container")) {
                servicesContainer.querySelectorAll(".service-card.selected").forEach(serviceCard => {
                    selectedServices.push(serviceCard.innerText);
                });
            }

            // Combine category and its services
            if (selectedServices.length > 0) {
                selectedItems.push(category + "," + selectedServices.join(","));
            } else {
                selectedItems.push(category);
            }
        });
        console.log("Selected Items to be Sent:", selectedItems);


        // Update hidden input field
        document.getElementById("expertise").value = selectedItems.join(",");
    }

    // Ensure expertise field updates before form submission
    document.querySelector("form").addEventListener("submit", function() {
        updateExpertiseField();
    });


    document.querySelector("form").addEventListener("submit", function() {
        updateExpertiseField(); // Ensure expertise field is updated before submission
    });

    // Load categories and services when the page is ready
    document.addEventListener("DOMContentLoaded", loadCategoriesAndServices);
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
    function updateWorkingHours() {
        let selectedSlots = [];
        document.querySelectorAll(".time-slot.selected").forEach(slot => {
            selectedSlots.push(slot.dataset.time);
        });
        document.getElementById("workingHours").value = selectedSlots.join(",");
    }

    document.querySelector("form").addEventListener("submit", function() {
        updateWorkingHours();
    });

    document.querySelectorAll(".time-slot").forEach(slot => {
        slot.addEventListener("click", function() {
            slot.classList.toggle("selected");
            updateWorkingHours();
        });
    });

</script>


    <%@ include file="footer.jsp" %>
</body>
</html>