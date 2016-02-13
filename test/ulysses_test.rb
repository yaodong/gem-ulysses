require 'test_helper'

class UlyssesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Ulysses::VERSION
  end

  def test_print
    library_path = File.expand_path(File.join(__dir__, 'fixtures', 'library'))
    library = Ulysses::Library.new library_path

    fixture  = File.expand_path(File.join(__dir__, 'fixtures', 'print.html'))
    expected = File.read(fixture)
    printed  = Ulysses::Printer.new(library).print

    assert_equal expected, printed
  end

end
