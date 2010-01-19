module TableBuilder
  module Helpers
    # table_for @discount_codes do |table|
    #   table.column :code
    #   table.column :description
    #   table.column :max_uses, :label => 'Maximum Uses' do |discount_code|
    #     discount_code.max_uses || 'Unlimited'
    #   end
    # end

    def table_for(object, *args, &block)
      raise ArgumentError, "Missing block" unless block_given?
      options = args.extract_options!
      builder = TableBuilder::Builder.new(object, self, options, block)

      table_class = []
      table_class << options.delete(:class)
      table_class = table_class.compact.join ' '

      concat '<div class="table">'
      concat "<table cellspacing=\"0\" cellpadding=\"0\" class=\"#{table_class}\">"

      yield builder

      # <colgroup>
      #   <col class="id" />
      #   <col class="code" />
      # </colgroup>

      concat '<colgroup>'

      number_of_columns = builder.columns.size

      builder.columns.each_with_index do |column, index|
        concat "<col class=\"#{column[:name]}#{" last" if (index + 1 == number_of_columns)}\" />"
      end
      concat '</colgroup>'

      # <thead>
      #   <tr>
      #         <th>ID</th>
      #         <th>Code</th>
      #   </tr>
      # </thead>

      concat '<thead><tr>'
      builder.columns.each do |column|
        th_options = column[:th] || {}
        
        style = []
        style << 'display:none;' if column[:hidden]
        style << th_options[:style]
        style = style.compact.join ' '

        concat "<th class=\"#{th_options[:class]}\" id=\"#{th_options[:id]}\" style=\"#{style}\" >"
        concat column[:label]
        concat '</th>'
      end
      concat '</tr></thead>'
      concat '<tbody>'
      object.each do |row|
        concat "<tr class=\"#{cycle('', 'odd') unless options[:sortable]}\">"
        builder.columns.each do |column|
          style = []
          style << 'display:none;' if column[:hidden]
          style << column[:th_style]
          style = style.compact.join ' '

          concat "<td class=\"#{column[:td_class]}\" id=\"#{column[:td_id]}\" style=\"#{style}\">"
          concat column[:value].call(row).to_s || ''
          concat '</td>'
        end
        concat '</tr>'
      end
      concat '</tbody>'
      concat '</table>'
      concat '</div>'
    end
  end
end