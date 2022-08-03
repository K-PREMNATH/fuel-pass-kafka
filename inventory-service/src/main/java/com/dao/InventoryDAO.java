package com.dao;

import com.dto.response.GeneralResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceUtils;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.sql.*;
import java.util.logging.Logger;

@Repository
public class InventoryDAO {
    private static final Logger LOGGER = Logger.getLogger(InventoryDAO.class.getName());

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional
    public GeneralResponse updateScheduleOrder(short fuelTypeId,double capacity,String referenceNumber){
        GeneralResponse  response = new GeneralResponse();
        Connection connection = null;
        CallableStatement callableStatement = null;
        ResultSet resultSet = null;
        try {
            connection = DataSourceUtils.getConnection(jdbcTemplate.getDataSource());
            callableStatement = connection.prepareCall(InventoryDAOConstant.Inventory.UPDATE_FUEL_ALLOCATION);
            callableStatement.setObject(1,fuelTypeId, Types.SMALLINT);
            callableStatement.setObject(2,capacity,Types.NUMERIC);
            callableStatement.setObject(3,referenceNumber,Types.VARCHAR);
            callableStatement.executeUpdate();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()){
                response.setRes(resultSet.getBoolean("Res"));
                response.setStatusCode(resultSet.getInt("StatusCode"));
                response.setMessage(resultSet.getString("Msg"));
            }
        }catch (SQLException exception){
            LOGGER.info("Exception occured in updateScheduleOrder, "+exception.toString());
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
        return response;
    }
}
