
--Функция, реализующая вывод списка всех звонков заданного абонента--
CREATE FUNCTION getCalls(person_name text)
RETURNS TABLE(CallID text)
LANGUAGE SQL
AS $$
	(SELECT Call."ID" FROM "Call" as Call 
	Left Join public."Treaty" as Tr ON Call."TreatyID" = Tr."ID"
	WHERE Tr."FullNameID" = person_name)
$$;

--SELECT * FROM getCalls('S000000005');
--end--


--Функция, реализующая вывод задолженности по оплате для заданного абонента--
CREATE OR REPLACE FUNCTION getPersonCreditValue(person_name text)
RETURNS TABLE (PersonCreditValue text)
LANGUAGE SQL
AS $$
SELECT CallCredit."sum"+RateCredit."sum" FROM 
	((SELECT sum(Call."Price"::numeric) FROM public."Treaty" as Tr
		LEFT JOIN public."Call" as Call ON Call."TreatyID" = Tr."ID" and Call."PaymentState"='false' 
		WHERE Tr."FullNameID" = person_name
	 ) LIMIT 1) as CallCredit ,
	((SELECT sum("Rate"."BasePrice"::numeric) FROM  public."Treaty" as Tr
		Left Join "Treaty_Rate" as T_R ON T_R."TreatyID" = Tr."ID" and T_R."LastMonthPayStatus"='false'
		Left Join "Rate" ON T_R."RateID" = "Rate"."RateID" 
		WHERE Tr."FullNameID" = person_name
	 ) LIMIT 1) as RateCredit
$$;

--SELECT * FROM getPersonCreditValue('S000000005');
--end--


--Функция, выполняющая рассчет общей стоимости звонков по каждой зоне за истекшую неделю--
CREATE OR REPLACE FUNCTION getZoneCallPrice()
RETURNS TABLE (ZoneName text, ZoneCode text, SumPrice numeric)
LANGUAGE SQL
AS $$
	SELECT Distinct ZN."ZoneName", Zn."ZoneCode", sum(Call."Price") FROM "Zone" as Zn 
		LEFT JOIN public."Call" as Call ON Zn."ZoneCodeID" = Call."ZoneCodeID" and
			Call."StartCallDate" BETWEEN NOW() - interval '7 day' and NOW()
		Group By Zn."ZoneCodeID"
$$;

--SELECT * FROM getZoneCallPrice();
--end--

--Триггер выполняющий расчет стоимости звонка, данные которого были занесены в БД--

CREATE OR REPLACE FUNCTION SetCallPrice() RETURNS TRIGGER AS $my_table$
	BEGIN
	UPDATE "Call" SET "Price" = 
		(SELECT tb."CallPrice" FROM
			(SELECT "Call"."ID", (((date_part('hour', "Call"."CallDuration") * 60) + (date_part('minute', "Call"."CallDuration")) + (date_part('second', "Call"."CallDuration") / 60))::numeric * "Zone"."Coefficient" * ("Rate"."MinPrice")::numeric) as "CallPrice" 
				From "Call", "Rate", "Zone"
				WHERE "Rate"."RateID" = "Call"."RateID" and "Zone"."ZoneCodeID" = "Call"."ZoneCodeID" and "Call"."Price" is NULL
				AND new."ID" = "Call"."ID"
			) AS tb)::numeric::money
		WHERE new."ID" = "Call"."ID" and "Call"."Price" is NULL;
	Return NEW;
	END;
	$my_table$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER CallPriceAndPaymentCalc
	AFTER INSERT on "Call"
	FOR EACH row 
	WHEN (NEW."Price" is NULL)
	EXECUTE PROCEDURE SetCallPrice();

--
