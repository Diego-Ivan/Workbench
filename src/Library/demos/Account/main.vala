#!/usr/bin/env -S vala workbench.vala --pkg libadwaita-1 --pkg libportal-gtk4

private Xdp.Portal portal;
private Xdp.Parent parent;

private Gtk.Revealer revealer;
private Gtk.Button button;
private Adw.Avatar avatar;
private Adw.EntryRow entry;
private Gtk.Label username;
private Gtk.Label display;

public void main () {
  portal = new Xdp.Portal ();
  parent = Xdp.parent_new_gtk (workbench.window);

  revealer = (Gtk.Revealer) workbench.builder.get_object ("revealer");
  button = (Gtk.Button) workbench.builder.get_object ("button");
  avatar = (Adw.Avatar) workbench.builder.get_object ("avatar");
  entry = (Adw.EntryRow) workbench.builder.get_object ("entry");
  username = (Gtk.Label) workbench.builder.get_object ("username");
  display = (Gtk.Label) workbench.builder.get_object ("name");

  button.clicked.connect (on_button_clicked);
}

public async void on_button_clicked () {
  string reason = entry.text;
  try {
    Variant user_info = yield portal.get_user_information (parent, reason, NONE, null);

    string id = (string) user_info.lookup_value ("id", VariantType.STRING);
    string name = (string) user_info.lookup_value ("name", VariantType.STRING);
    string uri = (string) user_info.lookup_value ("image", VariantType.STRING);

    var file = File.new_for_uri (uri);
    var texture = Gdk.Texture.from_file (file);

    username.label = id;
    display.label = name;
    avatar.custom_image = texture;
    revealer.reveal_child = true;

    entry.text = "";
    message ("Information Retrieved");
  }
  catch (Error e) {
    error (e.message);
  }
}
