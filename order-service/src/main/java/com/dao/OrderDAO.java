package com.dao;

import com.dto.request.FuelOrderReq;
import com.dto.response.CommonResponse;
import com.dto.response.OrderResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceUtils;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.sql.*;
import java.util.logging.Logger;

@Repository
public class OrderDAO {
    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional
    public OrderResponse updateOrderRequest(FuelOrderReq fuelOrderReq){
        OrderResponse  orderResponse = new OrderResponse();
        Connection connection = null;
        CallableStatement callableStatement = null;
        ResultSet resultSet = null;
        try {
            connection = DataSourceUtils.getConnection(jdbcTemplate.getDataSource());
            callableStatement = connection.prepareCall(OrderDAOConstant.Order.INSERT_ORDER_DETAIL);
            callableStatement.setObject(1,fuelOrderReq.getShedId(), Types.BIGINT);
            callableStatement.setObject(2,fuelOrderReq.getFuelType(),Types.SMALLINT);
            callableStatement.setObject(3,fuelOrderReq.getCapacity(),Types.NUMERIC);
            callableStatement.executeUpdate();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()){
               orderResponse.setReferenceNumber(resultSet.getString("rReferenceNumber"));
               orderResponse.setRes(resultSet.getBoolean("Res"));
               orderResponse.setStatusCode(resultSet.getInt("StatusCode"));
               orderResponse.setMessage(resultSet.getString("Msg"));
            }
        }catch (SQLException exception){
            LOGGER.info("Exception occured in updateOrderRequest, "+exception.toString());
        }finally {
            if(callableStatement !=null){
                try{
                    callableStatement.close();
                }catch (Exception ex){
                    LOGGER.info("Close CallableStatement Object...!");
                }
            }
            DataSourceUtils.releaseConnection(connection,jdbcTemplate.getDataSource());
        }
        return orderResponse;
    }
}
