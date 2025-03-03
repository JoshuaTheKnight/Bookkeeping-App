require 'tk'

module Helpers
  # Opens a simple dialog to get a string input from the user.
  def self.get_simple_string(title, prompt)
    input = nil
    dialog = TkToplevel.new do
      title title
      minsize(300, 100)
    end

    TkLabel.new(dialog) do
      text prompt
      pack('padx' => 10, 'pady' => 10)
    end

    var = TkVariable.new

    TkEntry.new(dialog) do
      textvariable var
      pack('padx' => 10, 'pady' => 5)
    end

    TkButton.new(dialog) do
      text "OK"
      command do
        input = var.value
        dialog.destroy
      end
      pack('padx' => 10, 'pady' => 10)
    end

    dialog.grab_set    # Make the dialog modal
    dialog.wait_window # Wait until it's closed
    input
  end

  # Opens a confirmation dialog with yes/no options.
  # Returns true if the user clicks 'yes', false otherwise.
  def self.confirm_dialog(title, message)
    response = Tk.messageBox(
      'type'    => 'yesno',
      'icon'    => 'question',
      'title'   => title,
      'message' => message
    )
    response == 'yes'
  end

  # Validates an ISBN (10-digit with optional X or 13-digit numeric).
  # Returns true if valid; otherwise false.
  def self.valid_isbn?(isbn)
    cleaned = isbn.gsub(/[-\s]/, '')
    if cleaned.length == 10
      # First 9 must be digits and last either a digit or 'X'/'x'
      (cleaned[0..8] =~ /^\d{9}$/) && (cleaned[9] =~ /^[\dXx]$/)
    elsif cleaned.length == 13
      cleaned =~ /^\d{13}$/
    else
      false
    end
  end

  # Displays an information message box.
  def self.show_info(title, message)
    Tk.messageBox(
      'type'    => 'ok',
      'icon'    => 'info',
      'title'   => title,
      'message' => message
    )
  end

  # Displays an error message box.
  def self.show_error(title, message)
    Tk.messageBox(
      'type'    => 'ok',
      'icon'    => 'error',
      'title'   => title,
      'message' => message
    )
  end
end
