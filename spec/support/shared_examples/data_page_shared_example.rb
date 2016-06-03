shared_examples 'a data page' do |table_ids:|
  it 'contains all required tables' do
    table_ids.each do |table_id|
      expect(page).to have_table table_id
    end
  end
end
