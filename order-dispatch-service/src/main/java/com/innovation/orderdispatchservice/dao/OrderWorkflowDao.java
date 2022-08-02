package com.innovation.orderdispatchservice.dao;

import com.innovation.orderdispatchservice.dto.request.OrderScheduleRequest;
import com.innovation.orderdispatchservice.dto.response.CommonResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceUtils;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.sql.*;
import java.util.logging.Logger;

/**
 * @Author G.Vageeshan
 * @Version 1.0
 * @since 2022-08-03 12:50 AM Wednesday
 **/

@Repository
public class OrderWorkflowDao {

    private static final Logger LOGGER = Logger.getLogger(OrderWorkflowDao.class.getName());

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional
    public CommonResponse scheduleOrderRequest(OrderScheduleRequest orderScheduleRequest) {
        CommonResponse commonResponse = new CommonResponse();
        Connection connection = null;
        CallableStatement callableStatement = null;
        ResultSet resultSet = null;
        try {
            connection = DataSourceUtils.getConnection(jdbcTemplate.getDataSource());
            callableStatement = connection.prepareCall(OrderWorkflowDaoConstant.OrderWorkflow.UPDATE_ORDER_STATUS);
            callableStatement.setObject(1, orderScheduleRequest.getOrderReferenceNumber(), Types.VARCHAR);
            callableStatement.setObject(2, OrderWorkflowDaoConstant.OrderWorkflow.orderStatus, Types.SMALLINT);
            callableStatement.executeUpdate();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()) {
                commonResponse.setMessage("Order Scheduled Successfully!!!");
                commonResponse.setStatusCode(200);
            }
        } catch (SQLException exception) {
            LOGGER.info("Exception occurred in this workflow, " + exception.toString());
        } finally {
            if (callableStatement != null) {
                try {
                    callableStatement.close();
                } catch (Exception ex) {
                    LOGGER.info("Close CallableStatement Object...!");
                }
            }
            DataSourceUtils.releaseConnection(connection, jdbcTemplate.getDataSource());
        }
        return commonResponse;
    }
}
