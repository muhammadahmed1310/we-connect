class HtmlInput < SimpleForm::Inputs::TextInput

  def input_html_options
    if options[:disabled]
      super
    else
      super.merge(class: 'html-text-area')
    end
  end

  def input(wrapper_options = nil)
    if options[:disabled]
      template.content_tag(:div, class: 'form-control disabled') do
        c = @builder.object.send(attribute_name)
        c = '&nbsp;' if c.blank?
        template.concat c.html_safe
      end
    else
      super
    end
  end

end
