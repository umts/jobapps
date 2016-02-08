module DashboardHelper
  def header_font_size(text)
    longest_word = text.split.max_by(&:length).length
    if longest_word < 10
      24
    else
      24 - (longest_word - 10)
    end
  end
end