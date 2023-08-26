--В данном файле представлены запросы на обновление и удаление, 
	--выполняющие некоторые рутинные задачи--


--UPDATE--
--Вычисление и установка суммы звонка, для всех звонков, стоимость которых неизвестна--
DO $$DECLARE i Record;
BEGIN For i IN (SELECT "Call"."ID" FROM "Call")
	LOOP
		UPDATE "Call"
			SET "Price" = 
				(SELECT tb."CallPrice" FROM
					(SELECT "Call"."ID", (((date_part('hour', "Call"."CallDuration") * 60) + (date_part('minute', "Call"."CallDuration")) + (date_part('second', "Call"."CallDuration") / 60))::numeric * "Zone"."Coefficient" * ("Rate"."MinPrice")::numeric) as "CallPrice" 
						From "Call", "Rate", "Zone"
						WHERE "Rate"."RateID" = "Call"."RateID" and "Zone"."ZoneCodeID" = "Call"."ZoneCodeID" and "Call"."Price" is NULL) AS tb LIMIT 1)::numeric::money
			WHERE i."ID" = "Call"."ID" and "Call"."Price" is null;
	end loop;
end$$;

--end--
		

--DELETE--
--Удаление тарифов, которые не используются и не использовались никогда, ни одним из абонентов--
DELETE FROM "Rate" AS Rt
	where Rt."RateID" NOT IN 
	(Select tbl."RateID" From 
		(SELECT "Rate"."RateID", count("Treaty_Rate"."RateID") FROM "Rate"
			Left Join "Treaty_Rate" 
		 		ON "Treaty_Rate"."RateID" = "Rate"."RateID"
			Group BY "Rate"."RateID") as tbl
			WHERE tbl."count" != 0
	)
	and
	Rt."RateID" NOT IN 
	(Select tbl2."RateID" From 
		(SELECT "Rate"."RateID", count("Call"."RateID") FROM "Rate"
			Left Join "Call" 
		 		ON "Call"."RateID" = "Rate"."RateID"
			Group BY "Rate"."RateID") as tbl2
			WHERE tbl2."count" != 0
	)
--end--
	

--index--

--end--


DO $$DECLARE i Record;
BEGIN For i IN (SELECT "Call"."ID" FROM "Call")
	LOOP
		UPDATE "Call"
			SET "Price" = 
				tb."CallPrice"  FROM
					(SELECT "Call"."ID", ((date_part('hour', "Call"."CallDuration") * 60) + (date_part('minute', "Call"."CallDuration")) + (date_part('second', "Call"."CallDuration") / 60) * CAST("Rate"."MinPrice" AS numeric) * "Zone"."Coefficient") as "CallPrice" 
						From "Call", "Rate", "Zone"
						WHERE "Rate"."RateID" = "Call"."RateID" and "Zone"."ZoneCodeID" = "Call"."ZoneCodeID" and "Call"."Price" is NULL) AS tb LIMIT 1)::numeric::money
			WHERE i."ID" = "Call"."ID" and "Call"."Price" is null;
			
		UPDATE "Call"
			SET "PaymentState" = 'true'
			inner join
				(SELECT "Call"."ID", ((date_part('hour', "Call"."CallDuration") * 60) + (date_part('minute', "Call"."CallDuration")) + (date_part('second', "Call"."CallDuration") / 60)) as "CallDurationMin" 
					From "Call", "Rate"
				 	JOIN public."Zone" 
						ON ("Zone"."ZoneCodeID" = "Call"."ZoneCodeID" and "Zone"."ZoneType" != 'Internal')
					WHERE "Rate"."RateID" = "Call"."RateID" and "Call"."PaymentState" = 'false') AS tb LIMIT 1)
			inner join "Treaty_Rate"
			WHERE i."ID" = "Call"."ID" and i."Treaty_Rate_ID" = "Treaty_Rate"."ID" and tb."CallDurationMin" <= "Treaty_Rate"."MinAmount";
			
			
		UPDATE "Treaty_Rate"
			SET "Balance" = "Balance" -
				(SELECT tb."CallPrice"  FROM
					(SELECT Distinct "Call"."ID", "Call"."Price" as "CallPrice" 
						From "Call"
						JOIN public."Zone" 
							ON ("Zone"."ZoneCodeID" = "Call"."ZoneCodeID")
						WHERE "Call"."Price" is not NULL and "Call"."PaymentState" = 'false')
					AS tb LIMIT 1)::numeric
			WHERE i."Treaty_Rate_ID" = "Treaty_Rate"."ID" and "Call"."Price" is null;
	end loop;
end$$;
