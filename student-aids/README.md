## Student Aids

This program is to take an input file of the students with their grants and loans data and reorganize / summarize them into a different format.

The input file looks like this:

AMOUNT | STUDENT_ID | FIRST_NAME | LAST_NAME | FIN_AID_TYPE  | FUND_TYPE
------ | ---------- | ---------- | ----------| ------------- | --------- 
90.47  |  02110     |  Darth     |  Vader    | Bursary       |  100
9.53   |  02110     |  Darth     |  Vader    | Bursary       |  100
500	   |  02110	    |  Darth	   |  Vader	   | Bursary	     |  210
500	   |  02110	    |  Darth	   |  Vader	   | Scholarship	 |  E0001
100	   |  02110	    |  Darth	   |  Vader	   | Scholarship	 |  NA
150	   |  02110	    |  Darth	   |  Vader	   | Scholarship	 |  E5410
250	   |  02111	    |  Han       |  Solo     | Scholarship	 |  E2222
110	   |  02111	    |  Han	     |  Solo	   | Student Loan	 |  NA
350	   |  02112	    |  Obi-Wan	 |  Kenobi	 | Bursary	     |  555

The script will privot the grouping of FIN_AID_TYPE and FUND from rows to columns, so that every student will only have one row of record in the output xlsx file. The header columns of the file look like the followings:

* student_ID
* grant_total
* bursary_total
* bursary_100	
* bursary_210	
* bursary_553	
* bursary_EXXXX	
* stdnt_loan_total
* stdnt_loan_NA	
* scholarship_total
* scholarship_100	
* scholarship_210	
* scholarship_5XX	
* scholarship_EXXXX	
* scholarship_NA				


