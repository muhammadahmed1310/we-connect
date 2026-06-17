class DropdownInput < SimpleForm::Inputs::CollectionSelectInput

  def input_html_classes
    classes = []
    if options[:multiple] || (options[:input_html] && options[:input_html][:multiple])
      classes.push('select2')
    end
    classes.push('autosubmit') if options[:autosubmit]
    classes.push('form-control')
    super + classes
  end

end
