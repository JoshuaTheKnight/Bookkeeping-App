require 'tk'
require_relative 'database'

# opens a manual entry window.
# Params: listbox - the main listbox widget to update after an entry is added, root - the main application window
def open_manual_entry_window(listbox, root)
  manual_win = TkToplevel.new(root) do
    title "Manual Book Entry"
    minsize(300, 400)
  end

  TkLabel.new(manual_win) do
    text "Fill in the fields below. Leave any fields blank if unknown."
    pack('padx' => 5, 'pady' => 5)
  end

  # Define manual entry fields
  fields = {
    isbn: "ISBN",
    title: "Title",
    authors: "Authors (comma separated)",
    publisher: "Publisher",
    published_date: "Published Date",
    description: "Description",
    categories: "Categories (comma separated)",
    page_count: "Page Count",
    maturity_rating: "Maturity Rating",
    language: "Language"
  }

  entry_vars = {}
  fields.each do |field, label_text|
    TkLabel.new(manual_win) { text label_text; pack('padx' => 5, 'pady' => 2, 'anchor' => 'w') }
    var = TkVariable.new
    entry_vars[field] = var
    TkEntry.new(manual_win) { textvariable var; pack('padx' => 5, 'pady' => 2, 'fill' => 'x') }
  end

  # Validate ISBN format.
  def valid_isbn?(isbn)
    cleaned = isbn.gsub(/[-\s]/, '')
    if cleaned.length == 10
      (cleaned[0..8] =~ /^\d{9}$/) && (cleaned[9] =~ /^[\dXx]$/)
    elsif cleaned.length == 13
      cleaned =~ /^\d{13}$/
    else
      false
    end
  end

  TkButton.new(manual_win) do
    text "Submit"
    command do
      data = {
        isbn: entry_vars[:isbn].value.strip,
        title: entry_vars[:title].value.strip,
        authors: entry_vars[:authors].value.strip,
        publisher: entry_vars[:publisher].value.strip,
        published_date: entry_vars[:published_date].value.strip,
        description: entry_vars[:description].value.strip,
        categories: entry_vars[:categories].value.strip,
        page_count: entry_vars[:page_count].value.strip,
        maturity_rating: entry_vars[:maturity_rating].value.strip,
        language: entry_vars[:language].value.strip,
        # Set fields not provided manually to defaults.
        industry_identifiers: nil,
        preview_link: "",
        info_link: "",
        image_links: nil,
        sale_info: nil,
        access_info: nil,
        search_info: nil,
        average_rating: nil,
        ratings_count: nil
      }

      unless valid_isbn?(data[:isbn])
        Tk.messageBox('type' => 'ok', 'icon' => 'warning', 'title' => 'Invalid ISBN', 'message' => 'Please enter a valid ISBN.')
        next
      end
      #CHATGPT assist with regex
      if !data[:page_count].empty? && data[:page_count] !~ /^\d+$/
        Tk.messageBox('type' => 'ok', 'icon' => 'warning', 'title' => 'Invalid Input', 'message' => 'Page Count must be an integer.')
        next
      end

      # Convert page_count to an integer; default to 0 if blank.
      data[:page_count] = data[:page_count].empty? ? 0 : data[:page_count].to_i

      BookDatabase.insert_book(data)
      Tk.messageBox('type' => 'ok', 'icon' => 'info', 'title' => 'Book Added', 'message' => "The book titled \"#{data[:title]}\" was added to the database.")
      BookDatabase.update_listbox(listbox)
      manual_win.destroy
    end
    pack('padx' => 10, 'pady' => 10)
  end
end
