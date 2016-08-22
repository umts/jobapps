require 'prawn/table'
include DateAndTimeMethods

class PrintRecordPdf < Prawn::Document
  def initialize(record)
    super()
    @record = record
    repeat(:all) do
      stroke do
        rounded_rectangle [0, bounds.height], bounds.width, bounds.height, 5
      end
    end
    content_width = bounds.width - 10
    column_width = content_width / 2
    header_content(content_width)
    table_content(content_width, column_width)
    start_new_page
    if @record.unavailability
      unavailability_calendar
    end
  end

  def header_content(content_width)
    date = format_date_time(@record.created_at)
    name = @record.user.full_name
    email = @record.user.email
    bounding_box([5, cursor], width: content_width) do
      font 'Helvetica'
      move_down 20
      text "#{@record.position.name} Application Record", size: 24
      text "submitted #{date} by #{name}, #{email}"
      move_down 5
      move_down 10
    end
  end

  def table_content(content_width, column_width)
    bounding_box([5, cursor - 5], width: content_width) do
      table @record.data_rows do
        style row(0), size: 20
        cells.padding = 12
        self.header = true
        self.column_widths = [column_width, column_width]
        self.cell_style = { borders: [:bottom], border_width: 0.5 }
      end
    end
  end

  def unavailability_calendar
    text "Applicant Unavailability", size: 24, align: :center
    table @record.unavailability_rows, position: :center do
      style row(0), size: 10
      padding = 12
    end
  end
end
