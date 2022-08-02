create function update_order_history("pOrderDetailId" bigint, "pReferenceNumber" character varying, "pShedId" bigint, "pFuelType" smallint, "pCapacity" numeric, "pOrderStatus" smallint, "pCreatedOn" timestamp without time zone, "pUpdatedOn" timestamp without time zone, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) returns record
    language plpgsql
as
$$
DECLARE
    err_context text;
BEGIN
    "Res" := true;
    "Msg" := '';
    "StatusCode" := 0;

    INSERT INTO "OrderHistory"(
                               "OrderDetailId",
                               "ReferenceNumber",
                               "ShedId","Capacity",
                               "FuelType",
                               "OrderStatus",
                               "CreatedOn",
                               "OrderCreatedOn",
                               "OrderUpdatedOn")
                VALUES (
                        "pOrderDetailId",
                        "pReferenceNumber",
                        "pShedId",
                        "pCapacity",
                        "pFuelType",
                        "pOrderStatus",
                         now(),
                        "pCreatedOn",
                        "pUpdatedOn"
                        );

exception
    when others then
        GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        RAISE INFO 'Error Context:%', err_context;
        "Res" := false;
        "Msg" := err_context;
        "StatusCode" := 1005;

        return;
END ;
$$;

alter function update_order_history(bigint, varchar, bigint, smallint, numeric, smallint, timestamp, timestamp, out boolean, out varchar, out integer) owner to postgres;


