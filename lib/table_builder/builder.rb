module TableBuilder
  class Builder

    attr_accessor :object_name, :object, :options, :columns

    def initialize(object, template, options, proc)
      @object, @template, @options, @proc = object, template, options, proc
      @columns = []
    end

    def column(column_name, options={}, &block)
      if block_given?
        value = block
      else
        value = lambda { |row| row.send(column_name) }
      end
      columns << {:name => column_name, :label => options.delete(:label) || column_name.to_s.titleize, :value => value}.merge(options)
    end
  end
end