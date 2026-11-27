# azure-static-website-deployment

A personal portfolio site built with **Vue 3 + Vite**, hosted as a **static website on Azure Blob Storage**, with a serverless **visitor counter** backed by **Azure Functions** and **Azure Cosmos DB**.

All infrastructure is defined in **Bicep** and deployed via **GitHub Actions** using OpenID Connect (no long-lived Azure credentials stored in GitHub).

---

## Table of contents

- [Architecture](#architecture)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Local development](#local-development)
- [End-to-end tests](#end-to-end-tests)
- [Infrastructure (Bicep)](#infrastructure-bicep)
- [CI/CD pipeline](#cicd-pipeline)
- [Azure setup](#azure-setup)
- [API reference](#api-reference)
- [Known limitations / TODO](#known-limitations--todo)

---

## Architecture

```
                    ┌──────────────────────────────┐
  Browser ────────▶ │ Azure Storage – static website│   ($web container, index.html)
     │              └──────────────────────────────┘
     │  GET /api/visits (CORS: static site origin only)
     ▼
  ┌──────────────────────────────┐   managed identity    ┌──────────────────────┐
  │ Azure Function App (Node 22) │ ────────────────────▶ │ Azure Cosmos DB      │
  │ Flex Consumption (FC1)       │   (Entra ID / RBAC)   │ portfolio_db/counters│
  └──────────────────────────────┘                       └──────────────────────┘
          │
          ├── Application Insights + Log Analytics (monitoring)
          └── Deployment package stored in a blob container (same storage account)
```

1. The Vue app is built to `dist/` and uploaded to the storage account's `$web` container.
2. On page load, the frontend calls the Function App's `/api/visits` endpoint and displays the total visit count in the hero section.
3. The Function App reads the counter document from Cosmos DB using `DefaultAzureCredential` (managed identity in Azure, your developer login locally).

## Tech stack

| Layer          | Technology                                                    |
| -------------- | ------------------------------------------------------------- |
| Frontend       | Vue 3 (`<script setup>`), Vite                                |
| Hosting        | Azure Storage static website (StorageV2, Standard_LRS)       |
| API            | Azure Functions v4 programming model, Node.js 22, Flex Consumption |
| Database       | Azure Cosmos DB (NoSQL API) via `@azure/cosmos`               |
| Auth           | Microsoft Entra ID — user-assigned managed identity, `@azure/identity` |
| Monitoring     | Application Insights + Log Analytics workspace                |
| IaC            | Bicep                                                         |
| CI/CD          | GitHub Actions with Azure OIDC login                          |
| Testing        | Cypress (end-to-end)                                          |

## Project structure

```
.
├── .github/workflows/main.yml   # CI/CD: build → test → deploy
├── api/                         # Azure Functions backend
│   ├── index.js                 # HTTP functions (visits counter)
│   ├── host.json
│   ├── local.settings.json      # Local-only settings (do not commit secrets)
│   └── package.json
├── cypress/e2e/home.cy.js       # E2E test for the homepage
├── infra/
│   ├── main.bicep               # Storage account, static website, function app module
│   ├── functions.bicep          # Function App, plan, identity, RBAC, App Insights
│   └── storage_account.bicep    # (placeholder, currently empty)
├── src/
│   ├── App.vue                  # Portfolio page + visit counter fetch
│   ├── main.js
│   └── style.css
├── index.html                   # Vite entry point
├── vite.config.js               # base: './' so assets resolve from blob storage
├── cypress.config.js
└── package.json
```

## Prerequisites

- [Node.js](https://nodejs.org/) 20+ (CI uses 20 for the frontend; the Function App runs on Node 22)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with Bicep (`az bicep install`)
- [Azure Functions Core Tools v4](https://learn.microsoft.com/azure/azure-functions/functions-run-local) (to run the API locally)
- An Azure subscription

## Local development

### Frontend

```bash
npm install
npm run dev        # http://localhost:5173
npm run build      # production build into dist/
npm run preview    # serve the production build locally
```

> The visit counter URL is currently hard-coded in `src/App.vue`. Point it to `http://localhost:7071/api/visits` when testing against a local Functions host.

### API (Azure Functions)

```bash
cd api
npm install
func start         # http://localhost:7071/api/visits
```

Or in VS Code, run the **`func: host start`** task (installs dependencies first).

Locally, `DefaultAzureCredential` uses your Azure CLI / VS Code login, so your account needs a Cosmos DB data-plane role (e.g. *Cosmos DB Built-in Data Contributor*) on the account. Run `az login` before starting the host.

`api/local.settings.json` holds local-only values (`FUNCTIONS_WORKER_RUNTIME`, `AzureWebJobsStorage`, …). It is listed in `.gitignore` — keep real connection strings out of version control.

## End-to-end tests

Cypress checks that the homepage renders the portfolio owner's name.

```bash
npm run dev        # terminal 1
npm run cy:run     # terminal 2 – headless run
npm run cy:open    # or open the interactive Cypress runner
```

## Infrastructure (Bicep)

### `infra/main.bicep`

- **Storage account** `stweb<uniqueString>` — StorageV2, HTTPS only, TLS 1.2.
- **Static website** enabled on the blob service (`index.html`, `404.html`).
- Calls `functions.bicep`, passing the static site origin (trailing `/` stripped) for CORS.

**Outputs:** `storageAccountName`, `websiteUrl`, `functionAppEndpoint`, `functionAppName`.

### `infra/functions.bicep`

- **Flex Consumption plan** (`FC1`, Linux) and **Function App** `func-<token>` running Node 22, HTTPS only.
- **User-assigned managed identity** with RBAC on the storage account (Blob Data Owner/Contributor, Queue and Table Data Contributor) and *Monitoring Metrics Publisher* on Application Insights.
- **Application Insights** (local auth disabled) backed by a **Log Analytics** workspace (30-day retention).
- A blob container for the Function App deployment package, accessed via the managed identity.
- **CORS** restricted to the static website origin.

### Deploying manually

```bash
az login
az group create --name static_web_storage_group --location francecentral
az deployment group create \
  --resource-group static_web_storage_group \
  --template-file infra/main.bicep
```

## CI/CD pipeline

`.github/workflows/main.yml` runs on every push to `master`:

| Job      | Steps                                                                                       |
| -------- | ------------------------------------------------------------------------------------------- |
| `build`  | `npm ci` → `npm run build` → upload `dist/` as an artifact                                  |
| `test`   | Starts the dev server and runs Cypress E2E tests                                            |
| `deploy` | Azure OIDC login → create resource group if missing → deploy `main.bicep` → install API prod deps → deploy `api/` to the Function App → upload `dist/` to `$web` → logout |

Environment variables used by the workflow:

| Name          | Value                       |
| ------------- | --------------------------- |
| `RG_Name`     | `static_web_storage_group`  |
| `RG_LOCATION` | `francecentral`             |

## Azure setup

### 1. GitHub OIDC federation

Create an Entra ID app registration (or user-assigned identity) with a **federated credential** for this repository's `master` branch, then add these **repository secrets**:

| Secret                  | Description                       |
| ----------------------- | --------------------------------- |
| `AZURE_CLIENT_ID`       | Client ID of the app registration |
| `AZURE_TENANT_ID`       | Entra ID tenant ID                |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID            |

The identity needs permission to create resource groups, deploy resources, **and create role assignments** (e.g. *Owner*, or *Contributor* + *Role Based Access Control Administrator*) because `functions.bicep` assigns RBAC roles. The blob upload step uses `--auth-mode key`, so it also needs to list storage account keys (covered by *Contributor*).

### 2. Cosmos DB (provisioned outside Bicep)

The Cosmos DB account is **not** created by the Bicep templates. The API expects:

| Setting   | Value                                                  |
| --------- | ------------------------------------------------------ |
| Endpoint  | `https://static-web-db-cosmos.documents.azure.com:443` |
| Database  | `portfolio_db`                                         |
| Container | `counters` (partition key path: `/id`)                 |
| Document  | `{ "id": "visitors", "count": 0 }`                     |

Grant the Function App's user-assigned identity (`uai-data-owner-<token>`) a Cosmos DB data-plane role, for example:

```bash
az cosmosdb sql role assignment create \
  --account-name static-web-db-cosmos \
  --resource-group <cosmos-rg> \
  --role-definition-id 00000000-0000-0000-0000-000000000002 \
  --principal-id <managed-identity-principal-id> \
  --scope "/"
```

## API reference

Base URL: `https://<functionAppName>.azurewebsites.net/api`

### `GET /visits`

Returns the current visitor count.

```json
{ "count": 42 }
```

### `POST /visits`

Intended to increment the visitor count by 1 and return `201`. **Work in progress** — see below.

## Known limitations / TODO

- **`POST /visits` is not functional yet**: it is registered under the same function name (`visits`) as the GET handler, and uses Python-style SDK calls (`patch_item(...)`). It should be given a unique name and use `container.item(id, partitionKey).patch([{ op: 'incr', path: '/count', value: 1 }])`.
- The frontend only reads the counter; it does not yet call `POST /visits` to increment it.
- The Function App URL is hard-coded in `src/App.vue`; consider a Vite env variable (`VITE_API_URL`).
- The Cosmos DB endpoint is hard-coded in `api/index.js`; consider an app setting.
- Cosmos DB is not provisioned or granted RBAC by Bicep.
- `infra/storage_account.bicep` is empty but still referenced as a module in `main.bicep`.
- The static website expects a `404.html` that the build does not currently produce.
- `mssql` remains in `api/package.json` from an earlier Azure SQL iteration and can be removed.
