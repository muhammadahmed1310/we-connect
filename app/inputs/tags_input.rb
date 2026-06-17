

# f.input :collection_names, :as => :tags, :collection => possible_tag_array,
#                            :value => current_comma_delimited_tags
#
class TagsInput < SimpleForm::Inputs::Base

  def input_html_options
    super['data-tagit-tags'] = options.delete(:collection).join(',')
    super.merge!(value: options.delete(:value))
  end

  def input_html_classes
    span = options.delete(:span)
    span ||= '3'
    super.push("span#{span}")
  end

  def input
    @builder.text_field(attribute_name, input_html_options)
  end

end
