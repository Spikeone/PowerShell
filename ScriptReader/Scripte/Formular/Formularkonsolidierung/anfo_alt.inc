   -- Tempo Tabelle anlegen
   create table #anftemp_alt(
      ANFORDERUNGX int null,
      PANFORDERUNGX int null,
      ANFORDERUNGTYP smallint null,
      FORMULARX int null,
      KATALOGANFX int null,
      PKATALOGANFX int null,
      SORT int,
      SUBSORT int,
      SUBSUBSORT int,
      EBENE int,
      ART char(1) null,
      ANALYTX int null,
      PANALYTX int null,
      ANA_ANALYTX int null,
      MFAANALYTX int null,
      DEFIX int null,
      BEHAELTERX int null,
      KENNUNG tinyint null,
      AUSWAHL tinyint null,
      LABELVAR varchar(32) null,
      DISPICON int null,
      PREIS money null,
      PUNKTE int null,
      BARCODEANFX int null)

   -- Anforderungen aus altem Formular
   insert into #anftemp_alt select
      R.ANFORDERUNGX,   -- ANFORDERUNGX
      null,             -- PANFORDERUNGX
      R.ANFORDERUNGTYP, -- ANFORDERUNGTYP
      R.FORMULARX,      -- FORMULARX
      null,             -- KATALOGANFX
      null,             -- PKATALOGANFX
      R.SORT,           -- SORT
      0,                -- SUBSORT
      0,                -- SUBSUBSORT
      R.EBENE,          -- EBENE
      R.ART,            -- ART
      R.ANALYTX,        -- ANALYTX
      R.PANALYTX,       -- PANALYTX
      null,             -- ANA_ANALYTX
      case when (A.KENNUNG = 7) then R.ANALYTX else null end,  -- MFAANALYTX
      R.DEFIX,          -- DEFIX
      R.BEHAELTERX,     -- BEHAELTERX
      A.KENNUNG,        -- KENNUNG
      R.AUSWAHL,        -- AUSWAHL
      R.LABELVAR,       -- LABELVAR
      R.DISPICON,       -- DISPICON
      null,             -- PREIS
      null,             -- PUNKTE
      null              -- BARCODEANFX
   from
      ANFORDERUNG R (index ANFORDERUNG_FK1), -- FORMULARX
      ANALYT A (index ANALYT_PK)             -- ANALYTX
   where
      R.FORMULARX = @formularx_alt
      and R.KATALOGANFX is null  -- abgeleitete Anforderungen aus dem Katalog erst im zweiten Schritt einfuegen
      and R.STORNODAT is null
      and R.ANALYTX *= A.ANALYTX
      and A.AKTIVBIS is null
      and A.STORNODAT is null

   if (@FORMULARTYP_alt = 1)
   begin
      -- abgeleitete Anforderungen aus dem Katalog einfuegen
      insert into #anftemp_alt select
         O.ANFORDERUNGX,   -- ANFORDERUNGX
         null,             -- PANFORDERUNGX
         R.ANFORDERUNGTYP, -- ANFORDERUNGTYP
         R.FORMULARX,      -- FORMULARX
         O.KATALOGANFX,    -- KATALOGANFX
         null,             -- PKATALOGANFX
         O.SORT,           -- SORT
         0,                -- SUBSORT
         0,                -- SUBSUBSORT
         O.EBENE,          -- EBENE
         R.ART,            -- ART
         R.ANALYTX,        -- ANALYTX
         R.PANALYTX,       -- PANALYTX
         null,             -- ANA_ANALYTX
         case when (A.KENNUNG = 7) then R.ANALYTX else null end,  -- MFAANALYTX
         R.DEFIX,          -- DEFIX
         R.BEHAELTERX,     -- BEHAELTERX
         A.KENNUNG,        -- KENNUNG
         R.AUSWAHL,        -- AUSWAHL
         R.LABELVAR,       -- LABELVAR
         R.DISPICON,       -- DISPICON
         null,             -- PREIS
         null,             -- PUNKTE
         null              -- BARCODEANFX
      from
         ANFORDERUNG O (index ANFORDERUNG_FK1), -- FORMULARX
         ANFORDERUNG R (index ANFORDERUNG_PK),  -- ANFORDERUNGX
         ANALYT A (index ANALYT_PK)             -- ANALYTX
      where
         O.FORMULARX = @formularx_alt
         and O.STORNODAT is null
         and O.KATALOGANFX = R.ANFORDERUNGX
         and R.STORNODAT is null
         and R.ANALYTX *= A.ANALYTX
         and A.AKTIVBIS is null
         and A.STORNODAT is null
   end -- if (@FORMULARTYP = 1)


   -- Block, MFA- und Ketten-Anforderungen aufloesen
   insert into #anftemp_alt select
      null,             -- ANFORDERUNGX
      T.ANFORDERUNGX,   -- PANFORDERUNGX
      3,                -- ANFORDERUNGTYP = Einzel-Anforderung
      T.FORMULARX,      -- FORMULARX
      null,             -- KATALOGANFX
      null,             -- PKATALOGANFX
      T.SORT,           -- SORT
      G.SORT,           -- SUBSORT
      0,                -- SUBSUBSORT
      T.EBENE + 1,      -- EBENE
      "R",              -- ART
      G.ANALYTX,        -- ANALYTX
      isnull(T.PANALYTX, G.ANA_ANALYTX),  -- PANALYTX
      G.ANA_ANALYTX,    -- ANA_ANALYTX
      case when (T.ANFORDERUNGTYP = 7) then G.ANA_ANALYTX else null end,  -- MFAANALYTX
      null,             -- DEFIX
      T.BEHAELTERX,     -- BEHAELTERX
      null,             -- KENNUNG
      case when (isnull(A.ANAFLAG,0) & 1) = 0 then 2 else 8 end,  -- AUSWAHL = 2:gesperrt, 8:unsichtbar
      T.LABELVAR,       -- LABELVAR
      T.DISPICON,       -- DISPICON
      null,             -- PREIS
      null,             -- PUNKTE
      null              -- BARCODEANFX
   from
      #anftemp_alt T,
      METHGRUPPE G,
      ANALYT A
   where
      T.ANFORDERUNGTYP in (6, 7, 8) -- Block (6) oder MFA (7) oder Kette (8)
      and T.ANALYTX = G.ANA_ANALYTX
      and G.ANALYTX = A.ANALYTX
      and A.AKTIVBIS is null
      and A.STORNODAT is null

   -- Block (33) oder MFA (34) oder Kette (35) mit Abnahmeort aufloesen
   insert into #anftemp_alt select
      null,             -- ANFORDERUNGX
      T.ANFORDERUNGX,   -- PANFORDERUNGX
      27,               -- ANFORDERUNGTYP = Einzel mit Abnahmeort
      T.FORMULARX,      -- FORMULARX
      null,             -- KATALOGANFX
      null,             -- PKATALOGANFX
      T.SORT,           -- SORT
      G.SORT,           -- SUBSORT
      0,                -- SUBSUBSORT
      T.EBENE + 1,      -- EBENE
      "R",              -- ART
      G.ANALYTX,        -- ANALYTX
      isnull(T.PANALYTX, G.ANA_ANALYTX),  -- PANALYTX
      G.ANA_ANALYTX,    -- ANA_ANALYTX
      case when (T.ANFORDERUNGTYP = 34) then G.ANA_ANALYTX else null end,  -- MFAANALYTX
      null,             -- DEFIX
      T.BEHAELTERX,     -- BEHAELTERX
      null,             -- KENNUNG
      case when (isnull(A.ANAFLAG,0) & 1) = 0 then 2 else 8 end,  -- AUSWAHL = 2:gesperrt, 8:unsichtbar
      T.LABELVAR,       -- LABELVAR
      T.DISPICON,       -- DISPICON
      null,             -- PREIS
      null,             -- PUNKTE
      null              -- BARCODEANFX
   from
      #anftemp_alt T,
      METHGRUPPE G,
      ANALYT A
   where
      T.ANFORDERUNGTYP in (33, 34, 35) -- Block (33) oder MFA (34) oder Kette (45)
      and T.ANALYTX = G.ANA_ANALYTX
      and G.ANALYTX = A.ANALYTX
      and A.AKTIVBIS is null
      and A.STORNODAT is null

   -- Analyt-Gruppenauswahl-Anforderungen aufloesen
   insert into #anftemp_alt select
      null,             -- ANFORDERUNGX
      T.ANFORDERUNGX,   -- PANFORDERUNGX
      3,                -- ANFORDERUNGTYP = Einzel-Anforderung
      T.FORMULARX,      -- FORMULARX
      null,             -- KATALOGANFX
      T.KATALOGANFX,    -- PKATALOGANFX
      T.SORT,           -- SORT
      G.SORT,           -- SUBSORT
      0,                -- SUBSUBSORT
      T.EBENE + 1,      -- EBENE
      T.ART,            -- ART
      G.ANALYTX,        -- ANALYTX
      isnull(T.PANALYTX, G.ANA_ANALYTX),  -- PANALYTX
      G.ANA_ANALYTX,    -- ANA_ANALYTX
      null,             -- MFAANALYTX
      null,             -- DEFIX
      T.BEHAELTERX,     -- BEHAELTERX
      null,             -- KENNUNG
      T.AUSWAHL,        -- AUSWAHL
      T.LABELVAR,       -- LABELVAR
      T.DISPICON,       -- DISPICON
      null,             -- PREIS
      null,             -- PUNKTE
      null              -- BARCODEANFX
   from
      #anftemp_alt T,
      METHGRUPPE G,
      ANALYT A
   where
      T.ANFORDERUNGTYP = 11
      and T.ANALYTX = G.ANA_ANALYTX
      and G.ANALYTX = A.ANALYTX
      and A.AKTIVBIS is null
      and A.STORNODAT is null

   -- Alle Gruppen nochmals aufloesen (Verschachtelung)
   insert into #anftemp_alt select
      null,             -- ANFORDERUNGX
      T.PANFORDERUNGX,  -- PANFORDERUNGX
      T.ANFORDERUNGTYP, -- ANFORDERUNGTYP
      T.FORMULARX,      -- FORMULARX
      null,             -- KATALOGANFX
      null,             -- PKATALOGANFX
      T.SORT,           -- SORT
      T.SUBSORT,        -- SUBSORT
      G.SORT,           -- SUBSUBSORT
      T.EBENE,          -- EBENE
      T.ART,            -- ART
      G.ANALYTX,        -- ANALYTX
      T.PANALYTX,       -- PANALYTX
      G.ANA_ANALYTX,    -- ANA_ANALYTX
      T.MFAANALYTX,     -- MFAANALYTX
      null,             -- DEFIX
      T.BEHAELTERX,     -- BEHAELTERX
      1,                -- KENNUNG = ab hier nur noch Einzelanalysen
      case when (isnull(A.ANAFLAG,0) & 1) = 0 then 2 else 8 end,  -- AUSWAHL = 2:gesperrt, 8:unsichtbar
      T.LABELVAR,       -- LABELVAR
      T.DISPICON,       -- DISPICON
      null,             -- PREIS
      null,             -- PUNKTE
      null              -- BARCODEANFX
   from
      #anftemp_alt T,
      METHGRUPPE G,
      ANALYT A
   where
      T.ANA_ANALYTX is not null
      and T.ANALYTX = G.ANA_ANALYTX
      and G.ANALYTX = A.ANALYTX
      and A.AKTIVBIS is null
      and A.STORNODAT is null

   -- Analyt-Anforderungen aufloesen
   insert into #anftemp_alt select
      null,             -- ANFORDERUNGX
      T.ANFORDERUNGX,   -- PANFORDERUNGX
      41,               -- ANFORDERUNGTYP = Analyt-Anforderung
      T.FORMULARX,      -- FORMULARX
      null,             -- KATALOGANFX
      T.KATALOGANFX,    -- PKATALOGANFX
      T.SORT,           -- SORT
      G.SORT,           -- SUBSORT
      0,                -- SUBSUBSORT
      T.EBENE + 1,      -- EBENE
      T.ART,            -- ART
      G.ANALYTX,        -- ANALYTX
      isnull(T.PANALYTX, G.ANA_ANALYTX),  -- PANALYTX = Analyt das angefordert wurde
      G.ANA_ANALYTX,    -- ANA_ANALYTX = unmittelbar uebergeordnetes Analyt
      case when (A.KENNUNG = 7) then G.ANALYTX when (T.KENNUNG = 7) then G.ANA_ANALYTX else null end,  -- MFAANALYTX
      null,             -- DEFIX
      T.BEHAELTERX,     -- BEHAELTERX
      A.KENNUNG,        -- KENNUNG
      case when (isnull(A.ANAFLAG,0) & 1) = 0 then 2 else 8 end,  -- AUSWAHL = 2:gesperrt, 8:unsichtbar
      T.LABELVAR,       -- LABELVAR
      T.DISPICON,       -- DISPICON
      null,             -- PREIS
      null,             -- PUNKTE
      null              -- BARCODEANFX
   from
      #anftemp_alt T,
      METHGRUPPE G,
      ANALYT A
   where
      T.ANFORDERUNGTYP = 41         -- nur Analyt-Anforderungen
      and T.KENNUNG in (6, 7, 8)    -- Kette (6) oder MFA (7) oder Block (8)
      and T.ANALYTX = G.ANA_ANALYTX
      and G.ANALYTX = A.ANALYTX
      and A.AKTIVBIS is null
      and A.STORNODAT is null

   -- Analyt-Anforderungen nochmals aufloesen (Verschachtelung)
   insert into #anftemp_alt select
      null,             -- ANFORDERUNGX
      T.PANFORDERUNGX,  -- PANFORDERUNGX
      41,               -- ANFORDERUNGTYP = Analyt-Anforderung
      T.FORMULARX,      -- FORMULARX
      null,             -- KATALOGANFX
      T.PKATALOGANFX,   -- PKATALOGANFX
      T.SORT,           -- SORT
      T.SUBSORT,        -- SUBSORT
      G.SORT,           -- SUBSUBSORT
      T.EBENE,          -- EBENE
      T.ART,            -- ART
      G.ANALYTX,        -- ANALYTX
      T.PANALYTX,       -- PANALYTX = Analyt das angefordert wurde
      G.ANA_ANALYTX,    -- ANA_ANALYTX = unmittelbar uebergeordnetes Analyt
      case when (T.KENNUNG = 7) then G.ANA_ANALYTX else null end,  -- MFAANALYTX
      null,             -- DEFIX
      T.BEHAELTERX,     -- BEHAELTERX
      1,                -- KENNUNG = ab hier nur noch Einzelanalysen
      case when (isnull(A.ANAFLAG,0) & 1) = 0 then 2 else 8 end,  -- AUSWAHL = 2:gesperrt, 8:unsichtbar
      T.LABELVAR,       -- LABELVAR
      T.DISPICON,       -- DISPICON
      null,             -- PREIS
      null,             -- PUNKTE
      null              -- BARCODEANFX
   from
      #anftemp_alt T,
      METHGRUPPE G,
      ANALYT A
   where
      T.ANFORDERUNGTYP = 41
      and T.ANA_ANALYTX is not null -- als Bestandteil einer Gruppe eingefügt
      and T.KENNUNG in (6, 7, 8)    -- Kette (6) oder MFA (7) oder Block (8)
      and T.ANALYTX = G.ANA_ANALYTX
      and G.ANALYTX = A.ANALYTX
      and A.AKTIVBIS is null
      and A.STORNODAT is null

   -- Text-Gruppenauswahl-Anforderungen aufloesen
   insert into #anftemp_alt select
      null,             -- ANFORDERUNGX
      T.ANFORDERUNGX,   -- PANFORDERUNGX
      4,                -- ANFORDERUNGTYP = Einzeltext-Anforderung
      T.FORMULARX,      -- FORMULARX
      null,             -- KATALOGANFX
      T.KATALOGANFX,    -- PKATALOGANFX
      T.SORT,           -- SORT
      G.SORT,           -- SUBSORT
      0,                -- SUBSUBSORT
      T.EBENE + 1,      -- EBENE
      T.ART,            -- ART
      T.ANALYTX,        -- ANALYTX
      T.PANALYTX,       -- PANALYTX
      null,             -- ANA_ANALYTX
      null,             -- MFAANALYTX
      G.DEFIX,          -- DEFIX
      T.BEHAELTERX,     -- BEHAELTERX
      null,             -- KENNUNG
      T.AUSWAHL,        -- AUSWAHL
      T.LABELVAR,       -- LABELVAR
      T.DISPICON,       -- DISPICON
      null,             -- PREIS
      null,             -- PUNKTE
      null              -- BARCODEANFX
   from
      #anftemp_alt T,
      DEFIGRUPPE G
   where
      T.ANFORDERUNGTYP = 12
      and T.DEFIX = G.DEF_DEFIX

   -- Mikrobiologie-Material aufloesen
   insert into #anftemp_alt select
      null,             -- ANFORDERUNGX
      T.ANFORDERUNGX,   -- PANFORDERUNGX
      4,                -- ANFORDERUNGTYP = Einzeltext-Anforderung
      T.FORMULARX,      -- FORMULARX
      null,             -- KATALOGANFX
      null,             -- PKATALOGANFX
      T.SORT,           -- SORT
      G.SORT,           -- SUBSORT
      0,                -- SUBSUBSORT
      T.EBENE + 1,      -- EBENE
      "R",              -- ART
      T.ANALYTX,        -- ANALYTX
      null,             -- PANALYTX
      null,             -- ANA_ANALYTX
      null,             -- MFAANALYTX
      G.DEFIX,          -- DEFIX
      T.BEHAELTERX,     -- BEHAELTERX
      null,             -- KENNUNG
      T.AUSWAHL,        -- AUSWAHL
      T.LABELVAR,       -- LABELVAR
      T.DISPICON,       -- DISPICON
      null,             -- PREIS
      null,             -- PUNKTE
      null              -- BARCODEANFX
   from
      #anftemp_alt T,
      DEFIGRUPPE G
   where
      T.ANFORDERUNGTYP = 26
      and T.DEFIX = G.DEF_DEFIX


   -- Ergebnis aus Tempo Tabelle ausgeben
   select
      T.ANFORDERUNGX,
      T.PANFORDERUNGX,
      T.ANFORDERUNGTYP,
      T.FORMULARX,
      T.KATALOGANFX,
      T.PKATALOGANFX,
      T.SORT,
      T.SUBSORT,
      T.SUBSUBSORT,
      T.EBENE,
      T.ART,
      T.ANALYTX,
      A.CODE as ANALYTCODE,
      A.KENNUNG,
      A.BESCHREIBUNG as ANALYTBESCHREIBUNG,
      A.EINHEIT,
      A.DEFTEXT as ANALYTDEFTEXT,
      A.DEFWERT as ANALYTDEFWERT,
      A.DEFDEFIX as ANALYTDEFDEFIX,
      A.DEFERFASS,
      A.DEFMATERIALX,
      A.VOLUMEN as ANALYTVOLUMEN,
      A.ANAFLAG,
      A.KOMMASTELLE,
      T.PANALYTX,
      P.CODE as PANALYTCODE,
      T.ANA_ANALYTX,
      T.MFAANALYTX,
      T.DEFIX,
      D.DEFICODE,
      D.TEXT as DEFITEXT,
      T.BEHAELTERX,
      BEHAELTERCODE = case when B.BEHAELTERCODE is not null then B.BEHAELTERCODE else 'none' end,
      B.BEHAELTERNAME,
      B.MATERIALX,
      M.MATCODE,
      M.MATERIALKREISNR,
      M.FKTESTVON,
      M.FKTESTBIS,
      M.MATNRVON,
      M.MATNRBIS,      
      B.FARBE,
      B.ZUSATZ,
      B.LABOR,
      B.MATEXT,
      B.ZEITOFFSET,
      B.VOLUMEN as BEHAELTERVOLUMEN,
      B.LAYOUTNAME,
      B.BARCODE,
      R.BEHAELTERID,
      R.ANZAHLBEHAELTER,
      R.BESCHREIBUNG,
      R.AUSGABEFORM,
      T.AUSWAHL,
      R.STEUERUNG,
      R.BISDRING,
      R.DEFTEXT,
      R.DEFWERT,
      T.LABELVAR,
      R.VOLUMEN,
      R.NACHFORDERN,
      T.DISPICON,
      R.DISPFORMAT,
      T.PREIS,
      T.PUNKTE,
      T.BARCODEANFX,
      C.BARPOSITION,
      C.BARBREITE,
      C.BARINHALT
   into #anfo_alt
   from
      #anftemp_alt T,
      ANFORDERUNG R (index ANFORDERUNG_PK),
      ANALYT A (index ANALYT_PK),
      ANALYT P (index ANALYT_PK),
      DEFI D (index DEFI_PK),
      BEHAELTER B (index BEHAELTER_PK),
      MATERIAL M (index MATERIAL_PK),
      BARCODEANF C (index BARCODEANF_PK)
   where
      isnull(T.KATALOGANFX, T.ANFORDERUNGX) *= R.ANFORDERUNGX
      and T.ANALYTX *= A.ANALYTX
      and T.PANALYTX *= P.ANALYTX
      and T.DEFIX *= D.DEFIX
      and T.BEHAELTERX *= B.BEHAELTERX
      and B.MATERIALX *= M.MATERIALX
      and T.BARCODEANFX *= C.BARCODEANFX
   order by
      T.SORT,
      T.SUBSORT,
      T.SUBSUBSORT

