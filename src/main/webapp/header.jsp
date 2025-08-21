<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css">
    <style>
        .navbar-custom {
            background-color: #1976D2;
            padding: 10px 20px;
        }
        .brand-text {
            font-size: 1.8rem;
            font-weight: bold;
            color: white;
        }
        .brand-text .connect {
            color: #F37321;
        }
        .nav-link {
            color: white !important;
            font-weight: bold;
            transition: 0.3s;
        }
        .nav-link:hover {
            color: #F57C00 !important;
        }
        .btn-custom {
            background-color: #F37321;
            color: white;
            border-radius: 5px;
            padding: 8px 15px;
            transition: 0.3s;
        }
        .btn-custom:hover {
            background-color: #E65100;
            color: white;
        }
        .icon-btn {
            font-size: 1.5rem;
            color: white;
            margin-right: 15px;
            transition: 0.3s;
        }
        .icon-btn:hover {
            color: #F57C00;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-custom shadow">
        <div class="container">
            <!-- SkillConnect Text Logo -->
            <a class="navbar-brand brand-text" href="index.jsp">
                <span class="skill">Skill</span><span class="connect">Connect</span>
            </a>

            <!-- Navbar Toggler for Mobile -->
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <!-- Navbar Content -->
            <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
                <ul class="navbar-nav align-items-center">
                    <!-- Notification Icon -->
                    <li class="nav-item">
                        <a class="nav-link icon-btn" href="#"><i class="bi bi-bell-fill"></i></a>
                    </li>
                    <!-- Login & Signup Buttons -->
                    <li class="nav-item">
                        <a href="login.jsp" class="btn btn-custom me-2">Login</a>
                    </li>
                    <li class="nav-item">
                        <a href="signup.jsp" class="btn btn-custom">Sign Up</a>



						
						
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <script src="assets/js/bootstrap.bundle.min.js"></script>
</body>
</html>
