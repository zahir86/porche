-- Dati di riferimento iniziali.
-- Sostituire i groupId con gli ID reali dei gruppi Appian (Admin Console / Designer → Groups).

INSERT INTO CMG_Team (code, name, groupId, createdBy, createdAt) VALUES
  ('TECHNICAL',      'Supporto Tecnico',      0, 'administrator', NOW()),
  ('ADMINISTRATIVE', 'Amministrazione',       0, 'administrator', NOW()),
  ('COMMERCIAL',     'Commerciale',           0, 'administrator', NOW());

INSERT INTO CMG_Category (code, name, description, teamId, createdBy, createdAt) VALUES
  ('TECHNICAL', 'Problema tecnico',     'Malfunzionamenti, guasti, errori',        (SELECT id FROM CMG_Team WHERE code = 'TECHNICAL'),      'administrator', NOW()),
  ('BILLING',   'Fatturazione',         'Fatture, pagamenti, rimborsi',            (SELECT id FROM CMG_Team WHERE code = 'ADMINISTRATIVE'), 'administrator', NOW()),
  ('CONTRACT',  'Contratto',            'Modifiche, disdette, rinnovi',            (SELECT id FROM CMG_Team WHERE code = 'COMMERCIAL'),     'administrator', NOW()),
  ('COMPLAINT', 'Reclamo',              'Reclami formali del cliente',             (SELECT id FROM CMG_Team WHERE code = 'COMMERCIAL'),     'administrator', NOW()),
  ('INFO',      'Richiesta informazioni','Domande generiche',                      (SELECT id FROM CMG_Team WHERE code = 'COMMERCIAL'),     'administrator', NOW());
