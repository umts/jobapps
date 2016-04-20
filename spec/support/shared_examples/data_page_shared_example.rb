shared_examples 'a data page' do |tables|
  it 'contains all requires tables' do
    tables.each do |table_name|
      expect page.has_table? table_name
    end
  end
end
