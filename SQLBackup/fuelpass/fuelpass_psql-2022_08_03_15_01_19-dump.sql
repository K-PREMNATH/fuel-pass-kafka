--
-- PostgreSQL database dump
--

-- Dumped from database version 13.7
-- Dumped by pg_dump version 13.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: insert_order_detail(bigint, smallint, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_order_detail("pShedId" bigint, "pFuelType" smallint, "pCapacity" numeric, OUT "rReferenceNumber" character varying, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.insert_order_detail("pShedId" bigint, "pFuelType" smallint, "pCapacity" numeric, OUT "rReferenceNumber" character varying, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) OWNER TO postgres;

--
-- Name: update_fuel_allocation(smallint, numeric, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_fuel_allocation("pFuelTypeId" smallint, "pCapacity" numeric, "pReferenceNumber" character varying, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.update_fuel_allocation("pFuelTypeId" smallint, "pCapacity" numeric, "pReferenceNumber" character varying, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) OWNER TO postgres;

--
-- Name: update_order_history(bigint, character varying, bigint, smallint, numeric, smallint, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_order_history("pOrderDetailId" bigint, "pReferenceNumber" character varying, "pShedId" bigint, "pFuelType" smallint, "pCapacity" numeric, "pOrderStatus" smallint, "pCreatedOn" timestamp without time zone, "pUpdatedOn" timestamp without time zone, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.update_order_history("pOrderDetailId" bigint, "pReferenceNumber" character varying, "pShedId" bigint, "pFuelType" smallint, "pCapacity" numeric, "pOrderStatus" smallint, "pCreatedOn" timestamp without time zone, "pUpdatedOn" timestamp without time zone, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) OWNER TO postgres;

--
-- Name: update_order_status(character varying, smallint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_order_status("pReferenceNumber" character varying, "pOrderStatus" smallint, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.update_order_status("pReferenceNumber" character varying, "pOrderStatus" smallint, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) OWNER TO postgres;

--
-- Name: update_schedule_order(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_schedule_order("pReferenceNumber" character varying, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
    err_context    text;
    lScheduledDate varchar(50) := '';
    lCreatedOn     date;
BEGIN
    set datestyle = dmy;
    "Res" := true;
    "Msg" := '';
    "StatusCode" := 1000;

    select "CreatedOn" :: date
    into lCreatedOn
    from "Order"
    where "ReferenceNumber" = "pReferenceNumber";

    --RAISE NOTICE '1------------->%',lCreatedOn;
    lScheduledDate := lCreatedOn + (floor(random() * (7 - 1 + 1)) + 1)::integer;

    update "Order"
    set "ScheduledDate" = lScheduledDate
    where "ReferenceNumber" = "pReferenceNumber";

exception
    when others then
        GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        RAISE INFO 'Error Context:%', err_context;
        "Res" := false;
        "Msg" := 'Unable to update the scheduled date for the order...!';
        "StatusCode" := 1001;

        return;
END ;
$$;


ALTER FUNCTION public.update_schedule_order("pReferenceNumber" character varying, OUT "Res" boolean, OUT "Msg" character varying, OUT "StatusCode" integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: CorporationStock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CorporationStock" (
    "StockId" bigint NOT NULL,
    "FuelTypeId" smallint DEFAULT 0 NOT NULL,
    "Capacity" numeric DEFAULT 0.0 NOT NULL
);


ALTER TABLE public."CorporationStock" OWNER TO postgres;

--
-- Name: CorporationStock_StockId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."CorporationStock_StockId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."CorporationStock_StockId_seq" OWNER TO postgres;

--
-- Name: CorporationStock_StockId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."CorporationStock_StockId_seq" OWNED BY public."CorporationStock"."StockId";


--
-- Name: FuelType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FuelType" (
    "FuelTypeCode" smallint NOT NULL,
    "FuelTypeName" character varying(20) NOT NULL
);


ALTER TABLE public."FuelType" OWNER TO postgres;

--
-- Name: FuelType_FuelTypeCode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."FuelType_FuelTypeCode_seq"
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."FuelType_FuelTypeCode_seq" OWNER TO postgres;

--
-- Name: FuelType_FuelTypeCode_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."FuelType_FuelTypeCode_seq" OWNED BY public."FuelType"."FuelTypeCode";


--
-- Name: Order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Order" (
    "OrderDetailId" bigint NOT NULL,
    "ShedId" bigint NOT NULL,
    "Capacity" numeric DEFAULT 0.0 NOT NULL,
    "FuelType" smallint DEFAULT 0 NOT NULL,
    "CreatedOn" timestamp without time zone DEFAULT now() NOT NULL,
    "UpdatedOn" timestamp without time zone,
    "OrderStatus" smallint DEFAULT 0 NOT NULL,
    "ReferenceNumber" character varying(100) NOT NULL,
    "ScheduledDate" character varying
);


ALTER TABLE public."Order" OWNER TO postgres;

--
-- Name: OrderHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OrderHistory" (
    "OrderHistoryId" bigint NOT NULL,
    "ShedId" bigint NOT NULL,
    "OrderDetailId" bigint NOT NULL,
    "Capacity" numeric NOT NULL,
    "FuelType" smallint NOT NULL,
    "OrderStatus" smallint NOT NULL,
    "CreatedOn" timestamp without time zone,
    "ReferenceNumber" character varying(100),
    "OrderCreatedOn" timestamp without time zone,
    "OrderUpdatedOn" timestamp without time zone
);


ALTER TABLE public."OrderHistory" OWNER TO postgres;

--
-- Name: OrderHistory_OrderHistoryId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."OrderHistory_OrderHistoryId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."OrderHistory_OrderHistoryId_seq" OWNER TO postgres;

--
-- Name: OrderHistory_OrderHistoryId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."OrderHistory_OrderHistoryId_seq" OWNED BY public."OrderHistory"."OrderHistoryId";


--
-- Name: OrderStatus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OrderStatus" (
    "OrderStatusCode" smallint NOT NULL,
    "OrderStatusName" character varying(50) NOT NULL
);


ALTER TABLE public."OrderStatus" OWNER TO postgres;

--
-- Name: OrderStatus_OrderStatusCode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."OrderStatus_OrderStatusCode_seq"
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."OrderStatus_OrderStatusCode_seq" OWNER TO postgres;

--
-- Name: OrderStatus_OrderStatusCode_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."OrderStatus_OrderStatusCode_seq" OWNED BY public."OrderStatus"."OrderStatusCode";


--
-- Name: Order_OrderDetailId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Order_OrderDetailId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Order_OrderDetailId_seq" OWNER TO postgres;

--
-- Name: Order_OrderDetailId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Order_OrderDetailId_seq" OWNED BY public."Order"."OrderDetailId";


--
-- Name: ShedRegister; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ShedRegister" (
    "ShedId" bigint NOT NULL,
    "ShedCode" character varying(50) NOT NULL,
    "ShedName" character varying(50) NOT NULL
);


ALTER TABLE public."ShedRegister" OWNER TO postgres;

--
-- Name: ShedRegister_ShedId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ShedRegister_ShedId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ShedRegister_ShedId_seq" OWNER TO postgres;

--
-- Name: ShedRegister_ShedId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ShedRegister_ShedId_seq" OWNED BY public."ShedRegister"."ShedId";


--
-- Name: CorporationStock StockId; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CorporationStock" ALTER COLUMN "StockId" SET DEFAULT nextval('public."CorporationStock_StockId_seq"'::regclass);


--
-- Name: FuelType FuelTypeCode; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FuelType" ALTER COLUMN "FuelTypeCode" SET DEFAULT nextval('public."FuelType_FuelTypeCode_seq"'::regclass);


--
-- Name: Order OrderDetailId; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order" ALTER COLUMN "OrderDetailId" SET DEFAULT nextval('public."Order_OrderDetailId_seq"'::regclass);


--
-- Name: OrderHistory OrderHistoryId; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderHistory" ALTER COLUMN "OrderHistoryId" SET DEFAULT nextval('public."OrderHistory_OrderHistoryId_seq"'::regclass);


--
-- Name: OrderStatus OrderStatusCode; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderStatus" ALTER COLUMN "OrderStatusCode" SET DEFAULT nextval('public."OrderStatus_OrderStatusCode_seq"'::regclass);


--
-- Name: ShedRegister ShedId; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShedRegister" ALTER COLUMN "ShedId" SET DEFAULT nextval('public."ShedRegister_ShedId_seq"'::regclass);


--
-- Data for Name: CorporationStock; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."CorporationStock" ("StockId", "FuelTypeId", "Capacity") VALUES (4, 4, 3000);
INSERT INTO public."CorporationStock" ("StockId", "FuelTypeId", "Capacity") VALUES (2, 2, 4600);
INSERT INTO public."CorporationStock" ("StockId", "FuelTypeId", "Capacity") VALUES (1, 1, 2700);
INSERT INTO public."CorporationStock" ("StockId", "FuelTypeId", "Capacity") VALUES (3, 3, 1300.0);


--
-- Data for Name: FuelType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."FuelType" ("FuelTypeCode", "FuelTypeName") VALUES (1, 'Octane-92');
INSERT INTO public."FuelType" ("FuelTypeCode", "FuelTypeName") VALUES (2, 'Octane-95');
INSERT INTO public."FuelType" ("FuelTypeCode", "FuelTypeName") VALUES (3, 'Diesel-Auto');
INSERT INTO public."FuelType" ("FuelTypeCode", "FuelTypeName") VALUES (4, 'Diesel-Super');


--
-- Data for Name: Order; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Order" ("OrderDetailId", "ShedId", "Capacity", "FuelType", "CreatedOn", "UpdatedOn", "OrderStatus", "ReferenceNumber", "ScheduledDate") VALUES (7, 1, 3000, 1, '2022-08-02 16:03:25.704168', '2022-08-02 16:05:47.217187', 2, '45c07a4e-17a9-6018-d61f-5335444dde88', '');
INSERT INTO public."Order" ("OrderDetailId", "ShedId", "Capacity", "FuelType", "CreatedOn", "UpdatedOn", "OrderStatus", "ReferenceNumber", "ScheduledDate") VALUES (8, 2, 6700.0, 3, '2022-08-03 14:57:45.738051', '2022-08-03 14:57:47.059091', 2, 'd201b5b0-f394-9f1e-28ff-2daf2d3db130', NULL);


--
-- Data for Name: OrderHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."OrderHistory" ("OrderHistoryId", "ShedId", "OrderDetailId", "Capacity", "FuelType", "OrderStatus", "CreatedOn", "ReferenceNumber", "OrderCreatedOn", "OrderUpdatedOn") VALUES (16, 1, 7, 3000, 1, 1, '2022-08-02 16:05:47.217187', '45c07a4e-17a9-6018-d61f-5335444dde88', '2022-08-02 16:03:25.704168', NULL);
INSERT INTO public."OrderHistory" ("OrderHistoryId", "ShedId", "OrderDetailId", "Capacity", "FuelType", "OrderStatus", "CreatedOn", "ReferenceNumber", "OrderCreatedOn", "OrderUpdatedOn") VALUES (17, 2, 8, 6700.0, 3, 1, '2022-08-03 14:57:47.059091', 'd201b5b0-f394-9f1e-28ff-2daf2d3db130', '2022-08-03 14:57:45.738051', NULL);


--
-- Data for Name: OrderStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."OrderStatus" ("OrderStatusCode", "OrderStatusName") VALUES (1, 'Pending');
INSERT INTO public."OrderStatus" ("OrderStatusCode", "OrderStatusName") VALUES (2, 'Allocated');
INSERT INTO public."OrderStatus" ("OrderStatusCode", "OrderStatusName") VALUES (3, 'Scheduled');
INSERT INTO public."OrderStatus" ("OrderStatusCode", "OrderStatusName") VALUES (4, 'Dispatch');
INSERT INTO public."OrderStatus" ("OrderStatusCode", "OrderStatusName") VALUES (5, 'NotAllocated');


--
-- Data for Name: ShedRegister; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."ShedRegister" ("ShedId", "ShedCode", "ShedName") VALUES (1, 'Shed001', 'Shed-Col03');
INSERT INTO public."ShedRegister" ("ShedId", "ShedCode", "ShedName") VALUES (2, 'Shed002', 'Shed-Jaf01');


--
-- Name: CorporationStock_StockId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."CorporationStock_StockId_seq"', 4, true);


--
-- Name: FuelType_FuelTypeCode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."FuelType_FuelTypeCode_seq"', 1, false);


--
-- Name: OrderHistory_OrderHistoryId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OrderHistory_OrderHistoryId_seq"', 17, true);


--
-- Name: OrderStatus_OrderStatusCode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OrderStatus_OrderStatusCode_seq"', 1, false);


--
-- Name: Order_OrderDetailId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Order_OrderDetailId_seq"', 8, true);


--
-- Name: ShedRegister_ShedId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ShedRegister_ShedId_seq"', 2, true);


--
-- Name: CorporationStock corporationstock_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CorporationStock"
    ADD CONSTRAINT corporationstock_pk PRIMARY KEY ("StockId");


--
-- Name: FuelType fueltype_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FuelType"
    ADD CONSTRAINT fueltype_pk PRIMARY KEY ("FuelTypeCode");


--
-- Name: OrderHistory order_history_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderHistory"
    ADD CONSTRAINT order_history_pk PRIMARY KEY ("OrderHistoryId");


--
-- Name: Order order_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT order_pk PRIMARY KEY ("OrderDetailId");


--
-- Name: OrderStatus orderstatus_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderStatus"
    ADD CONSTRAINT orderstatus_pk PRIMARY KEY ("OrderStatusCode");


--
-- Name: ShedRegister shedregister_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShedRegister"
    ADD CONSTRAINT shedregister_pk PRIMARY KEY ("ShedId");


--
-- Name: corporationstock_fueltypeid_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX corporationstock_fueltypeid_uindex ON public."CorporationStock" USING btree ("FuelTypeId");


--
-- PostgreSQL database dump complete
--

