/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package conexion;

import java.sql.Connection;

/**
 *
 * @author Jose1
 */
public class PruebaConexion {
    
    public static void main(String[] args){
        Connection conexion = Conexion.conectar();
        
        if(conexion != null){
            System.out.println(
            "todo funciona correctamente.");
        }else {
            System.out.println(
            "no se pudo conectar");
        }
    }
    
}
