require 'tk'
require_relative 'database'

def open_current_books_window(root)
  current_win = TkToplevel.new(root) do
    title "Current Books"
    minsize(775,400)
  end

  current_listbox = TkListbox.new(current_win) do
    width 60
    height 10
    pack('padx' => 10, 'pady' => 10, 'fill' => 'both', 'expand' => true)
  end

  BookDatabase.update_current_book_listbox(current_listbox)

  buttons_frame = TkFrame.new(current_win) do
    pack('padx' => 10, 'pady' => 10, 'fill' => 'x')
  end
  
  TkButton.new(buttons_frame) do
    text "Update Progress"
    command do
      # Get the currently selected item in the current reading listbox.
      selected_index = current_listbox.curselection.first rescue nil
      if selected_index.nil?
        Helpers.show_error("No Selection", "Please select a book to update progress.")
        next
      end
  
      selected_item = current_listbox.get(selected_index)
      # Expected format: "ID: <id> | Title: ... | Authors: ... | Start Date: ... | Progress: ..."
      if selected_item =~ /^ID:\s*(\d+)\s*\|/
        current_id = $1.to_i
        new_progress = Helpers.get_simple_string("Update Progress", "Enter new progress (pages read):")
        if new_progress.nil? || new_progress.strip.empty? || new_progress !~ /^\d+$/
          Helpers.show_error("Invalid Input", "Please enter a valid number for progress.")
        else
          new_progress = new_progress.to_i
          # Update the progress for the selected current reading record.
          BookDatabase.db.execute("UPDATE current_books SET progress = ? WHERE id = ?", [new_progress, current_id])
          Helpers.show_info("Progress Updated", "Progress updated successfully.")
          # Refresh the current reading listbox.
          BookDatabase.update_current_book_listbox(current_listbox)
        end
      else
        Helpers.show_error("Error", "Could not determine the current book ID.")
      end
    end
    pack('side' => 'left', 'padx' => 5)
  end
  
  TkButton.new(buttons_frame) do
    text "Update Total Pages"
    command do
      selected_indices = current_listbox.curselection
      selected_index = selected_indices.first rescue nil
      if selected_index.nil?
        Helpers.show_error("No Selection", "Please select a book from your currently reading list.")
        next
      end
  
      selected_item = current_listbox.get(selected_index)
      # Expected format: "ID: <current_book_id> | Book ID: <book_id> | Title: ... | Authors: ... | Start Date: ... | Progress: <progress>/<page_count>"
      if selected_item =~ /\| Book ID:\s*(\d+)\s*\|/
        book_id = $1.to_i
        new_total_pages = Helpers.get_simple_string("Update Total Pages", "Enter the new total pages value:")
        if new_total_pages.nil? || new_total_pages.strip.empty? || new_total_pages !~ /^\d+$/
          Helpers.show_error("Invalid Input", "Please enter a valid number for total pages.")
        else
          new_total_pages = new_total_pages.to_i
          BookDatabase.db.execute("UPDATE books SET page_count = ? WHERE id = ?", [new_total_pages, book_id])
          Helpers.show_info("Updated", "Total pages updated successfully.")
          # Refresh the currently reading listbox.
          BookDatabase.update_current_book_listbox(current_listbox)
        end
      else
        Helpers.show_error("Error", "Could not determine the Book ID from the selection.")
      end
    end
    pack('side' => 'left', 'padx' => 5)
  end
  
end