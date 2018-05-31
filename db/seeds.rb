require 'factory_bot_rails'
require 'csv'

exit if Rails.env.test?
FactoryBot.create :user, first_name: 'David', last_name: 'Faulkenberry', staff: true, spire: '12345678@umass.edu', email: 'dfaulken@umass.edu', admin: true

FactoryBot.create :site_text, name: 'welcome', text: 'Welcome to the UMass Transit job application page.'
markdown_text = FactoryBot.create :site_text, name: 'markdown explanation'
markdown_text.update text: <<MARKDOWN
Configurable site text is interpreted and shown to end users using a protocol known as Markdown. This means that you can do some of your own text formatting. Here's how:

+ Surround text with \*asterisks\* or \_underscores\_for *italic text*
+ Surround text with \*\*double asterisks\*\* or \_\_double underscores\_\_ for **bold text**
+ Start lines with a plus (`+`), a minus (`-`), or an asterisk (`*`) to make a list (that's how we made this one!).
+ For links, write the link text in [brackets] followed by the destination in (parentheses). Here's an example:
+ Typing '`[our homepage](https://umasstransit.org)`' outputs the following link: [our homepage](https://umasstransit.org)

For additional information, we like to reference [this tutorial](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) (and if you're feeling particularly meta, feel free to check out [how we wrote a Markdown tutorial in Markdown](/site_texts/#{markdown_text.id}/edit)).
MARKDOWN
department = FactoryBot.create :department, name: 'Bus'
position = FactoryBot.create :position, department: department, name: 'Operator'
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
