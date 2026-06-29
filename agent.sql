
-- SEMANTIC VIEW & CORTEX AGENT - Snowflake Intelligence Layer
-- Semantic View: Maps 22 raw tables into a business-semantic model with
--     relationships, facts, dimensions, metrics, synonyms, and verified queries.
--     Enables Cortex Analyst to generate SQL from natural language.
-- Cortex Agent: Interactive chatbot that business users (QA, Supply Chain,
--     Finance, Operations) interact with using plain English questions.
--     The agent uses cortex_analyst_text_to_sql + data_to_chart tools.

CREATE SCHEMA IF NOT EXISTS CL_DATA.SEMANTIC;
GRANT USAGE ON SCHEMA CL_DATA.SEMANTIC TO ROLE ACCOUNTADMIN;
GRANT USAGE ON AGENT CL_DATA.SEMANTIC.SAP_INTELLIGENCE_AGENT TO ROLE CL_ANALYST;

-- SEMANTIC VIEW: SAP_SUPPLY_CHAIN_INTELLIGENCE
-- Covers: T001W, T001L, MARA, MAKT, MARC, MARD, MCH1, MCHA,
--         T156, T156H, T156T, EKKO, EKPO, EKET, AUFK, AFKO, AFPO,
--         MKPF, MSEG, VBAK, VBAP, LFA1

CREATE OR REPLACE SEMANTIC VIEW CL_DATA.SEMANTIC.SAP_SUPPLY_CHAIN_INTELLIGENCE

  TABLES (
    plant_master AS CL_DATA.SAP_MM.T001W
      PRIMARY KEY (WERKS)
      COMMENT = 'Plant master data with plant name, country, city, region, and tax number',

    storage_location AS CL_DATA.SAP_MM.T001L
      PRIMARY KEY (WERKS, LGORT)
      COMMENT = 'Storage location master data within each plant',

    material_master AS CL_DATA.SAP_MM.MARA
      PRIMARY KEY (MATNR)
      COMMENT = 'General material master - material type, group, weight, batch management, shelf life, creation info',

    material_description AS CL_DATA.SAP_MM.MAKT
      PRIMARY KEY (MATNR, SPRAS)
      COMMENT = 'Material descriptions in different languages - filter SPRAS = E for English',

    plant_material AS CL_DATA.SAP_MM.MARC
      PRIMARY KEY (MATNR, WERKS)
      COMMENT = 'Plant-level material data - MRP type, procurement type, reorder point, safety stock, max stock',

    storage_stock AS CL_DATA.SAP_MM.MARD
      PRIMARY KEY (MATNR, WERKS, LGORT)
      WITH SYNONYMS ('inventory', 'stock on hand', 'warehouse stock')
      COMMENT = 'Current stock quantities per material, plant, and storage location',

    batch_master AS CL_DATA.SAP_MM.MCH1
      PRIMARY KEY (MATNR, CHARG)
      WITH SYNONYMS ('batch', 'lot')
      COMMENT = 'Batch master data with vendor batch, manufacture date, expiry date, and batch status',

    batch_plant_stock AS CL_DATA.SAP_MM.MCHA
      PRIMARY KEY (MATNR, WERKS, CHARG, LGORT)
      COMMENT = 'Batch-level stock per plant and storage location',

    movement_type AS CL_DATA.SAP_MM.T156
      PRIMARY KEY (BWART)
      COMMENT = 'Movement type configuration - debit/credit indicators and movement categories',

    movement_type_desc AS CL_DATA.SAP_MM.T156H
      PRIMARY KEY (BWART, SPRAS)
      COMMENT = 'Movement type descriptions - filter SPRAS = E for English',

    movement_type_text AS CL_DATA.SAP_MM.T156T
      PRIMARY KEY (BWART, SPRAS)
      COMMENT = 'Extended movement type descriptions and account assignment texts',

    purchase_order_header AS CL_DATA.SAP_MM.EKKO
      PRIMARY KEY (EBELN)
      WITH SYNONYMS ('purchase order', 'PO')
      COMMENT = 'Purchase order header with vendor, dates, currency, payment terms, and incoterms',

    purchase_order_item AS CL_DATA.SAP_MM.EKPO
      PRIMARY KEY (EBELN, EBELP)
      COMMENT = 'Purchase order line items with material, quantity, price, GR qty, and delivery status',

    po_schedule_line AS CL_DATA.SAP_MM.EKET
      PRIMARY KEY (EBELN, EBELP, ETENR)
      COMMENT = 'PO delivery schedule lines with scheduled and received quantities',

    order_master AS CL_DATA.SAP_MM.AUFK
      PRIMARY KEY (AUFNR)
      WITH SYNONYMS ('production order', 'work order', 'maintenance order')
      COMMENT = 'Order master data - production and maintenance orders with status and dates',

    production_order_header AS CL_DATA.SAP_MM.AFKO
      PRIMARY KEY (AUFNR)
      COMMENT = 'Production order header - output material, batch, planned/actual quantities and dates',

    production_order_component AS CL_DATA.SAP_MM.AFPO
      PRIMARY KEY (AUFNR, POSNR)
      WITH SYNONYMS ('BOM component', 'component list', 'material requirement')
      COMMENT = 'Production order component list - materials required and withdSAP_MMn for production',

    material_doc_header AS CL_DATA.SAP_MM.MKPF
      PRIMARY KEY (MBLNR, MJAHR)
      COMMENT = 'Material document header - document date, posting date, user, transaction code',

    material_doc_item AS CL_DATA.SAP_MM.MSEG
      PRIMARY KEY (MBLNR, MJAHR, ZEILE)
      WITH SYNONYMS ('goods movement', 'stock movement', 'material movement')
      COMMENT = 'Material document line items - movement type, material, qty, amount, references to PO/order',

    sales_order_header AS CL_DATA.SAP_MM.VBAK
      PRIMARY KEY (VBELN)
      WITH SYNONYMS ('sales order', 'customer order')
      COMMENT = 'Sales order header with customer, dates, net value, and customer PO reference',

    sales_order_item AS CL_DATA.SAP_MM.VBAP
      PRIMARY KEY (VBELN, POSNR)
      COMMENT = 'Sales order line items with material, batch, quantity, price, and delivery status',

    vendor_master AS CL_DATA.SAP_MM.LFA1
      PRIMARY KEY (LIFNR)
      WITH SYNONYMS ('vendor', 'supplier')
      COMMENT = 'Vendor/supplier master data with name, location, and currency'
  )

  RELATIONSHIPS (
    material_desc_to_material AS
      material_description (MATNR) REFERENCES material_master,
    plant_material_to_material AS
      plant_material (MATNR) REFERENCES material_master,
    plant_material_to_plant AS
      plant_material (WERKS) REFERENCES plant_master,
    storage_location_to_plant AS
      storage_location (WERKS) REFERENCES plant_master,
    storage_stock_to_material AS
      storage_stock (MATNR) REFERENCES material_master,
    storage_stock_to_plant AS
      storage_stock (WERKS) REFERENCES plant_master,
    storage_stock_to_sloc AS
      storage_stock (WERKS, LGORT) REFERENCES storage_location,
    batch_master_to_material AS
      batch_master (MATNR) REFERENCES material_master,
    batch_plant_stock_to_batch AS
      batch_plant_stock (MATNR, CHARG) REFERENCES batch_master,
    batch_plant_stock_to_plant AS
      batch_plant_stock (WERKS) REFERENCES plant_master,
    batch_plant_stock_to_sloc AS
      batch_plant_stock (WERKS, LGORT) REFERENCES storage_location,
    movement_type_desc_to_type AS
      movement_type_desc (BWART) REFERENCES movement_type,
    movement_type_text_to_type AS
      movement_type_text (BWART) REFERENCES movement_type,
    po_item_to_po_header AS
      purchase_order_item (EBELN) REFERENCES purchase_order_header,
    po_header_to_vendor AS
      purchase_order_header (LIFNR) REFERENCES vendor_master,
    po_item_to_material AS
      purchase_order_item (MATNR) REFERENCES material_master,
    po_schedule_to_po_item AS
      po_schedule_line (EBELN, EBELP) REFERENCES purchase_order_item,
    order_master_to_plant AS
      order_master (WERKS) REFERENCES plant_master,
    prod_order_to_order_master AS
      production_order_header (AUFNR) REFERENCES order_master,
    prod_order_to_material AS
      production_order_header (MATNR) REFERENCES material_master,
    prod_component_to_order AS
      production_order_component (AUFNR) REFERENCES order_master,
    prod_component_to_material AS
      production_order_component (MATNR) REFERENCES material_master,
    mat_doc_item_to_header AS
      material_doc_item (MBLNR, MJAHR) REFERENCES material_doc_header,
    mat_doc_item_to_material AS
      material_doc_item (MATNR) REFERENCES material_master,
    mat_doc_item_to_mvmt_type AS
      material_doc_item (BWART) REFERENCES movement_type,
    sales_order_item_to_header AS
      sales_order_item (VBELN) REFERENCES sales_order_header,
    sales_order_item_to_material AS
      sales_order_item (MATNR) REFERENCES material_master
  )

  FACTS (
    -- Stock facts
    storage_stock.unrestricted_qty AS LABST
      COMMENT = 'Unrestricted-use stock quantity available for consumption or sale',
    storage_stock.transfer_qty AS UMLME
      COMMENT = 'Stock in transfer between locations',
    storage_stock.qi_qty AS INSME
      COMMENT = 'Stock in quality inspection',
    storage_stock.restricted_qty AS EINME
      COMMENT = 'Restricted-use stock quantity',
    storage_stock.blocked_qty AS SPEME
      COMMENT = 'Blocked stock quantity - not available for use',

    -- Batch stock facts
    batch_master.batch_unrestricted_qty AS KULAB
      COMMENT = 'Batch-level unrestricted stock quantity',
    batch_master.batch_restricted_qty AS EINME
      COMMENT = 'Batch-level restricted stock quantity',
    batch_plant_stock.batch_sloc_unrestricted AS LABST
      COMMENT = 'Batch unrestricted stock at specific storage location',
    batch_plant_stock.batch_sloc_qi AS INSME
      COMMENT = 'Batch quality inspection stock at storage location',
    batch_plant_stock.batch_sloc_restricted AS EINME
      COMMENT = 'Batch restricted stock at storage location',
    batch_plant_stock.batch_sloc_blocked AS SPEME
      COMMENT = 'Batch blocked stock at storage location',

    -- MRP facts
    plant_material.reorder_point AS MINBE
      COMMENT = 'Reorder point - triggers replenishment when stock falls below',
    plant_material.safety_stock AS EISBE
      COMMENT = 'Safety stock level',
    plant_material.max_stock AS MABST
      COMMENT = 'Maximum stock level',

    -- Purchase order facts
    purchase_order_item.po_quantity AS MENGE
      COMMENT = 'Purchase order quantity',
    purchase_order_item.po_net_price AS NETPR
      COMMENT = 'Purchase order net price per unit',
    purchase_order_item.gr_quantity AS WEMNG
      COMMENT = 'Goods receipt quantity already received against PO',
    po_schedule_line.scheduled_qty AS MENGE
      COMMENT = 'Scheduled delivery quantity',
    po_schedule_line.received_qty AS WEMNG
      COMMENT = 'Received quantity against schedule line',

    -- Production order facts
    production_order_header.planned_qty AS GAMNG
      COMMENT = 'Production order planned/target quantity',
    production_order_header.confirmed_qty AS WEMNG
      COMMENT = 'Production order confirmed (goods receipt) quantity',
    production_order_component.required_qty AS BDMNG
      COMMENT = 'Required component quantity for production',
    production_order_component.withdSAP_MMn_qty AS ENMNG
      COMMENT = 'Quantity actually withdSAP_MMn/issued for production',

    -- Goods movement facts
    material_doc_item.movement_qty AS MENGE
      COMMENT = 'Goods movement quantity',
    material_doc_item.movement_amount AS DMBTR
      COMMENT = 'Goods movement value in local currency (INR)',

    -- Sales order facts
    sales_order_item.ordered_qty AS KWMENG
      COMMENT = 'Confirmed/ordered quantity in sales unit',
    sales_order_item.net_price AS NETPR
      COMMENT = 'Net price per unit in sales order',
    sales_order_header.order_net_value AS NETWR
      COMMENT = 'Total net value of the sales order',

    -- Material weight facts
    material_master.gross_weight AS BRGEW
      COMMENT = 'Material gross weight',
    material_master.net_weight AS NTGEW
      COMMENT = 'Material net weight'
  )

  DIMENSIONS (
    -- Material dimensions
    material_master.material_number AS MATNR
      WITH SYNONYMS = ('material', 'material ID', 'part number', 'MATNR')
      COMMENT = 'Unique material number identifier',
    material_master.industry_sector AS MBRSH
      COMMENT = 'Industry sector: M=Mechanical, C=Chemical, F=Food',
    material_master.material_type AS MTART
      COMMENT = 'Material type: ROH=SAP_MM Material, HALB=Semi-Finished, FERT=Finished Good, ERSA=Spare Part',
    material_master.material_group AS MATKL
      COMMENT = 'Material group classification',
    material_master.base_uom AS MEINS
      COMMENT = 'Base unit of measure (KG, L, EA)',
    material_master.batch_managed AS XCHPF
      COMMENT = 'Batch management indicator: X=Yes, blank=No',
    material_master.total_shelf_life AS MHDLP
      COMMENT = 'Total shelf life in days',
    material_master.created_on AS ERSDA
      COMMENT = 'Material creation date',
    material_description.material_name AS MAKTX
      WITH SYNONYMS = ('material description', 'product name', 'item name')
      COMMENT = 'Material description text in English',

    -- Plant dimensions
    plant_master.plant_code AS WERKS
      WITH SYNONYMS = ('plant', 'plant code', 'factory')
      COMMENT = 'Plant code identifier',
    plant_master.plant_name AS NAME1
      WITH SYNONYMS = ('plant name', 'manufacturing site')
      COMMENT = 'Name of the plant',
    plant_master.country AS LAND1
      COMMENT = 'Country code of the plant',
    plant_master.city AS ORT01
      WITH SYNONYMS = ('city', 'location')
      COMMENT = 'City where the plant is located',
    plant_master.region AS REGIO
      WITH SYNONYMS = ('state', 'region')
      COMMENT = 'Region/state of the plant',

    -- Storage location dimensions
    storage_location.sloc_code AS LGORT
      WITH SYNONYMS = ('storage location', 'sloc')
      COMMENT = 'Storage location code',
    storage_location.sloc_description AS LGOBE
      WITH SYNONYMS = ('storage location name', 'warehouse name')
      COMMENT = 'Storage location description',

    -- Batch dimensions
    batch_master.batch_number AS CHARG
      WITH SYNONYMS = ('batch', 'lot number', 'batch ID')
      COMMENT = 'Batch/lot number',
    batch_master.vendor_batch AS LICHN
      WITH SYNONYMS = ('vendor batch number', 'supplier lot')
      COMMENT = 'Vendor/supplier batch number',
    batch_master.expiry_date AS VFDAT
      WITH SYNONYMS = ('expiration date', 'shelf life expiry', 'best before')
      COMMENT = 'Shelf life expiry date',
    batch_master.manufacture_date AS HSDAT
      WITH SYNONYMS = ('production date', 'made on')
      COMMENT = 'Date of manufacture',
    batch_master.batch_status AS ZUSTD
      COMMENT = 'Batch status: 0=Unrestricted, 1=Restricted, 2=Blocked',

    -- MRP dimensions
    plant_material.mrp_type AS DISMM
      COMMENT = 'MRP type: PD=MRP, VM=Reorder Point Planning',
    plant_material.mrp_controller AS DISPO
      COMMENT = 'MRP controller/planner code',
    plant_material.purchasing_group AS EKGRP
      COMMENT = 'Purchasing group',
    plant_material.procurement_type AS BESKZ
      COMMENT = 'Procurement type: E=In-house production, F=External procurement, X=Both',

    -- Movement type dimensions
    movement_type.mvmt_type_code AS BWART
      WITH SYNONYMS = ('movement type', 'mvmt type')
      COMMENT = 'Movement type code (101, 261, 301, 311, 601, etc.)',
    movement_type.debit_credit AS SHKZG
      COMMENT = 'Debit/Credit indicator: S=Debit (receipt/increase), H=Credit (issue/decrease)',
    movement_type_desc.mvmt_description AS BWTXT
      COMMENT = 'Movement type short description',

    -- Purchase order dimensions
    purchase_order_header.po_number AS EBELN
      WITH SYNONYMS = ('PO number', 'purchase order number')
      COMMENT = 'Purchase order document number',
    purchase_order_header.po_category AS BSTYP
      COMMENT = 'PO category: F=Standard PO, K=Contract, L=Scheduling Agreement',
    purchase_order_header.po_type AS BSART
      COMMENT = 'PO type: NB=Standard, UB=Stock Transfer Order',
    purchase_order_header.po_date AS BEDAT
      WITH SYNONYMS = ('PO date', 'order date')
      COMMENT = 'Purchase order creation date',
    purchase_order_header.currency AS WAERS
      COMMENT = 'PO currency',
    purchase_order_header.payment_terms AS ZTERM
      COMMENT = 'Payment terms key',
    purchase_order_header.incoterms AS INCO1
      COMMENT = 'Incoterms (EXW, CIF, FOB)',
    purchase_order_item.po_item AS EBELP
      COMMENT = 'Purchase order item number',
    purchase_order_item.delivery_date AS EINDT
      WITH SYNONYMS = ('expected delivery', 'due date')
      COMMENT = 'Requested delivery date for PO item',
    purchase_order_item.delivery_completed AS ELIKZ
      COMMENT = 'Delivery completed flag: X=Complete, blank=Open',
    purchase_order_item.deletion_indicator AS LOEKZ
      COMMENT = 'Deletion indicator for PO item',

    -- Production order dimensions
    order_master.order_number AS AUFNR
      WITH SYNONYMS = ('order number', 'production order', 'work order')
      COMMENT = 'Order number (production or maintenance)',
    order_master.order_type AS AUART
      COMMENT = 'Order type: PP01=Production Order, PM01=Maintenance Order',
    order_master.order_phase AS IPHAS
      COMMENT = 'Order phase: 1=Created, 2=Released, 3=Confirmed, 4=TECO, 5=Closed',
    order_master.basic_start_date AS GSTRP
      WITH SYNONYMS = ('planned start', 'production start')
      COMMENT = 'Basic (planned) start date',
    order_master.basic_finish_date AS GLTRP
      WITH SYNONYMS = ('planned finish', 'production end')
      COMMENT = 'Basic (planned) finish date',
    order_master.actual_start AS GETRI
      COMMENT = 'Actual start date',
    order_master.actual_finish AS GETRS
      COMMENT = 'Actual finish date',
    production_order_header.output_batch AS CHARG
      COMMENT = 'Batch number of produced output material',
    production_order_header.scheduled_start AS GSTRS
      COMMENT = 'Scheduled start date for production',
    production_order_header.scheduled_finish AS GLTRS
      COMMENT = 'Scheduled finish date for production',

    -- Material document dimensions
    material_doc_header.document_date AS BLDAT
      COMMENT = 'Material document date',
    material_doc_header.posting_date AS BUDAT
      WITH SYNONYMS = ('GR date', 'goods receipt date', 'movement date', 'posting date')
      COMMENT = 'Posting date of material document',
    material_doc_header.user_name AS USNAM
      COMMENT = 'User who posted the material document',
    material_doc_header.transaction_code AS TCODE
      COMMENT = 'SAP transaction code used',
    material_doc_header.header_text AS BKTXT
      COMMENT = 'Material document header text',
    material_doc_item.mat_doc_number AS MBLNR
      COMMENT = 'Material document number',
    material_doc_item.fiscal_year AS MJAHR
      COMMENT = 'Fiscal year of material document',
    material_doc_item.batch AS CHARG
      WITH SYNONYMS = ('movement batch', 'lot moved')
      COMMENT = 'Batch number in goods movement',
    material_doc_item.ref_po AS EBELN
      COMMENT = 'Reference purchase order number in goods movement',
    material_doc_item.ref_order AS AUFNR
      COMMENT = 'Reference production/maintenance order in goods movement',
    material_doc_item.cost_centre AS KOSTL
      COMMENT = 'Cost centre charged in goods movement',
    material_doc_item.sales_delivery AS VBELN_IM
      COMMENT = 'Reference sales delivery document',
    material_doc_item.line_text AS SGTXT
      COMMENT = 'Goods movement line item text',

    -- Sales order dimensions
    sales_order_header.sales_order_number AS VBELN
      WITH SYNONYMS = ('SO number', 'sales order number')
      COMMENT = 'Sales order document number',
    sales_order_header.sales_order_type AS AUART
      COMMENT = 'Sales order type (OR=Standard Order)',
    sales_order_header.sales_org AS VKORG
      COMMENT = 'Sales organization',
    sales_order_header.distribution_channel AS VTWEG
      COMMENT = 'Distribution channel',
    sales_order_header.customer_number AS KUNNR
      WITH SYNONYMS = ('customer', 'sold-to party')
      COMMENT = 'Customer who placed the order',
    sales_order_header.customer_po AS BSTNK
      WITH SYNONYMS = ('customer PO', 'PO reference')
      COMMENT = 'Customer purchase order reference number',
    sales_order_header.order_date AS AUDAT
      WITH SYNONYMS = ('order placed date', 'sales order date')
      COMMENT = 'Date of the sales order document',
    sales_order_item.delivery_status AS WBSTA
      COMMENT = 'Delivery status: A=Not Delivered, B=Partial, C=Fully Delivered',
    sales_order_item.item_description AS ARKTX
      COMMENT = 'Sales order item short text',

    -- Vendor dimensions
    vendor_master.vendor_number AS LIFNR
      WITH SYNONYMS = ('vendor', 'supplier code')
      COMMENT = 'Vendor account number',
    vendor_master.vendor_name AS NAME1
      WITH SYNONYMS = ('supplier name', 'vendor name')
      COMMENT = 'Vendor/supplier company name',
    vendor_master.vendor_country AS LAND1
      COMMENT = 'Vendor country',
    vendor_master.vendor_city AS ORT01
      COMMENT = 'Vendor city',
    vendor_master.vendor_region AS REGIO
      COMMENT = 'Vendor region/state'
  )

  METRICS (
    -- Inventory metrics
    storage_stock.total_unrestricted_stock AS SUM(LABST)
      WITH SYNONYMS = ('total stock', 'available stock', 'free stock')
      COMMENT = 'Total unrestricted stock across all locations',
    storage_stock.total_stock_all AS SUM(LABST + UMLME + INSME + EINME + SPEME)
      WITH SYNONYMS = ('total inventory', 'overall stock')
      COMMENT = 'Total stock including all stock categories',
    storage_stock.total_qi_stock AS SUM(INSME)
      COMMENT = 'Total stock in quality inspection',
    storage_stock.total_blocked_stock AS SUM(SPEME)
      COMMENT = 'Total blocked stock',

    -- Purchase order metrics
    purchase_order_item.total_po_value AS SUM(MENGE * NETPR)
      WITH SYNONYMS = ('total PO value', 'procurement value')
      COMMENT = 'Total purchase order value',
    purchase_order_item.total_open_po_qty AS SUM(MENGE - WEMNG)
      WITH SYNONYMS = ('pending delivery', 'open PO quantity')
      COMMENT = 'Total open (not yet received) purchase order quantity',
    purchase_order_item.po_line_count AS COUNT(EBELP)
      COMMENT = 'Count of purchase order line items',

    -- Production metrics
    production_order_header.total_planned_production AS SUM(GAMNG)
      WITH SYNONYMS = ('planned production', 'target output')
      COMMENT = 'Total planned production quantity across orders',
    production_order_header.total_confirmed_production AS SUM(WEMNG)
      WITH SYNONYMS = ('actual production', 'confirmed output')
      COMMENT = 'Total confirmed/completed production quantity',
    order_master.production_order_count AS COUNT(AUFNR)
      WITH SYNONYMS = ('number of production orders', 'order count')
      COMMENT = 'Count of production/maintenance orders',

    -- Goods movement metrics
    material_doc_item.total_movement_value AS SUM(DMBTR)
      WITH SYNONYMS = ('goods movement value', 'transaction value')
      COMMENT = 'Total value of goods movements in local currency',
    material_doc_item.movement_line_count AS COUNT(ZEILE)
      COMMENT = 'Count of goods movement line items',

    -- Sales metrics
    sales_order_header.total_sales_value AS SUM(NETWR)
      WITH SYNONYMS = ('revenue', 'order value', 'sales value')
      COMMENT = 'Total net value across all sales orders',
    sales_order_item.total_ordered_qty AS SUM(KWMENG)
      WITH SYNONYMS = ('total quantity ordered')
      COMMENT = 'Total quantity ordered across sales orders',
    sales_order_header.sales_order_count AS COUNT(VBELN)
      WITH SYNONYMS = ('number of orders', 'sales order count')
      COMMENT = 'Count of sales orders'
  )

  COMMENT = 'SAP MM Supply Chain Intelligence - Covers procurement, manufacturing, inventory, batch management, goods movements, and sales. Supports QA, Supply Chain, Finance, and Operations teams. Tables: T001W, T001L, MARA, MAKT, MARC, MARD, MCH1, MCHA, T156, T156H, T156T, EKKO, EKPO, EKET, AUFK, AFKO, AFPO, MKPF, MSEG, VBAK, VBAP, LFA1.'

  AI_SQL_GENERATION 'When joining tables, always filter MAKT with SPRAS = ''E'' to get English descriptions. Use fully qualified table names (CL_DATA.SAP_MM.xxx). Key movement types: 101=GR from PO, 102=GR reversal, 103=GR to blocked, 122=Return to vendor, 201=GI cost centre, 261=GI production order, 301=Plant transfer 1-step, 311=SLoc transfer, 321=QI to unrestricted, 322=Unrestricted to QI, 551=Scrapping, 601=GI for delivery, 961=GR from production. Order phase (AUFK.IPHAS): 1=Created, 2=Released, 3=Confirmed, 4=TECO, 5=Closed. Batch status (MCH1.ZUSTD): 0=Unrestricted, 1=Restricted, 2=Blocked. For open PO qty: EKPO.MENGE - EKPO.WEMNG > 0. For batch expiry: compare MCH1.VFDAT to CURRENT_DATE(). For production yield: AFKO.WEMNG / AFKO.GAMNG. Sales delivery status (VBAP.WBSTA): A=Not Delivered, B=Partial, C=Full.'

  AI_QUESTION_CATEGORIZATION 'This model answers questions about: materials and inventory (stock levels, batch tracking, shelf life, MRP parameters), procurement (purchase orders, vendor details, goods receipts, open deliveries), manufacturing (production orders, components, planned vs actual output), goods movements (receipts, issues, transfers, scrapping, returns), and sales orders (customer orders, order values, delivery status). If the question is about HR, payroll, finance GL, or unrelated topics, say this model only covers SAP MM supply chain operations data.'

  AI_VERIFIED_QUERIES (
    current_stock_by_plant AS (
      QUESTION 'What is the current stock quantity by plant?'
      VERIFIED_AT 1748736000
      ONBOARDING_QUESTION TRUE
      VERIFIED_BY '(STEWARD = supply_chain_team)'
      SQL 'SELECT w.NAME1 AS plant_name, w.WERKS AS plant_code, SUM(d.LABST) AS unrestricted_stock, SUM(d.INSME) AS qi_stock, SUM(d.SPEME) AS blocked_stock, SUM(d.UMLME) AS transfer_stock, SUM(d.LABST + d.INSME + d.SPEME + d.UMLME + d.EINME) AS total_stock FROM CL_DATA.SAP_MM.MARD d JOIN CL_DATA.SAP_MM.T001W w ON w.WERKS = d.WERKS GROUP BY w.NAME1, w.WERKS ORDER BY total_stock DESC'
    ),
    batches_expiring_soon AS (
      QUESTION 'Which batches are expiring within 90 days?'
      VERIFIED_AT 1748736000
      ONBOARDING_QUESTION TRUE
      VERIFIED_BY '(STEWARD = qa_team)'
      SQL 'SELECT k.MAKTX AS material, b.MATNR, b.CHARG AS batch, b.LICHN AS vendor_batch, b.HSDAT AS manufacture_date, b.VFDAT AS expiry_date, DATEDIFF(''day'', CURRENT_DATE(), b.VFDAT) AS days_to_expiry, b.KULAB AS unrestricted_stock, b.ZUSTD AS batch_status FROM CL_DATA.SAP_MM.MCH1 b JOIN CL_DATA.SAP_MM.MAKT k ON k.MATNR = b.MATNR AND k.SPRAS = ''E'' WHERE b.VFDAT IS NOT NULL AND b.VFDAT <= DATEADD(''day'', 90, CURRENT_DATE()) ORDER BY b.VFDAT'
    ),
    open_purchase_orders AS (
      QUESTION 'Which purchase orders have open quantities pending delivery?'
      VERIFIED_AT 1748736000
      ONBOARDING_QUESTION TRUE
      VERIFIED_BY '(STEWARD = supply_chain_team)'
      SQL 'SELECT h.EBELN AS po_number, h.BEDAT AS po_date, v.NAME1 AS vendor, k.MAKTX AS material, p.MENGE AS ordered_qty, p.WEMNG AS received_qty, (p.MENGE - p.WEMNG) AS open_qty, p.NETPR AS unit_price, p.EINDT AS delivery_date, h.WAERS AS currency FROM CL_DATA.SAP_MM.EKPO p JOIN CL_DATA.SAP_MM.EKKO h ON h.EBELN = p.EBELN JOIN CL_DATA.SAP_MM.LFA1 v ON v.LIFNR = h.LIFNR JOIN CL_DATA.SAP_MM.MAKT k ON k.MATNR = p.MATNR AND k.SPRAS = ''E'' WHERE (p.MENGE - p.WEMNG) > 0 AND (p.LOEKZ IS NULL OR p.LOEKZ = '''') ORDER BY p.EINDT'
    ),
    production_order_status AS (
      QUESTION 'What is the status of all production orders?'
      VERIFIED_AT 1748736000
      ONBOARDING_QUESTION TRUE
      VERIFIED_BY '(STEWARD = operations_team)'
      SQL 'SELECT o.AUFNR AS order_number, o.AUART AS order_type, CASE o.IPHAS WHEN ''1'' THEN ''Created'' WHEN ''2'' THEN ''Released'' WHEN ''3'' THEN ''Confirmed'' WHEN ''4'' THEN ''Tech Complete'' WHEN ''5'' THEN ''Closed'' END AS status, k.MAKTX AS material, f.GAMNG AS target_qty, f.WEMNG AS confirmed_qty, f.CHARG AS output_batch, w.NAME1 AS plant, o.GSTRP AS planned_start, o.GLTRP AS planned_finish, o.GETRI AS actual_start, o.GETRS AS actual_finish FROM CL_DATA.SAP_MM.AUFK o JOIN CL_DATA.SAP_MM.AFKO f ON f.AUFNR = o.AUFNR JOIN CL_DATA.SAP_MM.T001W w ON w.WERKS = o.WERKS LEFT JOIN CL_DATA.SAP_MM.MAKT k ON k.MATNR = f.MATNR AND k.SPRAS = ''E'' ORDER BY o.GSTRP'
    ),
    goods_movements_summary AS (
      QUESTION 'Show goods movements by type for the last 30 days'
      VERIFIED_AT 1748736000
      ONBOARDING_QUESTION TRUE
      VERIFIED_BY '(STEWARD = operations_team)'
      SQL 'SELECT s.BWART AS mvmt_type, t.BWTXT AS description, COUNT(*) AS line_count, SUM(s.MENGE) AS total_qty, SUM(s.DMBTR) AS total_value_inr FROM CL_DATA.SAP_MM.MSEG s JOIN CL_DATA.SAP_MM.MKPF h ON h.MBLNR = s.MBLNR AND h.MJAHR = s.MJAHR JOIN CL_DATA.SAP_MM.T156H t ON t.BWART = s.BWART AND t.SPRAS = ''E'' WHERE h.BUDAT >= DATEADD(''day'', -30, CURRENT_DATE()) GROUP BY s.BWART, t.BWTXT ORDER BY total_value_inr DESC'
    ),
    vendor_delivery_performance AS (
      QUESTION 'How are vendors performing on purchase order deliveries?'
      VERIFIED_AT 1748736000
      ONBOARDING_QUESTION TRUE
      VERIFIED_BY '(STEWARD = supply_chain_team)'
      SQL 'SELECT v.NAME1 AS vendor, v.LIFNR AS vendor_code, COUNT(DISTINCT h.EBELN) AS total_pos, SUM(p.MENGE) AS total_ordered, SUM(p.WEMNG) AS total_received, SUM(p.MENGE - p.WEMNG) AS total_open, ROUND(SUM(p.WEMNG) / NULLIF(SUM(p.MENGE), 0) * 100, 1) AS fulfillment_pct FROM CL_DATA.SAP_MM.EKKO h JOIN CL_DATA.SAP_MM.EKPO p ON p.EBELN = h.EBELN JOIN CL_DATA.SAP_MM.LFA1 v ON v.LIFNR = h.LIFNR GROUP BY v.NAME1, v.LIFNR ORDER BY fulfillment_pct'
    ),
    production_component_consumption AS (
      QUESTION 'What components were consumed for a production order?'
      VERIFIED_AT 1748736000
      ONBOARDING_QUESTION FALSE
      VERIFIED_BY '(STEWARD = operations_team)'
      SQL 'SELECT c.AUFNR AS order_number, k.MAKTX AS component_material, c.CHARG AS batch_consumed, c.BDMNG AS required_qty, c.ENMNG AS withdSAP_MMn_qty, (c.BDMNG - c.ENMNG) AS remaining_qty, c.MEINS AS uom, w.NAME1 AS plant FROM CL_DATA.SAP_MM.AFPO c JOIN CL_DATA.SAP_MM.MAKT k ON k.MATNR = c.MATNR AND k.SPRAS = ''E'' JOIN CL_DATA.SAP_MM.T001W w ON w.WERKS = c.WERKS ORDER BY c.AUFNR, c.POSNR'
    ),
    sales_order_delivery_status AS (
      QUESTION 'Which sales orders are not yet fully delivered?'
      VERIFIED_AT 1748736000
      ONBOARDING_QUESTION FALSE
      VERIFIED_BY '(STEWARD = supply_chain_team)'
      SQL 'SELECT h.VBELN AS sales_order, h.AUDAT AS order_date, h.KUNNR AS customer, h.BSTNK AS customer_po, k.MAKTX AS material, p.KWMENG AS ordered_qty, p.NETPR AS unit_price, (p.KWMENG * p.NETPR) AS line_value, CASE p.WBSTA WHEN ''A'' THEN ''Not Delivered'' WHEN ''B'' THEN ''Partially Delivered'' WHEN ''C'' THEN ''Fully Delivered'' END AS delivery_status, h.WAERK AS currency FROM CL_DATA.SAP_MM.VBAK h JOIN CL_DATA.SAP_MM.VBAP p ON p.VBELN = h.VBELN JOIN CL_DATA.SAP_MM.MAKT k ON k.MATNR = p.MATNR AND k.SPRAS = ''E'' WHERE p.WBSTA != ''C'' ORDER BY h.AUDAT'
    )
  );

-- CORTEX AGENT: SAP_INTELLIGENCE_AGENT
-- Interactive chatbot with cortex_analyst_text_to_sql + data_to_chart tools

CREATE OR REPLACE AGENT CL_DATA.SEMANTIC.SAP_INTELLIGENCE_AGENT
  COMMENT = 'Interactive SAP MM Supply Chain Intelligence Agent - enables plain English questions across procurement, manufacturing, inventory, batch management, goods movements, and sales'
  FROM SPECIFICATION
$$
models:
  orchestration: auto

instructions:
  response: "Respond concisely with data tables and charts when appropriate. Use business-friendly language. Always show material descriptions (not raw codes). Format dates as YYYY-MM-DD. Include units of measure. When showing stock, distinguish between unrestricted, QI, and blocked. For production orders, show phase/status in plain text. Round numeric values to 2 decimal places. Currency is INR."
  orchestration: "Use SAP_Supply_Chain_Analytics for ALL questions about materials, stock, batches, vendors, purchase orders, production orders, goods movements, sales orders, and inventory. Generate charts when the user asks for trends, comparisons, or distributions."
  sample_questions:
    - question: "What is the current stock quantity by plant?"
    - question: "Which batches are expiring within 90 days?"
    - question: "Show me open purchase orders with pending deliveries"
    - question: "What is the status of production orders?"
    - question: "Show goods movements by type for the last 30 days"
    - question: "How are vendors performing on deliveries?"
    - question: "What components were consumed for production order 000001000001?"
    - question: "Which sales orders are not yet delivered?"

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "SAP_Supply_Chain_Analytics"
      description: "Answers questions about SAP MM supply chain data including: inventory/stock levels (by plant, storage location, batch), batch management (expiry dates, shelf life, lot tracking, batch status), procurement (purchase orders, vendors, goods receipts, open quantities, delivery schedules), manufacturing (production orders, components, planned vs actual output, order phases), goods movements (receipts, issues, transfers, scrapping, returns, QI movements), and sales orders (customer orders, order values, delivery status). Covers 22 tables: T001W, T001L, MARA, MAKT, MARC, MARD, MCH1, MCHA, T156, T156H, T156T, EKKO, EKPO, EKET, AUFK, AFKO, AFPO, MKPF, MSEG, VBAK, VBAP, LFA1."
  - tool_spec:
      type: "data_to_chart"
      name: "data_to_chart"
      description: "Generates charts and visualizations from query results. Use when the user asks for trends, comparisons, distributions, or any visual representation of data."

tool_resources:
  SAP_Supply_Chain_Analytics:
    semantic_view: "CL_DATA.SEMANTIC.SAP_SUPPLY_CHAIN_INTELLIGENCE"
    warehouse: "SF_DBT_TEST_WH"
$$;
