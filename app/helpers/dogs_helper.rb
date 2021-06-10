module DogsHelper
  extend self

  # Display value if applicable
  def if_applicable(value, titleize: true, not_applicable: t('messages.not_applicable'), attribute: nil)

    # Return not applicable if there is no value
    unless value.present?
      return not_applicable
    end

    # Replace value for an attribute of a given object
    if attribute.present?
      value = value.send(attribute)
    end

    # Apply options
    if titleize
      value = value.to_s.titleize
    end

    # Return the enhanced value
    value
  end

  # Gets the proper fontawesome classes to represent a present or missing value:
  def fontawesome_class_if_done(value)
    return (value.nil? || value.to_s.strip.empty? || value == 'Unknown' || value == 'N/A') ? 'fa fa-times' : 'fa fa-check'
  end

  # Gets an alternative description for a Dog object without one:
  def description_by_value(string)
    return (string.nil? || string.strip.empty? || string == 'N/A') ? 'There is no much information about this beauty' : string
  end
end
