--Данный код выполняет вставку в БД тестовых данных-- 


--Subscribers--
INSERT INTO public."Subscriber"(
	"FullName", "FullNameID", "Adress")
	VALUES ('Куклов Антон Федотович', 'S000000001', 'Россия, г. Тамбов, Полевой пер., д. 18 кв.107');
INSERT INTO public."Subscriber"(
	"FullName", "FullNameID", "Adress")
	VALUES ('Бодрова Рада Ефремовна', 'S000000002', 'Россия, г. Хасавюрт, Мирная ул., д. 23 кв.54');
INSERT INTO public."Subscriber"(
	"FullName", "FullNameID", "Adress")
	VALUES ('Капустов Илья Петрович', 'S000000003', 'Россия, г. Набережные Челны, Колхозный пер., д. 8 кв.118');
INSERT INTO public."Subscriber"(
	"FullName", "FullNameID", "Adress")
	VALUES ('Лигачёва Полина Макаровна', 'S000000004', 'Россия, г. Казань, Луговой пер., д. 6 кв.128');
INSERT INTO public."Subscriber"(
	"FullName", "FullNameID", "Adress")
	VALUES ('Климушин Антон Тимофеевич', 'S000000005', 'Россия, г. Калуга, Интернациональная ул., д. 11 кв.149');
--end--

--Договор--
INSERT INTO public."Treaty"(
	"ID", "PhoneNumber", "StartTreatyDate", "FullNameID")
	VALUES ('T000000004', '+7 (960) 275-58-80', '04.12.2017', 'S000000001');
INSERT INTO public."Treaty"(
	"ID", "PhoneNumber", "StartTreatyDate", "FullNameID")
	VALUES ('T000000002', '+7 (944) 845-13-99', '07.12.2022', 'S000000002');
INSERT INTO public."Treaty"(
	"ID", "PhoneNumber", "StartTreatyDate", "FullNameID")
	VALUES ('T000000003', '+7 (985) 328-18-98', '15.07.2020', 'S000000003');
INSERT INTO public."Treaty"(
	"ID", "PhoneNumber", "StartTreatyDate", "FullNameID")
	VALUES ('T000000001', '+7 (930) 173-16-65', '20.01.2022', 'S000000004');
INSERT INTO public."Treaty"(
	"ID", "PhoneNumber", "StartTreatyDate", "FullNameID")
	VALUES ('T000000005', '+7 (949) 408-14-51', '21.01.2019', 'S000000005');
INSERT INTO public."Treaty"(
	"ID", "PhoneNumber", "StartTreatyDate", "FullNameID")
	VALUES ('T000000006', '+7 (955) 689-66-18', '22.05.2021', 'S000000001');
--end--

--Тариф--
INSERT INTO public."Rate"(
	"RateID", "RateName", "BaseMinAmount", "BaseMessAmount", "BaseGbtAmount", "BasePrice", "MinPrice")
	VALUES ('R000000005', 'BigBlackRate', 300, 600, 45, 320, 1);
INSERT INTO public."Rate"(
	"RateID", "RateName", "BaseMinAmount", "BaseMessAmount", "BaseGbtAmount", "BasePrice", "MinPrice")
	VALUES ('R000000004', 'AllIn', 0, 100, 60, 200, 5);
INSERT INTO public."Rate"(
	"RateID", "RateName", "BaseMinAmount", "BaseMessAmount", "BaseGbtAmount", "BasePrice", "MinPrice")
	VALUES ('R000000003', 'Fikigu', 0, 100, 15, 120, 227);
INSERT INTO public."Rate"(
	"RateID", "RateName", "BaseMinAmount", "BaseMessAmount", "BaseGbtAmount", "BasePrice", "MinPrice")
	VALUES ('R000000002', 'Пырка', 1, 1, 1, 99, 0);
INSERT INTO public."Rate"(
	"RateID", "RateName", "BaseMinAmount", "BaseMessAmount", "BaseGbtAmount", "BasePrice", "MinPrice")
	VALUES ('R000000001', 'Бесперспективняк', 999, 999, 99, 222, 999);
INSERT INTO public."Rate"(
	"RateID", "RateName", "BaseMinAmount", "BaseMessAmount", "BaseGbtAmount", "BasePrice", "MinPrice")
	VALUES ('R000000006', 'Useless', 0, 0, 0, 33333, 999);
--end--

--Договор_Тариф--
INSERT INTO public."Treaty_Rate"(
	"ID", "RateConnectionDate", "TreatyID", "RateID", "Balance")
	VALUES ('TR00000001', '27.03.2022', 'T000000003', 'R000000001', '156');
INSERT INTO public."Treaty_Rate"(
	"ID", "RateConnectionDate", "TreatyID", "RateID", "Balance")
	VALUES ('TR00000002', '07.04.2022', 'T000000005', 'R000000002', '128');
INSERT INTO public."Treaty_Rate"(
	"ID", "RateConnectionDate", "TreatyID", "RateID", "Balance")
	VALUES ('TR00000003', '24.06.2022', 'T000000002', 'R000000003', '12');
INSERT INTO public."Treaty_Rate"(
	"ID", "RateConnectionDate", "TreatyID", "RateID", "Balance")
	VALUES ('TR00000004', '14.02.2022', 'T000000001', 'R000000004', '132');
INSERT INTO public."Treaty_Rate"(
	"ID", "RateConnectionDate", "TreatyID", "RateID", "Balance")
	VALUES ('TR00000005', '15.01.2022', 'T000000004', 'R000000005', '155');

--upd--
UPDATE "Treaty_Rate"
	Set "GbtAmount" = "Rate"."BaseGbtAmount"
		FROM "Rate" 
	Where "Treaty_Rate"."RateID" = "Rate"."RateID";

UPDATE "Treaty_Rate"
	Set "MinAmount" = "Rate"."BaseMinAmount"
		FROM "Rate" 
	Where "Treaty_Rate"."RateID" = "Rate"."RateID";

UPDATE "Treaty_Rate"
	Set "MessAmount" = "Rate"."BaseMessAmount"
		FROM "Rate" 
	Where "Treaty_Rate"."RateID" = "Rate"."RateID";
--upd_end--

--end--

--Зона--
INSERT INTO public."Zone"("ZoneCode", "Coefficient", "ZoneType", "ZoneName")
	VALUES ('+7', 1, 'Internal', 'Russia'),
	('8', 1, 'Internal', 'Russia'),
	('+375', 1, 'FriendlyAbroad', 'Belarus'),
	('+86', 1.2, 'FriendlyAbroad', 'China'),
	('+82', 2, 'FarAbroad', 'Korea');

--end--

--call--
INSERT INTO public."Call"(
	"ID", "ZoneCodeID", "RateID", "TreatyID", "Treaty_Rate_ID", "TargetPnoneNumber", "StartCallDate", "CallDuration", "PaymentState", "PaymentDate", "DateOfActualPayment")
	VALUES
	('C000000001', '1', 'R000000003', 'T000000001', 'TR00000001', '+7 (944) 845-13-99', '2022-03-30 01:01:01', '00:01:12', 'false', '2022-03-30 01:01:01', null),
	('C000000002', '1', 'R000000003', 'T000000001', 'TR00000001', '+7 (944) 845-13-99', '2022-04-02 12:00:00', '00:25:11', 'false', '2022-04-02 12:00:00', null),
	('C000000003', '1', 'R000000003', 'T000000001', 'TR00000001', '+7 (955) 689-66-18', '2022-04-02 04:00:00', '00:00:30', 'false', '2022-04-02 04:00:00', null),
	('C000000004', '1', 'R000000001', 'T000000004', 'TR00000004', '+7 (955) 689-66-18', '2022-04-05 02:22:22', '00:02:22', 'false', '2022-04-05 02:22:22', null),
	('C000000005', '2', 'R000000001', 'T000000003', 'TR00000001', '8 (944) 845-13-99', '2022-03-06 11:11:11', '00:30:21', 'false', '2022-03-06 11:11:11', null),
	('C000000006', '2', 'R000000002', 'T000000005', 'TR00000002', '8 (955) 689-66-18', '2022-04-06 7:30:33', '00:10:23', 'false', '2022-04-06 7:30:33', null),
	('C000000007', '3', 'R000000005', 'T000000004', 'TR00000005', '+380 (44) 357-14-91', '2022-04-06 9:22:22', '00:01:22', 'false', '2022-04-06 9:22:22', null),
	('C000000008', '3', 'R000000005', 'T000000004', 'TR00000005', '+380 (95) 563-78-90', '2022-04-01 10:22:22', '00:11:15', 'false', '2022-04-01 10:22:22', null),
	('C000000009', '3', 'R000000003', 'T000000002', 'TR00000003', '+380 (67) 917-93-71', '2022-04-07 15:22:22', '00:33:20', 'false', '2022-04-07 15:22:22', null),
	('C000000010', '4', 'R000000003', 'T000000002', 'TR00000003', '+86 (10) 773-17-861', '2022-04-12 12:22:22', '00:05:11', 'false', '2022-04-12 12:22:22', null),
	('C000000011', '4', 'R000000001', 'T000000003', 'TR00000001', '+86 (15) 859-19-101', '2022-05-22 15:22:22', '00:00:45', 'false', '2022-05-22 15:22:22', null),
	('C000000012', '5', 'R000000002', 'T000000005', 'TR00000002', '+82 (10) 418-10-85', '2022-03-11 01:22:22', '00:02:22', 'false', '2022-03-11 01:22:22', null),
	('C000000013', '5', 'R000000004', 'T000000001', 'TR00000004', '+82 (11) 428-41-33', '2022-04-13 02:22:22', '00:10:01', 'false', '2022-04-13 02:22:22', null),
	('C000000014', '5', 'R000000005', 'T000000004', 'TR00000005', '+82 (12) 043-26-78', '2022-05-15 3:22:22', '01:35:53', 'false', '2022-05-15 3:22:22', null);
--end--

--Доп. услуги--
INSERT INTO public."AdditionalServices"(
	"ID", "ASName", "AddMinAmount", "AddMessAmount", "AddGbtAmount", "ASPrice", "PaymentFrequency")
	VALUES ('AS00000001', 'Dop Minutes Month Rate', 100, 0, 0, 111, 'mon'),
	('AS00000002', 'Dop Messages Month Rate', 0, 200, 0, 112, 'mon'),
	('AS00000003', 'Dop Gbt Month Rate', 0, 0, 15, 155, 'mon'),
	('AS00000004', 'Dop Gbt Week Rate', 0, 0, 15, 130, 'wek');
	
	--связь--
	INSERT INTO public."AdditionalServices_Treaty_Rate"(
	"AdditionalServices_ID", "Treaty_Rate_ID", "AS_TR_ID", "Connection_Date")
	VALUES ('AS00000002', 'TR00000004', 'CS00000001', '2023.04.20'),
	('AS00000001', 'TR00000004', 'CS00000002', '2023.04.19'),
	('AS00000004', 'TR00000003', 'CS00000003', '2023.04.18');
--end--

--Сторонние ресурсы--
INSERT INTO public."ThirdPartyResources"(
	"ID", "TPRName", "Description", "Price", "PaymentFrequency")
	VALUES ('TR00000001', 'КРок', 'Добавляет возможность выбирать музыку на звонок', 100, 'mon'),
	('TR00000002', 'Мотает срок', 'Добавляет возможность заказывать еду по телефону', 50, 'wek');

	--связь--
	INSERT INTO public."ThirdPartyResources_Treaty_Rate"(
	"ThirdPartyResources_ID", "Treaty_Rate_ID", "TP_TR_ID", "Connection_Date")
	VALUES ('TR00000002', 'TR00000001', 'CR00000001', '2023.04.20'),
	('TR00000001', 'TR00000001', 'CR00000002', '2023.04.19'),
	('TR00000002', 'TR00000003', 'CR00000003', '2023.04.18'),
	('TR00000001', 'TR00000003', 'CR00000004', '2023.04.18');
--end--