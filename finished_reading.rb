require 'tk'
require_relative 'database'

def open_finished_books_window(root)
  current_win = TkToplevel.new(root) do
    title "Finished Books"
    minsize(775,400)
  end

  current_listbox = TkListbox.new(current_win) do
    width 60
    height 10
    pack('padx' => 10, 'pady' => 10, 'fill' => 'both', 'expand' => true)
  end

  BookDatabase.update_completed_listbox(current_listbox)
end