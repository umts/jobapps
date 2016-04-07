require 'rails_helper'

describe ApplicationHelper do
  describe 'text' do
    before :each do
      @site_text = create :site_text
    end
    it 'renders a site text if it exists' do
      expect(text @site_text.name).not_to be_blank
    end
    it 'renders nothing if a site text does not exist' do
      expect(text 'some random string').to be_blank
    end
  end

  describe 'parse_application_data' do
    before :each do
      @data = {}
      (0..4).each do |num|
        %w(prompt response data_type).each do |type|
          @data["#{type}_#{num}"] = "#{num}-#{type}"
        end
        @data[num.to_s] = "#{num}-#{num}"
      end
      @result = parse_application_data(@data)
                .select { |sub| !sub.nil? && sub.all? }
    end

    it 'does not return nothing when given data' do
      expect(@result.length).not_to be_zero
    end

    it 'generates the correct amount of data' do
      expect(@result.length).to be(5)
      @result.each do |subarray|
        expect(subarray.length).to be(4)
        expect(subarray.count(nil)).to be(0)
      end
    end

    it 'generates proper data' do
      @result.each_with_index do |subarray, index|
        %w(prompt response data_type).each do |type|
          expect(subarray).to include("#{index}-#{type}")
        end
        expect(subarray).to include(index + 1)
      end
    end
  end
end
