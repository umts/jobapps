require 'prawn/table'
include DateAndTimeMethods

class PrintRecordPdf < Prawn::Document
  def initialize(record)
    super()
    @record = record
    stroke do
      rounded_rectangle [0, bounds.height], bounds.width, bounds.height, 5
    end
    content_width = bounds.width - 10
    content_height = bounds.height - 10
    column_width = content_width / 2
    header_content(content_width)
    table_content(content_width, column_width)
  end

  def header_content(content_width)
    date = format_date_time(@record.created_at)
    name = @record.user.full_name
    email = @record.user.email
    bounding_box([5, cursor], width: content_width) do
      font "Helvetica"
      move_down 20
      text "#{@record.position.name} Application Record", size: 24
      text "submitted #{date} by #{name}, #{email}"
      move_down 5
      move_down 10
    end
  end

  def table_content(content_width, column_width)
    bounding_box([5, cursor - 5], width: content_width) do
      table data_rows do
        style row(0), size: 20, font_style: :bold
        cells.padding = 12
        self.header = true
        self.column_widths = [column_width, column_width]
        self.cell_style = { borders: [:bottom], border_width: 0.5 }
      end
    end
  end

  def data_rows
    header = [%w(Question Response)]
    # deletes rows of type header/explanation
    questions = @record.data.delete_if do |_prompt, _response, data_type, _id|
      %w(heading explanation).include? data_type
    end.map do |prompt, response, _data_type, _id|
      [prompt, response]
    end
    header + questions
  end
end
