<%@ page import="java.sql.*, java.util.ArrayList" %>
<%@ page import="com.skillconnect.util.DBConnection" %>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // Store categories and services in lists
    ArrayList<String> categories = new ArrayList<>();
    ArrayList<String[]> services = new ArrayList<>();

    try {
        conn = DBConnection.getConnection();

        // Fetch categories
        String sqlCategories = "SELECT category_name FROM Categories";
        pstmt = conn.prepareStatement(sqlCategories);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            categories.add(rs.getString("category_name"));
        }
        rs.close();
        pstmt.close();

        // Fetch services
        String sqlServices = "SELECT S.service_name, C.category_name FROM Services S " +
                             "JOIN Categories C ON S.category_id = C.category_id";
        pstmt = conn.prepareStatement(sqlServices);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            services.add(new String[]{rs.getString("category_name"), rs.getString("service_name")});
        }

        // Store in request attributes
        request.setAttribute("categories", categories);
        request.setAttribute("services", services);
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
