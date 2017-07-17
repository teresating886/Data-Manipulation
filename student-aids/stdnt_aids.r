library (dplyr)
library (tidyr)
library(reshape2)
library(xlsx)

# import the data
stdnt.awrd.tmp <- read.csv("studnt_awards/original.csv", header=TRUE
                            , stringsAsFactors = F
                            , colClasses = "character")
# verify data type
glimpse(stdnt.awrd.tmp)

#lowercase all column names
names(stdnt.awrd.tmp) <- tolower(names(stdnt.awrd.tmp))

# change amount from chr to int type
stdnt.awrd.tmp [, "amount"] <- stdnt.awrd.tmp [, "amount"] %>% 
                               sapply(as.numeric)

typeof(stdnt.awrd.tmp$emplid)
# student ID should be chr not num, otherwise the leading zero will be missing
# once the output file is opened.
as.character(stdnt.awrd.tmp$emplid)

# replace missing values with NA in fund
stdnt.awrd.tmp$fund[stdnt.awrd.tmp$fund == ''] = 'NA'

# Rename values in $fin_aid_type
stdnt.awrd.tmp$fin_aid_type <- 
  gsub('scholarship / award', 'scholarship'
       , stdnt.awrd.tmp$fin_aid_type
       , ignore.case = TRUE)

stdnt.awrd.tmp$fin_aid_type <- 
  gsub('Bursary', 'bursary'
       , stdnt.awrd.tmp$fin_aid_type
       , ignore.case = TRUE)

stdnt.awrd.tmp$fin_aid_type <- 
  gsub('Emergency Student Loan', 'stdnt_loan'
       , stdnt.awrd.tmp$fin_aid_type
       , ignore.case = TRUE)

# amount - 999999.90
stdnt.awrd.tmp$amount <- trunc(stdnt.awrd.tmp$amount, digits = 2)

# Create a subset
stdnt.dt.tmp <- stdnt.awrd.tmp  %>% 
            select(  emplid
                     , amount
                     , first_name
                     , last_name
                     , fin_aid_type
                     , fund)

# student by grand total
stdnt.grant.total.tmp <- 
            stdnt.dt.tmp %>% 
            group_by (emplid) %>% 
            summarize("grant_total" = sum(amount)) %>% 
            arrange(emplid)
stdnt.grant.total.tmp[is.na(stdnt.grant.total.tmp)] <- 0            

# student by financial aid type
stdnt.fin.typ.Uniq.tmp <- 
            stdnt.dt.tmp %>% 
            group_by (emplid, fin_aid_type) %>% 
            summarize ("total_by_fin_aid_type" = sum(amount)) %>%
            spread(fin_aid_type, total_by_fin_aid_type) %>% 
            arrange(emplid)
stdnt.fin.typ.Uniq.tmp[is.na(stdnt.fin.typ.Uniq.tmp)] <- 0    

# Aggregate by (or roll up to) fund types
stdnt.fund.typ.tmp <- 
          stdnt.dt.tmp %>% 
          group_by (emplid, fin_aid_type, fund) %>% 
          summarize ("total_by_fund_type" = sum(amount)) %>% 
          arrange(emplid)
stdnt.fund.typ.tmp 

#Pivot fund type
stdnt.fund.typ.Uniq.tmp  <- 
        stdnt.fund.typ.tmp %>% 
            dcast (emplid ~ fin_aid_type + fund
                   , value.var = ('total_by_fund_type')) %>%
            arrange(emplid)

# Get column names which has "_NA"
grep("_NA", names(stdnt.fund.typ.Uniq.tmp), value=TRUE)


# create new columns according to the final format
glimpse(stdnt.fund.typ.Uniq.tmp)

# first, replace missing values with zero
stdnt.fund.typ.Uniq.tmp[is.na(stdnt.fund.typ.Uniq.tmp)] <- 0

names(stdnt.fund.typ.Uniq.tmp)

# student by fund type
stdnt.fund.typ.Uniq.tmp <- 
  stdnt.fund.typ.Uniq.tmp %>%
    mutate("bursary_EXXXX" = rowSums(stdnt.fund.typ.Uniq.tmp[,c(5:115)]),
      "scholarship_5XX" = rowSums(stdnt.fund.typ.Uniq.tmp[,c(118:120)]), 
      "scholarship_EXXXX" = rowSums(stdnt.fund.typ.Uniq.tmp[,c(121:1309)])) %>%
    select (emplid, bursary_100, bursary_210, bursary_553, bursary_EXXXX
            , stdnt_loan_NA
            , scholarship_100, scholarship_210, scholarship_5XX
            , scholarship_EXXXX, scholarship_NA) %>%
    arrange(emplid)

# combine sets
fnl.stdnt.dt.tmp <- inner_join(stdnt.fund.typ.Uniq.tmp
                         , stdnt.fin.typ.Uniq.tmp
                         , by = 'emplid') %>%
                    inner_join ( stdnt.grant.total.tmp
                         , by = 'emplid' )

# validate the numbers
# grand_total = bursary + scholarship + stdnt_loan
calc.grand.tot.tmp <- with(fnl.stdnt.dt.tmp, bursary + scholarship + stdnt_loan)
which ((fnl.stdnt.dt.tmp$grant_total - calc.grand.tot.tmp) != 0)

# bursary = bursary_100 + bursary_210 + bursary_553 + bursary_EXXXX
calc.bursary.tmp <- with(fnl.stdnt.dt.tmp, 
                     bursary_100 + bursary_210 + bursary_553 + bursary_EXXXX)
which ((fnl.stdnt.dt.tmp$bursary - calc.bursary.tmp) != 0)

# scholarship = scholarship_100 + scholarship_210 + scholarship_5XX 
#               + scholarship_EXXXX + scholarship_NA
calc.scholarship.tmp <- with(fnl.stdnt.dt.tmp, 
                         scholarship_100 + scholarship_210 + scholarship_5XX 
                         + scholarship_EXXXX + scholarship_NA)
which ((fnl.stdnt.dt.tmp$scholarship - calc.scholarship.tmp) != 0)

#stdnt_loan vs stdnt_loan_NA
which (with(fnl.stdnt.dt.tmp, stdnt_loan - stdnt_loan_NA)  != 0)

# output to a csv file 
write.xlsx(fnl.stdnt.dt.tmp, 'studnt_awards/fnl_stdnt_awrd_dt.xlsx' 
           , row.names=FALSE)

# Clean up workspace
rm(list=ls(pattern="tmp"))

