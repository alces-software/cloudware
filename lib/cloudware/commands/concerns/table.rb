# frozen_string_literal: true

require 'tty/pager'

module Cloudware
  module Commands
    module Concerns
      module Table
        def table
          @table ||= TTY::Table.new header: table_header
        end

        def page_table
          if $stdout.isatty
            TTY::Pager.new.page(render_table)
          else
            puts render_table
          end
        end

        def render_table
          table.render(:unicode, multiline: true, width: table.width + 10)
        end
      end
    end
  end
end
