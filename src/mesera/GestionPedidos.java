package mesera;

import conexion.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class GestionPedidos {

    public boolean guardarPedidoTransaccional(int idMesa, int idUsuario, double totalPedido) {
        
        String sqlInsertarPedido = "INSERT INTO pedidos (id_mesa, id_usuario, total, estado) VALUES (?, ?, ?, 'PENDIENTE')";
        String sqlActualizarMesa = "UPDATE mesas SET estado = 'OCUPADA' WHERE id_mesa = ?";

        Connection cn = null;
        PreparedStatement pstPedido = null;
        PreparedStatement pstMesa = null;
        ResultSet rsKeys = null;

        try {
            cn = Conexion.conectar();
            
            if (cn == null) {
                System.out.println("No hay conexión con la base de datos.");
                return false;
            }

            cn.setAutoCommit(false);

            pstPedido = cn.prepareStatement(sqlInsertarPedido, Statement.RETURN_GENERATED_KEYS);
            pstPedido.setInt(1, idMesa);
            pstPedido.setInt(2, idUsuario);
            pstPedido.setDouble(3, totalPedido);
            pstPedido.executeUpdate();

            rsKeys = pstPedido.getGeneratedKeys();
            int idPedidoGenerado = -1;
            if (rsKeys.next()) {
                idPedidoGenerado = rsKeys.getInt(1);
            } else {
                throw new SQLException("No se pudo obtener el ID del pedido.");
            }

            pstMesa = cn.prepareStatement(sqlActualizarMesa);
            pstMesa.setInt(1, idMesa);
            pstMesa.executeUpdate();

            cn.commit();
            System.out.println("¡Pedido #" + idPedidoGenerado + " guardado con éxito!");
            return true;

        } catch (SQLException e) {
            System.err.println("Error en la transacción, aplicando Rollback: " + e.getMessage());
            if (cn != null) {
                try {
                    cn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            try {
                if (rsKeys != null) rsKeys.close();
                if (pstPedido != null) pstPedido.close();
                if (pstMesa != null) pstMesa.close();
                if (cn != null) {
                    cn.setAutoCommit(true);
                    cn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}