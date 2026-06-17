table_fields_for(controller.model).each do |f|
  json.set! f[:name], item[f[:name]]
end
