    -- =============================================================================
    -- SAP MM REPLICA IN SNOWFLAKE
    -- Covers: MARA, MAKT, MARC, MARD, MCHB, MCH1, MCHA,
    --         MKPF, MSEG, T156, T156H, T156T,
    --         AUFK, AFKO, AFPO,
    --         T001W, T001L,
    --         EKKO, EKPO, EKET,
    --         VBAK, VBAP,
    --         LQUA (WM), CHVW (batch where-used)
    -- =============================================================================

    -- ─────────────────────────────────────────────────────────────
    -- SCHEMA
    -- ─────────────────────────────────────────────────────────────
    CREATE SCHEMA IF NOT EXISTS SAP_MM;
    USE SCHEMA SAP_MM;


    -- =============================================================================
    -- MASTER DATA TABLES
    -- =============================================================================

    -- -----------------------------------------------------------------------------
    -- T001W  Plant / Storage Location Master
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE T001W (
        WERKS       VARCHAR(4)    NOT NULL,   -- Plant
        NAME1       VARCHAR(30),              -- Plant Name
        LAND1       VARCHAR(3),               -- Country
        ORT01       VARCHAR(25),              -- City
        REGIO       VARCHAR(3),               -- Region/State
        STCD1       VARCHAR(16),              -- Tax Number
        PRIMARY KEY (WERKS)
    );

    INSERT INTO T001W VALUES
    ('1000', 'Mumbai Manufacturing Plant',   'IN', 'Mumbai',    'MH', 'IN27AAA1234A1Z5'),
    ('1100', 'Pune Assembly Plant',          'IN', 'Pune',      'MH', 'IN27BBB5678B2Y6'),
    ('1200', 'Chennai Distribution Center', 'IN', 'Chennai',   'TN', 'IN33CCC9012C3X7'),
    ('2000', 'Delhi Warehouse',             'IN', 'New Delhi', 'DL', 'IN07DDD3456D4W8'),
    ('2100', 'Bengaluru Tech Plant',        'IN', 'Bengaluru', 'KA', 'IN29EEE7890E5V9');


    -- -----------------------------------------------------------------------------
    -- T001L  Storage Locations
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE T001L (
        WERKS   VARCHAR(4)  NOT NULL,
        LGORT   VARCHAR(4)  NOT NULL,
        LGOBE   VARCHAR(160),                  -- Description
        PRIMARY KEY (WERKS, LGORT)
    );

    INSERT INTO T001L VALUES
    ('1000','0001','Raw Material Store'),
    ('1000','0002','Finished Goods Store'),
    ('1000','0003','WIP Store'),
    ('1000','0004','Rejection Store'),
    ('1000','0005','Spare Parts Store'),
    ('1100','0001','Raw Material Store'),
    ('1100','0002','Finished Goods Store'),
    ('1100','0003','WIP Store'),
    ('1200','0001','Distribution Store'),
    ('1200','0002','Returns Store'),
    ('2000','0001','Main Warehouse'),
    ('2000','0002','Cold Storage'),
    ('2100','0001','Component Store'),
    ('2100','0002','Finished Goods Store');


    -- -----------------------------------------------------------------------------
    -- MARA  General Material Master
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE MARA (
        MATNR       VARCHAR(18)   NOT NULL,   -- Material Number
        MBRSH       VARCHAR(1),               -- Industry Sector  (M=Mech, C=Chem, F=Food)
        MTART       VARCHAR(4),               -- Material Type (ROH=Raw,HALB=Semi,FERT=Finished,ERSA=Spare)
        MATKL       VARCHAR(9),               -- Material Group
        MEINS       VARCHAR(3),               -- Base Unit of Measure
        BRGEW       NUMBER(13,3),             -- Gross Weight
        NTGEW       NUMBER(13,3),             -- Net Weight
        GEWEI       VARCHAR(3),               -- Weight Unit
        VOLUM       NUMBER(13,3),             -- Volume
        VOLEH       VARCHAR(3),               -- Volume Unit
        NORMT       VARCHAR(18),              -- Material Standard
        ZEINR       VARCHAR(22),              -- Drawing Number
        XCHPF       VARCHAR(1),               -- Batch Management (X=Yes, blank=No)
        MHDRZ       NUMBER(4,0),              -- Min remaining shelf life (days)
        MHDLP       NUMBER(4,0),              -- Total shelf life (days)
        IPRKZ       VARCHAR(1),               -- Period indicator for shelf life
        ERSDA       DATE,                     -- Created On
        LAEDA       DATE,                     -- Last Changed
        ERNAM       VARCHAR(12),              -- Created By
        PRIMARY KEY (MATNR)
    );

    INSERT INTO MARA VALUES
    -- ── RAW MATERIALS (batch-managed chemicals / ingredients) ──
    ('RM-STEEL-001',  'M','ROH','RM-METAL', 'KG',  50.000, 48.000,'KG', 6.500,'L3', NULL, 'DWG-S001','',   NULL,NULL,NULL,'2022-01-10','2024-06-01','ADMIN'),
    ('RM-ALUM-002',   'M','ROH','RM-METAL', 'KG',  10.000,  9.800,'KG', 3.700,'L3', NULL, 'DWG-A002','',   NULL,NULL,NULL,'2022-01-15','2024-06-01','ADMIN'),
    ('RM-RESIN-003',  'C','ROH','RM-CHEM',  'KG',  25.000, 24.500,'KG', 22.000,'L3',NULL, 'DWG-R003','X',  180, 365, 'M','2022-02-01','2024-07-01','ADMIN'),
    ('RM-PAINT-004',  'C','ROH','RM-CHEM',  'L',    5.000,  4.900,'KG',  5.000,'L3',NULL, 'DWG-P004','X',   90, 180, 'M','2022-02-05','2024-07-01','ADMIN'),
    ('RM-RUBBER-005', 'C','ROH','RM-CHEM',  'KG',  15.000, 14.500,'KG', 12.000,'L3',NULL, 'DWG-RB05','X',  365, 730, 'M','2022-03-01','2024-07-15','ADMIN'),
    ('RM-COPPER-006', 'M','ROH','RM-METAL', 'KG',   8.900,  8.700,'KG',  1.000,'L3',NULL, 'DWG-C006','',   NULL,NULL,NULL,'2022-03-10','2024-07-15','ADMIN'),
    ('RM-OIL-007',    'C','ROH','RM-CHEM',  'L',    0.900,  0.850,'KG',  1.000,'L3',NULL, 'DWG-O007','X',   60, 120, 'M','2022-04-01','2024-08-01','ADMIN'),
    -- ── SEMI-FINISHED (some batch, some not) ──
    ('SF-FRAME-010',  'M','HALB','SF-MECH', 'EA',  12.000, 11.500,'KG', 45.000,'L3','ISO9001','DWG-F010','',   NULL,NULL,NULL,'2022-05-01','2024-06-15','ADMIN'),
    ('SF-GEAR-011',   'M','HALB','SF-MECH', 'EA',   2.500,  2.400,'KG',  0.800,'L3','ISO9001','DWG-G011','',   NULL,NULL,NULL,'2022-05-10','2024-06-15','ADMIN'),
    ('SF-COIL-012',   'M','HALB','SF-ELEC', 'EA',   0.800,  0.750,'KG',  0.200,'L3', NULL, 'DWG-C012','X',  NULL,NULL,NULL,'2022-06-01','2024-07-01','ADMIN'),
    ('SF-PANEL-013',  'M','HALB','SF-ELEC', 'EA',   5.000,  4.800,'KG',  8.000,'L3', NULL, 'DWG-P013','',   NULL,NULL,NULL,'2022-06-15','2024-07-01','ADMIN'),
    -- ── FINISHED GOODS ──
    ('FG-MOTOR-020',  'M','FERT','FG-MACH', 'EA',  45.000, 43.000,'KG', 60.000,'L3','ISO9001','DWG-M020','X',  NULL,NULL,NULL,'2022-07-01','2024-08-01','ADMIN'),
    ('FG-PUMP-021',   'M','FERT','FG-MACH', 'EA',  32.000, 30.500,'KG', 42.000,'L3','ISO9001','DWG-P021','X',  NULL,NULL,NULL,'2022-07-15','2024-08-01','ADMIN'),
    ('FG-VALVE-022',  'M','FERT','FG-MACH', 'EA',   8.500,  8.200,'KG', 10.000,'L3','ISO9001','DWG-V022','',   NULL,NULL,NULL,'2022-08-01','2024-08-15','ADMIN'),
    ('FG-SENSOR-023', 'M','FERT','FG-ELEC', 'EA',   0.350,  0.320,'KG',  0.500,'L3', NULL, 'DWG-S023','X',  NULL,NULL,NULL,'2022-08-15','2024-08-15','ADMIN'),
    -- ── SPARE PARTS ──
    ('SP-BEARING-030','M','ERSA','SP-MECH', 'EA',   0.500,  0.480,'KG',  0.100,'L3', NULL, 'DWG-B030','',   NULL,NULL,NULL,'2022-09-01','2024-09-01','ADMIN'),
    ('SP-SEAL-031',   'C','ERSA','SP-SEAL', 'EA',   0.050,  0.045,'KG',  0.010,'L3', NULL, 'DWG-S031','X',  365,1095, 'M','2022-09-10','2024-09-01','ADMIN'),
    ('SP-FILTER-032', 'C','ERSA','SP-FILT', 'EA',   0.200,  0.180,'KG',  0.300,'L3', NULL, 'DWG-F032','X',  180, 720, 'M','2022-09-15','2024-09-15','ADMIN');


    -- -----------------------------------------------------------------------------
    -- MAKT  Material Descriptions
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE MAKT (
        MATNR   VARCHAR(18) NOT NULL,
        SPRAS   VARCHAR(1)  NOT NULL,         -- Language (E=English, D=German, H=Hindi)
        MAKTX   VARCHAR(40),                  -- Short Description
        PRIMARY KEY (MATNR, SPRAS)
    );

    INSERT INTO MAKT VALUES
    ('RM-STEEL-001', 'E','Hot Rolled Steel Coil - Grade S235'),
    ('RM-ALUM-002',  'E','Aluminium Extrusion Profile - 6061-T6'),
    ('RM-RESIN-003', 'E','Epoxy Resin - Industrial Grade A'),
    ('RM-PAINT-004', 'E','Anti-Corrosion Primer Paint - Grey'),
    ('RM-RUBBER-005','E','Nitrile Rubber Compound - 70 Shore'),
    ('RM-COPPER-006','E','Copper Bus Bar - 99.9% Pure'),
    ('RM-OIL-007',   'E','Cutting Oil - ISO VG 46'),
    ('SF-FRAME-010', 'E','Welded Steel Motor Frame Assembly'),
    ('SF-GEAR-011',  'E','Helical Gear Set - Module 4'),
    ('SF-COIL-012',  'E','Copper Wound Stator Coil - 3kW'),
    ('SF-PANEL-013', 'E','Control Panel Sub-Assembly'),
    ('FG-MOTOR-020', 'E','3-Phase Induction Motor - 5HP 415V'),
    ('FG-PUMP-021',  'E','Centrifugal Water Pump - 2 inch'),
    ('FG-VALVE-022', 'E','Ball Valve - SS316 - 1 inch PN40'),
    ('FG-SENSOR-023','E','Industrial Pressure Sensor 0-10 bar'),
    ('SP-BEARING-030','E','Deep Groove Ball Bearing 6205-2RS'),
    ('SP-SEAL-031',  'E','O-Ring Seal Kit - NBR - Assorted'),
    ('SP-FILTER-032','E','Oil Filter Cartridge - 10 Micron');


    -- -----------------------------------------------------------------------------
    -- MARC  Plant-level Material Data
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE MARC (
        MATNR   VARCHAR(18) NOT NULL,
        WERKS   VARCHAR(4)  NOT NULL,
        DISMM   VARCHAR(2),                   -- MRP Type
        DISPO   VARCHAR(3),                   -- MRP Controller
        EKGRP   VARCHAR(3),                   -- Purchasing Group
        BESKZ   VARCHAR(1),                   -- Procurement Type (E=In-house, F=External, X=Both)
        SONDERB VARCHAR(2),                   -- Special procurement
        MINBE   NUMBER(13,3),                 -- Reorder Point
        EISBE   NUMBER(13,3),                 -- Safety Stock
        MABST   NUMBER(13,3),                 -- Max Stock Level
        LGPRO   VARCHAR(4),                   -- Issue Storage Location
        LGFSB   VARCHAR(4),                   -- Default Storage Location
        PRIMARY KEY (MATNR, WERKS)
    );

    INSERT INTO MARC VALUES
    ('RM-STEEL-001', '1000','PD','M01','PG1','F',NULL, 500.000,200.000,5000.000,'0001','0001'),
    ('RM-ALUM-002',  '1000','PD','M01','PG1','F',NULL, 100.000, 50.000,2000.000,'0001','0001'),
    ('RM-RESIN-003', '1000','PD','M01','PG2','F',NULL,  50.000, 20.000, 500.000,'0001','0001'),
    ('RM-PAINT-004', '1000','PD','M01','PG2','F',NULL,  20.000, 10.000, 200.000,'0001','0001'),
    ('RM-RUBBER-005','1000','PD','M01','PG2','F',NULL,  30.000, 15.000, 300.000,'0001','0001'),
    ('RM-COPPER-006','1000','PD','M01','PG1','F',NULL,  50.000, 20.000, 500.000,'0001','0001'),
    ('RM-OIL-007',   '1000','PD','M01','PG2','F',NULL,  10.000,  5.000, 100.000,'0001','0001'),
    ('SF-FRAME-010', '1000','PD','M02','PG1','E',NULL,  10.000,  5.000, 100.000,'0003','0003'),
    ('SF-GEAR-011',  '1000','PD','M02','PG1','E',NULL,  20.000, 10.000, 200.000,'0003','0003'),
    ('SF-COIL-012',  '1000','PD','M02','PG1','E',NULL,  15.000,  5.000, 150.000,'0003','0003'),
    ('SF-PANEL-013', '1100','PD','M02','PG1','E',NULL,   5.000,  2.000,  50.000,'0003','0003'),
    ('FG-MOTOR-020', '1000','PD','M03','PG1','E',NULL,   5.000,  2.000,  50.000,'0002','0002'),
    ('FG-MOTOR-020', '1100','PD','M03','PG1','E',NULL,   3.000,  1.000,  30.000,'0002','0002'),
    ('FG-PUMP-021',  '1000','PD','M03','PG1','E',NULL,   5.000,  2.000,  50.000,'0002','0002'),
    ('FG-VALVE-022', '1200','PD','M03','PG1','F',NULL,  50.000, 20.000, 500.000,'0001','0001'),
    ('FG-SENSOR-023','1100','PD','M03','PG1','E',NULL,  10.000,  5.000, 100.000,'0002','0002'),
    ('SP-BEARING-030','2000','VM','M04','PG3','F',NULL, 100.000, 50.000,1000.000,'0001','0001'),
    ('SP-SEAL-031',  '2000','VM','M04','PG3','F',NULL, 200.000,100.000,2000.000,'0001','0001'),
    ('SP-FILTER-032','2000','VM','M04','PG3','F',NULL,  50.000, 25.000, 500.000,'0001','0001');


    -- -----------------------------------------------------------------------------
    -- MARD  Storage Location Stock
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE MARD (
        MATNR   VARCHAR(18) NOT NULL,
        WERKS   VARCHAR(4)  NOT NULL,
        LGORT   VARCHAR(4)  NOT NULL,
        LABST   NUMBER(13,3),                 -- Unrestricted Stock
        UMLME   NUMBER(13,3),                 -- Stock in Transfer
        INSME   NUMBER(13,3),                 -- Quality Inspection Stock
        EINME   NUMBER(13,3),                 -- Restricted-use Stock
        SPEME   NUMBER(13,3),                 -- Blocked Stock
        PRIMARY KEY (MATNR, WERKS, LGORT)
    );

    INSERT INTO MARD VALUES
    ('RM-STEEL-001', '1000','0001',1250.000,  0.000,200.000,0.000,  0.000),
    ('RM-ALUM-002',  '1000','0001', 320.000,  0.000, 50.000,0.000,  0.000),
    ('RM-RESIN-003', '1000','0001', 180.000,  0.000, 20.000,0.000,  5.000),
    ('RM-PAINT-004', '1000','0001',  75.000,  0.000,  0.000,0.000,  0.000),
    ('RM-RUBBER-005','1000','0001', 120.000,  0.000,  0.000,0.000,  0.000),
    ('RM-COPPER-006','1000','0001', 185.000, 50.000,  0.000,0.000,  0.000),
    ('RM-OIL-007',   '1000','0001',  45.000,  0.000,  0.000,0.000,  0.000),
    ('SF-FRAME-010', '1000','0003',  28.000,  5.000,  0.000,0.000,  0.000),
    ('SF-GEAR-011',  '1000','0003',  65.000,  0.000,  0.000,0.000,  0.000),
    ('SF-COIL-012',  '1000','0003',  40.000,  0.000, 10.000,0.000,  0.000),
    ('SF-PANEL-013', '1100','0003',  15.000,  0.000,  0.000,0.000,  0.000),
    ('FG-MOTOR-020', '1000','0002',  12.000,  0.000,  0.000,0.000,  0.000),
    ('FG-MOTOR-020', '1100','0002',   8.000,  0.000,  0.000,0.000,  0.000),
    ('FG-PUMP-021',  '1000','0002',  18.000,  0.000,  0.000,0.000,  0.000),
    ('FG-VALVE-022', '1200','0001', 350.000,  0.000,  0.000,0.000,  0.000),
    ('FG-SENSOR-023','1100','0002',  22.000,  0.000,  5.000,0.000,  0.000),
    ('SP-BEARING-030','2000','0001',450.000,  0.000,  0.000,0.000,  0.000),
    ('SP-SEAL-031',  '2000','0001',820.000,  0.000,  0.000,0.000,  0.000),
    ('SP-FILTER-032','2000','0001',180.000,  0.000,  0.000,0.000,  0.000);


    -- -----------------------------------------------------------------------------
    -- MCH1  Batch Master (cross-plant)
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE MCH1 (
        MATNR   VARCHAR(18) NOT NULL,
        CHARG   VARCHAR(100) NOT NULL,         -- Batch Number
        LICHN   VARCHAR(20),                  -- Vendor Batch Number
        VFDAT   DATE,                         -- Shelf Life Expiration Date
        HSDAT   DATE,                         -- Manufacturing Date
        LWEDT   DATE,                         -- Last Goods Receipt Date
        ZUSTD   VARCHAR(1),                   -- Batch Status (0=Unrestricted,1=Restricted,2=Blocked)
        KULAB   NUMBER(13,3),                 -- Unrestricted Stock (batch level)
        EINME   NUMBER(13,3),                 -- Restricted Stock
        PRIMARY KEY (MATNR, CHARG)
    );

    INSERT INTO MCH1 VALUES
    -- RM-RESIN-003 batches
    ('RM-RESIN-003', 'RESIN-2024-001','VB-R-9901','2025-03-31','2024-09-30','2024-10-05','0',80.000, 0.000),
    ('RM-RESIN-003', 'RESIN-2024-002','VB-R-9902','2025-06-30','2024-12-31','2025-01-08','0',80.000, 0.000),
    ('RM-RESIN-003', 'RESIN-2024-003','VB-R-9903','2024-11-30','2024-05-31','2024-06-03','1',20.000, 0.000), -- nearing expiry
    -- RM-PAINT-004 batches
    ('RM-PAINT-004', 'PAINT-2024-A01','VP-P-1101','2025-01-31','2024-07-31','2024-08-10','0',45.000, 0.000),
    ('RM-PAINT-004', 'PAINT-2024-A02','VP-P-1102','2025-04-30','2024-10-31','2024-11-05','0',30.000, 0.000),
    -- RM-RUBBER-005 batches
    ('RM-RUBBER-005','RBBR-2024-B01','VRB-001','2026-03-31','2024-03-31','2024-04-08','0',60.000, 0.000),
    ('RM-RUBBER-005','RBBR-2024-B02','VRB-002','2026-09-30','2024-09-30','2024-10-10','0',60.000, 0.000),
    -- RM-OIL-007 batches
    ('RM-OIL-007',   'OIL-2024-C01', 'VO-001','2025-02-28','2024-08-31','2024-09-02','0',25.000, 0.000),
    ('RM-OIL-007',   'OIL-2024-C02', 'VO-002','2025-05-31','2024-11-30','2024-12-01','0',20.000, 0.000),
    -- SF-COIL-012 batches (semi-finished)
    ('SF-COIL-012',  'COIL-WO-0010', NULL,    NULL,         '2024-11-15',NULL,        '0',20.000, 0.000),
    ('SF-COIL-012',  'COIL-WO-0011', NULL,    NULL,         '2024-12-20',NULL,        '0',20.000,10.000),
    -- FG-MOTOR-020 batches (finished goods serial/batch traceability)
    ('FG-MOTOR-020', 'MTR-2024-D01', NULL,    NULL,         '2024-11-20',NULL,        '0', 6.000, 0.000),
    ('FG-MOTOR-020', 'MTR-2024-D02', NULL,    NULL,         '2024-12-15',NULL,        '0', 6.000, 0.000),
    -- FG-PUMP-021 batches
    ('FG-PUMP-021',  'PMP-2024-E01', NULL,    NULL,         '2024-10-10',NULL,        '0', 9.000, 0.000),
    ('FG-PUMP-021',  'PMP-2024-E02', NULL,    NULL,         '2024-12-05',NULL,        '0', 9.000, 0.000),
    -- FG-SENSOR-023 batches
    ('FG-SENSOR-023','SNS-2024-F01', NULL,    NULL,         '2024-11-01',NULL,        '0',10.000, 0.000),
    ('FG-SENSOR-023','SNS-2024-F02', NULL,    NULL,         '2024-12-20',NULL,        '0',10.000, 5.000),
    -- SP-SEAL-031 batches
    ('SP-SEAL-031',  'SEAL-2023-G01','VS-301','2026-09-30','2023-09-30','2023-10-15','0',400.000,0.000),
    ('SP-SEAL-031',  'SEAL-2024-G02','VS-302','2027-03-31','2024-03-31','2024-04-05','0',420.000,0.000),
    -- SP-FILTER-032 batches
    ('SP-FILTER-032','FILT-2024-H01','VF-201','2025-09-30','2024-03-31','2024-04-10','0', 90.000,0.000),
    ('SP-FILTER-032','FILT-2024-H02','VF-202','2026-03-31','2024-09-30','2024-10-08','0', 90.000,0.000);


    -- -----------------------------------------------------------------------------
    -- MCHA  Batch Stock per Plant/Sloc
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE MCHA (
        MATNR   VARCHAR(18) NOT NULL,
        WERKS   VARCHAR(4)  NOT NULL,
        CHARG   VARCHAR(100) NOT NULL,
        LGORT   VARCHAR(4)  NOT NULL,
        LABST   NUMBER(13,3),                 -- Unrestricted
        INSME   NUMBER(13,3),                 -- Quality Inspection
        EINME   NUMBER(13,3),                 -- Restricted
        SPEME   NUMBER(13,3),                 -- Blocked
        PRIMARY KEY (MATNR, WERKS, CHARG, LGORT)
    );

    INSERT INTO MCHA VALUES
    ('RM-RESIN-003', '1000','RESIN-2024-001','0001',80.000, 0.000, 0.000,0.000),
    ('RM-RESIN-003', '1000','RESIN-2024-002','0001',80.000, 0.000, 0.000,0.000),
    ('RM-RESIN-003', '1000','RESIN-2024-003','0001', 0.000,20.000, 0.000,0.000), -- in QI
    ('RM-PAINT-004', '1000','PAINT-2024-A01','0001',45.000, 0.000, 0.000,0.000),
    ('RM-PAINT-004', '1000','PAINT-2024-A02','0001',30.000, 0.000, 0.000,0.000),
    ('RM-RUBBER-005','1000','RBBR-2024-B01', '0001',60.000, 0.000, 0.000,0.000),
    ('RM-RUBBER-005','1000','RBBR-2024-B02', '0001',60.000, 0.000, 0.000,0.000),
    ('RM-OIL-007',   '1000','OIL-2024-C01',  '0001',25.000, 0.000, 0.000,0.000),
    ('RM-OIL-007',   '1000','OIL-2024-C02',  '0001',20.000, 0.000, 0.000,0.000),
    ('SF-COIL-012',  '1000','COIL-WO-0010',  '0003',20.000, 0.000, 0.000,0.000),
    ('SF-COIL-012',  '1000','COIL-WO-0011',  '0003',20.000,10.000, 0.000,0.000),
    ('FG-MOTOR-020', '1000','MTR-2024-D01',  '0002', 6.000, 0.000, 0.000,0.000),
    ('FG-MOTOR-020', '1000','MTR-2024-D02',  '0002', 6.000, 0.000, 0.000,0.000),
    ('FG-PUMP-021',  '1000','PMP-2024-E01',  '0002', 9.000, 0.000, 0.000,0.000),
    ('FG-PUMP-021',  '1000','PMP-2024-E02',  '0002', 9.000, 0.000, 0.000,0.000),
    ('FG-SENSOR-023','1100','SNS-2024-F01',  '0002',10.000, 0.000, 0.000,0.000),
    ('FG-SENSOR-023','1100','SNS-2024-F02',  '0002', 0.000, 5.000, 0.000,0.000), -- in QI
    ('SP-SEAL-031',  '2000','SEAL-2023-G01', '0001',400.000,0.000, 0.000,0.000),
    ('SP-SEAL-031',  '2000','SEAL-2024-G02', '0001',420.000,0.000, 0.000,0.000),
    ('SP-FILTER-032','2000','FILT-2024-H01', '0001', 90.000,0.000, 0.000,0.000),
    ('SP-FILTER-032','2000','FILT-2024-H02', '0001', 90.000,0.000, 0.000,0.000);


    -- =============================================================================
    -- MOVEMENT TYPE CONFIGURATION TABLES
    -- =============================================================================

    -- -----------------------------------------------------------------------------
    -- T156  Movement Types
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE T156 (
        BWART   VARCHAR(3)  NOT NULL,         -- Movement Type
        KZBEW   VARCHAR(1),                   -- Goods movement indicator
        KZZUG   VARCHAR(1),                   -- Indicator: receipt (S=Stock, space=other)
        KZABG   VARCHAR(1),                   -- Indicator: issue
        SHKZG   VARCHAR(1),                   -- Debit/Credit indicator (S=Debit, H=Credit)
        PRIMARY KEY (BWART)
    );

    INSERT INTO T156 VALUES
    ('101','B','S','','S'),  -- GR for PO - Unrestricted
    ('102','B','','S','H'),  -- Reversal GR for PO
    ('103','B','S','','S'),  -- GR for PO into GR blocked stock
    ('105','B','S','','S'),  -- GR from GR blocked to unrestricted
    ('121','B','','S','H'),  -- Subsequent adjustment for subcontract
    ('122','B','','S','H'),  -- Return to vendor
    ('123','B','S','','S'),  -- Reversal of 122
    ('201','W','','S','H'),  -- GI for cost centre
    ('202','W','S','','S'),  -- Reversal GI cost centre
    ('261','W','','S','H'),  -- GI for production order
    ('262','W','S','','S'),  -- Reversal GI for production order
    ('301','U','','','S'),   -- Transfer plant to plant (1-step)
    ('303','U','','S','H'),  -- Transfer plant to plant (2-step send)
    ('305','U','S','','S'),  -- Transfer plant to plant (2-step receive)
    ('309','K','','S','H'),  -- Transfer to different material
    ('311','U','','S','H'),  -- Transfer within plant (sloc to sloc)
    ('312','U','S','','S'),  -- Reversal 311
    ('315','U','','S','H'),  -- Transfer to QI
    ('321','Q','S','','S'),  -- QI to unrestricted
    ('322','Q','','S','H'),  -- Unrestricted to QI
    ('323','Q','','S','H'),  -- QI to blocked
    ('324','Q','S','','S'),  -- Blocked to QI
    ('343','K','','S','H'),  -- Transfer to blocked
    ('344','K','S','','S'),  -- Reversal to unrestricted from blocked
    ('501','E','S','','S'),  -- Receipt without PO - unrestricted
    ('502','E','','S','H'),  -- Reversal 501
    ('551','W','','S','H'),  -- Scrapping/write-off
    ('552','W','S','','S'),  -- Reversal scrapping
    ('601','A','','S','H'),  -- GI for delivery (sales)
    ('602','A','S','','S'),  -- Reversal GI for delivery
    ('641','A','','S','H'),  -- GI for stock transfer (STO)
    ('643','A','','S','H'),  -- GI subcontracting
    ('701','I','S','','S'),  -- Inventory counting adjustment (+)
    ('702','I','','S','H'),  -- Inventory counting adjustment (-)
    ('901','Z','S','','S'),  -- Opening stock entry
    ('961','P','S','','S');  -- GR from production order (101 analogue for WO)


    -- -----------------------------------------------------------------------------
    -- T156H  Movement Type Help Texts / Descriptions
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE T156H (
        BWART   VARCHAR(3)  NOT NULL,
        SPRAS   VARCHAR(1)  NOT NULL,
        BWTXT   VARCHAR(140),                  -- Movement Type Description
        PRIMARY KEY (BWART, SPRAS)
    );

    INSERT INTO T156H VALUES
    ('101','E','GR for Purchase Order - Unrestricted Stock'),
    ('102','E','Reversal of GR for Purchase Order'),
    ('103','E','GR for PO into GR-Blocked Stock'),
    ('105','E','Release GR-Blocked Stock to Unrestricted'),
    ('121','E','Subsequent Adjustment (Subcontracting)'),
    ('122','E','Return Delivery to Vendor'),
    ('123','E','Reversal of Return to Vendor'),
    ('201','E','Goods Issue to Cost Centre'),
    ('202','E','Reversal of GI to Cost Centre'),
    ('261','E','Goods Issue for Production Order'),
    ('262','E','Reversal of GI for Production Order'),
    ('301','E','Transfer Posting Plant-to-Plant (1-step)'),
    ('303','E','Transfer Posting Plant-to-Plant - Send'),
    ('305','E','Transfer Posting Plant-to-Plant - Receive'),
    ('309','E','Transfer Posting to Different Material'),
    ('311','E','Transfer Posting SLoc-to-SLoc (Same Plant)'),
    ('312','E','Reversal of SLoc-to-SLoc Transfer'),
    ('315','E','Transfer Posting to Quality Inspection'),
    ('321','E','Quality Inspection to Unrestricted Stock'),
    ('322','E','Unrestricted Stock to Quality Inspection'),
    ('323','E','Quality Inspection to Blocked Stock'),
    ('324','E','Blocked Stock to Quality Inspection'),
    ('343','E','Transfer Posting to Blocked Stock'),
    ('344','E','Reversal: Blocked Stock to Unrestricted'),
    ('501','E','Receipt without Purchase Order (Unrest.)'),
    ('502','E','Reversal of Receipt w/o Purchase Order'),
    ('551','E','Scrapping / Write-off from Unrestricted'),
    ('552','E','Reversal of Scrapping'),
    ('601','E','Goods Issue for Customer Delivery'),
    ('602','E','Reversal of GI for Delivery'),
    ('641','E','GI for Stock Transfer Order (STO)'),
    ('643','E','GI for Subcontracting Order'),
    ('701','E','Physical Inventory Count - Stock Increase'),
    ('702','E','Physical Inventory Count - Stock Decrease'),
    ('901','E','Opening Stock Balance Entry'),
    ('961','E','GR from Production / Work Order');


    -- -----------------------------------------------------------------------------
    -- T156T  Extended movement description / account assignment texts
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE T156T (
        BWART   VARCHAR(3)  NOT NULL,
        SPRAS   VARCHAR(1)  NOT NULL,
        BDTEXT  VARCHAR,                  -- Long description
        PRIMARY KEY (BWART, SPRAS)
    );

    INSERT INTO T156T VALUES
    ('101','E','Goods receipt from external vendor against an approved purchase order. Increases unrestricted stock.'),
    ('261','E','Raw material or semi-finished goods consumed against a work order / production order on the shop floor.'),
    ('961','E','Finished or semi-finished goods produced from a work order posted into unrestricted or batch-restricted stock.'),
    ('601','E','Goods issue against a sales delivery document. Reduces unrestricted finished goods stock.'),
    ('311','E','Internal stock transfer between two storage locations within the same plant, no valuation change.'),
    ('321','E','Batch released after quality inspection passes. Moves stock from QI to unrestricted.'),
    ('551','E','Material scrapped due to damage, expiry, or quality rejection. Stock reduced and cost posted to scrap account.'),
    ('301','E','Stock transferred from one plant to another in a single posting step with simultaneous GI and GR.'),
    ('122','E','Defective or excess goods returned to the supplying vendor with a return delivery note.');


    -- =============================================================================
    -- PURCHASING TABLES
    -- =============================================================================

    -- -----------------------------------------------------------------------------
    -- EKKO  Purchase Order Header
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE EKKO (
        EBELN   VARCHAR(10)  NOT NULL,        -- PO Number
        BSTYP   VARCHAR(1),                   -- PO Category (F=PO, K=Contract, L=SA)
        BSART   VARCHAR(4),                   -- PO Type
        LIFNR   VARCHAR(10),                  -- Vendor
        EKGRP   VARCHAR(3),                   -- Purchasing Group
        BUKRS   VARCHAR(4),                   -- Company Code
        WERKS   VARCHAR(4),                   -- Plant
        BEDAT   DATE,                         -- PO Date
        KDATB   DATE,                         -- Validity Start
        KDATE   DATE,                         -- Validity End
        WAERS   VARCHAR(5),                   -- Currency
        ZTERM   VARCHAR(4),                   -- Payment Terms
        INCO1   VARCHAR(3),                   -- Incoterms
        ERNAM   VARCHAR(12),                  -- Created By
        AEDAT   DATE,                         -- Last Changed
        PRIMARY KEY (EBELN)
    );

    INSERT INTO EKKO VALUES
    ('4500000101','F','NB','VEND-001','PG1','1000','1000','2024-09-01',NULL,NULL,'INR','N030','EXW','BUYER1','2024-09-01'),
    ('4500000102','F','NB','VEND-002','PG2','1000','1000','2024-10-15',NULL,NULL,'INR','N030','CIF','BUYER1','2024-10-15'),
    ('4500000103','F','NB','VEND-001','PG1','1000','1000','2024-11-01',NULL,NULL,'INR','N060','EXW','BUYER2','2024-11-01'),
    ('4500000104','F','NB','VEND-003','PG3','1000','2000','2024-11-15',NULL,NULL,'INR','N030','FOB','BUYER2','2024-11-15'),
    ('4500000105','F','NB','VEND-002','PG2','1000','1000','2024-12-01',NULL,NULL,'INR','N030','CIF','BUYER1','2024-12-01'),
    ('4500000106','F','UB','VEND-004','PG1','1000','1100','2024-12-10',NULL,NULL,'INR','N000','EXW','BUYER3','2024-12-10');-- STO


    -- -----------------------------------------------------------------------------
    -- EKPO  Purchase Order Items
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE EKPO (
        EBELN   VARCHAR(10) NOT NULL,
        EBELP   VARCHAR(5)  NOT NULL,         -- PO Item
        MATNR   VARCHAR(18),
        TXZ01   VARCHAR(40),                  -- Short Text
        WERKS   VARCHAR(4),
        LGORT   VARCHAR(4),
        MENGE   NUMBER(13,3),                 -- PO Qty
        MEINS   VARCHAR(3),
        NETPR   NUMBER(11,2),                 -- Net Price
        WAERS   VARCHAR(5),
        EINDT   DATE,                         -- Delivery Date
        WEMNG   NUMBER(13,3),                 -- GR Qty so far
        ELIKZ   VARCHAR(1),                   -- Delivery completed
        LOEKZ   VARCHAR(1),                   -- Deletion indicator
        PRIMARY KEY (EBELN, EBELP)
    );

    INSERT INTO EKPO VALUES
    ('4500000101','00010','RM-STEEL-001','Hot Rolled Steel Coil','1000','0001',2000.000,'KG',72.50,'INR','2024-09-20',2000.000,'X',''),
    ('4500000101','00020','RM-ALUM-002', 'Aluminium Profile 6061','1000','0001', 500.000,'KG',245.00,'INR','2024-09-20',500.000,'X',''),
    ('4500000102','00010','RM-RESIN-003','Epoxy Resin Ind. Grade','1000','0001', 200.000,'KG',380.00,'INR','2024-11-01',200.000,'X',''),
    ('4500000102','00020','RM-PAINT-004','Anti-Corrosion Primer', '1000','0001', 100.000,'L',  520.00,'INR','2024-11-01', 75.000,'',''),
    ('4500000103','00010','RM-STEEL-001','Hot Rolled Steel Coil','1000','0001',1000.000,'KG', 74.00,'INR','2024-11-25',1000.000,'X',''),
    ('4500000103','00020','RM-COPPER-006','Copper Bus Bar 99.9%','1000','0001', 200.000,'KG',650.00,'INR','2024-11-25',200.000,'X',''),
    ('4500000104','00010','SP-BEARING-030','Ball Bearing 6205-2RS','2000','0001', 500.000,'EA',125.00,'INR','2024-12-01',500.000,'X',''),
    ('4500000104','00020','SP-SEAL-031',   'O-Ring Seal Kit NBR','2000','0001',1000.000,'EA', 35.00,'INR','2024-12-01',1000.000,'X',''),
    ('4500000105','00010','RM-RUBBER-005','Nitrile Rubber 70 Shore','1000','0001',250.000,'KG',310.00,'INR','2024-12-20',0.000,'',''),
    ('4500000105','00020','RM-OIL-007',   'Cutting Oil ISO VG 46','1000','0001',100.000,'L',  280.00,'INR','2024-12-20',0.000,'',''),
    ('4500000106','00010','SF-PANEL-013', 'Control Panel Sub-Assy','1100','0003', 20.000,'EA',4500.00,'INR','2024-12-31',0.000,'',''); -- STO item


    -- -----------------------------------------------------------------------------
    -- EKET  PO Schedule Lines (Delivery Schedule)
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE EKET (
        EBELN   VARCHAR(10) NOT NULL,
        EBELP   VARCHAR(5)  NOT NULL,
        ETENR   VARCHAR(4)  NOT NULL,         -- Schedule line number
        EINDT   DATE,                         -- Delivery date
        MENGE   NUMBER(13,3),                 -- Scheduled qty
        WEMNG   NUMBER(13,3),                 -- GR qty
        PRIMARY KEY (EBELN, EBELP, ETENR)
    );

    INSERT INTO EKET VALUES
    ('4500000101','00010','0001','2024-09-20',2000.000,2000.000),
    ('4500000101','00020','0001','2024-09-20', 500.000, 500.000),
    ('4500000102','00010','0001','2024-11-01', 200.000, 200.000),
    ('4500000102','00020','0001','2024-11-01',  75.000,  75.000),
    ('4500000102','00020','0002','2024-12-15',  25.000,   0.000),
    ('4500000103','00010','0001','2024-11-25',1000.000,1000.000),
    ('4500000103','00020','0001','2024-11-25', 200.000, 200.000),
    ('4500000104','00010','0001','2024-12-01', 500.000, 500.000),
    ('4500000104','00020','0001','2024-12-01',1000.000,1000.000),
    ('4500000105','00010','0001','2024-12-20', 250.000,   0.000),
    ('4500000105','00020','0001','2024-12-20', 100.000,   0.000);


    -- =============================================================================
    -- PRODUCTION ORDER TABLES
    -- =============================================================================

    -- -----------------------------------------------------------------------------
    -- AUFK  Order Master
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE AUFK (
        AUFNR   VARCHAR(12) NOT NULL,         -- Order Number
        AUART   VARCHAR(4),                   -- Order Type (PP01=Production, PM01=Maintenance)
        WERKS   VARCHAR(4),
        KOSTL   VARCHAR(10),                  -- Cost Centre
        ERDAT   DATE,                         -- Created Date
        AUDAT   DATE,                         -- Order Date
        GSTRP   DATE,                         -- Basic Start Date
        GLTRP   DATE,                         -- Basic Finish Date
        FTRMS   DATE,                         -- Scheduled Finish
        GETRI   DATE,                         -- Actual Start
        GETRS   DATE,                         -- Actual Finish
        OBJNR   VARCHAR(22),                  -- Object Number
        IPHAS   VARCHAR(1),                   -- Phase (1=Created,2=Released,3=Confirmed,4=TECO,5=Closed)
        ERNAM   VARCHAR(12),
        PRIMARY KEY (AUFNR)
    );

    INSERT INTO AUFK VALUES
    ('000001000001','PP01','1000','COST-PROD','2024-10-01','2024-10-01','2024-10-05','2024-10-12','2024-10-12','2024-10-05','2024-10-11','OBJ-PP-10001','4','PLANNER1'),
    ('000001000002','PP01','1000','COST-PROD','2024-10-15','2024-10-15','2024-10-20','2024-10-28','2024-10-28','2024-10-20','2024-10-27','OBJ-PP-10002','4','PLANNER1'),
    ('000001000003','PP01','1000','COST-PROD','2024-11-01','2024-11-01','2024-11-05','2024-11-15','2024-11-15','2024-11-05',NULL,          'OBJ-PP-10003','2','PLANNER2'),
    ('000001000004','PP01','1100','COST-PROD','2024-11-10','2024-11-10','2024-11-15','2024-11-25','2024-11-25','2024-11-15',NULL,          'OBJ-PP-10004','2','PLANNER2'),
    ('000001000005','PP01','1000','COST-PROD','2024-12-01','2024-12-01','2024-12-05','2024-12-15','2024-12-15',NULL,          NULL,         'OBJ-PP-10005','1','PLANNER1'),
    ('000002000001','PM01','1000','COST-MAINT','2024-11-20','2024-11-20','2024-11-22','2024-11-22','2024-11-22','2024-11-22','2024-11-22','OBJ-PM-20001','4','MAINT1');


    -- -----------------------------------------------------------------------------
    -- AFKO  Production Order Header
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE AFKO (
        AUFNR   VARCHAR(12) NOT NULL,
        MATNR   VARCHAR(18),                  -- Material to be produced
        WERKS   VARCHAR(4),
        CHARG   VARCHAR(100),                  -- Batch of output material
        GAMNG   NUMBER(13,3),                 -- Order Qty
        GMEIN   VARCHAR(3),
        WEMNG   NUMBER(13,3),                 -- GR Qty (confirmed)
        LGORT   VARCHAR(4),                   -- Receiving Storage Location
        GSTRS   DATE,                         -- Scheduled Start
        GLTRS   DATE,                         -- Scheduled Finish
        GSTRI   DATE,                         -- Actual Start
        GETRI   DATE,                         -- Actual Finish
        PRIMARY KEY (AUFNR)
    );

    INSERT INTO AFKO VALUES
    ('000001000001','FG-MOTOR-020','1000','MTR-2024-D01',  10.000,'EA', 10.000,'0002','2024-10-05','2024-10-12','2024-10-05','2024-10-11'),
    ('000001000002','FG-PUMP-021', '1000','PMP-2024-E01',  15.000,'EA', 15.000,'0002','2024-10-20','2024-10-28','2024-10-20','2024-10-27'),
    ('000001000003','FG-MOTOR-020','1000','MTR-2024-D02',   8.000,'EA',  0.000,'0002','2024-11-05','2024-11-15','2024-11-05',NULL),
    ('000001000004','FG-SENSOR-023','1100','SNS-2024-F01', 12.000,'EA', 12.000,'0002','2024-11-15','2024-11-25','2024-11-15',NULL),
    ('000001000005','SF-COIL-012', '1000','COIL-WO-0011', 30.000,'EA',  0.000,'0003','2024-12-05','2024-12-15',NULL,NULL),
    ('000002000001',NULL,           '1000',NULL,            1.000,'EA',  1.000,'0005','2024-11-22','2024-11-22','2024-11-22','2024-11-22');


    -- -----------------------------------------------------------------------------
    -- AFPO  Production Order Items (component list)
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE AFPO (
        AUFNR   VARCHAR(12) NOT NULL,
        POSNR   VARCHAR(4)  NOT NULL,         -- Item number
        MATNR   VARCHAR(18),                  -- Component material
        CHARG   VARCHAR(100),                  -- Batch consumed
        WERKS   VARCHAR(4),
        LGORT   VARCHAR(4),
        BDMNG   NUMBER(13,3),                 -- Required qty
        ENMNG   NUMBER(13,3),                 -- Withdrawn qty
        MEINS   VARCHAR(3),
        PRIMARY KEY (AUFNR, POSNR)
    );

    INSERT INTO AFPO VALUES
    -- WO 000001000001 → FG-MOTOR-020 (10 EA)
    ('000001000001','0010','SF-FRAME-010',NULL,          '1000','0001',10.000,10.000,'EA'),
    ('000001000001','0020','SF-GEAR-011', NULL,          '1000','0001',20.000,20.000,'EA'),
    ('000001000001','0030','SF-COIL-012', 'COIL-WO-0010','1000','0003',10.000,10.000,'EA'),
    ('000001000001','0040','RM-STEEL-001',NULL,          '1000','0001',50.000,50.000,'KG'),
    ('000001000001','0050','RM-RESIN-003','RESIN-2024-001','1000','0001',10.000,10.000,'KG'),
    -- WO 000001000002 → FG-PUMP-021 (15 EA)
    ('000001000002','0010','SF-FRAME-010',NULL,          '1000','0001',15.000,15.000,'EA'),
    ('000001000002','0020','RM-STEEL-001',NULL,          '1000','0001',75.000,75.000,'KG'),
    ('000001000002','0030','RM-RUBBER-005','RBBR-2024-B01','1000','0001',22.500,22.500,'KG'),
    ('000001000002','0040','RM-PAINT-004','PAINT-2024-A01','1000','0001',15.000,15.000,'L'),
    -- WO 000001000004 → FG-SENSOR-023 (12 EA)
    ('000001000004','0010','SF-COIL-012', 'COIL-WO-0010','1000','0003',12.000,12.000,'EA'),
    ('000001000004','0020','SF-PANEL-013',NULL,          '1100','0003', 6.000, 6.000,'EA'),
    ('000001000004','0030','RM-COPPER-006',NULL,         '1000','0001',12.000,12.000,'KG'),
    -- WO 000002000001 → PM Order (uses spare parts)
    ('000002000001','0010','SP-BEARING-030',NULL,        '1000','0005', 2.000, 2.000,'EA'),
    ('000002000001','0020','SP-SEAL-031','SEAL-2023-G01','1000','0005', 5.000, 5.000,'EA'),
    ('000002000001','0030','SP-FILTER-032','FILT-2024-H01','1000','0005',1.000, 1.000,'EA');


    -- =============================================================================
    -- GOODS MOVEMENT TABLES
    -- =============================================================================

    -- -----------------------------------------------------------------------------
    -- MKPF  Material Document Header
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE MKPF (
        MBLNR   VARCHAR(10) NOT NULL,         -- Material Document Number
        MJAHR   VARCHAR(4)  NOT NULL,         -- Fiscal Year
        BLDAT   DATE,                         -- Document Date
        BUDAT   DATE,                         -- Posting Date
        USNAM   VARCHAR(12),                  -- User Name
        TCODE   VARCHAR(20),                  -- Transaction Code
        BKTXT   VARCHAR,                  -- Header Text
        PRIMARY KEY (MBLNR, MJAHR)
    );

    INSERT INTO MKPF VALUES
    -- GR for POs (Sept-Oct)
    ('5000000001','2024','2024-09-20','2024-09-20','WH_RCVR1','MIGO','GR PO 4500000101 - Steel/Alum'),
    ('5000000002','2024','2024-10-05','2024-10-05','WH_RCVR1','MIGO','WO 10001 GI - Motor Components'),
    ('5000000003','2024','2024-10-11','2024-10-11','WH_RCVR2','MIGO','WO 10001 GR - Motor Output'),
    ('5000000004','2024','2024-10-20','2024-10-20','WH_RCVR1','MIGO','WO 10002 GI - Pump Components'),
    ('5000000005','2024','2024-10-27','2024-10-27','WH_RCVR2','MIGO','WO 10002 GR - Pump Output'),
    ('5000000006','2024','2024-11-01','2024-11-01','WH_RCVR1','MIGO','GR PO 4500000102 - Resin'),
    ('5000000007','2024','2024-11-05','2024-11-05','WH_RCVR1','MIGO','WO 10003 GI - Motor batch 2'),
    ('5000000008','2024','2024-11-10','2024-11-10','WH_RCVR2','MIGO','Transfer SLoc 0001 to 0003'),
    ('5000000009','2024','2024-11-15','2024-11-15','WH_RCVR1','MIGO','QI Release - RESIN-2024-001'),
    ('5000000010','2024','2024-11-20','2024-11-20','WH_RCVR2','MIGO','GR PO 4500000103 - Steel/Cu'),
    ('5000000011','2024','2024-11-22','2024-11-22','WH_RCVR1','MIGO','PM Order 20001 - Parts Issue'),
    ('5000000012','2024','2024-11-25','2024-11-25','WH_RCVR2','MIGO','WO 10004 GI - Sensor Comp'),
    ('5000000013','2024','2024-11-28','2024-11-28','WH_RCVR2','MIGO','WO 10004 GR - Sensor Output'),
    ('5000000014','2024','2024-12-01','2024-12-01','WH_RCVR1','MIGO','GR PO 4500000104 - Spares'),
    ('5000000015','2024','2024-12-03','2024-12-03','WH_RCVR2','MIGO','Scrap - Expired Resin Batch'),
    ('5000000016','2024','2024-12-05','2024-12-05','WH_RCVR1','MIGO','GI Delivery 80000001 - Motor'),
    ('5000000017','2024','2024-12-08','2024-12-08','WH_RCVR2','MIGO','GI Delivery 80000002 - Pump'),
    ('5000000018','2024','2024-12-10','2024-12-10','WH_RCVR1','MIGO','Stock Transfer 1000→1100'),
    ('5000000019','2024','2024-12-12','2024-12-12','WH_RCVR1','MIGO','GR PO 4500000102 rem - Paint'),
    ('5000000020','2024','2024-12-15','2024-12-15','QA_USER1', 'MIGO','QI Block SNS-2024-F02 fail'),
    ('5000000021','2024','2024-12-18','2024-12-18','WH_RCVR2','MIGO','Return to Vendor - VEND-001'),
    ('5000000022','2024','2024-12-20','2024-12-20','WH_RCVR1','MIGO','GI Cost Centre - Oil Maint'),
    ('5000000023','2024','2024-12-23','2024-12-23','WH_RCVR2','MIGO','Physical Inventory Adjust');


    -- -----------------------------------------------------------------------------
    -- MSEG  Material Document Segments (Line Items)
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE MSEG (
        MBLNR   VARCHAR(10) NOT NULL,
        MJAHR   VARCHAR(4)  NOT NULL,
        ZEILE   VARCHAR(4)  NOT NULL,         -- Line Item
        BWART   VARCHAR(3),                   -- Movement Type
        MATNR   VARCHAR(18),
        WERKS   VARCHAR(4),
        LGORT   VARCHAR(4),
        CHARG   VARCHAR(100),                  -- Batch (if applicable)
        MENGE   NUMBER(13,3),                 -- Qty
        MEINS   VARCHAR(3),
        DMBTR   NUMBER(13,2),                 -- Amount (local currency)
        WAERS   VARCHAR(5),
        EBELN   VARCHAR(10),                  -- Ref PO
        EBELP   VARCHAR(5),                   -- Ref PO Item
        AUFNR   VARCHAR(12),                  -- Ref Order
        KOSTL   VARCHAR(10),                  -- Cost Centre
        VBELN_IM VARCHAR(10),                 -- Ref Sales Order (for 601)
        SGTXT   VARCHAR(50),                  -- Line text
        PRIMARY KEY (MBLNR, MJAHR, ZEILE)
    );

    INSERT INTO MSEG VALUES
    -- DOC 5000000001: GR PO 4500000101 (101 - GR from PO)
    ('5000000001','2024','0001','101','RM-STEEL-001','1000','0001',NULL,    2000.000,'KG',145000.00,'INR','4500000101','00010',NULL,NULL,NULL,'GR Steel - PO 101 item 10'),
    ('5000000001','2024','0002','101','RM-ALUM-002', '1000','0001',NULL,     500.000,'KG',122500.00,'INR','4500000101','00020',NULL,NULL,NULL,'GR Aluminium - PO 101 item 20'),

    -- DOC 5000000002: WO 10001 GI (261 - GI for production order)
    ('5000000002','2024','0001','261','SF-FRAME-010','1000','0001',NULL,      10.000,'EA', 25000.00,'INR',NULL,NULL,'000001000001',NULL,NULL,'GI Frame - WO 10001'),
    ('5000000002','2024','0002','261','SF-GEAR-011', '1000','0001',NULL,      20.000,'EA',  8000.00,'INR',NULL,NULL,'000001000001',NULL,NULL,'GI Gear - WO 10001'),
    ('5000000002','2024','0003','261','SF-COIL-012', '1000','0003','COIL-WO-0010',10.000,'EA', 15000.00,'INR',NULL,NULL,'000001000001',NULL,NULL,'GI Coil batch - WO 10001'),
    ('5000000002','2024','0004','261','RM-STEEL-001','1000','0001',NULL,      50.000,'KG',  3625.00,'INR',NULL,NULL,'000001000001',NULL,NULL,'GI Steel - WO 10001'),
    ('5000000002','2024','0005','261','RM-RESIN-003','1000','0001','RESIN-2024-001',10.000,'KG',3800.00,'INR',NULL,NULL,'000001000001',NULL,NULL,'GI Resin batch - WO 10001'),

    -- DOC 5000000003: WO 10001 GR (961 - GR from production)
    ('5000000003','2024','0001','961','FG-MOTOR-020','1000','0002','MTR-2024-D01',10.000,'EA',250000.00,'INR',NULL,NULL,'000001000001',NULL,NULL,'GR Motor WO 10001'),

    -- DOC 5000000004: WO 10002 GI (261)
    ('5000000004','2024','0001','261','SF-FRAME-010', '1000','0001',NULL,     15.000,'EA', 37500.00,'INR',NULL,NULL,'000001000002',NULL,NULL,'GI Frame - WO 10002'),
    ('5000000004','2024','0002','261','RM-STEEL-001', '1000','0001',NULL,     75.000,'KG',  5437.50,'INR',NULL,NULL,'000001000002',NULL,NULL,'GI Steel - WO 10002'),
    ('5000000004','2024','0003','261','RM-RUBBER-005','1000','0001','RBBR-2024-B01',22.500,'KG',6975.00,'INR',NULL,NULL,'000001000002',NULL,NULL,'GI Rubber batch - WO 10002'),
    ('5000000004','2024','0004','261','RM-PAINT-004', '1000','0001','PAINT-2024-A01',15.000,'L',7800.00,'INR',NULL,NULL,'000001000002',NULL,NULL,'GI Paint batch - WO 10002'),

    -- DOC 5000000005: WO 10002 GR (961)
    ('5000000005','2024','0001','961','FG-PUMP-021','1000','0002','PMP-2024-E01',15.000,'EA',187500.00,'INR',NULL,NULL,'000001000002',NULL,NULL,'GR Pump WO 10002'),

    -- DOC 5000000006: GR PO 4500000102 - Resin (101)
    ('5000000006','2024','0001','101','RM-RESIN-003','1000','0001','RESIN-2024-002',100.000,'KG',38000.00,'INR','4500000102','00010',NULL,NULL,NULL,'GR Resin batch 2 - PO 102'),
    ('5000000006','2024','0002','103','RM-RESIN-003','1000','0001','RESIN-2024-003',100.000,'KG',38000.00,'INR','4500000102','00010',NULL,NULL,NULL,'GR Resin batch 3 - GR blocked (QI)'),

    -- DOC 5000000007: WO 10003 GI partial (261)
    ('5000000007','2024','0001','261','SF-FRAME-010','1000','0001',NULL,       8.000,'EA', 20000.00,'INR',NULL,NULL,'000001000003',NULL,NULL,'GI Frame WO 10003 partial'),
    ('5000000007','2024','0002','261','RM-STEEL-001','1000','0001',NULL,      40.000,'KG',  2960.00,'INR',NULL,NULL,'000001000003',NULL,NULL,'GI Steel WO 10003'),
    ('5000000007','2024','0003','261','RM-RESIN-003','1000','0001','RESIN-2024-001',8.000,'KG',3040.00,'INR',NULL,NULL,'000001000003',NULL,NULL,'GI Resin WO 10003'),

    -- DOC 5000000008: SLoc transfer 0001→0003 (311)
    ('5000000008','2024','0001','311','SF-GEAR-011','1000','0001',NULL,       10.000,'EA',  4000.00,'INR',NULL,NULL,NULL,NULL,NULL,'Transfer Gears to WIP SLoc'),
    ('5000000008','2024','0002','312','SF-GEAR-011','1000','0003',NULL,       10.000,'EA',  4000.00,'INR',NULL,NULL,NULL,NULL,NULL,'Receive Gears WIP SLoc'),

    -- DOC 5000000009: QI Release Resin batch (321)
    ('5000000009','2024','0001','321','RM-RESIN-003','1000','0001','RESIN-2024-002',100.000,'KG',38000.00,'INR',NULL,NULL,NULL,NULL,NULL,'QI Release Resin batch 002'),

    -- DOC 5000000010: GR PO 4500000103 (101)
    ('5000000010','2024','0001','101','RM-STEEL-001', '1000','0001',NULL,    1000.000,'KG', 74000.00,'INR','4500000103','00010',NULL,NULL,NULL,'GR Steel PO 103'),
    ('5000000010','2024','0002','101','RM-COPPER-006','1000','0001',NULL,     200.000,'KG',130000.00,'INR','4500000103','00020',NULL,NULL,NULL,'GR Copper PO 103'),

    -- DOC 5000000011: PM Order - spare parts issue (201)
    ('5000000011','2024','0001','201','SP-BEARING-030','1000','0005',NULL,      2.000,'EA',   250.00,'INR',NULL,NULL,'000002000001','COST-MAINT',NULL,'GI Bearing - PM Order'),
    ('5000000011','2024','0002','201','SP-SEAL-031',   '1000','0005','SEAL-2023-G01',5.000,'EA',175.00,'INR',NULL,NULL,'000002000001','COST-MAINT',NULL,'GI Seal batch - PM'),
    ('5000000011','2024','0003','201','SP-FILTER-032', '1000','0005','FILT-2024-H01',1.000,'EA', 98.00,'INR',NULL,NULL,'000002000001','COST-MAINT',NULL,'GI Filter - PM'),

    -- DOC 5000000012: WO 10004 GI - Sensor (261)
    ('5000000012','2024','0001','261','SF-COIL-012', '1000','0003','COIL-WO-0010',12.000,'EA',18000.00,'INR',NULL,NULL,'000001000004',NULL,NULL,'GI Coil WO 10004'),
    ('5000000012','2024','0002','261','SF-PANEL-013','1100','0003',NULL,         6.000,'EA',18000.00,'INR',NULL,NULL,'000001000004',NULL,NULL,'GI Panel WO 10004'),
    ('5000000012','2024','0003','261','RM-COPPER-006','1000','0001',NULL,        12.000,'KG',7800.00,'INR',NULL,NULL,'000001000004',NULL,NULL,'GI Copper WO 10004'),

    -- DOC 5000000013: WO 10004 GR - Sensor (961)
    ('5000000013','2024','0001','961','FG-SENSOR-023','1100','0002','SNS-2024-F01',12.000,'EA',96000.00,'INR',NULL,NULL,'000001000004',NULL,NULL,'GR Sensor WO 10004'),

    -- DOC 5000000014: GR PO 4500000104 - Spares (101)
    ('5000000014','2024','0001','101','SP-BEARING-030','2000','0001',NULL,     500.000,'EA',62500.00,'INR','4500000104','00010',NULL,NULL,NULL,'GR Bearing PO 104'),
    ('5000000014','2024','0002','101','SP-SEAL-031',   '2000','0001','SEAL-2024-G02',1000.000,'EA',35000.00,'INR','4500000104','00020',NULL,NULL,NULL,'GR Seal PO 104'),

    -- DOC 5000000015: Scrap expired resin (551)
    ('5000000015','2024','0001','551','RM-RESIN-003','1000','0001','RESIN-2024-003',20.000,'KG',7600.00,'INR',NULL,NULL,NULL,'COST-SCRAP',NULL,'Scrap expired Resin batch 003'),

    -- DOC 5000000016: GI Delivery for Motor (601)
    ('5000000016','2024','0001','601','FG-MOTOR-020','1000','0002','MTR-2024-D01',4.000,'EA',100000.00,'INR',NULL,NULL,NULL,NULL,'8000000001','GI Motor - Delivery 8000000001'),

    -- DOC 5000000017: GI Delivery for Pump (601)
    ('5000000017','2024','0001','601','FG-PUMP-021','1000','0002','PMP-2024-E01',6.000,'EA',75000.00,'INR',NULL,NULL,NULL,NULL,'8000000002','GI Pump - Delivery 8000000002'),

    -- DOC 5000000018: Plant-to-plant transfer Motor (301)
    ('5000000018','2024','0001','301','FG-MOTOR-020','1000','0002','MTR-2024-D01',2.000,'EA',50000.00,'INR',NULL,NULL,NULL,NULL,NULL,'Transfer Motor 1000→1100'),
    ('5000000018','2024','0002','305','FG-MOTOR-020','1100','0002','MTR-2024-D01',2.000,'EA',50000.00,'INR',NULL,NULL,NULL,NULL,NULL,'Receive Motor 1100'),

    -- DOC 5000000019: GR remaining Paint (101)
    ('5000000019','2024','0001','101','RM-PAINT-004','1000','0001','PAINT-2024-A02',75.000,'L',39000.00,'INR','4500000102','00020',NULL,NULL,NULL,'GR Paint remainder PO 102'),

    -- DOC 5000000020: QI Block Sensor batch failed (323 → blocked)
    ('5000000020','2024','0001','322','FG-SENSOR-023','1100','0002','SNS-2024-F02',5.000,'EA',40000.00,'INR',NULL,NULL,NULL,NULL,NULL,'Transfer Sensor to QI for retest'),

    -- DOC 5000000021: Return to vendor - Steel rejected lot (122)
    ('5000000021','2024','0001','122','RM-STEEL-001','1000','0001',NULL,      50.000,'KG', 3700.00,'INR','4500000103','00010',NULL,NULL,NULL,'Return rejected Steel to VEND-001'),

    -- DOC 5000000022: GI cost centre - Oil maintenance (201)
    ('5000000022','2024','0001','201','RM-OIL-007','1000','0001','OIL-2024-C01',5.000,'L',1400.00,'INR',NULL,NULL,NULL,'COST-MAINT',NULL,'Monthly machine lubrication'),

    -- DOC 5000000023: Physical inventory adjustment (702 = reduction)
    ('5000000023','2024','0001','702','RM-ALUM-002','1000','0001',NULL,       3.000,'KG',  735.00,'INR',NULL,NULL,NULL,NULL,NULL,'PI count variance - Alum short');


    -- =============================================================================
    -- SALES TABLES
    -- =============================================================================

    -- -----------------------------------------------------------------------------
    -- VBAK  Sales Order Header
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE VBAK (
        VBELN   VARCHAR(10) NOT NULL,         -- Sales Document
        AUART   VARCHAR(4),                   -- Sales Order Type
        VKORG   VARCHAR(4),                   -- Sales Org
        VTWEG   VARCHAR(2),                   -- Distribution Channel
        SPART   VARCHAR(2),                   -- Division
        KUNNR   VARCHAR(10),                  -- Sold-to Party
        BSTNK   VARCHAR(20),                  -- Customer PO Number
        BSTDK   DATE,                         -- Customer PO Date
        AUDAT   DATE,                         -- Document Date
        NETWR   NUMBER(15,2),                 -- Net Value
        WAERK   VARCHAR(5),                   -- Currency
        VKBUR   VARCHAR,                   -- Sales Office
        ERNAM   VARCHAR(12),
        PRIMARY KEY (VBELN)
    );

    INSERT INTO VBAK VALUES
    ('0000000001','OR','IN01','10','01','CUST-001','CPO-2024-0891','2024-11-30','2024-12-01',460000.00,'INR','SALES1','SD_USER1'),
    ('0000000002','OR','IN01','10','01','CUST-002','CPO-2024-0905','2024-12-03','2024-12-05',225000.00,'INR','SALES1','SD_USER2'),
    ('0000000003','OR','IN01','10','02','CUST-003','CPO-2024-0920','2024-12-10','2024-12-12',580000.00,'INR','SALES2','SD_USER1'),
    ('0000000004','OR','IN01','10','01','CUST-001','CPO-2024-0955','2024-12-15','2024-12-16',192000.00,'INR','SALES1','SD_USER2');


    -- -----------------------------------------------------------------------------
    -- VBAP  Sales Order Items
    -- -----------------------------------------------------------------------------
    CREATE OR REPLACE TABLE VBAP (
        VBELN   VARCHAR(10) NOT NULL,
        POSNR   VARCHAR(6)  NOT NULL,         -- Item
        MATNR   VARCHAR(18),
        ARKTX   VARCHAR(40),                  -- Item Description
        WERKS   VARCHAR(4),
        LGORT   VARCHAR(4),
        CHARG   VARCHAR(100),                  -- Batch
        KWMENG  NUMBER(15,3),                 -- Confirmed Qty
        VRKME   VARCHAR(3),                   -- Sales Unit
        NETPR   NUMBER(11,2),                 -- Net Price
        WAERS   VARCHAR(5),
        WBSTA   VARCHAR(1),                   -- Delivery Status (A=Not delivered,B=Partial,C=Full)
        LFSTA   VARCHAR(1),                   -- Goods movement status
        PRIMARY KEY (VBELN, POSNR)
    );

    INSERT INTO VBAP VALUES
    ('0000000001','000010','FG-MOTOR-020','3-Phase Motor 5HP 415V','1000','0002','MTR-2024-D01', 4.000,'EA',115000.00,'INR','C','C'),
    ('0000000001','000020','FG-PUMP-021', 'Centrifugal Pump 2 inch','1000','0002','PMP-2024-E01',6.000,'EA', 12500.00,'INR','C','C'),
    ('0000000002','000010','FG-VALVE-022','Ball Valve SS316 1 inch','1200','0001',NULL,          25.000,'EA',  2400.00,'INR','A','A'),
    ('0000000002','000020','FG-MOTOR-020','3-Phase Motor 5HP 415V','1000','0002','MTR-2024-D01', 2.000,'EA',115000.00,'INR','C','C'),
    ('0000000003','000010','FG-SENSOR-023','Pressure Sensor 0-10 bar','1100','0002','SNS-2024-F01',10.000,'EA', 8000.00,'INR','A','A'),
    ('0000000003','000020','FG-MOTOR-020','3-Phase Motor 5HP 415V','1100','0002','MTR-2024-D01',  4.000,'EA',115000.00,'INR','A','A'),
    ('0000000003','000030','FG-PUMP-021', 'Centrifugal Pump 2 inch','1000','0002','PMP-2024-E02', 3.000,'EA', 12500.00,'INR','A','A'),
    ('0000000004','000010','FG-SENSOR-023','Pressure Sensor 0-10 bar','1100','0002','SNS-2024-F01',8.000,'EA', 8000.00,'INR','A','A'),
    ('0000000004','000020','FG-VALVE-022', 'Ball Valve SS316 1 inch','1200','0001',NULL,          10.000,'EA',  2400.00,'INR','A','A');


    -- =============================================================================
    -- VENDOR MASTER (simplified LFA1)
    -- =============================================================================
    CREATE OR REPLACE TABLE LFA1 (
        LIFNR   VARCHAR(10) NOT NULL,
        NAME1   VARCHAR(35),
        LAND1   VARCHAR(3),
        ORT01   VARCHAR(25),
        REGIO   VARCHAR(3),
        WAERS   VARCHAR(5),
        PRIMARY KEY (LIFNR)
    );

    INSERT INTO LFA1 VALUES
    ('VEND-001','Tata Steel Limited',          'IN','Mumbai',   'MH','INR'),
    ('VEND-002','Asian Paints Industrial Div', 'IN','Mumbai',   'MH','INR'),
    ('VEND-003','SKF India Ltd',               'IN','Pune',     'MH','INR'),
    ('VEND-004','Siemens India Ltd',           'IN','Mumbai',   'MH','INR');


    -- =============================================================================
    -- USEFUL VIEWS FOR SNOWFLAKE INTELLIGENCE / CORTEX
    -- =============================================================================

    -- V_MATERIAL_STOCK_SUMMARY: Current stock across plants and storage locations
    CREATE OR REPLACE VIEW V_MATERIAL_STOCK_SUMMARY AS
    SELECT
        d.MATNR,
        k.MAKTX                             AS MATERIAL_DESC,
        a.MTART                             AS MATERIAL_TYPE,
        a.MATKL                             AS MATERIAL_GROUP,
        a.XCHPF                             AS BATCH_MANAGED,
        d.WERKS,
        w.NAME1                             AS PLANT_NAME,
        d.LGORT,
        l.LGOBE                             AS SLOC_DESC,
        d.LABST                             AS UNRESTRICTED_STOCK,
        d.INSME                             AS QI_STOCK,
        d.EINME                             AS RESTRICTED_STOCK,
        d.SPEME                             AS BLOCKED_STOCK,
        d.UMLME                             AS TRANSFER_STOCK,
        (d.LABST + d.INSME + d.EINME + d.SPEME + d.UMLME) AS TOTAL_STOCK,
        a.MEINS                             AS UOM
    FROM MARD d
    JOIN MARA a  ON a.MATNR = d.MATNR
    JOIN MAKT k  ON k.MATNR = d.MATNR AND k.SPRAS = 'E'
    JOIN T001W w ON w.WERKS  = d.WERKS
    JOIN T001L l ON l.WERKS  = d.WERKS AND l.LGORT = d.LGORT;


    -- V_BATCH_STOCK_DETAIL: Batch-level stock with expiry info
    CREATE OR REPLACE VIEW V_BATCH_STOCK_DETAIL AS
    SELECT
        b.MATNR,
        k.MAKTX                             AS MATERIAL_DESC,
        b.CHARG                             AS BATCH,
        b.LICHN                             AS VENDOR_BATCH,
        b.HSDAT                             AS MANUFACTURE_DATE,
        b.VFDAT                             AS EXPIRY_DATE,
        DATEDIFF('day', CURRENT_DATE(), b.VFDAT) AS DAYS_TO_EXPIRY,
        b.ZUSTD                             AS BATCH_STATUS,
        s.WERKS,
        w.NAME1                             AS PLANT_NAME,
        s.LGORT,
        l.LGOBE                             AS SLOC_DESC,
        s.LABST                             AS UNRESTRICTED,
        s.INSME                             AS QI_STOCK,
        s.EINME                             AS RESTRICTED,
        s.SPEME                             AS BLOCKED,
        a.MEINS                             AS UOM
    FROM MCH1 b
    JOIN MCHA s  ON s.MATNR = b.MATNR AND s.CHARG = b.CHARG
    JOIN MARA a  ON a.MATNR = b.MATNR
    JOIN MAKT k  ON k.MATNR = b.MATNR AND k.SPRAS = 'E'
    JOIN T001W w ON w.WERKS  = s.WERKS
    JOIN T001L l ON l.WERKS  = s.WERKS AND l.LGORT = s.LGORT;


    -- V_MATERIAL_MOVEMENTS: Full goods movement history with descriptions
    CREATE OR REPLACE VIEW V_MATERIAL_MOVEMENTS AS
    SELECT
        s.MBLNR                             AS MAT_DOC,
        s.MJAHR                             AS FISCAL_YEAR,
        s.ZEILE                             AS LINE,
        h.BLDAT                             AS DOC_DATE,
        h.BUDAT                             AS POSTING_DATE,
        h.USNAM                             AS POSTED_BY,
        s.BWART                             AS MVMT_TYPE,
        t.BWTXT                             AS MVMT_DESCRIPTION,
        s.MATNR,
        k.MAKTX                             AS MATERIAL_DESC,
        a.MTART                             AS MATERIAL_TYPE,
        s.WERKS,
        w.NAME1                             AS PLANT_NAME,
        s.LGORT,
        l.LGOBE                             AS SLOC_DESC,
        s.CHARG                             AS BATCH,
        s.MENGE                             AS QUANTITY,
        s.MEINS                             AS UOM,
        s.DMBTR                             AS AMOUNT_INR,
        s.EBELN                             AS PO_NUMBER,
        s.AUFNR                             AS ORDER_NUMBER,
        s.KOSTL                             AS COST_CENTRE,
        s.VBELN_IM                          AS SALES_ORDER,
        s.SGTXT                             AS LINE_TEXT,
        h.BKTXT                             AS HEADER_TEXT
    FROM MSEG s
    JOIN MKPF h  ON h.MBLNR = s.MBLNR AND h.MJAHR = s.MJAHR
    JOIN MARA a  ON a.MATNR = s.MATNR
    JOIN MAKT k  ON k.MATNR = s.MATNR AND k.SPRAS = 'E'
    JOIN T001W w ON w.WERKS  = s.WERKS
    JOIN T001L l ON l.WERKS  = s.WERKS AND l.LGORT = s.LGORT
    JOIN T156H t ON t.BWART  = s.BWART AND t.SPRAS = 'E';


    -- V_PRODUCTION_ORDERS: Production orders with components and output
    CREATE OR REPLACE VIEW V_PRODUCTION_ORDERS AS
    SELECT
        k.AUFNR                             AS ORDER_NUMBER,
        o.AUART                             AS ORDER_TYPE,
        k.MATNR                             AS OUTPUT_MATERIAL,
        m.MAKTX                             AS OUTPUT_DESC,
        k.CHARG                             AS OUTPUT_BATCH,
        k.WERKS,
        w.NAME1                             AS PLANT_NAME,
        k.GAMNG                             AS PLANNED_QTY,
        k.WEMNG                             AS CONFIRMED_QTY,
        k.GMEIN                             AS UOM,
        o.GSTRP                             AS BASIC_START,
        o.GLTRP                             AS BASIC_FINISH,
        k.GSTRI                             AS ACTUAL_START,
        k.GETRI                             AS ACTUAL_FINISH,
        o.IPHAS                             AS ORDER_PHASE,
        CASE o.IPHAS
            WHEN '1' THEN 'Created'
            WHEN '2' THEN 'Released'
            WHEN '3' THEN 'Confirmed'
            WHEN '4' THEN 'Technically Completed'
            WHEN '5' THEN 'Closed'
        END                                 AS ORDER_STATUS
    FROM AFKO k
    JOIN AUFK o  ON o.AUFNR = k.AUFNR
    JOIN T001W w ON w.WERKS  = k.WERKS
    LEFT JOIN MAKT m ON m.MATNR = k.MATNR AND m.SPRAS = 'E';


    -- V_PO_STATUS: Purchase order status with receipt progress
    CREATE OR REPLACE VIEW V_PO_STATUS AS
    SELECT
        p.EBELN                             AS PO_NUMBER,
        h.BEDAT                             AS PO_DATE,
        h.LIFNR                             AS VENDOR,
        v.NAME1                             AS VENDOR_NAME,
        p.EBELP                             AS ITEM,
        p.MATNR,
        k.MAKTX                             AS MATERIAL_DESC,
        p.WERKS,
        p.MENGE                             AS PO_QTY,
        p.MEINS                             AS UOM,
        p.NETPR                             AS UNIT_PRICE,
        (p.MENGE * p.NETPR)                 AS PO_VALUE,
        p.WEMNG                             AS GR_QTY,
        (p.MENGE - p.WEMNG)                 AS OPEN_QTY,
        p.EINDT                             AS DELIVERY_DATE,
        p.ELIKZ                             AS DELIVERY_COMPLETED,
        h.WAERS                             AS CURRENCY
    FROM EKPO p
    JOIN EKKO h  ON h.EBELN = p.EBELN
    JOIN LFA1 v  ON v.LIFNR = h.LIFNR
    JOIN MAKT k  ON k.MATNR = p.MATNR AND k.SPRAS = 'E';


    -- V_BATCH_EXPIRY_ALERT: Batches expiring within 90 days
    CREATE OR REPLACE VIEW V_BATCH_EXPIRY_ALERT AS
    SELECT
        b.MATNR,
        k.MAKTX                             AS MATERIAL_DESC,
        b.CHARG                             AS BATCH,
        b.VFDAT                             AS EXPIRY_DATE,
        DATEDIFF('day', CURRENT_DATE(), b.VFDAT) AS DAYS_TO_EXPIRY,
        b.KULAB                             AS UNRESTRICTED_STOCK,
        a.MEINS                             AS UOM,
        CASE
            WHEN b.VFDAT < CURRENT_DATE()                                       THEN 'EXPIRED'
            WHEN DATEDIFF('day', CURRENT_DATE(), b.VFDAT) <= 30                 THEN 'CRITICAL (<30 days)'
            WHEN DATEDIFF('day', CURRENT_DATE(), b.VFDAT) <= 90                 THEN 'WARNING (<90 days)'
            ELSE 'OK'
        END                                 AS EXPIRY_STATUS
    FROM MCH1 b
    JOIN MARA a ON a.MATNR = b.MATNR
    JOIN MAKT k ON k.MATNR = b.MATNR AND k.SPRAS = 'E'
    WHERE b.VFDAT IS NOT NULL
    ORDER BY b.VFDAT;


    -- V_SALES_ORDER_STATUS: Sales orders with delivery status
    CREATE OR REPLACE VIEW V_SALES_ORDER_STATUS AS
    SELECT
        h.VBELN                             AS SALES_ORDER,
        h.AUDAT                             AS ORDER_DATE,
        h.KUNNR                             AS CUSTOMER,
        h.BSTNK                             AS CUSTOMER_PO,
        p.POSNR                             AS ITEM,
        p.MATNR,
        k.MAKTX                             AS MATERIAL_DESC,
        p.WERKS,
        p.CHARG                             AS BATCH,
        p.KWMENG                            AS ORDER_QTY,
        p.VRKME                             AS UOM,
        p.NETPR                             AS UNIT_PRICE,
        (p.KWMENG * p.NETPR)                AS LINE_VALUE,
        h.NETWR                             AS ORDER_TOTAL,
        h.WAERK                             AS CURRENCY,
        CASE p.WBSTA
            WHEN 'A' THEN 'Not Delivered'
            WHEN 'B' THEN 'Partially Delivered'
            WHEN 'C' THEN 'Fully Delivered'
            ELSE 'Unknown'
        END                                 AS DELIVERY_STATUS
    FROM VBAK h
    JOIN VBAP p ON p.VBELN = h.VBELN
    JOIN MAKT k ON k.MATNR = p.MATNR AND k.SPRAS = 'E';




