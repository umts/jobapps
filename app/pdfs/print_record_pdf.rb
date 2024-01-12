# frozen_string_literal: true

require 'prawn'
require 'prawn/table'

class PrintRecordPdf
  include Prawn::View

  def initialize(record)
    @record = record
    @content_width = bounds.width - 10

    font 'DejaVu Sans'

    page_border
    header_content
    table_content
    return if @record.unavailability.blank?

    start_new_page
    unavailability_calendar
  end

  private

  def document
    @document ||= Prawn::Document.new.tap do |doc|
      doc.font_families.update 'DejaVu Sans' => {
        normal: Rails.root.join('app/assets/fonts/DejaVuSans.ttf')
      }
    end
  end

  def header_content
    date = @record.created_at.to_formatted_s :long_with_time
    name = @record.user.full_name
    email = @record.user.email
    bounding_box([5, cursor], width: @content_width) do
      move_down 20
      text "#{@record.position.name} Application Record", size: 24
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

  def table_content
    bounding_box([5, cursor - 5], width: @content_width) do
      column_widths = [(@content_width / 2), (@content_width / 2)]
      cell_style = { borders: [:bottom], border_width: 0.5, font: 'DejaVu Sans', padding: 12 }

      table(table_data, header: true, column_widths:, cell_style:)
    end
  end

  def table_data
    headers = [make_cell(content: 'Question', size: 20), make_cell(content: 'Response', size: 20)]

    @record.data.filter_map do |prompt, response, data_type, _id|
      next if %w[heading explanation].include? data_type

      [prompt, response]
    end.unshift headers
  end

  def unavailability_rows
    headers = Unavailability::HOURS.dup.unshift nil
    rows = Date::DAYNAMES.map do |name|
      ([nil] * Unavailability::HOURS.count).unshift name
    end
    rows.unshift headers
  end

  def unavailability_calendar
    move_down 10
    text 'Applicant Unavailability', size: 24, align: :center
    unavailability = @record.unavailability
    table unavailability_rows, position: :center do
      style row(0), size: 10
      cells.style do |cell|
        cell.background_color = 'b0b0b0' if unavailability.grid[cell.row - 1][cell.column - 1]
      end
    end
  end
end
