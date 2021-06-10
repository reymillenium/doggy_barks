module CommonHelper
  extend self

  # Get human representation for given resource
  def humanize_resource(resource, options = {})

    # Default values
    namespace = options.delete(:namespace) || 'resources'

    # Humanize the resource model if compatible with model name
    if get_resource_class(resource).respond_to?(:model_name)
      humanize_model resource, options

    else

      # Translate resource or use the string representation
      string = (I18n.translate "#{namespace}.#{resource}", raise: true) rescue resource.to_s

      # Apply human options to resulting string
      apply_human_options string, options
    end

  end

  # Humanize resource model if possible
  def humanize_model(resource, options = {})

    # Get humanized model name or use resource string representation
    string = (get_resource_class resource).model_name.human rescue resource.to_s

    # Apply human options to resulting string
    apply_human_options string, options
  end

  # Humanize resource attribute if possible
  def humanize_attribute(resource, attribute, options = {})

    # Get human attribute name if possible or use the string representation
    string = (get_resource_class resource).human_attribute_name(attribute) rescue attribute.to_s

    # Return the humanized representation
    apply_human_options string, options
  end

  # Apply_human_options values
  def humanize_value(value, options = {})

    # Default values
    namespace = options.delete(:namespace) || 'values'

    # Get human representation
    string = value.to_s.present? ? (I18n.translate("#{namespace}.#{value}", raise: true) rescue I18n.translate("#{namespace}._#{value}", raise: true) rescue value.to_s) : nil

    # Return the humanized representation
    apply_human_options string, options
  end

  # Apply human options to an string (pluralization, titleization, and more...)
  def apply_human_options(string, options = {})

    # Ensure to process an string
    unless string.is_a? String
      string = string.to_s
    end

    # Humanize unless is not required
    unless options[:humanize] === false
      string = string.humanize
    end

    if options[:capitalize]
      string = string.capitalize
    end

    if options[:titleize]
      string = string.titleize
    end

    if options[:downcase]
      string = string.downcase
    end

    if options[:upcase]
      string = string.upcase
    end

    if options[:pluralize]
      string = string.pluralize
    end

    # Return the humanized string
    string
  end

  # Get resource class
  def get_resource_class(resource)
    if resource.is_a? Class
      resource
    else
      resource.class
    end
  end

  # Check if it has any filter
  def have_any_filter?(filter)
    filter.values.select do |value|
      value.is_a?(Array) ? value.select(&:present?).present? : value.present?
    end.present? rescue false
  end

  def status_tag(caption, options = {}, &block)
    value_label_tag(caption, options.merge(mapper: ->(status) {
      case status
      when :ready then "success"
      when :summarizing then "warning"
      when :error then "danger"
      else "default"
      end
    }), &block)
  end

  def ellipsis_span
    raw("<span>...</span>")
  end

end