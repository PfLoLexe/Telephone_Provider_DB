
--Данный код выполняет создание реляционной БД в СУБД PostgreSQL--

BEGIN;


CREATE TABLE IF NOT EXISTS public."AdditionalServices"
(
    "ID" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("ID") = 10),
    "ASName" text COLLATE pg_catalog."default" NOT NULL,
    "AddMinAmount" integer NOT NULL CHECK("AddMinAmount" >= 0),
    "AddMessAmount" integer NOT NULL CHECK("AddMessAmount" >= 0),
    "AddGbtAmount" integer NOT NULL CHECK("AddGbtAmount" >= 0),
    "ASPrice" money NOT NULL CHECK("ASPrice"::money::numeric > 0),
    "PaymentFrequency" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("PaymentFrequency") = 3),
    CONSTRAINT "AdditionalServices_pkey" PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS public."AdditionalServices_Treaty_Rate"
(
    "AdditionalServices_ID" text COLLATE pg_catalog."default" NOT NULL,
    "Treaty_Rate_ID" text COLLATE pg_catalog."default" NOT NULL,
    "AS_TR_ID" text NOT NULL CHECK(char_length("AS_TR_ID") = 10),
    "Connection_Date" date NOT NULL CHECK("Connection_Date" <= CURRENT_DATE),
    "Shutdown_Date" date CHECK("Shutdown_Date" >= "Connection_Date"),
    CONSTRAINT "AS_Treaty_Rate_pkey" PRIMARY KEY ("AS_TR_ID")	
);

CREATE TABLE IF NOT EXISTS public."Call"
(
    "ID" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("ID") = 10),
    "ZoneCodeID" integer NOT NULL,
    "RateID" text COLLATE pg_catalog."default" NOT NULL,
    "TreatyID" text COLLATE pg_catalog."default" NOT NULL,
    "Treaty_Rate_ID" text COLLATE pg_catalog."default" NOT NULL,
    "TargetPnoneNumber" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("TargetPnoneNumber") <= 21 and char_length("TargetPnoneNumber") > 10),
    "StartCallDate" timestamp without time zone NOT NULL,
    "CallDuration" time without time zone NOT NULL,
    "Price" money,
    "PaymentState" boolean NOT NULL,
    "PaymentDate" timestamp without time zone NOT NULL CHECK("PaymentDate" >= "StartCallDate"),
    "DateOfActualPayment" timestamp without time zone CHECK("DateOfActualPayment" >= "PaymentDate"),
    CONSTRAINT "Call_pkey" PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS public."Rate"
(
    "RateID" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("RateID") = 10),
    "RateName" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("RateName") <= 30 and char_length("RateName") > 0),
    "BaseMinAmount" integer NOT NULL CHECK("BaseMinAmount" >= 0),
    "BaseMessAmount" integer NOT NULL CHECK("BaseMessAmount" >= 0),
    "BaseGbtAmount" integer NOT NULL CHECK("BaseGbtAmount" >= 0),
    "BasePrice" money NOT NULL CHECK("BasePrice"::money::numeric > 0),
    "MinPrice" money NOT NULL CHECK("MinPrice"::money::numeric >= 0),
    CONSTRAINT "Rate_pkey" PRIMARY KEY ("RateID")
);

CREATE TABLE IF NOT EXISTS public."Subscriber"
(
    "FullName" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("FullName") <= 50 and char_length("FullName")>0),
    "FullNameID" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("FullNameID") = 10),
    "Adress" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("Adress") <= 100 and char_length("Adress") > 0),
    CONSTRAINT "Subscriber_pkey" PRIMARY KEY ("FullNameID")
);

CREATE TABLE IF NOT EXISTS public."ThirdPartyResources"
(
    "ID" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("ID") = 10),
    "TPRName" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("TPRName") <= 30 and char_length("TPRName")>0),
    "Description" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("Description") <= 500),
    "Price" money NOT NULL CHECK("Price"::money::numeric > 0),
    "PaymentFrequency" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("PaymentFrequency") = 3),
    CONSTRAINT "ThirdPartyResources_pkey" PRIMARY KEY ("ID")
);

CREATE TABLE IF NOT EXISTS public."ThirdPartyResources_Treaty_Rate"
(
    "ThirdPartyResources_ID" text COLLATE pg_catalog."default" NOT NULL,
    "Treaty_Rate_ID" text COLLATE pg_catalog."default" NOT NULL,
    "TP_TR_ID" text NOT NULL CHECK(char_length("TP_TR_ID") = 10),
    "Connection_Date" date NOT NULL CHECK("Connection_Date" <= CURRENT_DATE),
    "Shutdown_Date" date CHECK("Shutdown_Date" >= "Connection_Date"),  
    CONSTRAINT "ThirdPartyResources_Treaty_Rate_pkey" PRIMARY KEY ("TP_TR_ID")
);

CREATE TABLE IF NOT EXISTS public."Treaty"
(
    "ID" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("ID") = 10),
    "PhoneNumber" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("PhoneNumber") <= 18 and char_length("PhoneNumber")>10),
    "StartTreatyDate" date NOT NULL CHECK("StartTreatyDate" <= CURRENT_DATE),
    "Shutdown_Date" date CHECK("Shutdown_Date" >= "StartTreatyDate"),
    "FullNameID" text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Treaty_pkey" PRIMARY KEY ("ID"),
    CONSTRAINT "PNI" UNIQUE ("PhoneNumber")
        INCLUDE("PhoneNumber")
);

CREATE TABLE IF NOT EXISTS public."Treaty_Rate"
(
    "ID" text COLLATE pg_catalog."default" NOT NULL,
    "RateConnectionDate" date NOT NULL,
    "Shutdown_Date" date,
    "TreatyID" text COLLATE pg_catalog."default" NOT NULL,
    "RateID" text COLLATE pg_catalog."default" NOT NULL,
    "Balance" money NOT NULL,
    "MinAmount" integer CHECK("MinAmount" >= 0),
    "MessAmount" integer CHECK("MessAmount" >= 0),
    "GbtAmount" integer CHECK("GbtAmount" >= 0),
    "LastMonthPayStatus" boolean NOT NULL DEFAULT false,
    CONSTRAINT "Treaty_Rate_pkey" PRIMARY KEY ("ID"),
    CONSTRAINT "Treaty_Rate_RateID_key" UNIQUE ("RateID"),
    CONSTRAINT "Treaty_Rate_TreatyID_key" UNIQUE ("TreatyID")
);

CREATE TABLE IF NOT EXISTS public."Zone"
(
    "ZoneCode" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("ZoneCode") <= 4 and char_length("ZoneCode") >=1),
    "ZoneCodeID" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "Coefficient" numeric NOT NULL CHECK("Coefficient" > 0),
    "ZoneType" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("ZoneType") <= 15 and char_length("ZoneType")>0),
    "ZoneName" text COLLATE pg_catalog."default" NOT NULL CHECK(char_length("ZoneName") <= 30 and char_length("ZoneName")>0),
    CONSTRAINT "Zone_pkey" PRIMARY KEY ("ZoneCodeID")
);

ALTER TABLE IF EXISTS public."AdditionalServices_Treaty_Rate"
    ADD CONSTRAINT "AdditionalServices_Treaty_Rate_AdditionalServices_ID_fkey" FOREIGN KEY ("AdditionalServices_ID")
    REFERENCES public."AdditionalServices" ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."AdditionalServices_Treaty_Rate"
    ADD CONSTRAINT "AdditionalServices_Treaty_Rate_Treaty_Rate_ID_fkey" FOREIGN KEY ("Treaty_Rate_ID")
    REFERENCES public."Treaty_Rate" ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."Call"
    ADD CONSTRAINT "Call_RateID_fkey1" FOREIGN KEY ("RateID")
    REFERENCES public."Treaty_Rate" ("RateID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."Call"
    ADD CONSTRAINT "Call_TreatyID_fkey" FOREIGN KEY ("TreatyID")
    REFERENCES public."Treaty_Rate" ("TreatyID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."Call"
    ADD CONSTRAINT "Call_ZoneCode_fkey" FOREIGN KEY ("ZoneCodeID")
    REFERENCES public."Zone" ("ZoneCodeID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."Call"
    ADD CONSTRAINT "Treaty_Rate_ID" FOREIGN KEY ("Treaty_Rate_ID")
    REFERENCES public."Treaty_Rate" ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."ThirdPartyResources_Treaty_Rate"
    ADD CONSTRAINT "ThirdPartyResources_Treaty_Rate_ThirdPartyResources_ID_fkey" FOREIGN KEY ("ThirdPartyResources_ID")
    REFERENCES public."ThirdPartyResources" ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."ThirdPartyResources_Treaty_Rate"
    ADD CONSTRAINT "ThirdPartyResources_Treaty_Rate_Treaty_Rate_ID_fkey" FOREIGN KEY ("Treaty_Rate_ID")
    REFERENCES public."Treaty_Rate" ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."Treaty"
    ADD CONSTRAINT "Treaty_FullNameID_fkey" FOREIGN KEY ("FullNameID")
    REFERENCES public."Subscriber" ("FullNameID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."Treaty_Rate"
    ADD CONSTRAINT "R_Treaty_Rate" FOREIGN KEY ("RateID")
    REFERENCES public."Rate" ("RateID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
CREATE INDEX IF NOT EXISTS "Treaty_Rate_RateID_key"
    ON public."Treaty_Rate"("RateID");


ALTER TABLE IF EXISTS public."Treaty_Rate"
    ADD CONSTRAINT "T_Treaty_Rate" FOREIGN KEY ("TreatyID")
    REFERENCES public."Treaty" ("ID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
CREATE INDEX IF NOT EXISTS "Treaty_Rate_TreatyID_key"
    ON public."Treaty_Rate"("TreatyID");

END;
-- Удаление таблиц
   DROP TABLE IF EXISTS goods, categories;

   -- Создание таблицы categories
   CREATE TABLE categories (
      category_id INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      category_name VARCHAR(100) NOT NULL
   );

   -- Создание таблицы goods
   CREATE TABLE goods (
      product_id INT NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      product_name VARCHAR(100) NOT NULL,
      category INT NOT NULL DEFAULT 1,
      price NUMERIC(18,2) NULL,
    CONSTRAINT fk_category_goods FOREIGN KEY (category) REFERENCES categories (category_id)
);