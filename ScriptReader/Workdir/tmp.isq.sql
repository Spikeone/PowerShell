/****************************************************************************/
/*FILENAME : patiliste_xpro.isq                                             */
/*AUTOR    : lis                                                            */
/*ERSTELLT : [010903.1100]                                                  */
/*KURZINFO : SWL-II: Aufbau der PATILISTE mit Kreuzprobenpatienten          */
/*MODULE   : Lauris, Pflege der PATILISTE im TAIN                           */
/*BEW_ANZ  :                                                                */
/*BEW_GEF  :                                                                */
/*TIMESTAMP: <20100903.1100>                                                */
/****************************************************************************/
/*AENDERUNG:                                                                */
/*[010903] 1.00 lis erstellt                                                */
/****************************************************************************/

set dateformat dmy  

/* Parameter deklarieren         */

declare
  @startdat                      smalldatetime,
  @enddat                        smalldatetime,
  @datumtxt                      varchar(23),
  @aufruftxt                     varchar(23),
  @ANALYTX                       int,
  @CODE                          char(16),  
  @USER                          smallint,
  @EINSENDERX                    int,
  @EINSCODE                      char(16),
  @MODUS                         tinyint,
  @PATIFALLX                     int,
  @PATIART                       char(8),
  @KOSTTRTYP                     char(6),
  @PZIMMERNR                     varchar(8),
  @AKTIVBIS                      smalldatetime,
  @STORNO                        tinyint,
  @QUIET                         tinyint,
  @REPORT                        tinyint, 
  @DEMO_ONLY                     tinyint,
  @RES1                          varchar(8),
  @RES2                          varchar(8),
  @RES3                          varchar(8),
  @RES4                          varchar(8),
  @RES5                          varchar(8),
  @RES6                          varchar(8),

  @patifallx                     int,
  @einsenderx                    int,
  @patiart                       char(8),
  @kosttrtyp                     char(6),
  @pzimmernr                     varchar(8),
  @aktivbis                      smalldatetime,
                                 
  @found                         int,
  @cnt                           int,
  @insertpf                      char(4)

set nocount on

/* -------- Aufrufparameter Beginn -------- */
select @CODE           =     'XPRO'   -- AnalytCode
select @EINSCODE       =     'FREY'   -- EinsenderCode, f?r den die Liste aufgebaut wird
select @RES1           =     'negativ'
select @RES2           =     'NEG'
select @RES3           =     'neg'
select @RES4           =     'N'
select @RES5           =     'n'
select @RES6           =     '-'
select @REPORT         =     1        -- 0 -> REPORT-Modus aus,  1 -> REPORT-Modus ein
select @DEMO_ONLY      =     1        -- 0 -> insert into PATILISTE,  1 -> keine ?nderungen an PATILISTE
/* -------- Aufrufparameter Ende   -------- */

/* ------------ Voreinstellungen PI_PATILISTE Beginn -------------------*/
select @STORNO         =     0
select @QUIET          =     1
select @MODUS          =     1   -- XREF ist 1=EINSENDERX, 2=CLIENTX, 3=IDENTX 
/* -------------Voreinstellungen PI_PATILISTE Ende ---------------------*/    

print '+-----------------------------------------------------------------------+'
print '|Lauris, PATILISTE: Aufnahme F?lle mit XPRO Auftrag                     |'
print '+-----------------------------------------------------------------------+'
print ''
if @DEMO_ONLY = 1 
begin
  print '+-----------------------------------------------------------------------+'
  print '| ==========  Demo-Modus, keine Aenderungen an PATILISTE  ============  |'
  print '+-----------------------------------------------------------------------+'
  print ''
end

select @startdat=getdate()
select @datumtxt='Start: ' + convert(char(11),@startdat,104)+convert(char(5),@startdat,108)
print  @datumtxt
select @USER=PERSONX from LOGIN where LOGINID=suser_name() and STORNODAT is null
select @aufruftxt = 'Aufruf durch: ' +PERSONID from PERSON where PERSONX=@USER
select @ANALYTX  = 0
select @ANALYTX = ANALYTX from ANALYT where CODE=@CODE and STORNODAT is null
select @EINSENDERX  = 0
select @EINSENDERX = EINSENDERX from EINSENDER where EINSCODE=@EINSCODE and STORNODAT is null

                       
if @REPORT=1  
begin
  print  @aufruftxt
end

select 
  A.AUFTRAGNR,
  A.AUFTRAGX,
  A.EINSENDERX,
  A.ERFASSPERS,
  A.PATIFALLX,
  PF.PATIFALLNR
into #temp1
from AUFTRAG A, TASKFLAG T, PATIFALL PF
where
  A.AUFTRAGX=T.XREF
  and T.TSTATUS > 0
  and A.STORNODAT is null
  and PF.PATIFALLX=A.PATIFALLX
-- select * from #temp1
select 
  t1.PATIFALLNR,
  t1.PATIFALLX,
  t1.AUFTRAGNR,
  E.EINSCODE,
  ErfassPersAuft=P2.PERSONID,
  AN.CODE,
  Resultatstatus=R.STATUS,
  Resultat=substring(R.ERGEBNIST,1,12),
  AnfordPers=P.PERSONID,
  Anforddat=convert(char(11),R.ANFORDDAT ,104)+convert(char(8),R.ANFORDDAT ,108)+' ',
  Stornodat=convert(char(11),R.STORNODAT ,104)+convert(char(8),R.STORNODAT ,108)+' '
into #temp2
from #temp1 t1, ANALYT AN (index ANALYT_PK) , PERSON P, PERSON P2, RESULTAT R, EINSENDER E
where
  R.AUFTRAGX = t1.AUFTRAGX and
  P2.PERSONX=t1.ERFASSPERS and
  R.ANALYTX = @ANALYTX and
  R.ERGEBNIST in (@RES1,@RES2,@RES3,@RES4,@RES5,@RES6) and
  R.STORNODAT is null and
  R.AKTIVBIS is null and
  R.FREIGABEDAT is not null and
  P.PERSONX=R.ANFORDPERS and
  AN.ANALYTX=R.ANALYTX and
  E.EINSENDERX=t1.EINSENDERX
if @REPORT=1  
begin
  print''
  print 'Auftraege und Resultate die selektiert wurden'
  print''
  select * from #temp2
end
-- nun noch doppeltes raus
select distinct     -- wir haben mehrere XPRO?s pro Auftrag
  t2.PATIFALLNR,
  t2.PATIFALLX
--  t1.AUFTRAGNR,
--  E.EINSCODE,
--  ErfassPersAuft=P2.PERSONID,
--  AN.CODE,
--  Resultatstatus=R.STATUS,
--  Resultat=substring(R.ERGEBNIST,1,12),
--  AnfordPers=P.PERSONID,
--  Anforddat=convert(char(11),R.ANFORDDAT ,104)+convert(char(8),R.ANFORDDAT ,108)+' ',
--  Stornodat=convert(char(11),R.STORNODAT ,104)+convert(char(8),R.STORNODAT ,108)+' '
into #temp3
from #temp2 t2
if @REPORT=1  
begin
  print''
  print 'Patientenfaelle die selektiert wurden'
  print''
  select * from #temp3
end
create table #ptemp(
  cnt            numeric       identity not null,
  patifallx      int           null,
  patifallnr     char(16)      null,
  pfeinsenderx   int           null,
  patiart        char(8)       null,
  kosttrtyp      char(6)       null,
  pzimmernr      varchar(8)    null,
  entldatverw    smalldatetime null,
  plandat        smalldatetime null,
  auftragnr      char(16)      null,
  patilistex     int           null,
  pleinsenderx   int           null,
  aktivbis       smalldatetime null,
  patifalleins   char(16)      null,
  patilisteeins  char(16)      null,
  auftrageins    char(16)      null,
  insertpf       char(4)       null
 )

insert into #ptemp
select
  patifallx             =     PF.PATIFALLX,
  patifallnr            =     PF.PATIFALLNR,
  pfeinsenderx          =     PF.EINSENDERX,
  patiart               =     PF.PATIART,
  kosttrtyp             =     PF.KOSTTRTYP,
  pzimmernr             =     PF.PZIMMERNR,
  entldatverw           =     PF.ENTLDATVERW,
  plandat               =     null,
  auftragnr             =     null,
  patilistex            =     PL.PATILISTEX,
  pleinsenderx          =     PL.EINSENDERX,
  aktivbis              =     PL.AKTIVBIS,
  patifalleins          =     P1.EINSCODE,
  patilisteeins         =     P2.EINSCODE,
  auftrageins           =     null,
  insertpf              =     'no'
 
from #temp3 t3, PATIFALL PF, PATILISTE PL, EINSENDER P1, EINSENDER P2

where
      PF.PATIFALLX =  t3.PATIFALLX
  and PL.PATIFALLX =* PF.PATIFALLX
  and P1.EINSENDERX=  PF.EINSENDERX
  and P2.EINSENDERX=*  PL.EINSENDERX
order by plandat
select @found = @@identity
if @REPORT=1 

select @cnt = 0
while @cnt < @found
begin
  select @cnt        = @cnt+1  
  update #ptemp set insertpf = 'yes'
  where (patilistex is null or (patilistex is not null and pleinsenderx <> @EINSENDERX))
  and (entldatverw is null or entldatverw > getdate())
end

if @REPORT=1 
begin
  print ''
  print ' Patientenf?lle der XPRO-Patienten f?r den Einsender OP in die Lauris-Patienliste nehmen'
  print ''

  set nocount off
  select patifallnr, 
         patiart,
         patifalleins, 
         entldatverw, 
         auftragnr, 
         auftrageins, 
         plandat, 
         insertpf, 
         patilisteeins, 
         aktivbis
  from #ptemp
  where insertpf = 'yes'
  set nocount on
end  
  
select @cnt = 0
while @cnt < @found
begin

  select @cnt        = @cnt+1  
  select @insertpf   = 'no'
  select @PATIFALLX  = pt.patifallx ,
         @PATIART    = pt.patiart   ,
         @KOSTTRTYP  = pt.kosttrtyp ,
         @PZIMMERNR  = pt.pzimmernr ,
         @AKTIVBIS   = convert(char(11),dateadd(day,1,getdate()) ,104)+convert(char(8),'23:59:00',108)+' ',
         @insertpf   = pt.insertpf
  from #ptemp pt  
  where     
        pt.cnt=@cnt    
    and pt.insertpf = 'yes'              
  if @insertpf = 'yes'
  begin
    select 'exec PI_PATILISTE: @cnt,'        = @cnt, 
                             ' @MODUS,'      = @MODUS,
                             ' @EINSENDERX,' = @EINSENDERX, 
                             ' @PATIFALLX,'  = @PATIFALLX, 
                             ' @PATIART,'    = @PATIART, 
                             ' @KOSTTRYP,'   = @KOSTTRTYP, 
                             ' @PZIMMERNR,'  = @PZIMMERNR, 
                             ' @AKTIVBIS,'   = @AKTIVBIS,  
                             ' @STORNO,'     = @STORNO,
                             ' @QUIET'       = @QUIET
    if @DEMO_ONLY=0
    begin
      exec PI_PATILISTE
             @USER       = @USER      ,
             @EINSENDERX = @EINSENDERX,
             @MODUS      = @MODUS     ,
             @PATIFALLX  = @PATIFALLX ,
             @PATIART    = @PATIART   ,
             @KOSTTRTYP  = @KOSTTRTYP ,
             @PZIMMERNR  = @PZIMMERNR ,
             @AKTIVBIS   = @AKTIVBIS  ,
             @STORNO     = @STORNO    ,
             @QUIET      = @QUIET      
    end
  end
end

go
