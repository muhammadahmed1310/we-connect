

class TimepickerInput < SimpleForm::Inputs::StringInput

  # def input_html_options
    # super.merge!('data-datepicker' => Locale.datepicker_dateformat)
  # end

  def input_html_classes
    super.push('form-control').push('datepicker')
  end

  # def input(wrapper_options = nil)
  #   template.content_tag(:div, class: 'input-group date form_datetime') do
  #     template.concat @builder.text_field(attribute_name, input_html_options)
  #     template.concat span_table
  #   end
  # end
  #
  # def span_table
  #   template.content_tag(:span, class: 'input-group-addon datepicker-trigger') do
  #     template.concat icon_table
  #   end
  # end
  #
  # def icon_table
  #   "<i class='fa fa-calendar'></i>".html_safe
  # end

end
