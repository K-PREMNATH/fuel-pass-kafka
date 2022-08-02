create function insert_order_detail("pShedId" bigint, "pFuelType" smallint, "pCapacity" numeric, OUT "rReferenceNumber" character varying, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) returns record
    language plpgsql
as
$$
DECLARE
    err_context text;
    lUUID varchar(50) := '';
    lCount integer := 0;
BEGIN
    "Res" := true;
    "Msg" := '';
    "StatusCode" := 0;
    "rReferenceNumber" := '';
    
    --validate shed detail
    IF "pShedId" = 0 THEN
         "Res" := false;
         "Msg" := 'Please select the Shed Detail...!';
         "StatusCode" := 1002;
         return;
    ELSE
        Select count("ShedId") ::integer
        into lCount 
        from "ShedRegister"
        where "ShedId" = "pShedId";
        IF lCount = 0 THEN
         "Res" := false;
         "Msg" := 'Invalid Shed...!';
         "StatusCode" := 1003;
         return;
        END IF;
    END IF;
        
    select uuid_in(md5(random()::text || random()::text)::cstring) into lUUID;

    INSERT INTO "Order"
        ("ShedId",
         "Capacity",
         "FuelType",
         "OrderStatus",
         "ReferenceNumber")
    VALUES ("pShedId",
            "pCapacity",
            "pFuelType",
            1::smallint,
            lUUID) returning "ReferenceNumber" into "rReferenceNumber";

    exception
    when others then
        GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        RAISE INFO 'Error Context:%', err_context;
        "Res" := false;
        "Msg" := 'Unable to place the request...!';
        "StatusCode" := 1001;

    return ;
END ;
$$;

alter function insert_order_detail(bigint, smallint, numeric, out varchar, out boolean, out varchar, out integer) owner to postgres;


