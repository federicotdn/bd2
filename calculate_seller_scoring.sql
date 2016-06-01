create or replace PACKAGE BODY scoring_pkg AS  -- body

   -- Cursor de vendedores cuyas calificaciones sufrieron modificaciones
   -- o cuya reputacion hay que actualizar porque es "vieja" (de mas de 1 semana)
   CURSOR SELLER_CUR( pInterval NUMBER ) IS 
   SELECT DISTINCT SELLER_ID AS USER_ID 
   FROM SALE S
   WHERE EXISTS (
        SELECT 1
        FROM REVIEW R
        WHERE S.ID = R.SALE_ID
        AND MODIFIED >= ( SYSDATE - pInterval ) 
   );

   CURSOR LAST_N_REVIEWS( pInterval NUMBER ) IS
   SELECT CREATED, SCORE
   FROM REVIEW
   WHERE USER_ID = SELLER_REC.USER_ID
   AND CREATED > SYSDATE - pInterval
   AND ROLE = 'SELLER'
   AND STATUS = 'PUBLISHED';


   -- Procedimiento que actualiza la reputacion de un vendedor 
   PROCEDURE update_seller_scoring( pUserId NUMBER, 
	  p7Positive NUMBER, p7Negative NUMBER, p7Neutral NUMBER,
	  p30Positive NUMBER, p30Negative NUMBER, p30Neutral NUMBER,
	  p180Positive NUMBER, p180Negative NUMBER, p180Neutral NUMBER,
	  pScoreTotal NUMBER, pCountTotal NUMBER
	  ) AS
	  vRATIO NUMBER(10,10):=0;
   BEGIN
		
		IF pCountTotal <=0 THEN 
			vRATIO:=0;
		ELSE 
			vRATIO:=round(pScoreTotal/pCountTotal,2) ;
		END IF;
   
	   --Intento la actualización
       UPDATE SCORE 
	   SET  
	   	LAST_WEEK_POSITIVE = p7Positive,
		LAST_WEEK_NEUTRAL = p7Neutral,
		LAST_WEEK_NEGATIVE  = p7Negative,
		LAST_MONTH_POSITIVE = p30Positive,
		LAST_MONTH_NEUTRAL = p30Neutral,
		LAST_MONTH_NEGATIVE = p30Negative,
		LAST_6MONTH_POSITIVE = p180Positive,
		LAST_6MONTH_NEUTRAL = p180Neutral,
		LAST_6MONTH_NEGATIVE = p180Negative,
		SCORE = vRATIO,
		MODIFIED = sysdate
	   WHERE USER_ID = pUserId;
	   -- Si no existe, inserto el registro
	   IF SQL%NOTFOUND then
         INSERT INTO SCORE ( USER_ID, 
				LAST_WEEK_POSITIVE, LAST_WEEK_NEUTRAL, LAST_WEEK_NEGATIVE,
				LAST_MONTH_POSITIVE, LAST_MONTH_NEUTRAL, LAST_MONTH_NEGATIVE,
				LAST_6MONTH_POSITIVE, LAST_6MONTH_NEUTRAL, LAST_6MONTH_NEGATIVE,
				SCORE, STATUS, CREATED, MODIFIED ) 
         VALUES ( pUserId,
				p7Positive, p7Neutral, p7Negative,
				p30Positive, p30Neutral, p30Negative,
				p180Positive, p180Neutral, p180Negative,
				vRATIO, 'ACTIVE', SYSDATE, SYSDATE
				);
       END IF;
	   COMMIT;
   END update_seller_scoring;
   
   -- Procedimiento que calcula el puntaje de los vendedores
   PROCEDURE calculate_seller_scoring( ndays NUMBER )  AS
      v7Positive NUMBER(6) := 0;
	  v7Negative NUMBER(6) := 0;
	  v7Neutral NUMBER(6) := 0;
	  v30Positive NUMBER(6) := 0;
	  v30Negative NUMBER(6) := 0;
	  v30Neutral NUMBER(6) := 0;
	  v180Positive NUMBER(6) := 0;
	  v180Negative NUMBER(6) := 0;
	  v180Neutral NUMBER(6) := 0;
	  vScoreTotal NUMBER(6) := 0;
	  vCountTotal NUMBER(6) := 0;
   BEGIN
      
	  -- Por cada seller,
	  FOR SELLER_REC IN SELLER_CUR(ndays) LOOP
		-- Buscar el puntaje recibido en las ventas de la ultima semana
		FOR REVIEW_REC IN LAST_N_REVIEWS(180) LOOP
			IF REVIEW_REC.SCORE = 'POSITIVE'  THEN 
				IF REVIEW_REC.CREATED > ( SYSDATE - 7 ) 
					v7Positive = v7Positive + 1;
				IF REVIEW_REC.CREATED > ( SYSDATE - 30 ) 
					v30Positive = v30Positive + 1;
				v180Positive = v180Positive + 1;

			IF REVIEW_REC.SCORE = 'NEGATIVE'  THEN 
				IF REVIEW_REC.CREATED > ( SYSDATE - 7 ) 
					v7Negative = v7Negative + 1;
				IF REVIEW_REC.CREATED > ( SYSDATE - 30 ) 
					v30Negative = v30Negative + 1;
				v180Negative = v180Negative + 1;


			IF REVIEW_REC.SCORE = 'NEUTRAL'  THEN 
				IF REVIEW_REC.CREATED > ( SYSDATE - 7 ) 
					v7Neutral = v7Neutral + 1;
				IF REVIEW_REC.CREATED > ( SYSDATE - 30 ) 
					v30Neutral = v30Neutral + 1;
				v180Neutral = v180Neutral + 1;

		END LOOP;

		-- Buscar el puntaje recibido en las ventas totales	

		SELECT  nvl(
					sum(
						CASE SCORE 
						WHEN 'POSITIVE' THEN 1 
						WHEN 'NEGATIVE' THEN -1 
						ELSE 0 END
				), 0)
				, COUNT(1) INTO vScoreTotal, vCountTotal
		FROM REVIEW
		WHERE USER_ID = SELLER_REC.USER_ID
		AND ROLE = 'SELLER'
		AND STATUS = 'PUBLISHED' ;		
		-- Insertar el puntaje actualizado
		update_seller_scoring( SELLER_REC.USER_ID, 
						v7Positive, v7Negative, v7Neutral, 
						v30Positive, v30Negative, v30Neutral, 
						v180Positive, v180Negative, v180Neutral, 
						vScoreTotal, vCountTotal
						); 
	  END LOOP;
	  
   END calculate_seller_scoring;
END scoring_pkg;