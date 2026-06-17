# frozen_string_literal: true

# We need to override the default CollectionRadioButtons because we need to distinguish between multiple
# radio buttons that have the same name. We do this by passing an id into the options and then using that as
# the id and the label for the radio button.
class WeRadioButtonsInput < SimpleForm::Inputs::CollectionInput

  def input(wrapper_options = nil)
    label_method, value_method = detect_collection_methods

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options[:class] = 'form-check-input radio-buttons optional'

    @builder.send(:"collection_radio_buttons",
                  attribute_name, collection, value_method, label_method,
                  input_options, merged_input_options,
                  &collection_block
    )
  end

  def input_options
    options = super
    wrapper = options[:wrapper_html] || {}
    options[:item_wrapper_class] = ['form-check', 'collection_radio_buttons'].compact.presence
    options[:item_wrapper_tag] = 'div'
    options[:collection_wrapper_tag] = 'fieldset'
    options[:collection_wrapper_class] = ['mb-3', 'radio_buttons', wrapper[:class]].compact
    options
  end

  protected

  def collection_block
    proc { |builder| build_item_tag(builder, @options[:id]) }
  end

  def build_item_tag(collection_builder, id)
    collection_builder.radio_button(id: "#{id}_#{collection_builder.text}") + collection_builder.label(class: 'form-check-label', for: "#{id}_#{collection_builder.text}")
  end

  # Do not attempt to generate label[for] attributes by default, unless an
  # explicit html option is given. This avoids generating labels pointing to
  # non existent fields.
  def generate_label_for_attribute?
    false
  end
end
