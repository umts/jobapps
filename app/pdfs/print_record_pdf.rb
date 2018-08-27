require 'prawn/table'
include DateAndTimeMethods

class PrintRecordPdf < Prawn::Document
  def initialize(record)
    super()
    font_families.update(
      "DejaVu Sans" => {
        normal: "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf"
      }
    )
    font 'DejaVu Sans'
    page_border
    content_width = bounds.width - 10
    column_width = content_width / 2
    header_content(content_width, record)
    table_content(content_width, column_width, record)
    if record.unavailability.present?
      start_new_page
      unavailability_calendar(record.unavailability)
    end
  end

  def header_content(content_width, record)
    date = format_date_time(record.created_at)
    name = record.user.full_name
    email = record.user.email
    bounding_box([5, cursor], width: content_width) do
      font 'Helvetica'
      move_down 20
      text "#{record.position.name} Application Record", size: 24
      text "submitted #{date} by #{name}, #{email}"
      move_down 5
      move_down 10
    end
  end

  def page_border
    repeat(:all) do
      stroke do
        rounded_rectangle [0, bounds.height], bounds.width, bounds.height, 5
      end
    end
  end

  def table_content(content_width, column_width, record)
    bounding_box([5, cursor - 5], width: content_width) do
      table record.data_rows do
        style row(0), size: 20
        cells.padding = 12
        self.header = true
        self.column_widths = [column_width, column_width]
        self.cell_style = { borders: [:bottom], border_width: 0.5 }
      end
    end
  end

  def unavailability_rows
    headers = Unavailability::HOURS.dup.unshift nil
    rows = Date::DAYNAMES.map do |name|
      ([nil] * Unavailability::HOURS.count).unshift name
    end
    rows.unshift headers
  end

  def unavailability_calendar(unavailability)
    move_down 10
    text 'Applicant Unavailability', size: 24, align: :center
    table unavailability_rows, position: :center do
      style row(0), size: 10
      cells.style do |cell|
        if unavailability.grid[cell.row - 1][cell.column - 1]
          cell.background_color = 'b0b0b0'
        end
      end
    end
  end
end
