class StringInput < SimpleForm::Inputs::StringInput

  def input_html_classes
    super
  end

  def input(wrapper_options = nil)
    if options[:disabled]
      template.content_tag(:div, class: 'form-control') do
        c = @builder.object.send(attribute_name)
        '&nbsp;' if c.blank?
        template.concat @builder.object.send(attribute_name)
      end
    else
      super
    end
  end

end
