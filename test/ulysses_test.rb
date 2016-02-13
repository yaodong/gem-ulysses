require 'test_helper'

class UlyssesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Ulysses::VERSION
  end

  def test_print
    library_path = File.expand_path(File.join(__dir__, 'fixtures', 'library'))
    export_file  = File.expand_path(File.join(__dir__, 'fixtures', 'print.html'))
    library = Ulysses::Library.new library_path
    printer = Ulysses::Printer.new(library)
    assert_equal File.read(export_file), printer.print
  end

end
