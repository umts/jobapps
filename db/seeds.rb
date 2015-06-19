require 'factory_girl_rails'

# If you wish to clear your database prior to running this file,
# you may do so by uncommenting the following:
#=begin
Rails.application.eager_load!
table_names = ActiveRecord::Base.connection.tables.select do |table_name|
  Object.const_defined? table_name.classify
end
tables = table_names.map { |table_name| table_name.classify.constantize }
tables.each(&:delete_all)
#=end

# SITE TEXTS
FactoryGirl.create :site_text, name: 'welcome', text: 'Welcome to the job application page.'

# DEPARTMENTS
department = FactoryGirl.create :department, name: 'Our department'

# POSITIONS
position = FactoryGirl.create :position, department: department, name: 'The best job'

# USERS
staff_member = FactoryGirl.create :user, :staff, first_name: 'Staff', last_name: 'member'
students = Hash.new
%w(with_no_applications with_pending_application with_denied_application with_completed_interview with_pending_interview).each do |student_type|
  students[student_type] = FactoryGirl.create :user, :student, first_name: 'Student', last_name: student_type.humanize.downcase
end

# APPLICATION RECORDS

                             FactoryGirl.create :application_record, user: students['with_pending_application'], position: position, reviewed: false, responses: { 'Do you want this job?' => "I'm not sure yet." }
                             FactoryGirl.create :application_record, user: students['with_denied_application'],  position: position, reviewed: true,  responses: { 'Will you submit to take a drug test?' => 'No thanks.' }
completed_interview_record = FactoryGirl.create :application_record, user: students['with_completed_interview'], position: position, reviewed: true,  responses: { 'Are you qualified for this position?' => 'Yes!' }
pending_interview_record =   FactoryGirl.create :application_record, user: students['with_pending_interview'],   position: position, reviewed: true,  responses: { 'Are you qualified for this position?' => 'Yes!' }

# INTERVIEWS
FactoryGirl.create :interview, user: students['with_completed_interview'], application_record: completed_interview_record, completed: true,  hired: true,  location: "The conference room", scheduled: (DateTime.now - 1.day)
FactoryGirl.create :interview, user: students['with_pending_interview'],   application_record: pending_interview_record,   completed: false, hired: false, location: "The break room",      scheduled: (DateTime.now + 1.day)

# APPLICATION TEMPLATES
template = FactoryGirl.create :application_template, position: position

# QUESTIONS
# One question per data type should be enough for development purposes.
FactoryGirl.create :question, application_template: template, number: 1, prompt: 'Please answer the questions below.',     data_type: 'heading',     required: false
FactoryGirl.create :question, application_template: template, number: 2, prompt: 'What is your name?',                     data_type: 'text',        required: true
FactoryGirl.create :question, application_template: template, number: 3, prompt: 'How old are you?',                       data_type: 'number',      required: false
FactoryGirl.create :question, application_template: template, number: 4, prompt: 'Do you want to work here?',              data_type: 'yes/no',      required: true
FactoryGirl.create :question, application_template: template, number: 5, prompt: 'When would you like to start?',          data_type: 'date',        required: true
FactoryGirl.create :question, application_template: template, number: 6, prompt: 'Your answers will remain confidential.', data_type: 'explanation', required: false


# MARKDOWN EXPLANATION SITE TEXT
FactoryGirl.create :site_text, name: 'markdown explanation', text: <<MARKDOWN
Configurable site text is interpreted and shown to end users using a protocol known as Markdown. This means that you can do some of your own text formatting. Here's how:

+ Surround text with \*asterisks\* or \_underscores\_for *italic text*
+ Surround text with \*\*double asterisks\*\* or \_\_double underscores\_\_ for **bold text**
+ Start lines with a plus (`+`), a minus (`-`), or an asterisk (`*`) to make a list (that's how we made this one!).
+ For links, write the link text in [brackets] followed by the destination in (parentheses). Here's an example:
  + Typing '`[our homepage](https://umasstransit.org)`' outputs the following link: [our homepage](https://umasstransit.org)

For additional information, we like to reference [this tutorial](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) (and if you're feeling particularly meta, feel free to check out [how we wrote a Markdown tutorial in Markdown](/site_texts/3/edit)).
MARKDOWN
