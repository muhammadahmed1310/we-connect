class ExcelUploadService
  def initialize(file, model_class, parser, current_user: nil)
    @file         = file
    @model_class  = model_class
    @parser       = parser
    @current_user = current_user
  end

  def call
    return failure('Invalid file type') unless valid_excel?

    spreadsheet = Roo::Spreadsheet.open(@file.tempfile)

    result = nil
    PaperTrail.request(enabled: false) do
      unless @parser.respond_to?(:parse_data)
        return failure("Parser missing parse_data method")
      end

      m = @parser.method(:parse_data)

      # 1) Parser accepts keywords (Ruby 2.7+/3): use keyword
      if accepts_keywords?(m)
        result = m.call(spreadsheet, current_user: @current_user)

        # 2) Parser has an optional/rest second arg: send an options hash positionally
      elsif accepts_positional_options?(m)
        result = m.call(spreadsheet, { current_user: @current_user })

        # 3) Legacy: only wants the sheet
      else
        result = m.call(spreadsheet)
      end
    end

    result || failure('Unknown error')
  rescue => e
    Rails.logger.error("Failed to upload file: #{e.class}: #{e.message}")
    failure(e.message)
  end

  private

  def failure(message)
    { success: false, message: message, errors: [] }
  end

  def valid_excel?
    return true if @file.respond_to?(:content_type) &&
      %w[
                     application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                     application/vnd.ms-excel
                   ].include?(@file.content_type)

    # Fallback to filename extension
    fname = @file.respond_to?(:original_filename) ? @file.original_filename : @file.to_s
    ext   = File.extname(fname).delete('.').downcase
    %w[xls xlsx].include?(ext)
  end

  def accepts_keywords?(method_obj)
    method_obj.parameters.any? { |kind, name| [:key, :keyreq, :keyrest].include?(kind) }
  end

  def accepts_positional_options?(method_obj)
    # Allow a second positional arg (optional or rest) for options
    params = method_obj.parameters
    params.any? { |kind, _| [:opt, :rest].include?(kind) } || params.size >= 2
  end
end
