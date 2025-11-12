create database Loan_Management_System;
use Loan_Management_System;

-- Sheet 1


create table customer_grades select * ,
Case when Applicantincome >15000 then "Grade A"
	when Applicantincome >9000 then "Grade B"
	when Applicantincome >5000 then "middle class customer"
	else "low class" 
end as customer_grades,
case when 	
	Applicantincome <5000 and Property_Area = "rural" then "3"
	when Applicantincome <5000 and Property_Area ="semi rural" then "3.5"
	when Applicantincome <5000 and Property_Area ="urban" then "5"
	when Applicantincome <5000 and Property_Area ="semi urban" then "2.5"
	else "7"
end as 
monthly_income_percentage from customer_income;

	select* from customer_grades;
 create table customer_interest_analysis select c.*,l.Loan_amount, l.Loan_Amount_Term, l.Cibil_Score, l.Cibil_Score_criteria,
round(loan_amount*(monthly_interest_percentage/100)) as monthly_interest,
round((loan_amount*(monthly_interest_percentage/100)*12)) as annual_interest from customer_grades c inner join loan_cibil_score_status_details l on 
c.customer_ID=l.customer_ID;

select * from customer_interest_analysis;
-- Sheet 2
-- row trigger

create table loan_status_updation(Loan_ID varchar(20), Customer_id varchar(20), Loan_amount varchar(50), Loan_Amount_Term int, Cibil_Score int);

 delimiter //
 create trigger loan_status_Update before insert on loan_status_updation for each row
 begin
 if new.loan_amount is null then set  new.loan_amount="loan still processing";
 end if;
 end //
 delimiter ;

insert into loan_status_updation(Loan_ID , Customer_id , Loan_amount , Loan_Amount_Term , Cibil_Score )
select Loan_ID , Customer_id , Loan_amount , Loan_Amount_Term , Cibil_Score from loan_status;

select * from loan_status_updation;

-- statement trigger

-- using loan_status_updation

create table remarks_update(Loan_ID varchar(20) , 
Customer_id varchar(20) , 
Loan_amount varchar(50),
Cibil_Score int,
Cibil_Score_criteria varchar(50));

delimiter //
create trigger remarks_updation after insert on loan_status_updation for each row
begin
	case when new.Cibil_score >900 then insert into remarks_update (Loan_ID  , 
Customer_id  , 
Loan_amount ,
Cibil_Score ,
cibil_score_criteria) values(new.Loan_ID  , 
new.Customer_id  , 
new.Loan_amount ,
new.Cibil_Score ,"high cibil score");
	when new.Cibil_score >750 then insert into remarks_update (Loan_ID  , 
Customer_id  , 
Loan_amount ,
Cibil_Score ,cibil_score_criteria)values(new.Loan_ID  , 
new.Customer_id  , 
new.Loan_amount ,
new.Cibil_Score ,
"no penalty");

	when new.Cibil_score >0 then insert into remarks_update (Loan_ID  , 
Customer_id  , 
Loan_amount ,
Cibil_Score ,cibil_score_criteria)values(new.Loan_ID  , 
new.Customer_id  , 
new.Loan_amount ,
new.Cibil_Score ,"penalty customers");
	when new.Cibil_score <=0 then insert into remarks_update (Loan_ID  , 
Customer_id  , 
Loan_amount ,
Cibil_Score ,cibil_score_criteria)values(new.Loan_ID  , 
new.Customer_id  , 
new.Loan_amount ,
new.Cibil_Score ,"reject customers (loan cannot apply)");
end case;
end //
delimiter ;

select * from loan_status_updation;

select* from remarks_update;

 delete from remarks_update 
 where loan_amount="loan still processing" or
 cibil_score_criteria ="Reject Customers(loan cannot apply)";


alter table remarks_update modify Loan_amount int;

CREATE TABLE  customer_interest_analysis SELECT l.*, r.Cibil_Score_criteria FROM
    loan_status_updation l
        INNER JOIN
    remarks_update r ON l.Loan_ID = r.Loan_ID;
    
    
    select* from loan_cibil_score_status_details ;
    
    
-- Sheet 3
-- Customer_id	Gender
-- IP43006	Female
-- IP43016	Female
-- IP43018	Male
-- IP43038	Male
-- IP43508	Female
-- IP43577	Female
-- IP43589	Female
-- IP43593	Female 
	
update customer_det set gender = case
 when customer_ID in ("IP43006","IP43016","IP43508","IP43577","IP43589","IP43593") then "Female" 
 when customer_ID in("IP43018","IP43038") then "Male"
 else gender
 end;
 
 select * from customer_det;
 
 -- Sheet 4 & 5
 
 select c.*, co.Customer_name, co.Region_id, co.Postal_Code, co.Segment, co.State, 
 cu.Gender, cu.Age, cu.Married, cu.Education, cu.Self_Employed, cu.Loan_Id, cu.Region_id,r.region 
 from customer_interest_analysis c inner join country_state co on c.customer_ID=co.customer_ID
 inner join customer_det cu on co.customer_ID=cu.customer_ID inner join region_info r on cu.region_ID=r.region_ID;
 
select cu.Customer_ID, cu.Customer_name, cu.Gender, cu.Age, 
cu.Married, cu.Education, cu.Self_Employed, cu.Loan_Id, cu.Region_id, 
co.Customer_name, co.Postal_Code, co.Segment, co.State,r.Region from customer_det cu
left join country_state co on cu.customer_ID=co.customer_ID right join region_info r
on co.region_ID=r.region_ID; 



select * from loan_cibil_score_status_details 
where cibil_score_criteria="High cibil score";

select * from country_state where segment in('Home office','corporate');


delimiter //
create procedure Output_5()
begin
select c.*, co.Customer_name, co.Region_id, co.Postal_Code, co.Segment, co.State, 
 cu.Gender, cu.Age, cu.Married, cu.Education, cu.Self_Employed, cu.Loan_Id, cu.Region_id,r.region 
 from customer_interest_analysis c inner join country_state co on c.customer_ID=co.customer_ID
 inner join customer_det cu on co.customer_ID=cu.customer_ID inner join region_info r on cu.region_ID=r.region_ID;
 
select cu.Customer_ID, cu.Customer_name, cu.Gender, cu.Age, 
cu.Married, cu.Education, cu.Self_Employed, cu.Loan_Id, cu.Region_id, 
co.Customer_name, co.Postal_Code, co.Segment, co.State,r.Region from customer_det cu
left join country_state co on cu.customer_ID=co.customer_ID right join region_info r
on co.region_ID=r.region_ID; 

select * from loan_cibil_score_status_details 
where cibil_score_criteria="High cibil score";

select * from country_state where segment in('Home office','corporate');
end //
delimiter ;

call output_5;

