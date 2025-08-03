# Micro-Services

This guide details the monitoring API for managing your VPS fleet, covering endpoints to manage nodes, alerts, and integer parameters. All routes are under your SaaS primary domain and secured with a super‑user API key.

## Table of Contents

1. [Node Endpoints](#node-endpoints)

   * [1. List Nodes](#1-list-nodes)
   * [2. Create Node](#2-create-node)
   * [3. Delete Node](#3-delete-node)
   * [4. Upsert Node](#4-upsert-node)
   * [5. Track Node](#5-track-node)
2. [Node Alert Endpoints](#node-alert-endpoints)

   * [Create/Upsert Alert](#createupsert-alert)
3. [Integer Parameter Endpoints](#integer-parameter-endpoints)

   * [Upsert Integer Parameter](#upsert-integer-parameter)

---

## Node Endpoints

### 1. List Nodes

```
POST /api2.0/node/list.json
```

**Request Body**

| Field     | Type    | Required | Description                  |
| --------- | ------- | -------- | ---------------------------- |
| api\_key  | String  | Yes      | Super‑user API key           |
| page      | Integer | No       | Page number (default: 1)     |
| per\_page | Integer | No       | Items per page (default: 50) |
| ip        | String  | No       | Filter by node IP            |

**Response**

```json
{
  "status": "success",
  "data": [ { /* node records */ } ],
  "page": 1,
  "per_page": 50,
  "total": 123
}
```

**Example: cURL**

```bash
curl -X POST http://127.0.0.1:3000/api2.0/node/list.json \
  -H "Content-Type: application/json" \
  -d '{"api_key":"YOUR_SUPER_USER_API_KEY","page":1,"per_page":10}'
```

**Example: Ruby**

```ruby
require 'net/http'; require 'uri'; require 'json'
uri = URI('http://127.0.0.1:3000/api2.0/node/list.json')
req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
req.body = { api_key: 'YOUR_SUPER_USER_API_KEY', page: 1, per_page: 10 }.to_json
res = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
puts JSON.parse(res.body)
```

### 2. Create Node

```
POST /api2.0/node/create.json
```

Creates a new node record. All fields must be supplied (except optional ones).

**Request Body**

| Field                            | Type      | Required | Description                                 |
| -------------------------------- | --------- | -------- | ------------------------------------------- |
| api\_key                         | String    | Yes      | Super‑user API key                          |
| ip                               | String    | Yes      | Public IPv4 address                         |
| ssh\_username                    | String    | No       | SSH username                                |
| ssh\_password                    | String    | No       | SSH password                                |
| ssh\_root\_username              | String    | No       | Root SSH username                           |
| ssh\_root\_password              | String    | No       | Root SSH password                           |
| postgres\_username               | String    | No       | PostgreSQL username for services            |
| postgres\_password               | String    | No       | PostgreSQL password for services            |
| provider\_type                   | String    | Yes      | e.g. "contabo-vps"                          |
| provider\_code                   | String    | Yes      | Provider‑assigned code                      |
| micro\_service                   | String    | Yes      | Assigned micro‑service role                 |
| slots\_quota                     | Integer   | Yes      | Maximum number of slots                     |
| slots\_used                      | Integer   | No       | Currently used slots (default 0)            |
| total\_ram\_gb                   | Numeric   | No       | Total RAM in GB                             |
| total\_disk\_gb                  | Numeric   | No       | Total disk in GB                            |
| current\_ram\_usage              | Real      | No       | Current RAM usage (%)                       |
| current\_disk\_usage             | Real      | No       | Current disk usage (%)                      |
| current\_cpu\_usage              | Real      | No       | Current CPU usage (%)                       |
| max\_ram\_usage                  | Real      | No       | RAM usage threshold (%)                     |
| max\_disk\_usage                 | Real      | No       | Disk usage threshold (%)                    |
| max\_cpu\_usage                  | Real      | No       | CPU usage threshold (%)                     |
| creation\_time                   | Timestamp | No       | VPS creation initiation time                |
| creation\_success                | Boolean   | No       | whether VPS creation succeeded              |
| creation\_error\_description     | Text      | No       | error message if creation failed            |
| installation\_time               | Timestamp | No       | software installation start time            |
| installation\_success            | Boolean   | No       | whether installation succeeded              |
| installation\_error\_description | Text      | No       | error message if installation failed        |
| migrations\_time                 | Timestamp | No       | DB migrations start time                    |
| migrations\_success              | Boolean   | No       | whether migrations succeeded                |
| migrations\_error\_description   | Text      | No       | error message if migrations failed          |
| last\_start\_time                | Timestamp | No       | last software start attempt time            |
| last\_start\_success             | Boolean   | No       | whether last start succeeded                |
| last\_start\_description         | Text      | No       | message or error from last start            |
| last\_stop\_time                 | Timestamp | No       | last software stop attempt time             |
| last\_stop\_success              | Boolean   | No       | whether last stop succeeded                 |
| last\_stop\_description          | Text      | No       | message or error from last stop             |

**Response**

```json
{ "status": "success", "id": "<UUID>" }
```

**Example: cURL**

```bash
curl -X POST http://127.0.0.1:3000/api2.0/node/create.json \
  -H "Content-Type: application/json" \
  -d '{
    "api_key":"YOUR_KEY",
    "id":"$(uuidgen)",
    "create_time":"$(date -Iseconds)",
    "ip":"203.0.113.42",
    "provider_type":"contabo-vps",
    "provider_code":"contabo-xyz-123",
    "micro_service":"worker-rpa",
    "slots_quota":5,
    "total_ram_gb":8.00,
    "total_disk_gb":100.00
  }'
```

### 3. Delete Node

```
POST /api2.0/node/delete.json
```

Soft-deletes a node by setting `delete_time` to `now()`.

**Request Body**

| Field    | Type   | Required | Description        |
| -------- | ------ | -------- | ------------------ |
| api\_key | String | Yes      | Super‑user API key |
| id       | UUID   | Yes      | Node identifier    |

**Response**

```json
{ "status": "success" }
```

**Example: cURL**

```bash
curl -X POST http://127.0.0.1:3000/api2.0/node/delete.json \
  -H "Content-Type: application/json" \
  -d '{"api_key":"YOUR_KEY","id":"<NODE_UUID>"}'
```

### 4. Upsert Node

```
POST /api2.0/node/upsert.json
```

Creates or updates a node by `ip`. Accepts the exact same parameters as **Create Node**. If a node with the given `ip` exists, it will be updated; otherwise, inserted.

**Request Body**

| Field    | Type                       | Required | Description                         |
| -------- | -------------------------- | -------- | ----------------------------------- |
| api\_key | String                     | Yes      | Super‑user API key                  |
| ip       | String                     | Yes      | Public IPv4 address (merge key)     |
| ...      | (other create.json fields) | No       | All fields listed under Create Node |

**Response**

```json
{ "status": "success", "action": "inserted" | "updated", "node_id": "<UUID>" }
```

**Example: cURL**

```bash
curl -X POST http://127.0.0.1:3000/api2.0/node/upsert.json \
  -H "Content-Type: application/json" \
  -d '{
    "api_key":"YOUR_KEY",
    "ip":"203.0.113.42",
    "slots_quota":10
  }'
```

### 5. Track Node

```
POST /api2.0/node/track.json
```

This endpoint is a lightweight heartbeat/upsert that identifies the node by the **caller IP** (`request.ip`) instead of requiring `ip` in the body. 

It **only updates a restricted set of fields** (usage metrics, capacity, thresholds, slot info, and last start heartbeat) to avoid overwriting unrelated metadata. If the node does not yet exist, it will be created with sensible defaults so required non-null fields are populated.

**Request Body**: Accepts all **Create Node** fields except `ip`, `id`, and `create_time`.

**Response**

```json
{ "status":"success","action":"inserted"|"updated","node_id":"<UUID>" }
```

**Example: cURL**

```bash
curl -X POST http://127.0.0.1:3000/api2.0/node/track.json \
  -H "Content-Type: application/json" \
  -d '{"api_key":"YOUR_KEY","slots_used":2}'
```

---

## Node Alert Endpoints

### Create/Upsert Alert

```
POST /api2.0/node_alert/create.json
```

Merge key: `id_node`, `type`, `solved`

**Request Body**

| Field           | Type    | Required | Description                        |
| --------------- | ------- | -------- | ---------------------------------- |
| api\_key        | String  | Yes      | Super‑user API key                 |
| id\_node        | UUID    | Yes      | Node UUID                          |
| type            | String  | Yes      | Alert type                         |
| description     | Text    | No       | Context or details                 |
| screenshot\_url | String  | No       | URL for an illustrative screenshot |
| solved          | Boolean | No       | Mark as resolved (default false)   |

**Response**

```json
{ "status":"success","action":"inserted"|"updated","id":"<UUID>" }
```

**Example: cURL**

```bash
curl -X POST http://127.0.0.1:3000/api2.0/node_alert/create.json \
  -H "Content-Type: application/json" \
  -d '{
    "api_key":"YOUR_KEY",
    "id_node":"<NODE_UUID>",
    "type":"CPU_THRESHOLD",
    "description":"CPU > 90%",
    "solved":false
  }'
```

---

## Integer Parameter Endpoints

### Upsert Integer Parameter

```
POST /api2.0/general_int_parameter/upsert.json
```

Merge key: `name`

**Request Body**

| Field       | Type    | Required | Description                              |
| ----------- | ------- | -------- | ---------------------------------------- |
| api\_key    | String  | Yes      | Super‑user API key                       |
| name        | String  | Yes      | Parameter name                           |
| description | Text    | No       | Human‑readable description               |
| value       | Integer | No       | Current numeric value                    |
| min         | Integer | No       | Minimum allowable value                  |
| max         | Integer | No       | Maximum allowable value                  |
| solved      | Boolean | No       | Mark parameter as solved (default false) |

**Response**

```json
{ "status":"success","action":"inserted"|"updated","id":"<UUID>" }
```

**Example: cURL**

```bash
curl -X POST http://127.0.0.1:3000/api2.0/general_int_parameter/upsert.json \
  -H "Content-Type: application/json" \
  -d '{
    "api_key":"YOUR_KEY",
    "name":"max_connections",
    "value":100,
    "min":10,
    "max":500,
    "solved":false
  }'
```
