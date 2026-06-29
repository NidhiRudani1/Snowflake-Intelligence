# Snowflake Intelligent Supply Chain Agent
### AI-Powered Natural Language Analytics using Snowflake Cortex Analyst

An enterprise-grade Intelligent AI Agent built completely on **Snowflake AI**, allowing business users to query enterprise SAP-like data using **plain English** instead of SQL.

The application combines **Snowflake Cortex Analyst**, **Semantic Views**, and an interactive **Python web application** to provide instant insights through tables and visualizations for multiple business domains.

---

# Project Overview

Traditional business users depend on technical teams to create reports or write SQL queries.

This project eliminates that dependency by providing an intelligent conversational interface where users simply ask questions in natural language.

The system automatically:

- Understands the business question
- Converts Natural Language → SQL using Cortex Analyst
- Executes SQL on Snowflake
- Returns interactive tables
- Automatically generates charts
- Provides business-friendly answers

---

# Business Users

This solution is designed for multiple enterprise departments.

| Department | Example Questions |
|------------|-------------------|
| QA | Show today's production yield by product family |
| Supply Chain | Which materials are overdue this month? |
| Finance | What is the current stock quantity by plant? |
| Operations | Where is my in-transit inventory right now? |
| Manufacturing | Show production orders pending confirmation |
| Procurement | Which purchase orders are still open? |

---

# Features

## Natural Language Querying

Users simply ask questions in English.

Example:

> Show today's production yield by product family

No SQL knowledge required.

---

## Snowflake Cortex Analyst

The project uses Snowflake Cortex Analyst as the Natural Language to SQL engine.

Responsibilities:

- Understand user intent
- Interpret business terminology
- Generate optimized SQL
- Execute SQL
- Return structured results

---

## Semantic Layer

A complete Semantic View is created over SAP-style data.

The semantic model includes:

- Facts
- Dimensions
- Metrics
- Relationships
- Business Synonyms
- Verified Queries

This enables Cortex Analyst to understand enterprise terminology rather than raw database schema.

Example:

Instead of

```
LABST
```

business users can simply ask

> Available Stock

---

## Automatic Chart Generation

Depending on the returned data, the application automatically creates:

- Bar Charts
- Pie Charts
- Line Charts
- Trend Charts
- Tables

No manual visualization required.

---

## Interactive Chat Interface

Users interact with the system through a conversational chatbot.

Example:

```
User:

Which materials are overdue this month?

↓

Snowflake Cortex Analyst

↓

Generated SQL

↓

Snowflake Execution

↓

Interactive Table

↓

Trend Chart
```

---

# Architecture

```
                        +-----------------------+
                        |   Business Users      |
                        +-----------+-----------+
                                    |
                                    |
                        Natural Language Question
                                    |
                                    ▼
                    +-------------------------------+
                    | Interactive Python Web App    |
                    +---------------+---------------+
                                    |
                                    |
                                    ▼
                    +-------------------------------+
                    | Snowflake Cortex Analyst      |
                    | Natural Language → SQL        |
                    +---------------+---------------+
                                    |
                                    |
                                    ▼
                 +--------------------------------------+
                 | Semantic View (Business Layer)       |
                 | Facts                               |
                 | Dimensions                          |
                 | Metrics                             |
                 | Synonyms                            |
                 | Relationships                       |
                 +---------------+----------------------+
                                 |
                                 ▼
                      +--------------------------+
                      | Snowflake Database       |
                      | SAP MM Tables            |
                      +--------------------------+
                                 |
                                 ▼
                      SQL Execution Result
                                 |
                                 ▼
                +--------------------------------+
                | Tables + Charts + AI Response |
                +--------------------------------+
```

---

# Business Domains Covered

The semantic model supports multiple enterprise domains.

## Quality Assurance (QA)

- Production Yield
- Batch Status
- Quality Inspection
- Blocked Inventory
- Batch Traceability

---

## Supply Chain

- Inventory
- Material Availability
- Purchase Orders
- Vendor Performance
- Delivery Tracking
- Material Movements

---

## Finance

- Inventory Valuation
- Stock by Plant
- Goods Movement Value
- Purchase Order Value
- Procurement Spend

---

## Operations

- Production Orders
- Work Orders
- Material Consumption
- In-transit Inventory
- Warehouse Status

---

# SAP Data Model

The project uses SAP MM style tables including:

```
MARA
MAKT
MARC
MARD
MCH1
MCHA
MKPF
MSEG
T001W
T001L
EKKO
EKPO
EKET
AUFK
AFKO
AFPO
VBAK
VBAP
LFA1
T156
T156H
T156T
```

---

# Semantic Intelligence

The semantic layer contains

- Business Dimensions
- Facts
- Metrics
- Relationships
- Synonyms
- Verified Business Queries

Example mappings

```
Stock on Hand
Inventory
Available Stock

↓

LABST
```

```
Purchase Order

↓

EKKO
EKPO
```

```
Production Order

↓

AUFK
AFKO
```

---

# Example User Queries

### QA

```
Show today's production yield by product family
```

Returns

- Yield Chart
- Product Family Summary
- Production Statistics

---

### Supply Chain

```
Which materials are overdue this month?
```

Returns

- Overdue Material List
- Trend Chart
- Material Details

---

### Finance

```
What is the current stock quantity by plant?
```

Returns

- Inventory Table
- Plant-wise Stock Chart

---

### Operations

```
Where is my in-transit stock right now?
```

Returns

- Material
- Plant
- Storage Location
- In-transit Quantity

---

### Procurement

```
Show all purchase orders pending delivery
```

Returns

- Open Purchase Orders
- Pending Quantity
- Vendor
- Delivery Dates

---

# Automatic Visualization

Depending on query results, the application automatically renders:

| Data Type | Visualization |
|------------|--------------|
| Time Series | Line Chart |
| Categories | Bar Chart |
| Percentage | Pie Chart |
| Inventory | Tables |
| KPIs | Metric Cards |

---

# Technology Stack

| Layer | Technology |
|---------|------------|
| Database | Snowflake |
| AI | Snowflake Cortex Analyst |
| Semantic Layer | Snowflake Semantic Views |
| Programming | Python |
| UI | Streamlit |
| Visualization | Plotly |
| Data Processing | Pandas |
| SQL Engine | Snowflake SQL |
| Authentication | Snowflake |

---

# Application Flow

```
User Question

↓

Python Web Application

↓

Snowflake Cortex Analyst

↓

Natural Language → SQL

↓

Semantic View

↓

Snowflake Execution

↓

Result Set

↓

Chart Generation

↓

Interactive Dashboard
```

---

# Key Benefits

- No SQL knowledge required
- Business-friendly AI assistant
- Faster decision making
- Enterprise semantic understanding
- Secure Snowflake-native architecture
- Interactive charts and reports
- Supports multiple business functions
- Highly scalable and extensible

---

# Sample Business Scenarios

### QA Manager

> "Show me today's production yield by product family."

✔️ Receives an instant production yield chart.

---

### Supply Chain User

> "Which materials are overdue this month?"

✔️ Receives an overdue materials report with trend analysis.

---

### Finance User

> "What is the current stock quantity by plant?"

✔️ Receives a plant-wise inventory table and visualization.

---

### Operations User

> "Where is my in-transit stock right now?"

✔️ Receives current in-transit inventory details across plants and storage locations.

---

# Future Enhancements

- Voice-enabled AI assistant
- Predictive inventory analytics
- AI-powered anomaly detection
- Automated alerts and notifications
- Forecasting with Snowflake ML
- Role-based AI agents
- Executive KPI dashboards

---

# Author

Developed as a Snowflake AI Proof of Concept demonstrating enterprise-grade Natural Language Analytics using **Snowflake Cortex Analyst**, **Semantic Views**, and **Python** to deliver conversational business intelligence across Supply Chain, QA, Finance, and Operations.
