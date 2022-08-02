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
-- Data for Name: FuelType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."FuelType" ("FuelTypeCode", "FuelTypeName") FROM stdin;
1	Octane-92
2	Octane-95
3	Diesel-Auto
4	Diesel-Super
\.


--
-- Data for Name: Order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Order" ("OrderDetailId", "ShedId", "Capacity", "FuelType", "CreatedOn", "UpdatedOn", "OrderStatus", "ReferenceNumber") FROM stdin;
4	1	230.0	2	2022-08-02 18:51:26.651924	\N	1	2128c63c-e32d-6f3a-feef-6a602c7c19b2
5	2	3300.0	3	2022-08-02 18:55:00.345499	\N	1	7c1a9673-feef-a6f3-c55a-53c352daa3bf
6	2	6700.0	3	2022-08-02 18:56:06.070862	\N	1	cc89baf5-452b-cef6-2da7-240291023a43
\.


--
-- Data for Name: OrderHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OrderHistory" ("OrderHistoryId", "ShedId", "OrderDetailId", "Capacity", "FuelType", "OrderStatus", "CreatedOn", "ReferenceNumber", "OrderCreatedOn", "OrderUpdatedOn") FROM stdin;
3	1	3	3000	1	1	2022-08-02 07:58:50.113968	81a24ee4-7e13-2c7f-fa78-213f105c902c	2022-08-02 07:57:54.069232	\N
4	1	3	3000	1	2	2022-08-02 07:59:46.811192	81a24ee4-7e13-2c7f-fa78-213f105c902c	2022-08-02 07:57:54.069232	2022-08-02 07:58:50.113968
5	1	3	3000	1	3	2022-08-02 08:00:18.260708	81a24ee4-7e13-2c7f-fa78-213f105c902c	2022-08-02 07:57:54.069232	2022-08-02 07:59:46.811192
\.


--
-- Data for Name: OrderStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OrderStatus" ("OrderStatusCode", "OrderStatusName") FROM stdin;
1	Pending
2	Allocated
3	Scheduled
4	Dispatch
5	NotAllocated
\.


--
-- Data for Name: ShedRegister; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ShedRegister" ("ShedId", "ShedCode", "ShedName") FROM stdin;
1	Shed001	Shed-Col03
2	Shed002	Shed-Jaf01
\.


--
-- Name: FuelType_FuelTypeCode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."FuelType_FuelTypeCode_seq"', 1, false);


--
-- Name: OrderHistory_OrderHistoryId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OrderHistory_OrderHistoryId_seq"', 5, true);


--
-- Name: OrderStatus_OrderStatusCode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OrderStatus_OrderStatusCode_seq"', 1, false);


--
-- Name: Order_OrderDetailId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Order_OrderDetailId_seq"', 6, true);


--
-- Name: ShedRegister_ShedId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ShedRegister_ShedId_seq"', 2, true);


--
-- PostgreSQL database dump complete
--

