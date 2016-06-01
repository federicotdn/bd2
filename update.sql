DROP INDEX SCORE_IDX1;
DROP INDEX SCORE_IDX2;
DROP INDEX SCORE_IDX3;
DROP INDEX SCORE_IDX4;
DROP INDEX SCORE_IDX5;
DROP INDEX SCORE_IDX6;
DROP INDEX SCORE_IDX7;
DROP INDEX SCORE_IDX8;
DROP INDEX SCORE_IDX9;
DROP INDEX SCORE_IDX10;
DROP INDEX SCORE_IDX11;
DROP INDEX SCORE_IDX12;
DROP INDEX SCORE_IDX13;
DROP INDEX SCORE_IDX14;
DROP INDEX SCORE_IDX15;
CREATE INDEX DATE_REVIEW ON REVIEW (CREATED) TABLESPACE BDIITPE21C;
ALTER DATABASE DATAFILE '$ORACLE_HOME/dbs/bdiitpe21c_indexes.ora' AUTOEXTEND ON;
DBADATAFILES -> NOMBRE DE LOS DBADATAFILES
DBAUSER SEGMENTS
ALTER TABLE "BDIITPE2"."SCORE" MODIFY "SCORE" NUMBER(6);
ALTER TABLE "BDIITPE2"."REVIEW" MODIFY "ROLE" VARCHAR(10);
ALTER TABLE "BDIITPE2"."REVIEW" MODIFY "SCORE" VARCHAR(10);
ALTER TABLE "BDIITPE2"."REVIEW" MODIFY "COMMENTS" VARCHAR(10);
ALTER TABLE "BDIITPE2"."REVIEW" MODIFY "STATUS" VARCHAR(10);
ALTER TABLE "BDIITPE2"."EUSER" MODIFY "STATUS" VARCHAR(10);
ALTER TABLE "BDIITPE2"."SALE" MODIFY "STATUS" VARCHAR(10);
ALTER TABLE "BDIITPE2"."SCORE" MODIFY "STATUS" VARCHAR(10);

CREATE INDEX "BDIITPE2"."REVIEW_CREATED_ROLE_STATUS" ON "BDIITPE2"."REVIEW" ("CREATED","ROLE","STATUS") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 10240 NEXT 10240 MINEXTENTS 1 MAXEXTENTS 121
  PCTINCREASE 50 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "BDIITPE21C_INDEXES" ;

CREATE INDEX "BDIITPE2"."REVIEW_MODIFIED" ON "BDIITPE2"."REVIEW" ("MODIFIED") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 10240 NEXT 10240 MINEXTENTS 1 MAXEXTENTS 121
  PCTINCREASE 50 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "BDIITPE21C_INDEXES" ;

CREATE INDEX "BDIITPE2"."REVIEW_ROLE_STATUS" ON "BDIITPE2"."REVIEW" ("ROLE","STATUS") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 10240 NEXT 10240 MINEXTENTS 1 MAXEXTENTS 121
  PCTINCREASE 50 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "BDIITPE21C_INDEXES" ;