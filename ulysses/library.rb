module Ulysses
  class Library

    attr_reader :dirname

    def initialize(dirname = nil)
      dirname ||= '~/Library/Mobile Documents/X5AZV975AG~com~soulmen~ulysses3/Documents/Library'
      @dirname = File.expand_path(dirname)
    end

    def groups
      Dir.glob(File.join @dirname, 'Groups-ulgroup', '*.ulgroup').map do |info_file|
        Group.new info_file
      end
    end

  end
end
