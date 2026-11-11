package DAO;

import conexion.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PlatoDAO {

    // Clase modelo sencilla para representar el plato (o puedes usar tu propia clase Plato si ya la tienes)
    public static class Plato {
        private int idPlato;
        private String nombre;
        private double precio;
        private String categoria;

        public Plato(int idPlato, String nombre, double precio, String categoria) {
            this.idPlato = idPlato;
            this.nombre = nombre;
            this.precio = precio;
            this.categoria = categoria;
        }

        public int getIdPlato() { return idPlato; }
        public String getNombre() { return nombre; }
        public double getPrecio() { return precio; }
        public String getCategoria() { return categoria; }
        
        // Esto es clave para que el JComboBox o JList muestre el nombre y precio bonito
        @Override
        public String toString() {
            return nombre + " - $" + precio;
        }
    }

    /**
     * Consulta todos los platos disponibles en la base de datos unidos con sus categorías
     */
    public List<Plato> obtenerPlatosDisponibles() {
        List<Plato> listaPlatos = new ArrayList<>();
        String sql = "SELECT p.id_plato, p.nombre, p.precio, c.nombre AS categoria " +
                     "FROM platos p " +
                     "JOIN categorias c ON p.id_categoria = c.id_categoria " +
                     "WHERE p.disponible = 1 AND p.estado = 1";

        try (Connection cn = Conexion.conectar();
             PreparedStatement pst = cn.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                int id = rs.getInt("id_plato");
                String nombre = rs.getString("nombre");
                double precio = rs.getDouble("precio");
                String categoria = rs.getString("categoria");

                Plato plato = new Plato(id, nombre, precio, categoria);
                listaPlatos.add(plato);
            }

        } catch (SQLException e) {
            System.err.println("Error al obtener los platos: " + e.getMessage());
        }

        return listaPlatos;
    }
}