#!/usr/bin/env -S vala workbench.vala --pkg libadwaita-1 --pkg libportal-gtk4

private Xdp.Portal portal;
private Xdp.Parent parent;

private Gtk.Button button;
private Gtk.Entry entry;

public void main () {
  portal = new Xdp.Portal ();
  parent = Xdp.parent_new_gtk (workbench.window);

  button = (Gtk.Button) workbench.builder.get_object ("button");
  entry = (Gtk.Entry) workbench.builder.get_object ("entry");

  button.clicked.connect (on_button_clicked);
}

private async void on_button_clicked () {
  try {
    string email_address = entry.text;

    bool success = yield portal.compose_email (
      parent, // parent
      {email_address}, // addresses
      null, // cc
      null, // bcc
      "Email from Workbench", // subject
      "Hello World", // body
      null, // attachments
      NONE, // flags
      null // Cancellable
    );

    if (success) {
      message ("Success");
    } else {
      message ("Failure, verify that you have an email application");
    }
  }
  catch (Error e) {
    error (e.message);
  }
}
