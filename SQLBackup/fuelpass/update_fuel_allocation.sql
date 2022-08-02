create function update_fuel_allocation("pFuelTypeId" smallint, "pCapacity" numeric, "pReferenceNumber" character varying, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) returns record
    language plpgsql
as
$$
DECLARE
    err_context text;
    lCount      integer := 0;
BEGIN
    "Res" := true;
    "Msg" := '';
    "StatusCode" := 0;

    Select count(*) ::integer
    into lCount
    from "CorporationStock" ord
    where ord."FuelTypeId" = "pFuelTypeId"
      and ord."Capacity" >= "pCapacity";

    RAISE NOTICE 'lCount : %', lCount;

    IF lCount = 0 THEN
        select status."Res",
               status."StatusCode",
               status."Msg"
        into
            "Res",
            "StatusCode",
            "Msg"
        from update_order_status("pReferenceNumber", 5::smallint) status;

        "Res" := false;
        "Msg" := 'There is no enough fuel capacity...!';
        "StatusCode" := 1006;
        return;
    ELSE
        select status."Res",
               status."StatusCode",
               status."Msg"
        into
            "Res",
            "StatusCode",
            "Msg"
        from update_order_status("pReferenceNumber", 2::smallint) status;

        update "CorporationStock" cs
        set "Capacity" = (cs."Capacity" - "pCapacity")
        where "FuelTypeId" = "pFuelTypeId";

        "Res" := false;
        "Msg" := 'Fuel allocated to the Shed...!';
        "StatusCode" := 1000;
        return;
    END IF;

exception
    when others then
        GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        RAISE INFO 'Error Context:%', err_context;
        "Res" := false;
        "Msg" := 'Unable to place the request...!';
        "StatusCode" := 1001;

        return;
END ;
$$;

alter function update_fuel_allocation(smallint, numeric, varchar, out boolean, out varchar, out integer) owner to postgres;


