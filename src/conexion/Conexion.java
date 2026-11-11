/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package conexion;

import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 *
 * @author Jose1
 */
public class Conexion {

    // Valores por defecto (se usan si no existe el archivo db.properties)
    private static String URL = "jdbc:mysql://localhost:3306/restaurante_gestion";
    private static String USER = "root";
    private static String PASSWORD = "42033205566";

    // Se ejecuta una sola vez: lee db.properties si existe.
    static {
        Properties props = new Properties();
        InputStream in = null;
        try {
            in = new FileInputStream("db.properties");
        } catch (Exception e1) {
            try {
                in = new FileInputStream("../db.properties");
            } catch (Exception e2) {
                in = null;
            }
        }
        if (in != null) {
            try {
                props.load(in);
                URL = props.getProperty("db.url", URL);
                USER = props.getProperty("db.user", USER);
                PASSWORD = props.getProperty("db.password", PASSWORD);
                System.out.println("Configuracion cargada desde db.properties");
            } catch (Exception e) {
                System.out.println("No se pudo leer db.properties, usando valores por defecto");
            }
        }
    }

    public static Connection conectar() {

        Connection conexion = null;

        try {

            conexion = DriverManager.getConnection(
                    URL,
                    USER,
                    PASSWORD
            );

            System.out.println("Conexion exitosa a MySQL");

        } catch (SQLException e) {

            System.out.println("Error de conexion: " + e.getMessage());
        }

        return conexion;
    }
    
}
