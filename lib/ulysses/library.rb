module Ulysses
  class Library

    DEFAULT_LIBRARY_DIR = '~/Library/Mobile Documents/X5AZV975AG~com~soulmen~ulysses3/Documents/Library'

    attr_reader :dirname

    def initialize(dirname = nil)
      @dirname = File.expand_path(dirname ||= DEFAULT_LIBRARY_DIR)
    end

    def groups
      @groups ||= parse_groups
    end

    def reload
      @groups = nil
    end

    private

    def parse_groups
      Dir.glob(File.join @dirname, 'Groups-ulgroup', '*.ulgroup').map do |info_file|
        Group.new info_file
      end
    end

  end
end
