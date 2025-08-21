<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Invalidate session
    session.invalidate();

    // Delete cookies by setting their expiry to 0
    Cookie emailCookie = new Cookie("userEmail", "");
    Cookie roleCookie = new Cookie("userRole", "");
    emailCookie.setMaxAge(0);
    roleCookie.setMaxAge(0);
    response.addCookie(emailCookie);
    response.addCookie(roleCookie);

    // Redirect to login page
    response.sendRedirect("index.jsp");
%>