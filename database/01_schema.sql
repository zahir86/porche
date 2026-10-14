-- =====================================================================
-- CMG Case Management - schema (MariaDB / Appian Cloud Database)
-- Convenzioni: PK sempre `id` auto-increment, FK `{entita}Id`,
-- ID esterni in campi dedicati, audit fields su ogni tabella.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Business data
-- ---------------------------------------------------------------------
CREATE TABLE CMG_Team (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  code          VARCHAR(50)  NOT NULL UNIQUE,
  name          VARCHAR(255) NOT NULL,
  groupId       INT          NOT NULL COMMENT 'ID del gruppo Appian del team',
  isActive      BOOLEAN      NOT NULL DEFAULT TRUE,
  createdBy     VARCHAR(255) NOT NULL,
  createdAt     DATETIME     NOT NULL,
  modifiedBy    VARCHAR(255),
  modifiedAt    DATETIME
);

CREATE TABLE CMG_Category (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  code          VARCHAR(50)  NOT NULL UNIQUE,
  name          VARCHAR(255) NOT NULL,
  description   VARCHAR(4000),
  teamId        INT          NOT NULL,
  isActive      BOOLEAN      NOT NULL DEFAULT TRUE,
  createdBy     VARCHAR(255) NOT NULL,
  createdAt     DATETIME     NOT NULL,
  modifiedBy    VARCHAR(255),
  modifiedAt    DATETIME,
  CONSTRAINT fk_category_team FOREIGN KEY (teamId) REFERENCES CMG_Team(id)
);

CREATE TABLE CMG_Customer (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  externalId      VARCHAR(100) COMMENT 'Codice cliente nel CRM / ERP',
  name            VARCHAR(255) NOT NULL,
  email           VARCHAR(255),
  phone           VARCHAR(50),
  isVip           BOOLEAN      NOT NULL DEFAULT FALSE,
  preferredChannel VARCHAR(50),
  createdBy       VARCHAR(255) NOT NULL,
  createdAt       DATETIME     NOT NULL,
  modifiedBy      VARCHAR(255),
  modifiedAt      DATETIME,
  INDEX idx_customer_external (externalId)
);

-- ---------------------------------------------------------------------
-- Case data (contenitore di processo)
-- ---------------------------------------------------------------------
CREATE TABLE CMG_Case (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  caseNumber      VARCHAR(20)  COMMENT 'Numero leggibile, es. CMG-2026-000123',
  externalRef     VARCHAR(100) COMMENT 'Riferimento del sistema/canale di origine',
  parentCaseId    INT          COMMENT 'Case originale in caso di riapertura',
  customerId      INT          NOT NULL,
  categoryId      INT,
  teamId          INT,
  subject         VARCHAR(255) NOT NULL,
  description     VARCHAR(4000),
  channel         VARCHAR(50)  NOT NULL,
  impact          VARCHAR(50),
  status          VARCHAR(50)  NOT NULL,
  priority        VARCHAR(50)  NOT NULL,
  owner           VARCHAR(255) COMMENT 'Username dell operatore corrente',
  dueAt           DATETIME     COMMENT 'Scadenza SLA di risoluzione',
  followUpAt      DATETIME     COMMENT 'Prossimo follow-up in WAITING_CUSTOMER',
  followUpCount   INT          NOT NULL DEFAULT 0,
  isCompleted     BOOLEAN      NOT NULL DEFAULT FALSE,
  completedAt     DATETIME,
  completedBy     VARCHAR(255),
  outcome         VARCHAR(50)  COMMENT 'RESOLVED, CANCELLED, NO_RESPONSE, DUPLICATE',
  createdBy       VARCHAR(255) NOT NULL,
  createdAt       DATETIME     NOT NULL,
  modifiedBy      VARCHAR(255),
  modifiedAt      DATETIME,
  CONSTRAINT fk_case_customer FOREIGN KEY (customerId)   REFERENCES CMG_Customer(id),
  CONSTRAINT fk_case_category FOREIGN KEY (categoryId)   REFERENCES CMG_Category(id),
  CONSTRAINT fk_case_team     FOREIGN KEY (teamId)       REFERENCES CMG_Team(id),
  CONSTRAINT fk_case_parent   FOREIGN KEY (parentCaseId) REFERENCES CMG_Case(id),
  INDEX idx_case_status (status, isCompleted),
  INDEX idx_case_due (isCompleted, dueAt),
  INDEX idx_case_followup (status, followUpAt)
);

-- ---------------------------------------------------------------------
-- Activity / result data
-- ---------------------------------------------------------------------
CREATE TABLE CMG_Activity (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  caseId        INT          NOT NULL,
  type          VARCHAR(50)  NOT NULL COMMENT 'CREATED, TRIAGED, WORKED, INFO_REQUESTED, ...',
  description   VARCHAR(4000),
  outcome       VARCHAR(50),
  startedAt     DATETIME,
  performedBy   VARCHAR(255) NOT NULL,
  performedAt   DATETIME     NOT NULL,
  CONSTRAINT fk_activity_case FOREIGN KEY (caseId) REFERENCES CMG_Case(id),
  INDEX idx_activity_case (caseId, performedAt)
);

CREATE TABLE CMG_StatusTransition (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  caseId        INT          NOT NULL,
  fromStatus    VARCHAR(50),
  toStatus      VARCHAR(50)  NOT NULL,
  enteredAt     DATETIME     NOT NULL COMMENT 'Ingresso nel toStatus',
  exitedAt      DATETIME     COMMENT 'Valorizzato alla transizione successiva',
  durationHours DECIMAL(10,2),
  changedBy     VARCHAR(255) NOT NULL,
  reason        VARCHAR(4000),
  CONSTRAINT fk_transition_case FOREIGN KEY (caseId) REFERENCES CMG_Case(id),
  INDEX idx_transition_open (caseId, exitedAt)
);

CREATE TABLE CMG_Comment (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  caseId        INT          NOT NULL,
  text          VARCHAR(4000) NOT NULL,
  isInternal    BOOLEAN      NOT NULL DEFAULT TRUE,
  createdBy     VARCHAR(255) NOT NULL,
  createdAt     DATETIME     NOT NULL,
  CONSTRAINT fk_comment_case FOREIGN KEY (caseId) REFERENCES CMG_Case(id)
);

CREATE TABLE CMG_CustomerRequest (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  caseId        INT          NOT NULL,
  question      VARCHAR(4000) NOT NULL,
  answer        VARCHAR(4000),
  requestedBy   VARCHAR(255) NOT NULL,
  requestedAt   DATETIME     NOT NULL,
  followUpAt    DATETIME     NOT NULL,
  answeredAt    DATETIME,
  status        VARCHAR(50)  NOT NULL COMMENT 'OPEN, ANSWERED, EXPIRED',
  CONSTRAINT fk_request_case FOREIGN KEY (caseId) REFERENCES CMG_Case(id)
);

CREATE TABLE CMG_Resolution (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  caseId          INT          NOT NULL,
  rootCause       VARCHAR(255),
  solution        VARCHAR(4000) NOT NULL,
  customerMessage VARCHAR(4000) NOT NULL,
  proposedBy      VARCHAR(255) NOT NULL,
  proposedAt      DATETIME     NOT NULL,
  reviewOutcome   VARCHAR(50)  COMMENT 'APPROVED, REJECTED, NOT_REQUIRED',
  reviewComment   VARCHAR(4000),
  reviewedBy      VARCHAR(255),
  reviewedAt      DATETIME,
  CONSTRAINT fk_resolution_case FOREIGN KEY (caseId) REFERENCES CMG_Case(id)
);

CREATE TABLE CMG_CaseDocument (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  caseId        INT          NOT NULL,
  documentId    INT          NOT NULL COMMENT 'ID documento Appian',
  documentType  VARCHAR(50),
  uploadedBy    VARCHAR(255) NOT NULL,
  uploadedAt    DATETIME     NOT NULL,
  CONSTRAINT fk_document_case FOREIGN KEY (caseId) REFERENCES CMG_Case(id)
);

-- ---------------------------------------------------------------------
-- Reporting: snapshot giornalieri (Appian non ha storico nativo)
-- ---------------------------------------------------------------------
CREATE TABLE CMG_KpiSnapshot (
  id                 INT AUTO_INCREMENT PRIMARY KEY,
  snapshotDate       DATE         NOT NULL UNIQUE,
  numCreated         INT          NOT NULL,
  numCompleted       INT          NOT NULL,
  numOpen            INT          NOT NULL,
  numOverdue         INT          NOT NULL,
  numWaitingCustomer INT          NOT NULL,
  avgResolutionHours DECIMAL(10,2),
  slaMetPercent      DECIMAL(5,2),
  createdAt          DATETIME     NOT NULL
);
