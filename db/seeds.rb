require 'factory_bot_rails'
require 'csv'

exit if Rails.env.test?
FactoryBot.create :user, first_name: 'David', last_name: 'Faulkenberry', staff: true, spire: '12345678@umass.edu', email: 'dfaulken@umass.edu', admin: true
user = FactoryBot.create :user, first_name: 'Justin', last_name: 'Forgue', spire: '13579246@umass.edu', email: 'jforgue@umass.edu'
department = FactoryBot.create :department, name: 'Bus'
position = FactoryBot.create :position, department: department, name: 'Operator'
FactoryBot.create :application_submission,
                  data: [["Bus Application", nil, "heading", 1],
                         [<<~REQS, nil, 'explanation', 81],
                          Minimum Job Requirements for **Bus Driver**

                          +   You must have at least three semesters remaining
                              as a UMass Student.
                          +   You must be registered for the current or
                              upcoming semester.
                          +   You must be willing to accept a work assignment
                              of at least 15 hours per week during the
                              semester.
                          +   You must be willing to work a minimum of 180
                              hours per semester for at least two full
                              semesters after training is complete.
                          +   You must possess a driver's license that is
                              valid in the United States.
                          +   You must be at least 18 years of age, and be
                              able to communicate clearly in English.
                          +   You must be able to pass a NIDA-5 panel
                              pre-employment drug screening and agree to
                              participate in random, unannounced, NIDA-5 panel
                              drug testing throughout your employment.
                          +   You must be willing to sign a legally binding
                              contract that includes (but is not limited to)
                              the above terms.
                          +   You must enjoy driving.
                         REQS
                         ["I understand and meet the above minimum requirements for entering the UMass Transit bus driver training program.", "Yes", "yes/no", 2],
                         ["Local address (street, apt., etc.)", "255 Governors Dr", "text", 3],
                         ["Local address (city)", "Amherst", "text", 4],
                         ["Local address (state)", "MA", "text", 5],
                         ["Local address (zip code)", "01003", "text", 6],
                         ["Local phone number", "(413) 545-0056", "text", 7],
                         ["Permanent address (street, apt., etc.)", "123 Imaginary St", "text", 8],
                         ["Permanent address (city)", "Imaginary Land", "text", 9],
                         ["Permanent address (state)", "IL", "text", 10],
                         ["Permanent address (zip code)", "12345", "text", 11],
                         ["Permanent phone number", "4135550000", "text", 12],
                         ["Date of birth", "1997-11-18", "date", 13],
                         ["Anticipated graduation date", "2024-05-20", "date", 14],
                         ["Major", "Bus Driving", "text", 15],
                         ["How many credits are you enrolled in this semester?", "2", "number", 16],
                         ["Are you interested in training during the summer?", "Yes", "yes/no", 17],
                         ["Employment History #1", nil, "heading", 18],
                         ["Employer", "UMass", "text", 19],
                         ["Supervisor's name", "GPA", "text", 20],
                         ["Your job title", "Student", "text", 21],
                         ["Address of employer", "255 Governors Dr", "text", 22],
                         ["Phone number", "(413) 545-0056", "text", 23],
                         ["Begin date", "2018-12-05", "date", 24],
                         ["End date", "2021-12-08", "date", 25],
                         ["Salary/wage", "10", "number", 26],
                         ["Reason for leaving", "I'm failing", "text", 27],
                         ["Job responsibilities", "Not failing", "text", 28],
                         ["May we contact this employer for a reference?", "No", "yes/no", 29],
                         ["Employment History #2", nil, "heading", 30],
                         ["Employer", "", "text", 31],
                         ["Supervisor's name", "", "text", 32],
                         ["Your job title", "", "text", 33],
                         ["Address of employer", "", "text", 34],
                         ["Phone number", "", "text", 35],
                         ["Begin date", "", "date", 36],
                         ["End date", "", "date", 37],
                         ["Salary/wage", "0", "number", 38],
                         ["Reason for leaving", "", "text", 39],
                         ["Job responsibilities", "", "text", 40],
                         ["May we contact this employer for a reference?", nil, "yes/no", 41],
                         ["Driving experience", nil, "heading", 42],
                         ["What year did you get your first driver's license?", "1492", "number", 43],
                         ["Where was your first license issued?", "Spain", "text", 44],
                         ["For how many years have you been driving in the United States (must be at least 1 full year)?", "0", "number", 45],
                         ["In what state is your current license issued?", "MA", "text", 46],
                         ["For what vehicle class is your current license valid (A, B, C, or D)?", "D", "text", 47],
                         ["When does your current license expire?", "2020-12-16", "date", 48],
                         ["Traffic violations", nil, "heading", 49],
                         ["First violation", nil, "explanation", 50],
                         ["State", "", "text", 51],
                         ["Year", "", "text", 52],
                         ["Nature of violation", "", "text", 53],
                         ["Second violation", nil, "explanation", 54],
                         ["State", "", "text", 55],
                         ["Year", "", "text", 56],
                         ["Nature of violation", "", "text", 57],
                         ["Third violation", nil, "explanation", 58],
                         ["State", "", "text", 59],
                         ["Year", "", "text", 60],
                         ["Nature of violation", "", "text", 61],
                         ["**Note**: A copy of your driving record may be requested. If you have *any* previous experience as a CDL driver of any class, you must provide a copy of your driving record.", nil, "explanation", 62],
                         ["Referral information", nil, "heading", 63],
                         ["Have you previously applied for a job at UMass Transit?", "No", "yes/no", 64],
                         ["How did you hear about this job?", nil, "explanation", 65],
                         ["Advertisement inside bus", nil, "yes/no", 66],
                         ["Bus destination sign", nil, "yes/no", 67],
                         ["Poster in bus stop shelter", nil, "yes/no", 68],
                         ["Poster in Campus Center", nil, "yes/no", 69],
                         ["Resource fair / orientation", nil, "yes/no", 70],
                         ["Referred by employee", nil, "yes/no", 71],
                         ["If you selected 'Referred by employee', please enter his or her name:", "", "text", 72],
                         ["Are you a graduate student?", "No", "yes/no", 73],
                         ["Have you ever tested positive, or refused to test, on any pre-employment drug or alcohol test administered by an employer to which you did not obtain safety-sensitive transportation work covered by Department of Transportation agency drug and alcohol testing rules during the past two years?", "No", "yes/no", 74],
                         ["Voluntary Equal Employment Opportunity Information", nil, "heading", 75],
                         ["The University of Massachusetts and the Pioneer Valley Transit Authority are equal opportunity employers. To help us insure that we are complying with EEO policies, please supply the information requested below.", nil, "explanation", 76],
                         ["What is your gender?", "", "text", 77],
                         ["Are you a veteran?", nil, "yes/no", 78],
                         ["What is your race / ethnicity?", "", "text", 79],
                         ["All responses to the previous questions are true and correct to the best of your knowledge.", "Yes", "yes/no", 80]],
                  user_id: user.id,
                  position_id: position.id
# create staff members?
template = FactoryBot.create :application_template, position: position
ActiveRecord::Base.transaction do
  CSV.parse(<<QUESTIONS, headers: true, col_sep: ';').each do |row|
number;data_type;prompt;required
1;heading;Bus Application;false
3;yes/no;I understand and meet the above minimum requirements for entering the UMass Transit bus driver training program.;true
4;text;Local address (street, apt., etc.);true
5;text;Local address (city);true
6;text;Local address (state);true
7;text;Local address (zip code);true
8;text;Local phone number;true
9;text;Permanent address (street, apt., etc.);true
10;text;Permanent address (city);true
11;text;Permanent address (state);true
12;text;Permanent address (zip code);true
13;text;Permanent phone number;true
14;date;Date of birth;true
15;date;Anticipated graduation date;true
16;text;Major;true
17;number;How many credits are you enrolled in this semester?;true
18;yes/no;Are you interested in training during the summer?;true
19;heading;Employment History #1;false
20;text;Employer;true
21;text;Supervisor's name;true
22;text;Your job title;true
23;text;Address of employer;true
24;text;Phone number;true
25;date;Begin date;true
26;date;End date;true
27;number;Salary/wage;false
28;text;Reason for leaving;true
29;text;Job responsibilities;true
30;yes/no;May we contact this employer for a reference?;true
31;heading;Employment History #2;false
32;text;Employer;false
33;text;Supervisor's name;false
34;text;Your job title;false
35;text;Address of employer;false
36;text;Phone number;false
37;date;Begin date;false
38;date;End date;false
39;number;Salary/wage;false
40;text;Reason for leaving;false
41;text;Job responsibilities;false
42;yes/no;May we contact this employer for a reference?;false
43;heading;Driving experience;false
44;number;What year did you get your first driver's license?;true
45;text;Where was your first license issued?;true
46;number;For how many years have you been driving in the United States (must be at least 1 full year)?;true
47;text;In what state is your current license issued?;true
48;text;For what vehicle class is your current license valid (A, B, C, or D)?;true
49;date;When does your current license expire?;true
50;heading;Traffic violations;false
51;explanation;First violation;false
52;text;State;false
53;text;Year;false
54;text;Nature of violation;false
55;explanation;Second violation;false
56;text;State;false
57;text;Year;false
58;text;Nature of violation;false
59;explanation;Third violation;false
60;text;State;false
61;text;Year;false
62;text;Nature of violation;false
63;explanation;**Note**: A copy of your driving record may be requested. If you have *any* previous experience as a CDL driver of any class, you must provide a copy of your driving record.;false
64;heading;Referral information;false
65;yes/no;Have you previously applied for a job at UMass Transit?;true
66;explanation;How did you hear about this job?;false
67;yes/no;Advertisement inside bus;false
68;yes/no;Bus destination sign;false
69;yes/no;Poster in bus stop shelter;false
70;yes/no;Poster in Campus Center;false
71;yes/no;Resource fair / orientation;false
72;yes/no;Referred by employee;false
73;text;If you selected 'Referred by employee', please enter his or her name:;false
74;yes/no;Are you a graduate student?;true
75;yes/no;Have you ever tested positive, or refused to test, on any pre-employment drug or alcohol test administered by an employer to which you did not obtain safety-sensitive transportation work covered by Department of Transportation agency drug and alcohol testing rules during the past two years?;true
76;heading;Voluntary Equal Employment Opportunity Information;false
77;explanation;The University of Massachusetts and the Pioneer Valley Transit Authority are equal opportunity employers. To help us insure that we are complying with EEO policies, please supply the information requested below.;false
78;text;What is your gender?;false
79;yes/no;Are you a veteran?;false
80;text;What is your race / ethnicity?;false
81;yes/no;All responses to the previous questions are true and correct to the best of your knowledge.;true
QUESTIONS
    attrs = row.to_hash.merge application_template_id: template.id
    Question.create! attrs
    # making the min job requirements manually because newlines
  end
  Question.create!(application_template_id: template.id, number: 2, prompt: <<PROMPT, required: false, data_type: 'explanation')
Minimum Job Requirements for **Bus Driver**

+ You must have at least three semesters remaining as a UMass Student
+ You must be registered for the current or upcoming semester.
+ You must be willing to accept a work assignment of at least 15 hours per week during the semester.
+ You must be willing to work a minimum of 180 hours per semester for at least two full semesters after training is complete.
+ You must possess a driver's license that is valid in the United States.
+ You must be at least 18 years of age, and be able to communicate clearly in English.
+ You must be able to pass a NIDA-5 panel pre-employment drug screening and agree to participate in random, unannounced, NIDA-5 panel drug testing throughout your employment.
+ You must be willing to sign a legally binding contract that includes (but is not limited to) the above terms.
+ You must enjoy driving.
PROMPT
end
