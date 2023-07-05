DROP TABLE IF EXISTS celltowers;
DROP TABLE IF EXISTS cells;

DROP TYPE IF EXISTS radio;

CREATE TYPE radio AS ENUM ('GSM', 'UMTS', 'LTE', 'CDMA');

CREATE TABLE celltowers (
    mcc             int       NOT NULL,
    mnc             int       NOT NULL,
    lac             int       NOT NULL,
    cell_id         int       NOT NULL,
    net_type        radio, 
    unit            int ,
    lat             float     NOT NULL,
    lon             float     NOT NULL,
    range           float     NOT NULL,
    samples         int       NOT NULL,
    changeable      boolean   NOT NULL,
    created         timestamp NOT NULL,
    updated         timestamp NOT NULL,
    averageSignal   int 
);

ALTER TABLE celltowers ADD PRIMARY KEY (mcc, mnc, lac, cell_id, net_type);

CREATE TABLE cells (
    mcc         int       NOT NULL,
    mnc         int       NOT NULL,
    lac         int       NOT NULL,
    cell_id     int       NOT NULL,
    net_type    radio     NOT NULL,    
    measured_at timestamp NOT NULL
);

ALTER TABLE cells ADD PRIMARY KEY (measured_at);

\copy celltowers FROM 'celltowers.csv' WITH CSV;
\copy cells      FROM 'cells.csv'      WITH CSV;
