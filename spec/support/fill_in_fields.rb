# frozen_string_literal: true

# Using the human attribute names for the given AR model
# and the hash of attributes from the keyword argument,
# fills in form elements with the provided attributes
def fill_in_fields_for(model, attributes:)
  attributes.each do |attribute, value|
    name = model.human_attribute_name attribute
    value = value.name if value.respond_to? :name
    if page.has_selector? :fillable_field, name then fill_in name, with: value
    elsif page.has_selector? :select, name then select value, from: name
    else
      raise Capybara::ElementNotFound, "Unable to find field #{name}"
    end
  end
end
