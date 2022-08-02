create function update_order_status("pReferenceNumber" character varying, "pOrderStatus" smallint, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) returns record
    language plpgsql
as
$$
DECLARE
    err_context      text;
    lOrderDetailId   bigint                      := 0;
    lReferenceNumber character varying           := '';
    lShedId          bigint                      := 0;
    lFuelType        smallint                    := 0;
    lCapacity        numeric                     := 0.0;
    lOrderStatus     smallint                    := 0;
    lCreatedOn       timestamp without time zone ;
    lUpdatedOn       timestamp without time zone ;
BEGIN
    "Res" := true;
    "Msg" := '';
    "StatusCode" := 0;

    --RAISE NOTICE 'orderstatus - 1: %', "pOrderStatus";

    Select "OrderDetailId",
           "ReferenceNumber",
           "ShedId",
           "FuelType",
           "Capacity",
           "OrderStatus",
           "CreatedOn",
           "UpdatedOn"
    into
        lOrderDetailId,
        lReferenceNumber,
        lShedId,
        lFuelType,
        lCapacity,
        lOrderStatus,
        lCreatedOn,
        lUpdatedOn
    from "Order"
    where "ReferenceNumber" = "pReferenceNumber";


    UPDATE "Order"
    set "OrderStatus" = "pOrderStatus",
        "UpdatedOn"   = now()
    where "ReferenceNumber" = "pReferenceNumber";

    select h."Res", h."StatusCode", h."Msg"
    into "Res","StatusCode","Msg"
    from update_order_history(
                 lOrderDetailId,
                 lReferenceNumber,
                 lShedId,
                 lFuelType::smallint,
                 lCapacity::numeric,
                 lOrderStatus::smallint,
                 lCreatedOn,
                 lUpdatedOn
             ) h;

exception
    when others then
        GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        RAISE INFO 'Error Context:%', err_context;
        "Res" := false;
        "Msg" := 'Unable to update the order request...!';
        "StatusCode" := 1004;

        return;
END ;
$$;

alter function update_order_status(varchar, smallint, out boolean, out varchar, out integer) owner to postgres;


