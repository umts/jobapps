require 'prawn/table'
include DateAndTimeMethods

class PrintRecordPdf < Prawn::Document
  def initialize(record)
    super()
    @record = record
    page_width = bounds.width
    column_width = bounds.width / 2
    header_content(page_width, column_width)
    table_content(page_width, column_width)
  end

  def header_content(page_width, column_width)
    bounding_box([0, cursor], width: page_width) do
      cell_style = { border_color: 'FFFFFF', align: :center }
      table text_content, cell_style: cell_style do
        column(0).font_style = :bold
        self.column_widths = [column_width, column_width]
      end
    end
    move_down 10
  end

  def text_content
    [[format_date_time(@record.created_at)], [@record.user.full_name, @record.user.email, ]]
  end

  def table_content(page_width, column_width)
    bounding_box([0, cursor], width: page_width) do
      table data_rows do
        row(0).font_style = :bold
        row(0).align = :center
        self.header = true
        self.row_colors = %w(DDDDDD FFFFFF)
        self.column_widths = [column_width, column_width]
      end
    end
  end

  def data_rows
    header = [%w(Question Answer)]
    questions = @record.data.delete_if do |_prompt, _response, data_type, _id|
      %w(heading explanation).include? data_type
    end.map do |prompt, response, _data_type, _id|
      [prompt, response]
    end
    header + questions
  end
end
