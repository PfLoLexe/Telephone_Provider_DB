
--Task2--


--Вывести суммарное время переговоров каждого абонента за заданный период--
SELECT Distinct Subs."FullName", sum(Call."CallDuration") FROM public."Subscriber" as Subs 
	Left Join public."Treaty" as Tr ON Subs."FullNameID" = Tr."FullNameID"
	LEFT JOIN public."Call" as Call ON Call."TreatyID" = Tr."ID" and Call."StartCallDate" 
		BETWEEN '2022-04-01' and '2022-04-10'
	Group By Subs."FullNameID"  
--end--

--Найти среднюю продолжительность разговора абонента АТС--
SELECT Subs."FullName", avg(Call."CallDuration") FROM public."Call" as Call, public."Subscriber" as Subs, public."Treaty" as Tr 
	WHERE Subs."FullNameID" = Tr."FullNameID" and Call."TreatyID" = Tr."ID"
	Group By Subs."FullName" 
--end--

--Вывести количество междугородных переговоров каждого абонента--
SELECT Subs."FullName", count(Call."ID") FROM public."Call" as Call
	JOIN public."Zone" as Zone ON (Zone."ZoneCodeID" = Call."ZoneCodeID" and Zone."ZoneType" != 'Internal')
	Right JOIN public."Treaty" as Tr ON Call."TreatyID" = Tr."ID"
	Right Join public."Subscriber" as Subs ON Subs."FullNameID" = Tr."FullNameID"
	Group By Subs."FullName";
--end--

--Вывести список абонентов, не внѐсших оплату за прошедший месяц--
SELECT DISTINCT Subs."FullName" FROM public."Subscriber" as Subs, public."Treaty" as Tr, public."Treaty_Rate" as T_R
	WHERE Subs."FullNameID" = Tr."FullNameID" and T_R."TreatyID" = Tr."ID" and T_R."LastMonthPayStatus" = 'false'
--end--

--Сколько звонков было сделано в каждый из следующих городов: в Москву, Лондон, Париж--
SELECT Zone."ZoneName", count(Call."ID") FROM public."Call" as Call
	JOIN public."Zone" as Zone ON (Zone."ZoneCodeID" = Call."ZoneCodeID" and
		(Zone."ZoneCodeID" = 3 or Zone."ZoneCodeID" = 4 or Zone."ZoneCodeID" = 5))
	Group By Zone."ZoneName";
end--

--Вывести список абонентов, звонивших только в ночное время--
SELECT Subs."FullName" FROM public."Call" as Call, public."Subscriber" as Subs, public."Treaty" as Tr 
	WHERE Subs."FullNameID" = Tr."FullNameID" and Call."TreatyID" = Tr."ID" and 
	Call."TreatyID" not In ( 
		Select Distinct Call."TreatyID" FROM public."Call" as Call WHERE 							 		( (cast(Call."StartCallDate" as time without time zone) >= '5:00:00' 
		and cast(Call."StartCallDate" as time without time zone) <= '23:0:0') ) )
--end--

--Вывести список абонентов, время разговоров которых превышает среднее для этой же зоны--
SELECT Distinct Sum_Sel."FullName", Sum_Sel."ZoneName"
	From
		(SELECT Subs."FullName", Zone."ZoneCodeID", sum(Call."CallDuration"), Zone."ZoneName"
			FROM public."Subscriber" as Subs, public."Treaty" as Tr, public."Call" as Call, public."Zone" as Zone
			WHERE Subs."FullNameID" = Tr."FullNameID" and Call."TreatyID" = Tr."ID" and 
				Call."ZoneCodeID" = Zone."ZoneCodeID"
			GROUP BY Subs."FullName", Zone."ZoneCodeID"
		) as Sum_Sel, 
		(SELECT Zone."ZoneCodeID", avg(Call."CallDuration") 
			FROM public."Call" as Call, public."Zone" as Zone
			WHERE Zone."ZoneCodeID" = Call."ZoneCodeID"
			GROUP BY Zone."ZoneCodeID"
		) as AVG_T
	Where Sum_Sel."ZoneCodeID" = AVG_T."ZoneCodeID"
		and Sum_Sel."sum" > AVG_T."avg"

--end--

--Task2 end--


--Task3--
--Создать представление, cодержащее сведения обо всех абонентах и их переговорах за прошедший месяц--
CREATE VIEW Subs_Status AS
	SELECT Subs."FullName", Subs."Adress", Call."Treaty_Rate_ID", Call."ID", Call."TargetPnoneNumber", Call."StartCallDate", Call."CallDuration", Call."PaymentState" FROM "Subscriber" as Subs 
		Left Join public."Treaty" as Tr ON Subs."FullNameID" = Tr."FullNameID"
		left JOIN public."Call" as Call ON Call."TreatyID" = Tr."ID" 
			and date_part('month', Call."StartCallDate") = date_part('month', current_date)  
--end--

--Создать представление, содержащее самую популярную зону звонков за истекший год --
CREATE VIEW MostPopZone AS
	SELECT Zn."ZoneName" as "Zone Name", SeL."count" as "Max Call Count" 
		FROM "Zone" as Zn, 
			(Select Call."ZoneCodeID", count(Call."ID") FROM "Call" as Call
			 	Where date_part('year', Call."StartCallDate") = (date_part('year', current_date)-1)
				Group By Call."ZoneCodeID"
			) AS SeL
		Where SeL."ZoneCodeID" = Zn."ZoneCodeID" and 
			SeL."count" = (SELECT max(SeL."count") FROM (Select Call."ZoneCodeID", count(Call."ID") FROM "Call" as Call Group By Call."ZoneCodeID") AS SeL)
		Group By Zn."ZoneCodeID", SeL."count"
--end--

--Task3 end--