require 'tk'
require_relative 'database'
require_relative 'google_books'
require_relative 'manual_entry'
require_relative 'automatic_entry'
require_relative 'currently_reading'
require_relative 'helpers'

# Initialize database
BookDatabase.init

# Create main window
root = TkRoot.new do
  title "Google Books ISBN Lookup"
  minsize(400, 600)
end

# Listbox to display all books
book_listbox = TkListbox.new(root) do
  width 60
  height 10
  pack('padx' => 10, 'pady' => 10, 'fill' => 'both', 'expand' => true)
end

# Initially update listbox
BookDatabase.update_listbox(book_listbox)

buttons_frame = TkFrame.new(root) do
  pack('padx' => 10, 'pady' => 10, 'fill' => 'x')
end

TkButton.new(buttons_frame) do
  text "Delete Selected"
  command do
    selected_index = book_listbox.curselection.first rescue nil
    if selected_index.nil?
      Tk.messageBox('type' => 'ok', 'icon' => 'warning', 'title' => 'No Selection', 'message' => 'Please select a book to delete.')
      next
    end

    selected_item = book_listbox.get(selected_index)
    # CHATGPT help with validating the entry
    if selected_item =~ /^ID:\s*(\d+)\s*\|/
      book_id = $1.to_i
      response = Tk.messageBox('type' => 'yesno', 'icon' => 'question', 'title' => 'Confirm Deletion', 'message' => 'Are you sure you want to delete the selected book?')
      if response == 'yes'
        BookDatabase.delete_book(book_id)
        BookDatabase.update_listbox(book_listbox)
      end
    else
      Tk.messageBox('type' => 'ok', 'icon' => 'warning', 'title' => 'Error', 'message' => 'Could not determine the book ID.')
    end
  end
  pack('side' => 'left', 'padx' => 5)
end

# Button to create manual entry
TkButton.new(buttons_frame) do
  text "Add Manual Entry"
  command do
    open_manual_entry_window(book_listbox, root)
  end
  pack('side' => 'left', 'padx' => 5)
end

TkButton.new(buttons_frame) do
  text "View Currently Reading"
  command do
    open_current_books_window(root)
  end
  pack('side' => 'left', 'padx' => 5)
end

TkButton.new(buttons_frame) do
  text "Add Selected Book to Currently Reading"
  command do
    selected_index = book_listbox.curselection.first rescue nil
    if selected_index.nil?
      Helpers.show_error("No Selection", "Please select a book first.")
      next
    end

    selected_item = book_listbox.get(selected_index)
    # Expecting the listbox item format: "ID: <id> | <isbn> | <title> | <authors>"
    if selected_item =~ /^ID:\s*(\d+)\s*\|/
      book_id = $1.to_i
      start_date = Helpers.get_simple_string("Start Date", "Enter the start date (YYYY-MM-DD):")
      progress = Helpers.get_simple_string("Progress", "Enter progress (number of pages read, leave blank for 0):")
      progress = progress.strip.empty? ? 0 : progress.to_i

      BookDatabase.add_current_book(book_id, start_date, progress)
      Helpers.show_info("Book Added", "The book has been added to your currently reading list.")
    else
      Helpers.show_error("Error", "Could not determine the book ID from the selection.")
    end
  end
  pack('side' => 'left', 'padx' => 5)
end


search_frame = TkFrame.new(root) do
  pack('padx' => 10, 'pady' => 10, 'fill' => 'x')
end

TkLabel.new(search_frame) do
  text "Enter ISBN:"
  pack('padx' => 10, 'pady' => 10)
end

isbn_var = TkVariable.new
TkEntry.new(search_frame) do
  textvariable isbn_var
  width 30
  pack('padx' => 10, 'pady' => 5)
end

TkButton.new(search_frame) do
  text "Search"
  command do
    isbn = isbn_var.value
    if isbn.strip.empty?
      Tk.messageBox('type' => 'ok', 'icon' => 'warning', 'title' => 'Input Error', 'message' => 'Please enter an ISBN.')
      next
    end

    begin
      data = AutomaticEntry.lookup_and_extract(isbn)
      if data.nil?
        Tk.messageBox('type' => 'ok', 'icon' => 'info', 'title' => 'Lookup Result', 'message' => "No book found for that ISBN.")
      else
        # Before inserting, check if ISBN already exists
        existing = BookDatabase.db.get_first_value("SELECT COUNT(*) FROM books WHERE isbn = ?", [data[:isbn]])
        if existing.to_i > 0
          Tk.messageBox('type' => 'ok', 'icon' => 'info', 'title' => 'Duplicate ISBN', 'message' => "A book with ISBN \"#{data[:isbn]}\" already exists in the database.")
        else
          BookDatabase.insert_book(data)
          Tk.messageBox('type' => 'ok', 'icon' => 'info', 'title' => 'Book Added', 'message' => "The book titled \"#{data[:title]}\" was added to the database.")
          BookDatabase.update_listbox(book_listbox)
        end
      end
    rescue StandardError => e
      Tk.messageBox('type' => 'ok', 'icon' => 'error', 'title' => 'Error', 'message' => "An error occurred: #{e.message}")
    end
  end
  pack('padx' => 10, 'pady' => 10)
end

Tk.mainloop