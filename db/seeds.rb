require 'factory_bot_rails'
require 'csv'

exit if Rails.env.test?
FactoryBot.create :user, first_name: 'David', last_name: 'Faulkenberry', staff: true, spire: '12345678@umass.edu', email: 'dfaulken@umass.edu', admin: true
user = FactoryBot.create :user, first_name: 'Justin', last_name: 'Forgue', spire: '13579246@umass.edu', email: 'jforgue@umass.edu'
department = FactoryBot.create :department, name: 'Bus'
position = FactoryBot.create :position, department: department, name: 'Operator'
FactoryBot.create :application_submission,
                  data: [["Bus Application", nil, "heading", 1],
                         [<<~REQS, nil, 'explanation', 4],
                          Minimum Job Requirements for **Application**

                          + You know how to select yes/no
                          + You must be able to read and type
                         REQS
                         ["I understand and meet the above minimum requirements for this application.", "No", "yes/no", 2],
                         ["What are the primary colors?", "Cyan, fuchsia", "text", 3],
                         ["what is 2 + 2?", "5", "number", 4],
                         ["What day is it?", "12/19/2018", "date", 5],
                         ["Newton's third law states that for every action (force) in nature there is an equal and opposite reaction.", nil, "explanation", 6]],
                   user_id: user.id,
                   position_id: position.id

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
# create staff members?
template = FactoryBot.create :application_template, position: position
ActiveRecord::Base.transaction do
  CSV.parse(<<QUESTIONS, headers: true, col_sep: ';').each do |row|
number;data_type;prompt;required
1;heading;Application;false
3;yes/no;I understand and meet the above minimum requirements for this application.;true
4;text;What are the primary colors?;false
5;number;what is 2 + 2?;false
6;date;What day is it?;false
7;explanation;Newton's third law states that for every action (force) in nature there is an equal and opposite reaction.;false
QUESTIONS
    attrs = row.to_hash.merge application_template_id: template.id
    Question.create! attrs
    # making the min job requirements manually because newlines
  end
  Question.create!(application_template_id: template.id, number: 2, prompt: <<PROMPT, required: false, data_type: 'explanation')
Application Requirements for **Position**

+ You know how to select yes/no
+ You must be able to read and type
PROMPT
end
