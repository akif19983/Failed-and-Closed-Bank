-- Raw master data

Select *
From FailedBank..failed_bank_acquirer$


-- Drop unused column

Alter table FailedBank..failed_bank_acquirer$
Drop column acq_inst

-- Check for duplicates

With duplicate(Cert, duplicates)
as
(
Select CERT, COUNT(*) as duplicates
From FailedBank..failed_bank_acquirer$
Group by CERT
)
Select *
From duplicate
Where duplicates > 1

-- Total Bank Closed from year 2000 to 2016

Select COUNT(CERT) as TotalBankClose
From FailedBank..failed_bank_acquirer$

-- Which city has the highest failed bank

With TopCityFailedBank(City, TotalFailedBank)
as
(
Select City, COUNT(City) as TotalFailedBank
From FailedBank..failed_bank_acquirer$
Group by City
)
Select *, RANK () OVER (Order by TotalFailedBank desc) as CityRankforFailedBank
From TopCityFailedBank

-- Which year has the highest bank close

With TopClosingYear(Cert, YearClose)
as
(
Select CERT, Year([Closing Date]) as YearClose
From FailedBank..failed_bank_acquirer$
)
Select YearClose, COUNT(CERT) as TotalBankCloseintheYear
From TopClosingYear
Group by YearClose
Order by TotalBankCloseintheYear desc

-- Top 3 year highest bank close

Drop table if exists #TopYearBankClose
Create table #TopYearBankClose
(
Cert int,
YearClose int 
)

Insert into #TopYearBankClose
Select CERT, Year([Closing Date]) as YearClose
From FailedBank..failed_bank_acquirer$

With YearlyRank(YearClose, TotalBankCloseintheYear)
as
(
Select YearClose, COUNT(Cert) as TotalBankCloseintheYear
From #TopYearBankClose
Group by YearClose
 )
Select *, RANK() OVER (Order by TotalBankCloseintheYear desc) as YearlyRankforTotalClosed
From YearlyRank
Order by YearlyRankforTotalClosed asc

