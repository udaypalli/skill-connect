package com.skillconnect.util;



import java.sql.Connection;

import com.skillconnect.util.DBConnection;

public class TestDBConnection {
	 public static void main(String[] args) {
	        Connection connection = DBConnection.getConnection();
	        if (connection != null) {
	            System.out.println("Database connected successfully!");
	        } else {
	            System.out.println("Failed to connect to the database.");
	        }
	    }

}

