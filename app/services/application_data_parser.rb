# frozen_string_literal: true

# A complete question data set might look like:
# { "prompt_0"    => "What is your name?",
#   "response_0"  => "Luke Starkiller",
#   "data_type_0" => "text",
#   "316"         => "316-1" }
# which would translate in an application record's data to:
# ['What is your name?', 'Luke Starkiller', 'text', 316]
class ApplicationDataParser
  INPUT_TYPES = %w[prompt response data_type].freeze

  def initialize(data)
    @data = data
    @questions = []
    @processing_complete = false
  end

  def process!
    @questions = []
    @data.each do |key, value|
      if (index = data_field_index(key))
        store_question_data(key, value, index)
      else
        store_question_id(value)
      end
    end
    @processing_complete = true
    @questions
  end

  def result
    process! unless @processing_complete
    @questions
  end

  private

  def data_field_index(key)
    INPUT_TYPES.index key.sub(/_\d+\z/, '')
  end

  def store_question_data(key, value, dindex)
    index = key.split('_').last.to_i
    @questions[index] ||= []
    @questions[index][dindex] = value
  end

  # e.g. "316-1" (for the first question)
  def store_question_id(value)
    id, index = value.split('-').map(&:to_i)
    index -= 1 #question ids are 1-indexed
    @questions[index] ||= []
    @questions[index][INPUT_TYPES.length] = id
  end
end
