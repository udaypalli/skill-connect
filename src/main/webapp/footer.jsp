<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<head >
<meta charset="UTF-8">
<style>
.modern-footer {
    background: linear-gradient(135deg, #001f3f 0%, #001329 100%);
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    position: relative;
    overflow: hidden;
}

.modern-footer::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(45deg, rgba(66, 178, 255, 0.1) 0%, rgba(0, 0, 0, 0) 100%);
    z-index: 1;
}

.footer-content {
    position: relative;
    z-index: 2;
}

.footer-logo {
    font-size: 1.8rem;
    font-weight: 700;
    color: #ffffff;
    text-decoration: none;
}

.footer-title {
    color: #ffffff;
    font-weight: 600;
    font-size: 1.2rem;
    margin-bottom: 1.5rem;
    position: relative;
    display: inline-block;
}

.footer-title::after {
    content: '';
    position: absolute;
    left: 0;
    bottom: -5px;
    width: 100%;
    height: 2px;
    background: linear-gradient(90deg, #66b2ff, transparent);
}

.contact-info {
    list-style: none;
    padding: 0;
}

.contact-info li {
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    gap: 10px;
    color: #ffffff;
}

.contact-info i {
    color: #66b2ff;
    width: 20px;
}

.social-links {
    display: flex;
    gap: 15px;
}

.social-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: white;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #001f3f;
    text-decoration: none;
    transition: all 0.3s ease;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.social-icon:hover {
    transform: translateY(-3px);
    color: #66b2ff;
    box-shadow: 0 5px 15px rgba(102, 178, 255, 0.2);
}

.quick-links {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 1rem;
    padding: 0;
    list-style: none;
}

.quick-links a {
    color: #ffffff; /* Changed to White */
    text-decoration: none;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 5px;
}

.quick-links a:hover {
    color: #66b2ff;
    transform: translateX(5px);
}

.quick-links a::before {
    content: '→';
    opacity: 0;
    transition: all 0.3s ease;
}

.quick-links a:hover::before {
    opacity: 1;
}

.newsletter-input {
    border: none;
    padding: 0.8rem;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.btn-subscribe {
    background: linear-gradient(45deg, #ff851b, #ff6600); /* Orange Gradient */
    border: none;
    box-shadow: 0 2px 10px rgba(255, 133, 27, 0.2);
    padding: 0.8rem 2rem;
    border-radius: 10px;
    color: #ffffff; /* White text for better visibility */
    font-weight: bold;
    transition: all 0.3s ease;
}

.btn-subscribe:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(255, 133, 27, 0.3);
}


.footer-bottom {
    background: #001329;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.footer-bottom p {
    margin: 0;
    color: #ffffff;
}

.footer-bottom a {
    color: #ffffff; /* Changed to White */
    text-decoration: none;
}

.footer-bottom a:hover {
    text-decoration: underline;
    color: #66b2ff;
}

@media (max-width: 768px) {
    .quick-links {
        grid-template-columns: 1fr;
    }
}


</style>
</head>
<body>
    <footer class="modern-footer pt-5">
        <div class="container footer-content">
            <div class="row g-4 mb-5">
                <!-- Company Info -->
                <div class="col-lg-4 col-md-6">
                    <a href="#" class="footer-logo d-block mb-4">
                        SkillConnect<span class="text-primary">.</span>
                    </a>
                    <p class="text-white mb-4" >Empowering businesses with innovative digital solutions. We create
                        meaningful experiences that drive success.</p>
                    <ul class="contact-info mb-4">
                        <li>
                            <i class="fas fa-map-marker-alt"></i>
                            <span>I Group Vidi Gharkul <br>Solapur, 413005</span>
                        </li>
                        <li>
                            <i class="fas fa-phone"></i>
                            <span>+91 23178213223</span>
                        </li>
                        <li>
                            <i class="fas fa-envelope"></i>
                            <span>skillconnectsupport@gmail.com</span>
                        </li>
                    </ul>
                </div>

                <!-- Quick Links -->
                <div class="col-lg-4 col-md-6">
                    <h3 class="footer-title">Quick Links</h3>
                    <ul class="quick-links">
                        <li><a href="#">Our Services</a></li>
                        <li><a href="#">About Company</a></li>
                        <li><a href="#">Customer Support</a></li>
                        <li><a href="#">Privacy Policy</a></li>
                        <li><a href="#">Find Service</a></li>
                        <li><a href="#">Become Provider</a></li>
                        <li><a href="admin_login.jsp">Admin Login</a></li>
                        <li><a href="#">Terms of Service</a></li>
                    </ul>
                </div>

                <!-- Newsletter -->
                <div class="col-lg-4 col-md-12">
                    <h3 class="footer-title">Stay Connected</h3>
                    <p class="text-muted mb-4">Subscribe to our newsletter and stay updated with the latest news and
                        insights.</p>
                    <form class="mb-4">
                        <div class="mb-3">
                            <input type="email" class="form-control newsletter-input" placeholder="Your email address">
                        </div>
                        <button type="submit" class="btn btn-subscribe text-white w-100">Subscribe Now</button>
                    </form>
                    <div class="social-links">
                        <a href="#" class="social-icon"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-instagram"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-linkedin-in"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-youtube"></i></a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer Bottom -->
        <div class="footer-bottom">
            <div class="container">
                <div class="row py-4">
                    <div class="col-md-6 text-center text-md-start">
                        <p>&copy; 2024 SkillConnect. All rights reserved.</p>
                    </div>
                    <div class="col-md-6 text-center text-md-end">
                        <p>Made with <i class="fas fa-heart text-danger"></i> by <a href="#">Uday</a></p>
                    </div>
                </div>
            </div>
        </div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>